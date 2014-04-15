HOSTNAME="majcn-laptop"
USERNAME="majcn"
FULL_NAME="Gregor Majcen"

ZONEINFO="Europe/Ljubljana"

GRUB_DEVICE="/dev/sda"

BTRFS_DEVICE="/dev/sda1"
BTRFS_LABEL="ArchSSD"
BTRFS_MOUNTS="rw,noatime,compress=lzo,ssd,discard,space_cache,autodefrag,inode_cache"

mkfs.btrf -L $BTRFS_LABEL $BTRFS_DEVICE -f
BTRFS_DEVICE_UUID=`blkid $BTRFS_DEVICE -o export | grep ^UUID= | cut -c6-`

mkdir /mnt/btrfs-root
mount -o $BTRFS_MOUNTS /dev/sda1 /mnt/btrfs-root

mkdir -p /mnt/btrfs/__snapshot
mkdir -p /mnt/btrfs/__current
btrfs subvolume create /mnt/btrfs-root/__current/ROOT
btrfs subvolume create /mnt/btrfs-root/__current/home
btrfs subvolume create /mnt/btrfs-root/__current/opt
btrfs subvolume create /mnt/btrfs-root/__current/var

mkdir -p /mnt/btrfs-current
mount -o $BTRFS_MOUNTS,subvol=__current/ROOT /dev/sda1 /mnt/btrfs-current
mkdir -p /mnt/btrfs-current/home
mkdir -p /mnt/btrfs-current/opt
mkdir -p /mnt/btrfs-current/var/lib
mount -o $BTRFS_MOUNTS,nodev,nosuid,subvol=__current/home /dev/sda1 /mnt/btrfs-current/home
mount -o $BTRFS_MOUNTS,nodev,nosuid,subvol=__current/opt /dev/sda1 /mnt/btrfs-current/opt
mount -o $BTRFS_MOUNTS,nodev,nosuid,noexec,subvol=__current/var /dev/sda1 /mnt/btrfs-current/var
mkdir -p /mnt/btrfs-current/var/lib
mount --bind /mnt/btrfs-root/__current/ROOT/var/lib /mnt/btrfs-current/var/lib

pacstrap -i /mnt base base-devel btrfs-progs
genfstab -U -p /mnt >> /mnt/etc/fstab
arch-chroot /mnt <<EOF
 
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

ln -s /usr/share/zoneinfo/$ZONEINFO /etc/localtime
hwclock --systohc --utc

echo $HOSTNAME > /etc/hostname

pacman -Syy
pacman -S --noconfirm sudo
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

grep -v '^#' packagesList | sudo pacman -S --noconfirm -

mkinitcpio -p linux

pacman -S --noconfirm grub os-prober
grub-install --recheck $GRUB_DEVICE
grub-mkconfig -o /boot/grub/grub.cfg

useradd -m -G wheel -s /bin/bash $USERNAME

chfn $USERNAME --full-name $FULL_NAME

echo -e "pass\npass" | passwd majcn

exit

EOF

umount /mnt/btrfs-current/home
umount /mnt/btrfs-current/opt
umount /mnt/btrfs-current/var/lib
umount /mnt/btrfs-current/var
umount /mnt/btrfs-current
umount /mnt/btrfs-root

echo "When you are ready, type 'reboot' and eject your installation media"
