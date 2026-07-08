---
name: feature-kickoff
description: Prepare a new feature for development in three phases — gather and verify every connected resource (Linear, Notion, Google Docs, Figma, Slack, codebase), run an interactive session to resolve conflicts and produce a single PRD, then split the PRD into tasks that autonomous agents can complete (in parallel where possible). Use when the user wants to kick off, scope, or plan a new feature and provides a Linear project or ticket link.
---

# Feature Kickoff

Turn a feature idea plus its scattered sources into a verified PRD and a set of agent-ready tasks. Three phases, in order. Do not start a phase until the previous one is confirmed complete by the user.

## Input

A Linear project or ticket URL (or name). If none is given, ask for it before doing anything else.

## Ground rules

- Keep all documentation and notes as brief as possible. Use ~8-word bullets where possible.
- All deliverables live in one directory: `docs/features/<feature-slug>/` (create it; if the repo has a different docs convention, follow it). It holds four files: `findings.md`, `PRD.md`, `tasks.md`, and `progress.md`.
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

## Phase 3 — Split into tasks

Break the approved PRD into individual tasks completable by autonomous agents.

**First, remind the user about the design skill:** before splitting tasks, recommend running `/modularity:design` on the PRD — it produces module-level design docs with integration contracts that make the task boundaries (and parallelism) much cleaner. It's optional; let the user decide, then proceed.

1. Each task must be self-contained: context, acceptance criteria, files/areas touched, and links back to the PRD section — an agent with no prior context should be able to execute it.
2. Prefer tasks that can run **in parallel** (minimal shared files, clear interfaces). Parallelism is desirable, not essential — where ordering is required, state the dependency explicitly.
3. Write the task list to `docs/features/<feature-slug>/tasks.md`: one section per task with title, description, acceptance criteria, dependencies, and a parallel-safe yes/no flag.
4. Show the breakdown to the user. After approval, offer to create the tasks as Linear tickets in the project (via the Linear MCP), linking each to the parent project.
