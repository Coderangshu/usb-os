#!/bin/sh

getrootpass() {
    # Prompts user for root password.
    pas1=$(dialog --no-cancel --passwordbox "Enter a password for the root user." 10 60 3>&1 1>&2 2>&3 3>&1)
    pas2=$(dialog --no-cancel --passwordbox "Retype password." 10 60 3>&1 1>&2 2>&3 3>&1)
    while ! [ "$pas1" = "$pas2" ]; do
        unset pas2
        pas1=$(dialog --no-cancel --passwordbox "Passwords do not match.\\n\\nEnter password again." 10 60 3>&1 1>&2 2>&3 3>&1)
        pas2=$(dialog --no-cancel --passwordbox "Retype password." 10 60 3>&1 1>&2 2>&3 3>&1)
    done
}
addrootuserpass() {
    # Adds root password $pas1.
    echo root:$pas1 | chpasswd
    unset pas1 pas2
}

ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc

# Update reflector list
iso=$(curl -4 ifconfig.co/country-iso)
reflector -a 47 -c $iso -f 5 -l 20 --sort rate --save /etc/pacman.d/mirrorlist
pacman -Syy

# Locale-Gen, Hostname setup
sed -i '/^#en_US.UTF-8* /s/^#//' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >>/etc/locale.conf
echo "archlinux" >>/etc/hostname
echo "127.0.0.1 localhost" >>/etc/hosts
echo "::1       localhost" >>/etc/hosts
echo "127.0.1.1 archlinux.localdomain archlinux" >>/etc/hosts

# Add root user's password
getrootpass || error "Root user error"
addrootuserpass || error "Root user password error"
clear

# Determine processor type and install microcode
print "Installing Intel microcode"
pacman -S --noconfirm intel-ucode

print "Installing AMD microcode"
pacman -S --noconfirm amd-ucode

# Enable Network Manager
systemctl enable NetworkManager
systemctl enable bluetooth
