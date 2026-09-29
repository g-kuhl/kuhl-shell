#!/usr/bin/env bash
# Prompt path with the middle collapsed, Finder-style: ~/projects/…/src/lib
# Usage: starship-path.sh [keep_head] [keep_tail]   (defaults 2 and 2)
head=${1:-2} tail=${2:-2}
p=${PWD/#$HOME/\~}
IFS=/ read -ra parts <<< "$p"
[[ $p == /* ]] && parts[0]=/
n=${#parts[@]}
if (( n > head + tail )); then
    out=$(IFS=/; echo "${parts[*]:0:head}")/…/$(IFS=/; echo "${parts[*]:n-tail}")
else
    out=$p
fi
echo "${out//\/\//\/}"
