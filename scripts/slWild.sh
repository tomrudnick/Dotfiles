#!/usr/bin/env bash
# Start sl in the background
SCRIPT_DIR="$(dirname "$0")"

sl &
SL_PID=$!

# Start your second command in the background
play "${SCRIPT_DIR}/thomas_tank_engine.mp3" > /dev/null 2>&1 &
MUSIC_PID=$!

# Wait for sl to finish
wait $SL_PID

# Kill the second command
kill $MUSIC_PID
