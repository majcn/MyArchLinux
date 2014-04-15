systemctl enable gdm.service

gpasswd --add $1 bumblebee
systemctl enable bumblebeed.service
