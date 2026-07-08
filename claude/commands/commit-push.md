Stage all uncommitted changes, commit them as separate commits grouped by related work, then push.

## Instructions

1. Run `git status` and `git diff` / `git diff --cached` to see every modified and untracked file and understand what changed.
2. **Group the changes into logical units** — one commit per related concern, not one commit per file and not everything in one commit. Files that change together for the same reason belong in the same commit; unrelated concerns get their own commit.
3. Exclude files that should not be committed (stray temp/build artifacts, e.g. `*.tmp`, editor swap files). Flag anything you skip rather than committing it silently.
4. For each group, choose a conventional-commit prefix (`feat` / `fix` / `chore` / `docs` / `refactor` / `style` / `test` / `perf`) and a `scope`, then write:
   ```
   prefix(scope): short description of what changed
   ```
5. Commit each group with only its files: `git add <those files>` then `git commit -F <message-file>` (write the message to a scratchpad file — inline `-m` with special characters can hang the harness shell).
6. After all groups are committed, run `git push`.
7. Report the commits made (and anything deliberately excluded).

Notes:
- If on the repo's default/PR branch and this is shared work, branch first; for a personal repo that commits to its main branch directly, committing there is fine.
- End each commit message with the co-author trailer if that is the repo convention.
