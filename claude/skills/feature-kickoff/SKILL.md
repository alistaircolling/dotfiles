---
name: feature-kickoff
description: Prepare a new feature for development in four phases — gather and verify every connected resource (Linear, Notion, Google Docs, Figma, Slack, codebase), run an interactive session to resolve conflicts and produce a single PRD, adversarially stress-test that PRD with parallel subagents, then design the architecture and split it into agent-ready issues (with approval gates on both the PRD and the implementation plan). Use when the user wants to kick off, scope, or plan a new feature and provides a Linear project or ticket link.
---

# Feature Kickoff

Turn a feature idea plus its scattered sources into a verified PRD and a set of agent-ready issues. Four phases, in order. Do not start a phase until the previous one is confirmed complete by the user.

## Input

A Linear project or ticket URL (or name). If none is given, ask for it before doing anything else.

## Ground rules

- Keep all documentation and notes as brief as possible. Use ~8-word bullets where possible.
- **Never create or draft Linear tickets at any point unless the user specifically instructs it.** All tasks, issues, and notes are tracked as markdown files in the feature directory — not in Linear.
- All deliverables live in one directory: `docs/features/<feature-slug>/` (create it; if the repo has a different docs convention, follow it). It holds: `findings.md` (Phase 1), `PRD.md` (Phase 2), `prd-review.md` (Phase 3), `plan.md` plus module design docs and `plan-review.md` (Phase 4 Step 1), one file per issue under `issues/` (Phase 4 Step 2), and `progress.md` (maintained throughout).
- Maintain `progress.md` from the start and update it after every step: current phase, completed steps, decisions made, pending questions. A fresh session must be able to resume the kickoff from this file alone — check for it before starting Phase 1.
- Save any images, designs, or screenshots encountered or shared (Figma exports, mockups, screenshots from Slack/Notion, files the user pastes) to `docs/features/<feature-slug>/assets/`, and reference them from the markdown files by relative path.
- If you don't have access to any resource (MCP missing, permission denied, link broken), **flag it before proceeding** — list what's inaccessible and let the user decide whether to continue without it.
- **Phase handoff:** when a phase is confirmed complete, copy a continuation prompt to the user's clipboard (`printf '%s' "<prompt>" | pbcopy`) and tell them it's copied, so they can start the next phase in a fresh session. Format: `/feature-kickoff <linear-url> — resume at Phase <n> (<phase name>). Read docs/features/<feature-slug>/progress.md first.` Ensure `progress.md` is fully up to date before copying.

## Phase 1 — Gather and verify

Collect everything available about the feature:

1. **Linear** — the project overview, its description, all tickets in the project, comments, and linked resources on each.
2. **Notion** — search for documents mentioning the feature/project name; read anything relevant.
3. **Google Docs** — check Linear/Notion/Slack for Google Doc links; fetch any found (flag if inaccessible).
4. **Figma** — designs linked from Linear/Notion/Slack. Pull design context/screenshots for the key frames via the Figma MCP.
5. **Slack** — search messages for the feature/project name; read relevant threads.
6. **Codebase** — review the existing code the feature will touch. Note what architectural decisions will be needed and what the architectural approach could be (existing patterns to follow, modules affected, data model implications).

Fan out subagents for independent sources where useful. Record everything in `docs/features/<feature-slug>/findings.md`, organized by source, in terse bullets. Include:

- One-line summary per source with links.
- Key requirements, decisions, and constraints found.
- **Conflicts** between sources (e.g. Figma vs ticket description).
- **Open product questions** that need a decision.
- Architectural notes: options, recommendation, affected code areas.
- Access gaps: anything you couldn't reach.

End Phase 1 by presenting a short summary of findings, conflicts, questions, and access gaps. Once the user confirms, update `progress.md` and copy the Phase 2 continuation prompt to their clipboard (see Phase handoff).

## Phase 2 — Interactive PRD session

An interactive working session with the user — not a solo writing task.

1. Walk through the findings source by source, surfacing each **conflict** and **open product question** one at a time via AskUserQuestion (numbered options, pros/cons, recommended option first and labelled "(Recommended)").
2. Record each decision as it's made. Some questions may be deferred — mark them explicitly as open decisions in the PRD.
3. Where Figma designs are not aligned with the agreed solution, note that **the Figma frame is the fallback reference** and record what differs.
4. Write the PRD to `docs/features/<feature-slug>/PRD.md`. Keep it brief (8-word bullets where possible). Structure:
   - **Overview** — what and why, 2–3 lines.
   - **Key features** — the core of the document.
   - **Decisions made** — with one-line rationale each.
   - **Open decisions** — deferred questions.
   - **Design references** — Figma links, alignment notes.
   - **Architecture** — chosen approach, affected areas.
   - **Out of scope.**

End Phase 2 by having the user review and approve the PRD. Once approved, update `progress.md` and copy the Phase 3 continuation prompt to their clipboard (see Phase handoff).

## Phase 3 — Adversarial PRD review

Stress-test the approved PRD before any design work. Fan out **parallel subagents**, each with a distinct adversarial lens — instruct each to actively hunt for problems and default to skepticism:

- **Scope & feasibility** — scope creep, unrealistic ambition, hidden cost.
- **Gaps & edge cases** — missing requirements, unhandled states, error paths.
- **Contradictions & ambiguity** — internal inconsistencies, vague acceptance criteria.
- **Product assumptions** — unvalidated claims; does it solve the real user problem.
- **Technical & architecture risk** — integration, data model, dependency risks.

1. Give each subagent the PRD (and `findings.md` for context). Collect their findings.
2. Dedupe and rank by severity. Write to `docs/features/<feature-slug>/prd-review.md` in terse bullets.
3. Present the findings to the user — grouped by lens, most severe first — or state the PRD passed clean.
4. Walk the user through material findings one at a time via AskUserQuestion; fold agreed changes back into `PRD.md`. Mark anything deferred as an open decision.

End Phase 3 when the user approves the (possibly revised) PRD. Update `progress.md` and copy the Phase 4 continuation prompt to their clipboard (see Phase handoff).

## Phase 4 — Design and split into issues

Two steps, each gated on explicit user approval. Do not start Step 2 until Step 1's plan is approved.

### Step 1 — Implementation plan

1. Run `/modularity:design` on the approved PRD to produce module-level design docs (integration contracts, test specs). Save its output under `docs/features/<feature-slug>/` and distil a single implementation plan to `plan.md`.
2. Run an adversarial analysis on the plan — fan out **parallel subagents** with distinct lenses, each hunting for problems:
   - **Module boundaries & coupling** — does the decomposition hold; balanced coupling.
   - **Sequencing & dependencies** — hidden ordering, blocking work, false parallelism.
   - **Missing or underspecified work** — steps with no owner, hand-wavy areas.
   - **Risk & failure modes** — migration/rollout risk, what breaks, rollback.
   - **Testability** — can each piece be independently verified.
3. Dedupe and write findings to `plan-review.md`. Present issues and open questions to the user one at a time (AskUserQuestion); fold agreed changes into `plan.md`.
4. **Get explicit approval of the implementation plan before proceeding to Step 2.**

### Step 2 — Write issues

1. **First, ask how granular the issues should be** via AskUserQuestion — present options with a recommendation first and pros/cons for each. For example:
   - **Medium (Recommended)** — one issue per cohesive unit of work / likely PR. Balances context and parallelism.
   - **Coarse** — few large issues, one per module/area. Fewer to manage; each needs more in-issue planning.
   - **Fine** — many small issues, one per discrete task. Maximum parallelism; more overhead and cross-links.
2. Write one markdown file per issue under `docs/features/<feature-slug>/issues/` (e.g. `01-<slug>.md`). Each must be self-contained: context, acceptance criteria, files/areas touched, dependencies, a parallel-safe yes/no flag, and links back to the relevant `PRD.md` and `plan.md` sections — an agent with no prior context should be able to execute it.
3. **Reference supporting resources** where useful — link screenshots/designs from `assets/`, Figma frames, and relevant findings by relative path.
4. Prefer issues that can run **in parallel** (minimal shared files, clear interfaces); where ordering is required, state the dependency explicitly.
5. Show the issue breakdown to the user. The issue markdown files under `issues/` are the deliverable — do **not** create Linear tickets from them unless the user specifically asks you to.
