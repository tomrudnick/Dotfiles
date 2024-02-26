#!/bin/sh
player="$1"
volume="$2"
playerSinkIndexes="$(pactl list sink-inputs |  awk '/application.name |object.serial / {print $0};' | grep -iA 1 "$player" | awk '/object.serial/ {print $3}' |  sed 's/"//g' )"  # get specific app sink

if [ -n "$playerSinkIndexes" ]; then
    for playerSinkIndex in $playerSinkIndexes; do
        pactl set-sink-input-volume "$playerSinkIndex" "$volume"
    done
fi

