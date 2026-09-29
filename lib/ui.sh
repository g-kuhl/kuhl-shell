# kuhl-shell: palette colors plus box-frame helpers, sourced by bin/welcome and
# bin/sys-update so they match the prompt (╭─ │ ╰─, rules to the edge).
KUHL_SHELL=${KUHL_SHELL:-$HOME/.local/share/kuhl-shell}
. "$KUHL_SHELL/lib/palette.sh"
_hex() { printf '\e[38;2;%d;%d;%dm' "0x${1:1:2}" "0x${1:3:2}" "0x${1:5:2}"; }
FRAME=$(_hex "$ATLAS_FRAME") ACCENT=$(_hex "$ATLAS_ACCENT") SOFT=$(_hex "$ATLAS_SOFT") GIT=$(_hex "$ATLAS_GIT")
LANG_=$(_hex "$ATLAS_LANG") WARN=$(_hex "$ATLAS_WARN") BAD=$(_hex "$ATLAS_BAD") GOOD=$(_hex "$ATLAS_GOOD")
R=$'\e[0m' B=$'\e[1m' DIM=$'\e[2m'
COLS=${COLUMNS:-$(tput cols 2>/dev/null || echo 80)}

# Visible width of a string, ignoring color codes.
vlen() {
    local s=$1 re=$'\e\\[[0-9;]*m'
    while [[ $s =~ $re ]]; do s=${s//"${BASH_REMATCH[0]}"/}; done
    echo "${#s}"
}
rule() { local s; printf -v s '%*s' "$(( $1 > 0 ? $1 : 0 ))" ''; printf '%s' "${s// /─}"; }
# seg COLOR TEXT → (text) in frame brackets, like the prompt's segments.
seg() { printf '%s(%s%s%s)' "$FRAME" "$1" "$2" "$FRAME"; }
# top/bottom LEFT [RIGHT]: a frame line with the gap filled to the terminal edge.
top()    { local l=$1 r=${2:-}; printf '%s╭─%s%s%s%s\n' "$FRAME" "$l" "$FRAME" "$(rule $(( COLS - 2 - $(vlen "$l") - $(vlen "$r") )))" "$r$R"; }
bottom() { local l=$1 r=${2:-}; printf '%s╰─%s%s%s%s\n' "$FRAME" "$l" "$FRAME" "$(rule $(( COLS - 2 - $(vlen "$l") - $(vlen "$r") )))" "$r$R"; }
row()    { printf '%s│%s %s\n' "$FRAME" "$R" "$1"; }
# meter PCT WIDTH → ━━━━━━──── colored good/warn/bad by how full it is.
meter() {
    local pct=$1 w=$2 fill c
    fill=$(( pct * w / 100 )); (( fill > w )) && fill=$w
    c=$GOOD; (( pct >= 60 )) && c=$WARN; (( pct >= 85 )) && c=$BAD
    local a b; printf -v a '%*s' "$fill" ''; printf -v b '%*s' "$(( w - fill ))" ''
    printf '%s%s%s%s%s' "$c" "${a// /━}" "$FRAME" "${b// /─}" "$R"
}
# human BYTES → 4.1G
human() { numfmt --to=iec --format='%.1f' "$1" | sed 's/\.0\([A-Z]\)/\1/'; }
