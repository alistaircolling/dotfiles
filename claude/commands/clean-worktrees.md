Clean up merged worktrees interactively across all repos.

Run the cleanup script:

```
/Users/Shared/dotfiles/scripts/clean-worktrees.sh
```

Scans every worktree under `~/Development/worktrees/`, finds branches merged (or squash-merged) into their parent repo's default branch, and prompts per worktree to delete the worktree and its local branch. Dirty worktrees get an extra confirmation prompt. Prompts support `y` / `n` / `a` (yes-to-all) / `q` (quit).
