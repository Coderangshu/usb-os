#!/bin/sh

# confirm you can access the internet
if [[ ! $(curl -Is http://www.google.com/ | head -n 1) =~ "200 OK" ]]; then
	echo "Your Internet seems broken. Press Ctrl-C to abort or enter to continue."
	read
fi

# make filesystems
# /boot
mkfs.fat -F32 /dev/sdc1
# /
mkfs.ext4 -O "^has_journal" /dev/sdc2

# set up /mnt
mount /dev/sdc2 /mnt
mkdir -p /mnt/boot/efi
mount /dev/sdc1 /mnt/boot/efi

grep -q "ILoveCandy" /etc/pacman.conf || sed -i "/#VerbosePkgLists/a ILoveCandy" /etc/pacman.conf
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/;s/^#Color$/Color/" /etc/pacman.conf

# install base packages (take a coffee break if you have slow internet)
pacstrap /mnt base linux linux-firmware vim grub efibootmgr networkmanager network-manager-applet mtools dosfstools reflector git base-devel linux-headers bluez bluez-utils cups xdg-utils xdg-user-dirs --noconfirm --needed

genfstab -U /mnt >>/mnt/etc/fstab

cp -r /root/Q-OS /mnt/root/
