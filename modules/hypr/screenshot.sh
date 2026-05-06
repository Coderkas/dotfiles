#!/usr/bin/env bash
function select_area() {
    cmd='grim -g "$(slurp)" - | wl-copy; pkill wayfreeze'
    wayfreeze --after-freeze-cmd "$cmd"
}

function select_monitor() {
    monitor=$(hyprctl activeworkspace -j | jq -r .monitor)
    grim -o "$monitor" - | wl-copy
}

function select_window() {
    window=$(hyprctl activewindow -j | jq -r .stableId)
    grim -T "$window" - | wl-copy
}

function tesseracting() {
    cmd='grim -l 0 -g "$(slurp)" - | wl-copy; pkill wayfreeze'
    wayfreeze --after-freeze-cmd "$cmd"
    wl-paste | tesseract -l "$2" - - | wl-copy
}

case "$1" in
"select") select_area ;;
"monitor") select_monitor ;;
"window") select_window ;;
"tesseract") tesseracting "$@" ;;
*) notify-send "something went wrong" ;;
esac
