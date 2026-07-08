export const meta = {
  name: 'rename-symbol',
  description: 'Rename a symbol (model, function, type, constant) across every callsite — discover all sites, edit each file in parallel, adversarially review, then verify the build',
  whenToUse: 'A rename/refactor that touches many files where doing it in one context risks missed sites or partial edits.',
  phases: [
    { title: 'Discover', detail: 'find every file referencing the symbol' },
    { title: 'Edit & review', detail: 'one agent edits each file, a second reviews it' },
    { title: 'Verify', detail: 'build/typecheck/test the whole change once' },
  ],
}

// args: { from, to, note? } — required. `from` is the current name, `to` the new name.
//   note: optional extra guidance (e.g. "also update doc comments and fixtures").
if (!args || !args.from || !args.to) {
  log('rename-symbol needs { from, to }. Aborting.')
  return { error: 'missing args: { from, to }' }
}
const { from, to } = args
const note = args.note || ''

const SITES = {
  type: 'object',
  properties: {
    files: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          path: { type: 'string' },
          occurrences: { type: 'integer' },
          notes: { type: 'string', description: 'tricky cases: strings, partial matches, generated code' },
        },
        required: ['path'],
      },
    },
  },
  required: ['files'],
}

const EDIT = {
  type: 'object',
  properties: {
    path: { type: 'string' },
    changed: { type: 'boolean' },
    edits: { type: 'integer' },
    skipped: { type: 'array', items: { type: 'string' }, description: 'occurrences deliberately left (false positives)' },
  },
  required: ['path', 'changed'],
}

const REVIEW = {
  type: 'object',
  properties: {
    correct: { type: 'boolean' },
    issues: { type: 'array', items: { type: 'string' } },
  },
  required: ['correct'],
}

phase('Discover')
const found = await agent(
  `Find EVERY file that references the symbol "${from}" (the one we are renaming to "${to}"). Search the whole repo — code, tests, fixtures, config, docs. For each file, count occurrences and flag tricky cases (it appears inside a string, a substring of another identifier, or generated/vendored code that must NOT change). ${note}`,
  { schema: SITES, label: 'discover' },
)

if (!found || !found.files.length) {
  log(`No references to "${from}" found.`)
  return { from, to, files: [] }
}
log(`${found.files.length} files reference "${from}" — editing each in parallel`)

// Each agent owns a distinct file, so parallel edits to the shared tree don't collide.
const results = await pipeline(
  found.files,
  (f) => agent(
    `Rename "${from}" to "${to}" in EXACTLY this one file: ${f.path}. Update every genuine reference (including imports/exports), but DO NOT touch unrelated substrings, string literals that aren't this symbol, or generated code. ${f.notes ? 'Watch out: ' + f.notes : ''} ${note}`,
    { schema: EDIT, phase: 'Edit & review', label: `edit:${f.path}` },
  ),
  (e, f) => agent(
    `Adversarially review the rename of "${from}" -> "${to}" in ${f.path}. Read the file as it stands now. Did it miss any real reference, change something it shouldn't have, or break syntax/imports? Be strict.`,
    { schema: REVIEW, phase: 'Edit & review', label: `review:${f.path}` },
  ).then((r) => ({ ...e, review: r })),
)

const edited = results.filter(Boolean)
const flagged = edited.filter((r) => r.review && !r.review.correct)

phase('Verify')
const verify = await agent(
  `A rename of "${from}" -> "${to}" was applied across ${edited.length} files. Run the project's typecheck/build and the test suite. Report whether everything passes, and any remaining references to "${from}" that should have changed (search the repo). List concrete failures.`,
  { label: 'verify' },
)

log(`${edited.length} files edited; ${flagged.length} flagged by review`)
return { from, to, edited, flagged, verify }
