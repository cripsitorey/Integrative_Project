#!/usr/bin/env bash
# customize.sh — paste-and-run this inside the Cubic virtual terminal (the chroot).
# It applies every Part 1 modification in one go so the build stays reproducible.
# You're already root in here, so there's no sudo and no password prompts.

set -e

# Pull current package metadata before installing anything. The index baked into
# the base ISO is as old as the ISO itself, so without this you'd be installing
# stale versions.
apt update

# --- Mod 1: replace the default video player (Totem) with mpv ---
# Ubuntu ships GNOME Videos (Totem) out of the box. mpv is a lighter, scriptable
# GPL player that I'd rather have on a lean build, so I swap one for the other.
apt install -y mpv
apt purge -y totem totem-common 2>/dev/null || true

# --- Mod 2: a privacy browser from a reliable external repo (Brave) ---
# I wanted LibreWolf at first, but their repo server (repo.librewolf.net) keeps
# falling over and was unreachable mid-build. Brave gives me the same privacy-
# first angle, it's Chromium-based and open source, and it ships from an
# S3-backed APT repo that's basically always up. This is also my "add an external
# repository" change for the project.

# Make sure curl and CA certs are here before I fetch the signing key.
apt install -y curl ca-certificates

# Clear out anything extrepo/LibreWolf might have left behind so apt update stays
# clean (this matters if an earlier run already enabled that repo).
extrepo disable librewolf 2>/dev/null || true
rm -f /etc/apt/sources.list.d/extrepo_librewolf.sources

# Brave's official keyring and repo.
curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
  https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" \
  > /etc/apt/sources.list.d/brave-browser-release.list
apt update
apt install -y brave-browser

# Make Brave the system-wide browser alternative too.
update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/brave-browser 200 || true

# --- Mod 3: a small recon + dev toolset baked in ---
# This distro is really the warm-up for the Black Hat Bash lab later in the
# project, so I preload the CLI tools I'll actually use plus a configured Neovim.
apt install -y neovim nmap net-tools dnsutils curl git tmux build-essential

# --- /etc/skel: turn all of the above into the default for any new account ---
# /etc/skel is the template Linux copies into a brand new home directory. Drop a
# file here and every account created afterward inherits it, the live-session
# user included. That's the trick that makes the customization persistent instead
# of a one-off I have to redo by hand.

# Aliases. Ubuntu's stock .bashrc already sources .bash_aliases, so this file
# alone is enough and I don't have to edit .bashrc.
cat > /etc/skel/.bash_aliases <<'EOF'
# quality-of-life aliases
alias ll='ls -alhF'
alias ports='ss -tulpn'
alias myip='curl -s ifconfig.me'
alias vim='nvim'
EOF

# Minimal Neovim config. No plugin manager on purpose, so a fresh boot never has
# to hit the network. Just the sane defaults I want on every machine.
mkdir -p /etc/skel/.config/nvim
cat > /etc/skel/.config/nvim/init.vim <<'EOF'
set number
set relativenumber
set expandtab
set shiftwidth=4
set tabstop=4
set ignorecase
set smartcase
syntax on
EOF

# Pin Brave as the default browser for new users at the desktop level too.
mkdir -p /etc/skel/.config
cat > /etc/skel/.config/mimeapps.list <<'EOF'
[Default Applications]
x-scheme-handler/http=brave-browser.desktop
x-scheme-handler/https=brave-browser.desktop
text/html=brave-browser.desktop
EOF

# A short welcome note so it's obvious on first login that this is the custom build.
cat > /etc/skel/Welcome.txt <<'EOF'
ReconBox Linux — custom Ubuntu 24.04 build
Built with Cubic for the UIDE Integrative Project (Part 1).
EOF

# --- gschema: dark theme as the real default, not just an option ---
# A schema override in /usr/share/glib-2.0/schemas/ changes the baked-in default,
# so new users land in dark mode the first time they log in. Flipping it in
# Settings would only survive the current session and die on the live ISO.
cat > /usr/share/glib-2.0/schemas/90_reconbox-defaults.gschema.override <<'EOF'
[org.gnome.desktop.interface]
color-scheme='prefer-dark'
gtk-theme='Yaru-dark'
icon-theme='Yaru-dark'
EOF
glib-compile-schemas /usr/share/glib-2.0/schemas/

# --- Clean up so the squashfs doesn't haul around dead weight ---
apt -y autoremove
apt -y clean
rm -rf /var/lib/apt/lists/*

echo "Done. Head back to Cubic, pick XZ compression, and generate the ISO."
