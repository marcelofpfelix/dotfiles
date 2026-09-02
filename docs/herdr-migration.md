# Herdr migration plan

## Current state

- Herdr 0.8.2 and the Sessionizer 0.8.0 plugin are installed.
- The running Herdr server is 0.8.2 and protocol-compatible with the client.
- Sessionizer is configured as a non-destructive project/worktree picker over
  `~/gwt/*/*` and `~/git`. Repositories opt into pane layouts with a checked-in
  `.sessionizer/config.toml`.
- A Sessionizer smoke test reproduced the existing four-column by two-row pane
  tree using named `from` panes and split ratios.
- `tmx` and its `dash6`/`dash8` profiles remain the active telecom dashboard
  path. They depend on runtime service/server selection and should not be
  replaced by a global Sessionizer project layout.

## Status and tab-bar options

Use the smallest surface that fits the data:

1. Herdr's native `ui.tab_bar_right` is the preferred tmux-style bar. It shows
   Board's cached `tmux-top` surface plus zoom and datetime. The hostname is
   already in the window title and is omitted here so status fits narrow panes.
2. Herdr sidebar metadata (`$name` tokens) is better for multi-line or
   per-workspace/per-pane data. The existing `local.script-status` plugin
   already implements this path, but is currently disabled.
3. A Herdr popup or temporary pane is better for detailed, on-demand status
   that does not fit on one line.
4. `ui.window_title` should contain only stable context such as host, workspace,
   and tab; it is not a metrics surface.

Do not execute independent health scripts directly from `tab_bar_right`.
Board owns collection and caching; Herdr renders that state every 30 seconds
with a 10-second timeout. Herdr clears command output on failure, empty output,
or timeout.

## Unified entry point

`mux` is the maintained Herdr-first entry point. It leaves `tmx`, `tmuxa`,
`tmxx`, tmuxp, and their existing workflows intact while the dashboard moves
across:

```sh
mux                         # start or attach to Herdr
mux attach <label>          # focus or create a named workspace
mux window <label>          # create a tab
mux dashboard us-prod       # focus or create a dynamic server dashboard
mux dashboard --dry-run us-prod
mux dashboard --replace us-prod
```

The private homework-rendered `~/lib/lib_tmx.sh` remains the single source of
service, profile, and ordered server-alias data. `mux` consumes that data and
uses Herdr CLI operations to build the layout; it does not copy target maps to
public dotfiles or Sessionizer configuration.

## Implementation tasks

### 1. Activate and smoke-test Sessionizer

Acceptance criteria:

- Restart Herdr only after its existing panes are disposable.
- `prefix+f` opens the project picker and lists the configured worktrees.
- `prefix+Up` opens the worktree picker.
- Opening an existing workspace does not reapply or destroy its layout.

Validation:

```sh
herdr status server
herdr plugin list
herdr config check
```

Stop gate: do not run `herdr server stop` while any pane process must survive.

### 2. Separate dashboard data from dashboard execution

Move service selection and the `SERVER_1` through `SERVER_4`/profile mapping
behind backend-neutral functions in the managed homework template that
currently produces `~/lib/lib_tmx.sh`. Keep secrets and host data out of this
public dotfiles repository.

Acceptance criteria:

- One selector returns the same service, environment, server list, and profile
  for both backends.
- Existing `tmx us-prod` behavior is unchanged with `MUX_BACKEND=tmux`.
- Invalid or incomplete targets fail before opening or closing panes.

Validation: shell tests with fixed fixture maps; no SSH connection required.

### 3. Add the Herdr dashboard adapter

Implement the `mux dashboard` Herdr adapter with Herdr CLI operations or a
small dedicated plugin.
Use named pane anchors so `dash6` and `dash8` retain their exact 3x2 and 4x2
trees. Sessionizer remains responsible for project/worktree picking; it should
not own the dynamic telecom target map.

Acceptance criteria:

- `mux dashboard us-prod` creates one named workspace/tab with the same server
  ordering as `dash8`.
- Re-running prompts before closing/replacing a dashboard containing live
  processes.
- A dry-run prints the target, commands, pane anchors, directions, and ratios.
- No command is sent to the production hosts during automated tests.

Validation: mocked Herdr CLI test followed by an isolated local-shell layout
smoke test. Live SSH is a separate approval gate.

### 4. Use Board as the backend-neutral status renderer

Board consumes cached check state and emits one line. Use its `tmux`,
`terminal`, or `plain` renderer only for formatting; collection remains
independent. `tbar` is retained as a thin compatibility adapter for tmux users.
Herdr uses the terminal renderer with `--color never`, so Nerd Font icons stay
available without ANSI escape sequences. On macOS the memory check runs the
existing `check-mem` command through Board because the native IOReport sampler
is not available in the current desktop session; Board still owns scheduling,
health state, caching, and rendering.

Acceptance criteria:

- Herdr output contains no tmux format sequences and fits on one line.
- Tmux output stays compatible with the current Catppuccin status command.
- Missing cache, stale cache, and individual check failures return concise
  output within two seconds.
- Agent-tmux is not reintroduced.

Validation:

```sh
board render --format plain --surface tmux-top
board render --format terminal --surface tmux-top --color never
board render --format tmux --surface tmux-top
```

### 5. Connect the native Herdr tab bar

The native command entry reads Board's shared `tmux-top` surface without ANSI
colors:

```toml
{ type = "command", command = "PATH=/opt/homebrew/bin:$HOME/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin board render --format terminal --surface tmux-top --color never", interval_seconds = 30, timeout_seconds = 10 }
```

`tbar` defaults to Board's tmux renderer for compatibility and maps
`--format herdr` to Board's no-color terminal renderer. The explicit path locates the
installed Board binary. Keep the existing zoom and datetime entries; omitting
hostname leaves enough width for the status surface in a typical split pane.

## Rollback

Existing `tmx`, `tmuxa`, and tmuxp workflows remain available. `mux dashboard`
focuses an existing dashboard by default and requires `--replace` to close and
recreate it. Keep the legacy tools until the Herdr adapter has passed the same
target/profile tests and a manual SSH smoke test; no removal is implied.
