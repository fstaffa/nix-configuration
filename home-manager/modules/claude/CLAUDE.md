# Global Claude Code Instructions

## CLI Commands with Subcommands (ENFORCED BY HOOK)

For tools that use subcommands (`git`, `kubectl`, `docker`, `nix`, etc.), place the subcommand immediately after the base command. Global flags before the subcommand break sandbox permission matching.

**`git -C`, `git --git-dir`, and `git --work-tree` before the subcommand are BLOCKED by a PreToolUse hook and will always fail.**

```sh
# BLOCKED — hook rejects these
git -C /some/path log --oneline
git --git-dir=/repo/.git show abc123

# CORRECT — subcommand immediately after git
git log --oneline
git show abc123

# For a different repo, use a subshell
(cd /other/repo && git log --oneline)
```

Similarly for other tools:
```sh
# Wrong
kubectl -n mynamespace get pods

# Correct
kubectl get pods -n mynamespace
```
