DIR="$( cd "$( dirname "$0" )" && pwd )"

HOSTNAME="majcn-laptop"
USERNAME="majcn"
FULL_NAME="Gregor Majcen"

ZONEINFO="Europe/Ljubljana"

GRUB_DEVICE="/dev/sda"

BTRFS_DEVICE="/dev/sda1"
BTRFS_LABEL="Arch Linux"
BTRFS_MOUNTS="rw,noatime,compress=lzo,ssd,discard,space_cache,autodefrag,inode_cache"

mkfs.btrfs -L "$BTRFS_LABEL" $BTRFS_DEVICE -f
BTRFS_DEVICE_UUID=`blkid $BTRFS_DEVICE -o value -s UUID`

mkdir /mnt/btrfs-root
mount -o $BTRFS_MOUNTS $BTRFS_DEVICE /mnt/btrfs-root

mkdir -p /mnt/btrfs-root/__snapshot
mkdir -p /mnt/btrfs-root/__current
btrfs subvolume create /mnt/btrfs-root/__current/ROOT
btrfs subvolume create /mnt/btrfs-root/__current/home
btrfs subvolume create /mnt/btrfs-root/__current/opt
btrfs subvolume create /mnt/btrfs-root/__current/var

mkdir -p /mnt/btrfs-current
mount -o $BTRFS_MOUNTS,subvol=__current/ROOT $BTRFS_DEVICE /mnt/btrfs-current
mkdir -p /mnt/btrfs-current/home
mkdir -p /mnt/btrfs-current/opt
mkdir -p /mnt/btrfs-current/var/lib
mount -o $BTRFS_MOUNTS,nodev,nosuid,subvol=__current/home $BTRFS_DEVICE /mnt/btrfs-current/home
mount -o $BTRFS_MOUNTS,nodev,nosuid,subvol=__current/opt $BTRFS_DEVICE /mnt/btrfs-current/opt
mount -o $BTRFS_MOUNTS,nodev,nosuid,noexec,subvol=__current/var $BTRFS_DEVICE /mnt/btrfs-current/var
mkdir -p /mnt/btrfs-current/var/lib
mount --bind /mnt/btrfs-root/__current/ROOT/var/lib /mnt/btrfs-current/var/lib

pacstrap /mnt/btrfs-current base base-devel btrfs-progs sudo grub os-prober

cp $DIR/ConfigFiles/fstab /mnt/btrfs-current/etc/fstab
chmod 644 /mnt/btrfs-current/etc/fstab
sed -i "s|{{BTRFS_DEVICE}}|$BTRFS_DEVICE|" /mnt/btrfs-current/etc/fstab
sed -i "s|{{BTRFS_LABEL}}|$BTRFS_LABEL|" /mnt/btrfs-current/etc/fstab
sed -i "s|{{BTRFS_DEVICE_UUID}}|$BTRFS_DEVICE_UUID|" /mnt/btrfs-current/etc/fstab
sed -i "s|{{BTRFS_MOUNTS}}|$BTRFS_MOUNTS|" /mnt/btrfs-current/etc/fstab

# TODO: include grub file instead of generating one
# cp $DIR/grub.cfg /mnt/btrfs-current/boot/grub/grub.cfg
# chmod 600 /mnt/btrfs-current/boot/grub/grub.cfg

cp $DIR/ConfigFiles/packages.install /mnt/btrfs-current/packages.install
cp -r $DIR/CustomScripts /mnt/btrfs-current/CustomScripts

arch-chroot /mnt/btrfs-current <<EOF
 
cp /etc/pacman.d/mirrorlist{,.backup}
rankmirrors -n 6 /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist

sed -i "s/#sl_SI/sl_SI/" /etc/locale.gen
sed -i "s/#en_US/en_US/" /etc/locale.gen
locale-gen

echo LANG=en_US.UTF-8 > /etc/locale.conf
export LANG=en_US.UTF-8

echo KEYMAP=us > /etc/vconsole.conf
sed -i "$ a FONT=" /etc/vconsole.conf
sed -i "$ a FONT_MAP=" /etc/vconsole.conf

sed -i "s/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/" /etc/sudoers

ln -s /usr/share/zoneinfo/$ZONEINFO /etc/localtime
hwclock --systohc --utc

echo $HOSTNAME > /etc/hostname

grep -v "^#" /packages.install | pacman -Sy --noconfirm -

sed -i 's/^\(HOOKS=.*fsck\)\(.*$\)/\1 btrfs\2/g' /etc/mkinitcpio.conf
mkinitcpio -p linux

grub-install --recheck $GRUB_DEVICE
grub-mkconfig -o /boot/grub/grub.cfg

useradd -m -G wheel -s /bin/bash $USERNAME

chfn --full-name "$FULL_NAME" $USERNAME

echo -e "pass\npass" | passwd $USERNAME

find /CustomScripts -executable -type f -exec sh '{}' $USERNAME \;

exit

EOF

mkdir -p /mnt/btrfs-current/home/$USERNAME/Pictures
cp -r $DIR/Wallpapers /mnt/btrfs-current/home/$USERNAME/Pictures/Wallpapers

rm /mnt/btrfs-current/packages.install
rm -r /mnt/btrfs-current/CustomScripts

sync

umount /mnt/btrfs-current/home
umount /mnt/btrfs-current/opt
umount /mnt/btrfs-current/var/lib
umount /mnt/btrfs-current/var
umount /mnt/btrfs-current
umount /mnt/btrfs-root

echo "When you are ready, type 'reboot' and eject your installation media"
