# Security policy

## Reporting a vulnerability

Please report security problems privately through
[GitHub security advisories](https://github.com/g-kuhl/kuhl-shell/security/advisories/new)
rather than a public issue. Expect a first reply within a week.

## What to know

- `install.sh` edits `~/.bashrc` and writes under `~/.local/share/kuhl-shell`. It can also run `apt install` and starship's installer, but only after you say yes (or pass `--yes`).
- If you don't want to pipe `curl` into `bash`, clone the repo, read `install.sh`, and run it from the clone.
- `update` and `ports -s` call `sudo`. Nothing else does.

Only the latest release gets fixes.
