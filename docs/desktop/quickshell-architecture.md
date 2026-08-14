# Quickshell Architecture

This shell stays small by keeping ownership boring and visible.

## Ownership

- `shell.qml` owns top-level windows, IPC endpoints, live service instances, and cross-panel state.
- `ShellBar.qml` owns only the bar layout.
- `Shell*Panel.qml` files own menu bodies.
- `Shell*Service.qml` files own filtering, ranking, parsing, and backend-specific state.
- `ShellConfigData.qml` owns static ids, menu sizes, menu rows, labels, and command data.
- `ShellConfig.qml` owns helper functions that turn config data into commands.
- `ShellTheme.qml` owns fonts, colors, spacing, radii, and shared dimensions.
- `desktop/lib/lib_qs_menus.sh` owns the shell menu registry for scripts.
- `desktop/bin/qs-bar` owns Quickshell lifecycle and IPC entrypoints.
- `desktop/tools/*` owns validation, screenshots, smoke tests, and agent-only checks.

## IPC Direction

The current shell is Quickshell-owned and scriptable through `qs-bar`, but its
canonical control target is still mostly `bar` plus a few panel-specific IPC
targets. The next improvement is a small local `shell` IPC target that routes
`ping`, `toggle`, `hide`, and `summon` to existing menus. Do not copy a full
third-party plugin manager until local built-in menu/widget routing is too
large to keep declarative.

## Boundaries

QML panel files should render state and call named helpers. They should not embed shell command arrays, app paths, menu geometry, static action rows, theme colors, or user-tunable values.

Quickshell consumes system facts from local helpers such as `board`, `audioctl`, `network-status`, `check-time-panel`, `calendar-agenda-status`, and privacy/status scripts. It should not parse private finance, calendar credentials, browser internals, or health exports directly.

Board owns health/status collection and text rendering for reusable surfaces. Quickshell only displays those rendered surfaces or calls narrow board commands.

## Archive Rule

X11-era files stay under `archive/x11/desktop/` or `archive/obsolete/desktop/` when retired. They are history, not an active fallback, and `home -y` should not deploy them.

## Reference Rule

Use reference repos for behavior, layout patterns, and small implementation ideas. Do not import upstream-branded binaries, broad framework rewrites, distro update machinery, or assumptions that fight the default i3-compatible profile.

## Do Not Abstract

Do not add a new helper just because two files share one line. Move code only when it removes real duplication, keeps `shell.qml` focused on root wiring, or makes menu behavior testable from one place.
