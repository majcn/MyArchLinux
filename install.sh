### ON LIVE ###
#gdisk /dev/sda
#mkfs.ext2 -L boot /dev/sda1
#mkfs.ext4 -L system /dev/sda2
#mkfs.ext4 -L home /dev/sda3
#mount /dev/sda2 /mnt
#mkdir /mnt/home
#mkdir /mnt/boot
#mount /dev/sda3 /mnt/home
#mount /dev/sda1 /mnt/boot
#pacstrap -i /mnt base base-devel
#genfstab -U -p /mnt >> /mnt/etc/fstab
#arch-chroot /mnt

sed -i 's/#sl_SI/sl_SI/' /etc/locale.gen
sed -i 's/#en_US/en_US/' /etc/locale.gen
locale-gen

echo LANG=en_US.UTF-8 > /etc/locale.conf
export LANG=en_US.UTF-8

echo KEYMAP=us > /etc/vconsole.conf
sed -i '$ a FONT=' /etc/vconsole.conf
sed -i '$ a FONT_MAP=' /etc/vconsole.conf

ln -s /usr/share/zoneinfo/Europe/Ljubljana /etc/localtime
hwclock --systohc --utc

echo majcn-laptop > /etc/hostname

pacman -Syy
pacman -S --noconfirm bash-completion vim sudo
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

pacman -S --noconfirm ifplugd wireless_tools wpa_supplicant wpa_actiond dialog
systemctl enable net-auto-wireless.service
#systemctl enable net-auto-wired.service

mkinitcpio -p linux

pacman -S --noconfirm gptfdisk syslinux
syslinux-install_update -i -a -m
sed -i 's/APPEND root=\/dev\/sda3/APPEND root=\/dev\/sda2/' /boot/syslinux/syslinux.cfg

#extra
pacman -S --noconfirm alsa-utils xorg-server xorg-xinit xorg-server-utils mesa xf86-video-intel xf86-input-synaptics ttf-dejavu

useradd -m -g users -G wheel,storage,power -s /bin/bash majcn

echo "enter root password:"
passwd root
echo "enter majcn password:"
passwd majcn
