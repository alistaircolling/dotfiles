# Dynamic workflow templates

Saved [dynamic workflows](https://x.com/trq212/status/2061907337154367865) for Claude Code —
custom multi-agent harnesses Claude runs via the `Workflow` tool. Symlinked to
`~/.claude/workflows/` by `setup.sh`, so they're available by name in every session
and shared across both accounts.

## Run one

```
Workflow({ name: "verify-claims", args: "blog-draft.md" })
```

Or just ask Claude in plain language ("use a workflow to verify the claims in this draft"),
or prefix a prompt with `ultracode` to force one.

## The templates

| File | Does | args |
|------|------|------|
| `verify-claims.js` | Verify every claim in a doc against the codebase, then audit the verdicts | path, or `{ path }` / `{ text }` |
| `flaky-test-hunter.js` | Reproduce → theorize → adversarially test in worktrees, loop until a theory holds | `{ test, command?, rate?, maxRounds? }` |
| `root-cause.js` | Disjoint-evidence investigation → hypotheses → verifier/refuter panel | question, or `{ question, sources? }` |
| `rename-symbol.js` | Find all callsites, edit each file in parallel, review, verify build | `{ from, to, note? }` |
| `naming-tournament.js` | Brainstorm names from several angles, pairwise tournament, top 3 | subject, or `{ subject, constraints?, rubric? }` |
| `qualitative-sort.js` | Rank a list by a qualitative measure via pairwise comparisons | `{ items, criterion }` |
| `triage-backlog.js` | Classify → dedupe vs tracked → act/escalate, with a quarantine rule | `{ items, tracked? }` |

These are **templates** — Claude reads and adapts them to the task rather than running them
verbatim. The `workflows` skill (`claude/skills/workflows/`) documents the patterns and when
to reach for each. Workflows cost more tokens, so use them for tasks that genuinely need the
extra compute.

## Add a new one

Each script starts with a literal `export const meta = { name, description, phases }` block,
then uses `agent() / parallel() / pipeline() / phase() / log()`. Save a workflow Claude wrote
by pressing `s` in the workflow menu and dropping the file here.
