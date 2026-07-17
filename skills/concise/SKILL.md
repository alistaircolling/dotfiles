---
name: concise
description: Rewrite a drafted piece of text dramatically shorter without losing essential information. Use when the user asks to "make this shorter", "cut this down", "tighten this up", "halve the length", "make this more concise", "trim", or names a target length (e.g. "~450 chars", "3 bullets", "one paragraph") for a team update, Slack message, PM/exec report, status update, or doc section — especially during fast-moving incident or investigation work.
---

# Concise

Compress drafted text to roughly **half its length** (or a length the user names) while preserving every load-bearing fact. The numbers and actions are the payload — never drop them to save space.

## When to use

Trigger when the user has a drafted message, update, report, or doc section and wants it shorter or tighter — common during incident/investigation work where they repeatedly say "make this about half the length but keep all the essential numbers and actions."

## Target length

- **Default:** roughly half the input length.
- If the user names a length — `~450 chars`, `3 bullets`, `one paragraph`, `under 100 words` — hit that instead.

## Preserve without exception

Carry these through verbatim. They are why the message exists:

- Every number, dollar figure, percentage, count, and date.
- Every proper noun: people, projects, ticket IDs, file/system/service names.
- Every action item and next step.

## Cut aggressively

- Hedging and qualifiers ("I think", "it seems", "somewhat", "fairly").
- "Context for the reader" preamble and restated background the audience already knows.
- Ruled-out alternatives and justifications for inaction.
- Adjectives, adverbs, and redundant connective phrasing ("in order to", "the fact that", "it is worth noting that").

## Structure

- Lead with the headline the reader must act on.
- One idea per line or bullet.
- Avoid nested subclauses.
- Prefer plain language over jargon for non-technical or team audiences.

## Constraints

- Keep the original meaning and tone. Compress only — do not invent facts, and do not soften or strengthen any claim.

## Output

1. Return the rewritten text **paste-ready** — no surrounding commentary unless the user asked for it.
2. Copy it to the macOS clipboard:
   ```sh
   pbcopy < /path/to/rewritten.txt   # or: printf '%s' "$REWRITTEN" | pbcopy
   ```
3. Report the new character/word count and roughly the % reduction (e.g. "612 → 301 chars, ~51% shorter").
4. Offer one more pass if they want it even shorter.

## Worked example

**Before** (verbose, 3 bullets, ~590 chars):

> - After a fair amount of digging, it turns out that the nightly re-index job we were worried about actually never ran at all — there were 0 documents written, 0 records touched, and nothing in the audit log, which we confirmed from the Dec-17 snapshot.
> - In terms of cost, it's worth noting that the CDN double-fetch issue was responsible for roughly $4,200 of extra spend over the period in question.
> - As a next step, we should probably go ahead and get the ABC-2109 backfill scheduled at some point soon if everyone agrees.

**After** (~290 chars, ~51% shorter):

> - Nightly re-index job never ran: 0 documents, 0 records, 0 audit entries (confirmed in Dec-17 snapshot).
> - CDN double-fetch cost ~$4,200 extra over the period.
> - Next: schedule the ABC-2109 backfill.

Every number (0/0/0, $4,200), date (Dec-17), ticket (ABC-2109), system name (CDN), and the action survive. Hedging ("after a fair amount of digging", "it's worth noting", "probably", "if everyone agrees") is gone.
