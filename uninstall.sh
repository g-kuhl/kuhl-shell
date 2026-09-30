#!/usr/bin/env bash
# Remove kuhl-shell: the ~/.bashrc block, the install folder, and ~/.hushlogin if the
# installer created it. Leaves starship, gawk and jq installed.
set -euo pipefail
DEST=${KUHL_SHELL:-$HOME/.local/share/kuhl-shell}
BASHRC=$HOME/.bashrc

if [[ -f $BASHRC ]] && grep -qF '# >>> kuhl-shell >>>' "$BASHRC"; then
    cp "$BASHRC" "$BASHRC.bak-kuhl-shell-uninstall"
    # Drop the block and the blank line install.sh put before it. Rewrite in place
    # (not sed -i) so a symlinked ~/.bashrc stays a symlink.
    kept=$(awk '
        skip { if ($0 == "# <<< kuhl-shell <<<") skip = 0; next }
        $0 == "# >>> kuhl-shell >>>" { skip = 1; if (blank) blank--; next }
        /^$/ { blank++; next }
        { for (; blank; blank--) print ""; print }
        END { for (; blank; blank--) print "" }' "$BASHRC")
    printf '%s\n' "$kept" > "$BASHRC"
    echo "✔ removed kuhl-shell from ~/.bashrc (backup: ~/.bashrc.bak-kuhl-shell-uninstall)"
fi
if [[ -f $DEST/.kuhl-shell ]]; then
    grep -qx hushlogin "$DEST/.kuhl-shell" && rm -f "$HOME/.hushlogin" && echo "✔ removed ~/.hushlogin"
    rm -rf "$DEST"
    echo "✔ removed ${DEST/#$HOME/\~}"
fi
echo "open a new terminal to get your old prompt back"
