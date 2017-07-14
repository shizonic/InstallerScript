#!/bin/sh

# Internet Connection Check
if ! [ "$(ping -c 1 8.8.8.8)" ]; then
	echo "Please check your internet connection"
	exit 1
fi
