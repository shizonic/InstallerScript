#!/bin/bash
DISK=""

Attached_Disks=$(lsblk -d | awk '{print "/dev/" $1}' | grep 'sd\|hd\|vd\|nvme');
Booted_Disk=`df | grep 'sd\|hd\|vd\|nvme' | awk 'NR==1{print substr($1, 1, length($1)-1)}'`;
# if Attached_Disks ==2 then remove booted disk from that to get working disk

if [[ $(echo "${Attached_Disks[@]}" | wc -w) -eq 2 ]]; then
	DISK=`printf '%s\n' ${Attached_Disks[@]} | grep -v "$Booted_Disk"`
else
	echo ""
	echo "List of Disks: "
	printf '%s\n' "${Attached_Disks[@]}"
	echo ""
	read -r -p "Write device name: " DISK
fi
