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
