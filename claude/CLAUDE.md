# Response format

Use precise, simple language. Prefer common words over obscure ones.

Keep responses concise. Never more than 5 lines. The user will ask for more detail if required.

Ask decisions via the AskUserQuestion tool (numbered, selectable options) — **one question at a time**, not batched. For each option give pros and cons. The recommended option MUST appear first AND have "(Recommended)" written in its label text (not just the description).


# Dynamic workflows

Some tasks are best solved by a **dynamic workflow** — a custom multi-agent harness built with the `Workflow` tool — rather than one context window. Reach for one when a task is **massively parallel, adversarial/verification-heavy, qualitatively ranked, an unknown-size sweep, or a large refactor/triage backlog** — the shapes where a single context drifts, gets lazy, or prefers its own answers.

When a request matches one of these, **propose a workflow and ask before running it** (they cost more tokens). Saved templates run by name — `Workflow({ name, args })`:

- Verify every claim in a doc/PR against the code → `verify-claims`
- Hunt a flaky / intermittent test → `flaky-test-hunter`
- Root-cause a failure or outage from disjoint evidence → `root-cause`
- Rename / refactor a symbol across many callsites → `rename-symbol`
- Name something via brainstorm + tournament → `naming-tournament`
- Rank a list by a qualitative measure → `qualitative-sort`
- Triage a backlog (classify → dedupe → act) → `triage-backlog`

The `workflows` skill has the full patterns and details. The word **`ultracode`** in a prompt forces a workflow; pair repeatable ones with `/loop` and `/goal`, and cap spend with a budget ("use 10k tokens"). For ordinary coding, skip workflows unless the task genuinely needs more compute.


# Coding principles
<!-- karpathy:start — from github.com/multica-ai/andrej-karpathy-skills. Toggle off by deleting this block (start..end). -->

Behavioral guidelines to reduce common LLM coding mistakes.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

<!-- karpathy:end -->


# Shell & git in this harness

The Bash tool runs each command in a **non-interactive zsh** (`zsh -c`, eval-wrapped) with the cwd prepended as a `cd`. So:

- **Commit via a file:** write the message to the scratchpad and `git commit -F <file>`. Inline `git commit -m "…"` with quotes/parens/newlines can hang on stdin and time out (exit 143).
- **In a git worktree, `.git` is a _file_** not a directory — never write temp files (commit messages, markers) under `.git/`; use the scratchpad dir.
- **Don't background with a trailing `&`** (the harness holds the pipe) — use the Bash tool's `run_in_background`. Wait on long runs with an `until <check>; do sleep N; done` loop, not foreground `sleep`.
