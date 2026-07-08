export const meta = {
  name: 'flaky-test-hunter',
  description: 'Reproduce an intermittent test failure, generate independent root-cause theories, and adversarially test each in an isolated worktree until one holds',
  whenToUse: 'A test fails occasionally (e.g. 1 in 50 runs) and you want the real root cause, not a guess.',
  phases: [
    { title: 'Reproduce', detail: 'run the test repeatedly, capture a failing trace' },
    { title: 'Hypothesize', detail: 'propose fresh independent theories each round' },
    { title: 'Test', detail: 'one worktree-isolated agent probes each theory' },
  ],
}

// args: a string describing the test, or { test, command, rate } —
//   test:    identifier / file::name of the flaky test
//   command: how to run it (defaults to the project's usual test runner)
//   rate:    observed failure rate, if known
const test = typeof args === 'string' ? args : (args && args.test) || 'the flaky test the user described'
const command = (args && args.command) || 'the project test runner'
const rate = (args && args.rate) || 'unknown'
const MAX_ROUNDS = (args && args.maxRounds) || 3

const REPRO = {
  type: 'object',
  properties: {
    reproduced: { type: 'boolean' },
    runs: { type: 'integer' },
    failures: { type: 'integer' },
    trace: { type: 'string', description: 'failing output / stack / timing notes' },
    suspects: { type: 'array', items: { type: 'string' }, description: 'files or mechanisms that look involved' },
  },
  required: ['reproduced', 'trace'],
}

const HYPOTHESES = {
  type: 'object',
  properties: {
    theories: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          id: { type: 'string' },
          statement: { type: 'string', description: 'the specific mechanism causing the flake' },
          test_plan: { type: 'string', description: 'how to confirm or refute it' },
        },
        required: ['id', 'statement', 'test_plan'],
      },
    },
  },
  required: ['theories'],
}

const VERDICT = {
  type: 'object',
  properties: {
    theory_id: { type: 'string' },
    statement: { type: 'string' },
    confirmed: { type: 'boolean', description: 'true only if the fix/probe makes the flake disappear under repeated runs' },
    evidence: { type: 'string' },
    fix: { type: 'string', description: 'the change that stabilizes the test, if confirmed' },
  },
  required: ['theory_id', 'statement', 'confirmed', 'evidence'],
}

phase('Reproduce')
const repro = await agent(
  `Reproduce this intermittent test failure: ${test} (observed rate: ${rate}). Run it repeatedly with ${command} — many iterations — until you capture at least one failing run. Report how many runs/failures, the failing trace, and any files or mechanisms (timing, ordering, shared state, async, randomness, env) that look involved. Do not attempt a fix yet.`,
  { schema: REPRO, label: 'reproduce' },
)

let confirmed = null
const refuted = []
let round = 0
while (!confirmed && round < MAX_ROUNDS) {
  round++
  phase('Hypothesize')
  const hyp = await agent(
    `A test flakes intermittently. Evidence: ${JSON.stringify(repro)}. Already refuted theories: ${refuted.length ? refuted.join('; ') : 'none'}. Propose 3 NEW, independent, falsifiable root-cause theories drawn from disjoint angles (timing/async, shared/global state, test ordering, nondeterminism, resource limits). For each give a concrete test plan.`,
    { schema: HYPOTHESES, label: `hypothesize:r${round}` },
  )
  phase('Test')
  const tested = await parallel(
    hyp.theories.map((t) => () =>
      agent(
        `Work in your isolated worktree. Test this theory about a flaky test (${test}): "${t.statement}". Plan: ${t.test_plan}. Apply the minimal instrumented fix or probe it implies, then run the test MANY times. Set confirmed=true only if the flake reliably disappears with your change and reappears without it. Report the stabilizing fix if confirmed.`,
        { schema: VERDICT, isolation: 'worktree', phase: 'Test', label: `test:${t.id}` },
      ),
    ),
  )
  for (const v of tested.filter(Boolean)) {
    if (v.confirmed) { confirmed = v; break }
    refuted.push(v.statement)
  }
  log(confirmed ? `Root cause confirmed in round ${round}` : `Round ${round}: no theory held (${refuted.length} refuted so far)`)
}

return { reproduced: repro.reproduced, rounds: round, confirmed, refuted }
