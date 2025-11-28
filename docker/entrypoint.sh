#!/usr/bin/env bash
set -e

# If no arguments are provided, run Isaac Sim with the default launcher script
if [ "$#" -eq 0 ]; then
    exec gosu isaac-sim /isaac-sim/python.sh ./src/andino_isaac/tools/isaac_launch_script.py
fi

# If arguments are provided, run them as a command (e.g. "bash")
exec gosu isaac-sim "$@"
