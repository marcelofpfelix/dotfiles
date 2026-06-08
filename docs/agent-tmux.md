# tmux Agent Monitor

`agent-tmux` is the Bash-first monitor for Codex, Claude Code, OpenCode, and
Hermes panes. It gives the tmux pieces of cmux/herdr-style agent visibility
without requiring a separate app or plugin yet.

## Current Scope

- Discover tmux panes whose foreground command is `codex`, `claude`,
  `claudecode`, `opencode`, or `hermes`.
- Classify each pane as `running`, `free`, `blocked`, or `dead`.
- Show a compact tmux status module with `agent-tmux bar`.
- Show the full pane list with prefix `A` or `agent-tmux status`.
- Switch to an agent pane with prefix `A`, `agent-tmux switch`, or
  `agent-tmux focus %pane_id`.
- Open an agent in a consistently named tmux window with `agent-tmux open`.
- Reuse an existing `agent-tmux open` window for the same agent/path unless
  `--new` is passed.
- Restart panes launched with `agent-tmux open`.
- Notify on selected state transitions with `agent-tmux notify`. The default is
  `blocked` only.
- Cache bar scans for `AGENT_TMUX_CACHE_TTL` seconds. The default is 5 seconds.
- Accept native lifecycle events with `agent-event`, and overlay those states
  onto matching tmux panes by exact cwd or repo root.
- Show hook-derived duration in `status`, `switch`, notifications, and compact
  `bar` output when available.
- Show a padded colored state marker next to tmux window names through
  `agent-tmux window-icon`.
- Send hook-derived notifications directly from `agent-event`, without waiting
  for the next tmux status refresh.
- Explain state decisions with `agent-tmux why %pane_id`.
- Group by session or repo.
- Check setup with `agent-tmux doctor`.

## State Model

- `blocked`: recent pane text contains actionable approval/permission prompt
  UI, such as `do you want to allow`, `allow ...?`, `choose an option`,
  `yes/no`, or `y/n`.
- `running`: pane output changed since the last scan, or it has not yet crossed
  the idle threshold.
- `free`: pane output has not changed for `AGENT_TMUX_IDLE_SECONDS`.
  Explicit ready prompts can also be matched with `AGENT_TMUX_FREE_RE`.
- `dead`: tmux reports the pane as dead.

The default idle threshold is intentionally conservative at 45 seconds. Override
it per host or session:

```bash
AGENT_TMUX_IDLE_SECONDS=90 agent-tmux bar
AGENT_TMUX_BAR_MODE=counts agent-tmux bar
AGENT_TMUX_CACHE_TTL=5 agent-tmux bar
AGENT_TMUX_FREE_RE='ready|type a message' agent-tmux status
```

If an agent CLI runs through a wrapper and the pane is not detected,
`agent-tmux why %pane_id` shows the tmux command and process lines used by the
detector. Extend `AGENT_TMUX_AGENT_RE` or `AGENT_TMUX_AGENT_ARG_RE` locally for
host-specific process names.

## Commands

```bash
agent-tmux status   # table view
agent-tmux status --cached --state blocked
agent-tmux status --group repo
agent-tmux group session
agent-tmux group repo
agent-tmux bar      # tmux-formatted compact status with severity exit code
agent-tmux bar-plain # compact status text without tmux formatting
agent-tmux window-icon dev:2 # icon for one tmux window's agent state
agent-tmux focus %91 # focus a specific pane id
agent-tmux switch   # pick an agent pane with fzf/gum and focus it
agent-tmux open codex ~/git/repo # open or reuse an agent window
agent-tmux open --new --name codex:repo --session dev codex ~/git/repo
agent-tmux restart %91 # restart a pane launched by agent-tmux open
agent-tmux keys     # show switcher key bindings
agent-tmux notify   # one notification pass
agent-tmux notify-test # send a test desktop/terminal notification
agent-tmux notify-debug # show notifier config/state
agent-tmux why %91  # explain classification for a pane id
agent-tmux doctor   # check dependencies and command availability
agent-tmux cache-clear # clear cached scan and pane state
agent-tmux watch    # repeated notification loop
check-agents        # tbar/polybar-compatible wrapper
```

`why` redacts bearer-style tokens from process arguments before printing them.

## Native Hook Events

`agent-event` is the repo-local hook target for Codex, Claude Code, and
OpenCode lifecycle events. It reads optional JSON from stdin and writes
normalized event state to:

```bash
${XDG_CACHE_HOME:-~/.cache}/agent-tmux/event-state.tsv
${XDG_CACHE_HOME:-~/.cache}/agent-tmux/events.jsonl
```

It stores metadata only: agent, event, cwd, state, timestamps, duration, and a
short redacted message when the hook provides one. It does not store raw prompts
or full hook payloads.

State mapping:

- `PermissionRequest`: `blocked`.
- `Notification`: `blocked` only when the message looks like approval,
  permission, or confirmation; otherwise `free`.
- `UserPromptSubmit`, `PreToolUse`, `PostToolUse`, `SubagentStart`: `running`.
- `Stop`: `free`.

`agent-tmux status`, `bar`, `notify`, `switch`, and `why` use native hook state
when the event agent and cwd or repo root match the tmux pane. Pane text
heuristics remain the fallback. Native event state expires after
`AGENT_TMUX_EVENT_MAX_AGE`, default 12 hours.

When hook metadata is available, `status` and `switch` show state labels such as
`blocked(2m)`, and compact `bar` output appends the highest-priority state age.

Commands:

```bash
agent-tmux events       # show latest native hook state
agent-tmux events-clear # clear only native hook state/log
agent-tmux cache-clear  # clear scan, pane idle, and hook state
```

Manual test:

```bash
printf '{"message":"waiting for approval","cwd":"%s"}\n' "$PWD" \
  | agent-event codex PermissionRequest
agent-tmux events
agent-tmux status --fresh --agent codex
agent-tmux events-clear
```

### Source Config Files

Portable source config now lives under:

- `/home/marcelof/git/marcelofpfelix/homework/workdesk/.codex/hooks.json`
- `/home/marcelof/git/marcelofpfelix/homework/workdesk/.codex/config.toml.example`
- `/home/marcelof/git/marcelofpfelix/homework/workdesk/.claude/settings.json`
- `/home/marcelof/git/marcelofpfelix/homework/workdesk/.claude/hooks/agent-tmux-event.sh`
- `/home/marcelof/git/marcelofpfelix/homework/workdesk/.config/opencode/plugins/agent-tmux.ts`

Those source files can be synced into `~/.codex`, `~/.claude`, and
`~/.config/opencode` when you want native event capture active. Codex supports
both `hooks.json` and inline `[hooks]` config; Claude discovers hooks through
`settings.json` while the command lives in `.claude/hooks/`; OpenCode uses a
separate `agent-tmux.ts` plugin and leaves the RTK plugin untouched.

Dry-run the source-to-home sync:

```bash
/home/marcelof/git/marcelofpfelix/homework/workdesk/bin/sync-agent-monitor-config
```

Apply it only when you want those source files copied into `~/`:

```bash
/home/marcelof/git/marcelofpfelix/homework/workdesk/bin/sync-agent-monitor-config --apply
```

The helper backs up existing destination files before overwriting them. It does
not copy `.codex/config.toml.example`; merge that manually with the real local
Codex config.

Switcher keys when using `fzf`:

- `Enter`: focus the selected pane.
- `Ctrl-r`: refresh the pane list.
- `Ctrl-e`: send Enter to the selected pane, then focus it.
- `Ctrl-n`: rename the selected pane's window.
- `Ctrl-k`: ask for confirmation, then kill the selected pane.
- `Ctrl-y`: copy pane id and path to the tmux buffer.
- `Ctrl-w`: open the selected pane's path in a new tmux window.
- `Ctrl-x`: restart panes launched by `agent-tmux open`.

The `fzf` switcher sorts `blocked`, `running`, `free`, then `dead`, and shows a
preview of the selected pane's recent output.

Notification controls:

```bash
agent-tmux notify-test
AGENT_TMUX_NOTIFY_STATES=blocked,dead agent-tmux notify
AGENT_TMUX_NOTIFY_COOLDOWN=600 agent-tmux notify
AGENT_TMUX_NOTIFY=notify-send agent-tmux notify
AGENT_TMUX_NOTIFY=telemsg agent-tmux notify
AGENT_TMUX_EVENT_NOTIFY=0 agent-event codex PermissionRequest
```

`AGENT_TMUX_NOTIFY=auto` is the default. It tries `notify-send`,
`terminal-notifier`, then `telemsg`. Hook notifications use the same
`AGENT_TMUX_NOTIFY`, `AGENT_TMUX_NOTIFY_STATES`, and
`AGENT_TMUX_NOTIFY_COOLDOWN` controls. `AGENT_TMUX_EVENT_NOTIFY=0` disables
direct notifications from `agent-event`; then `agent-tmux notify` can still
notify on later tmux refreshes.

Bar modes:

```bash
AGENT_TMUX_BAR_MODE=compact agent-tmux bar # agent:10 blocked:1
AGENT_TMUX_BAR_MODE=counts agent-tmux bar  # icon counts by state
AGENT_TMUX_BAR_MODE=agents agent-tmux bar  # codex:10/1
AGENT_TMUX_BAR_MODE=sessions agent-tmux bar # dev:9/1
AGENT_TMUX_BAR_MODE=repos agent-tmux bar    # dotfiles:1 tel-proxy:2
```

Open controls:

```bash
agent-tmux open codex ~/git/repo
agent-tmux open claude ~/git/repo
AGENT_TMUX_OPEN_SESSION=dev agent-tmux open opencode ~/git/repo
agent-tmux open hermes ~/git/repo
AGENT_TMUX_OPEN_NAME=agent:repo agent-tmux open codex ~/git/repo
agent-tmux open --new codex ~/git/repo
agent-tmux open --session dev --name codex:repo codex ~/git/repo
agent-tmux restart %91
```

## tmux Integration

`desktop/.tmux.conf` appends this to `status-right`:

```tmux
#(agent-tmux notify >/dev/null 2>&1; agent-tmux bar)
```

That makes normal tmux status refreshes drive both visibility and transition
notifications. Window titles render a state icon through:

```tmux
#(agent-tmux window-icon #{session_name}:#{window_index})#W
```

The default window marker is a tmux-colored `● ` to avoid Nerd Font width issues
overlapping the window name. Set `AGENT_TMUX_WINDOW_ICON_STYLE=nerd` to use the
older Nerd Font symbols.

Prefix `A` opens the interactive switcher. Prefix `M-A` opens the read-only
status popup. Prefix `E` opens the native hook event popup.

This is not currently packaged as a TPM plugin. Keeping it as repo-local scripts
is lower friction while the behavior is still moving. A plugin package would be
worth doing only when the config surface is stable enough to install elsewhere.
Generic pane-completion plugins such as `rickstaa/tmux-notify` are useful for
long-running shell commands, but they do not replace this monitor's agent-aware
blocked/running/free states, repo grouping, hook metadata, or switcher.

## Backlog Decisions

Implemented from the high-value list:

- State accuracy tooling: stricter agent detection, `AGENT_TMUX_FREE_RE`, and
  `agent-tmux why`.
- Reliable notifications: `auto` notifier fallback, cooldowns,
  `notify-test`, and `notify-debug`.
- Cached bar/status path through `AGENT_TMUX_CACHE_TTL` and `cache-clear`.
- Interactive popup switcher with preview, sorting, focus, send Enter, rename,
  kill, copy, open path, and restart actions.
- Direct focus by pane id.
- Pretty tmux bar modes.
- Padded colored state marker next to tmux window names.
- Launch/reuse helper and restart metadata.
- Grouping by session/repo.
- Setup diagnostics through `agent-tmux doctor`.
- Native hook event bridge with state overlay and duration metadata.
- Repo-root event matching, so panes in subdirectories can use hook events from
  the same repository.
- Duration hints in `status`, `switch`, compact `bar`, and notifications.
- Native hook event popup with prefix `E`.
- Dry-run/apply sync helper in `homework/workdesk`.
- Event-triggered notification directly from `agent-event` without waiting for a
  tmux status refresh.
- Hermes pane detection.

Won't do for this Bash/tmux tool:

- Cross-host aggregation.
- Full TUI dashboard.
- tmux plugin packaging.
- SQLite job database before native hooks exist.
- Web dashboard.
