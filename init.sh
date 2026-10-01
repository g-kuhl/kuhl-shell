# kuhl-shell: sourced from ~/.bashrc by the block install.sh adds.
# Sets up the starship prompt, dir, tree, df, du, ip, free, ports, uptime, apt, git status, dt, update, welcome
# and the login welcome screen.
# Set KUHL_NO_WELCOME=1 before this line to skip the welcome screen at login.
[[ $- == *i* ]] || return 0
export KUHL_SHELL=${KUHL_SHELL:-$HOME/.local/share/kuhl-shell}
. "$KUHL_SHELL/lib/palette.sh"
. "$KUHL_SHELL/lib/dir.sh"

unalias update welcome ports uptime df du ip tree free apt git sudo 2>/dev/null
update()  { "$KUHL_SHELL/bin/sys-update" "$@"; }
welcome() { "$KUHL_SHELL/bin/welcome" "$@"; }
ports()   { "$KUHL_SHELL/bin/kports" "$@"; }

# Framed versions of everyday commands. Only the usual interactive forms (df -h,
# du -sh, ip a, tree -L 2, free -h) are framed, and only when output goes to the
# terminal; other flags, pipes and redirects get the real command. `command df`
# (or \df) always skips them.
df() {
    if [[ -t 1 && ( $# -eq 0 || $* == -h || $* == -H ) ]]; then "$KUHL_SHELL/bin/kdf"
    else command df "$@"; fi
}
du() {
    local a args=()
    for a in "$@"; do [[ $a == -[sh]* && $a =~ ^-[sh]+$ ]] || args+=("$a"); done
    if [[ -t 1 && ${#args[@]} -le 1 && -d ${args[0]:-.} && ( ${#args[@]} -eq 0 || ${args[0]} != -* ) ]]; then
        "$KUHL_SHELL/bin/kdu" "${args[@]}"
    else command du "$@"; fi
}
ip() {
    if [[ -t 1 && ( $# -eq 0 || ( $# -eq 1 && $1 =~ ^(a|addr|address)$ ) ) ]]; then "$KUHL_SHELL/bin/kip"
    else command ip "$@"; fi
}
free() {
    if [[ -t 1 && ( $# -eq 0 || $1 =~ ^-[hmg]$ && $# -eq 1 ) ]]; then "$KUHL_SHELL/bin/kfree"
    else command free "$@"; fi
}
uptime() {
    if [[ -t 1 && ( $# -eq 0 || $* == -p || $* == --pretty ) ]]; then "$KUHL_SHELL/bin/kuptime"
    else command uptime "$@"; fi
}
tree() {
    local a framed=1
    for a in "$@"; do [[ $a == -* && ! $a =~ ^-(L[0-9]*|a|d)$ ]] && framed=; done
    if [[ -t 1 && $framed ]]; then "$KUHL_SHELL/bin/ktree" "$@"
    elif command -v tree >/dev/null; then command tree "$@"
    else echo "tree: that option needs the tree package (sudo apt install tree)" >&2; return 1; fi
}

# apt install|remove|purge PACKAGE... (optionally with -y) is planned, shown and run in a
# frame; it asks for sudo itself. Other apt commands and flags get the real apt, with
# sudo added when the command needs root (apt update, upgrade, install -s ...).
# `sudo apt install ...` is framed too. \apt skips it.
_kuhl_apt_framed() {
    local a
    [[ -t 1 && $1 =~ ^(install|remove|purge)$ && $# -ge 2 ]] || return 1
    for a in "${@:2}"; do
        [[ $a == -y || $a == --yes || ( $a != -* && $a != [./]* && $a != *.deb ) ]] || return 1
    done
}
apt() {
    if _kuhl_apt_framed "$@"; then "$KUHL_SHELL/bin/kapt" "$@"
    elif (( EUID )) && command -v sudo >/dev/null && [[ $1 =~ ^(install|reinstall|remove|purge|autoremove|autopurge|update|upgrade|full-upgrade|dist-upgrade|clean|autoclean|edit-sources|satisfy)$ ]]; then
        # shellcheck disable=SC2033  # `command` bypasses the sudo function defined below
        command sudo apt "$@"   # commands that need root get it, so apt update just works
    else command apt "$@"; fi
}
sudo() {
    if [[ $1 == apt ]] && _kuhl_apt_framed "${@:2}"; then "$KUHL_SHELL/bin/kapt" "${@:2}"
    else command sudo "$@"; fi
}
# git status, plain or -s/-sb/--short, is framed; every other git command is untouched.
git() {
    if [[ $1 == status && -t 1 ]] && (( $# == 1 )) || [[ $1 == status && -t 1 && $# -eq 2 && $2 =~ ^(-s|-sb|-bs|--short)$ ]]; then
        "$KUHL_SHELL/bin/kgit"
    else command git "$@"; fi
}

# dt: run a deno task by its number in the prompt's task line (dt 2), or by name.
# Plain `dt` lists them. Extra arguments go to the task: dt 4 --filter foo
dt() {
    local names; mapfile -t names < <("$KUHL_SHELL/prompt/tasks.sh" --names)
    if (( ! ${#names[@]} )); then echo "dt: no deno tasks here" >&2; return 1; fi
    if [[ -z $1 ]]; then
        local i; for i in "${!names[@]}"; do printf '%2d  %s\n' $((i + 1)) "${names[i]}"; done
        return
    fi
    local task=$1; shift
    if [[ $task =~ ^[0-9]+$ ]]; then
        (( task >= 1 && task <= ${#names[@]} )) || { echo "dt: no task $task (1-${#names[@]})" >&2; return 1; }
        task=${names[task-1]}
    fi
    echo "▶ deno task $task $*"
    deno task "$task" "$@"
}

# Swap to the compact prompt in narrow terminals (re-checked before every prompt).
_kuhl_pick_config() {
    export STARSHIP_COLS=${COLUMNS:-$(tput cols)}   # read by prompt/tasks.sh
    if (( STARSHIP_COLS < 72 )); then
        export STARSHIP_CONFIG="$KUHL_SHELL/prompt/starship-compact.toml"
    else
        export STARSHIP_CONFIG="$KUHL_SHELL/prompt/starship.toml"
    fi
}
if command -v starship >/dev/null; then
    starship_precmd_user_func=_kuhl_pick_config
    _kuhl_pick_config
    [[ -n ${STARSHIP_SHELL:-} ]] || eval "$(starship init bash)"
fi

shopt -q login_shell && [[ -z ${KUHL_NO_WELCOME:-} ]] && "$KUHL_SHELL/bin/welcome"
return 0
