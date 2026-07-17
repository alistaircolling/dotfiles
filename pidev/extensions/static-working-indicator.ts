// Use a static working indicator to avoid the default spinner's 80ms TUI redraws.
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.on("session_start", (_event, ctx) => {
    ctx.ui.setWorkingIndicator({
      frames: [ctx.ui.theme.fg("accent", "●")],
    });
  });
}
