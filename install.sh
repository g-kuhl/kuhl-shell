#!/usr/bin/env bash
# kuhl-shell installer. Safe to re-run: it's also how you update.
#   from a clone:  ./install.sh [--yes]
#   one-liner:     curl -fsSL https://raw.githubusercontent.com/g-kuhl/kuhl-shell/main/install.sh | bash
# --yes answers yes to every question (installing missing packages and starship).
set -euo pipefail

REPO=https://github.com/g-kuhl/kuhl-shell
DEST=${KUHL_SHELL:-$HOME/.local/share/kuhl-shell}
BASHRC=$HOME/.bashrc
BEGIN='# >>> kuhl-shell >>>'
END='# <<< kuhl-shell <<<'
yes=; [[ ${1:-} == --yes || ${1:-} == -y ]] && yes=1

say()  { printf '\e[38;2;90;99;128m│\e[0m %s\n' "$*"; }
ok()   { printf '\e[38;2;90;99;128m│\e[0m \e[38;2;195;232;141m✔\e[0m %s\n' "$*"; }
warn() { printf '\e[38;2;90;99;128m│\e[0m \e[38;2;255;199;119m!\e[0m %s\n' "$*"; }
die()  { printf '\e[38;2;90;99;128m│\e[0m \e[38;2;255;117;127m✘\e[0m %s\n' "$*" >&2; exit 1; }
# ask QUESTION → true on yes. Reads the terminal directly so it works under curl | bash.
ask() {
    [[ $yes ]] && return 0
    [[ -r /dev/tty ]] || return 1
    local a; printf '\e[38;2;90;99;128m│\e[0m \e[38;2;118;159;240m?\e[0m %s [y/N] ' "$1" > /dev/tty
    read -r a < /dev/tty; [[ $a == [yY]* ]]
}

printf '\e[38;2;90;99;128m╭─(\e[1;38;2;118;159;240mkuhl-shell installer\e[0;38;2;90;99;128m)\e[0m\n'

# Find the source: this script's folder when run from a clone, else fetch the repo.
src=$(cd "$(dirname "${BASH_SOURCE[0]:-.}")" 2>/dev/null && pwd || true)
if [[ ! -f ${src:-}/init.sh || ! -d $src/bin ]]; then
    tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
    say "downloading $REPO"
    if command -v git >/dev/null; then
        git clone -q --depth 1 "$REPO" "$tmp/kuhl-shell"
    else
        curl -fsSL "$REPO/archive/refs/heads/main.tar.gz" | tar -xz -C "$tmp" && mv "$tmp"/kuhl-shell-main "$tmp/kuhl-shell"
    fi
    src=$tmp/kuhl-shell
fi

# Dependencies: bash 4.4+, gawk (dir), jq (deno task menu), starship (prompt), coreutils/iproute2.
(( BASH_VERSINFO[0] > 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] >= 4) )) || die "needs bash 4.4 or newer"
missing=()
for cmd in gawk jq; do command -v "$cmd" >/dev/null || missing+=("$cmd"); done
if (( ${#missing[@]} )); then
    if command -v apt-get >/dev/null && ask "install ${missing[*]} with apt?"; then
        sudo apt-get install -y -qq "${missing[@]}" && ok "installed ${missing[*]}"
    else
        warn "missing ${missing[*]}: dir/tree need gawk, ip and the deno task line need jq"
    fi
fi
if ! command -v starship >/dev/null; then
    if ask "starship isn't installed; install it to ~/.local/bin?"; then
        mkdir -p "$HOME/.local/bin"
        curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin" >/dev/null
        ok "installed starship to ~/.local/bin (make sure it's on your PATH)"
    else
        warn "no starship (https://starship.rs): the commands still work, but the prompt won't change"
    fi
fi

# Copy files. Only ever replace a folder that a previous install made.
if [[ -d $DEST && ! -f $DEST/.kuhl-shell ]]; then die "$DEST exists and isn't a kuhl-shell install"; fi
state=; [[ -f $DEST/.kuhl-shell ]] && state=$(cat "$DEST/.kuhl-shell")
rm -rf "$DEST"; mkdir -p "$DEST"
cp -r "$src"/{init.sh,uninstall.sh,VERSION,bin,lib,prompt} "$DEST"/
chmod +x "$DEST"/bin/* "$DEST"/prompt/*.sh "$DEST"/uninstall.sh
printf '%s\n' "$state" > "$DEST/.kuhl-shell"
ok "installed kuhl-shell $(cat "$DEST/VERSION") to ${DEST/#$HOME/\~}"

# Hook into ~/.bashrc once, at the end so it wins over earlier prompt setups.
if ! grep -qF "$BEGIN" "$BASHRC" 2>/dev/null; then
    cp "$BASHRC" "$BASHRC.bak-kuhl-shell" 2>/dev/null || true
    {
        printf '\n%s\n' "$BEGIN"
        printf 'export KUHL_SHELL="%s"\n[ -f "$KUHL_SHELL/init.sh" ] && . "$KUHL_SHELL/init.sh"\n' "${DEST/#$HOME/\$HOME}"
        printf '%s\n' "$END"
    } >> "$BASHRC"
    ok "added kuhl-shell to ~/.bashrc (backup: ~/.bashrc.bak-kuhl-shell)"
else
    ok "~/.bashrc already loads kuhl-shell"
fi

# Ubuntu's login banner duplicates the welcome screen; silence it (uninstall restores it).
if [[ ! -e $HOME/.hushlogin ]]; then
    touch "$HOME/.hushlogin"; grep -qx hushlogin "$DEST/.kuhl-shell" || echo hushlogin >> "$DEST/.kuhl-shell"
    ok "created ~/.hushlogin so the welcome screen replaces the system login banner"
fi

say "icons need a Nerd Font set as your terminal font: https://www.nerdfonts.com/font-downloads"
printf '\e[38;2;90;99;128m╰─(\e[38;2;195;232;141mdone\e[38;2;90;99;128m)\e[0m open a new terminal, or run: source ~/.bashrc\n'
