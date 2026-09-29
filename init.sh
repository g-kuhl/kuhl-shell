# kuhl-shell: sourced from ~/.bashrc by the block install.sh adds.
# Sets up the starship prompt, `dir`, `dt`, `update`, `welcome`, and the login welcome screen.
# Set KUHL_NO_WELCOME=1 before this line to skip the welcome screen at login.
[[ $- == *i* ]] || return 0
export KUHL_SHELL=${KUHL_SHELL:-$HOME/.local/share/kuhl-shell}
. "$KUHL_SHELL/lib/palette.sh"
. "$KUHL_SHELL/lib/dir.sh"

unalias update welcome 2>/dev/null
update()  { "$KUHL_SHELL/bin/sys-update" "$@"; }
welcome() { "$KUHL_SHELL/bin/welcome" "$@"; }

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
