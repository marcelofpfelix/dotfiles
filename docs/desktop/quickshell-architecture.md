# Quickshell Architecture

This shell stays small by keeping ownership boring and visible.

## Ownership

- `shell.qml` owns top-level windows, IPC endpoints, live service instances, and cross-panel state.
- `ShellBar.qml` owns only the bar layout.
- `Shell*Panel.qml` files own menu bodies.
- `Shell*Service.qml` files own filtering, ranking, parsing, and backend-specific state.
- `ShellConfigData.qml` owns static ids, aliases, built-in menu/action routing, menu sizes, menu rows, labels, and command data.
- `ShellConfig.qml` owns helper functions that turn config data into commands.
- `ShellTheme.qml` owns fonts, colors, spacing, radii, and shared dimensions.
- `Commons/`, `Ui/`, and `plugins/menu/` are copied Omarchy Quattro foundation
  modules. Keep them close to upstream; local changes are limited to documented
  Qt compatibility, registry lifecycle, palette, and command adapters.
- `omarchy-menu.jsonc` owns the Ubuntu-safe root-menu catalog. The copied menu
  engine owns hierarchy, search, aliases, guards, providers, and navigation.
- `services/AppSearch.js` and `services/AppLibrary.qml` own the shared desktop
  application catalog, filtering, icon lookup, and launch path used by both the
  copied root menu and `Win+D`. Launcher MRU/MFU, favorites, and command mode
  remain in `ShellLauncherService.qml` because Omarchy does not provide them.
- Copied `Ui/TextField.qml` owns search-input styling for launcher, clipboard,
  passmenu, web search, and keybindings. Panels add only local palette/font
  values and behavior-specific native Qt key handlers.
- Copied `Ui/Button.qml` owns action-button rendering, hover/pressed/focus
  states, tooltips, and left/right clicks. `ShellActionButton.qml` is only a
  compatibility adapter for the existing property and signal names.
- Copied `Ui/BorderSurface.qml` and `Commons/Border.qml` own border routing and
  geometry for `ShellFrame`, `ShellSection`, and `ShellStateBox`; those local
  components retain only layout and Catppuccin role mapping.
- `~/.local/state/quickshell/marcelof/settings.json` owns user-selected shell theme state such as primary color, density, weather location, wallpaper path, and fixed appearance/font tokens.
- `desktop/lib/lib_qs_menus.sh` owns the shell menu registry for scripts.
- `desktop/bin/qbar` owns Quickshell lifecycle and IPC entrypoints.
- `desktop/tools/*` owns validation, screenshots, smoke tests, and agent-only checks.

## IPC Direction

The current shell is Quickshell-owned and scriptable through `qbar`. The
canonical menu control target is `shell`: `ping`, `toggle`, `hide`, and
`summon` route through one panel lifecycle and the shared menu registry.
`ShellPopup.qml` and `ShellFloatingPopup.qml` expose the same visibility verbs;
anchored popups delegate mutations back to the root registry to preserve QML
bindings.
The root menu is the copied `plugins/menu/Menu.qml`, not a parallel local menu.
Its engine and model remain upstream code while `shell.qml` injects the local
theme and routes lifecycle through the existing `shell` IPC registry.
`listPlugins` and `listShellConfig` expose read-only Omarchy-compatible
inspection of those built-ins. Keep older `bar` and panel-specific IPC calls
only where they are already stable compatibility shims. Do not copy a full
third-party plugin manager until a reviewed plugin has a concrete dependency
set worth supporting.

## Boundaries

QML panel files should render state and call named helpers. They should not embed shell command arrays, app paths, menu geometry, static action rows, theme colors, or user-tunable values.

Quickshell consumes system facts from local helpers such as `board`, `audioctl`, `network-status`, `check-time-panel`, `calendar-agenda-status`, and privacy/status scripts. It should not parse private finance, calendar credentials, browser internals, or health exports directly.

Board owns health/status collection and text rendering for reusable surfaces. Quickshell only displays those rendered surfaces or calls narrow board commands.

## Archive Rule

X11-era files stay under `archive/x11/desktop/` or `archive/obsolete/desktop/` when retired. They are history, not an active fallback, and `home -y` should not deploy them.

## Reference Rule

Use reference repos for behavior, layout patterns, and small implementation ideas. Upstream runtime command names are allowed only when they remove local glue and stay wrapped by local entrypoints such as `qbar`. Do not import broad framework rewrites, distro update machinery, or assumptions that fight the default i3-compatible profile.

## Do Not Abstract

Do not add a new helper just because two files share one line. Move code only when it removes real duplication, keeps `shell.qml` focused on root wiring, or makes menu behavior testable from one place.
