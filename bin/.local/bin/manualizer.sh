#!/bin/sh

selected="$(find "/usr/bin/" -type f | sort | fzf)"

[ -z "$selected" ] && exit 0

name="$(printf "man_${selected##*/}" | tr "." "_")"

[ -z "$(tmux lsw | grep ": $name")" ] \
    && tmux neww -n "$name" -c sh "man $selected" \
    || tmux selectw -t "$name"
