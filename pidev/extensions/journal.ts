// Safety-net journal hook — captures git state after each prompt.
// - Calls the shared journal-hook.sh (same script Claude uses)
// - Fire-and-forget to avoid blocking the UI
// - 5-min debounce per project (handled by the script)
// - Skips if a narrative entry already exists
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.on("agent_end", async () => {
    pi.exec("bash", ["/Users/Shared/dotfiles/claude/journal-hook.sh"], {
      env: { ...process.env, CLAUDE_WORKING_DIRECTORY: process.cwd() },
      timeout: 10000,
    }).catch(() => {});
  });
}
