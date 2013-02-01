#zsh
sudo pacman -S --noconfirm zsh
curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh
sed -i 's/ZSH_THEME=".*"/ZSH_THEME="jnrowe"/' ~/.zshrc
