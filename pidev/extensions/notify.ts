// Play a sound when the agent finishes responding.
// - Replicates Claude Code's Stop and Notification hooks
// - Fire-and-forget to avoid blocking the UI
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.on("agent_end", async () => {
    pi.exec("afplay", ["/System/Library/Sounds/Morse.aiff"]).catch(() => {});
  });
}
