---
name: resolve-comments
description: Walk through unresolved PR review comments one by one so the user can address them in their editor. Accepts a PR number or ticket number.
---

# Resolve Comments

Walk through unresolved PR review comments one by one so the user can address them in their editor.

Use the PR number or ticket number supplied with the skill invocation. If none was supplied, ask for it before continuing. Call this value `<query>` below and substitute its actual value in every command.

## Steps

1. Detect the current GitHub repo using `gh repo view --json nameWithOwner -q .nameWithOwner`.

2. Try to fetch the PR directly by number. If the PR is not found, fall back to searching by branch name:

```bash
gh pr list --search "<query>" --json number,title,headRefName --limit 10
```

Look for a PR whose branch name contains the argument (e.g. branch `feature/abc-1820-fix-upload-flow` matches argument `1820`). If exactly one match is found, use that PR number. If multiple matches are found, show them and ask the user which one to use. If none are found, tell the user and stop.

3. Fetch all unresolved review threads for the resolved PR number using the GitHub GraphQL API:

```bash
gh api graphql -f query='
query {
  repository(owner: "OWNER", name: "REPO") {
    pullRequest(number: PR_NUMBER) {
      title
      reviewThreads(first: 100) {
        nodes {
          isResolved
          isOutdated
          path
          line
          startLine
          comments(first: 20) {
            nodes {
              body
              author { login }
              createdAt
            }
          }
        }
      }
    }
  }
}'
```

Replace OWNER, REPO, and PR_NUMBER with actual values.

4. Filter to only threads where `isResolved` is `false`.

5. If there are no unresolved threads, tell the user and stop.

6. Show a summary line: **X unresolved comments on PR #N: "PR Title"**

7. Present each unresolved thread ONE AT A TIME in this format:

```
### Comment [current/total]

**File:** `path/to/file.ts` Line(s): 42-50
**Author:** @username
**Posted:** relative time ago

> quoted comment body

(If there are reply comments in the thread, show them indented below the original)
```

8. After displaying each comment, ask the user:
   - `Continue to next comment? (y/n/skip to #N)`
   - If the user says no or stop, end the walkthrough
   - If the user says skip to a number, jump to that comment
   - If the user says yes or presses enter, show the next comment

9. After the last comment, show: **All unresolved comments reviewed.**

## Rules

- Always show the file path and line numbers clearly so the user can jump to them in vim
- If `startLine` exists and differs from `line`, show the range (e.g., Lines 42-50)
- If `startLine` is null, just show the single line number
- Mark outdated comments with `(outdated)` next to the file path
- Show all replies in a thread together - don't split them into separate prompts
- Keep formatting clean and scannable
