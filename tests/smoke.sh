#!/usr/bin/env bash
# Smoke test: install into a throwaway HOME, load the shell config, run each
# command, then uninstall and check ~/.bashrc is back to how it started.
# Never touches the real home directory. Run from anywhere: tests/smoke.sh
set -euo pipefail

repo=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
export HOME="$scratch/home" KUHL_SHELL="$scratch/home/ks" TERM=xterm COLUMNS=100
mkdir -p "$HOME"
printf '# my bashrc\nalias ll="ls -l"\n' > "$HOME/.bashrc"
cp "$HOME/.bashrc" "$scratch/bashrc.orig"

fail() { echo "FAIL: $*" >&2; exit 1; }
step() { echo "== $*"; }

step "install"
"$repo/install.sh" --yes < /dev/null > "$scratch/install.log" 2>&1 || { cat "$scratch/install.log"; fail "install.sh exited non-zero"; }
[[ -f $KUHL_SHELL/init.sh ]]   || fail "init.sh not installed"
[[ -x $KUHL_SHELL/bin/ktree ]] || fail "bin/ktree not installed"
grep -q '# >>> kuhl-shell >>>' "$HOME/.bashrc" || fail "bashrc block missing"

step "idempotent reinstall"
"$repo/install.sh" --yes < /dev/null > /dev/null 2>&1 || fail "second install failed"
[[ $(grep -c '# >>> kuhl-shell >>>' "$HOME/.bashrc") -eq 1 ]] || fail "bashrc block duplicated"

step "commands run and draw a frame"
# A pseudo-terminal isn't available on every runner, so force output with script(1) when present.
run() { if command -v script > /dev/null; then script -qec "$*" /dev/null; else bash -c "$*"; fi; }
for cmd in "bin/kdf" "bin/kdu $repo" "bin/kip" "bin/kfree" "bin/kports" "bin/ktree $repo" "bin/kgit" "bin/kuptime"; do
    out=$(run "$KUHL_SHELL/$cmd" 2>&1) || fail "$cmd exited non-zero"
    [[ $out == *'╭'* ]] || fail "$cmd drew no frame"
done

step "apt wrapper plans without root"
# Planning uses apt-get -s, so these run unprivileged and change nothing.
if command -v apt-get > /dev/null; then
    out=$(run "$KUHL_SHELL/bin/kapt install bash" 2>&1) || fail "kapt install bash exited non-zero"
    [[ $out == *'nothing to do'* ]] || fail "kapt did not report nothing to do"
    if run "$KUHL_SHELL/bin/kapt install kuhl-no-such-package" > /dev/null 2>&1; then fail "kapt accepted a missing package"; fi
fi

step "uninstall"
"$KUHL_SHELL/uninstall.sh" --yes < /dev/null > /dev/null 2>&1 || fail "uninstall failed"
[[ ! -e $KUHL_SHELL ]] || fail "install dir still present"
cmp -s "$HOME/.bashrc" "$scratch/bashrc.orig" || { diff "$scratch/bashrc.orig" "$HOME/.bashrc" || true; fail "bashrc not restored"; }

echo "all good"
