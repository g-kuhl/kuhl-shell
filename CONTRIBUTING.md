# Contributing

Thanks for helping out. Bug reports, ideas and pull requests are all welcome.

## Before you start

- For anything bigger than a small fix, open an issue first so we can agree on the approach.
- Everything here is bash and gawk. Keep it that way: no new runtime dependencies unless there's a strong reason.

## Setting up

```bash
git clone https://github.com/g-kuhl/kuhl-shell && cd kuhl-shell
```

You need `gawk` and `jq` (see the README's prerequisites) and [ShellCheck](https://www.shellcheck.net) for linting.

## Testing your change

```bash
shellcheck -S warning install.sh uninstall.sh init.sh bin/* lib/*.sh prompt/*.sh tests/*.sh
tests/smoke.sh
```

`tests/smoke.sh` installs into a throwaway home, runs every command, and uninstalls, so it never touches your real setup. CI runs the same two commands on every pull request.

**Careful when testing the installer by hand:** `KUHL_SHELL` overrides the install location. If it's exported in your shell, `uninstall.sh` will remove that directory. Run `env HOME=/tmp/x KUHL_SHELL=/tmp/x/ks ./install.sh` to keep it isolated.

## Style

- Match the surrounding code: same naming, same comment density.
- New colors go in `lib/palette.sh` and the `[palettes.atlas]` tables in `prompt/*.toml` together.
- Framed commands must keep passing through to the real command for flags they don't handle and when the output isn't a terminal.
- Update the README and `CHANGELOG.md` (under *Unreleased*) when behavior changes.

## Pull requests

1. Branch from `main`.
2. Keep each PR to one change, with a clear description of what and why.
3. Make sure CI is green.

By contributing, you agree your work is released under the [MIT license](LICENSE).

## Releasing (maintainers)

1. Move the *Unreleased* entries in `CHANGELOG.md` under a new version heading, and set `VERSION` to match.
2. Commit, then `git tag vX.Y.Z && git push --tags`.
3. The Release workflow checks the tag against `VERSION` and publishes the release notes from the changelog.
