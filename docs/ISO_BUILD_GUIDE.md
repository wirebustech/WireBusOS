# Remastering WireBusOS v1.0.0 (Initial Release ISO Build Guide)

This guide walks you through building the standalone, bootable **WireBusOS v1.0.0 (Initial Release)** ISO image on an Ubuntu Desktop build environment.

---

## 🏗️ Architectural Overview & Remastering Strategy

Because custom ISO remastering extracts, customizes, and re-compresses the root filesystem within a `chroot` environment:

> [!IMPORTANT]
> **Key Remastering Constraint**: Active background daemons (such as `systemd` or live Docker engine containers) **cannot run** during the image customization phase. WireBusOS resolves this by placing a systemd first-boot service (`wirebus-first-boot.service`) to handle container image pulls and telemetry startup upon initial boot of the physical or virtual target machine.

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

3. Inside the `chroot` terminal, run the WireBusOS installer with the `--chroot` flag:
   ```bash
   ./build-scripts/install-wirebus.sh --chroot
   ```

---

## 💡 What `--chroot` Mode Does

Inside a `chroot` environment, `systemd` is not active, and Docker daemons cannot run live background containers. The `--chroot` flag:

1. Installs all core system packages (`qgis`, `freecad`, `kicad`, `openmodelica`, `ngspice`, `qelectrotech`).
2. Creates the Python energy engineering virtualenv and installs scientific libraries across all 14 functional modules (`pvlib`, `PyPSA`, `PyBaMM`, `OpenFAST`, `CodeCarbon`, `pyPPA`, `pandapower`, `Calliope`).
3. Deploys `/etc/systemd/system/first-boot-wirebus.service` and `/usr/local/bin/wirebus-first-boot.sh`.
4. Enables the first-boot service (`systemctl enable first-boot-wirebus.service`) so that Docker containers pull automatically when the ISO boots for the first time.

---

## 📀 3. Finishing & Generating the ISO

1. Click **Next** in Cubic to generate the bootable `WireBusOS-v1.0.0-amd64.iso` image.
2. Test the generated `WireBusOS-v1.0.0-amd64.iso` in VirtualBox, VMware, or QEMU:
   ```bash
   qemu-system-x86_64 -enable-kvm -m 4096 -cdrom WireBusOS-v1.0.0-amd64.iso
   ```
