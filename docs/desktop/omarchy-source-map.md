# Omarchy Shell Source Map

## Ownership

Upstream-derived code under `desktop/.config/quickshell/marcelof/`:

- foundation: `Commons/` and `Ui/`
- host services: `AppLibrary.qml`, `AppSearch.js`, `BarWidgetRegistry.qml`, and
  `PluginRegistry.qml`
- first-party plugins: all 37 built-ins shipped by the pinned release; optional
  plugins are installed but disabled in `shell.json`
- root host: `shell.qml`, heavily adapted for local ownership and routing

Local code:

- top-level `Shell*.qml`, `StatusText.qml`, and `omarchy-menu.jsonc`
- `marcelof.status-actions`, Board, media-controls, network-tools, and plugin
  manager plugins
- local plugin/service hosts and `ShellPluginConfig.qml`
- notification-center history UI and local calendar, screen, tray, dashboard,
  work-inbox, settings, and confirmation surfaces

Configuration and generated state:

- `desktop/.config/omarchy/shell.json`: tracked deployment default
- `~/.config/omarchy/shell.json`: live mutable layout and plugin enablement
- `~/.local/state/quickshell/marcelof/settings.json`: live local preferences
- `~/.local/state/omarchy/`: notification, indicator, and compatible plugin state
- Quickshell runtime directories under `$XDG_RUNTIME_DIR`: generated IPC/log data

## v4.0.6 Audit

Official release: `v4.0.6`, commit
`237f1b4071a0bff2296c6d740ba2b9fd695ebfa0`, published 2026-10-19.

Compared with the recorded base `1926611`:

- 105 managed files already match `v4.0.6`
- 35 files are clean old copies and can take the upstream version directly
- 32 files contain local adaptations and require a three-way merge
- 8 new host API files are explicitly selected in the lock file
- 36 files are local-only
- 3 non-plugin upstream files remain intentionally unselected
- no managed file was removed upstream

The current prepare pass reports conflicts in:

- `plugins/image-picker/ImagePicker.qml`
- `plugins/menu/Menu.qml`
- `plugins/notifications/NotificationLogic.js`
- `plugins/notifications/Service.qml`
- `plugins/notifications/components/NotificationCard.qml`
- `plugins/panels/monitor/Panel.qml`
- `plugins/panels/network/Panel.qml`
- `shell.qml`

All 37 built-in plugin manifests from the pinned release are tracked. Agents,
dev gallery, clock, disk speed test, Dropbox, network speed test, Tailscale,
weather, reminders, and battery are installed but listed in `disabledPlugins`;
they consume no bar slot and their QML is not loaded until explicitly enabled.
`importPrefixes` in the upstream lock keeps those complete plugin families in
future tagged-release comparisons.

## Upgrade Workflow

Inspect the latest stable tag without changing tracked source:

```sh
desktop/tools/omarchy-shell-upstream report latest
```

Build a temporary three-way-merged candidate:

```sh
desktop/tools/omarchy-shell-upstream prepare latest
```

Resolve and validate conflicts in the reported candidate first. `apply` is
allowed only when prepare has no conflicts or upstream removals and the managed
source is clean:

```sh
desktop/tools/omarchy-shell-upstream apply v4.0.6
python3 -m unittest desktop/tests/omarchy_shell_upstream_test.py \
  desktop/tests/quickshell_plugins_test.py desktop/tests/qbar_runtime_test.py
```

After deployment, run the live checks from `quickshell-runtime.md`. Commit the
source update and lock-file advance together. Do not run Omarchy's Arch package
migrations on Ubuntu.
