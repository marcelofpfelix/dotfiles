#!/usr/bin/env bash
# Shared Quickshell menu metadata for small shell helpers.

qs_menu_panels=(
  launcher controls media notifications work-inbox personal-dashboard
  calendar wallpaper screen settings keybindings clipboard passmenu websearch network tray power power-confirm
)

declare -gA qs_menu_labels=(
  [calendar]="Calendar"
  [clipboard]="Clipboard history"
  [controls]="Controls"
  [keybindings]="Keybindings"
  [launcher]="Apps"
  [media]="Media"
  [network]="Network"
  [notifications]="Notifications"
  [passmenu]="Passwords"
  [power]="Session menu"
  [settings]="Settings"
  [tray]="Tray"
  [wallpaper]="Wallpaper"
  [websearch]="Web search"
)

qs_menu_list() {
  printf "%s\n" "${qs_menu_panels[@]}"
}

qs_menu_label() {
  local id=${1:-}
  printf "%s\n" "${qs_menu_labels[$id]:-$id}"
}

qs_menu_open_panel() {
  qs-bar "$1"
}

qs_menu_crop_geometry() {
  local panel=$1 max_w=$2 max_h=$3
  local width=720 height=700 x y

  case "$panel" in
    launcher) width=960; height=820; x=$(((max_w - width) / 2)); y=$(((max_h - height) / 2)) ;;
    clipboard|passmenu) width=800; height=660; x=$(((max_w - width) / 2)); y=$(((max_h - height) / 2)) ;;
    websearch) width=820; height=180; x=$(((max_w - width) / 2)); y=$(((max_h - height) / 2)) ;;
    osd) width=360; height=140; x=$(((max_w - width) / 2)); y=0 ;;
    notifications) width=440; height=170; x=$((max_w - width)); y=0 ;;
    wallpaper) width=720; height=150; x=$((max_w - width)); y=0 ;;
    controls) width=760; height=840; x=$((max_w - width)); y=0 ;;
    calendar) width=780; height=840; x=$((max_w - width)); y=0 ;;
    personal-dashboard) width=720; height=620; x=$((max_w - width)); y=0 ;;
    *) x=$((max_w - width)); y=0 ;;
  esac

  (( width > max_w )) && width=$max_w
  (( height > max_h )) && height=$max_h
  (( x < 0 )) && x=0
  (( y < 0 )) && y=0
  (( x + width > max_w )) && x=$((max_w - width))
  (( y + height > max_h )) && y=$((max_h - height))

  printf "%s %s %s %s\n" "$width" "$height" "$x" "$y"
}
