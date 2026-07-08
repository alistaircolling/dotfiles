---
name: plan-no-context
description: Write a self-contained implementation plan to a markdown file. Asks the user about any decisions with multiple options (with a recommendation) before writing, and ensures the resulting plan can be executed by an agent with no prior context.
---

For the following changes, write an implementation plan in a markdown file. If there are multiple options for any decisions in this plan, ask me questions along with options and a recommended option before proceeding, then write the plan and ensure the plan can be implemented by an agent with no context other than what is in the plan.

## How to ask questions

Use the **AskUserQuestion tool** for every decision that has multiple viable options. Ask one question at a time. For each question, provide 2–4 concrete options, with the recommended option listed first and labeled "(Recommended)".

If a question can be answered by exploring the codebase or files, explore them yourself instead of asking the user.

## Writing the plan

After all decisions are resolved, write the plan to a markdown file. The plan must be fully self-contained — assume the implementing agent has no memory of this conversation and no other context. Include:

- The goal and motivation for the changes
- All relevant file paths, function names, and line numbers
- Concrete code-level instructions (not vague directions)
- Any constraints, gotchas, or assumptions discovered during planning
- The order in which steps should be done, with dependencies between steps called out
- How to verify each step worked (commands to run, files to check, expected output)

When the plan is complete, copy its absolute path to the user's clipboard with `printf '%s' "<path>" | pbcopy` and tell the user it has been copied.
