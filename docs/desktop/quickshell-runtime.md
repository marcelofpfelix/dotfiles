# Quickshell Runtime Verification

`qbar` resolves `qs` and `quickshell` through PATH, with the user's separately
upgraded Nix profile before the older desktop closure. Keep both commands on
the same runtime. Missing `PwNodePeakMonitor`, `Quickshell.Networking`, or
`updatesEnabled` errors indicate an incompatible runtime, not missing plugin
manifests. The audio/network panels require the installed 0.3 runtime.

Deploy from the Mac through the existing home composition:

```sh
home -wf -t lap0
```

On lap0, use the actual graphical user's `XDG_RUNTIME_DIR`, D-Bus, Wayland
display and Hyprland instance from `systemctl --user show-environment`.
Restart only Quickshell with `qbar restart`, then run:

```sh
qbar shell ping
python3 ~/tests/quickshell_plugins_test.py --live
qbar shell listBarGeometry
```

The live test compares the loaded config to `~/.config/omarchy/shell.json`
and checks all referenced widgets and enabled services. `listPlugins.active`
means an overlay is currently open; it does not mean a service or bar widget
loaded. Use `serviceLoaded`, `widgetRegistered`, and `widgetCount` instead.
An empty placeholder can have `widgetCount=1` but is not registered.

Test menus by opening and closing them without activating their actions:
`qbar root-menu`, `qbar media`, and
`qbar shell summon marcelof.media-controls '{}'`. Query `qbar shell state`
for root/custom menu state; confirm positive-size visible surfaces with
`hyprctl -j layers`. Finish with `qbar shell closePanels`. Do not test lock,
power, Wi-Fi QR, clipboard contents, or secret-store actions as menu probes.
