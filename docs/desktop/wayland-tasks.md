# Wayland parity tasks

## Profiles

- [x] Keep exactly two Hyprland profiles: `default` and `omarchy`.
- [x] Make `default` the i3-compatible migration profile.
- [x] Make `omarchy` provide similar Wayland-first behavior without upstream runtime binaries.
- [x] Start Hyprland through the documented `start-hyprland -- --config ...` path.
- [x] Install/require `nixGL` for Nix-packaged Hyprland on Ubuntu.
- [x] Add GDM session integration with rollback through `hypr-gdm`.

## Default profile parity

- [x] `Win+Enter` opens Ghostty.
- [x] `Win+D` opens the Quickshell fuzzy application launcher.
- [x] `Win+A` has an explicit i3-parity notice for unsupported focus-parent behavior.
- [x] `Win+W` closes the focused window, matching the Omarchy quattro binding accepted for this migration.
- [x] `Win+S` uses the local `hypr-scratch` helper and `Win+Alt+S` moves the active window there.
- [x] `Win+U` toggles a floating tmux popup session through `hypr-term popup-tmux`.
- [x] `Win+R` reports the resize replacement.
- [x] `Win+Space` opens the Quickshell launcher; the old floating-focus behavior is not kept because app launch is the accepted default.
- [x] `Win+Shift+E` uses the Quickshell exit confirmation instead of exiting immediately.
- [x] `Win+Alt+L` calls the Quickshell lock IPC target so `Win+Ctrl+L` can stay resize-right.
- [x] `Win+Ctrl+A` opens the Quickshell controls popup, which now acts as the all-menus hub.
- [x] `Win+Ctrl+V` and `Win+Ctrl+W` are explicit no-op blockers so they do not fall through to `Win+V` paste or `Win+W` close.

## Omarchy profile parity

- [x] `Win+Space` opens the local Quickshell launcher through `qbar launcher`.
- [x] `Win+W` closes the focused window like Omarchy quattro.
- [x] `Win+S` uses the local `hypr-scratch` helper and `Win+Alt+S` moves a window there.
- [x] `Win+Escape` and `Win+Shift+E` open the local Quickshell exit confirmation.
- [x] `Win+Ctrl+L` calls the local Quickshell lock IPC target.
- [x] `Win+Ctrl+V` and `Win+Ctrl+W` are explicit no-op blockers; the controls menu opens the network panel through `qs ipc call network toggle`.
- [x] `Win+K` opens local Quickshell keybindings, matching Omarchy quattro behavior without upstream binaries.
- [x] `Win+Ctrl+A` opens local Quickshell controls/audio, matching Omarchy quattro intent without upstream binaries.
- [x] `Win+Shift+Space` toggles the local Quickshell bar.
- [x] `Win+G`, `Win+Alt+G`, `Win+Alt+Arrows`, and `Win+Alt+Tab` use native Hyprland groups.
- [x] `Win+Shift+Arrows` swaps windows like Omarchy quattro.
- [x] `Alt+Volume` and `Alt+Brightness` provide precise native adjustments.
- [x] `Win+C`, `Win+V`, and `Win+X` provide universal clipboard shortcuts without external shell IPC in the Omarchy-like profile; default uses `Win+V` for terminal-aware paste and `Win+Shift+V` for vertical split.
- [x] Avoid upstream runtime binaries; implement similar behavior with generic tools and local Quickshell IPC.
- [x] Use local Quickshell IPC and common Wayland apps/CLIs for launcher, network, lock, screenshot, audio, and related actions.
- [x] Media playback keys use generic `playerctl`; volume and brightness use `pactl` and `brightnessctl`.
- [x] Clipboard history is available from the Quickshell controls menu backed by `cliphist decode | wl-copy`; `cliphist`, `wl-copy`, and `wl-paste` are tracked.

## Quickshell replacements

- [x] Replace the main rofi app launcher with a Quickshell fuzzy launcher.
- [x] Replace the Polybar workspace/status/tray surface with Quickshell.
- [x] Render Polybar color markup through `BAR_COLOR_FORMAT=quickshell` for Quickshell status text.
- [x] Put wallpaper ownership in Quickshell startup.
- [x] Put system tray ownership in Quickshell startup.
- [x] Add a Quickshell-owned network panel and status segment.
- [x] Add a Quickshell-owned lock IPC command using `hyprlock`, `swaylock`, or `loginctl lock-session`.
- [x] Keep secure locking delegated to a real Wayland locker instead of faking a lock window.
- [x] Replace Wayland rofi/dmenu/zenity utility paths in `passmenu` and `rcal` with Quickshell-owned popups.
- [x] Add a native Quickshell calendar popup with month navigation, today highlighting, Lisbon time context, and todo detail area.
- [x] Add a Quickshell password picker popup for `passmenu` parity: fuzzy entry filtering, copy password, type password, type username, and type entry name.
- [x] Replace X11 monitor toggling with a Hyprland-aware `monitor` path.
- [x] Add optional `cliphist-menu watch` startup guarded by `command -v cliphist`.
- [x] `gocode` and `gowork` are Hyprland-only under this desktop profile.

## Validation

- [x] `bash -n` passes for touched shell helpers.
- [x] `luac -p` passes for Hyprland Lua profiles.
- [x] `qmllint` passes for local Quickshell QML.
- [x] `Hyprland --config desktop/.config/hypr/init.lua --verify-config` passes for `default`.
- [x] `HYPR_PROFILE=omarchy Hyprland --config desktop/.config/hypr/init.lua --verify-config` passes for `omarchy`.
- [x] Live files under `$HOME/.config/hypr`, `$HOME/.config/quickshell`, `$HOME/.config/board`, `$HOME/bin`, and `$HOME/lib` are refreshed from the repo.
- [x] Safe color-format sample proves Quickshell rich text and plain output modes.
- [x] `hypr-session status` and `hypr-session smoke` check required Wayland tools, Quickshell, board, notification owner, portals, clock sync, audio state, inactive dunst, legacy launcher masks, Hyprland/Quickshell config validity, generated keybinding help, Quickshell IPC menu targets, `qbar` menu commands, and optional `hyprpicker`.
- [x] `desktop/tools/desktop-doctor` wraps the live Wayland smoke check with current profile, Quickshell status, board status, picker helper status, clipboard helper status, audio state, audioctl pause/resume/status regression checks, screenshot helper status, wallpaper helper status, screen-record status, notification-smoke readiness, and static browser wrapper flag checks.
- [x] `desktop/tools/desktop-package-audit` verifies active Wayland helper package intent, including local `board`, is tracked in the sibling homelab install list, and `desktop/tools/desktop-doctor` runs it.
- [x] `desktop/tools/qs-menu-smoke` opens, captures, closes, and checks Quickshell launcher/control/media/notification/calendar/wallpaper/screen/keybinding/clipboard/websearch/network/tray/power/power-confirm menu screenshots plus `contact.png` for visual regression checks; `desktop/tools/desktop-doctor` now fails when the latest smoke run predates live Quickshell QML.

## References

Reference review snapshot: 2026-07-26. Keep exact star counts out of this file because they drift; use popularity only as a rough priority signal.

- end-4 dots-hyprland: https://github.com/end-4/dots-hyprland
  - Status: high-signal Quickshell plus Hyprland reference.
  - Kept locally: visual smoke screenshots, keybinding discoverability, notification/control/media polish goals, and Hyprland 0.55/Lua awareness.
  - Rejected here: full installer flow, AI/search extras, large theme engine, and distro-wide setup assumptions.
- Caelestia shell: https://github.com/caelestia-dots/shell
  - Status: high-signal Quickshell shell reference.
  - Kept locally: small IPC surface, shell-owned wallpaper/menu behavior, MPRIS/media ideas, hidden launcher entries, and config/state separation.
  - Rejected here: upstream CLI/runtime names, C++ plugin build path, broad token/theming system, and heavy dependency set.
- Noctalia shell: https://github.com/noctalia-dev/noctalia-shell
  - Status: high-signal Wayland shell reference.
  - Kept locally: desktop-shell boundary, compact control surfaces, notification history, brightness/audio/network/power modules, and clear package boundary thinking.
  - Rejected here: forked `noctalia-qs` runtime, plugin ecosystem, setup wizard, and shell-managed features better owned by Hyprland or normal apps.
- Omarchy: https://github.com/basecamp/omarchy
  - Status: high-signal Hyprland workflow reference, not a runtime dependency.
  - Kept locally: accepted key behavior, generated keybinding menu idea, local diagnostics/doctor direction, screen/share/menu shortcuts, and package/update hygiene ideas.
  - Rejected here: Omarchy-named binaries, distro-level refresh/update machinery, and assumptions that conflict with the default i3-compatible profile.
- cxOrz dotfiles-hyprland: https://github.com/cxOrz/dotfiles-hyprland
  - Status: lower-star but useful concrete ChromeOS-style layout reference.
  - Kept locally: compact control center shape, power/menu grouping, and tray/menu ergonomics.
  - Rejected here: rofi launcher, waybar/dunst ownership, hyprpaper ownership, Arch-only package assumptions, and greetd/session defaults.
- Aylur AGS/dotfiles ecosystem: https://github.com/Aylur/ags and https://aylur.github.io/ags/
  - Status: useful service/UI design reference, not part of the active stack.
  - Kept locally: listen-vs-poll thinking, notification/media/network service boundaries, launcher click-away behavior, and Alt-number launcher selection.
  - Rejected here: adding AGS/Astal as another shell runtime.
- surface-dots: https://github.com/snes19xx/surface-dots
  - Status: limited value for this Quickshell migration.
  - Kept locally: Hyprland-first login/session presentation checks.
  - Rejected here: monitor/surface-specific layout assumptions.
- ilyamiro nixos-configuration: https://github.com/ilyamiro/nixos-configuration
  - Status: useful for native Hyprland state ideas.
  - Kept locally: `hyprctl -j` state generation and event-triggered refresh.
  - Rejected here: a dedicated cache daemon until measured polling cost justifies it.
- ML4W dotfiles: https://github.com/mylinuxforwork/dotfiles
  - Status: popular Hyprland dotfiles reference, but broad distro/tooling scope.
  - Kept locally: doctor/setup validation direction and distro-aware package docs.
  - Rejected here: installer app, distro-wide OS assumptions, and broad app bundle.
- JaKooLit Hyprland-Dots: https://github.com/JaKooLit/Hyprland-Dots
  - Status: popular Hyprland install/dots reference, but not Quickshell-first.
  - Kept locally: installer-package tracking reminder and practical first-login checks.
  - Rejected here: rofi/waybar/swww/wallust stack and broad install scripts.

## Reference-derived implementation tasks

### Open UI/UX enhancement tasks

Review snapshot: 2026-07-28. Sources were local clones under `/tmp/wayland-ui-review`; refreshed clones include Caelestia, end-4, Noctalia, Omarchy, cxOrz, Aylur AGS, surface-dots, ilyamiro/nixos-configuration, ML4W, and JaKooLit. Refresh again before copying exact upstream code.

- [x] Add a launcher command mode.
  - Sources: Caelestia launcher actions/calculator/wallpaper modes, Omarchy menu app library.
  - Dependencies: keep the existing Quickshell launcher; add packages to homelab only if a calculator CLI is chosen.
  - Acceptance: `Win+D` can still launch apps, but a prefix can run local commands such as calculator, web search, wallpaper, and existing desktop helpers without rofi/dmenu.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/shell.qml`, `desktop/tools/qs-menu-smoke launcher`, and one manual calculator/action launch.
  - Current behavior: `>` in the launcher opens command rows for web, YouTube, calculator, wallpaper, controls, settings, notifications, DND, media, and screenshot.
- [x] Add launcher favorite and hidden-app management.
  - Sources: Caelestia app favourites/hidden-app config, Omarchy launcher hide entries.
  - Dependencies: reuse Quickshell state JSON; do not add a second app database.
  - Acceptance: favorites rank above MRU/MFU, hidden apps disappear from the launcher, and both settings survive `qbar reload`.
  - Validation: `desktop/tools/qs-menu-smoke launcher` plus manual favorite/hide/reload checks.
  - Current behavior: launcher rows expose favorite and hide controls; favorites rank above MRU/MFU and hidden entries are persisted in Quickshell state.
- [x] Add notification Do Not Disturb.
  - Sources: Caelestia DND toggle, Omarchy persisted notification DND and bar indicator.
  - Dependencies: reuse the current Quickshell notification owner and history model.
  - Acceptance: DND suppresses popup toasts but still records notifications in history, has a visible active state, and persists across `qbar reload`.
  - Validation: `desktop/tools/desktop-notification-smoke --status`, `desktop/tools/desktop-notification-smoke actions`, `desktop/tools/qs-menu-smoke notifications controls`, and manual DND check.
  - Current behavior: DND persists in Quickshell state, suppresses toast popups, keeps notification history, and has bar/settings indicators.
- [x] Add volume, mic, and brightness OSD feedback.
  - Sources: Caelestia OSD module, Noctalia OSD overlay.
  - Dependencies: reuse current audio and brightness helpers; no new always-on daemon.
  - Acceptance: volume, mic mute, screen brightness, and keyboard brightness key changes show one compact overlay instead of notification spam.
  - Validation: `qmllint`, `desktop/tools/qs-menu-smoke controls`, and manual XF86 key presses.
  - Current behavior: hardware volume, mic, screen brightness, and keyboard brightness bindings route through `desktop-osd` and Quickshell IPC.
- [x] Expand the calendar popup into a light day dashboard.
  - Sources: Caelestia dashboard calendar/weather/date-time widgets, Noctalia calendar/weather direction.
  - Dependencies: reuse `check-weather` and current todo source; no calendar account integration in this task.
  - Acceptance: calendar shows today, Lisbon time, configured extra timezones, weather summary, and the current todo/note block without becoming a full agenda client.
  - Validation: `desktop/tools/qs-menu-smoke calendar` and manual clock/timezone sanity check.
  - Current behavior: calendar includes Lisbon clock, weather summary, and the existing todo block.
- [x] Add optional external monitor brightness controls.
  - Sources: Noctalia `ddcutil` optional dependency, Caelestia brightness service shape.
  - Dependencies: if `ddcutil` is used, track it in homelab install intent first.
  - Acceptance: laptop brightness stays on `brightnessctl`; external displays get separate controls only when `ddcutil detect` finds controllable monitors.
  - Validation: `desktop/tools/desktop-package-audit`, `desktop/tools/qs-menu-smoke controls`, and manual external-monitor brightness change.
  - Current behavior: `ddcutil` is installed and tracked in homelab; `external-brightness status` reports the current percent, `external-brightness set N` was validated by setting the current value back to itself, and Controls exposes the external display as a slider.
- [x] Add richer Bluetooth device controls.
  - Sources: Caelestia Bluetooth popout and device battery display.
  - Dependencies: reuse Quickshell Bluetooth service and existing controls popup.
  - Acceptance: controls can toggle Bluetooth, scan/discover, show connected device names, and show device battery where available.
  - Validation: `qmllint`, `desktop/tools/qs-menu-smoke controls`, and manual Bluetooth toggle/scan check.
  - Current behavior: controls can toggle the adapter, start/stop discovery, and show connected device labels from the Quickshell Bluetooth service.
- [x] Add media now-playing detail.
  - Sources: Caelestia MPRIS dashboard/player selector/cover-progress ideas, Noctalia media widgets.
  - Dependencies: keep `audioctl` for local noise/music; use MPRIS/playerctl for normal players.
  - Acceptance: media popup shows the active MPRIS player, title/artist, play state, and the existing local noise/music controls without dead whitespace.
  - Validation: `audioctl self-test`, `desktop/tools/qs-menu-smoke media`, and manual `audioctl restore` plus normal media player check.
  - Current behavior: `media-now-playing` reports the first MPRIS player; progress and player switching remain deferred until there is a real need.
- [x] Add privacy and session activity indicators.
  - Sources: Noctalia privacy/screencast direction, Caelestia service indicators.
  - Dependencies: reuse portal/audio state; avoid polling faster than current status refreshes.
  - Acceptance: bar indicates active microphone, camera, screen recording, and screen sharing when the local stack exposes that state; clicking opens the relevant screen/media controls.
  - Validation: `desktop/tools/desktop-doctor`, `desktop/tools/qs-menu-smoke screen media`, and manual Meet/share or recording check.
  - Current behavior: `desktop-privacy-status` reports mic capture from Pulse/PipeWire source outputs, camera use from open `/dev/video*` devices, and screen sharing from recorder/portal-style PipeWire nodes. Meet must be confirmed during a live call.
- [x] Add a compact Quickshell settings page for shell-owned toggles.
  - Sources: Caelestia Nexus settings pages, Noctalia configuration boundary.
  - Dependencies: only expose settings already backed by local state files.
  - Acceptance: one popup can change DND, launcher favorites visibility, tray native menus, bar hide/show, weather location, and UI density/font choice without editing files.
  - Validation: `qmllint`, `desktop/tools/qs-menu-smoke controls`, and manual setting persistence after `qbar reload`.
  - Current behavior: `qbar settings` opens DND, native tray menu, bar visibility, density, weather location, launcher, notifications, and controls toggles.

- [x] Reduce polling in the Quickshell bar using native/event state.
  - Source: ilyamiro `hyprctl` workspace JSON plus socket-triggered refresh.
  - Keep it small: use the existing local helper model first; add a daemon only if measured polling cost is visible.
  - Acceptance: workspace/group/scratch indicators update from `hypr-state watch` on Hyprland socket events without a 1s timer.
- [x] Improve the Quickshell notification center layout from polished reference shells.
  - Sources: Omarchy quattro notification service/card split, Noctalia compact notification center, end-4 notification surfaces.
  - Keep local implementation in the existing single shell unless one extracted component clearly shrinks the file.
  - Acceptance: long app/body/action text never overflows collapsed rows; actions remain clickable; clear-one and clear-all still work.
- [x] Tighten the control center layout and controls.
  - Sources: Noctalia all-in-one controls, cxOrz ChromeOS-style quick settings, end-4 quick settings polish.
  - Keep the current local helpers for audio, brightness, network, Bluetooth, and power.
  - Acceptance: audio stream rows, brightness, network, Bluetooth, and power controls use consistent row heights, icons, hover states, and no dead right-side space.
- [x] Build a main Quickshell control dashboard.
  - Sources: Noctalia dashboard/control center, cxOrz ChromeOS-style quick settings, end-4 quick settings.
  - Acceptance: one dashboard exposes audio mixer, player controls, brightness, network, Bluetooth, power profile, battery health, screenshot, lock, and suspend without replacing the smaller popups; recording stays in the screen-record task until a recorder is installed.
- [x] Polish launcher interaction using already-proven app-shell behavior.
  - Sources: AGS launcher example and current Quickshell launcher.
  - Acceptance: launcher closes on Escape, supports direct `Alt+1..9` selection, and keeps MRU/MFU ordering.
- [x] Revisit launcher click-away close only if it can keep the current floating input behavior.
  - Source: AGS full-screen launcher backdrop.
  - Current behavior: launcher, clipboard picker, and web search stay as focused floating Quickshell windows and close when Hyprland clears their focus grab after an outside click.
  - Acceptance: outside click closes the launcher without returning to the earlier no-input/side-window failure mode.
- [x] Split a media dashboard from the control dashboard if the control popup gets crowded.
  - Sources: Caelestia MPRIS controls, AGS/Astal MPRIS service model, Noctalia media widgets.
  - Acceptance: `qbar media` and audio right-click open a dedicated media popup with previous/play-next, pause-all, local noise/music state, stream volume controls, and pavucontrol output switching.
- [x] Build a notification dashboard/inbox.
  - Sources: Omarchy quattro notification service/card split, Noctalia notification center, AGS notification popup replacement behavior.
  - Current behavior: existing center groups recent notifications by app, preserves notification actions, supports clear-one, clear-app, and clear-all, and `desktop/tools/desktop-notification-smoke --status` verifies D-Bus action capability.
  - Acceptance: group by app, show seen/unseen or recent sections, preserve actions, clear one app, clear all.
- [x] Add a small wallpaper/theme popup only if it uses existing local tools.
  - Sources: Caelestia structured config/wallpaper handling, end-4 wallpaper/theme panels.
  - Do not add a theme engine or upstream runtime naming.
  - Acceptance: choose from local wallpapers, apply via the current Wayland wallpaper path, and persist only the selected file/theme token.
  - Current behavior: `qbar wallpaper` lists local files from `~/.local/share/backgrounds` and `~/Pictures/Wallpapers`, previews the active wallpaper, applies it through Quickshell, and persists the path in Quickshell state.
- [x] Add screen-record/share utility popup.
  - Sources: Omarchy quattro share/menu bindings, end-4 utility surfaces.
  - Prefer native tools already tracked for screenshots and portals.
  - Current behavior: `qbar screen` opens a Quickshell popup for screenshot edit/copy/save/full/window, recording start/stop/open/copy-path, and portal status. `wf-recorder` is installed live and tracked in homelab install intent.
  - Acceptance: expose screenshot, screen record start/stop, copy/open result, and portal status without rofi/zenity.
- [x] Add OCR/share only after the screenshot/recording popup exists.
  - Sources: Omarchy-style share flow and end-4 utility UI.
  - Acceptance: selected screenshot can be OCR'd or shared using installed open tools; no extra service stays running.
  - Current behavior: `screenshot-wayland ocr` OCRs a selected area to clipboard using `grim`, `slurp`, `tesseract`, and `wl-copy`; the Screen popup also opens/copies the last saved screenshot path.
- [x] Make keybinding help generated from Hyprland profile data.
  - Sources: Omarchy quattro generated keybinding menu concept.
  - Acceptance: `Win+/` reflects `default`/`omarchy` bindings through `hypr-keys`, without manually duplicating the list in QML.
- [x] Defer a scratchpad dashboard until scratchpad use is proven.
  - Sources: Omarchy/Caelestia special workspace patterns.
  - Current behavior: `Win+S` toggles the helper-backed `special:scratchpad`, `Win+Alt+S` moves the active window there, and Quickshell shows the scratchpad count without exposing it as a numbered workspace.
  - Decision: no dashboard yet; build it only if repeated scratchpad use needs window selection.
  - Acceptance: show scratchpad windows, focus one, move active window there, and move all out.
- [x] Defer named special-workspace app placement until scratchpad use grows.
  - Source: Caelestia configurable special workspace apps.
  - Decision: no named special-workspace app rules yet; document the pattern only after there is a repeated app set.
  - Acceptance: no new special workspace is added until there is a real repeated app set; document the pattern first.
- [x] Improve session/login documentation, not runtime code.
  - Source: surface-dots session/login presentation.
  - Current behavior: `hypr-gdm install` creates the login-manager session file and updates GDM account defaults; the repo tracks the helper and Hyprland entrypoint, not `/usr/share` or `/var/lib` generated state.
  - Acceptance: docs explain how GDM/SDDM discover the Hyprland session and where this dotfiles repo tracks the session files.

## Follow-up

- [x] Reduce controls-hub keybindings to one real shortcut.
  - Current behavior: `Win+Ctrl+A` is the only intentional Controls shortcut; `Win+Ctrl+V` and `Win+Ctrl+W` are explicit no-op blockers, not duplicate menu shortcuts.
- [x] Fix `Win+V` behavior cleanly.
  - Current behavior: `Win+V` is terminal-aware paste; vertical split moved to `Win+Shift+V`; live Hyprland bindings verify `Win+Ctrl+V` and `Win+Ctrl+W` are harmless blockers.

- [x] Build a Quickshell power/session popup for `lock`, `logout`, `suspend`, `hibernate`, `reboot`, and `shutdown`.
  - Use native commands behind a local helper or IPC target: `loginctl lock-session`, `hyprctl dispatch exit`, `systemctl suspend`, `systemctl hibernate`, `systemctl reboot`, and `systemctl poweroff`.
  - Require confirmation for `logout`, `hibernate`, `reboot`, and `shutdown`.
  - Current behavior: the session popup asks for an in-menu confirmation before Hibernate, Reboot, Shutdown, or Exit Hyprland runs; Lock and Suspend stay one-click.
  - Wire `Win+Shift+E` to this popup in the i3-compatible default profile instead of the current exit-only confirmation.
  - Add one common secondary binding, such as `Ctrl+Alt+Delete` or `Win+Delete`, only if it does not conflict with existing i3 parity.
- [x] Build a Quickshell keybindings popup.
  - Show the active profile plus launcher, terminal, movement, workspaces, screenshots, audio, brightness, network, calendar, notifications, scratchpad, reload, and power actions.
  - Bind it to a free key such as `Win+/` or `Win+Ctrl+K`.
  - Generate or source the content close to the Hyprland profile data so it does not drift.
- [x] Finish the rofi/dmenu/zenity migration audit for Wayland.
  - Move i3, polybar, rofi, picom, and `ddspawn` to `archive/x11` so they are not redeployed.
  - Make `passmenu` Quickshell-only under the active Wayland desktop profile.
  - Keep `rcal` opening the native Quickshell calendar under Wayland and plain `cal -3` outside a graphical session.
  - Validate that Hyprland startup, Quickshell actions, and Wayland helpers do not hard-call rofi, dmenu, or zenity.
- [x] Add a Quickshell clipboard history picker.
  - Replace `cliphist-menu` Wayland zenity/fzf selection with a Quickshell fuzzy popup.
  - Keep `cliphist decode | wl-copy` as the backend action after selection.
  - Keep clipboard selection Quickshell-owned for the active Wayland desktop profile.
- [x] Replace the old `Win+,` rofi websearch path with direct Quickshell web-search IPC; keep `websearch` only as a CLI helper.
- [x] Expand the Quickshell control center.
  - [x] Audio popup has per-stream mute/volume, active stream metadata, pavucontrol launch, noise toggle, music toggle, stop, right-click force-stop, and play/pause-all actions.
  - [x] Keep the top bar audio control icon-only; put details in the popup.
  - [x] Add screen brightness controls where hardware support exists.
  - [x] Add keyboard brightness controls where hardware support exists.
  - [x] Add an Awake idle/sleep inhibitor button backed by `systemd-inhibit`.
  - [x] Add richer network and Bluetooth status/toggles using native services.
  - [x] Add power profile and battery health only if the local native service is available.
- [x] Improve the local Quickshell notification center basics.
  - Popup toasts, expandable notification details, action buttons, clear-one, clear-all, and app labels are implemented.
  - Local `notify-send -A` no longer reports missing action support.
- [x] Verify Chrome and Brave native notifications after a full browser restart.
  - Current behavior: fresh temp-profile launches through `chrome-wayland` and `brave-wayland` emitted `org.freedesktop.Notifications.Notify` on D-Bus for service-worker notifications.
- [x] Evaluate Hyprland groups as the closest native replacement for i3 tabbed/stacked containers.
  - Groupbar styling is enabled in both profiles and Quickshell shows active grouped-window count.
- [x] Improve scratchpad/dropdown behavior.
  - `Win+S` scratchpad count is visible beside workspaces without showing special workspaces as numbered workspaces.
  - `Win+U` now uses a stable Ghostty popup title for the tmux popup session.

- [x] Verify browser WebGL through fresh wrapper-launched Chrome and Brave profiles.
  - Current behavior: `chrome-wayland` and `brave-wayland` both expose WebGL 2 through ANGLE on Intel Iris Xe under Hyprland. The wrappers still log a Vulkan compatibility warning, but WebGL works.
  - Decision: do not add `--use-gl=egl`, `--use-angle=opengl`, or `--use-gl=angle --use-angle=opengl`; all three broke WebGL in the smoke test.
- [x] Keep Chrome and Brave on conservative Wayland/PipeWire flags with Vulkan disabled unless `chrome://gpu` proves the Vulkan path is stable under Hyprland.
  - Current behavior: live Chrome and fresh Chrome/Brave test launches keep `--ozone-platform=wayland`, `--enable-native-notifications`, `UseOzonePlatform`, `WebRTCPipeWireCapturer`, `--disable-features=Vulkan`, and `--disable-vulkan`.
- [x] Review Electron apps for Wayland/PipeWire wrappers: Slack first, then 1Password, Obsidian, Zed-like editors, Discord/Zoom if installed.
  - Current behavior: Slack, 1Password, Discord, and Obsidian launch through local Wayland wrappers that unset inherited Nix/Mesa loader state and pass `--ozone-platform=wayland` plus `UseOzonePlatform,WebRTCPipeWireCapturer`.
  - Decision: Zed is already a native local app, and Zoom uses its own `/opt/zoom/ZoomLauncher`; no Electron flags are forced into either.

## 2026-07-28 Dashboard And Integration Tasks

Task source: this file is the canonical local queue for the Hyprland/Quickshell migration. It is fed by direct user requests, current local dotfiles behavior, smoke-test results, local reference clones under `/tmp/wayland-ui-review`, and official service docs when an external API is involved.

- [x] Highlight today and show uptime in the calendar popup.
  - Sources: current `check-time-panel`; Caelestia lock/system info shows uptime as compact status.
  - Acceptance: clock click shows Lisbon time, Unix/hex timestamp, uptime, and the current day visibly marked in the text calendar.
  - Validation: `check-time-panel` and `desktop/tools/qs-menu-smoke calendar`.
- [x] Add signal-aware network status and on-demand public IP.
  - Sources: ilyamiro Quickshell/NMCLI Wi-Fi signal icon thresholds; current local `network-status`.
  - Acceptance: bar uses Wi-Fi strength icons; network popup shows local IP and public IP without polling public IP every bar refresh.
  - Validation: `network-status bar`, `NETWORK_STATUS_PUBLIC_IP=0 network-status details`, and `desktop/tools/qs-menu-smoke network controls`.
- [x] Add a configurable shell primary color defaulting to Catppuccin Mocha lavender.
  - Sources: current Catppuccin palette in `shell.qml`; user preference for lavender as primary.
  - Acceptance: primary color is state-backed and used for notification attention, DND, muted audio, and selected notification borders.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/shell.qml`.
- [x] Add notification source-app focusing.
  - Sources: Quickshell notification API exposes actions and `desktopEntry`; Hyprland exposes clients through `hyprctl -j`.
  - Acceptance: expanded notification rows expose `Open`; clicking an already-expanded notification attempts to focus a matching Hyprland client by desktop entry, app name, class, or title.
  - Validation: `notification-focus-app --self-test`; send a desktop notification from an open app, open Notifications, expand it, then use `Open`.
- [x] Add a launcher hidden-app smoke test.
  - Sources: Caelestia app info page exposes favorite/hidden launcher settings; local launcher already persists `hiddenAppIds` in Quickshell state.
  - Acceptance: `desktop/tools/qs-menu-smoke launcher-hidden` asks Quickshell to hide one visible desktop entry in memory, proves it disappears, restores the override, and reports pass/fail without editing persisted launcher settings.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/shell.qml`, `bash -n desktop/tools/qs-menu-smoke`, `home -y`, `qbar reload`, `desktop/tools/qs-menu-smoke launcher-hidden`, and `desktop/tools/qs-menu-smoke launcher`.

- [x] Polish calendar popup task/weather presentation.
  - Sources: current `check-todo-panel`, `check-time-panel`, `check-weather`, user preference for Palmela weather and primary-color today marker.
  - Acceptance: time popup shows Taskwarrior ready tasks without broken leading indentation, highlights today in a native QML calendar grid with the configured primary color, and shows Palmela weather with today/tomorrow min-max temperatures.
  - Validation: `check-todo-panel`, `check-time-panel`, `WEATHER_LOCATION="Palmela, Portugal" check-weather panel`, `qmllint`, and `desktop/tools/qs-menu-smoke calendar`.
- [x] Design Pomodoro plus timewarrior integration.
  - Sources: current calendar/time menu, Taskwarrior todo block, possible `timew` tracking state.
  - Current behavior: `docs/desktop/pomodoro-timewarrior.md` defines a future `pomodoroctl` helper boundary, JSON shape, state file, Timewarrior ownership rules, and Quickshell calendar surface.
  - Validation: `test -s docs/desktop/pomodoro-timewarrior.md`.
- [x] Implement `pomodoroctl` before adding QML controls.
  - Acceptance: helper supports `status`, `start`, `pause`, `resume`, `stop`, `break`, and `self-test`; it never stops unrelated Timewarrior intervals.
  - Current behavior: `desktop/bin/pomodoroctl` stores local timer state under Quickshell state, prints redacted JSON for QML, uses Timewarrior only when available and idle, and stops Timewarrior only for helper-owned `pomodoro` intervals.
  - Validation: `pomodoroctl self-test` and `pomodoroctl status`.
- [x] Wire `pomodoroctl` into the calendar popup.
  - Acceptance: calendar popup shows the current Pomodoro mode, remaining time, focus label, and start/pause/resume/stop/break controls backed only by `pomodoroctl`.
  - Current behavior: the calendar popup refreshes `pomodoroctl status`, shows mode, remaining time, label, Timewarrior state, and exposes Start/Pause/Resume/Stop/5m/15m controls.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/shell.qml`, `desktop/tools/qs-menu-smoke calendar`, and `desktop/tools/desktop-doctor`.
- [x] Add a board-rendered personal dashboard shell to Quickshell.
  - Sources: rush `board/docs/personal-dashboards.md`, current Quickshell controls/work-inbox panel patterns, and installed board `render text personal.*` surfaces.
  - Current behavior: `qbar personal-dashboard` opens a right-side Quickshell popup with Today, Money, Health, and Habits tabs rendered only from `board --config ~/.config/board/board.toml render text`; Controls exposes it as Dash.
  - Validation: `board render text personal.today`, `qmllint`, `desktop/tools/qs-menu-smoke personal-dashboard`, and `desktop/tools/desktop-doctor`.
- [x] Add board actions to the personal dashboard once board exposes an action CLI.
  - Current behavior: `board action` is implemented in rush with nested TOML action definitions, no-shell argv execution, `--dry-run`, and `--yes` for confirmed actions. The Personal dashboard exposes a `Fresh` button that calls `board --config ~/.config/board/board.toml action personal.refresh`; QML still renders only `board render text` output and delegates action execution to `board`.
  - Validation: `cargo test -p board`, `cargo build -p board --release`, install to `~/bin/board`, `board action --help`, `board --config desktop/.config/board/board.toml action --dry-run personal.refresh`, `board --config ~/.config/board/board.toml action personal.refresh`, `qmllint ...`, `home -y`, `qbar reload`, `desktop/tools/qs-menu-smoke personal-dashboard`, and `desktop/tools/desktop-doctor`.

- [x] Make the Quickshell clipboard picker a true popup.
  - Sources: current Quickshell clipboard picker, launcher popup behavior, user report that clipboard should be popup-like instead of a normal window.
  - Current behavior: `qbar clipboard` toggles a centered 720x500 floating Quickshell picker, uses the same Hyprland float/center rule shape as launcher/web search, takes focus immediately, and closes through Escape, focus-grab clear, or repeated toggle.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/shell.qml`, `luac -p desktop/.config/hypr/init.lua desktop/.config/hypr/profiles/default.lua desktop/.config/hypr/profiles/omarchy.lua`, `bash -n desktop/tools/qs-menu-smoke desktop/bin/hypr-session desktop/bin/qbar`, `desktop/tools/qs-menu-smoke clipboard-toggle clipboard`, and `desktop/tools/desktop-doctor`.
- [x] Integrate secret-aware clipboard handling with gopass/Wayland.
  - Sources: local `gopass-clip-copy`, `gopass-clip-clear`, `history-secrets`, `passmenu`, local gopass/Wayland clipboard command surface, and the current Quickshell clipboard picker.
  - Constraint: keep decrypted values out of argv, logs, QML state, and normal clipboard history by default.
  - Current behavior: `passmenu` opens a Quickshell password picker again; QML stores only entry names, and selection delegates copy/type work to `passmenu-action`. Copy mode uses `gopass show -c` with tracked `GOPASS_CLIPBOARD_COPY_CMD`/`GOPASS_CLIPBOARD_CLEAR_CMD` defaults. `gopass-clip-copy` is stdin-only and leaves `cliphist` running; `gopass-clip-clear` is temporarily a no-op while debugging Wayland paste regressions. `cliphist-menu watch` mirrors normal text clipboard changes into the primary selection for middle-click paste. GPaste remains disabled because its daemon can take stale Wayland clipboard ownership. Password copies may enter normal clipboard history until secret cleanup is re-enabled.
  - Validation: `passmenu-action --self-test`, fake-backend `passmenu --name`, fake-backend `passmenu --user`, `qmllint desktop/.config/quickshell/marcelof/shell.qml`, `bash -n desktop/bin/passmenu desktop/bin/passmenu-action desktop/bin/gopass-clip-copy desktop/bin/gopass-clip-clear desktop/tools/desktop-doctor desktop/tools/desktop-accept desktop/bin/hypr-session`, `desktop/tools/qs-menu-smoke`, and `desktop/tools/desktop-doctor`.
- [x] Add a redacted work inbox status helper.
  - Sources: Slack Conversations API, GitHub search through `gh api`, Linear notifications GraphQL, and existing cache patterns.
  - Current behavior: `work-inbox-status` prints cached JSON for Slack unread counts, GitHub PR review requests, and Linear notification counts. Missing credentials are quiet unavailable states; tokens and message text never enter stdout or curl argv.
  - Validation: `work-inbox-status --self-test`, `work-inbox-status --no-network`, and `desktop/tools/desktop-doctor`.
- [x] Build a small unread-work Quickshell dashboard from `work-inbox-status`.
  - Current behavior: `qbar work-inbox` opens a right-side Quickshell popup with Slack unread/mentions, GitHub review requests, and Linear notification counts from the helper. Controls also has a Work button.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/shell.qml`, `desktop/tools/qs-menu-smoke work-inbox`, and `desktop/tools/desktop-doctor`.
- [x] Add local calendar agenda integration.
  - Source: existing `khal` local calendar cache; future Google/CalDAV sync stays outside Quickshell.
  - Current behavior: `calendar-agenda-status` renders upcoming local agenda text from `khal list today 7d --notstarted`; the calendar popup shows it in a dedicated Agenda block and refreshes through the helper.
  - Validation: `calendar-agenda-status self-test`, `qmllint`, `desktop/tools/qs-menu-smoke calendar`, and `desktop/tools/desktop-doctor`.
- [x] Add a Google Calendar sync boundary outside Quickshell.
  - Current blocker: no tracked `gcalcli` or `vdirsyncer` setup is present; Quickshell only consumes local khal output.
  - Acceptance: external sync populates the local khal calendar cache without credentials entering QML or shell command argv.
  - Validation: `khal list today 7d --notstarted` shows synced events and `calendar-agenda-status` handles auth/offline states.
  - Current behavior: `calendar-sync-status` records the boundary: this machine is local-khal-only until an external sync tool is installed/configured outside Quickshell. Quickshell and QML still never own calendar credentials.
- [x] Redesign meeting/privacy awareness around DND.
  - Current behavior: the bar uses one DND-aware privacy indicator for mic, camera, screen share/recording, and DND; left click opens Screen details and right click toggles DND. Controls includes a compact privacy state block with refresh/details actions.
  - Constraint: this detects capture state, not a guaranteed Google Meet meeting identity, because Chrome/portal state does not expose enough app-specific call metadata locally.
  - Validation: `desktop-privacy-status status`, `desktop-privacy-status self-test`, `qmllint desktop/.config/quickshell/marcelof/shell.qml`, `desktop/tools/qs-menu-smoke controls screen`, and `desktop/tools/desktop-doctor`.
- [x] Add app-open deep links for notification producers where generic focusing is not enough.
  - Sources: notification `desktopEntry` metadata, app-specific desktop files, Hyprland client matching.
  - Current behavior: notification `Open` first focuses a matching Hyprland window; when none exists it launches Slack, Chrome, Brave, Linear inbox, Discord, Obsidian, 1Password, or falls back to `gtk-launch` for known desktop entries.
  - Validation: `notification-focus-app --self-test`, one notification from each supported app focuses the right window or opens the wrapper.


### Execution Plan For Open Dashboard Tasks

Do these in this order; each task should leave one small validation command behind. Keep all secrets in helpers, never in QML state.

1. Launcher hidden-app proof. Done.
   - Task: `desktop/tools/qs-menu-smoke launcher-hidden` calls Quickshell IPC to hide one visible desktop entry with an in-memory override, verifies it is absent from launcher results, then clears the override.
   - Depends on: existing `hiddenAppIds` filter path and launcher rebuild.
   - Validation: `desktop/tools/qs-menu-smoke launcher-hidden` plus normal `desktop/tools/qs-menu-smoke launcher`.
   - Result: passed with desktop entry `1password`; persisted `hiddenAppIds` is not edited.
2. Notification open/focus hardening. Done.
   - Task: `notification-focus-app --self-test` now exercises fake `hyprctl clients -j` input and verifies Chrome, Slack, and WezTerm desktop-entry/app-name matching.
   - Depends on: current `notification-focus-app` helper.
   - Validation: `notification-focus-app --self-test`, `desktop/tools/desktop-notification-smoke actions`, manual Slack/Chrome notification focus.
   - Result: generic matching now normalizes reverse-DNS desktop IDs; no unsupported app-specific behavior found in the local test fixture.
3. Clipboard popup parity. Done.
   - Task: make `qbar clipboard` use the same popup/focus-grab behavior as the launcher instead of presenting as a normal side/tiled window.
   - Depends on: current Quickshell clipboard picker and `cliphist-menu` data path.
   - Validation: `desktop/tools/qs-menu-smoke clipboard-toggle clipboard` and `desktop/tools/desktop-doctor`.
   - Result: clipboard now toggles through Quickshell IPC, is centered/floating by Hyprland title rule, and exposes a smoke-test visible state.
4. Secret-safe clipboard and gopass integration. Done.
   - Task: audit active password copy paths, keep decrypted values out of QML, and make Quickshell clipboard hide likely secret rows from normal `cliphist`.
   - Depends on: `passmenu`, `passmenu-action`, `gopass-clip-copy`, `gopass-clip-clear`, and the local GPaste/gopass command surface.
   - Validation: `passmenu-action --self-test`, fake-backend `passmenu --name`, fake-backend `passmenu --user`, `desktop/tools/qs-menu-smoke`, and `desktop/tools/desktop-doctor`.
   - Result: `passmenu` has a Quickshell popup target again; copy/type actions run in a helper, not QML; gopass copy uses repo-managed clipboard hook defaults; local GPaste password-entry mode and copyq secret copy are intentionally not used because they require password argv.
5. Work inbox helper first, dashboard second. Helper done.
   - Task: `work-inbox-status` returns redacted cached JSON counts for Slack unread, GitHub PR review requests, and Linear notifications.
   - Sources: Slack Conversations API, GitHub search through `gh api`, Linear notifications GraphQL, and local cache patterns.
   - Validation: `work-inbox-status --self-test`, `work-inbox-status --no-network`, and `desktop/tools/desktop-doctor`.
   - Result: `qbar work-inbox` now opens a Quickshell popup fed by this helper; the Controls menu exposes it as Work. Missing credentials render quiet unavailable rows.
6. Meeting and DND awareness. Done.
   - Task: collapse mic/camera/screenshare into one DND-aware meeting indicator and move details into controls/privacy popup.
   - Result: capture indicators and DND are shown as one bar item; Controls and Screen show the detailed helper output. This intentionally reports capture state only, not confirmed Meet identity.
   - Validation: `desktop-privacy-status self-test`, `qmllint`, `desktop/tools/qs-menu-smoke controls screen`, and `desktop/tools/desktop-doctor`.
7. Pomodoro plus timewarrior design. Done.
   - Task: write the minimal design for a time-menu Pomodoro timer with optional Taskwarrior/timewarrior links before implementation.
   - Result: `docs/desktop/pomodoro-timewarrior.md` documents commands, state files, Timewarrior ownership, JSON output, and no-secret QML boundary.
   - Result: `desktop/bin/pomodoroctl` implements status/start/pause/resume/stop/break/self-test and is covered by `desktop/tools/desktop-doctor`.
   - Result: the calendar popup renders `pomodoroctl` status and calls the helper for all timer actions.
   - Next: calendar agenda integration or visual consistency pass.
8. Personal dashboard shell. Done.
   - Task: add a Quickshell popup that renders board-owned Today, Money, Health, and Habits surfaces without collecting private data in QML.
   - Result: `qbar personal-dashboard` toggles the popup, Controls exposes Dash, and smoke tests capture the panel.
   - Blocked next: board action buttons wait for an installed `board action` subcommand.
9. Calendar agenda integration. Done locally.
   - Task: add a helper for cached calendar summaries, then feed the existing calendar popup.
   - Result: `calendar-agenda-status` renders upcoming events from the local khal cache, and the calendar popup has a dedicated Agenda section.
   - Blocked next: Google account sync credentials/tooling are intentionally outside Quickshell and not configured here.
10. Visual consistency pass. Done first pass.
   - Task: normalize panel spacing, action row size, and empty states across launcher, clipboard, network, notifications, calendar, media, and controls using current local components.
   - Sources: Noctalia compact control-center layout, Caelestia settings/actions, cxOrz quick settings, end-4 smoke/utility polish.
   - Result: shared action buttons now keep a stable height and elide long labels instead of overflowing; the media popup width matches the other right-side dashboards; Controls menu rows no longer cram six actions into one row.
   - Follow-up: right-side Quickshell menus now use a shared 640px width, crowded panels use 560px height, compact panels use 360px height, calendar keeps a taller 720px surface, Work Inbox uses 420px, Personal uses 460px, Media uses the same medium height as Work Inbox, and default action buttons are wider so labels do not collapse to two letters, and menu smoke crops now match the wider right-side panels.
   - Follow-up: current screenshot pass trims the Session menu to a compact width, makes Exit Hyprland secondary, gives Controls enough height for its bottom rows, expands Controls menu buttons to readable cells, makes Privacy action buttons icon-only, and tones down Media stream mute buttons.
   - Validation: `qmllint desktop/.config/quickshell/marcelof/shell.qml`, `desktop/tools/qs-menu-smoke controls media notifications clipboard network calendar`, and `desktop/tools/desktop-doctor`.

## Automation helpers

- `desktop/tools/desktop-accept` runs static script checks, validates `quickshell-repeat-audit`, checks all Hyprland profiles including `profiles/common.lua`, runs QML lint and the repeat audit, applies dotfiles, reloads Quickshell, runs Hyprland smoke, runs menu smoke, and finishes with `desktop/tools/desktop-doctor`.
- `desktop-startup-report` prints Hyprland startup commands, autostart desktop files, running user services, and the current Quickshell instance.

## Notes

- `default` is the i3-compatible profile. There is intentionally no separate `i3` profile.
- Quickshell owns bar, launcher, tray, wallpaper, controls, calendar, notification history, network panel, lock IPC, and exit confirmation; controls also acts as the all-menus hub. `board` is the tracked local status renderer for Quickshell and tmux surfaces.
- Both profiles use the local lightweight Quickshell shell. The `omarchy` profile does not install or call upstream runtime binaries.
- Adapted reference patterns already landed locally: Caelestia-like session actions behind local commands, end-4-like `Super+/` keybinding help and cliphist watcher refresh, Noctalia-like compact popup/control surfaces, and cxOrz-like cliphist as backend plumbing.
- Rust system-metrics helper is intentionally not active work. The future note lives in `wiki/main/resources/dev/desktop.md`; build it only if measured Quickshell status polling cost becomes a real problem.

## Open polish and simplification tasks

Review snapshot: 2026-08-03. Sources: local reference clones for Caelestia, end-4, Noctalia, Omarchy, cxOrz, surface-dots, ilyamiro/nixos-configuration, Aylur AGS, ML4W, and JaKooLit. Priority favors code repetition, simple config, and keeping this shell maintainable over adding new runtime layers.

### Config and repetition priority backlog

- [x] P0: Replace repeated Quickshell literals with a tiny theme token map.
  - Sources: cxOrz `Theme.qml`, surface-dots `theme.js`, Caelestia token/state split.
  - Acceptance: repeated font family, font sizes, radii, spacing, panel widths/heights, and Catppuccin colors are read from `ShellTheme.qml`/`ShellConfig.qml`; local overrides remain only where a value is genuinely different.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/shell.qml desktop/.config/quickshell/marcelof/Shell*.qml desktop/.config/quickshell/marcelof/StatusText.qml`, `rg -n "spacing: (12|10|8|7|6|5|4|2)|implicitHeight: (36|52)|actionRow\.implicitWidth  18|radius: isGroup \? 0 : 5|anchors\.margins: 8" desktop/.config/quickshell/marcelof/Shell*.qml`.
  - Current behavior: `ShellTheme.qml` now owns common spacing, padding, action sizing, tooltip padding, row height, font, radius, and color tokens; extracted `Shell*.qml` components use the tokens for repeated spacing/action literals.

- [x] P0: Split `shell.qml` into a small root plus imported components.
  - Sources: Caelestia and Noctalia component boundaries; end-4 menu/component split.
  - Acceptance: `shell.qml` owns app wiring only; menu bodies, services, popups, launchers, and dashboards live in focused `Shell*.qml` files; no new abstraction unless it deletes repeated code.
  - Validation: `wc -l desktop/.config/quickshell/marcelof/shell.qml desktop/.config/quickshell/marcelof/ShellBar.qml`, `qmllint desktop/.config/quickshell/marcelof/shell.qml desktop/.config/quickshell/marcelof/Shell*.qml desktop/.config/quickshell/marcelof/StatusText.qml`.
  - Current behavior: the top bar moved into `ShellBar.qml`; `shell.qml` dropped from 2362 to 2097 lines and keeps the root state, service processes, IPC handlers, wallpaper, and popup wiring.

- [x] P0: Centralize menu popup geometry and open/close behavior.
  - Sources: AGS click-away launcher behavior, Noctalia compact popups, local launcher floating rules.
  - Acceptance: launcher, clipboard, web search, calendar, controls, media, notifications, wallpaper, screen, network, power, settings, and work inbox use one menu registry for width, height, anchor, focus, Escape, and double-toggle close.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/shell.qml desktop/.config/quickshell/marcelof/Shell*.qml desktop/.config/quickshell/marcelof/StatusText.qml`, `rg -n "anchor\.rect\.x: Math\.max\(8, anchorWindow\.width - implicitWidth|anchor\.rect\.y: anchorWindow\.height  6|visible: panelOpen|implicitWidth: panelWidth|implicitHeight: panelHeight" desktop/.config/quickshell/marcelof/Shell*.qml`, `desktop/tools/qs-menu-smoke controls launcher notifications calendar media clipboard`.
  - Current behavior: right-side menus use `ShellPopup`; launcher, clipboard, passmenu, and web search use `ShellFloatingPopup`; special tooltip/toast/OSD surfaces keep their custom placement.

- [x] P0: Centralize QML command actions into `ShellConfig`.
  - Sources: surface-dots config separation, Caelestia action helpers.
  - Acceptance: QML components call named helpers for audio, wallpaper, network, screenshots, browser, clipboard, power, screen recording, notifications, and settings; direct command arrays appear only in the config/action module or intentional one-off tests.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/shell.qml desktop/.config/quickshell/marcelof/Shell*.qml desktop/.config/quickshell/marcelof/StatusText.qml`, `rg -n "command: \[|Quickshell\.execDetached\(\[|\[shellConfig\.bin|\[[a-zA-Z0-9_.]+Config\.bin" desktop/.config/quickshell/marcelof/*.qml`.
  - Current behavior: command arrays for bar status, weather, brightness, clipboard, passmenu, launcher MRU, screenshots, power, audio, privacy, work inbox, Pomodoro, and helpers are defined through `ShellConfig.qml`; `shell.qml` and panel components call named helpers.

- [x] P1: Build a simple menu/action registry for Controls.
  - Sources: Noctalia all-in-one controls, cxOrz quick settings.
  - Acceptance: Controls buttons are data rows from one local list, so adding/removing Wallpaper, Screen, Network, Work, Dash, Power, Settings, and Keybindings does not duplicate icon/label/action/button code.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/shell.qml desktop/.config/quickshell/marcelof/Shell*.qml desktop/.config/quickshell/marcelof/StatusText.qml`, `desktop/tools/qs-menu-smoke controls`.
  - Current behavior: Controls menu buttons now come from `menuActionRows` plus `triggerMenuAction()` in `ShellControlPanel.qml`; session commands used by Controls/Power are also routed through `ShellConfig.qml`.

- [x] P1: Normalize all menu empty/loading/error states.
  - Sources: Caelestia settings and launcher states, end-4 utility surfaces.
  - Acceptance: every popup has one shared style for empty, loading, warning, and error rows; long text wraps or elides inside the panel.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/shell.qml desktop/.config/quickshell/marcelof/Shell*.qml desktop/.config/quickshell/marcelof/StatusText.qml`, `desktop/tools/qs-menu-smoke clipboard notifications tray`.
  - Current behavior: `ShellStateBox.qml` owns the shared empty/loading state frame and text style for clipboard, passmenu, notifications, and tray manager. Contextual inline status rows remain inline for media, network, privacy, and calendar data.

- [x] P1: Dry Hyprland keybinding/profile definitions.
  - Sources: Omarchy keybinding discoverability, local generated `hypr-keys`.
  - Acceptance: default and omarchy profiles share common binding lists where behavior matches; generated help and actual binds still come from the same data.
  - Validation: `luac -p desktop/.config/hypr/init.lua desktop/.config/hypr/profiles/common.lua desktop/.config/hypr/profiles/default.lua desktop/.config/hypr/profiles/omarchy.lua`, `Hyprland --config desktop/.config/hypr/init.lua --verify-config`, `HYPR_PROFILE=omarchy Hyprland --config desktop/.config/hypr/init.lua --verify-config`, `HYPR_PROFILE=default hypr-keys`, `HYPR_PROFILE=omarchy hypr-keys`.
  - Current behavior: repeated direction and workspace-number binding loops, terminal shortcut helpers, shared action names, Ghostty class, monitor mode, Catppuccin border/group colors, and groupbar config now live in `profiles/common.lua`; `default.lua` and `omarchy.lua` keep only profile-specific binding choices.

- [x] P1: Dry Hyprland window rules and popup rules.
  - Sources: Omarchy floating utilities, local floating menu experiments.
  - Acceptance: launcher/menu/tmux popup/window floating rules are generated through one small helper/table instead of repeated `windowrulev2` blocks.
  - Validation: `luac -p desktop/.config/hypr/init.lua desktop/.config/hypr/profiles/common.lua desktop/.config/hypr/profiles/default.lua desktop/.config/hypr/profiles/omarchy.lua`, `Hyprland --config desktop/.config/hypr/init.lua --verify-config`, `HYPR_PROFILE=omarchy Hyprland --config desktop/.config/hypr/init.lua --verify-config`.
  - Current behavior: `profiles/common.lua` owns default monitor declarations, common Quickshell/floating popup rules, and dropdown tmux rules; each profile keeps only profile-specific window rules.

- [x] P1: Move board status config into data files and keep Rust code generic.
  - Sources: current board native/script check split, user request to separate config from code.
  - Acceptance: check names, labels, thresholds, script paths, and enabled/disabled flags live in board config; Rust keeps only native check implementations and render plumbing.
  - Validation: `cargo test -p board`, source and live `board --config ... doctor`, source and live `board --config ... checks`, live `board --config ... render text quickshell-bar`, `home -y`.
  - Current behavior: board defaults are TOML-backed; labels, thresholds, enabled flags, script commands, weather location, time-panel timezones, and surface membership live in config. `StatusItem.name` stays the stable cache/metric key; human output uses config `label`.

- [x] P2: Add a repetition audit helper for Quickshell and Hyprland config.
  - Sources: local DRY work, no new dependency.
  - Acceptance: one script reports top repeated QML strings/numbers/colors and repeated Hyprland command fragments, excluding obvious imports and generated text.
  - Validation: `ruby -c desktop/tools/quickshell-repeat-audit`, `desktop/tools/quickshell-repeat-audit | sed -n '1,90p'`.
  - Current behavior: `desktop/tools/quickshell-repeat-audit` uses a tiny stdlib Ruby scanner to report repeated QML string literals, numeric UI literals, and Hyprland Lua string literals for the next DRY passes.

- [x] P0: Remove the remaining repeated search-box and list-row QML.
  - Sources: current launcher, clipboard, passmenu, and web-search panels; Caelestia/end-4 reusable input and list-row components.
  - Acceptance: one tiny search input component and one tiny selectable row pattern cover launcher, clipboard, passmenu, and web search without changing behavior or adding a widget framework.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/shell.qml desktop/.config/quickshell/marcelof/Shell*.qml desktop/.config/quickshell/marcelof/StatusText.qml`, `desktop/tools/quickshell-repeat-audit`, `bash -n desktop/bin/qbar desktop/tools/qs-menu-smoke desktop/tools/quickshell-repeat-audit`, `home -y`, `desktop/bin/qbar reload`, `desktop/tools/qs-menu-smoke launcher clipboard websearch launcher-hidden clipboard-toggle`, `desktop/bin/qbar status`.
  - Current behavior: Omarchy `Ui/TextField.qml` now owns the shared search input styling for launcher, clipboard, passmenu, web search, and keybindings; each panel uses the native Qt text and key signals directly. The replaced `ShellSearchBox.qml` is preserved under `archive/obsolete/desktop/`. `ShellSelectableRow.qml` still owns the simple selected-row frame and click/hover signals for clipboard and passmenu.

- [x] P0: Move remaining bar and menu size literals into existing theme/config tokens.
  - Sources: `desktop/tools/quickshell-repeat-audit` repeated `height: 22`, `height: 42`, `width: 22`, margin, and row-height findings.
  - Acceptance: shared sizes like bar icon box, tray icon, search height, list row height, divider height, and standard margins live in `ShellTheme.qml` or `ShellConfig.qml`; one-off geometry remains local.
  - Validation: `desktop/tools/quickshell-repeat-audit`, `qmllint desktop/.config/quickshell/marcelof/shell.qml desktop/.config/quickshell/marcelof/Shell*.qml desktop/.config/quickshell/marcelof/StatusText.qml`, `bash -n desktop/bin/qbar desktop/tools/qs-menu-smoke desktop/tools/quickshell-repeat-audit`, `home -y`, `desktop/bin/qbar reload`, `desktop/tools/qs-menu-smoke launcher clipboard websearch notifications calendar network work-inbox`.
  - Current behavior: `ShellTheme.qml` owns shared bar height, bar icon/tray sizes, workspace indicator size, panel/input margins, search/list row heights, launcher row height, chip height, and divider height; the audit now reports only divider-style numeric literals (`width: 1`, `height: 1`).

- [x] P0: Keep `shell.qml` as wiring by moving repeated state/process blocks into focused components.
  - Sources: Caelestia/Noctalia service-state split and current extracted `Shell*.qml` components.
  - Acceptance: root keeps global wiring and IPC only; launcher, notifications, media/audio, privacy, calendar, wallpaper, and work-inbox polling/state stay next to their panels or in one small service component when shared.
  - Validation: `wc -l desktop/.config/quickshell/marcelof/shell.qml`, `qmllint desktop/.config/quickshell/marcelof/shell.qml desktop/.config/quickshell/marcelof/Shell*.qml desktop/.config/quickshell/marcelof/StatusText.qml`, `desktop/tools/qs-menu-smoke launcher controls media notifications calendar wallpaper work-inbox`.
  - Current behavior: calendar/time/Pomodoro polling moved to `ShellCalendarService.qml`; Work Inbox and Personal Dashboard refreshes moved to `ShellDashboardService.qml`; wallpaper current/list polling moved to `ShellWallpaperService.qml`; screen recording and portal polling moved to `ShellScreenService.qml`; launcher MRU, clipboard, passmenu, and keybinding refreshes moved to `ShellMenuDataService.qml`; privacy, power, network, brightness, external brightness, keyboard brightness, fan, and idle-inhibit refreshes moved to `ShellSystemStatusService.qml`; audio status, audio streams, media now-playing, and audio refresh timers moved to `ShellAudioService.qml`. Root `shell.qml` has no direct `Process` blocks left.

- [x] P0: Split config data from command/action code without adding a settings framework.
  - Sources: surface-dots config separation, Caelestia action helpers, current `ShellConfig.qml`.
  - Acceptance: static user values, command paths, menu geometry, and action functions are easy to scan; `ShellConfig.qml` does not become a mixed dump of constants plus behavior.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/ShellConfig.qml desktop/.config/quickshell/marcelof/ShellConfigData.qml desktop/.config/quickshell/marcelof/Shell*.qml desktop/.config/quickshell/marcelof/shell.qml desktop/.config/quickshell/marcelof/StatusText.qml`, `rg -n "readonly property .*:|function .*\(" desktop/.config/quickshell/marcelof/ShellConfig.qml desktop/.config/quickshell/marcelof/ShellConfigData.qml`, `bash -n desktop/bin/qbar desktop/tools/qs-menu-smoke desktop/tools/quickshell-repeat-audit`, `home -y`, `desktop/bin/qbar reload`, `desktop/tools/qs-menu-smoke launcher clipboard websearch controls media notifications calendar wallpaper screen network power personal-dashboard`, `desktop/bin/qbar status`.
  - Current behavior: static paths, menu geometry, dashboard surface names, and calendar weekday data live in `ShellConfigData.qml`; `ShellConfig.qml` keeps command/action helpers and forwards the existing property names so call sites stay stable.

- [x] P0: Create one small section/card primitive for repeated dashboard blocks.
  - Sources: current Controls, Media, Calendar, Network, Work Inbox, and Personal Dashboard repeated `Rectangle + RowLayout + Text` blocks; Noctalia/end-4 quick-setting cards.
  - Acceptance: dashboard sections share padding, radius, border, heading/body text, and action-row layout through one existing-style primitive; no nested decorative cards.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/shell.qml desktop/.config/quickshell/marcelof/Shell*.qml desktop/.config/quickshell/marcelof/StatusText.qml`, `bash -n desktop/bin/qbar desktop/tools/qs-menu-smoke desktop/tools/quickshell-repeat-audit`, `home -y`, `desktop/bin/qbar reload`, `desktop/tools/qs-menu-smoke controls media calendar network work-inbox personal-dashboard`, `desktop/bin/qbar status`.
  - Current behavior: `ShellSection.qml` owns the shared dashboard section frame, padding, radius, optional border, fill-height behavior, and inner layout spacing. Controls privacy, Media stream cards, Calendar Pomodoro, Network details, and Work Inbox source rows use it; Personal Dashboard was smoke-tested but left unframed to avoid adding a decorative nested card.

- [x] P1: Make the menu registry the single source for menu names, geometry, shortcuts, and smoke targets.
  - Sources: current `ShellPopup`/`ShellFloatingPopup`, Controls all-menus hub, generated keybindings, and `desktop/tools/qs-menu-smoke`.
  - Acceptance: menu id, label, shortcut, size, placement, and smoke command are not repeated separately in QML, Hyprland docs, and shell helpers unless the target truly differs.
  - Validation: `bash -n desktop/lib/lib_qs_menus.sh desktop/bin/qbar desktop/tools/qs-menu-smoke`, `desktop/bin/qbar list-menus`, `desktop/tools/qs-menu-smoke --list`, `diff -u <(desktop/bin/qbar list-menus) <(desktop/tools/qs-menu-smoke --list)`, `qmllint desktop/.config/quickshell/marcelof/shell.qml desktop/.config/quickshell/marcelof/Shell*.qml desktop/.config/quickshell/marcelof/StatusText.qml`, `desktop/tools/qs-menu-smoke controls launcher clipboard calendar media notifications wallpaper screen network power settings`.
  - Current behavior: `desktop/lib/lib_qs_menus.sh` is the shared shell source for smoke menu names, menu labels used by generated key help, special open commands, and screenshot crop geometry; `qbar list-menus` and `desktop/tools/qs-menu-smoke --list` return the same list, and `diff -u <(desktop/bin/qbar list-menus) <(desktop/tools/qs-menu-smoke --list)` passed. QML menu sizes live in `ShellConfigData.qml` under `menuSizes`, and popup instances ask `shellConfig.menuSize(id, dense)` through `root.menuWidthFor`/`root.menuHeightFor`. Controls menu button icons, labels, tooltips, and actions live in `ShellConfigData.qml` under `controlMenuRows`; Settings menu shortcut rows live there under `settingsMenuRows`; the panels only render and dispatch them. `hypr-keys default` and `hypr-keys omarchy` now resolve Quickshell menu labels through `lib_qs_menus.sh` when the binding calls `qbar <menu>` or `qs("<menu>")`.

- [x] P2: Add docs for the intended component/config layout.
  - Sources: this migration queue and reference repo organization.
  - Acceptance: `docs/desktop/quickshell-architecture.md` explains root shell, components, theme/config/state, helpers, board boundary, and what not to add.
  - Validation: doc exists and links from this task file.
  - Current behavior: `docs/desktop/quickshell-architecture.md` exists and documents root/component/service/config/theme/helper ownership, board and archive boundaries, the reference import rule, and what not to abstract. Later architecture task also links this file.

- [x] P0: Add a tiny `ShellText.qml` primitive for repeated Quickshell text styling.
  - Sources: Caelestia `StyledText`, cxOrz `Theme.qml`, surface-dots `theme.js`.
  - Acceptance: common label/body/muted/title/icon text styles no longer repeat font family, style, size, and color literals across menus.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/shell.qml desktop/.config/quickshell/marcelof/Shell*.qml desktop/.config/quickshell/marcelof/StatusText.qml`.
  - Current behavior: `ShellText.qml` owns common text roles; shared buttons, tooltips, status text, and common fixed one-line menu labels now use it. Dynamic status text can still override color or size locally.

- [x] P0: Add `ShellScrollPanel.qml` or simplify scroll menus into the existing frame/panel primitives.
  - Sources: Noctalia and end-4 control/menu surfaces; Caelestia component layering.
  - Acceptance: scroll-heavy menus share the same panel frame, margins, and scrollbar policy without hand-copying the frame in every file.
  - Validation: `qmllint`, `desktop/tools/qs-menu-smoke controls media notifications launcher clipboard passmenu`.
  - Current behavior: `ShellScrollPanel.qml` wraps the shared `ShellFrame` plus `ScrollView`; the pure scroll dashboards, Controls and Media, use it. Mixed header-plus-scroll panels keep local inner scroll areas.

- [x] P0: Move Quickshell command paths and user-tunable values into one simple config object.
  - Sources: surface-dots `config.js`, Caelestia config/state split.
  - Acceptance: browser, terminal, wallpaper, screenshot, audio, network, and state-file paths are defined in one local QML config/helper, not repeated in menu components.
  - Validation: `qmllint`, `rg -n "hypr-clean-env|audioctl|screenshot-wayland|wallpaper-wayland|network-status" desktop/.config/quickshell/marcelof/*.qml`.
  - Current behavior: `ShellConfig.qml` owns command helpers for clean-env apps, Quickshell IPC, screenshots, browser, audioctl, network-status, wallpaper, network settings, and volume mixer. The command-string grep now resolves to `ShellConfig.qml` only.

- [x] P1: Polish launcher states and ranking.
  - Sources: Caelestia launcher modes, Omarchy app menu behavior, AGS launcher close/selection behavior.
  - Acceptance: launcher keeps MRU/MFU/favorite behavior, has a clean empty state, stable keyboard focus, and consistent row actions for favorite/hide/open.
  - Validation: `desktop/tools/qs-menu-smoke launcher settings`, `qs ipc ... call launcher state` after `qbar launcher`, manual `Win+D`, type query, click or Enter launch, hide app, favorite app, clear hidden apps, reload.
  - Current behavior: `ShellLauncherService.qml` owns MRU/MFU scoring, favorites, hidden apps, command rows, and app activation. Launcher IPC opens with `panelOpen`, so click and Enter pass the same state guard as keyboard toggles. Click and Enter launch the visible `DesktopEntries` object through Quickshell native `execute()` first, with command/`gtk-launch` fallback; custom command rows keep direct command execution. The launcher shows a shared empty state, and Settings exposes `Clear Hidden Apps` so hidden entries are recoverable.

- [x] P1: Improve notification center grouping and details.
  - Sources: Noctalia notification center, end-4 notification surfaces, Omarchy notification service/card split.
  - Acceptance: grouped notifications preserve actions, expand/collapse cleanly, long summaries/bodies never overflow, and clicking a notification focuses the source app when possible.
  - Validation: `desktop/tools/desktop-notification-smoke actions`, `desktop/tools/qs-menu-smoke notifications`.
  - Current behavior: later notification task documents grouped history, clean expansion, clipped action rows, and source-app focus via `notification-focus-app`; validation passed again in `desktop/tools/qs-menu-smoke notifications controls media calendar` at `/home/marcelof/.local/state/quickshell/menu-smoke/20260803-201008`.

- [x] P1: Normalize the control center into one coherent dashboard.
  - Sources: Noctalia all-in-one controls, cxOrz ChromeOS-style quick settings, end-4 quick settings.
  - Acceptance: audio, brightness, network, Bluetooth, power, privacy, DND, screenshot, and session controls share row heights, spacing, hover states, and no dead right-side whitespace.
  - Validation: `desktop/tools/qs-menu-smoke controls media screen network power`.
  - Current behavior: later Controls task documents the data-driven hub and stable secondary-menu buttons; validation passed again in `desktop/tools/qs-menu-smoke notifications controls media calendar` at `/home/marcelof/.local/state/quickshell/menu-smoke/20260803-201008`.

- [x] P1: Rework media into a clean player card.
  - Sources: Caelestia MPRIS cards, Noctalia media widgets, AGS MPRIS service examples.
  - Acceptance: media menu shows player/source, title/artist, play state, local noise/music controls, stream volume rows, and pause-all without visual crowding.
  - Validation: `audioctl self-test`, `desktop/tools/qs-menu-smoke media`, manual local music/noise restore plus a normal MPRIS player.
  - Current behavior: later media task documents the compact player/stream layout, saved noise/music state, play-pause/stop/force-stop controls, and per-stream volume/mute rows; validation passed again in `desktop/tools/qs-menu-smoke notifications controls media calendar` at `/home/marcelof/.local/state/quickshell/menu-smoke/20260803-201008`.

- [x] P1: Re-polish the time/calendar dashboard.
  - Sources: Caelestia date/time dashboard and weather widgets; Noctalia calendar direction.
  - Acceptance: Lisbon time, extra timezones, timestamp formats, today highlight, weather min/max for Palmela, todo/pomodoro/timewarrior sections, and future calendar integration placeholders are visually balanced.
  - Validation: `desktop/tools/qs-menu-smoke calendar`, manual clock/timezone sanity check.
  - Current behavior: later calendar task documents Lisbon/timezones/timestamps, Palmela weather, todo, Pomodoro/Timewarrior, and today highlighting; validation passed again in `desktop/tools/qs-menu-smoke notifications controls media calendar` at `/home/marcelof/.local/state/quickshell/menu-smoke/20260803-201008`.

- [x] P2: Add a small shell settings/theme editor only for existing state.
  - Sources: Caelestia settings surface, Noctalia config boundary.
  - Acceptance: primary color, density, weather location, DND, tray menu mode, and bar visibility are editable through one menu without introducing a theme engine.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/ShellSettingsPanel.qml desktop/.config/quickshell/marcelof/ShellSettings.qml desktop/.config/quickshell/marcelof/ShellConfig.qml desktop/.config/quickshell/marcelof/ShellConfigData.qml desktop/.config/quickshell/marcelof/ShellLauncherService.qml desktop/.config/quickshell/marcelof/shell.qml`, `home -y`, `/home/marcelof/bin/qbar reload`, `desktop/tools/qs-menu-smoke launcher settings controls launcher-hidden`.
  - Current behavior: Settings edits DND, native tray menus, bar visibility, density, weather location, launcher hidden apps, and the existing persisted primary color through a small swatch row. Final smoke artifact: `/home/marcelof/.local/state/quickshell/menu-smoke/20260803-202026`.

- [x] P2: Add a cheap Quickshell runtime cleanup helper.
  - Sources: Omarchy-style doctor/maintenance direction; local finding that `qs list --all` can leave dead runtime IDs.
  - Acceptance: `qbar` can prune stale `/run/user/$UID/quickshell/by-path/*` dead instance entries without touching the live process.
  - Validation: `bash -n desktop/bin/qbar desktop/lib/lib_qs_menus.sh desktop/tools/qs-menu-smoke desktop/bin/hypr-keys`, `desktop/bin/qbar runtime-prune`, `desktop/bin/qbar status`, `find /run/user/1001/quickshell/by-path -maxdepth 1 -mindepth 1 -printf ...`, `home -y`.
  - Current behavior: `qbar runtime-prune` is dry-run by default and only considers broken symlinks under `${XDG_RUNTIME_DIR:-/run/user/$UID}/quickshell/by-path`; `--force` uses `unlink` on those broken symlinks only, never `rm -rf` and never `by-id` directories. Current validation reported `no stale quickshell by-path entries`, one live Quickshell process, and one live `by-path` symlink pointing at the active shell id.

- [x] P2: Make menu screenshots a reliable visual regression workflow.
  - Sources: end-4 visual polish practice, local `desktop/tools/qs-menu-smoke`.
  - Acceptance: `desktop/tools/qs-menu-smoke` captures all main menus, stores readable PNGs, and fails when a menu renders as blank, side-window-only, or obviously clipped.
  - Validation: `desktop/tools/qs-menu-smoke all`, inspect latest screenshot folder.
  - Current behavior: `desktop/tools/qs-menu-smoke all` captures every registered menu, writes per-menu PNG/crop images plus a contact sheet and summary TSV, waits for launcher `panelOpen` through IPC before screenshotting, and `desktop/tools/desktop-doctor` validates the latest full smoke artifact.


- [x] P0: Burn down the top repeated Quickshell literals before adding features.
  - Sources: local `desktop/tools/quickshell-repeat-audit`, Caelestia/cxOrz theme-token style, surface-dots config split.
  - Acceptance: each pass removes or explains the top repeated color, font, spacing, size, and command literals; intentional repeats live in `ShellTheme.qml`, `ShellConfigData.qml`, or one focused primitive.
  - Validation: `desktop/tools/quickshell-repeat-audit`, `qmllint desktop/.config/quickshell/marcelof/shell.qml desktop/.config/quickshell/marcelof/Shell*.qml desktop/.config/quickshell/marcelof/StatusText.qml`.
  - Current behavior: `ShellTheme.qml` now owns the transparent color token, all direct QML `"transparent"` uses outside the theme are gone, menu sizes, menu IDs, network labels/keywords, shared labels/actions/states, default web search provider, web search site data, and the repeated CLI `status` action live in `ShellConfigData.qml`; `desktop/tools/quickshell-repeat-audit` ignores intentional `ShellText` role assignments plus config-data literals so the report focuses on real duplication.

- [x] P0: Keep config in data files and behavior in helpers.
  - Sources: surface-dots data/config separation, Caelestia services/utils split, current `ShellConfig.qml`/`ShellConfigData.qml`.
  - Acceptance: user-tunable values, menu geometry, commands, board surfaces, weather location, and theme tokens are declarative; QML panel files call helpers and do not embed shell command arrays.
  - Validation: `rg -n "command: \[|Quickshell\.execDetached\(\[|readonly property .*: .*audioctl|readonly property .*: .*wallpaper" desktop/.config/quickshell/marcelof/*.qml` returns only approved config/helper files.
  - Current behavior: stream mute/volume commands, brightness wheel commands, repeated status commands, network matching helpers, and session power commands route through `ShellConfig.qml`; Power menu session rows now live in `ShellConfigData.qml` as `sessionActionRows`/`exitSessionAction`; menu IDs, shared labels/actions/states, network labels/keywords, and default web-search provider/site data also live in `ShellConfigData.qml`; the config-boundary grep returns no panel/root direct command-array matches.

- [x] P1: Add a tray drawer and context menu that behaves like a normal desktop tray.
  - Sources: Noctalia tray drawer/context menu, Caelestia tray controls, local tray manage panel.
  - Acceptance: tray entries expose app name, status, pin/hide, activate, and context actions where Quickshell provides them; hidden entries remain recoverable in the shell settings/control menu.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/ShellTrayManagePanel.qml desktop/.config/quickshell/marcelof/ShellTrayButton.qml desktop/.config/quickshell/marcelof/ShellBar.qml desktop/.config/quickshell/marcelof/shell.qml`, `home -y`, `/home/marcelof/bin/qbar reload`, `desktop/tools/qs-menu-smoke controls tray`, `desktop/tools/qs-menu-smoke all`, `desktop/tools/desktop-doctor`.
  - Current behavior: the bar tray drawer exposes pinned and unpinned visible tray items, middle-click pinning, direct/network actions, native menu display when enabled, activation, and scroll forwarding. The Tray manager now shows every tray item including hidden ones, displays pinned/drawer/hidden plus menu status, and provides Activate, Menu/action, Pin, and Hide buttons so hidden entries remain recoverable.

- [x] P1: Normalize the existing volume/brightness OSD surfaces.
  - Sources: Caelestia OSD, end-4/noctalia quick feedback surfaces, existing local OSD behavior.
  - Acceptance: hardware volume, mute, mic mute, and brightness overlays reuse the same small surface, theme tokens, timeout, and icon sizing without opening the full controls menu.
  - Validation: `bash -n desktop/tools/qs-menu-smoke desktop/lib/lib_qs_menus.sh desktop/bin/qbar`, `qmllint desktop/.config/quickshell/marcelof/ShellOverlays.qml desktop/.config/quickshell/marcelof/shell.qml`, `home -y`, `desktop/tools/qs-menu-smoke osd`.
  - Current behavior: volume, mute, mic mute, brightness, and keyboard brightness all route through the shared `ShellOverlays` OSD surface. `desktop/tools/qs-menu-smoke osd` now triggers the existing `qbar osd-volume` IPC, captures the overlay, crops it with shared geometry, and passed at `/home/marcelof/.local/state/quickshell/menu-smoke/20260803-202553`.

- [x] P1: Make clipboard/pass/search picker paths share one launcher primitive.
  - Sources: Caelestia launcher modes, AGS picker patterns, local Walker/passmenu migration.
  - Acceptance: app launcher, web search, clipboard, and passmenu share focus, close, empty state, row spacing, and keyboard navigation; backend-specific code is only data fetch plus activation.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/ShellConfigData.qml desktop/.config/quickshell/marcelof/ShellConfig.qml desktop/.config/quickshell/marcelof/shell.qml desktop/.config/quickshell/marcelof/ShellWallpaperService.qml desktop/.config/quickshell/marcelof/ShellWallpaperPanel.qml desktop/.config/quickshell/marcelof/ShellCalendarPanel.qml desktop/.config/quickshell/marcelof/ShellPersonalDashboardPanel.qml desktop/.config/quickshell/marcelof/ShellPickerList.qml desktop/.config/quickshell/marcelof/ShellClipboardPanel.qml desktop/.config/quickshell/marcelof/ShellPassMenuPanel.qml desktop/.config/quickshell/marcelof/ShellLauncherPanel.qml desktop/.config/quickshell/marcelof/ShellLauncherService.qml`, `bash -n desktop/bin/qbar desktop/tools/qs-menu-smoke desktop/lib/lib_qs_menus.sh`, `desktop/tools/quickshell-repeat-audit`, `home -y`, `/home/marcelof/bin/qbar reload`, `desktop/tools/qs-menu-smoke launcher clipboard websearch passmenu launcher-hidden clipboard-toggle`, `/home/marcelof/bin/qbar list-menus`.
  - Current behavior: `ShellPickerList.qml` owns picker list visibility, spacing, current-index movement, and current-row positioning for launcher, clipboard, and passmenu. Web search uses the same copied Omarchy `Ui/TextField.qml` as the other search surfaces. `qbar passmenu` calls the typed passmenu IPC with default copy/username/gopass args, and `passmenu` is included in `desktop/lib/lib_qs_menus.sh`.

- [x] P1: Add meeting-aware DND/privacy status without guessing app internals.
  - Sources: Noctalia privacy indicators, local Google Meet/screenshare/mic issues, PipeWire portal status.
  - Acceptance: bar/control center distinguishes mic, camera, screen share, and DND; audioctl pause-all never touches meeting/browser capture sessions.
  - Validation: `desktop/bin/desktop-privacy-status self-test`, `desktop/bin/audioctl self-test`, `qmllint desktop/.config/quickshell/marcelof/ShellBar.qml desktop/.config/quickshell/marcelof/ShellControlPanel.qml desktop/.config/quickshell/marcelof/ShellScreenPanel.qml desktop/.config/quickshell/marcelof/shell.qml`, `desktop/tools/qs-menu-smoke controls screen`, `desktop/tools/desktop-doctor`.
  - Current behavior: the bar shows separate mic, camera, screen-share/record, and DND icons from `desktop-privacy-status`; left click opens Screen details and right click toggles DND. Controls shows the same privacy state plus refresh/details actions. `audioctl self-test` proves pause/resume/force-stop only touch helper-owned noise/music and leave an unmanaged process alive, so browser/meeting audio is not controlled by pause-all.

- [x] P1: Add a tiny system-health details page instead of crowding the bar.
  - Sources: Caelestia dashboard modules, board native checks, current bar status pressure.
  - Acceptance: bar keeps short icons only; details for clock sync, DNS, Docker, safe status, CPU, memory, temperature, weather, fan, and battery health live in one popup page.
  - Validation: `board render text quickshell-bar`, `desktop/tools/qs-menu-smoke controls personal-dashboard`.
  - Current behavior: the existing Personal dashboard now includes a `system` tab backed by `board render text quickshell-bar`, keeping the bar compact while exposing board health details in a popup surface. Validation passed for focused `qmllint`, `board --config desktop/.config/board/board.toml render text quickshell-bar`, `home -y`, `/home/marcelof/bin/qbar reload`, and `desktop/tools/qs-menu-smoke controls personal-dashboard` at `/home/marcelof/.local/state/quickshell/menu-smoke/20260803-200754`.

- [x] P2: Add wallpaper/theme preview workflow without a full theme engine.
  - Sources: Caelestia wallpaper handling, end-4 wallpaper/theme panels, current Catppuccin lavender primary color.
  - Acceptance: wallpaper menu previews current/next wallpaper, can apply it, and optionally updates only the existing primary/accent tokens.
  - Validation: `desktop/tools/qs-menu-smoke wallpaper`, manual apply/reload smoke.
  - Current behavior: wallpaper menu shows a current/hover preview image, opens the current wallpaper, refreshes the list, opens the wallpaper folder, and applies a selected image through `wallpaper-wayland set` without adding a theme engine. Validation passed for focused `qmllint`, `home -y`, `/home/marcelof/bin/qbar reload`, `wallpaper-wayland status`, no-op apply with the current wallpaper, and `desktop/tools/qs-menu-smoke wallpaper` at `/home/marcelof/.local/state/quickshell/menu-smoke/20260803-200440`.

- [x] P2: Document the reference-repo import rule.
  - Sources: Omarchy, Caelestia, end-4, Noctalia, cxOrz, surface-dots, Aylur AGS, ML4W, JaKooLit.
  - Acceptance: docs state what ideas we copied, what we intentionally did not copy, and the rule: reuse ideas/patterns, avoid upstream-branded binaries and broad framework rewrites.
  - Validation: doc link from this task file.
  - Current behavior: `docs/desktop/wayland.md` has a `Reference Import Rule` section that names adapted ideas, rejected imports, and the local rule to reuse patterns without upstream-branded binaries or broad shell rewrites.

### 2026-08-03 Follow-Up Task Batch

Task source: latest local review request. Priority is code repetition and simple config first, then the highest-value UX gaps already seen in the local reference set.

- [x] P0: Move agent validation helpers out of the runtime bin surface.
  - Sources: user request to separate validation/helper scripts, current `desktop/bin` clutter, local `home -y` copy behavior.
  - Acceptance: agent/validation-only scripts live under `desktop/tools`; runtime commands used by Hyprland/Quickshell remain in `desktop/bin`; validation tools can still call each other from their new folder.
  - Validation: `bash -n desktop/tools/desktop-doctor desktop/tools/desktop-accept desktop/tools/desktop-package-audit desktop/tools/desktop-notification-smoke desktop/tools/qs-menu-smoke desktop/tools/quickshell-repeat-audit`.
  - Current behavior: `desktop-accept`, `desktop-doctor`, `desktop-package-audit`, `desktop-notification-smoke`, `qs-menu-smoke`, and `quickshell-repeat-audit` moved to `desktop/tools`; `desktop-doctor` and `desktop-accept` prepend their tool directory to `PATH`.

- [x] P0: Fix `Win+D` app selection and remove the duplicate launcher wrapper.
  - Sources: live launcher IPC smoke, current Quickshell `DesktopEntries` API, redundant `qs-launcher` wrapper.
  - Acceptance: `Win+D`/`Win+Space` open the launcher through `qbar launcher`; selecting an app launches the Quickshell desktop-entry object with command/`gtk-launch` fallback; the old wrapper is archived, not deleted.
  - Validation: `desktop/tools/qs-menu-smoke launcher`, `luac -p desktop/.config/hypr/init.lua desktop/.config/hypr/profiles/common.lua desktop/.config/hypr/profiles/default.lua desktop/.config/hypr/profiles/omarchy.lua`, manual `Win+D` open/type/Enter.
  - Current behavior: both active Hyprland profiles bind launcher keys to `qbar launcher`; `archive/obsolete/desktop/bin/qs-launcher` keeps the retired wrapper for history. Launcher IPC sets `panelOpen`, so click and Enter route through the visible `DesktopEntries` object in `ShellLauncherService.qml`; Settings exposes `Clear Hidden Apps` for hidden-entry recovery.

- [x] P1: Continue reducing Quickshell/Hyprland runtime script count by call-site audit only.
  - Sources: user request to reduce script count, current runtime helpers, Ponytail/YAGNI rule.
  - Acceptance: remove or archive only scripts proven redundant by `rg` call-site checks; keep scripts that represent real runtime boundaries such as audio, privacy, screenshots, wallpaper, monitor, and browser wrappers.
  - Validation: `rg -n "bin\(\\"|qs\(|exec|command -v" desktop/.config/quickshell/marcelof desktop/.config/hypr desktop/bin desktop/tools desktop/lib`, `bash -n desktop/bin/qbar desktop/bin/desktop-osd desktop/bin/audioctl desktop/bin/screenshot-wayland desktop/bin/wallpaper-wayland desktop/bin/screen-record-wayland desktop/bin/desktop-privacy-status desktop/bin/network-status desktop/tools/desktop-doctor`, `desktop/tools/qs-menu-smoke all`, `desktop/tools/desktop-doctor`, `home -y`.
  - Current behavior: the call-site audit did not prove any additional active runtime wrapper redundant. `qbar`, `desktop-osd`, `audioctl`, screenshot, wallpaper, screen-record, privacy, network, browser, picker, and board/status helpers remain real runtime boundaries. During validation, targeted smoke checks were fixed so they no longer clobber the full-smoke `latest` pointer; `desktop/tools/qs-menu-smoke osd` now reports `latest unchanged`, full smoke restored `/home/marcelof/.local/state/quickshell/menu-smoke/20260803-202905`, and `desktop/tools/desktop-doctor` passes.

- [x] P0: Make `desktop/tools/quickshell-repeat-audit` a gate for every Quickshell pass.
  - Sources: local repetition audit, current `ShellTheme.qml`/`ShellConfigData.qml` split.
  - Acceptance: the audit has an allowlist for intentional repeats and fails on new repeated literals outside theme/config/component primitives.
  - Validation: `ruby -c desktop/tools/quickshell-repeat-audit`, `desktop/tools/quickshell-repeat-audit`, temporary non-allowlisted repeat fixture.
  - Current behavior: repeated literals are printed as `allowed` or `BLOCK`; the script exits 1 on any non-allowlisted repeated literal and exits 0 for the current intentional repeats. `desktop/tools/desktop-accept` now syntax-checks and runs this audit before applying and reloading the desktop.

- [x] P0: Finish the QML config boundary.
  - Sources: Caelestia config/state split, surface-dots config file layout, current `ShellConfig.qml`/`ShellConfigData.qml`.
  - Acceptance: panel components do not define command arrays, app paths, static labels, menu ids, menu sizes, theme colors, or user-tunable values; they only render data and call named helpers.
  - Validation: boundary `rg` returns no matches, `qmllint desktop/.config/quickshell/marcelof/ShellTheme.qml desktop/.config/quickshell/marcelof/ShellControlPanel.qml`, `desktop/tools/quickshell-repeat-audit`.
  - Current behavior: command arrays, app paths, static menu data, and user-tunable values are routed through `ShellConfig.qml`, `ShellConfigData.qml`, or `ShellTheme.qml`; the last controls menu width literal moved into `ShellTheme.qml`.

- [x] P0: Finish splitting `shell.qml` down to root wiring only.
  - Sources: Caelestia services/components, Noctalia modules, end-4 widgets.
  - Acceptance: `shell.qml` owns windows, IPC, and top-level state only; any repeated visual block, service process, or menu body lives in a focused `Shell*.qml` component.
  - Validation: `wc -l desktop/.config/quickshell/marcelof/shell.qml`, `qmllint desktop/.config/quickshell/marcelof/shell.qml desktop/.config/quickshell/marcelof/Shell*.qml desktop/.config/quickshell/marcelof/StatusText.qml`.
  - Current behavior: OSD state/display/timers and notification toast timing moved into `ShellOverlays.qml`; calendar grid helpers moved into `ShellCalendarPanel.qml`; launcher ranking/activation moved into `ShellLauncherService.qml`; polling/process blocks live in focused service components, and `shell.qml` has no direct `Process` blocks left. `shell.qml` is 1465 lines and focused QML lint passed. Remaining root-owned code is top-level state, IPC, and glue that crosses panels.

- [x] P0: Move board check metadata out of Rust.
  - Sources: current board config, user request to keep config in one place and code generic.
  - Acceptance: board check labels, thresholds, enabled flags, script paths, and surface membership live in TOML; Rust keeps only native check implementations and rendering.
  - Validation: `cargo test -p board`, source and live `board --config ... doctor`, source and live `board --config ... checks`, live `board --config ... render text quickshell-bar`, release install to `~/bin/board`, `home -y`.
  - Current behavior: config owns check labels, thresholds, enabled flags, script commands, weather location, time-panel timezones, and surface membership. Rust keeps native check implementations, render plumbing, and stable `StatusItem.name` cache/metric keys; human `checks` and TUI output use config labels.

- [x] P1: Make the menu registry the single source across QML, scripts, and key help.
  - Sources: local `lib_qs_menus.sh`, Controls menu, `hypr-keys`, `desktop/tools/qs-menu-smoke`.
  - Acceptance: menu id, label, shortcut, smoke target, geometry, and placement are declared once or generated from the same small data source.
  - Validation: `desktop/bin/qbar list-menus`, `desktop/tools/qs-menu-smoke --list`, `diff -u <(desktop/bin/qbar list-menus) <(desktop/tools/qs-menu-smoke --list)`, `bash -n desktop/lib/lib_qs_menus.sh desktop/bin/qbar desktop/tools/qs-menu-smoke desktop/bin/hypr-keys`, `desktop/bin/hypr-keys default`, `desktop/bin/hypr-keys omarchy`, `desktop/tools/qs-menu-smoke launcher clipboard websearch passmenu controls media notifications calendar wallpaper screen network power settings tray personal-dashboard`.
  - Current behavior: `desktop/lib/lib_qs_menus.sh` owns shell-side menu ids, labels for generated key help, open dispatch, and smoke crop geometry. `qbar list-menus` and `desktop/tools/qs-menu-smoke --list` are identical. `hypr-keys` parses the active Hyprland profile for shortcuts and asks `lib_qs_menus.sh` for Quickshell menu labels, so shortcut help is generated from the real bindings plus the shared menu label registry. QML menu sizes, control rows, settings rows, and dashboard surfaces remain in `ShellConfigData.qml`, which is the QML-side data source consumed by panel instances through `ShellConfig.qml`.

- [x] P1: Normalize all popup menus to the same shell primitives.
  - Sources: Noctalia compact popups, AGS launcher behavior, current `ShellPopup` and `ShellFloatingPopup`.
  - Acceptance: launcher, clipboard, passmenu, web search, calendar, controls, media, notifications, wallpaper, screen, network, power, settings, tray, and dashboards share focus, Escape, double-toggle, click-away, empty/loading/error state, row sizing, and clipping behavior.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/ShellFloatingPopup.qml desktop/.config/quickshell/marcelof/ShellLauncherPanel.qml desktop/.config/quickshell/marcelof/ShellClipboardPanel.qml desktop/.config/quickshell/marcelof/ShellPassMenuPanel.qml desktop/.config/quickshell/marcelof/ShellWebSearchPanel.qml desktop/.config/quickshell/marcelof/ShellPickerList.qml desktop/.config/quickshell/marcelof/ShellLauncherService.qml`, `bash -n desktop/bin/qbar desktop/tools/qs-menu-smoke desktop/lib/lib_qs_menus.sh desktop/bin/hypr-keys`, `desktop/tools/quickshell-repeat-audit`, `home -y`, `/home/marcelof/bin/qbar reload`, `desktop/tools/qs-menu-smoke launcher clipboard websearch passmenu controls media notifications calendar wallpaper screen network power settings tray personal-dashboard`.
  - Current behavior: `ShellFloatingPopup.qml` owns the Hyprland focus grab for floating picker popups and emits one `focusCleared` signal; launcher, clipboard, passmenu, and web search now only provide their close action. `ShellPickerList.qml` owns list spacing, visibility, current-index movement, and current-row positioning for picker lists, while anchored menus continue through `ShellPopup`/`ShellPanel`. Focused popup smoke passed at `/home/marcelof/.local/state/quickshell/menu-smoke/20260803-210254`.

- [x] P1: Add screenshot-backed visual regression for shell menus.
  - Sources: existing `desktop/tools/qs-menu-smoke`, local screenshot workaround docs, user reports that menus regress visually.
  - Acceptance: one command opens each menu, captures readable PNGs, detects blank/clipped/side-window render failures, and stores artifacts for comparison.
  - Validation: `desktop/tools/qs-menu-smoke all`, `desktop/tools/desktop-doctor`.
  - Current behavior: default-speed full smoke passed at `/home/marcelof/.local/state/quickshell/menu-smoke/20260803-193908`; launcher open is state-gated through IPC so the first floating popup no longer needs a manual slow smoke run.

- [x] P1: Rebuild the Controls dashboard as the hub for secondary menus.
  - Sources: Noctalia/cxOrz quick settings, current Controls menu and user request for buttons to every menu.
  - Acceptance: Controls exposes stable buttons for screen, network, audio, media, wallpaper, clipboard, notifications, tray, keybindings, settings, power, and personal dashboard without duplicate keybindings for the same action.
  - Validation: `desktop/tools/qs-menu-smoke controls screen network media wallpaper clipboard notifications tray power settings keybindings`.
  - Current behavior: Controls exposes data-driven hub buttons for apps, web, keybindings, clipboard, wallpaper, screen, audio/media, network, calendar, work inbox, personal dashboard, notifications, settings, tray, and power. The Power menu is now in the menu-row registry, and the Media button is explicitly the audio/media surface. Validation passed after `home -y` and `/home/marcelof/bin/qbar reload` with `desktop/tools/qs-menu-smoke controls screen network media wallpaper clipboard notifications tray power settings keybindings personal-dashboard` at `/home/marcelof/.local/state/quickshell/menu-smoke/20260803-200032`.

- [x] P1: Clean up media/audio UI without changing `audioctl` behavior.
  - Sources: Caelestia MPRIS cards, Noctalia media widgets, local `audioctl` regressions.
  - Acceptance: media menu uses one player card layout, shows local noise/music and MPRIS players clearly, exposes play/pause/stop/restore/kill safely, and never pauses browser meeting audio.
  - Validation: `audioctl self-test`, `desktop/tools/qs-menu-smoke media`, manual local noise plus music restore.
  - Current behavior: media menu uses one compact player/stream layout, shows MPRIS now-playing text plus saved noise/music state, exposes previous/play-pause/next, noise/music toggles, stop/force-stop, output mixer, default output slider, and per-stream volume/mute controls. `audioctl self-test` proves saved noise/music restore and force-stop behavior without touching browser meeting audio, and `desktop/tools/qs-menu-smoke media` passed.

- [x] P1: Improve notification center behavior and app focus.
  - Sources: Noctalia notification center, end-4 notification surfaces, local `notification-focus-app`.
  - Acceptance: grouped notifications expand/collapse without text overflow, action buttons remain usable, and clicking a notification focuses the matching app where Hyprland client metadata permits it.
  - Validation: `desktop/tools/desktop-notification-smoke actions`, `notification-focus-app --self-test`, `desktop/tools/qs-menu-smoke notifications`.
  - Current behavior: notification center groups history by app, expands a selected notification without collapsed-body overflow, keeps action buttons inside clipped rows, and routes `Open` through `notification-focus-app` using desktop-entry/app metadata. Validation passed for `desktop/tools/desktop-notification-smoke actions`, `notification-focus-app --self-test`, `desktop/tools/qs-menu-smoke notifications`, and focused `qmllint`.

- [x] P1: Finish the calendar/time dashboard.
  - Sources: Caelestia date/weather widgets, current time panel, user requests for Lisbon, Palmela, timestamps, todo, Pomodoro, and timewarrior.
  - Acceptance: calendar highlights today with the primary color, shows Lisbon plus configured timezones, timestamp formats, Palmela today/tomorrow min-max weather, todo, and a designed Pomodoro/timewarrior placeholder.
  - Validation: `desktop/tools/qs-menu-smoke calendar`, `check-time-panel`, `check-weather`.
  - Current behavior: calendar QML highlights today with `shellSettings.primaryColor`, shows Lisbon/timezone/timestamp output from `check-time-panel`, Palmela today/tomorrow min-max weather from `check-weather panel`, ready tasks from `check-todo-panel`, and Pomodoro/Timewarrior state through `pomodoroctl`. Validation passed for `desktop/tools/qs-menu-smoke calendar`, `check-time-panel`, `WEATHER_LOCATION="Palmela, Portugal" check-weather panel`, and `check-todo-panel`.

- [x] P1: Keep Hyprland profiles DRY and discoverable.
  - Sources: Omarchy keybinding discoverability, local `profiles/common.lua`, `hypr-keys`.
  - Acceptance: default and omarchy profiles share common actions/window rules through `common.lua`; only true profile differences stay in profile files; `hypr-keys` renders current behavior from the same data.
  - Validation: `luac -p desktop/.config/hypr/init.lua desktop/.config/hypr/profiles/common.lua desktop/.config/hypr/profiles/default.lua desktop/.config/hypr/profiles/omarchy.lua`, `HYPR_PROFILE=default hypr-keys`, `HYPR_PROFILE=omarchy hypr-keys`.
  - Current behavior: `profiles/common.lua` owns shared colors, group config, monitor defaults, popup/dropdown rules, direction loops, workspace-number loops, terminal detection, and shared action names. `hypr-keys` renders readable current behavior for both profiles, including Quickshell IPC, OSD, screenshot, and tmux popup actions.

- [x] P2: Document the final Quickshell/Hyprland architecture.
  - Sources: this task file, reference repo review, local extracted components.
  - Acceptance: docs explain shell root, services, primitives, config data, theme tokens, menu registry, board boundary, archive rule for X11 code, and what not to abstract.
  - Validation: `test -s docs/desktop/quickshell-architecture.md`, link from this task file.
  - Current behavior: `docs/desktop/quickshell-architecture.md` documents root/component/service/config/theme/helper ownership, board and archive boundaries, the reference import rule, and the "do not abstract" rule.

## Board And Quickshell Performance Boundary

- [x] P0: Measure the current Quickshell status polling cost before moving code.
  - Sources: rush `board/docs/design.md`, current `StatusText.qml`, current bar `board render` every second.
  - Acceptance: one note records idle CPU, process spawn rate, and the active `StatusText` timers for the current shell; the result decides whether a daemon/watch change is worth doing now.
  - Validation: `ps -eo comm,args`, `pidstat` or `perf stat` when available, `desktop/bin/qbar status`, and a short before/after note in this file.
  - Current behavior: before the change, `ShellBar.qml` ran `board render quickshell quickshell-bar` through `StatusText` every second. A short `pidstat` sample showed Quickshell around 0.66% CPU idle and no persistent board renderer, so the waste was process churn more than board CPU.

- [x] P0: Replace the per-second `board render` bar poll with a board daemon/watch path.
  - Sources: rush board design says `board run` owns scheduling and Quickshell should read snapshots or subscribe to daemon events instead of polling cache files every second.
  - Acceptance: Quickshell no longer starts a new `board render quickshell quickshell-bar` process every second; it consumes one long-running board stream or snapshot watcher, and `board render` stays useful for CLI/debug fallback.
  - Validation: `desktop/bin/qbar status`, process-spawn count before/after, `desktop/tools/qs-menu-smoke controls personal-dashboard`, and `desktop/tools/desktop-doctor`.
  - Current behavior: `board render --watch quickshell quickshell-bar` is installed and runs as one long-lived child of Quickshell. `StatusText.watch` consumes the newline-delimited stream, while one-shot `board render quickshell quickshell-bar` still works for CLI/debug.

- [x] P0: Keep Quickshell-native service facts out of board unless measurement proves a need.
  - Sources: Quickshell UPower/PipeWire/SystemTray/Notifications services and rush board boundary.
  - Acceptance: battery stays in Quickshell UPower; tray, notifications, workspace/window state, and direct UI interaction state stay in Quickshell. Board does not duplicate those services just to render the bar.
  - Validation: `rg -n "UPower|Pipewire|SystemTray|Notifications" desktop/.config/quickshell/marcelof`, `rg -n "battery|tray|notification|workspace" desktop/.config/board board/src` with expected boundary notes.
  - Current behavior: battery, PipeWire/media, tray, notifications, workspaces, popups, and direct interaction state remain Quickshell-owned. Board only renders the status segment stream.

- [x] P1: Move remaining hot command-backed status checks toward native board modules or event hooks.
  - Sources: board design native/module/event sections, current `kind = "command"` checks for scripts, alerts, agents, and gpg.
  - Acceptance: hot-path render never runs shell scripts; command checks either run only in the board scheduler, become native modules, or receive event updates plus slow reconciliation.
  - Validation: `board --config ~/.config/board/board.toml checks`, `board render quickshell quickshell-bar` under tracing, and no command-backed check executes from the common render path.
  - Current behavior: `board render` and `board render --watch` are cache-only for `kind = "command"`; missing command cache renders `pending`, stale command cache keeps the last scheduler value, and `board run` is started from both Hyprland profiles. `desktop/tools/desktop-doctor` now fails if the scheduler is not running.

- [x] P1: Move battery thresholds and icon/color policy into declarative shell config only if the rules change again.
  - Sources: current Quickshell UPower battery widget and repeated user tuning requests.
  - Acceptance: battery remains Quickshell-native, but thresholds/colors/icons are easy to tune without editing logic; skip this if the current hardcoded four-rule policy stays stable.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/ShellBar.qml desktop/.config/quickshell/marcelof/ShellConfigData.qml`.
  - Current behavior: `ShellConfigData.qml` owns `batteryPolicy` for full hiding, charge/full/discharge color roles, 15/30 percent critical/warning thresholds, and percent-to-icon mapping. `ShellBar.qml` only reads UPower and applies that policy.

## 2026-08-04 Visual Follow-Up

- [x] P1: Fix notification popup clipping from screenshot inspection.
  - Sources: `desktop/tools/qs-menu-smoke --inspect` reported clipped notification rows and an unreadable header action label.
  - Acceptance: notification rows do not clip collapsed or expanded content, header actions are readable, and the empty-state panel stays compact.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/ShellNotificationCenter.qml`, `desktop/tools/qs-menu-smoke --inspect notifications`, `desktop/tools/qs-menu-smoke`, and `desktop/tools/desktop-doctor`.
  - Current behavior: notification group rows are 40px, collapsed rows are 76px, expanded rows use content height with padding, delegates clip their own content, and the header clear buttons have readable `App` and `All` labels. Focused image inspection at `/home/marcelof/.local/state/quickshell/menu-smoke/20260804-195814` reported no clipped popup content, overlap, unreadable text, or regression.

- [x] P1: Fix Network popup readability and dead space from screenshot inspection.
  - Sources: `desktop/tools/qs-menu-smoke --inspect` reported small Network status text and then oversized empty space in the device list.
  - Acceptance: Network details are readable, controls remain intact, and the device list does not stretch into a large empty panel.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/ShellNetworkPanel.qml desktop/.config/quickshell/marcelof/ShellConfigData.qml`, `desktop/tools/qs-menu-smoke --inspect network`, `desktop/tools/qs-menu-smoke`, and `desktop/tools/desktop-doctor`.
  - Current behavior: Network popup height is compact, device details use larger wrapped text, the device section has a fixed useful minimum instead of filling dead space, and focused image inspection at `/home/marcelof/.local/state/quickshell/menu-smoke/20260804-200534` reported no visible defects or regressions.

- [x] P1: Fix Wallpaper popup compact layout and screenshot coverage.
  - Sources: `desktop/tools/qs-menu-smoke --inspect` reported a blank Wallpaper body, but `desktop/lib/lib_qs_menus.sh` cropped only the top 150px of a taller popup.
  - Acceptance: Wallpaper visual inspection captures the preview and list area instead of only the header slice.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/ShellWallpaperPanel.qml`, `bash -n desktop/lib/lib_qs_menus.sh desktop/tools/qs-menu-smoke desktop/bin/qbar`, `desktop/tools/qs-menu-smoke --inspect wallpaper`, `desktop/tools/qs-menu-smoke`, and `desktop/tools/desktop-doctor`.
  - Current behavior: the Wallpaper popup uses a compact current-wallpaper thumbnail row plus a content-sized list, and the smoke crop is 430px high so visual review includes the whole body. Focused image inspection at `/home/marcelof/.local/state/quickshell/menu-smoke/20260804-201610` reported no clipping, overlap, unreadable text, broken controls, huge empty area, or regression.

- [x] P1: Compact Media popup empty area.
  - Sources: `desktop/tools/qs-menu-smoke --inspect` reported a large unused area below Media playback controls when there are no active streams.
  - Acceptance: Media keeps the existing controls and stream scroll behavior, but the no-stream popup no longer has a large blank lower body.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/ShellConfigData.qml desktop/.config/quickshell/marcelof/ShellMediaPanel.qml`, `desktop/tools/qs-menu-smoke --inspect media`, `desktop/tools/qs-menu-smoke`, and `desktop/tools/desktop-doctor`.
  - Current behavior: Media popup height is 260px, keeping the controls visible while avoiding the previous no-stream dead area. Focused image inspection at `/home/marcelof/.local/state/quickshell/menu-smoke/20260804-202156` reported readable text, intact controls, no overlap, no clipped content, and no unusually huge empty area.

- [x] P1: Compact Personal dashboard empty area.
  - Sources: `desktop/tools/qs-menu-smoke --inspect` reported a very large empty area after the Personal dashboard status list.
  - Acceptance: Personal keeps its existing board-backed surfaces and scroll behavior, but the default surface renders readable todo content instead of falling back to the icon-only bar.
  - Validation: `board --config desktop/.config/board/board.toml doctor`, `board --config desktop/.config/board/board.toml render text personal.today`, `qmllint desktop/.config/quickshell/marcelof/ShellConfigData.qml desktop/.config/quickshell/marcelof/ShellPersonalDashboardPanel.qml`, `desktop/tools/qs-menu-smoke --inspect personal-dashboard`, `desktop/tools/qs-menu-smoke`, and `desktop/tools/desktop-doctor`.
  - Current behavior: Personal dashboard height is 240px, `personal.today` maps to the todo board check, placeholder personal surfaces no longer fall back to the bar, personal surfaces render as plain preformatted text, and the action button uses a short Run label. Focused image inspection at `/home/marcelof/.local/state/quickshell/menu-smoke/20260804-203103` reported no clipping, overlap, unreadable text, broken controls, or meaningful regression.

- [x] P1: Compact Web search floating popup.
  - Sources: `desktop/tools/qs-menu-smoke --inspect` reported a huge empty area in the Web search popup; `profiles/common.lua` still forced `quickshell-websearch` to 640x220.
  - Acceptance: Web search keeps provider chips and input visible without a large blank body, and shared floating pickers keep explicit size tokens.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/ShellFloatingPopup.qml desktop/.config/quickshell/marcelof/ShellSearchBox.qml desktop/.config/quickshell/marcelof/ShellWebSearchPanel.qml desktop/.config/quickshell/marcelof/ShellConfigData.qml desktop/.config/quickshell/marcelof/shell.qml`, `luac -p desktop/.config/hypr/init.lua desktop/.config/hypr/profiles/common.lua desktop/.config/hypr/profiles/default.lua desktop/.config/hypr/profiles/omarchy.lua`, `desktop/tools/qs-menu-smoke --inspect websearch`, `desktop/tools/qs-menu-smoke`, and `desktop/tools/desktop-doctor`.
  - Current behavior: Web search uses a 112px QML/menu size, Hyprland floats it at 640x112, the smoke crop is 124px high, and focused image inspection at `/home/marcelof/.local/state/quickshell/menu-smoke/20260804-204455` reported no overlap, unreadable text, broken controls, clipped popup content, or regression.

- [x] P1: Fix Password popup bottom-row clipping.
  - Sources: `desktop/tools/qs-menu-smoke --inspect` reported the Passwords popup lower list content clipped at the bottom with no clear scroll affordance.
  - Acceptance: Password entries render without visible bottom clipping, existing search/list behavior stays unchanged, and Quickshell IPC remains healthy.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/ShellConfigData.qml desktop/.config/quickshell/marcelof/ShellPassMenuPanel.qml desktop/.config/quickshell/marcelof/shell.qml`, `luac -p desktop/.config/hypr/init.lua desktop/.config/hypr/profiles/common.lua desktop/.config/hypr/profiles/default.lua desktop/.config/hypr/profiles/omarchy.lua`, `home -y`, `hyprctl reload`, `qbar restart`, `desktop/tools/qs-menu-smoke --inspect passmenu`, `desktop/tools/qs-menu-smoke`, and `desktop/tools/desktop-doctor`.
  - Current behavior: Password popup QML and Hypr floating rule use a 544px height, dense mode uses 500px, and focused image inspection at `/home/marcelof/.local/state/quickshell/menu-smoke/20260804-205920` reported no clipped popup content, overlap, unreadable text, broken controls, huge empty area, or regression.

- [x] P1: Fix Launcher popup bottom clipping.
  - Sources: `desktop/tools/qs-menu-smoke --inspect` reported the Launcher popup bottom label/text clipped at the lower edge, and live geometry showed Hyprland had previously forced a shorter launcher window than the QML menu token.
  - Acceptance: Launcher opens as a floating popup with a whole-row list viewport, no visible bottom clipping, and existing search/favorite/hide/launch behavior unchanged.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/ShellConfigData.qml desktop/.config/quickshell/marcelof/ShellLauncherPanel.qml desktop/.config/quickshell/marcelof/shell.qml`, `luac -p desktop/.config/hypr/init.lua desktop/.config/hypr/profiles/common.lua desktop/.config/hypr/profiles/default.lua desktop/.config/hypr/profiles/omarchy.lua`, `home -y`, `hyprctl reload`, `qbar restart`, `hyprctl clients -j`, `desktop/tools/qs-menu-smoke --inspect launcher`, `desktop/tools/qs-menu-smoke`, and `desktop/tools/desktop-doctor`.
  - Current behavior: Launcher QML and Hypr floating rule use a 714px height, live Hyprland reported `size=720x714`, and focused image inspection at `/home/marcelof/.local/state/quickshell/menu-smoke/20260804-210814` reported no clipped popup content, no internal overlap, no broken controls, no huge empty area, and no launcher regression.

- [x] P1: Fix Work Inbox action button clipping.
  - Sources: `desktop/tools/qs-menu-smoke --inspect` reported Work Inbox right-side action buttons clipped as `Op...`.
  - Acceptance: Work Inbox `Open` buttons render readable labels without clipping, while Slack/GitHub/Linear rows and refresh behavior stay unchanged.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/ShellWorkInboxPanel.qml desktop/.config/quickshell/marcelof/shell.qml`, `home -y`, `qbar restart`, `QS_MENU_SMOKE_SLEEP=1.5 desktop/tools/qs-menu-smoke --inspect work-inbox`, `desktop/tools/qs-menu-smoke`, and `desktop/tools/desktop-doctor`.
  - Current behavior: Work Inbox uses 78px `Open` buttons, and focused image inspection at `/home/marcelof/.local/state/quickshell/menu-smoke/20260804-211633` reported no clipped content, no overlap, readable text, intact controls, no huge empty area, and no regression.

- [x] P1: Add Launcher bottom breathing room.
  - Sources: fresh `desktop/tools/qs-menu-smoke --inspect` still reported Launcher bottom item text clipped at the lower edge after the previous size alignment.
  - Acceptance: Launcher list keeps whole-row geometry, has real layout spacing above the bottom frame, and existing search/favorite/hide/launch behavior stays unchanged.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/ShellLauncherPanel.qml desktop/.config/quickshell/marcelof/ShellConfigData.qml desktop/.config/quickshell/marcelof/shell.qml`, `luac -p desktop/.config/hypr/init.lua desktop/.config/hypr/profiles/common.lua desktop/.config/hypr/profiles/default.lua desktop/.config/hypr/profiles/omarchy.lua`, `home -y`, `hyprctl reload`, `qbar restart`, `hyprctl clients -j`, `desktop/tools/qs-menu-smoke --inspect launcher`, `desktop/tools/qs-menu-smoke`, and `desktop/tools/desktop-doctor`.
  - Current behavior: Launcher list has a 12px layout bottom margin, launcher size is 720x726, live Hyprland reported `size=720x726`, and focused image inspection at `/home/marcelof/.local/state/quickshell/menu-smoke/20260804-212612` reported no clipped popup content, overlap, unreadable text, broken controls, or huge empty area.

- [x] P1: Make Calendar dashboard scroll instead of cramming bottom sections.
  - Sources: fresh visual smoke showed Calendar was functionally healthy but dense after weather, Pomodoro, timezones, agenda, and ready tasks accumulated in one fixed-height panel.
  - Acceptance: Calendar keeps all existing sections, but overflow uses the shared scrollable panel behavior instead of shrinking lower content into an unreadable stack.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/ShellCalendarPanel.qml desktop/.config/quickshell/marcelof/ShellScrollPanel.qml desktop/.config/quickshell/marcelof/shell.qml`, `home -y`, `qbar restart`, `desktop/tools/qs-menu-smoke calendar`, `desktop/tools/qs-menu-smoke`, and `desktop/tools/desktop-doctor`.
  - Current behavior: Calendar uses `ShellScrollPanel`, reusing the existing shared popup scrolling frame while keeping the month grid, Palmela weather, Pomodoro, timezone/timestamp, agenda, and ready-task sections intact. Full smoke passed at `/home/marcelof/.local/state/quickshell/menu-smoke/20260804-213303`.

## 2026-08-04 Notification Follow-Up

- [x] P1: Render Android-like app icons and notification images.
  - Sources: user request for Android-style notifications; Quickshell `Notification.appIcon`, `Notification.image`, `desktopEntry`, `hasActionIcons`, and current `ShellNotificationCenter` grouped rows.
  - Acceptance: toast and notification-center rows show the sender app icon when available, fall back to desktop-entry/app initials when not, and show notification images as bounded thumbnails without stretching rows or clipping text.
  - Dependencies: keep Quickshell as the notification server; no external daemon replacement.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/ShellNotificationCenter.qml desktop/.config/quickshell/marcelof/ShellOverlays.qml desktop/.config/quickshell/marcelof/shell.qml`, send icon and image notifications with `notify-send`, `desktop/tools/qs-menu-smoke --inspect notifications`, and `desktop/tools/desktop-notification-smoke actions`.
  - Current behavior: notification history stores `appIcon` and `image`; toasts and notification-center rows render app icons via `Quickshell.iconPath`, pass through `file://` and `image://` payloads, fall back to app initials for grouped rows, and show expanded notification images as bounded thumbnails.

- [x] P1: Add notification routing policy for neutral vs attention-worthy events.
  - Sources: user request that neutral notifications go only to the main place; current DND and notification-history model.
  - Acceptance: Quickshell records every non-transient notification in history, but only shows popup toasts for urgent notifications, configured important apps, or notifications with configured important actions/patterns. Neutral notifications increment the bar count and appear in the notification center only.
  - Dependencies: add a small declarative policy map in `ShellConfigData.qml`; avoid per-app logic scattered through QML.
  - Validation: `desktop/tools/desktop-notification-smoke routing` covers neutral and urgent notifications, `desktop/tools/qs-menu-smoke notifications controls`, and manual Slack/Chrome notification sanity check.
  - Current behavior: notification history still records every notification, but popup toasts are limited to critical urgency, configured important apps, configured action labels, or configured text patterns in `ShellConfigData.qml`; neutral notifications update the bar count and notification center only.

- [x] P1: Make notification action buttons visually reliable.
  - Sources: `desktop/tools/qs-menu-smoke --inspect notifications` reported that the action-smoke card promises `Open` and `Done`, but only the generic `Open` focus button is visible.
  - Acceptance: notification cards clearly separate the source-app `Open` button from live notification actions, and action labels fit without truncation or disappearing.
  - Validation: `desktop/tools/desktop-notification-smoke actions`, `desktop/tools/qs-menu-smoke --inspect notifications`, and manual action notification check.
  - Current behavior: source-app focusing is labeled `App`, while live D-Bus notification actions render as separate shared `ShellActionButton` controls with consistent label sizing and tooltips.

- [x] P1: Support sticky notifications until they are completed or dismissed.
  - Sources: user request for permanent notifications until something is done; Quickshell `resident`, `expireTimeout`, `transient`, and notification actions.
  - Acceptance: notifications marked resident, no-timeout, urgent, or matched by local policy stay visible in the notification center until dismissed/actioned; invoking an action only removes the card when the source notification is not resident or the local policy says the task is complete.
  - Dependencies: live actions still require the Quickshell notification object; durable history cannot replay arbitrary D-Bus action callbacks after reload.
  - Validation: `notify-send -t 0`, action smoke notification, reload with `qbar restart`, and `desktop/tools/qs-menu-smoke --inspect notifications`.
  - Current behavior: resident, no-timeout, urgent, and locally important notifications are marked sticky in the live history; action clicks keep sticky cards unless the action label matches `completeActions`, while normal action cards still dismiss.

- [x] P1: Persist safe notification history to disk.
  - Sources: user request for notification history; current in-memory `notificationHistory` capped at 50.
  - Acceptance: new notifications append sanitized metadata to a JSONL file under Quickshell state, capped/rotated to a small bounded size; stored data includes app, summary, body, time, urgency, desktop entry, icon/image references when safe, and whether live actions are still available.
  - Dependencies: do not store secrets from password helpers; keep body markup sanitized like the current QML text path.
  - Validation: send notifications, restart Quickshell, verify history survives in the center or CLI, run `desktop/tools/desktop-doctor`, and inspect the JSONL for bounded size and no obvious markup leakage.
  - Current behavior: sanitized notification rows persist to `~/.local/state/quickshell/marcelof/notifications.jsonl`, capped at the same 50-entry live history; password-helper apps are skipped, unsafe URL/data image references are dropped, and restored rows hide dead action callbacks with `liveActions: false`.

- [x] P2: Add `notificationctl` CLI/TUI backed by Quickshell history.
  - Sources: user request for a terminal CLI/TUI; current `qbar notifications`, `notification-focus-app`, and existing terminal-first helpers.
  - Acceptance: `notificationctl list`, `notificationctl open <id>`, `notificationctl clear <id|app|all>`, and `notificationctl tui` operate on the same persisted history; live notifications can still invoke actions through Quickshell IPC, while old entries can focus/open the source app.
  - Dependencies: depends on persisted history and a minimal Quickshell IPC command surface for clear/open/action.
  - Validation: `bash -n desktop/bin/notificationctl`, `notificationctl self-test`, `desktop/tools/desktop-notification-smoke actions routing`, and `desktop/tools/qs-menu-smoke notifications`.
  - Current behavior: `notificationctl` reads the persisted Quickshell notification JSONL, lists/open/clears safe entries, and offers a minimal terminal chooser without adding another notification daemon.


## 2026-08-05 Reliability Follow-Up

- [x] P0: Make desktop-doctor trustworthy before more UI work.
  - Sources: user request to prioritize reliable acceptance, plus recent false failures from active helper audio and stale board agent cache.
  - Acceptance: validation and agent-only helpers do not live in user-facing `desktop/bin`, duplicate wrappers are merged where practical, board uses a direct supported command for agent status, and `desktop-doctor` does not run `audioctl self-test` while helper-owned noise/music are active.
  - Validation: `bash -n desktop/bin/agent-tmux desktop/tools/ai-stack-doctor desktop/tools/desktop-doctor desktop/tools/desktop-accept`, `agent-tmux check`, `board --config ~/.config/board/board.toml once`, full `desktop/tools/qs-menu-smoke`, and full `desktop/tools/desktop-doctor`.
  - Current behavior: `ai-stack-doctor` lives under `desktop/tools`, `check-agents` is merged into `agent-tmux check`, live stale `~/bin/check-agents` and `~/bin/ai-stack-doctor` were archived out of PATH, board scheduler was restarted with the updated config, and full `desktop-doctor` passes while skipping the audio self-test during active helper playback.

## 2026-08-14 Omarchy Quattro IPC and Shell Optimization Follow-Up

Source review:

- Current Omarchy clone: `/tmp/omarchy-quattro`, branch `quattro`, refreshed with `git pull --ff-only`; last observed commit `ebdc026`.
- Upstream reference docs: https://github.com/basecamp/omarchy/blob/quattro/docs/omarchy-shell.md and `/tmp/omarchy-quattro/AGENTS.md`.
- Local source of truth: `docs/desktop/quickshell-architecture.md`, `docs/desktop/wayland.md`, and this task file. The wiki has older/general desktop notes, but executable Wayland/Quickshell work belongs here.
- Current local state: `desktop/bin/qbar` already wraps `qs ipc --path ~/.config/quickshell/marcelof/shell.qml`; `shell.qml` exposes a central `bar` IPC target plus smaller `websearch`, `lock`, `launcher`, `network`, `passmenu`, and `power` targets; Hyprland starts Quickshell and a separate `board run`; `ShellBar.qml` consumes `board render --watch quickshell quickshell-bar`.
- Direction: copy Omarchy patterns and small components where they shrink local code or make scripting reliable. Omarchy-style runtime names are allowed when they remove local glue, but they must stay behind local entrypoints such as `qbar`. Do not import distro update machinery, installer/reset flows, or the full plugin installer unless built-in local routing becomes too large to keep declarative.

Claim rule: complete one task at a time, keep `default` i3-compatible behavior intact, and run the listed validation before marking a task done.

- [x] P0: Add a small local `shell` IPC target above the current `bar` actions.
  - Sources: Omarchy `shell` IPC target with `ping`, `summon`, `hide`, `toggle`, and `call`; current local `qbar` and `shell.qml` IPC handlers.
  - Acceptance: `qbar shell ping`, `qbar shell toggle launcher`, `qbar shell hide launcher`, and `qbar close-panels` work without restarting Quickshell; existing commands such as `qbar launcher`, `qbar controls`, `qbar notifications`, and `qbar power` keep working.
  - Dependencies: reuse the existing menu ids from `ShellConfigData.qml` and existing toggle/hide functions in `shell.qml`; no new plugin registry yet.
  - Validation: `bash -n desktop/bin/qbar`, `qmllint desktop/.config/quickshell/marcelof/shell.qml`, `desktop/tools/qs-menu-smoke launcher controls notifications power`, and manual `qbar shell ping`.
  - Stop conditions: stop if Quickshell IPC cannot pass variable menu ids safely; fall back to explicit method names rather than adding a parser.
  - Current behavior: local `shell` IPC target exposes `ping`, `toggle`, `hide`, `summon`, and `closePanels`; `qbar shell ping`, `qbar shell summon launcher`, and `qbar shell hide launcher` were live-tested after `home -y` and `qbar restart`; targeted `desktop/tools/qs-menu-smoke launcher controls notifications power` passed at `~/.local/state/quickshell/menu-smoke/20260814-175546`.

- [x] P0: Move popup open, close, toggle, and focus behavior into one shared panel lifecycle.
  - Sources: Omarchy `shell/Ui/Panel.qml`; current duplicated handlers in `ShellLauncherPanel.qml`, `ShellNetworkPanel.qml`, `ShellPassMenuPanel.qml`, `ShellPowerMenu.qml`, and root `shell.qml` state functions.
  - Acceptance: launcher, clipboard, passmenu, web search, calendar, notifications, controls, media, wallpaper, screen, network, settings, and power use the same open/close/toggle semantics; pressing the same key twice closes the popup; Escape and `qbar close-panels` close every transient popup.
  - Dependencies: extend existing `ShellPanel.qml` or `ShellFloatingPopup.qml`; do not add a new abstraction if a small helper property on the current components is enough.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/*.qml`, `desktop/tools/qs-menu-smoke`, and manual double-toggle tests for `Win+D`, `Win+,`, `Win+/`, `Win+Ctrl+A`, and `Win+Esc`.
  - Stop conditions: do not change Hyprland window rules or popup geometry in the same task unless the shared lifecycle exposes a real mismatch.

- [x] P1: Replace hardcoded menu command routing with a declarative built-in menu registry.
  - Sources: Omarchy `shell.json` bar/plugin layout idea; current `ShellConfigData.qml.menuIds`, `desktop/lib/lib_qs_menus.sh`, and `desktop/bin/qbar` case statement.
  - Acceptance: one local data map defines menu id, IPC target, open action, keybinding label, smoke-test name, and default size where practical; `qbar list-menus`, keybinding help, and smoke tests read the same names or generated output.
  - Dependencies: built-in registry only; no third-party plugin install/update support.
  - Validation: `bash -n desktop/bin/qbar desktop/lib/lib_qs_menus.sh desktop/tools/qs-menu-smoke`, `qmllint desktop/.config/quickshell/marcelof/ShellConfigData.qml`, `qbar list-menus`, and `desktop/tools/qs-menu-smoke --list` if available.
  - Stop conditions: if generating shell code from QML data gets awkward, keep Bash and QML registries separate but add a doctor check that they agree.
  - Current behavior: kept the existing two small registries instead of adding code generation: QML owns menu ids and sizes in `ShellConfigData.qml`, Bash owns shell-facing labels/smoke names in `desktop/lib/lib_qs_menus.sh`. `qbar` now routes legacy menu commands such as `launcher`, `controls`, `notifications`, `network`, `clipboard`, and `close-panels` through the generic `shell` IPC target; Quickshell exposes `shell listMenus` for scriptable discovery of QML menu ids. Validation passed for `bash -n desktop/bin/qbar desktop/lib/lib_qs_menus.sh desktop/tools/qs-menu-smoke`, `qmllint desktop/.config/quickshell/marcelof/shell.qml desktop/.config/quickshell/marcelof/ShellConfigData.qml`, `desktop/bin/qbar list-menus`, `desktop/tools/qs-menu-smoke --list`, `home -y`, `qbar restart`, `qbar shell ping`, `qbar shell listMenus`, `qbar launcher`, `qbar controls`, and `qbar notifications`.

- [x] P1: Make `qbar` IPC behavior match the useful parts of `omarchy-shell`.
  - Sources: Omarchy `bin/omarchy-shell` quiet mode, IPC timeout, display recovery, and clear error handling.
  - Acceptance: `qbar -q <action>` suppresses noisy failures for keybind/autostart use; calls from SSH or TTY recover `WAYLAND_DISPLAY` from the runtime dir when possible; IPC failures do not automatically restart Quickshell unless the user explicitly asks for `restart` or the target is known to be starting.
  - Dependencies: keep current `qbar start|stop|restart|status`; no new binary name.
  - Validation: `bash -n desktop/bin/qbar`, `qbar status`, `qbar -q shell ping`, `env -u WAYLAND_DISPLAY qbar shell ping` from inside a live session, and `desktop/tools/desktop-doctor`.
  - Stop conditions: avoid broad process killing from quiet IPC paths.
  - Current behavior: `qbar -q` quiet mode, a 2s IPC timeout, and TTY/SSH `WAYLAND_DISPLAY` recovery are implemented; `qbar shell ...` and legacy per-menu IPC paths no longer restart Quickshell on IPC failure. Live checks passed for `env -u WAYLAND_DISPLAY qbar shell ping`, `qbar launcher`, quiet unknown calls, and a forced `QS_BIN=/bin/false qbar launcher` failure while the existing Quickshell process stayed running.

- [x] P1: Keep board as backend health state, but stop pushing interactive shell state through text render paths.
  - Sources: Omarchy single shell process model; current board boundary in `quickshell-architecture.md`.
  - Acceptance: battery, audio/mic, brightness, tray, notifications, workspaces, privacy, and current popup state remain Quickshell-native; board keeps health/status checks and personal dashboards. Any board-backed bar segment must be one watched stream or cached snapshot, not repeated hot shell execution.
  - Dependencies: measure before replacing `board render --watch`; this task may be docs/validation only if current behavior is already one long-lived stream.
  - Validation: process tree check for one `board render --watch quickshell quickshell-bar`, `board --config desktop/.config/board/board.toml doctor`, `desktop/tools/desktop-doctor`, and `desktop/tools/qs-menu-smoke controls media notifications`.
  - Stop conditions: do not rewrite board modules into QML without measured CPU, memory, or latency evidence.
  - Current behavior: no rewrite needed. `ShellBar.qml` consumes `board --config ... render --watch quickshell quickshell-bar` through one watched `StatusText`; the live process tree showed one Quickshell child `board --config /home/marcelof/.config/board/board.toml render --watch quickshell quickshell-bar` plus the separate scheduler `board --config ... run`. Board owns health checks and personal dashboard surfaces; battery, privacy, tray, workspaces, popups, and interaction state stay Quickshell-native. Validation passed for `board --config desktop/.config/board/board.toml doctor`, `hypr-session smoke`, full `desktop/tools/qs-menu-smoke` at `~/.local/state/quickshell/menu-smoke/20260814-183334`, and full `desktop/tools/desktop-doctor`.

- [x] P1: Adapt Omarchy notification and OSD structure where it removes local duplication.
  - Sources: Omarchy `plugins/notifications/Service.qml`, notification card components, and OSD model; current `ShellNotificationCenter.qml`, `ShellOverlays.qml`, and `desktop-osd` path.
  - Acceptance: notification app icons, actions, sticky state, grouped history, and OSD visuals keep their current features but use smaller shared components and consistent spacing; no regression in notification action smoke tests.
  - Dependencies: preserve current notification history file and DND/routing policy.
  - Validation: `desktop/tools/desktop-notification-smoke actions routing`, `desktop/tools/qs-menu-smoke --inspect notifications`, `desktop/tools/qs-menu-smoke controls`, and `qmllint` on touched QML.
  - Stop conditions: do not replace the notification server with another daemon.
  - Current behavior: `ShellNotificationCard.qml` carries the shared card layout for the center and toast overlay; notification rows keep app/icon/action/sticky behavior, grouped history, and DND routing. OSD sizing is content-based. Validation passed for `qmllint desktop/.config/quickshell/marcelof/ShellNotificationCenter.qml desktop/.config/quickshell/marcelof/ShellOverlays.qml desktop/.config/quickshell/marcelof/ShellNotificationCard.qml`, `desktop/tools/desktop-notification-smoke actions routing`, full `desktop/tools/qs-menu-smoke`, and `desktop/tools/desktop-doctor`.

- [x] P2: Add shell-owned lock, idle, and polkit review tasks after IPC and panels are stable.
  - Sources: Omarchy Quattro moved lock screen, idle behavior, and polkit into the shell process; current local lock path delegates to `hyprlock`, `swaylock`, or `loginctl` and idle inhibit uses `desktop-inhibit`.
  - Acceptance: document whether each of lock, idle, and polkit should stay delegated or move into Quickshell; create implementation tasks only for items that reduce real runtime complexity or fix a current bug.
  - Dependencies: finish shell IPC and shared panel lifecycle first.
  - Validation: `hypr-session smoke`, lock/unlock manual test, suspend/inhibit manual test, and polkit prompt manual test if changed.
  - Stop conditions: do not fake a secure lock window in QML; keep real locker delegation unless there is a proven secure replacement.

- [x] P2: Document copy-license rules for upstream QML snippets.
  - Sources: Omarchy MIT license and existing local reference rule.
  - Acceptance: `docs/desktop/wayland.md` or `quickshell-architecture.md` states that small copied snippets from MIT references must keep attribution when substantial, while behavior-only rewrites need only a source note in tasks.
  - Dependencies: none.
  - Validation: docs-only review and `rg -n "Omarchy|MIT|Reference Rule|attribution" docs/desktop`.
  - Current behavior: `docs/desktop/wayland.md` now states the attribution rule for substantial MIT-compatible snippets versus behavior-only rewrites.

## 2026-08-15 Omarchy Manual Compatibility Follow-Up

Source review:

- Current manual fetched from `https://omarchy.org/manual/` into `/tmp/omarchy-manual-review`; 51 chapters were reviewed.
- Relevant manual chapters: Navigation, The Top Bar, Themes, Hotkeys, Unified Clipboard & History, Reminders, Notices, Text Extraction & Dictation, Screenshots & Recording, Toggles/Idle/Screensaver, Monitors, Keyboard/Mouse/Trackpad, Networking, System sleep, Fonts, Backgrounds, Branding, Common tweaks, Troubleshooting, FAQ, Security.
- Copy rule: copy behavior, component structure, and small MIT-compatible snippets whenever they fit the local stack and make this repo leaner. Omarchy-style command names are acceptable behind local wrappers if they reduce glue. Do not copy Arch package/update flows, installer/reset/snapshot machinery, or distro security defaults into dotfiles.
- Local boundary: user-facing Wayland/Quickshell work belongs in this file and `docs/desktop/wayland.md`; system security/service changes belong in homelab tasks.

Claim rule: complete one task at a time. Keep `default` i3-compatible, keep `omarchy` profile Omarchy-like, validate each task before marking done, and archive old code instead of deleting it.

- [x] P0: Do an Omarchy quick-copy pass before inventing more shell code.
  - Sources: `/tmp/omarchy-quattro` when available, upstream Omarchy Quattro shell docs, current `ShellNotificationCenter.qml`, `ShellOverlays.qml`, `ShellFloatingPopup.qml`, `ShellPanel.qml`, and `qbar`.
  - Acceptance: identify the smallest Omarchy components worth copying or adapting first, starting with notifications, OSD, panel lifecycle, and IPC helpers. For each copied snippet, keep attribution and rename only where local clarity wins. Do not replace the whole shell.
  - Dependencies: refresh the Omarchy clone before copying exact code; keep `qbar` as the stable local entrypoint.
  - Validation: focused `qmllint` on touched QML, `bash -n` on touched shell wrappers, `desktop/tools/qs-menu-smoke notifications controls`, and `desktop/tools/desktop-notification-smoke actions routing`.
  - Stop conditions: stop if the copy requires Arch-only services, upstream package/update flow, or a broad plugin loader before any quick win works.

- [x] P0: Finish notification history CLI/TUI parity.
  - Sources: manual Notices and Hotkeys chapters; existing persisted `~/.local/state/quickshell/marcelof/notifications.jsonl`; current `notification-focus-app`; existing pending `notificationctl` task.
  - Acceptance: `notificationctl list`, `notificationctl open <id>`, `notificationctl clear <id|app|all>`, and `notificationctl tui` operate on the same safe persisted history. Live notifications can still invoke Quickshell actions; restored entries can focus/open their source app but do not pretend old D-Bus callbacks are live.
  - Dependencies: reuse the existing notification JSONL and Quickshell IPC; do not add a second notification daemon.
  - Validation: `bash -n desktop/bin/notificationctl`, `notificationctl self-test` with fake state, `desktop/tools/desktop-notification-smoke actions routing`, and `desktop/tools/qs-menu-smoke notifications`.
  - Stop conditions: stop if action replay would require storing unsafe callback state; list and focus old entries instead.

- [x] P0: Audit and complete bar click/scroll behavior against the manual.
  - Sources: manual Top Bar chapter; current `ShellBar.qml`, `ShellControlPanel.qml`, `ShellMediaPanel.qml`, `ShellNetworkPanel.qml`, `ShellPowerMenu.qml`, and `ShellCalendarPanel.qml`.
  - Acceptance: each visible bar item has documented left, right, middle, and scroll behavior where useful. Audio, mic, display/brightness, clock, network, notifications, power, tray, workspaces, privacy indicators, and launcher/menu affordances either match Omarchy behavior or document the local difference.
  - Dependencies: reuse existing panels and helpers; do not add new one-off scripts for click actions.
  - Validation: `docs/desktop/wayland.md` behavior table or bullet list, `qmllint desktop/.config/quickshell/marcelof/ShellBar.qml`, `desktop/tools/qs-menu-smoke controls media notifications calendar network power`, and manual scroll checks for audio/brightness.
  - Stop conditions: do not bind destructive actions to scroll/middle click; keep power actions behind confirmation.

- [x] P1: Add local notice commands for time, weather, and battery.
  - Sources: manual Notices chapter; current `check-time-panel`, `check-weather`, UPower state in Quickshell, and `desktop-osd`/notification toast surfaces.
  - Acceptance: generic local commands or `qbar shell` actions show time, weather, and battery notices as Quickshell notifications or OSDs. Add matching menu rows under Controls or Settings only if they reuse existing rows.
  - Dependencies: reuse existing time/weather/battery data; no polling daemon and no upstream command names.
  - Validation: `qbar shell ...` or helper self-tests, `desktop/tools/desktop-notification-smoke`, `desktop/tools/qs-menu-smoke controls calendar power`, and `desktop/tools/desktop-doctor`.
  - Stop conditions: if battery data is already clearer in the power panel, expose only time/weather notices.

- [x] P1: Add a small reminder workflow.
  - Sources: manual Reminders chapter; current Pomodoro/Timewarrior notes and notification history.
  - Acceptance: `reminderctl add <duration> <message>`, `reminderctl list`, and `reminderctl clear` store local reminders, trigger Quickshell notifications, and expose a compact panel/list in Controls or Calendar. Keep countdown reminders separate from Pomodoro.
  - Dependencies: local state under `~/.local/state/quickshell/marcelof`; use systemd user timers only if a sleeping shell process is not enough.
  - Validation: `bash -n desktop/bin/reminderctl`, `reminderctl self-test`, `reminderctl list`, `qmllint desktop/.config/quickshell/marcelof/ShellCalendarPanel.qml desktop/.config/quickshell/marcelof/ShellCalendarService.qml`, manual short reminder, `desktop/tools/desktop-notification-smoke`, and `desktop/tools/qs-menu-smoke calendar controls`.
  - Current behavior: `reminderctl` uses systemd user timers and `desktop-reminder` notifications; the Calendar popup shows a compact reminders list with refresh and clear-all buttons.
  - Stop conditions: do not integrate Google Calendar or Taskwarrior in this task.

- [x] P1: Improve NetworkManager panel toward manual parity.
  - Sources: manual Networking and FAQ chapters; current `network-status`, `ShellNetworkPanel.qml`, `nm-applet`, and `nmtui` fallback.
  - Acceptance: network popup shows connection state, Wi-Fi signal/band where `nmcli` exposes it, local IP, on-demand public IP, DNS summary, and safe actions for Wi-Fi toggle and reconnect. Optional follow-up rows for DNS presets and speed test are task-gated.
  - Dependencies: NetworkManager/nmcli only; secrets must not be displayed unless explicitly requested by a separate command.
  - Validation: `network-status bar`, `NETWORK_STATUS_PUBLIC_IP=0 network-status details`, `qmllint desktop/.config/quickshell/marcelof/ShellNetworkPanel.qml`, and `desktop/tools/qs-menu-smoke network controls`.
  - Stop conditions: no password reveal in Quickshell; no firewall or SSH daemon changes in dotfiles.

- [x] P1: Improve display and power panel parity.
  - Sources: manual Top Bar, Monitors, System sleep, Common tweaks, and FAQ chapters; current `external-brightness`, `power-status`, `monitor`, `ShellControlPanel.qml`, and `ShellPowerMenu.qml`.
  - Acceptance: display/power surfaces expose screen brightness, external brightness, battery health, AC/battery power profile state, text scale or monitor scale status where practical, suspend/hibernate visibility, and clear current monitor identity. Persist separate AC/battery profile preference only if `powerprofilesctl` supports the local hardware cleanly.
  - Dependencies: reuse `brightnessctl`, `ddcutil`, `powerprofilesctl`, `monitor`, and existing session menu confirmation.
  - Validation: `external-brightness self-test`, `power-status status`, `monitor status`, `qmllint desktop/.config/quickshell/marcelof/ShellControlPanel.qml desktop/.config/quickshell/marcelof/ShellPowerMenu.qml desktop/.config/quickshell/marcelof/ShellSystemStatusService.qml`, `desktop/tools/qs-menu-smoke controls power screen`, full `desktop/tools/qs-menu-smoke`, and `desktop/tools/desktop-doctor`.
  - Current behavior: Controls shows internal brightness, external brightness when available, keyboard brightness, monitor identity/status, battery health/profile status, fan status, and privacy state. Power menu refreshes and shows current profile plus battery/health before session actions. Hibernate stays available only through the existing confirmed session action; no monitor layout automation was added.
  - Stop conditions: do not change monitor layout automatically in this task; do not enable hibernate without explicit user approval.

- [x] P1: Add a minimal local theme compatibility model without a full theme engine.
  - Sources: manual Themes, Fonts, Backgrounds, Branding, and Making your own theme chapters; current `ShellTheme.qml`, `ShellConfigData.qml`, Settings primary-color swatches, Ghostty/GTK dark settings, and wallpaper picker.
  - Acceptance: one local theme state file records primary color, dark/light preference, font token, and wallpaper path; Quickshell reads it through existing settings/state paths; Settings can edit only values already supported. Document how this maps to Omarchy theme concepts.
  - Dependencies: no generated app-wide templates unless a current app already has a tracked config path and validation.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/ShellTheme.qml desktop/.config/quickshell/marcelof/ShellSettings.qml desktop/.config/quickshell/marcelof/ShellSettingsPanel.qml desktop/.config/quickshell/marcelof/ShellWallpaperService.qml desktop/.config/quickshell/marcelof/shell.qml`, `home -y`, `qbar restart`, `qbar shell ping`, live `jq . ~/.local/state/quickshell/marcelof/settings.json`, `desktop/tools/qs-menu-smoke settings wallpaper`, and `desktop/tools/desktop-doctor`.
  - Current behavior: `settings.json` persists primary color, fixed dark appearance token, fixed Fira Code Retina font token, wallpaper path, density, weather, DND, tray, and launcher preferences. Settings displays the active theme/font/primary/wallpaper summary. Wallpaper selection updates the same state file. Broad app templating, theme marketplace support, boot branding, and light-mode switching remain intentionally out of scope.
  - Stop conditions: skip boot unlock, Plymouth, broad app templating, and theme marketplace support.

- [x] P1: Compare current hotkeys to Omarchy manual categories and close useful gaps.
  - Sources: manual Hotkeys and Navigation chapters; current `desktop/bin/hypr-keys`, `profiles/default.lua`, and `profiles/omarchy.lua`.
  - Acceptance: a generated comparison lists manual category, current default behavior, current `omarchy` profile behavior, and decision. Add free, useful bindings to the `omarchy` profile first; only change `default` when it improves i3-compatible behavior without conflict.
  - Dependencies: reuse `hypr-keys`; no manually maintained duplicate key list.
  - Validation: `HYPR_KEYS_PROFILE_DIR=desktop/.config/hypr/profiles LIBS_DIR=desktop/lib desktop/bin/hypr-keys default`, `HYPR_KEYS_PROFILE_DIR=desktop/.config/hypr/profiles LIBS_DIR=desktop/lib desktop/bin/hypr-keys omarchy`, `luac -p desktop/.config/hypr/profiles/default.lua desktop/.config/hypr/profiles/omarchy.lua desktop/.config/hypr/init.lua`, `bash -n desktop/bin/hypr-keys desktop/lib/lib_qs_menus.sh`, `hypr-session test`, and `HYPR_PROFILE=omarchy hypr-session test`.
  - Current behavior: `docs/desktop/hotkeys-omarchy-compat.md` records category decisions from the Omarchy manual and generated local `hypr-keys` output. The `omarchy` profile adopted free local shortcuts for Controls/Bluetooth hub, Screen, Wallpaper, Settings, Notifications, DND, and time/weather/battery notices. Default kept i3-compatible behavior. Active profiles now call `qbar`, not the retired `qs-bar`.
  - Stop conditions: do not break `Win+D`, `Win+Enter`, `Win+V`, `Win+W`, or existing i3-parity expectations.

- [x] P2: Review shell-owned lock, idle, and polkit against manual Quickshell ownership.
  - Sources: manual Toggles/Idle/Screensaver, Hardware authentication, and Top Bar chapters; existing task for shell-owned lock/idle/polkit review.
  - Acceptance: document what stays delegated (`hyprlock`, `swaylock`, `loginctl`, system polkit) and what, if anything, should move into Quickshell. Implement only changes that reduce real bugs or duplicated runtime state.
  - Dependencies: keep secure lock handled by a real locker unless there is a proven secure replacement.
  - Validation: `hypr-session smoke`, `desktop/tools/desktop-doctor`, and docs-only review. Manual lock/unlock, idle inhibit, and polkit prompt checks are only required when behavior changes.
  - Current behavior: `docs/desktop/wayland.md` documents that Quickshell owns visible controls/IPC only. Lock stays delegated to `hyprlock`, `swaylock`, or `loginctl`; idle inhibit stays delegated to `desktop-inhibit`/`systemd-inhibit`; polkit stays delegated to the system agent. No fake QML lock or password prompt was added.
  - Stop conditions: no fake QML lock screen for security; no fingerprint/Fido setup in dotfiles.

- [x] P2: Split distro/system compatibility into homelab tasks.
  - Sources: manual Security, Networking, System snapshots, Updates, System sleep, Hardware authentication, and Unattended installs chapters.
  - Acceptance: create or document homelab-owned tasks for firewall/LocalSend exception, SSHD enablement policy, Docker exposure lockdown, time sync repair, package update workflow, hibernation, snapshots/backups, fingerprint/Fido setup, and Tailscale. Dotfiles should only link to those tasks.
  - Dependencies: homelab repo owns system changes; dotfiles can only validate or document.
  - Validation: docs-only in dotfiles plus homelab syntax checks when homelab tasks are created.
  - Current behavior: `docs/desktop/homelab-system-boundary.md` lists homelab-owned tasks for firewall/LocalSend, SSHD, Docker exposure, time sync, package updates, hibernation, snapshots/backups, fingerprint/Fido, and Tailscale. Dotfiles only validate/report these boundaries.
  - Stop conditions: do not run firewall, SSH, hibernation, or system reset commands from the home role.

- [x] P2: Add upstream snippet attribution policy.
  - Sources: manual review, Omarchy MIT license, and current reference-import rule.
  - Acceptance: docs state that substantial copied QML/shell snippets from Omarchy or other MIT references keep attribution near the adapted code or in the task entry; behavior-only rewrites need a source note but not copied branding.
  - Dependencies: none.
  - Validation: `rg -n "Reference|MIT|attribution|Omarchy" docs/desktop`.
  - Current behavior: `docs/desktop/wayland.md` records the upstream attribution policy and keeps runtime names behind local entrypoints such as `qbar`.

- [x] P0: Add a minimal Omarchy shell IPC compatibility shim.
  - Sources: Omarchy quattro `bin/omarchy-shell`, `docs/omarchy-shell.md`, and `manual/32-shell-plugins.md`.
  - Acceptance: `omarchy-shell shell ping`, `omarchy-shell shell toggle omarchy.menu`, and `omarchy-shell shell toggle omarchy.clock` route through the local `qbar` IPC. `omarchy.menu` opens the local root menu, whose Apps button opens the app launcher. Unsupported direct plugin targets fail clearly instead of opening the wrong local menu.
  - Dependencies: reuse the existing local Quickshell process and `qbar`; do not add a plugin loader yet.
  - Validation: `bash -n desktop/bin/omarchy-shell desktop/bin/qbar`, `qmllint desktop/.config/quickshell/marcelof/shell.qml`, `omarchy-shell -q shell ping`, and live menu toggle/hide checks after `home -y` and `qbar reload`.
  - Current behavior: `omarchy.menu` aliases the local root menu, `omarchy.clock` aliases the local calendar, and `notifications toggleDnd` maps to the existing DND toggle.


- [x] P0: Add Omarchy-style root menu entrypoint.
  - Sources: Omarchy quattro `shell/plugins/menu/BarWidget.qml` plus the existing local Controls menu rows.
  - Acceptance: `Win+Space`, `qbar menu`, and the left bar penguin toggle the same root menu; `Win+D` remains the app launcher; right-clicking the penguin opens the configured terminal.
  - Dependencies: reuse existing Quickshell menu actions and `qbar`; do not import the full upstream menu/plugin system yet.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/*.qml`, `luac -p desktop/.config/hypr/init.lua desktop/.config/hypr/profiles/common.lua desktop/.config/hypr/profiles/default.lua desktop/.config/hypr/profiles/omarchy.lua`, `bash -n desktop/bin/qbar desktop/lib/lib_qs_menus.sh`, `qbar shell toggle omarchy.menu '{}'`, and `qbar shell hide omarchy.menu`.

- [x] P0: Add read-only Omarchy plugin manifest review.
  - Sources: Omarchy plugin manifest schema in `manual/32-shell-plugins.md`.
  - Acceptance: a local review command validates `manifest.json`, lists kinds and entry points, warns that plugin QML is unsandboxed, and leaves plugins disabled by default.
  - Dependencies: no installer side effects and no runtime plugin execution in this task.
  - Validation: `omarchy-plugin-review self-test`, `omarchy-plugin-review --first-party /tmp/omarchy-quattro/shell/plugins/panels/clock`, and `desktop/tools/desktop-doctor`.
  - Current behavior: `omarchy-plugin-review` validates manifest schema, id/name/version, supported kinds, safe relative entry points, entry point files, missing symlinks, and reserved `omarchy.*` ids unless `--first-party` is explicit. It prints a short plugin summary and never executes plugin code.

- [x] P1: Add explicit local adapters for useful Omarchy plugin IPC targets.
  - Sources: Omarchy `docs/omarchy-shell.md` target list and local `qbar shell` target.
  - Acceptance: only targets backed by existing local state get adapters; unsupported targets keep failing clearly.
  - Dependencies: reuse `qbar` and existing Quickshell IPC handlers.
  - Validation: `omarchy-shell self-test`, `omarchy-shell shell ping`, `omarchy-shell notifications dndState`, `omarchy-shell omarchy.clock toggle`, `omarchy-shell omarchy.clock hide`, `omarchy-shell media status`, and `desktop/tools/desktop-doctor`.
  - Current behavior: direct panel targets with `open`, `show`, `summon`, `close`, `hide`, `toggle`, `ping`, and `refresh` map to existing local menus for menu, clock, audio, network, power, clipboard, notifications, weather, and monitor. Notifications map DND state/toggle/set, history, and clear. Media maps helper-owned audio status/play/pause/playPause only, so browser/Meet audio remains untouched. Lock maps `lock` and reports `false` for status because local locking stays delegated.

- [x] P1: Add safe Omarchy plugin staging without execution.
  - Sources: Omarchy `omarchy-plugin-add` staging flow and local `omarchy-plugin-review`.
  - Acceptance: a plugin directory or git URL can be staged into `~/.config/omarchy/plugins/<id>` only after manifest review. The command warns that plugins are unsandboxed and does not enable or run plugin QML.
  - Dependencies: reuse `omarchy-plugin-review`; no loader, no sudo, no shell reload, no enable state.
  - Validation: `omarchy-plugin-add self-test`, `bash -n desktop/bin/omarchy-plugin-add`, and `desktop/tools/desktop-doctor`.
  - Current behavior: `omarchy-plugin-add --yes <plugin-dir-or-git-url>` copies or clones into a temporary staging directory, validates, refuses id collisions, and moves the reviewed plugin into the Omarchy-compatible user plugin directory. `--enable` is accepted only to explain that enable is skipped until local plugin loading exists.

## 2026-08-18 Omarchy Quickshell Replacement Audit

Snapshot: `/tmp/omarchy-quattro`, branch `quattro`, refreshed with `git pull --ff-only`; last observed commit `f32ebbd`. Local shell summary: `desktop/.config/quickshell/marcelof` has about 6.1k QML lines, with `shell.qml` still about 1.8k lines. Omarchy's comparable shell is larger overall, but its structure is better separated: root shell, shared `Ui/` primitives, plugin registry, panel loader, bar widget registry, and first-party plugins.

Use this pass to replace local custom glue only where Omarchy's structure makes this repo smaller or less duplicated. Do not copy the full shell.

- [x] P0: Replace local menu lifecycle glue with a built-in panel registry.
  - Sources: Omarchy `shell/shell.qml` `summon`, `hide`, `toggle`, `panelEntries`, and `Ui/Panel.qml`; local `shell.qml` `closeTransientPanels`, `shellMenuOpen`, `hideShellMenu`, `toggleShellMenu`, and `openShellMenu`.
  - Acceptance: one registry maps built-in menu id, aliases, open property, refresh callback, floating/sidebar kind, and default size. `qbar shell summon|hide|toggle <id>` keeps working, repeated hotkeys still close, and Escape/focus-grab still close floating menus.
  - Dependencies: built-in local menus only; no third-party plugin loading or dynamic QML execution.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/*.qml`, `qbar shell listMenus`, `qbar shell toggle launcher`, `qbar shell hide launcher`, `desktop/tools/qs-menu-smoke launcher controls notifications clipboard calendar network power`, and `desktop/tools/desktop-doctor`.
  - Current behavior: `ShellConfigData.qml` owns built-in menu aliases, lifecycle callbacks, and action routing. `shell.qml` executes that registry and exposes read-only Omarchy-compatible `listPlugins` and `listShellConfig` IPC alongside open/hide/toggle. Launcher, bar, DND, and idle inhibit keep their small special paths.
  - Stop conditions: stop if the registry becomes code generation or requires replacing all panels in one diff.

- [x] P0: Fold popup lifecycle into shared local panel primitives.
  - Sources: Omarchy `shell/Ui/Panel.qml` and `shell/Ui/PanelController.qml`; local `ShellPopup.qml`, `ShellFloatingPopup.qml`, and `ShellPanel.qml`.
  - Acceptance: sidebar and floating menus expose the same `open`, `close`, `hide`, `show`, `toggle`, and optional IPC lifecycle. Individual panels should not need their own IPC handlers unless they have custom arguments such as passmenu mode or web-search site.
  - Dependencies: reuse current `PopupWindow`, `FloatingWindow`, and `HyprlandFocusGrab`; do not change visual layout in this task.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/ShellPopup.qml desktop/.config/quickshell/marcelof/ShellFloatingPopup.qml desktop/.config/quickshell/marcelof/*.qml` and manual double-toggle checks for `Win+D`, `Win+,`, `Win+/`, and `Win+Ctrl+A`.
  - Current behavior: `ShellPopup.qml` and `ShellFloatingPopup.qml` both expose `open`, `show`, `close`, `hide`, and `toggle`. Anchored popups route visibility through the built-in registry so child methods do not break root property bindings. `shell state <id>` provides read-only lifecycle verification. Launcher and passmenu retain custom IPC for their arguments and diagnostics; network and session retain thin legacy aliases. Live closed-open-closed assertions passed for launcher, web search, keybindings, controls, network, power, and tray. Full smoke: `~/.local/state/quickshell/menu-smoke/20260818-131850`.

- [x] P1: Consolidate menu metadata into one local data shape.
  - Sources: Omarchy manifest and `shell.json` layout idea; local `ShellConfigData.qml.menuIds/menuSizes`, `desktop/lib/lib_qs_menus.sh`, `desktop/bin/qbar`, and `desktop/tools/qs-menu-smoke`.
  - Acceptance: menu id, aliases, display label, smoke name, default size, and command routing are no longer maintained in several unrelated switch statements. Keep separate Bash and QML maps only where crossing the boundary would add more code than it removes.
  - Dependencies: no new parser dependency; `jq` is allowed only for existing JSON checks.
  - Validation: `bash -n desktop/bin/qbar desktop/lib/lib_qs_menus.sh desktop/tools/qs-menu-smoke`, `qbar list-menus`, and `desktop/tools/qs-menu-smoke --list`.
  - Current behavior: QML menu ids, aliases, lifecycle callbacks, actions, sizes, and rows live in `ShellConfigData.qml`. The smaller Bash registry remains the script boundary for display labels and screenshot crops; generating it from QML would add more machinery than it removes.

- [x] P1: Defer Omarchy bar widget registry until it removes real duplication.
  - Sources: Omarchy `plugins/bar/Bar.qml`, `BarModel.js`, widget manifests, and shared `Ui/BarWidget.qml`; local `ShellBar.qml` and `board render --watch quickshell quickshell-bar`.
  - Acceptance: document exact bar widgets that would become registry-backed, but do not replace `ShellBar.qml` until a focused diff removes real duplication. `board` remains the status renderer for health checks and personal dashboard data.
  - Dependencies: first finish built-in menu registry; avoid a plugin layout editor unless the user asks for draggable/reorderable bar widgets.
  - Validation: docs-only until implementation starts; then `qmllint ShellBar.qml` and `desktop/tools/qs-menu-smoke controls media notifications`.
  - Current behavior: keep direct composition for menu, workspaces, tray, board status, privacy, audio, controls, weather, brightness, network, battery, clock, and notifications. The local bar is 383 lines and has one layout; Omarchy's registry-backed bar is over 1,800 lines plus a loader and registry. Add registry-backed placement only when a second bar layout or a reviewed external bar widget is actually enabled. `board` remains the single status renderer.

- [x] P2: Keep local notification/media behavior; copy no larger Omarchy runtime.
  - Sources: Omarchy `plugins/notifications/Service.qml`, `plugins/notifications/components/NotificationCard.qml`, `plugins/services/media/Service.qml`, and `plugins/panels/audio/Panel.qml`; local `ShellNotificationCard.qml`, `ShellNotificationCenter.qml`, `ShellMediaPanel.qml`, and `audioctl`.
  - Acceptance: notification history, action routing, DND, and helper-owned audio boundaries stay local. Only copy layout/service splits that reduce duplicated QML or fix a visible bug.
  - Dependencies: do not let MPRIS/player controls pause Google Meet/browser capture sessions unless explicitly requested.
  - Validation: `desktop/tools/desktop-notification-smoke actions routing`, `audioctl self-test`, `desktop/tools/qs-menu-smoke notifications media`, and a manual Meet call safety check when audio control behavior changes.
  - Current behavior: local notification cards already provide per-app icons, click-to-focus, actions, grouping, DND, and history in 367 QML lines. Local media uses a 95-line panel plus `audioctl`, which deliberately owns only saved music/noise. Omarchy's compared media service and panel total about 1,760 lines and select across MPRIS/PipeWire players, so copying them would add complexity and weaken the Meet/browser boundary. No audio behavior changed; notification action/routing smoke, isolated `audioctl self-test`, and notification/media screenshots passed.

## 2026-08-18 Runtime Efficiency and Visual Follow-up

- [x] P0: Replace the process-backed bar clock with the existing native `SystemClock`.
  - Current behavior: `lisbonClockText` is a `Qt.formatDateTime(clock.date, "ddd-dd HH:mm:ss")` binding. The shell no longer forks `date` every second. Live screenshot verification showed `Tue-18 13:25:41` with no bar clipping.
- [x] P0: Give Controls enough width for device and battery-health status.
  - Current behavior: Controls is 720 by 960 pixels. Network/device, power, battery-health, and fan rows are fully visible beside their buttons; the matching smoke crop is 840 by 1020. Visual verification passed at `~/.local/state/quickshell/menu-smoke/20260818-132732`.
- [x] P1: Measure the settled shell before changing remaining polling.
  - Current behavior: an eight-second `pidstat` sample averaged 0.38% CPU for Quickshell with about 113 MiB RSS. Its persistent children were only `board render --watch` and `hypr-state watch`, both at 0.0% in the snapshot. Keep privacy, audio, network, and brightness polling unchanged until measurement shows a regression; optimize when sustained Quickshell CPU exceeds 1% at idle or RSS materially exceeds 150 MiB.

## 2026-08-18 Visual Consistency Follow-up

- [x] P0: Show live notification actions without requiring card expansion.
  - Current behavior: live actions such as `Open` and `Done` render immediately. App focus and clear controls use explicit labels. Live visual verification passed with no overlap.
- [x] P1: Give the launcher search field a visible prompt.
  - Current behavior: the shared search box displays `Search apps`. The launcher remains a centered floating popup, and launchability plus hide/unhide round-trip checks pass.
- [x] P1: Compact sparse calendar, tray, work inbox, and personal dashboard states.
  - Acceptance: empty or unavailable sections do not reserve large blank areas; populated states remain scrollable and unclipped. Reuse content-driven implicit heights instead of adding per-state fixed sizes.
  - Current behavior: Tray height follows its live item count up to the existing maximum. Work Inbox uses a 320px shared size token and readable secondary text instead of a faint 420px sparse surface. Calendar keeps its required scrollable 720px content, and Personal Dashboard was already content-fit at 240px, so neither received speculative geometry. Focused before/after smoke inspection found no clipping or overlap.

## 2026-08-18 Omarchy System and Keybindings Review

Upstream reference: `/tmp/omarchy-quattro` at `f32ebbd`. Omarchy routes `Super+Space` to a hierarchical menu, `Super+Escape` directly to its System submenu, and `Super+K` directly to searchable keybindings. Locally, `Super+Space` opens a flat menu whose Keys and Power rows already open the same panels as `Win+/` and `Win+Escape`; they are interconnected by action routing, but not by shared nested routes.

Provenance: the System naming and searchable-keybindings behavior were adapted from Omarchy. The first keybindings adaptation used the anchored `ShellPopup`; it was replaced because hotkey-opened xdg popups did not receive keyboard input. The final version reuses the local `ShellFloatingPopup` already proven by Launcher and Clipboard. Omarchy `KeyboardPanel.qml` was not copied because it depends on Omarchy `Ui`, `Commons`, bar coordination, plugin hosting, styling, and menu-provider code; copying most of it alone would not run. A live Hyprland `send_shortcut` test confirmed that typed text reaches the field and filters the list.

- [x] P0: Rename the root-menu Power entry to System without changing the `power` IPC id.
  - Acceptance: Super+Space shows System; selecting it, `Win+Escape`, and `qbar power` open the same session-action panel. Existing scripts and IPC remain compatible.
  - Current behavior: Super+Space shows System while the stable `power` action and IPC id remain unchanged.
- [x] P0: Make the local keybindings panel searchable and correct its visible action labels.
  - Current gap: `hypr-keys` shows 57 source-derived rows while live Hyprland has 92 binds, and it renders the Super+Space action as `root_menu)`.
  - Acceptance: typing filters shortcuts and descriptions, Super+Space reads as the root menu, Escape closes, and keyboard selection remains usable. Keep the current source parser until bindings carry runtime descriptions; live `hyprctl binds` currently reports zero descriptions.
  - Current behavior: the panel has a focused `Search keybindings` field and filters visible rows; Super+Space now reads `Root menu`. Runtime completeness remains a separate future task because live bindings have no descriptions.
- [x] P1: Route the battery bar item into the existing Controls power section.
  - Acceptance: clicking the visible battery opens Controls, current power profile is visibly selected, and no second battery/power panel or polling loop is added.
  - Current behavior: the battery item opens Controls, and exactly one of Save, Bal, or Perf reflects the active profile from the existing power-status refresh.
- [ ] P1: Enrich the existing one-shot power status with useful battery details.
  - Sources: Omarchy power panel battery size, charge cycles, time remaining/to full, rate, capacity, and profile controls.
  - Acceptance: show only values available from the existing UPower refresh; keep fan and profile controls in Controls; do not copy rotating phrases, animations, or a separate Omarchy runtime helper.
- [ ] P1: Hide or disable Hibernate when logind reports it unavailable.
  - Acceptance: Lock and Suspend remain immediate; Hibernate, Reboot, Shutdown, and Exit Hyprland retain confirmation; unavailable Hibernate cannot be selected.
- [ ] P1: Replace the flat Super+Space list with shallow local routes.
  - Proposed root: Apps, Trigger, Status, Setup, Learn, System. Learn opens Keybindings; System opens the existing session panel. Preserve direct hotkeys and IPC aliases.
  - Stop condition: do not copy the Omarchy JSONC provider engine or dynamic plugin menu until a user extension actually needs it.
## 2026-08-18 Omarchy Foundation Replacement Review

Snapshot: `/tmp/omarchy-quattro` at `f32ebbd`. The review compared local callers and line counts against Omarchy `shell/Ui`, `shell/Commons`, `shell/services`, `shell/plugins/menu`, and `shell/plugins/bar`. Copy upstream code only when it replaces a local implementation in the same task. Keep copied files close to upstream and record unavoidable local changes; do not build a second UI toolkit beside `Shell*` components.

- [x] P0: Copy Omarchy `PanelController.qml` and remove duplicate popup lifecycle state.
  - Sources: Omarchy `shell/Ui/PanelController.qml` and its focused tests; local `ShellPopup.qml` and `ShellFloatingPopup.qml` duplicate `open`, `show`, `close`, `hide`, and `toggle` state transitions.
  - Acceptance: copy the upstream controller with attribution, use one instance from both local popup bases, preserve registry-backed `visibilityAction` and `closeAction`, and delete duplicated state-transition code. Repeated hotkeys, Escape, focus loss, and `qbar close-panels` behave exactly as before.
  - Dependencies: none; this is the smallest self-contained upstream component found in the review.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/PanelController.qml desktop/.config/quickshell/marcelof/ShellPopup.qml desktop/.config/quickshell/marcelof/ShellFloatingPopup.qml`, live closed-open-closed assertions for launcher, clipboard, keybindings, controls, and power, then `desktop/tools/qs-menu-smoke launcher clipboard keybindings controls power`.
  - Current behavior: the copied controller owns lifecycle decisions for both popup bases. The only upstream adaptation is `transitionAction`, required because local menu state is registry-owned while Omarchy's controller mutates local state directly. Full QML lint passed, all five menus passed closed-open-closed assertions and visual smoke at `~/.local/state/quickshell/menu-smoke/20260818-152759`, and a live `brightness` query still received keyboard input and filtered the keybindings list.
  - Stop conditions: do not copy Omarchy `Panel.qml` or add per-panel IPC handlers in this task.

- [x] P0: Replace the local flat root menu with the copied Omarchy menu slice.
  - Sources: Omarchy `shell/plugins/menu/Menu.qml`, `MenuModel.js`, `manifest.json`, and `default/omarchy/omarchy-menu.jsonc`; local `ShellRootMenuPanel.qml` and `ShellConfigData.qml.controlMenuRows`.
  - Acceptance: Super+Space uses Omarchy's hierarchical navigation, search, aliases, checked/disabled rows, and provider contract from copied code. A local JSONC menu contains only commands supported by this Ubuntu/dotfiles setup. The copied menu replaces `ShellRootMenuPanel.qml`; `controlMenuRows` remains only as the Controls hub model. It must not coexist as a second root menu. `qbar menu`, the penguin button, keyboard navigation, mouse activation, Escape, and repeated Super+Space all work live.
  - Dependencies: first copy only the exact `Ui`/`Commons` files imported by the menu and keep their upstream module paths. Prefer thin local property injection and command adapters over editing the copied menu. This task supersedes the earlier JSONC-provider stop condition because the user explicitly chose direct upstream reuse.
  - Validation: run Omarchy's `MenuModel.js` tests against the copied file, `qmllint` the copied dependency closure, `qbar shell toggle root-menu`, and `desktop/tools/qs-menu-smoke launcher keybindings controls power`; manually type a query and activate one nested action.
  - Current behavior: the full upstream `Commons`, `Ui`, and menu plugin modules are present, and `Menu.qml` plus `MenuModel.js` are byte-identical to Omarchy `f32ebbd`. Local changes are confined to `Ui/PanelController.qml` for registry-owned transitions, `Ui/Panel.qml` for the older Ubuntu Qt parser, palette and lifecycle injection in `shell.qml`, and Ubuntu-safe actions in `omarchy-menu.jsonc`. The replaced flat menu and standalone controller are preserved under `archive/obsolete/desktop/`. Upstream menu tests, local JSONC parsing, and full QML lint pass. Live checks confirmed one Quickshell process, closed-open-closed root lifecycle, the System submenu, leaf routing into Power, and visual smoke for Launcher, Keybindings, Controls, and Power at `~/.local/state/quickshell/menu-smoke/20260818-155355`.
  - Stop conditions: stop and document the dependency that blocks the copy if the working slice requires the upstream bar, plugin registry, Arch package helpers, or changes to more than 10 percent of copied menu code. Do not silently rewrite it into another local menu.

- [ ] P1: Copy Omarchy plugin discovery and management as one tested runtime slice.
  - Sources: Omarchy `shell/services/PluginRegistry.qml`, `Commons/Util.qml`, plugin-registry fixtures, and `bin/omarchy-plugin-{validate,list,add,enable,disable,remove}`; local `omarchy-plugin-review`, `omarchy-plugin-add`, fake `shell.listPlugins`, and staged-but-never-enabled behavior.
  - Acceptance: copied upstream validation, discovery, list, add, enable, disable, remove, rescan, and `listPlugins` work against `~/.config/omarchy/plugins`. Replace the local review/add scripts and fake built-in plugin list rather than retaining parallel implementations. Third-party QML remains explicitly unsandboxed and disabled until enabled. Prove the runtime with one tiny fixture plugin before loading any external plugin.
  - Dependencies: complete the copied menu slice first so one real plugin kind and loader path already exists; preserve `qbar` as the local entrypoint and the current shell process.
  - Validation: upstream plugin validate/add/registry tests, `omarchy-shell shell rescanPlugins`, `omarchy-shell shell listPlugins`, enable/disable round trip for the fixture, `desktop/tools/desktop-doctor`, and a live Quickshell restart.
  - Stop conditions: do not claim arbitrary plugin compatibility until every declared plugin kind has a loader. Do not copy update/catalog/network installation behavior in this task.
  - Current blocker: upstream enablement assumes Omarchy's persistent `shell.json`, generic panel/service loaders, and bar registry. Copying only `PluginRegistry.qml` would report plugins enabled without loading them. Complete a real generic loader boundary before replacing the local compatibility list.

- [x] P0: Replace duplicated application search with Omarchy's shared AppLibrary foundation.
  - Sources: Omarchy `shell/services/AppSearch.js`, `AppLibrary.qml`, and `test/shell.d/app-search-test.sh`; local `ShellLauncherService.qml` and the copied menu Apps provider.
  - Acceptance: `Win+D` and Super+Space > Apps use one desktop-entry catalog and fuzzy search implementation. Preserve local MRU/MFU, favorites, reversible hide, command mode, and Ubuntu launching. Do not add a resident scanner.
  - Current behavior: `AppSearch.js` remains byte-identical to Omarchy `f32ebbd`; `AppLibrary.qml` is adapted to `DesktopEntry.execute()`/`gtk-launch`, reversible hide, and lazy icon indexing because `uwsm-app` is absent and the eager upstream scan made restart take about 34 seconds. The local launcher deleted its duplicate acronym, fuzzy-score, hidden-filter, entry-lookup, and launch-fallback code. The prior service is preserved under `archive/obsolete/desktop/`.
  - Validation: upstream AppSearch tests, full QML lint, JSONC Apps-provider validation, launcher visual smoke, `launcher-hidden` visible-hidden-visible round trip, live Apps submenu screenshot, one-process check, and post-adaptation `qbar restart` completed in about 4 seconds end to end.

- [ ] P1: Replace local UI primitives only when the copied menu dependency can delete them.
  - Sources: the dependency closure proven by the root-menu task; local `ShellTooltip.qml`, `ShellTheme.qml`, and related callers.
  - Progress: copied Omarchy `Ui/TextField.qml` remains byte-identical to `f32ebbd`; all five local search surfaces migrated to it with only caller-level Catppuccin/FiraCode overrides and native Qt key handlers. The old `ShellSearchBox.qml` is archived. Full QML lint, repetition audit, full menu smoke, live paced launcher input, visual field inspection, Escape-close checks for launcher/clipboard/web search/keybindings, and one-process restart validation passed. The live test also fixed `qbar` process matching to require the exact configured executable instead of matching validation command lines.
  - Progress: Omarchy `Ui/Button.qml` now owns rendering and interaction for all 89 `ShellActionButton` callers. The only upstream adaptation is generic `minimumWidth`/`minimumHeight`; the retained 30-line `ShellActionButton.qml` maps legacy names, local theme values, and signals without painting or input code. The removed 50-line implementation is archived. Omarchy's border-stability test, a local left/right-click and geometry fixture, full QML lint, six menu smokes, and before/after image comparison passed. A quiet idle fill was retained because transparent buttons hid hit areas and borders made dense menus noisy.
  - Progress: Omarchy `Ui/BorderSurface.qml` and `Commons/Border.qml` now own border rendering for `ShellFrame`, `ShellSection`, and `ShellStateBox`, covering 19 direct instances plus nine `ShellPanel` descendants. The local adapters keep layout and Catppuccin role values; flat uniform specs still take Omarchy's native `Rectangle.border` fast path. Prior implementations are archived. Omarchy's full border-geometry suite, full QML lint, nine affected-menu smokes, and before/after image comparison passed with no geometry or visual regression.
  - Progress: `ShellTheme.qml` remains the single local Catppuccin owner and now binds its palette/font into copied Omarchy `Color`/`Style` consumers. This avoids a second theme loader while `~/.local/state/omarchy/current/theme` is absent. QML lint, repetition audit, live restart, focused Power/Controls/root-menu smoke, and Power/Display screenshot inspection passed.
  - Acceptance: for each upstream primitive adopted, migrate all matching local callers and archive the replaced local file in the same commit. Keep `ShellTheme.qml` unless copied `Color` and `Style` replace it completely and still load Catppuccin Mocha lavender from one source. No panel may mix two button, text-field, tooltip, border, or spacing systems.
  - Dependencies: root-menu copy must identify a real shared dependency used by at least two local surfaces.
  - Validation: `qmllint desktop/.config/quickshell/marcelof/*.qml`, `desktop/tools/quickshell-repeat-audit`, full `desktop/tools/qs-menu-smoke`, and before/after screenshots for every migrated surface.
  - Stop conditions: no task is created for a one-caller primitive. Do not copy all 1,784 lines of Omarchy `Color.qml`, `Style.qml`, `Border.qml`, and `BorderGeometry.js` unless they delete the local theme and styling path rather than wrap it.

- [ ] P2: Reassess Omarchy bar coordination only after one real plugin widget is selected.
  - Sources: Omarchy `Ui/BarWidget.qml`, `services/BarWidgetRegistry.qml`, `plugins/bar/BarModel.js`, and `plugins/bar/Bar.qml`; local `ShellBar.qml` and its single fixed layout.
  - Acceptance: name the concrete widget that cannot be integrated cleanly with the current bar and measure the local code it replaces. Copy coordination/registry code only if the resulting bar removes local layout or popup-switching code and preserves board's single watched status stream.
  - Dependencies: working plugin discovery and one reviewed bar-widget plugin.
  - Validation: `qmllint` on the copied closure, bar geometry diagnostics, drag/reorder persistence if imported, `desktop/tools/qs-menu-smoke controls media notifications`, and settled CPU/RSS comparison.
  - Stop conditions: current evidence is against immediate replacement: local `ShellBar.qml` is about 392 lines, while Omarchy `Bar.qml` alone is about 1,826 lines. Do not import it merely for API compatibility.

## 2026-08-18 Omarchy First-Party Panel Adoption

Source: `/tmp/omarchy-quattro` at `f32ebbd`. First-party panels can be mounted
statically; PluginRegistry is not a prerequisite. Keep copied files close to
upstream and put Ubuntu command mapping in one host adapter. Do not add helper
scripts where native Quickshell or an existing local command already works.

- [x] P0: Add one minimal host adapter for copied Omarchy panels.
  - Acceptance: supply anchoring, lifecycle, palette/settings, panel switching, and service lookup while preserving `qbar`, repeated-hotkey close, outside-click close, and one shell process.
  - Dependencies: commit the current copied `Commons`/`Ui` foundation first.
  - Validation: `qmllint`; live open/close/toggle/Escape/outside-click/`qbar close-panels` checks.
  - Completed 2026-08-19: `ShellBar.qml` implements the narrow copied-panel contract; Power passed IPC toggle/close and outside-click popup behavior without a second shell or registry.
  - Stop: no plugin discovery, second registry, or per-panel adapters.

- [x] P0: Copy Omarchy Power as the battery and power-profile panel.
  - Sources: `shell/plugins/panels/power/{Panel.qml,Model.js,manifest.json}`; local UPower, `power-status`, board status, Controls, and battery bar item.
  - Acceptance: show charge state, health, cycles, rate, remaining/full time, battery size, and profile; replace overlapping Controls UI/polling; preserve local colors and hide-at-100-percent behavior.
  - Dependencies: host adapter; map Omarchy commands to native state or existing helpers.
  - Validation: upstream model tests, `qmllint`, charging/discharging screenshots, profile smoke, one-process and CPU/RSS checks.
  - Completed 2026-08-19: copied `Panel.qml` and `Model.js`; mapped commands to `power-status`; preserved battery health, local state colors, and hide-at-100-percent; live screenshot had no clipping or overlap. Removed the upstream unused system-stats process and decorative phrase/pulse animations.
  - Stop: omit rotating phrases/animations and duplicate helpers.

- [x] P0: Finish the copied System route with local safe actions.
  - Acceptance: Super+Space > System and `Win+Escape` expose Lock, Suspend, available Hibernate, Logout, Reboot, Shutdown, and Exit Hyprland; destructive/session-ending actions retain confirmation.
  - Dependencies: existing commands/confirmation state; query logind capability on open.
  - Validation: menu-model and lifecycle tests, safe Lock test, and non-executing command-plan assertions.
  - Completed 2026-08-19: Super+Space > System now mirrors Omarchy's direct actions while routing through the existing Session confirmation flow; Logout uses the current logind session; Hibernate is hidden when `CanHibernate` is `na`. Live reboot testing stopped at confirmation.
  - Stop: no Arch shutdown scripts or second System panel.

- [x] P0: Copy Omarchy Display and replace overlapping screen controls.
  - Sources: `shell/plugins/panels/monitor/{Panel.qml,Model.js,manifest.json}`; local screen/brightness helpers and Hyprland monitor config.
  - Acceptance: one panel owns focused internal/external brightness, supported live scaling, safe display enablement, and focused-monitor state; existing keys and monitor auto-connect keep working.
  - Dependencies: host adapter and command mapping for monitor state, brightness, and scale.
  - Validation: upstream model tests, `Hyprland --verify-config`, `qmllint`, brightness smoke, and one/two-display screenshots.
  - Completed 2026-08-19: copied and mounted Monitor `Panel.qml`/`Model.js`; reused `monitor`, `bri`, and `external-brightness`; removed old Controls display UI/polling; same-value brightness, two-display state, model, QML, session, and screenshot checks passed. Scale is live-only and preserves current position; final-display disable is refused. Upstream carries mirror state but renders no mirror control, so no local one was invented.
  - Stop: omit text-size controls unless they replace current settings cleanly; never disable the final display.

- [ ] P1: Copy Omarchy Bluetooth as a dedicated panel.
  - Acceptance: list, scan, connect, disconnect, pair, forget, power-toggle, and select a connected audio sink; route existing actions here and remove superseded glue.
  - Dependencies: host adapter and native Quickshell Bluetooth/PipeWire; reuse existing commands.
  - Validation: upstream model tests, `qmllint`, adapter-off/scan states, and one manual connect/disconnect round trip.
  - Stop: no second poller or copied hardware-specific scripts.

- [ ] P1: Copy Omarchy Network and replace `ShellNetworkPanel`.
  - Acceptance: active interface, approved local/public details, signal, throughput, latency, Wi-Fi scan/connect/disconnect/forget, password prompt, radio toggle, and supported DNS choices; secrets never appear in logs or argv.
  - Dependencies: prove the installed Quickshell NetworkManager backend; map status/DNS/band/QR actions without duplicate helpers.
  - Validation: upstream model tests, `qmllint`, wired/no-radio, saved/new Wi-Fi, wrong-password, DNS dry-run, screenshot, and idle CPU checks.
  - Stop: omit unsupported band control; archive the replaced panel rather than retaining a fallback.

- [ ] P1: Copy Omarchy Audio mixer while preserving `audioctl` ownership.
  - Acceptance: manage sinks, sources, volume/mute, playback streams, microphone level, and MPRIS; keep saved music/noise restore/pause/stop/force-kill under `audioctl`; never affect communication/capture streams with music controls.
  - Dependencies: host adapter and physical-sink/availability mapping; import Omarchy Media only if it replaces local code.
  - Validation: upstream model tests, `audioctl self-test`, `qmllint`, mixer smoke, saved noise+music restore, and manual Meet mic/share safety test.
  - Stop: no unused tuning/EasyEffects assumptions; stop on PipeWire or Quickshell crash regression.

- [ ] P1: Copy Wi-Fi QR after Network is stable.
  - Acceptance: show a decodable QR for the active shareable network without exposing its password in argv, logs, notifications, history, or screenshots outside the explicit panel.
  - Dependencies: copied Network and a secure NetworkManager secret-reading path.
  - Validation: upstream model tests, `qmllint`, QR decode, redaction, and process-list checks.
  - Stop: no plaintext connection-file parsing or second network backend.

- [ ] P2: Copy network and disk speed-test panels only when existing commands are reusable.
  - Acceptance: stream progress, cancel cleanly, report failures, run only on demand, and appear in the root menu without permanent bar widgets.
  - Dependencies: stable Network; inspect existing tracked CLIs before adding anything.
  - Validation: `qmllint`, success/failure/cancel runs, cleanup, and no idle child process.
  - Stop: skip panels requiring duplicate wrappers or duplicating board output.

- [ ] P1: Copy Omarchy Image Picker to replace the wallpaper picker UI.
  - Acceptance: thumbnails, filtering/navigation, current selection, apply/cancel, repeated-hotkey close, one shell process, and archived old wallpaper panel.
  - Dependencies: host/overlay lifecycle; retain existing wallpaper apply command/settings.
  - Validation: upstream tests, `qmllint`, screenshots, select/cancel/repeated-summon, and process checks.
  - Stop: no Omarchy theme-management or polling scripts merely to adopt the picker.

- [ ] P2: Copy Omarchy Emoji overlay as the shell-native emoji picker.
  - Acceptance: fuzzy search, keyboard/mouse selection, reliable close, standard-clipboard copy, and one default route.
  - Dependencies: host/overlay lifecycle and stable clipboard behavior.
  - Validation: `qmllint`, search/select, paste into Ghostty/Chrome, close, and process checks.
  - Stop: no extra emoji database or clipboard synchronizer when copied data and `wl-copy` suffice.

- [ ] P1: Bring Omarchy keybinding parsing improvements into the existing QML panel.
  - Sources: `bin/omarchy-menu-keybindings`; local `hypr-keys` and `ShellKeybindingsPanel.qml`.
  - Acceptance: resolve code binds, mouse buttons, Lua descriptions/dispatchers, and cached records while retaining Quickshell search/direct dispatch.
  - Progress: copied Omarchy's code-key and mouse-button normalization into `hypr-keys` and expanded the existing `common.bind_direction_keys`/`common.bind_workspace_numbers` calls from source. The default output now has 92 rows, exactly matching live `hyprctl binds`; Omarchy output has 144 readable rows. Repo and installed self-tests plus live QML panel smoke pass. Cache/dispatch records remain deferred because the current panel is display-only and live Lua binds expose zero descriptions.
  - Validation: fixtures for normal/code/mouse/Lua/exec/sendshortcut binds, comparison with `hyprctl binds`, live search, and one harmless dispatch.
  - Stop: do not copy `omarchy-menu-select`, Walker UI, or Omarchy-only Lua assumptions.

- [ ] P2: Enable PluginRegistry only after one copied panel proves the host contract.
  - Acceptance: replace static mounting for one proven panel with discovery, enable/disable, rescan, and persistence without behavioral change; third-party code stays disabled by default and explicitly unsandboxed.
  - Dependencies: Power or Display working from a copied manifest and entry point.
  - Validation: upstream registry/CLI tests, enable-disable-rescan, restart persistence, `listPlugins`, full menu smoke, and CPU/RSS comparison.
  - Stop: no bar layout registry, catalog installer, or arbitrary-plugin claim until each supported kind has a loader.

- [ ] P1: Package local custom menus as portable Omarchy-compatible plugins.
  - Acceptance: each retained custom menu has a manifest, stable plugin id, standard entry point, explicit settings, and no dependency on `shell.qml` internals. The same plugin directory loads from this shell and an unmodified Omarchy host.
  - Progress: the copied `omarchy.emojis` directory proves the unmodified schema-1 manifest and standard overlay entry-point package against local validation. Its manifest and search engine remain byte-identical to Omarchy `f32ebbd`, and the dataset differs only by the repository-required trailing newline; QML differs only by an injectable data path and direct `wl-copy`. A retained local custom menu still needs migration before this task can close.
  - Dependencies: shared host adapter and one copied first-party panel proving the contract; migrate one small local menu before the rest.
  - Validation: manifest validation, `qmllint`, enable/disable/rescan in both hosts, IPC summon/close, screenshots, and one-process checks.
  - Stop: no duplicate host variants, local-only manifest extensions, or migration of panels scheduled for Omarchy replacement.

- [ ] P2: Deprecate the local Settings panel as plugin-owned settings replace it.
  - Acceptance: remove Settings from the bar now; keep its IPC route until primary color, density, weather location, wallpaper, DND, tray, and launcher preferences have an owning plugin or Omarchy setting surface. Then archive the panel without losing persisted values.
  - Dependencies: portable plugin settings contract and selected Image Picker/Weather replacements.
  - Validation: settings-state migration fixture, `qbar settings` compatibility before removal, full menu smoke, and restart persistence.
  - Stop: do not delete settings state or the panel while any active feature still depends on it.
