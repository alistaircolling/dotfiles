export const meta = {
  name: 'qualitative-sort',
  description: 'Rank a list by a qualitative measure using agent-driven pairwise comparisons (merge sort), since comparative judgment beats absolute scoring',
  whenToUse: 'Ordering items by something only judgment can assess — bug severity, lead quality, answer relevance — where scoring 1000 rows in one prompt degrades.',
  phases: [
    { title: 'Sort', detail: 'pairwise comparison agents, ordered by a deterministic merge sort' },
  ],
}

// args: { items, criterion, descending? } — required.
//   items:     array of things to rank (strings or objects)
//   criterion: the qualitative measure, e.g. "severity of the bug" (higher = first)
if (!args || !Array.isArray(args.items) || !args.criterion) {
  log('qualitative-sort needs { items: [...], criterion: "..." }. Aborting.')
  return { error: 'missing args: { items, criterion }' }
}
const { items, criterion } = args
if (items.length > 40) log(`Warning: ${items.length} items — pairwise sorting spends many agent calls. Consider bucket-ranking first.`)

const CMP = {
  type: 'object',
  properties: { higher: { type: 'string', enum: ['A', 'B'] }, why: { type: 'string' } },
  required: ['higher'],
}

const fmt = (x) => (typeof x === 'string' ? x : JSON.stringify(x))
let comparisons = 0

// Returns negative if a should rank before b (a is "higher" on the criterion).
async function compare(a, b) {
  comparisons++
  const r = await agent(
    `Compare two items by this measure: ${criterion}. Which one ranks HIGHER (more ${criterion})?\nA: ${fmt(a)}\nB: ${fmt(b)}`,
    { schema: CMP, phase: 'Sort', label: `cmp:${comparisons}` },
  )
  return r && r.higher === 'B' ? 1 : -1
}

async function mergeSort(arr) {
  if (arr.length <= 1) return arr
  const mid = Math.floor(arr.length / 2)
  // Sub-sorts run concurrently; only the merge below is sequential.
  const [left, right] = await Promise.all([mergeSort(arr.slice(0, mid)), mergeSort(arr.slice(mid))])
  const out = []
  let i = 0
  let j = 0
  while (i < left.length && j < right.length) {
    const c = await compare(left[i], right[j])
    if (c <= 0) out.push(left[i++])
    else out.push(right[j++])
  }
  while (i < left.length) out.push(left[i++])
  while (j < right.length) out.push(right[j++])
  return out
}

phase('Sort')
const ranked = await mergeSort(items)
log(`Sorted ${items.length} items in ${comparisons} pairwise comparisons`)
return { criterion, ranked, comparisons }
