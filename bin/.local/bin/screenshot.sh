#!/bin/sh

command -v slurp > /dev/null || exit 1
command -v grim > /dev/null || exit 1

slurp | grim -g - - | wl-copy
