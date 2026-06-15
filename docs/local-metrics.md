# Local Script Metrics

`lib_status.sh` writes Prometheus textfile-compatible metrics when scripts call
`update_status` or `report_check_status`.

Default output:

```sh
${XDG_STATE_HOME:-$HOME/.local/state}/script-metrics/*.prom
```

Override the directory for node_exporter or another local service exporter:

```sh
export PROM_TEXTFILE_DIR=/var/lib/node_exporter/textfile_collector
```

or:

```sh
export SCRIPT_METRICS_DIR=$HOME/.cache/script-metrics
```

Core metrics:

- `local_script_status{script="..."}`: last status code.
- `local_script_ok{script="..."}`: `1` when status is `0`, otherwise `0`.
- `local_script_last_run_timestamp_seconds{script="..."}`: last run time.
- `local_script_status_info{script="...",message="..."}`: last message.

Check scripts can add script-specific gauges, for example CPU percent, memory
percent, Docker container counts, VPN state, and alert counts.
