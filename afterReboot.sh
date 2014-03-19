#extra
pacman -S --noconfirm alsa-utils xorg-server xorg-xinit xorg-server-utils xf86-input-synaptics ttf-dejavu mlocate

#gnome
pacman -S --noconfirm gnome
#pacman -S --noconfirm gnome-extra
systemctl enable gdm.service

#xmonad
#pacman -S --noconfirm xmonad xmonad-contrib

#desktop extra
pacman -S --noconfirm firefox chromium flashplugin meld

#video
pacman -S --noconfirm bumblebee bbswitch primus intel-dri xf86-video-intel nvidia
gpasswd -a majcn bumblebee
systemctl enable bumblebeed.service

#samsung-tools
#aurget -S samsung-tools --deps --rebuild --noedit --discard --noconfirm
#systemctl enable samsung-tools.service

#TODO
#set settings in samsung-tools
#copy ConfigFiles to their locations
