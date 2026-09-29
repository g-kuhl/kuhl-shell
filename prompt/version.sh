#!/usr/bin/env bash
# Print the project version: a VERSION file at the repo root, else the
# "version" field of deno.json / deno.jsonc / package.json. Prints nothing if none.
# Usage: starship-version.sh [dir]   (defaults to $PWD)
dir=${1:-$PWD}
root=$(git -C "$dir" --no-optional-locks rev-parse --show-toplevel 2>/dev/null) || root=$dir
if [[ -f $root/VERSION ]]; then
    v=$(head -n1 "$root/VERSION" | tr -d '[:space:]')
else
    for f in deno.json deno.jsonc package.json; do
        [[ -f $root/$f ]] || continue
        v=$(grep -m1 -oE '"version"[[:space:]]*:[[:space:]]*"[^"]+"' "$root/$f" | sed -E 's/.*"([^"]+)"$/\1/')
        [[ -n $v ]] && break
    done
fi
[[ -n $v ]] && echo "${v#v}"
