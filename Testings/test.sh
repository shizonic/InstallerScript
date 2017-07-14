#!/bin/bash

####### TODO $$$$$
## Partition_Manipulation to use menu
####### TODO $$$$$


###############################################################################
#                           Definitions                                       #
###############################################################################
UserName="burhan"
HostName="Extreme"
Groups=(wheel autologin media storage)

Mirror="Worldwide"
TimeZone="Asia/Dhaka"
Locale="en_GB.UTF-8"
KeyMap="us"
VirtualBox="guest"
Services=()

Disk=/dev/sda
ESP_PART=/dev/sda1
ROOT_PART=/dev/sda2
HOME_PART=/dev/sda3
SWAP_PART=/dev/sda4

DHCPOnCurrentInterface="yes"
BasePackages=(intel-ucode git)
Packages=(neovim iw wpa_supplicant dialog wget net-tools)
Packages+=(yaourt)
## OR you can define these values in the following file for easy reading
# source definitions.conf
# source packages.list

###############################################################################
#                           Redefine                                          #
###############################################################################

# Have correct keymap
loadkeys $KeyMap

## User Password
#
while true; do
	read -rsp "User password: " USER_PASSWORD
	echo
	read -rsp "Confirm password: " PASSWORD2
	echo
	[ "$USER_PASSWORD" = "$PASSWORD2" ] && break
	echo "Passwords don't match. Try again"
done

## Root Password
#
while true; do
	read -rsp "Root password: " ROOT_PASSWORD
	echo
	read -rsp "Confirm password: " PASSWORD2
	echo
	[ "$ROOT_PASSWORD" = "$PASSWORD2" ] && break
	echo "Passwords don't match. Try again"
done

# add comma in Groups
tmp=$(printf ",%s" "${Groups[@]}" )
Groups=${tmp:1}

# Enable Dhcp on the current active connection
if [ "$DHCPOnCurrentInterface" == "yes" ]; then
	tmp=$(iw dev | awk 'NR==2{print $2}')
	Services+=( dhcpcd@$tmp )
fi

# ( interactive )
## Hostname 
# read -rp "Enter Hostname: " HostName
## UserName 
# read -rp "Enter UserName: " UserName
# etc. etc. Set it yourself

###############################################################################
# Update system clock
#******************************************************************************
timedatectl set-ntp true


###############################################################################
#                           Partition                                         #
###############################################################################

contains_element() {
	for e in "${@:2}"; do [[ $e == "$1" ]] && break; done;
	}

	function re_check_partition {
		echo "";
		fdisk -l
		echo "
		**************************
		Verify Partitions
		**************************"
		echo "EFI System Partition=$ESP_PART
		Root Partition=$ROOT_PART
		Home Partition=$HOME_PART
		Swap Partition=$SWAP_PART
		"

		read -rp "Are You sure ? press enter" yes
	}

	function FindDisk {
		AttachedDisks=$(lsblk -d | awk '{print "/dev/" $1}' | grep 'sd\|hd\|vd\|nvme');
		BusyDisks=$(df | grep 'sd\|hd\|vd\|nvme' | awk 'NR==1{print substr($1, 1, length($1)-1)}');

		# if AttachedDisks ==2 then remove booted disk from that to get working disk
		if [[ $(echo "${AttachedDisks[@]}" | wc -w) -eq 1 ]]; then
			Disk=$(printf '%s\n' "${AttachedDisks[@]}")
		elif [[ $(echo "${AttachedDisks[@]}" | wc -w) -eq 2 ]]; then
			Disk=$(printf '%s\n' "${AttachedDisks[@]}" | grep -v "$BusyDisks")
		else
			PS3="Desired Device to Use: "
			echo ""
			echo "List of Disks: "
			echo ""
			select device in "${AttachedDisks[@]}"; do
				contains_element "${device}" "${AttachedDisks[@]}" && Disk=$device && break
			done
		fi
	}




	function Partition_Manipulation {
		FindDisk

		# interactive using cgdisk
		# USE EMPTY STRING TO AVOID that partition
		cgdisk "$Disk"
		fdisk -l

		tmp=""
		while [[ -z  $tmp ]]; do
			read -rp "esp  partition: (default: $ESP_PART): " tmp
			ESP_PART=$tmp; done
			tmp=""
			while [[ -z $tmp ]]; do
				read -rp "root partition: (default: $ROOT_PART): " tmp
				ROOT_PART=$tmp; done
				read -rp "home partition: (default: $HOME_PART): " HOME_PART
				read -rp "swap partition: (default: $SWAP_PART): " SWAP_PART

			}

			function Auto_Partition {
				FindDisk

				# Non-interactive using parted(see documentation)
				##
				ESP_END=250MiB
				#  ROOT_END=20.25GiB
				ROOT_END=100%
				SWAP_END=22.25GiB
				HOME_END=100%


				# Create new gpt partition table ( deletes everything)
				parted -s "$Disk" mklabel gpt
				# Create ESP partition and make it bootable
				parted -s "$Disk" mkpart ESP fat32 0% $ESP_END
				parted -s "$Disk" set 1 boot on
				# Create root partition
				parted -s "$Disk" mkpart primary ext4 $ESP_END $ROOT_END
				# Create swap partition
				#  parted -s $Disk mkpart primary linux-swap $ROOT_END $SWAP_END
				# Create home partition
				#  parted -s $Disk mkpart primary ext4 $SWAP_END $HOME_END

				ESP_PART=/dev/sda1
				ROOT_PART=/dev/sda2
				SWAP_PART=
				HOME_PART=
			}

			## Enable any of these three
			Auto_Partition
			re_check_partition
			#Partition_Manipulation

			###############################################################################
			#                           Format                                            #
			###############################################################################


			# Format ESP
			mkfs.fat -F32 $ESP_PART

			# Format Root
			mkfs.ext4 -L "Arch root" $ROOT_PART

			# If Home not empty String format HOME
			[[ !  -z  $HOME_PART ]] && 
			mkfs.ext4 -L "Arch home" $HOME_PART

			# If swap not empty String format swap
			[[ !  -z  $SWAP_PART ]] && 
			mkswap -L "Linux Swap" $SWAP_PART



			###############################################################################
			#                           Mount                                             #
			###############################################################################


			mount $ROOT_PART /mnt
			mkdir /mnt/boot /mnt/home
			mount $ESP_PART /mnt/boot

			[[ !  -z  $HOME_PART ]] && 
			mount $HOME_PART /mnt/home

			[[ !  -z  $SWAP_PART ]] && 
			swapon $SWAP_PART



			###############################################################################
			#                           Mirrors                                           #
			###############################################################################

			# This one activates all mirrors from a country, not based on speed or completeness
			function all_frm_spfc_cntry {
				local Destination=/etc/pacman.d/mirrorlist
				# vim in normal mode
				vim -s <(printf "/%s\n{}d\e:wq! %s\n" "$Mirror" "$Destination") <(curl -s https://www.archlinux.org/mirrorlist/all/)
			}

			# mirrorlist based on speed, not limited to specific country
			function mirrors_ranked {
				# Or use rankmirror
				wget -O /etc/pacman.d/mirrorlist.bak 'https://www.archlinux.org/mirrorlist/?country=all&protocol=http&protocol=https&ip_version=4&use_mirror_status=on'
				sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist.bak
				rankmirrors -n 8 /etc/pacman.d/mirrorlist.bak > /etc/pacman.d/mirrorlist
			}

			all_frm_spfc_cntry
			#mirrors_ranked

			###############################################################################
			#                     Install Base System And configure fstab                 #
			###############################################################################

			pacstrap /mnt base base-devel

			genfstab -U -p /mnt >> /mnt/etc/fstab
			echo "tmpfs                                   	/tmp    	tmpfs   	defaults,noatime,mode=1777	0 0" >> /mnt/etc/fstab




			read -rp "Continue" yes


			###############################################################################
			#                     Copy Previous stuff setup in runtime                    #
			###############################################################################

			#cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist
			## Export Previous Values to Installed system
			# ###IGNORED FOR NOW###


###############################################################################
#                          Chroot into Installed system                       #
###############################################################################


arch-chroot /mnt << 069StringFirst

# Set hostname
echo "$HostName" > /etc/hostname

# setup hosts file correctly
#echo "127.0.1.1	$HostName.localdomain	$HostName" >> /etc/hosts
sed -i "s/localdomain	localhost/& $HostName/" /etc/hosts
sed -i "/^::1/a 127.0.1.1	$HostName.localdomain	$HostName" /etc/hosts


# pacman.conf modify (enable multilib)
sed -i /etc/pacman.conf \
	-e '/\[multilib\]/{s/^#//;n;s/^#//}' \
	-e 's/^#Color/Color/' \
	-e '/^# Misc options/a ILoveCandy'

pacman -Syu

# Install BasePackages
pacman --noconfirm --needed -S ${BasePackages[@]}

# regenerate initrd image
mkinitcpio -p linux


# Setup bootloader (Systemd-boot)
bootctl install
# Add arch boot entry to list
cat > /boot/loader/entries/arch.conf <<EOF
title Arch Linux
linux /vmlinuz-linux
initrd /intel-ucode.img
initrd /initramfs-linux.img
options root=PARTUUID=$(blkid -s PARTUUID -o value $ROOT_PART) rw
EOF

# Make arch linux be the default in
cat > /boot/loader/loader.conf<<EOF
default Arch Linux
# timeout 3
EOF


# Locale Config
#
sed -i 's/^#en_GB\.UTF/en_GB\.UTF/' /etc/locale.gen
sed -i 's/^#en_US\.UTF/en_US\.UTF/' /etc/locale.gen

locale-gen
echo LANG=$Locale > /etc/locale.conf
echo LANGUAGE=en_GB:en_US >> /etc/locale.conf
echo LC_COLLATE=C >> /etc/locale.conf


# Set keymap
#echo "KEYMAP=$KeyMap" > /etc/vconsole.conf


# TimeZone config & sync hwclock to utc
ln -sf /usr/share/zoneinfo/$TimeZone /etc/localtime
hwclock --systohc --utc


# Set root password
echo "root:$ROOT_PASSWORD" | chpasswd

# Adding (Standard)user 
useradd -m -g users -G ${Groups[@]} -s /bin/bash $UserName
# Set user password
echo "$UserName:$USER_PASSWORD" | chpasswd
## Uncomment to allow members of group wheel to execute any command
sed -i '/%wheel ALL=(ALL) ALL/s/^#//' /etc/sudoers



# Temporary wheel no password
echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/99_wheel_group_nopass

# create autologin for Virtual Console
mkdir -p /etc/systemd/system/getty@tty1.service.d
cat > /etc/systemd/system/getty@tty1.service.d/override.conf <<EOF
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin $UserName --noclear %I \$TERM
EOF
069StringFirst




read -rp "Continue" yes




# Launch scriopt as soon as logged in as user
touch /mnt/home/$UserName/.bash_profile
chown ${UserName}:users /mnt/home/$UserName/.bash_profile

## Can't use login shell for user arch-chroot
cat >> /mnt/home/$UserName/.bash_profile<< 069StringSecond

sudo rm -rf /etc/systemd/system/getty@tty1.service.d
cd /home/$UserName

## Auto PGP
#
# Packages signature checking
mkdir .gnupg
echo "keyserver-options auto-key-retrieve" >> .gnupg/gpg.conf
echo "keyserver hkp://pgp.mit.edu" >> .gnupg/gpg.conf


# install AUR helper
##

mkdir building
cd building

###   Cower 
gpg --recv-keys --keyserver hkp://pgp.mit.edu 1EB2638FF56C0C53
git clone "https://aur.archlinux.org/cower.git"
cd cower
makepkg -sir

#      PacAUR
cd ..
git clone "https://aur.archlinux.org/pacaur.git"
cd pacaur
makepkg -sir
cd ../..
rm -rf building

#install AUR packages
pacaur -S --noconfirm --noedit --needed ${Packages[@]}

## if virtualbox setup related things , possible inputs are "host","guest","" (empty string)
if [[ !  -z  $VirtualBox ]];then
	if [ "$VirtualBox" == "guest" ]; then
		sudo pacman -S --noconfirm virtualbox-guest-utils virtualbox-guest-modules-arch
		sudo systemctl enable vboxservice
	elif [ "$VirtualBox" == "host" ]; then
		sudo pacman -S --noconfirm virtualbox-host-modules-arch virtualbox-guest-iso
		sudo gpasswd -a $UserName vboxusers
	fi
fi
sudo systemctl enable ${Services[@]}
rm -f /home/$UserName/.bash_profile
sudo rm /etc/sudoers.d/99_wheel_group_nopass
069StringSecond

echo "rebooting in 10 seconds"
sleep 10 && systemctl reboot
