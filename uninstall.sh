#!/usr/bin/env bash
# Remove kuhl-shell: the ~/.bashrc block, the install folder, and ~/.hushlogin if the
# installer created it. Leaves starship, gawk and jq installed.
set -euo pipefail
DEST=${KUHL_SHELL:-$HOME/.local/share/kuhl-shell}
BASHRC=$HOME/.bashrc

if [[ -f $BASHRC ]] && grep -qF '# >>> kuhl-shell >>>' "$BASHRC"; then
    cp "$BASHRC" "$BASHRC.bak-kuhl-shell-uninstall"
    sed -i '/^# >>> kuhl-shell >>>$/,/^# <<< kuhl-shell <<<$/d' "$BASHRC"
    echo "✔ removed kuhl-shell from ~/.bashrc (backup: ~/.bashrc.bak-kuhl-shell-uninstall)"
fi
if [[ -f $DEST/.kuhl-shell ]]; then
    grep -qx hushlogin "$DEST/.kuhl-shell" && rm -f "$HOME/.hushlogin" && echo "✔ removed ~/.hushlogin"
    rm -rf "$DEST"
    echo "✔ removed ${DEST/#$HOME/\~}"
fi
echo "open a new terminal to get your old prompt back"
