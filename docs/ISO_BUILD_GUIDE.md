# Remastering WireBusOS v1.0.0 (Initial Release ISO Build Guide)

This guide walks you through building the standalone, bootable **WireBusOS v1.0.0 (Initial Release)** ISO image on an Ubuntu Desktop build environment.

---

## 🏗️ Architectural Overview & Remastering Strategy

Because custom ISO remastering extracts, customizes, and re-compresses the root filesystem within a `chroot` environment:

> [!IMPORTANT]
> **Key Remastering Constraint**: Active background daemons (such as `systemd` or live Docker engine containers) **cannot run** during the image customization phase. WireBusOS resolves this by placing a systemd first-boot service (`first-boot-wirebus.service` executing `/opt/wirebus/wirebus-first-boot.sh`) to handle container image pulls and telemetry startup upon initial boot of the physical or virtual target machine.

> [!TIP]
> **Pro-Tip**: Take a **VM snapshot** prior to launching ISO remastering. If a build step fails or is aborted halfway, restoring from snapshot ensures a clean environment.

---

## 🛠️ 1. Prerequisites

Make sure your host build system has sufficient disk space (minimum 25 GB free):

```bash
sudo apt update && sudo apt install -y git build-essential xorriso squashfs-tools cubic
```

---

## 🚀 2. Building the WireBusOS v1.0.0 ISO

1. Clone the WireBusOS repository into your build environment:
   ```bash
   git clone https://github.com/wirebustech/WireBusOS.git
   cd WireBusOS
   ```

2. Open **Cubic** and set ISO Metadata:
   - **Disk Name**: `WireBusOS v1.0.0`
   - **Volume ID**: `WireBusOS_v1_0_0`
   - **Release Name**: `WireBusOS Initial Release (v1.0.0)`
   - **Filename**: `WireBusOS-v1.0.0-amd64.iso`

3. Inside the `chroot` terminal, grant execute permissions and run the installer with the `--chroot` flag:
   ```bash
   chmod +x build-scripts/install-wirebus.sh
   ./build-scripts/install-wirebus.sh --chroot
   ```

---

## 🎨 Full Distribution Customization Engine (`customize-distro.sh`)

WireBusOS includes a dedicated distribution remastering engine (`build-scripts/customize-distro.sh`) that completely customizes the operating system:

1. **System Identity & Release Metadata**: Configures `/etc/os-release`, `/etc/lsb-release`, `/etc/issue`, `/etc/hostname` (`wirebus-os`), and `/etc/casper.conf` to brand the OS as **WireBusOS 1.0.0 LTS**.
2. **DPKG Vendor Identity**: Deploys `/etc/dpkg/origins/wirebusos` setting `Vendor: WireBusOS` so package management utilities report WireBusOS as the operating system vendor.
3. **Visual Branding & Renewable Energy 4K Wallpaper**: Deploys a high-resolution 4K vector wallpaper (`/usr/share/backgrounds/wirebusos/wirebusos_wallpaper.svg`) featuring vector illustrations of Solar PV arrays, Wind Turbines, Battery Storage (BESS) units, and Microgrid Transmission pylons.
4. **Bootloader Menu De-branding**: Replaces boot menu entries in GRUB/Isolinux with **"Try or Install WireBusOS 1.0.0 LTS"** and **"WireBusOS 1.0.0 (Safe Graphics)"**.
5. **14-Module Auto-Provisioning & Workspace Sync**: Copies all 14 energy engineering modules (`01-solar-pv` through `14-carbon-accounting-energy-efficiency`) into `/opt/wirebus/modules/` and user home directories (`/etc/skel/WireBusOS-Modules/` & `~/WireBusOS-Modules/`).
6. **Python Energy Scientific Virtualenv**: Pre-installs and validates Python libraries across all 14 modules (`pvlib`, `PyPSA`, `PyBaMM`, `windpowerlib`, `OpenFAST`, `CodeCarbon`, `pandapower`, `Calliope`, `ocpp`, `power-grid-model`, `pymodbus`).
7. **Plymouth Boot Splash Screen**: Builds and sets a custom Plymouth boot theme (`/usr/share/plymouth/themes/wirebusos`) with logo and animated boot status text.
8. **GRUB Bootloader**: Updates GRUB distributor title to `WireBusOS` and configures custom dark background wallpaper.
9. **GNOME GSettings Theme Overrides**: Deploys `/usr/share/glib-2.0/schemas/90_wirebusos.gschema.override` enforcing dark mode (`prefer-dark`), Yaru-viridian theme, default wallpaper, and pinned dock applications.
10. **Terminal & Fastfetch System Summary**: Configures customized bash prompt (`PS1="⚡ WireBusOS \u@\h:\w\$ "`), `/etc/motd` header, Fastfetch configuration (`/etc/fastfetch/config.jsonc`), and environment aliases (`python3-wirebus`).
11. **Ubiquity Live Installer Customization**: Pre-creates `/var/log/installer`, installs installer target symlinks (`wirebusos.py -> ubuntu.py`), and deploys custom HTML slideshow slides showcasing WireBusOS features.
12. **Desktop Application Launchers**: Installs launcher shortcuts in `/usr/share/applications/` and `/etc/skel/Desktop/` for Solar PV, Wind Energy, Microgrid Modeling, Telemetry Dashboard, Control Center, and Live Installer.

---

## 📀 3. Finishing & Generating the ISO

1. Click **Next** in Cubic to generate the bootable `WireBusOS-v1.0.0-amd64.iso` image.
2. Test the generated `WireBusOS-v1.0.0-amd64.iso` in VirtualBox, VMware, or QEMU:
   ```bash
   qemu-system-x86_64 -enable-kvm -m 4096 -cdrom WireBusOS-v1.0.0-amd64.iso
   ```

---

## 🔍 Verification & Troubleshooting

- **Check System Identity & Vendor Origin**:
  ```bash
  cat /etc/os-release
  cat /etc/lsb-release
  cat /etc/dpkg/origins/default
  hostname
  ```
- **Check Plymouth Theme**:
  ```bash
  plymouth-set-default-theme
  ```
- **Check First-Boot Service & Module Workspace**:
  ```bash
  systemctl status first-boot-wirebus.service
  cat /var/log/wirebus-first-boot.log
  ls -la ~/WireBusOS-Modules/
  ```
