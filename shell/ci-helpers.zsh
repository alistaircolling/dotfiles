# CI workflow helpers

_watch_ci() {
  local branch run_id
  branch=$(git branch --show-current)

  for i in 1 2 3; do
    sleep 3
    run_id=$(gh run list --branch "$branch" --limit 1 \
      --json databaseId,status \
      --jq '.[] | select(.status != "completed") | .databaseId')
    [[ -n "$run_id" ]] && break
  done

  [[ -n "$run_id" ]] && gh run watch "$run_id"
}
