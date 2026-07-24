# Global Agent Instructions

## Clipboard behavior

Whenever you suggest a command, shell snippet, or URL that the user should run or visit themselves (i.e. you are NOT executing it via bash), automatically copy it to the user's clipboard by running `printf '%s' "<the command or URL>" | pbcopy` via bash, then tell the user it has been copied. Do not do this for commands you are executing yourself.

## Sudo commands

Never run `sudo` commands directly. Instead, provide the exact command to the user and copy to their clipboard so they can run it themselves.


## Linear API access

Pi.dev does not have MCP support. To access Linear, use the GraphQL API via `curl` with the `$LINEAR_API_KEY` environment variable:

```bash
curl -s -X POST https://api.linear.app/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: $LINEAR_API_KEY" \
  -d '{"query": "{ issue(id: \"ABC-1234\") { title description state { name } assignee { name } } }"}'
```

If `$LINEAR_API_KEY` is not set, inform the user and skip Linear-dependent steps.

## Starting Claude in a Herdr pane

Do NOT use `herdr agent start … --kind claude` in this environment. My `claude` command is a zsh function (`/Users/Shared/dotfiles/shell/wez-claude.zsh`) that launches Claude inside a **WezTerm** pane split. Herdr's `agent start` types `claude`, which triggers that function and fails with `pane_id 0 invalid` / `Split failed` (WezTerm CLI can't drive a split from inside Herdr).

Instead:

1. Create the pane: `herdr pane split --current --direction right --cwd "$PWD" --no-focus` → read `.result.pane.pane_id`.
2. Run the REAL binary (the `command` builtin bypasses the function):
   `herdr pane run <pane-id> "command claude --permission-mode auto"`
3. Poll for detection every 1s instead of one long sleep, e.g.:
   `for i in $(seq 1 20); do herdr agent list | grep -q '"pane_id":"<pane-id>"' && break; sleep 1; done`
   then name it: `herdr agent rename <pane-id> <name>`.
4. As soon as it's detected (usually within 1-2s), instruct it right away: `herdr agent prompt <name> "…" --wait`. No extra delay needed — the poll in step 3 already gates on readiness, so a sub-agent can be launched and instructed within a second or two.

Keep all waits in this flow to a 1-second poll cadence rather than long fixed sleeps, so sub-agents launch and get instructed quickly.

The same `command <binary>` trick applies to any other agent that's shadowed by a WezTerm-wrapping shell function.

## Deploying pi sub-agents via Herdr

When the user says "deploy pi subagents" or asks to spin up pi agents in panes, always use `herdr agent start --kind pi`. Do **not** launch Claude or any other agent kind. Pi does not have a WezTerm-wrapping shell function, so plain `herdr agent start <name> --kind pi --pane <id>` works directly — no `command` trick needed.
