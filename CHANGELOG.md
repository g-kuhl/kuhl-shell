# Changelog

All notable changes are listed here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow
[Semantic Versioning](https://semver.org).

## [Unreleased]

### Added
- Framed `apt install`, `remove` and `purge`: shows the plan, asks once, runs behind a spinner.
- Framed `git status`.
- A blank line above each frame so it doesn't run into the prompt; `KUHL_FRAME_GAP=0` turns it off.

## [0.3.0]

### Added
- MIT license, contributing guide, code of conduct and security policy.
- CI: syntax check, ShellCheck and an install/uninstall smoke test (`tests/smoke.sh`).
- Release workflow that publishes a GitHub release from a `v*` tag.
- Weekly stale-issue cleanup and monthly GitHub Actions updates.

### Fixed
- `install.sh` no longer prompts when there is no terminal.
- `uninstall.sh` keeps a symlinked `~/.bashrc` intact.
- `dir` and `tree` print a clear message when `gawk` is missing.

## [0.2.0]

### Added
- Framed `tree`, `df`, `du`, `ip`, `free` and `ports`.
- Prerequisites check in the installer, and credits in the README.

## [0.1.0]

### Added
- The atlas starship prompt, `dir`, `update` and the welcome screen.
