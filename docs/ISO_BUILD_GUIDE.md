# Remastering WireBusOS (Custom ISO Remastering Guide)

This guide walks you through building a standalone, bootable **WireBusOS ISO** image on an Ubuntu Desktop environment.

---

## 🏗️ Architectural Overview & Remastering Strategy

Because custom ISO remastering extracts, customizes, and re-compresses the entire Ubuntu filesystem within a `chroot` environment:

> [!IMPORTANT]
> **Key Remastering Constraint**: Active background daemons (such as `systemd` or live Docker engine containers) **cannot run** during the image customization phase. WireBusOS resolves this by placing a systemd first-boot service (`wirebus-first-boot.service`) to handle container image pulls and telemetry startup upon initial boot of the physical or virtual target machine.

> [!TIP]
> **Pro-Tip**: Take a **VM snapshot** prior to launching ISO remastering. If a build step fails or is aborted halfway, restoring from snapshot ensures a clean environment.

---

## 🛠️ 1. Prerequisites

Make sure your host build system has sufficient disk space (minimum 25 GB free):

```bash
sudo apt update && sudo apt install -y git build-essential xorriso squashfs-tools
```

---

## 🚀 2. Building the WireBusOS ISO

1. Clone the WireBusOS repository into your build environment:
   ```bash
   git clone https://github.com/wirebustech/WireBusOS.git
   cd WireBusOS
   ```

2. Extract the base Ubuntu 24.04 LTS Desktop ISO in your remastering tool or chroot environment.

3. Inside the `chroot` terminal, run the WireBusOS installer with the `--chroot` flag:
   ```bash
   ./build-scripts/install-wirebus.sh --chroot
   ```

---

## 💡 What `--chroot` Mode Does

Inside a `chroot` environment, `systemd` is not active, and Docker daemons cannot run live background containers. The `--chroot` flag:

1. Installs all core system packages (`qgis`, `freecad`, `kicad`, `openmodelica`, `ngspice`, `qelectrotech`).
2. Creates the Python energy engineering virtualenv and installs scientific libraries (`pvlib`, `PyPSA`, `PyBaMM`, `openfast-io`, `pandapower`, `Calliope`).
3. Deploys `/etc/systemd/system/first-boot-wirebus.service` and `/usr/local/bin/wirebus-first-boot.sh`.
4. Enables the first-boot service (`systemctl enable first-boot-wirebus.service`) so that Docker containers pull automatically when the ISO boots for the first time.

---

## 📀 3. Finishing & Generating the ISO

1. Generate the bootable `.iso` image using `xorriso` or your ISO build kit.
2. Test the generated `WireBusOS-24.04-Desktop-amd64.iso` in VirtualBox or QEMU:
   ```bash
   qemu-system-x86_64 -enable-kvm -m 4096 -cdrom WireBusOS-24.04-Desktop-amd64.iso
   ```
