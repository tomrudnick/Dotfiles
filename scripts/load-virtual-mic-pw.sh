#!/bin/sh
MIC="alsa_input.usb-Logitech_PRO_X_000000000000-00.mono-fallback:capture_MONO"
SPEAKER_LEFT="alsa_output.usb-Logitech_PRO_X_000000000000-00.analog-stereo:playback_FL"
SPEAKER_RIGHT="alsa_output.usb-Logitech_PRO_X_000000000000-00.analog-stereo:playback_FR"

module_file="/tmp/pulseaudio_module_list.txt"


pactl load-module module-null-sink sink_name=virtual_output sink_properties=device.description="virtual_output" | tee -a "${module_file}"
pactl load-module module-virtual-source source_name=VirtualMic source_properties=device.description=Virtual-Microphone | tee -a "${module_file}"

sleep 2

pw-link $MIC input.VirtualMic:input_MONO

pw-link virtual_output:monitor_FL input.VirtualMic:input_MONO
pw-link virtual_output:monitor_FR input.VirtualMic:input_MONO

pw-link virtual_output:monitor_FL $SPEAKER_LEFT
pw-link virtual_output:monitor_FR $SPEAKER_RIGHT


