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

- **Prompt**: <what the user asked>
- **Type**: <code | research | planning | review | project-management | devops | other>

### What I did
<brief description of actions taken>

### How I did it
<brief technical description of approach>

### Challenges
<any obstacles or interesting decisions>

### Future work
- <suggested improvements or follow-ups, if any>

---
```

$ARGUMENTS
