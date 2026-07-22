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
3. Wait ~10s, confirm detection with `herdr agent list`, then name it: `herdr agent rename <pane-id> <name>`.
4. Drive it normally: `herdr agent prompt <name> "…" --wait`.

The same `command <binary>` trick applies to any other agent that's shadowed by a WezTerm-wrapping shell function.
