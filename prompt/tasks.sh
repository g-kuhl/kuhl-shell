#!/usr/bin/env bash
# Deno task menu for the prompt: "1 dev  2 test  3 check", trimmed to fit the
# terminal. Prints nothing when there's no deno.json or it has no tasks.
# Usage: starship-tasks.sh [--names] [dir]
#   --names  one task name per line, in menu order (used by `dt` in init.sh)
# Width comes from $STARSHIP_COLS, set in init.sh.
names_only=; [[ $1 == --names ]] && { names_only=1; shift; }
dir=${1:-$PWD}
root=$(git -C "$dir" --no-optional-locks rev-parse --show-toplevel 2>/dev/null) || root=$dir
for f in "$root/deno.json" "$root/deno.jsonc"; do
    [[ -f $f ]] || continue
    # deno.jsonc may carry // comments, which jq can't read
    mapfile -t names < <(sed -E 's#^[[:space:]]*//.*$##' "$f" | jq -r '(.tasks // {}) | keys_unsorted[]' 2>/dev/null)
    break
done
(( ${#names[@]} )) || exit 0
if [[ $names_only ]]; then printf '%s\n' "${names[@]}"; exit 0; fi
max=$(( ${STARSHIP_COLS:-80} - 8 ))
out=
for i in "${!names[@]}"; do
    item="$((i + 1)) ${names[i]}"
    if (( ${#out} + ${#item} + 5 > max )); then out+="  …"; break; fi
    out+="${out:+  }$item"
done
echo "$out"
