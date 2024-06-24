#!/bin/sh

selected="$(find "$HOME/.dotfiles" -type f ! -path "*.git/*" | sort | fzf --preview "bat --style=numbers --color=always {}")"

[ -z "$selected" ] && exit 0

name="$(printf "${selected#/*/*/}" | tr "[/.]" "_")"

[ -z "$(tmux lsw | grep ": $name")" ] \
    && tmux neww -n "$name" -c sh "nvim $selected" \
    || tmux selectw -t "$name"
