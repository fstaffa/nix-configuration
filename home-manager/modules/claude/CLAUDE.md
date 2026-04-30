# Global Claude Code Instructions

## Git Command Format

Sandbox permission rules use prefix matching on the full command string (e.g. `git add`, `git commit`). Placing global flags like `-C` before the subcommand breaks this matching.

**Do not** use global flags before the subcommand:
```sh
# Wrong — permission rules see "git -C" not "git add"
git -C /some/path add file.txt
```

**Instead**, change directory first or use the `--git-dir`/`--work-tree` flags after the subcommand if needed:
```sh
# Correct
cd /some/path && git add file.txt

# Also correct — subcommand immediately follows git
git add file.txt
git commit -m "message"
git status
```

The subcommand (`add`, `commit`, `status`, `diff`, etc.) must always come immediately after `git`.
