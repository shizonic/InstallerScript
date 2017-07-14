#!/bin/bash






# interactive using cgdisk
cgdisk "$DISK"
read -p "esp  partition: (default: /dev/sda1): " ESP_PART
read -p "root partition: (default: /dev/sda2): " ROOT_PART
read -p "home partition: (default: /dev/sda3): " HOME_PART
read -p "swap partition: (default: /dev/sda4): " SWAP_PART
# USE NULL TO AVOID that partition


# Non-interactive using parted(see documentation)
##
DISK=/dev/sda
ESP_END=250MiB
ROOT_END=20.25GiB
SWAP_END=22.25GiB
HOME_END=100%


# Create new gpt partition table ( deletes everything)
parted -s $DISK mklabel gpt
# Create ESP partition and make it bootable
parted -s $DISK mkpart ESP fat32 0% $ESP_END
parted -s $DISK set 1 boot on
# Create root partition
parted -s $DISK mkpart primary ext4 $ESP_END $ROOT_END
# Create swap partition
parted -s $DISK mkpart primary linux-swap $ROOT_END $SWAP_END
# Create home partition
parted -s $DISK mkpart primary ext4 $SWAP_END $HOME_END


# vim:ts=2 sw=2 et

