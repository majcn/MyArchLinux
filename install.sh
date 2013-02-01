### ON LIVE ###
#gdisk /dev/sda
#mkfs.ext2 -L boot /dev/sda2
#mkfs.ext4 -L system /dev/sda3
#mkfs.ext4 -L home /dev/sda4
#mount /dev/sda3 /mnt
#mkdir /mnt/home
#mkdir /mnt/boot
#mount /dev/sda4 /mnt/home
#mount /dev/sda2 /mnt/boot
#pacstrap -i /mnt base base-devel
#genfstab -U -p /mnt >> /mnt/etc/fstab
#arch-chroot /mnt

cp /etc/pacman.d/mirrorlist{,.backup}
rankmirrors -n 6 /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist

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
pacman -S --noconfirm bash-completion vim sudo git
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

pacman -S --noconfirm ifplugd wireless_tools wpa_supplicant wpa_actiond dialog
systemctl enable net-auto-wireless.service
#systemctl enable net-auto-wired.service

mkinitcpio -p linux

pacman -S --noconfirm grub-bios
grub-install --recheck /dev/sda
cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
grub-mkconfig -o /boot/grub/grub.cfg

useradd -m -g users -G wheel,storage,power -s /bin/bash majcn
chfn majcn

echo "enter root password:"
passwd root
echo "enter majcn password:"
passwd majcn
