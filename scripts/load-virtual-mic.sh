#!/bin/sh

module_file="/tmp/pulseaudio_module_list.txt"

pactl load-module module-null-sink sink_name=virtual_output sink_properties=device.description="virtual_output" | tee -a "${module_file}"
pactl load-module module-null-sink sink_name=virtual_output_2 sink_properties=device.description="virtual_output_2" | tee -a "${module_file}"
pactl load-module module-loopback sink_dont_move=true sink=virtual_output_2 latency_msec=1 | tee -a "${module_file}"
pactl load-module module-loopback sink_dont_move=true sink=virtual_output_2 source=virtual_output.monitor latency_msec=1 | tee -a "${module_file}"
pactl load-module module-loopback sink_dont_move=true source=virtual_output.monitor latency_msec=1 | tee -a "${module_file}"
pactl load-module module-virtual-source source_name=VirtualMic master=virtual_output_2.monitor source_properties=device.description=Virtual-Microphone | tee -a "${module_file}"


echo "$(tac ${module_file})" > $module_file
