# Pomodoro And Timewarrior Design

Goal: add a small Pomodoro surface to the existing Quickshell calendar popup without putting timer logic, task descriptions, or Timewarrior parsing in QML.

## Current Tools

- `task 2.6.2` is installed and already feeds `check-todo-panel`.
- `timew 1.7.1` is installed.
- `desktop/bin/doit` is an older Timewarrior bar helper, but it depends on legacy helpers and is not the right integration point for Quickshell.

## Minimal Shape

Helper: `desktop/bin/pomodoroctl`.

Commands:

- `pomodoroctl status`: print redacted JSON for QML.
- `pomodoroctl start [--task UUID|--label TEXT]`: start a 25 minute focus interval.
- `pomodoroctl pause`: pause the local Pomodoro countdown only.
- `pomodoroctl resume`: resume the local countdown.
- `pomodoroctl stop`: stop the local countdown and, if started by this helper, stop the matching Timewarrior interval.
- `pomodoroctl break [short|long]`: start a 5 or 15 minute break.
- `pomodoroctl self-test`: test state transitions with a temp state directory.

State:

- `${XDG_STATE_HOME:-$HOME/.local/state}/quickshell/marcelof/pomodoro.json`
- Store only timer state, timestamps, optional Taskwarrior UUID, and a short display label.
- Do not store task notes, annotations, URLs, or secrets.

JSON for QML:

```json
{
  "schema": 1,
  "mode": "focus",
  "running": true,
  "paused": false,
  "remaining_seconds": 1120,
  "label": "current task",
  "task_uuid": "redacted-or-empty",
  "timew": {"available": true, "tracking": true, "owned": true}
}
```

## Quickshell Surface

Add a compact block to the existing calendar popup:

- Focus label.
- Remaining time.
- Start, pause/resume, stop.
- Optional task picker link: open `hypr-term task next` first; a richer picker can come later.
- Optional Timewarrior state line: `tracking`, `not tracking`, or `unavailable`.

QML must only call `pomodoroctl` and render its JSON. It must not call `task`, `timew`, or parse task descriptions directly.

## Timewarrior Boundary

Use Timewarrior only when available.

- On focus start with a task UUID, run `timew start pomodoro task:<uuid>`.
- On focus start without a task UUID, run `timew start pomodoro`.
- On pause, do not mutate Timewarrior; pause is local countdown state.
- On stop, run `timew stop` only if the active interval was started by `pomodoroctl`.

This avoids accidentally stopping unrelated manual tracking.

## Validation

- `pomodoroctl self-test`
- `pomodoroctl status` with no active state
- `pomodoroctl start --label test`, `pause`, `resume`, `stop`
- `qs-menu-smoke calendar`
- `desktop-doctor`
