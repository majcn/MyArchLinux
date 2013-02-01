#extra
pacman -S --noconfirm alsa-utils xorg-server xorg-xinit xorg-server-utils xf86-input-synaptics ttf-dejavu mlocate

#gnome + xmonad
pacman -S --noconfirm gnome gnome-extra xmonad xmonad-contrib
systemctl enable gdm.service

#desktop extra
pacman -S --noconfirm firefox chromium flashplugin meld

#preload
pacman -S --noconfirm preload
systemctl enable preload.service

#AURget
cd /tmp
curl https://aur.archlinux.org/packages/au/aurget/aurget.tar.gz | tar xvz
cd aurget
makepkg -i --noconfirm

#video
pacman -S --noconfirm xf86-video-intel xf86-video-nouveau nouveau-dri mesa
aurget -S bumblebee bbswitch --deps --rebuild --noedit --discard --noconfirm
gpasswd -a majcn bumblebee
systemctl enable bumblebeed.service

#samsung-tools
aurget -S samsung-tools --deps --rebuild --noedit --discard --noconfirm
systemctl enable samsung-tools.service

#keyboard backlight
sed -i '$ a %wheel ALL=(ALL) NOPASSWD: /usr/bin/kb_down.sh' /etc/sudoers
sed -i '$ a %wheel ALL=(ALL) NOPASSWD: /usr/bin/kb_up.sh' /etc/sudoers

#TODO
#set settings in samsung-tools
#copy ConfigFiles to their locations
