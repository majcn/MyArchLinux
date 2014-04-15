systemctl enable gdm.service

gpasswd -a $USERNAME bumblebee
systemctl enable bumblebeed.service
