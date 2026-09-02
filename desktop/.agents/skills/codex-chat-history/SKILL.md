---
name: codex-chat-history
description: Explain how Codex stores and exposes local chats, session transcripts, prompt history, app logs, archived sessions, resume/fork/delete/archive behavior, and hook-based chat logging. Use only when explicitly invoked as $codex-chat-history or when the user directly asks about Codex conversation history, session files, transcript paths, chat logs, history persistence, or how to inspect, export, resume, archive, or delete Codex chats.
---

# Codex Chat History

Use this skill to answer Codex chat/session/history questions from the live machine first, then from current official docs when behavior may have changed.

## Read Order

1. Inspect live state before answering:

```sh
printf '%s\n' "${CODEX_HOME:-$HOME/.codex}"
fd -a . "${CODEX_HOME:-$HOME/.codex}/sessions" -d 5
fd -a . "${CODEX_HOME:-$HOME/.codex}/archived_sessions" -d 5
ls -lh "${CODEX_HOME:-$HOME/.codex}/history.jsonl" "${CODEX_HOME:-$HOME/.codex}/logs_2.sqlite" 2>/dev/null
```

2. Inspect the active user config when settings matter:

```sh
rg -n 'history|hooks|features|CODEX_HOME|sqlite_home' "${CODEX_HOME:-$HOME/.codex}/config.toml"
```

3. Use official Codex docs for current behavior around commands, config, hooks, and plugin packaging. Prefer the `openai-docs` skill or official docs only.

## Local Files

Treat these as likely locations, but verify them live:

- `CODEX_HOME`: defaults to `~/.codex`; stores config, auth, logs, sessions, skills, and package state.
- `~/.codex/sessions/YYYY/MM/DD/rollout-*.jsonl`: rich local session transcripts. These can include prompts, assistant messages, tool calls, command output, and metadata.
- `~/.codex/archived_sessions`: archived local sessions.
- `~/.codex/history.jsonl`: prompt/session history file when history persistence is enabled. Do not assume it is the complete transcript; inspect the shape.
- `~/.codex/logs_2.sqlite`: internal app/runtime logs, not the primary conversation transcript.
- `~/Library/Logs/com.openai.codex/YYYY/MM/DD`: macOS app logs when present.

Never dump raw transcript content unless the user explicitly asks and the scope is narrow. These files can contain secrets, private repo output, credentials pasted into prompts, and sensitive tool output.

## Useful Inspection Commands

Find recent session files:

```sh
fd -a 'rollout-.*\.jsonl' "${CODEX_HOME:-$HOME/.codex}/sessions" | sort | tail -n 20
```

Summarize a transcript without exposing message content:

```sh
jq -r '.type? // "no-type"' path/to/rollout.jsonl | sort | uniq -c
jq -r 'select(.type=="response_item") | .payload.type? // "unknown"' path/to/rollout.jsonl | sort | uniq -c
jq -r 'select(.type=="session_meta") | .payload | {id,session_id,cwd,timestamp,model_provider,source}' path/to/rollout.jsonl
```

Inspect prompt history shape without printing prompt text:

```sh
jq -r 'keys_unsorted | join(",")' "${CODEX_HOME:-$HOME/.codex}/history.jsonl" | sort | uniq -c
```

Inspect internal log DB shape and counts:

```sh
sqlite3 "${CODEX_SQLITE_HOME:-${CODEX_HOME:-$HOME/.codex}}/logs_2.sqlite" '.schema logs'
sqlite3 "${CODEX_SQLITE_HOME:-${CODEX_HOME:-$HOME/.codex}}/logs_2.sqlite" 'select level, count(*) from logs group by level order by count(*) desc;'
```

## Commands And Settings

Use these concepts when explaining user-facing session management:

- `/resume` or `codex resume`: continue a saved interactive session.
- `/fork` or `codex fork`: branch a session while preserving the original transcript.
- `/archive` or `codex archive`: remove a session from active lists without deleting its transcript.
- `/delete` or `codex delete`: permanently delete a saved session transcript.
- `/status`: inspect active session state.

History persistence:

```toml
[history]
persistence = "save-all" # default
max_bytes = 5242880      # optional cap; oldest records are dropped when exceeded
```

To disable local history persistence:

```toml
[history]
persistence = "none"
```

Do not change this setting unless the user asks to change retention behavior.

## Hook-Based Logging

For custom exports or searchable logs, prefer hooks over parsing files from shell prompts. Confirm hooks are enabled:

```toml
[features]
hooks = true
```

Hook events such as `UserPromptSubmit`, `Stop`, and `SessionEnd` can receive shared fields including `session_id`, `cwd`, and `transcript_path`. Use `transcript_path` as a convenience pointer, but mention that transcript file formats are not a stable hook API and may change.

Plugins can bundle lifecycle hooks. Recommend a plugin only when the logging behavior should be packaged and reused across machines; otherwise a user-level `~/.codex/hooks.json` or inline `~/.codex/config.toml` hook is simpler.

## Answering Style

When answering:

- Separate confirmed live findings from documented defaults.
- Include exact paths and commands the user can run.
- Say when a file may contain secrets before suggesting inspection commands.
- Prefer summaries and counts over printing transcript content.
- If docs were checked, cite the official docs URL used.
