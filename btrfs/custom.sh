systemctl enable gdm.service

gpasswd --add $USERNAME bumblebee
systemctl enable bumblebeed.service
