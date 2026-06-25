# ReconBox Linux — Part 1

A custom Ubuntu 24.04 LTS live ISO I built with Cubic for Part 1 of the UIDE
Integrative Project. The goal was a base image that's already set up the way I
work: a privacy browser instead of Firefox, a configured editor, the recon CLI
tools I keep reaching for, and a dark desktop that any new account gets by
default. It doubles as a warm-up for the offensive lab in Part 3.

## What's under the hood

| Item | Value |
|------|-------|
| Base ISO | Ubuntu 24.04.4 LTS Desktop (Noble Numbat), amd64 |
| Tool | Cubic (Custom Ubuntu ISO Creator) |
| Build host | Ubuntu 24.04 running inside QEMU/KVM |
| Output ISO | `ReconBox-24.04-amd64.iso` |
| Compression | XZ |

I went with 24.04 on purpose. The newest LTS, 26.04, had only been out a couple
of months when I started this, it's Wayland-only now, and Cubic has a track
record of choking on freshly released Ubuntu images for the first while. Noble is
boring in the good way: the Cubic repo is built and tested against it, so nothing
fights back.

## How to reproduce it

You need an Ubuntu 24.04 host with roughly 15 GB free. A VM is fine, that's what
I used.

1. Install Cubic:
   ```bash
   sudo apt-add-repository universe
   sudo apt-add-repository ppa:cubic-wizard/release
   sudo apt update
   sudo apt install --no-install-recommends cubic
   ```
2. Launch Cubic, point it at an empty project folder, and select the Ubuntu
   24.04.4 desktop ISO as the base. Fill in the distro name and the version/volume
   label.
3. When Cubic drops you into its virtual terminal (that's a chroot straight into
   the live filesystem), paste in `customize.sh` and run it. That one script
   applies every modification listed below.
4. Back in Cubic, choose XZ on the compression page and generate the ISO.
5. Make a checksum so the file can be verified later:
   ```bash
   sha256sum ReconBox-24.04-amd64.iso > ReconBox-24.04-amd64.iso.sha256
   ```
6. Boot-test it in QEMU (commands further down).

## The modifications, and why

| # | Change | Why I made it |
|---|--------|---------------|
| 1 | mpv replaces Totem (GNOME Videos) | Totem is the stock player. mpv is lighter, scriptable, and still fully free software, so it's a better fit for a lean build. |
| 2 | Brave added from its official APT repo and set as the default browser | This is also my "add an external repository" change. I went for LibreWolf first, but their repo server was down during the build, so I switched to Brave: a privacy-focused, Chromium-based, open-source browser that ships from a reliable S3-backed repo. |
| 3 | Neovim (with a config) plus nmap, net-tools, dnsutils, curl, git, tmux preinstalled | The recon tools I'll use in Part 3 are already here, and Neovim ships configured instead of bare. |
| 4 | Dark theme set as the system default through a gschema override | I wanted dark mode to be the actual default for everyone, not something each user has to enable. |

## Making it stick: /etc/skel and gschema

The rubric cares about customization being the *default*, not just something you
can toggle. Two mechanisms handle that:

- **`/etc/skel`** is the template Linux copies into a new home directory the
  moment an account is created, live-session user included. Whatever I drop in
  there (`.bash_aliases`, the Neovim config under `.config/nvim/`, a
  `mimeapps.list` pinning LibreWolf, and a `Welcome.txt`) every new user inherits
  automatically. That's the difference between a real default and a setting I'd
  have to redo on every machine.
- **gschema override**: a `90_reconbox-defaults.gschema.override` file in
  `/usr/share/glib-2.0/schemas/`, compiled with `glib-compile-schemas`. It
  rewrites the baked-in defaults for `org.gnome.desktop.interface`, so a brand
  new login lands in dark mode straight away. Setting it through the Settings app
  would only last the current session and vanish on the next live boot.

## Testing in QEMU

```bash
qemu-system-x86_64 \
  -enable-kvm -m 4096 -smp 2 -cpu host \
  -cdrom ReconBox-24.04-amd64.iso \
  -boot d -vga virtio -display gtk
```

No disk is attached on purpose. Booting the ISO on its own, in a clean session,
is what proves the changes are baked into the image and not leftovers from a
machine I'd already touched. Cubic's own "Test" button does the same thing if you
prefer clicking.

## Screenshots

All images live in `images/`.

| Evidence | File | Rubric criterion |
|----------|------|------------------|
| Cubic start page with the base ISO and distro name | `images/01-cubic-base.png` | Base used |
| `customize.sh` running in the Cubic terminal | `images/02-cubic-chroot.png` | Modifications applied |
| Compression page with XZ selected | `images/03-cubic-xz.png` | Build config |
| ISO generated successfully | `images/04-iso-generated.png` | Bootable ISO |
| `sha256sum` of the ISO | `images/05-checksum.png` | Checksum |
| QEMU booting ReconBox (GRUB / splash) | `images/06-qemu-boot.png` | Bootable ISO |
| Live desktop in dark mode (clean session) | `images/07-dark-default.png` | Persistent gschema default |
| `which mpv brave-browser nvim nmap` in the live session | `images/08-tools-present.png` | Modifications applied |
| New user inherits skel (aliases / nvim / Welcome.txt) | `images/09-skel-newuser.png` | Persistent skel default |

## Repo layout

```
part1/
├── README.md
├── customize.sh
├── ReconBox-24.04-amd64.iso.sha256
└── images/
    ├── 01-cubic-base.png
    ├── ...
    └── 09-skel-newuser.png
```

The ISO itself isn't committed (it's well over the repo size limit). The checksum
and a download link cover it instead.

LINK FOR ISO IMAGE:
#--------------------
https://drive.google.com/drive/folders/1dsihNjzLFlg39A40Ll6vUsG4zfX91qqw?usp=drive_link
#--------------------