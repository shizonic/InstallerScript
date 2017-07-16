#!/bin/bash
UserName=burhan
Groups=(wheel storage autologin)

# add comma in Groups
tmp=$(printf ",%s" "${Groups[@]}" )
GroupsJoined=${tmp:1}

ESP_PART=/dev/sda1
ROOT_PART=/dev/sda2
SWAP_PART=
HOME_PART=

mount $ROOT_PART /mnt
mount $ESP_PART /mnt/boot

[[ !  -z  $HOME_PART ]] && 
mount $HOME_PART /mnt/home

[[ !  -z  $SWAP_PART ]] && 
swapon $SWAP_PART

# Launch scriopt as soon as logged in as user
touch /mnt/home/$UserName/.bash_profile
arch-chroot /mnt chown ${UserName}:users /home/$UserName/.bash_profile

## Can't use login shell for user arch-chroot
cat >> /mnt/home/$UserName/.bash_profile<< 069StringSecond

Groups=( "${Groups[@]}" )
# add needed groups
for GroupName in ${Groups[@]}
do
  sudo groupadd -r \$GroupName
done

# add user to groups
sudo usermod -a -G ${GroupsJoined[@]} $UserName
mv /home/$UserName/.bash_profile /home/$UserName/.bash_profile.bak
069StringSecond

echo "rebooting in 5 seconds"
sleep 5 && systemctl reboot

