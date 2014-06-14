DIR="$( cd "$( dirname "$0" )" && pwd )"

HOSTNAME="majcn-laptop"
USERNAME="majcn"
FULL_NAME="Gregor Majcen"

ZONEINFO="Europe/Ljubljana"

EFI_DEVICE="/dev/sda1"
EFI_MOUNTS="rw,noatime,discard,nodev,nosuid,noexec"

BTRFS_DEVICE="/dev/sda2"
BTRFS_LABEL="Arch Linux"
BTRFS_MOUNTS="rw,noatime,compress=lzo,ssd,discard,space_cache,autodefrag,inode_cache"

mkfs.btrfs -L "$BTRFS_LABEL" $BTRFS_DEVICE -f
BTRFS_DEVICE_UUID=`blkid $BTRFS_DEVICE -o value -s UUID`
EFI_DEVICE_UUID=`blkid $EFI_DEVICE -o value -s UUID`

mkdir /mnt/btrfs-root
mount -o $BTRFS_MOUNTS $BTRFS_DEVICE /mnt/btrfs-root

mkdir -p /mnt/btrfs-root/__snapshot
mkdir -p /mnt/btrfs-root/__active
btrfs subvolume create /mnt/btrfs-root/__active/ROOT
btrfs subvolume create /mnt/btrfs-root/__active/home
btrfs subvolume create /mnt/btrfs-root/__active/opt
btrfs subvolume create /mnt/btrfs-root/__active/var

mkdir -p /mnt/btrfs-active
mount -o $BTRFS_MOUNTS,subvol=__active/ROOT $BTRFS_DEVICE /mnt/btrfs-active
mkdir -p /mnt/btrfs-active/home
mkdir -p /mnt/btrfs-active/opt
mkdir -p /mnt/btrfs-active/var/lib
mount -o $BTRFS_MOUNTS,nodev,nosuid,subvol=__active/home $BTRFS_DEVICE /mnt/btrfs-active/home
mount -o $BTRFS_MOUNTS,nodev,nosuid,subvol=__active/opt $BTRFS_DEVICE /mnt/btrfs-active/opt
mount -o $BTRFS_MOUNTS,nodev,nosuid,noexec,subvol=__active/var $BTRFS_DEVICE /mnt/btrfs-active/var
mkdir -p /mnt/btrfs-active/var/lib
mount --bind /mnt/btrfs-root/__active/ROOT/var/lib /mnt/btrfs-active/var/lib

mkdir -p /mnt/btrfs-active/boot
mount -o $EFI_MOUNTS $EFI_DEVICE /mnt/btrfs-active/boot

pacstrap /mnt/btrfs-active base base-devel btrfs-progs sudo gummiboot

cp $DIR/ConfigFiles/fstab /mnt/btrfs-active/etc/fstab
chmod 644 /mnt/btrfs-active/etc/fstab
sed -i "s|{{BTRFS_DEVICE}}|$BTRFS_DEVICE|" /mnt/btrfs-active/etc/fstab
sed -i "s|{{BTRFS_LABEL}}|$BTRFS_LABEL|" /mnt/btrfs-active/etc/fstab
sed -i "s|{{BTRFS_DEVICE_UUID}}|$BTRFS_DEVICE_UUID|" /mnt/btrfs-active/etc/fstab
sed -i "s|{{BTRFS_MOUNTS}}|$BTRFS_MOUNTS|" /mnt/btrfs-active/etc/fstab
sed -i "s|{{EFI_DEVICE_UUID}}|$EFI_DEVICE_UUID|" /mnt/btrfs-active/etc/fstab
sed -i "s|{{EFI_MOUNTS}}|$EFI_MOUNTS|" /mnt/btrfs-active/etc/fstab

cp $DIR/ConfigFiles/packages.install /mnt/btrfs-active/packages.install
cp -r $DIR/CustomScripts /mnt/btrfs-active/CustomScripts

arch-chroot /mnt/btrfs-active <<EOF

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

gummiboot install

useradd -m -G wheel -s /bin/bash $USERNAME

chfn --full-name "$FULL_NAME" $USERNAME

echo -e "pass\npass" | passwd $USERNAME

find /CustomScripts -executable -type f -exec sh '{}' $USERNAME \;

exit

EOF

useradd -m -s /bin/bash $USERNAME
mkdir -p /mnt/btrfs-active/home/$USERNAME/Pictures
cp -r $DIR/Wallpapers /mnt/btrfs-active/home/$USERNAME/Pictures/Wallpapers
chown -R $USERNAME:$USERNAME /mnt/btrfs-active/home/$USERNAME/Pictures

mkdir -p /mnt/btrfs-active/boot/loader/entries
cp $DIR/ConfigFiles/arch.conf.gummiboot /mnt/btrfs-active/boot/loader/entries/arch.conf
chmod 644 /mnt/btrfs-active/boot/loader/entries/arch.conf
sed -i "s|{{BTRFS_DEVICE_UUID}}|$BTRFS_DEVICE_UUID|" /mnt/btrfs-active/boot/loader/entries/arch.conf

rm /mnt/btrfs-active/packages.install
rm -r /mnt/btrfs-active/CustomScripts

sync

umount /mnt/btrfs-active/boot
umount /mnt/btrfs-active/home
umount /mnt/btrfs-active/opt
umount /mnt/btrfs-active/var/lib
umount /mnt/btrfs-active/var
umount /mnt/btrfs-active
umount /mnt/btrfs-root

echo "When you are ready, type 'reboot' and eject your installation media"
