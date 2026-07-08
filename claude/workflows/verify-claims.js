export const meta = {
  name: 'verify-claims',
  description: 'Extract every factual/technical claim in a doc and verify each against the codebase, then audit the verification',
  whenToUse: 'Checking a blog draft, PR description, README, or report for claims that may have drifted from the actual code.',
  phases: [
    { title: 'Extract claims', detail: 'one agent pulls every checkable claim from the doc' },
    { title: 'Verify', detail: 'one agent per claim searches the code for evidence' },
    { title: 'Audit', detail: 'adversarial check that the evidence really supports the verdict' },
  ],
}

// args: a file path string, or { path } / { text } of the document to check.
// Falls back to discovering a recent draft if nothing is passed.
const target = typeof args === 'string' ? args : (args && (args.path || args.text))
const where = target
  ? `the document at: ${target}`
  : `the document the user referenced — if no path is given, inspect the working directory for the most recently edited markdown/draft, use that, and state which file you chose`

const CLAIMS = {
  type: 'object',
  properties: {
    source: { type: 'string', description: 'the file actually inspected' },
    claims: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          id: { type: 'string' },
          text: { type: 'string', description: 'the claim, quoted or paraphrased' },
          kind: { type: 'string', description: 'e.g. api-behavior, perf, config, dependency, naming' },
        },
        required: ['id', 'text'],
      },
    },
  },
  required: ['claims'],
}

const VERDICT = {
  type: 'object',
  properties: {
    status: { type: 'string', enum: ['supported', 'contradicted', 'unverifiable'] },
    evidence: { type: 'string', description: 'what was found, with file:line citations' },
    citations: { type: 'array', items: { type: 'string' } },
  },
  required: ['status', 'evidence'],
}

const AUDIT = {
  type: 'object',
  properties: {
    final_status: { type: 'string', enum: ['supported', 'contradicted', 'unverifiable'] },
    confidence: { type: 'string', enum: ['low', 'medium', 'high'] },
    note: { type: 'string' },
  },
  required: ['final_status', 'confidence'],
}

phase('Extract claims')
const extracted = await agent(
  `Read ${where}. Extract every checkable factual or technical claim it makes about this codebase or system — anything that could be right or wrong (API behavior, file/function names, config values, performance numbers, dependencies, defaults). Skip opinions and aspirations. Give each a short id.`,
  { schema: CLAIMS, label: 'extract' },
)

if (!extracted || !extracted.claims.length) {
  log('No checkable claims found.')
  return { source: extracted && extracted.source, claims: [] }
}
log(`${extracted.claims.length} claims to verify`)

const results = await pipeline(
  extracted.claims,
  (c) => agent(
    `Verify this claim against the actual code in the current working directory. Claim: "${c.text}". Search the codebase, read the relevant files, and cite file:line. Decide: supported, contradicted, or unverifiable (can't find enough to judge).`,
    { schema: VERDICT, phase: 'Verify', label: `verify:${c.id}` },
  ),
  (v, c) => agent(
    `Adversarially audit this verification. Claim: "${c.text}". Verdict was "${v.status}" with evidence: ${v.evidence}. Re-check independently: does the evidence actually support that verdict, or was a file misread / a citation wrong? Return the corrected final status and your confidence.`,
    { schema: AUDIT, phase: 'Audit', label: `audit:${c.id}` },
  ).then((a) => ({ ...c, status: v.status, evidence: v.evidence, citations: v.citations, audit: a })),
)

const checked = results.filter(Boolean)
const problems = checked.filter((r) => r.audit && r.audit.final_status !== 'supported')
log(`${problems.length}/${checked.length} claims are contradicted or unverifiable`)
return { source: extracted.source, claims: checked, problems }
