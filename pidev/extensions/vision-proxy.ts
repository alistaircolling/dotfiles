/**
 * Vision Proxy Extension
 *
 * When the current model lacks vision capability, this extension transparently
 * proxies image reads through a vision-capable API (default: Google Antigravity).
 *
 * The model calls `read(path)` on an image file as normal. The extension
 * intercepts, sends the image to a vision model for analysis, and returns a
 * text description — so the primary model never sees raw image bytes.
 *
 * Two modes (controlled by the prompt the model passes):
 *   read("screenshot.png")                    → auto-describe (compact)
 *   read("screenshot.png", offset=1, limit=1) → "Describe this image concisely"
 *     (offset/limit mean nothing for images; we piggyback on offset as a
 *      hint: 1 = compact, 2 = detailed, 3+ = identify UI elements)
 *
 * Alternatively, the model can pass a question via the path:
 *   read("screenshot.png?q=What buttons are visible?")
 *
 * Provider priority: Google Antigravity (Gemini) → Anthropic Claude (Sonnet).
 * Each provider resolves its token from an env var or the pi OAuth token.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { createReadTool } from "@earendil-works/pi-coding-agent";
import { readFile } from "node:fs/promises";
import { extname, resolve as resolvePath } from "node:path";
import { existsSync, readFileSync } from "node:fs";
import { homedir } from "node:os";

const IMAGE_EXTENSIONS = new Set([
  ".jpg",
  ".jpeg",
  ".png",
  ".gif",
  ".webp",
  ".bmp",
]);

const EXT_TO_MIME: Record<string, string> = {
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".png": "image/png",
  ".gif": "image/gif",
  ".webp": "image/webp",
  ".bmp": "image/bmp",
};

interface ProviderConfig {
  name: string;
  /** Get the active API key/token (reads from env or pi auth file) */
  resolveToken: () => string | null;
  /** Call the vision API */
  call: (
    token: string,
    base64Image: string,
    mimeType: string,
    prompt: string,
    signal?: AbortSignal
  ) => Promise<string>;
}

// ── Provider: Anthropic ──────────────────────────────────────────────

const anthropicProvider: ProviderConfig = {
  name: "anthropic",
  resolveToken() {
    // 1. Env var
    if (process.env.ANTHROPIC_API_KEY) return process.env.ANTHROPIC_API_KEY;

    // 2. pi OAuth token from auth.json
    const token = readPiOAuthToken("anthropic");
    if (token) return token;

    return null;
  },
  async call(token, base64Image, mimeType, prompt, signal) {
    const mediaType = mimeType === "image/jpeg" ? "image/jpeg" : mimeType;

    const body = {
      // If we fall back to Claude for vision, we must use Sonnet.
      model: "claude-sonnet-5",
      max_tokens: 1024,
      system:
        "You are an image analysis assistant. Describe the image in clear, concise detail. Focus on what is practically useful for a developer: UI layout, text content, error messages, data shown, visual structure. Be thorough but direct. Use plain text only — no markdown.",
      messages: [
        {
          role: "user",
          content: [
            {
              type: "image",
              source: {
                type: "base64",
                media_type: mediaType as any,
                data: base64Image,
              },
            },
            { type: "text", text: prompt },
          ],
        },
      ],
    };

    const response = await fetch("https://api.anthropic.com/v1/messages", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-api-key": token,
        "anthropic-version": "2023-06-01",
      },
      body: JSON.stringify(body),
      signal,
    });

    if (!response.ok) {
      const errText = await response.text().catch(() => "unknown error");
      throw new Error(`Anthropic API error ${response.status}: ${errText.slice(0, 300)}`);
    }

    const data = (await response.json()) as any;
    const text = data.content
      ?.filter((c: any) => c.type === "text")
      .map((c: any) => c.text)
      .join("\n");

    if (!text) throw new Error("No text content in Anthropic response");
    return text;
  },
};

// ── Provider: Google Gemini (antigravity) ────────────────────────────

const geminiProvider: ProviderConfig = {
  name: "google-antigravity",
  resolveToken() {
    if (process.env.GEMINI_API_KEY) return process.env.GEMINI_API_KEY;

    // pi OAuth token
    const token = readPiOAuthToken("google-antigravity");
    if (token) return token;

    // Also try the GENERATIVE_LANGUAGE_API_KEY env var some tools set
    if (process.env.GOOGLE_API_KEY) return process.env.GOOGLE_API_KEY;
    if (process.env.GOOGLE_GENERATIVE_AI_API_KEY)
      return process.env.GOOGLE_GENERATIVE_AI_API_KEY;

    return null;
  },
  async call(token, base64Image, mimeType, prompt, signal) {
    // Gemini API uses inline data
    const body = {
      contents: [
        {
          parts: [
            { text: prompt },
            {
              inline_data: {
                mime_type: mimeType,
                data: base64Image,
              },
            },
          ],
        },
      ],
      generationConfig: {
        maxOutputTokens: 1024,
        temperature: 0,
      },
    };

    // Google OAuth tokens work with the Gemini API via the standard endpoint
    // with Bearer auth
    const response = await fetch(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-001:generateContent",
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
          ...(token.startsWith("ya29.")
            ? {}
            : { "x-goog-api-key": token }),
        },
        body: JSON.stringify(body),
        signal,
      }
    );

    if (!response.ok) {
      const errText = await response.text().catch(() => "unknown error");
      throw new Error(
        `Gemini API error ${response.status}: ${errText.slice(0, 300)}`
      );
    }

    const data = (await response.json()) as any;
    const text = data.candidates?.[0]?.content?.parts
      ?.map((p: any) => p.text)
      .join("\n");

    if (!text) throw new Error("No text content in Gemini response");
    return text;
  },
};

// ── Helpers ──────────────────────────────────────────────────────────

function readPiOAuthToken(providerName: string): string | null {
  try {
    const authPath = resolvePath(homedir(), ".pi", "agent", "auth.json");
    if (!existsSync(authPath)) return null;
    const auth = JSON.parse(readFileSync(authPath, "utf-8"));
    const provider = auth[providerName];
    if (provider?.type === "oauth" && provider.access) {
      return provider.access;
    }
    if (provider?.type === "api_key" && provider.key) {
      return provider.key;
    }
    return null;
  } catch {
    return null;
  }
}

function resolveAbsolutePath(
  rawPath: string,
  cwd: string
): string {
  if (rawPath.startsWith("/")) return rawPath;
  if (rawPath.startsWith("~/"))
    return resolvePath(homedir(), rawPath.slice(2));
  return resolvePath(cwd, rawPath);
}

function parseQuestionFromPath(rawPath: string): {
  path: string;
  question: string | null;
} {
  // Model might pass "screenshot.png?q=What is this?"
  if (rawPath.includes("?")) {
    const [path, query] = rawPath.split("?", 2);
    const params = new URLSearchParams(query);
    const q = params.get("q") || params.get("question");
    return { path: path!, question: q || null };
  }
  return { path: rawPath, question: null };
}

function buildPrompt(rawPath: string, question: string | null): string {
  if (question) return question;

  // Use the "offset" param as hint level if it looks intentional
  // (model might say offset=1 for brief, 2 for detailed, 3 for UI analysis)
  // We parse the raw path to extract offset-like hints
  const lower = rawPath.toLowerCase();

  // Auto-detect context from filename hints
  if (
    lower.includes("screenshot") ||
    lower.includes("screen") ||
    lower.includes("ui") ||
    lower.includes("error")
  ) {
    return "Describe this image in detail. What UI elements, text, data, errors, or notable information is visible? Be thorough — include all text you can read.";
  }

  if (
    lower.includes("diagram") ||
    lower.includes("arch") ||
    lower.includes("flow")
  ) {
    return "Describe this diagram in detail. What components, connections, and structure is shown? What does it represent?";
  }

  if (
    lower.includes("photo") ||
    lower.includes("pic") ||
    lower.includes("img")
  ) {
    return "Describe this image in detail. What do you see?";
  }

  // Default
  return "Describe this image concisely but thoroughly. Include all visible text, UI elements, data, and notable details.";
}

// ── Extension ────────────────────────────────────────────────────────

export default function (pi: ExtensionAPI) {
  const cwd = process.cwd();

  // Track model vision capability
  let supportsVision = true; // Default to true until model_select fires

  pi.on("model_select", (event) => {
    const model = event.model as any;
    const input = model?.input;
    supportsVision = Array.isArray(input) ? input.includes("image") : true;
  });

  // Resolve best available provider once at startup.
  // Antigravity (Gemini) is the default; Claude/Sonnet is the fallback.
  function getBestProvider(): ProviderConfig | null {
    for (const p of [geminiProvider, anthropicProvider]) {
      if (p.resolveToken()) return p;
    }
    return null;
  }

  // Session-start: show vision proxy status
  pi.on("session_start", async (_event, ctx) => {
    const provider = getBestProvider();
    if (!supportsVision) {
      if (provider) {
        ctx.ui.setStatus(
          "vision",
          `👁 Vision proxy active → ${provider.name}`
        );
      } else {
        ctx.ui.setStatus(
          "vision",
          "⚠ No vision API — images will be invisible"
        );
      }
    }
  });

  // ── Handle clipboard-pasted images via the input event ──
  // When the user pastes an image (Ctrl+V) and the model lacks vision,
  // replace the image data with a text description.
  pi.on("input", async (event, ctx) => {
    if (supportsVision) return; // model can see images, nothing to do
    if (!event.images || event.images.length === 0) return;

    const provider = getBestProvider();
    if (!provider) return; // can't help

    const token = provider.resolveToken();
    if (!token) return;

    // Replace each image with a text description
    const descriptions: string[] = [];
    for (const img of event.images) {
      try {
        const desc = await provider.call(
          token,
          img.data,
          img.mimeType || "image/png",
          "Describe this image concisely but thoroughly. Include all visible text, UI elements, data, and notable details.",
          ctx.signal
        );
        descriptions.push(`[Pasted image]: ${desc}`);
      } catch {
        descriptions.push("[Pasted image — analysis failed]");
      }
    }

    if (descriptions.length > 0) {
      const prefix = event.text ? `${event.text}\n\n` : "";
      return {
        action: "transform" as const,
        text: `${prefix}${descriptions.join("\n\n")}`,
        images: [], // Remove raw image data
      };
    }
  });

  // ── Override read tool for image files ──
  const originalRead = createReadTool(cwd);

  pi.registerTool({
    ...originalRead,
    async execute(
      toolCallId: string,
      params: { path?: string; file_path?: string; offset?: number; limit?: number },
      signal: AbortSignal | undefined,
      onUpdate: any,
      _ctx: any
    ): Promise<any> {
      const rawPath = params.path || params.file_path || "";
      const { path: cleanPath, question } = parseQuestionFromPath(rawPath);
      const ext = extname(cleanPath).toLowerCase();

      // Not an image → delegate to original
      if (!IMAGE_EXTENSIONS.has(ext)) {
        return originalRead.execute(toolCallId, params, signal, onUpdate);
      }

      // Model supports vision → delegate to original
      if (supportsVision) {
        return originalRead.execute(toolCallId, params, signal, onUpdate);
      }

      // ── Image + non-vision model → proxy ──
      const absolutePath = resolveAbsolutePath(cleanPath, cwd);
      const prompt = buildPrompt(rawPath, question);

      const provider = getBestProvider();
      if (!provider) {
        return {
          content: [
            {
              type: "text",
              text: `Error: Cannot analyze image "${cleanPath}". No vision provider (Anthropic/Gemini) available. Set ANTHROPIC_API_KEY or GEMINI_API_KEY.`,
            },
          ],
          isError: true,
          details: {},
        };
      }

      const token = provider.resolveToken()!;

      try {
        const imageBuffer = await readFile(absolutePath);
        const base64 = imageBuffer.toString("base64");
        const mimeType = EXT_TO_MIME[ext] || "application/octet-stream";

        const description = await provider.call(
          token,
          base64,
          mimeType,
          prompt,
          signal
        );

        return {
          content: [
            {
              type: "text",
              text: `[Image analyzed via ${provider.name}]\n\n${description}`,
            },
          ],
          details: {
            proxied: true,
            provider: provider.name,
          },
        };
      } catch (err: any) {
        return {
          content: [
            {
              type: "text",
              text: `Error analyzing image "${cleanPath}" via ${provider.name}: ${err.message}`,
            },
          ],
          isError: true,
          details: {},
        };
      }
    },
  });
}
