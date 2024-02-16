#!/usr/bin/env bash

# Terminate already running bar instances
# If all your bars have ipc enabled, you can use
timeout 5 polybar-msg cmd quit
sleep 1
# Otherwise you can use the nuclear option:
#killall -q polybar
# check if polybar is running
if pgrep -x polybar >/dev/null; then
    echo "Polybar is running, killing it..."
    pkill -9 polybar
fi


# name should match the config
echo "---" | tee -a /tmp/polybar1.log # /tmp/polybar2.log
polybar main 2>&1 | tee -a /tmp/polybar1.log & disown
# polybar bar2 2>&1 | tee -a /tmp/polybar2.log & disownpul

echo "Bars launched..."
