export const meta = {
  name: 'naming-tournament',
  description: 'Brainstorm name candidates from several angles, then run a pairwise tournament against a rubric to pick the top 3',
  whenToUse: 'Naming a tool, product, feature, or API where taste matters and a single pass anchors too early.',
  phases: [
    { title: 'Generate', detail: 'parallel agents brainstorm from different angles' },
    { title: 'Tournament', detail: 'pairwise comparisons narrow the field' },
    { title: 'Final', detail: 'rank the survivors, return top 3' },
  ],
}

// args: a string describing what's being named, or { subject, constraints, rubric }.
const subject = typeof args === 'string' ? args : (args && args.subject) || 'the thing the user wants to name'
const constraints = (args && args.constraints) || 'short, memorable, easy to type and say, no trademark collisions if avoidable'
const rubric = (args && args.rubric) || 'memorable, fits the product, easy to say/spell, distinctive, not generic'

const NAMES = {
  type: 'object',
  properties: { names: { type: 'array', items: { type: 'object', properties: { name: { type: 'string' }, rationale: { type: 'string' } }, required: ['name'] } } },
  required: ['names'],
}

const PAIR = {
  type: 'object',
  properties: { winner: { type: 'string', enum: ['A', 'B'] }, why: { type: 'string' } },
  required: ['winner'],
}

const FINAL = {
  type: 'object',
  properties: {
    top: { type: 'array', items: { type: 'object', properties: { name: { type: 'string' }, why: { type: 'string' } }, required: ['name'] } },
  },
  required: ['top'],
}

const ANGLES = [
  'descriptive / literal — says what it does',
  'evocative / metaphorical — a vivid image or association',
  'short & punchy — one or two syllables, coinable',
  'playful / unexpected — a twist, pun, or surprising reference',
]

phase('Generate')
const pools = await parallel(
  ANGLES.map((angle, i) => () =>
    agent(
      `Brainstorm 8 name candidates for: ${subject}. Angle for this batch: ${angle}. Constraints: ${constraints}. Give a one-line rationale each.`,
      { schema: NAMES, phase: 'Generate', label: `gen:${i}` },
    ),
  ),
)

let field = [...new Set(pools.filter(Boolean).flatMap((p) => p.names.map((n) => n.name)))]
log(`${field.length} unique candidates`)

phase('Tournament')
let round = 0
while (field.length > 4) {
  round++
  const pairs = []
  for (let i = 0; i < field.length; i += 2) pairs.push(field.slice(i, i + 2))
  const winners = await parallel(
    pairs.map((pair, i) => () => {
      if (pair.length === 1) return Promise.resolve(pair[0])
      return agent(
        `Pairwise comparison for naming: ${subject}. Judge against this rubric: ${rubric}. A: "${pair[0]}"  B: "${pair[1]}". Pick the stronger name.`,
        { schema: PAIR, phase: 'Tournament', label: `r${round}:cmp${i}` },
      ).then((r) => (r && r.winner === 'B' ? pair[1] : pair[0]))
    }),
  )
  field = winners.filter(Boolean)
  log(`Round ${round}: ${field.length} remain`)
}

phase('Final')
const final = await agent(
  `Finalists for naming ${subject}: ${field.join(', ')}. Rank them against this rubric: ${rubric}. Return the top 3 with a sharp one-line reason each.`,
  { schema: FINAL, label: 'final' },
)
return { subject, finalists: field, top: final.top }
