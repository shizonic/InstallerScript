#!/bin/bash

contains_element() {
	for e in "${@:2}"; do [[ $e == $1 ]] && break; done;
	}

	select_device(){
		devices_list=(`lsblk -lnp | awk '{print $1}'`);
		PS3="Hello: "
		echo -e "Attached Devices:\n"
		lsblk -lnp -I 2,3,8,9,22,34,56,57,58,65,66,67,68,69,70,71,72,91,128,129,130,131,132,133,134,135 | awk '{print $1,$4,$6,$7}'| column -t
		echo -e "\n"
		echo -e "Select device to partition:\n"
		select device in "${devices_list[@]}"; do
			contains_element "${device}" "${devices_list[@]}" && Devices=$device && break
		done
		echo $Devices
	}
	select_device
