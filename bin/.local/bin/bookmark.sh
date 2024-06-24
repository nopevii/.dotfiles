#!/bin/sh

command -v wofi > /dev/null || exit 1
command -v firefox > /dev/null || exit 1

selected="$(grep -v "^#\|^$" "$HOME/.dotfiles/url.txt" | wofi -d)"
[ -z "$selected" ] && exit 0
pgrep firefox \
    && firefox "$selected" \
    || setsid -f firefox "$selected"
