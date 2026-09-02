#!/usr/bin/env bash
# Shared Quickshell menu metadata for small shell helpers.

qs_menu_panels=(
  root-menu launcher controls media media-controls bluetooth notifications work-inbox personal-dashboard
  calendar wallpaper screen settings keybindings clipboard emojis passmenu websearch network network-tools
  display battery wifi-qr tray power power-confirm
)

declare -gA qs_menu_labels=(
  [bluetooth]="Bluetooth"
  [calendar]="Calendar"
  [clipboard]="Clipboard history"
  [controls]="Controls"
  [emojis]="Emojis"
  [keybindings]="Keybindings"
  [launcher]="Apps"
  [media]="Media"
  [media-controls]="Player and saved audio"
  [network]="Network"
  [network-tools]="Network details"
  [notifications]="Notifications"
  [passmenu]="Passwords"
  [power]="Session menu"
  [root-menu]="Menu"
  [screen]="Screen"
  [settings]="Settings"
  [tray]="Tray"
  [wallpaper]="Wallpaper"
  [websearch]="Web search"
  [display]="Displays"
  [battery]="Battery and power"
  [wifi-qr]="Share Wi-Fi"
)

qs_menu_list() {
  printf "%s\n" "${qs_menu_panels[@]}"
}

qs_menu_label() {
  local id=${1:-}
  printf "%s\n" "${qs_menu_labels[$id]:-$id}"
}

qs_menu_open_panel() {
  case "$1" in
    keybindings) qbar keybindings >/dev/null 2>&1 & ;;
    media-controls) qbar shell toggle marcelof.media-controls ;;
    network-tools) qbar shell toggle marcelof.network-tools ;;
    *) qbar "$1" ;;
  esac
}

qs_menu_crop_geometry() {
  local panel=$1 max_w=$2 max_h=$3
  local width=720 height=700 x y

  case "$panel" in
    root-menu|power) width=500; height=840; x=$(((max_w - width) / 2)); y=$(((max_h - height) / 2)) ;;
    launcher) width=960; height=820; x=$(((max_w - width) / 2)); y=$(((max_h - height) / 2)) ;;
    clipboard|passmenu) width=800; height=660; x=$(((max_w - width) / 2)); y=$(((max_h - height) / 2)) ;;
    keybindings) width=1300; height=$max_h; x=$(((max_w - width) / 2)); y=0 ;;
    websearch) width=700; height=124; x=$(((max_w - width) / 2)); y=$(((max_h - height) / 2)) ;;
    emojis|wallpaper) width=$max_w; height=$max_h; x=0; y=0 ;;
    media-controls|network-tools|wifi-qr) width=900; height=800; x=$(((max_w - width) / 2)); y=$(((max_h - height) / 2)) ;;
    battery) width=720; height=700; x=0; y=0 ;;
    osd) width=360; height=140; x=$(((max_w - width) / 2)); y=$((max_h - height)) ;;
    notifications) width=720; height=620; x=$(((max_w - width) / 2)); y=21 ;;
    controls) width=840; height=1020; x=$((max_w - width)); y=0 ;;
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
