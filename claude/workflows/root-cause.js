export const meta = {
  name: 'root-cause',
  description: 'Investigate a failure by gathering disjoint evidence, forming independent hypotheses, and running each past a panel of verifiers and refuters',
  whenToUse: 'Any post-mortem — a broken pipeline, a metric drop, an outage — where one context window would anchor on its first guess (self-preferential bias).',
  phases: [
    { title: 'Gather evidence', detail: 'parallel agents, one per disjoint source' },
    { title: 'Hypothesize', detail: 'form independent hypotheses from the evidence' },
    { title: 'Adjudicate', detail: 'each hypothesis faces a verifier and a refuter' },
  ],
}

// args: a string question, or { question, sources } where sources is an array of
//   { key, prompt } describing each disjoint evidence stream to collect.
const question = typeof args === 'string' ? args : (args && args.question) || 'the problem the user described'
const sources = (args && args.sources) || [
  { key: 'logs', prompt: 'Search logs, error output, and recent run history for anomalies, errors, and timing changes around the incident.' },
  { key: 'code', prompt: 'Search the codebase and recent diffs/commits for changes that could plausibly cause this.' },
  { key: 'data', prompt: 'Inspect config, environment, data shape, and external inputs/dependencies for anything off.' },
]

const EVIDENCE = {
  type: 'object',
  properties: {
    source: { type: 'string' },
    observations: { type: 'array', items: { type: 'string' } },
    anomalies: { type: 'array', items: { type: 'string' } },
  },
  required: ['observations'],
}

const HYPOTHESES = {
  type: 'object',
  properties: {
    hypotheses: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          id: { type: 'string' },
          statement: { type: 'string' },
          grounded_in: { type: 'string', description: 'which evidence supports it' },
        },
        required: ['id', 'statement'],
      },
    },
  },
  required: ['hypotheses'],
}

const STANCE = {
  type: 'object',
  properties: {
    verdict: { type: 'string', enum: ['supports', 'refutes', 'inconclusive'] },
    reasoning: { type: 'string' },
  },
  required: ['verdict', 'reasoning'],
}

phase('Gather evidence')
const evidence = (await parallel(
  sources.map((s) => () =>
    agent(
      `Investigating: "${question}". Your job is ONE evidence stream only — stay in your lane, do not speculate about other sources. ${s.prompt} Report concrete observations and anything anomalous.`,
      { schema: EVIDENCE, phase: 'Gather evidence', label: `evidence:${s.key}` },
    ),
  ),
)).filter(Boolean)

phase('Hypothesize')
const hyp = await agent(
  `Investigating: "${question}". Here is disjoint evidence from separate investigators: ${JSON.stringify(evidence)}. Form 3-5 independent, falsifiable hypotheses for the root cause. Each must name the evidence it rests on.`,
  { schema: HYPOTHESES, label: 'hypothesize' },
)

phase('Adjudicate')
const judged = await parallel(
  hyp.hypotheses.map((h) => () =>
    parallel(
      [
        { stance: 'verify', role: 'an investigator trying hard to CONFIRM' },
        { stance: 'refute', role: 'a skeptic trying hard to REFUTE — default to refutes if evidence is thin' },
      ].map((s) => () =>
        agent(
          `Hypothesis for "${question}": "${h.statement}". Evidence available: ${JSON.stringify(evidence)}. You are ${s.role} this hypothesis. Investigate further if needed and give your verdict.`,
          { schema: STANCE, phase: 'Adjudicate', label: `${s.stance}:${h.id}` },
        ),
      ),
    ).then((votes) => {
      const v = votes.filter(Boolean)
      const supports = v.filter((x) => x.verdict === 'supports').length
      const refutes = v.filter((x) => x.verdict === 'refutes').length
      return { ...h, supports, refutes, votes: v }
    }),
  ),
)

const ranked = judged
  .filter(Boolean)
  .sort((a, b) => (b.supports - b.refutes) - (a.supports - a.refutes))
log(`Most likely cause: ${ranked.length ? ranked[0].statement : 'inconclusive'}`)
return { question, ranked, evidence }
