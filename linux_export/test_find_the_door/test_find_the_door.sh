#!/bin/sh
echo -ne '\033c\033]0;scribble_2d\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/test_find_the_door" "$@"
