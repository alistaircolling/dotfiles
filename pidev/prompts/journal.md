---
description: Write a development journal entry for the current session
---
Write a development journal entry for the work done in this session.

The journal lives at `~/Development/dev-journal/entries/`.
Each day gets one file named `YYYY-MM-DD.md` (e.g., `2026-03-18.md`).

**Rules:**
- If today's file already exists, **append** a new entry section to it (do not overwrite).
- If it doesn't exist, create it with a top-level heading `# YYYY-MM-DD`.
- Determine the project name from the current working directory.
- After writing the entry, `cd` into the journal repo, stage, and commit with message "journal: <project> - <brief summary>".
- **Track ALL tasks**, not just code changes. This includes:
  - Updating Linear tickets, Jira, or other project management tools
  - Research conversations and findings
  - PR reviews and feedback given
  - Debugging sessions (even if no fix was applied)
  - Planning, architecture discussions, or design decisions
  - DevOps, deployment, or infrastructure work
  - Any other meaningful work done in the session

**Entry format:**

```
## <HH:MM> — <project name>: <brief task title>

<1-3 sentence narrative: what, why, and any key decisions or findings>

**Type**: code | research | planning | review | project-management | devops | debugging | other
**Refs**: <PR #, Linear ticket, branch name, or "none">

---
```

$ARGUMENTS
