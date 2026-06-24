# Integrative Project — Build, Boot, and Attack

**Course:** UNIX  
**Instructor:** Ing. Jonathan E. Tito O., MSc. — UIDE  
**Term:** March–July 2026

## Team members

| Name | Role |
|------|------|
| Cesar Arciniegas | Part 3 |
| Emilio Cuenca | Part 2 |
| Ariel Guerrero | Part 1 |

---

## Repository structure

```
Integrative_Project/
├── part1-distro/     # Part 1 — Custom distro built with Cubic
├── part2-kernel/     # Part 2 — 64-bit kernel from scratch
└── part3-lab/        # Part 3 — Black Hat Bash offensive lab
```

## How to reproduce each part

### Part 1 — Distro (Cubic)
---

## Overview

A custom bootable Linux distribution built on top of **Linux Mint 22.1 Cinnamon**, repackaged using **Cubic (Custom Ubuntu ISO Creator)**. The resulting ISO includes privacy-focused software replacements, a pre-configured developer environment, and a persistent dark theme applied to all new users via `/etc/skel`.

---

## Base ISO

| Field | Value |
|-------|-------|
| Base | Linux Mint 22.1 Cinnamon (64-bit) |
| Original ISO | `linuxmint-22.1-cinnamon-64bit.iso` |
| Custom ISO | `ArielOS-22.1-amd64.iso` |
| Tool | Cubic 2026.06.105 |

---

## Modifications

### 1. Firefox → LibreWolf
**What:** Removed the default Firefox browser and replaced it with [LibreWolf](https://librewolf.net/), a hardened Firefox fork.  
**Why:** LibreWolf ships with strict privacy defaults — no telemetry, no sponsored content, uBlock Origin pre-installed. Aligns with free-software principles and reduces data collection on the base system.

```bash
# Inside Cubic chroot
add-apt-repository ppa:mozillateam/ppa
apt update
apt remove --purge firefox -y
apt install librewolf -y
```

---

### 2. Neovim — Pre-installed developer editor
**What:** Installed Neovim with a base configuration placed in `/etc/skel` so every new user gets it.  
**Why:** Neovim is a lightweight, keyboard-driven editor used in professional development environments. Pre-configuring it demonstrates skel-based personalization and gives the distro a developer identity.

```bash
# Inside Cubic chroot
apt install neovim -y
mkdir -p /etc/skel/.config/nvim
cat > /etc/skel/.config/nvim/init.vim << 'EOF'
set number
set tabstop=4
set shiftwidth=4
set expandtab
syntax on
EOF
```

---

### 3. Dark theme by default (GTK + skel)
**What:** Configured the Mint-Y-Dark theme as the default for all new users via `/etc/skel/.config/gtk-3.0/settings.ini`.  
**Why:** Default themes only apply to the live session; writing to skel ensures every new user account created after install inherits the dark theme without manual configuration.

```bash
# Inside Cubic chroot
mkdir -p /etc/skel/.config/gtk-3.0
cat > /etc/skel/.config/gtk-3.0/settings.ini << 'EOF'
[Settings]
gtk-application-prefer-dark-theme=1
gtk-theme-name=Mint-Y-Dark
gtk-icon-theme-name=Mint-Y-Dark
EOF
```

---

## How to Reproduce

### Requirements
- Ubuntu 22.04 / Linux Mint 21+ (or a VM running either)
- Cubic installed
- ~15 GB free disk space
- `qemu-system-x86_64` for testing

### Steps

**1. Install Cubic**
```bash
sudo apt-add-repository ppa:cubic-wizard/release
sudo apt update
sudo apt install cubic -y
```

**2. Download the base ISO**
```bash
wget https://mirrors.edge.kernel.org/linuxmint/stable/22.1/linuxmint-22.1-cinnamon-64bit.iso
```

**3. Open Cubic**
```bash
cubic
```
- Set project directory → `~/Desktop`
- Select the downloaded ISO as **Original Disk**
- Set Custom Disk name to `ArielOS`, filename `ArielOS-22.1-amd64.iso`
- Click **Next**

**4. Apply modifications**  
When Cubic opens the chroot terminal, run the commands listed in each modification section above.

**5. Generate ISO**  
- In Cubic's compression step, select **XZ** for smallest size
- Click **Generate** and wait (~10–20 min)

**6. Test the ISO**
```bash
qemu-system-x86_64 -m 2048 -cdrom ~/Desktop/ArielOS-22.1-amd64.iso -boot d
```

---

## ISO Download

> The ISO exceeds GitHub's file size limit.  
> (https://mirrors.layeronline.com/linuxmint/stable/22.1/linuxmint-22.1-cinnamon-64bit.iso)
> **SHA256 checksum:**
> ```
> (run: sha256sum ArielOS-22.1-amd64.iso)
> ```

---

## Boot Screenshots

> 

```
screenshots/
├── 01-boot-screen.png
├── 02-desktop.png
├── 03-librewolf.png
├── 04-neovim.png
└── 05-dark-theme.png
```

### Part 2 — 64-bit Kernel

```bash
cd part2-kernel
docker build -t uide-kernel-builder . && docker run --rm -v "$(pwd)":/root/kernel uide-kernel-builder make build-kernel
qemu-system-x86_64 -cdrom kernel.iso
```

See [part2-kernel/README.md](part2-kernel/README.md) for full details.

### Part 3 — Black Hat Bash Lab
See [part3-lab/README.md](part3-lab/README.md)

---

## Global rubric

| Component | Pts |
|---|---|
| Part 1 — Distro with Cubic | 25 |
| Part 2 — 64-bit kernel | 30 |
| Part 3.A — Lab up and running | 20 |
| Part 3.B — Hacking technique | 15 |
| Documentation, repo, and teamwork | 10 |
| **Total** | **100** |
