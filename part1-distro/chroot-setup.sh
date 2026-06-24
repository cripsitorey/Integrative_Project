#!/bin/bash
set -e

echo "[1/3] Installing LibreWolf and removing Firefox..."
add-apt-repository ppa:mozillateam/ppa -y
apt update
apt remove --purge firefox -y
apt install librewolf -y

echo "[2/3] Installing Neovim and configuring /etc/skel..."
apt install neovim -y
mkdir -p /etc/skel/.config/nvim
cat > /etc/skel/.config/nvim/init.vim << 'VIMEOF'
set number
set tabstop=4
set shiftwidth=4
set expandtab
syntax on
VIMEOF

echo "[3/3] Setting Mint-Y-Dark as default theme via skel..."
mkdir -p /etc/skel/.config/gtk-3.0
cat > /etc/skel/.config/gtk-3.0/settings.ini << 'GTKEOF'
[Settings]
gtk-application-prefer-dark-theme=1
gtk-theme-name=Mint-Y-Dark
gtk-icon-theme-name=Mint-Y-Dark
GTKEOF

echo "All modifications applied."
