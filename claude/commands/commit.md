Stage and commit all currently unstaged changes with a conventional commit message.

## Instructions

1. Run `git status` to see all modified and untracked files
2. Run `git diff` and `git diff --cached` to understand what changed
3. Determine the ticket/task ID:
   - Extract it from the current branch name (e.g., `your-name/abc-1234-description` → `ABC-1234`)
   - If no ticket ID is found in the branch name, check if Linear MCP tools are available and look up the current work
   - If still no ticket ID, ask the user
4. Determine the appropriate conventional commit prefix based on the changes:
   - `feat:` — new feature or functionality
   - `fix:` — bug fix
   - `chore:` — maintenance, dependencies, config changes
   - `docs:` — documentation only
   - `refactor:` — code restructuring with no behavior change
   - `style:` — formatting, whitespace, linting
   - `test:` — adding or updating tests
   - `perf:` — performance improvement
5. Draft a commit message in this format:
   ```
   prefix(TICKET-ID): short description of what changed
   ```
   Example: `feat(ABC-1234): add social login buttons to signup page`
6. **Show the user the draft commit message and the list of files that will be staged.** Wait for their approval or edits before proceeding.
7. Once approved, stage all relevant files with `git add` and commit with the agreed message
