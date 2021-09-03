#!/bin/bash
#######################
##### ROOT ACCESS #####
#######################
if [ $EUID != "0" ]; then
	echo "Must be run as root!" 1>&2
	#exit 1
	if [ -t 1 ]; then
		exec sudo -- "$0" "$@"
	else
		exec gksudo -- "$0" "$@"
	fi
fi
