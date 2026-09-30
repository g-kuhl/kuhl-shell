# dir: clear, then list a folder inside the same box frame and atlas palette as the
# starship prompt, directories first. dir [-h|-a] [path]   (-h or -a includes hidden dotfiles)
# At 130+ columns folders and files sit side by side in two panes.
unalias dir 2>/dev/null || true
dir() {
    local all=0
    [[ $1 == -[ah] ]] && { all=1; shift; }
    local target=${1:-.}
    command -v gawk >/dev/null || { echo "dir: needs gawk (sudo apt install gawk)" >&2; return 1; }
    [[ -d $target ]] || { echo "dir: $target: not a directory" >&2; return 1; }
    local cols=${COLUMNS:-$(tput cols)}
    local where branch
    where=$(cd "$target" && "$KUHL_SHELL/prompt/path.sh" 2 2)
    branch=$(git -C "$target" branch --show-current 2>/dev/null)
    clear
    find "$target" -mindepth 1 -maxdepth 1 \
        -printf '%Y\t%y\t%M\t%s\t%Tb %Td\t%TY\t%TH:%TM\t%f\t%l\n' 2>/dev/null |
    LC_ALL=C sort -t $'\t' -k1,1 -k8,8f |
    gawk -F'\t' -v all="$all" -v cols="$cols" -v where="$where" -v branch="$branch" \
        -v ro="$([[ -w $target ]] || echo 1)" -v year="$(date +%Y)" \
        -v pal="$ATLAS_FRAME $ATLAS_ACCENT $ATLAS_SOFT $ATLAS_GIT $ATLAS_LANG $ATLAS_WARN $ATLAS_BAD $ATLAS_GOOD" \
        -f "$KUHL_SHELL/lib/style.awk" -e '
    # One entry as exactly w visible columns: icon, name (trimmed to fit), then perms/size/date.
    function cell(i, w, withsize,   meta, room, shown, line) {
        meta = P[i] "  " (withsize ? SOFT sprintf("%5s", S[i]) "  " : "") FRAME W[i] R
        room = w - 2 - 1 - (withsize ? 30 : 23)
        shown = N[i] (L[i] != "" ? " → " L[i] : "")
        if (length(shown) > room) { line = C[i] substr(N[i], 1, room - 1) "…" R; room = 0 }
        else { line = C[i] N[i] R (L[i] != "" ? FRAME " → " L[i] R : ""); room -= length(shown) }
        return C[i] I[i] R " " line pad(room + 1) meta
    }
    {
        type = $2; name = $8
        if (!all && name ~ /^\./) { hidden++; next }
        isdir = $1 == "d"
        classify(type, isdir, $3, name)
        if (type == "d") name = name "/"
        else if (type != "l") total += $4
        i = ++n
        if (isdir) D[++dirs] = i; else F[++files] = i
        N[i] = name; L[i] = type == "l" ? $9 : ""; I[i] = ICON; C[i] = COLOR; P[i] = perms($3)
        S[i] = type == "d" ? "-" : human($4); W[i] = $5 " " ($6 == year ? $7 : " " $6)
    }
    END {
        head = FRAME "╭─[" B ACCENT " " where R (ro ? BAD " " R : "") FRAME "]"
        hw = 6 + length(where) + (ro ? 2 : 0)
        if (branch != "") { head = head "─(" B GIT " " branch R FRAME ")"; hw += 5 + length(branch) }
        dfoot = sprintf("%d dir%s", dirs, dirs == 1 ? "" : "s")
        ffoot = sprintf("%d file%s · %s", files, files == 1 ? "" : "s", human(total + 0))
        if (hidden) ffoot = ffoot sprintf(" · %d hidden", hidden)
        bar = FRAME "│" R " "

        if (cols >= 130 && dirs && files) {
            # Two panes: "│ " left " │ " right; the split column gets ┬ and ┴ in the frame.
            wl = int((cols - 5) * 0.45); wr = cols - 5 - wl; mid = 2 + wl + 1
            rows = dirs > files ? dirs : files
            print head (hw < mid ? rule(mid - hw) "┬" rule(cols - mid - 1) : rule(cols - hw)) R
            for (r = 1; r <= rows; r++)
                print bar (r <= dirs ? cell(D[r], wl, 0) : pad(wl)) " " FRAME "│" R " " (r <= files ? cell(F[r], wr, 1) : pad(wr))
            print FRAME "╰─(" SOFT dfoot FRAME ")" rule(mid - 4 - length(dfoot)) "┴─(" SOFT ffoot FRAME ")" rule(cols - mid - 4 - length(ffoot)) R
            exit
        }
        print head rule(cols - hw) R
        for (r = 1; r <= dirs; r++)  print bar cell(D[r], cols - 2, 1)
        for (r = 1; r <= files; r++) print bar cell(F[r], cols - 2, 1)
        if (!n) print bar DIM SOFT "  (empty)" R
        foot = dfoot " · " ffoot
        print FRAME "╰─(" SOFT foot FRAME ")" rule(cols - length(foot) - 4) R
    }'
}
