---
name: workflows
description: >-
  Build or run a dynamic workflow — a custom multi-agent harness Claude writes
  on the fly via the Workflow tool — for tasks that overwhelm a single context
  window. Use when the user says "use a workflow", "dynamic workflow",
  "ultracode", "fan out agents", "orchestrate subagents", or "set up a harness";
  AND consider proposing one (ask first) when a task matches a workflow shape:
  verify every claim in a doc/PR against the code, hunt a flaky/intermittent
  test, root-cause a failure or outage, rename/refactor a symbol across many
  callsites, do a large migration, triage a backlog/support queue/alerts, rank
  or sort a list by a qualitative measure, name something via brainstorm +
  tournament, run an adversarial review, deep research with cited sources, or
  run lightweight evals. These are massively-parallel,
  adversarial/verification-heavy, qualitatively-ranked, unknown-size-sweep, or
  large-refactor tasks where one context drifts, gets lazy, or prefers its own
  answers.
---

# Dynamic workflows

A **dynamic workflow** is a JavaScript harness Claude writes (or loads) and runs via the `Workflow` tool. It spawns and coordinates focused subagents, each with its own clean context window. Use it instead of a single long context when a task is large, parallel, adversarial, or highly structured.

## Why — the failure modes it fixes

A single context window, pushed long and hard, hits three failure modes that workflows structurally prevent:

- **Agentic laziness** — stops after partial progress (20 of 50 items) and declares done.
- **Self-preferential bias** — prefers its own findings when asked to verify or judge them.
- **Goal drift** — loses fidelity to the original objective across turns, especially after compaction.

## When NOT to use one

Workflows cost **significantly more tokens**. Most ordinary coding tasks don't need one — a single edit doesn't need a panel of 5 reviewers. Before reaching for a workflow, ask: *does this really need more compute?* Propose one only when the task genuinely matches a shape below, and **ask before running** unless the user said `ultracode` or "just do it".

## Patterns (compose these)

- **Classify-and-act** — a classifier agent routes each item to different handling.
- **Fan-out-and-synthesize** — split into many steps, run an agent on each, merge the structured outputs (the synthesize step is a barrier).
- **Adversarial verification** — for each produced result, a separate agent tries to refute it against a rubric.
- **Generate-and-filter** — generate many ideas, then filter/dedupe/verify down to the best.
- **Tournament** — N agents compete; pairwise judges narrow to a winner (comparative judgment beats absolute scoring).
- **Loop-until-done** — for unknown-size work, keep spawning until a stop condition (no new findings, no more errors), not a fixed count.

## Saved templates

These live in `~/.claude/workflows/` and run by name: `Workflow({ name: "<name>", args: {...} })`. **Treat them as templates** — read the script, and adapt it inline if the task differs rather than forcing a fit.

| Name | Does | args |
|------|------|------|
| `verify-claims` | Extract every claim in a doc, verify each against the code, audit the verification | path string, or `{ path }` / `{ text }` |
| `flaky-test-hunter` | Reproduce → theorize → adversarially test in worktrees, loop until a theory holds | `{ test, command?, rate?, maxRounds? }` |
| `root-cause` | Disjoint-evidence investigation → hypotheses → verifier/refuter panel | question string, or `{ question, sources? }` |
| `rename-symbol` | Find all callsites, edit each file in parallel, adversarial review, verify build | `{ from, to, note? }` |
| `naming-tournament` | Brainstorm names from several angles, pairwise tournament, top 3 | subject string, or `{ subject, constraints?, rubric? }` |
| `qualitative-sort` | Rank a list by a qualitative measure via pairwise comparisons | `{ items, criterion, descending? }` |
| `triage-backlog` | Classify → dedupe vs tracked → act/escalate, with a quarantine rule | `{ items, tracked? }` |

For research with cited web sources, the built-in **`/deep-research`** skill already wraps a workflow — prefer it.

## How to run

- **By name:** `Workflow({ name: "verify-claims", args: "blog-draft.md" })`.
- **Inline:** for a one-off shape not covered above, author a script (start with `export const meta = {...}`, then use `agent()/parallel()/pipeline()/phase()/log()`) and pass it as `script`. Iterate by editing the saved `scriptPath` the tool returns and re-invoking.
- **Force one:** the trigger word **`ultracode`** in a prompt tells Claude to build a workflow.
- **Quick workflows:** workflows aren't only for big tasks — prompt for a "quick workflow", e.g. a fast adversarial review of one assumption.

## Combine with /loop, /goal, and budgets

- Pair repeatable workflows (triage, research, verification) with **`/loop`** to run on an interval, and **`/goal`** to set a hard completion bar ("don't stop until one theory works").
- Cap token spend by prompting a **budget** — e.g. "use 10k tokens" — and the workflow scales depth to it.

## Saving and sharing

- Press **`s`** in the workflow menu to save a workflow Claude just wrote — store it in `~/.claude/workflows/` (this repo's `claude/workflows/`, symlinked) to keep it checked in and shared across both accounts.
- To distribute via a skill, drop the `.js` files in the skill folder and reference them here; tell Claude to treat them as templates, not scripts to run verbatim.
