# X11 Desktop Archive

This directory keeps the pre-Hyprland X11 desktop configuration out of the active
`desktop/` tree so `home -y` does not copy it back into `$HOME`.

Archived paths:

- `desktop/.config/i3`: old i3 session config.
- `desktop/.config/polybar`: old Polybar status bar config.
- `desktop/.config/rofi`: old rofi launcher/calendar config.
- `desktop/.config/picom`: old X11 compositor config.
- `desktop/bin/ddspawn`: old i3 scratchpad/dropdown helper.

Restore by copying the needed path back under the repo `desktop/` tree, then run
`home -y`.
