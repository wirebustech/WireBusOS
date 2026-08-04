# Remastering WireBusOS with Cubic (Custom Ubuntu ISO Creator)

This guide walks you through building a standalone, bootable **WireBusOS ISO** image using **Cubic** on an Ubuntu Desktop environment.

---

## 💻 1. Virtual Machine & Host Requirements

Because Cubic extracts, customizes, and re-compresses the entire Ubuntu filesystem within a `chroot` environment:

- **Host/VM OS**: Ubuntu 24.04 LTS Desktop (GUI required).
- **Disk Space**: **100 GB+** recommended (you need space for base ISO, extracted chroot, installed packages like FreeCAD/QGIS/KiCad, and compressed output `.iso`).
- **RAM**: **8 GB+** (16 GB recommended for multi-threaded squashfs compression).
- **CPU**: 4+ vCPUs.

> 💡 **Pro-Tip**: Take a **VM snapshot** prior to launching Cubic. If a build step fails or is aborted halfway, restoring from snapshot ensures a clean environment.

---

## 🛠️ 2. Installing Cubic

Cubic is maintained via a dedicated PPA:

```bash
sudo apt-add-repository universe -y
sudo apt-add-repository ppa:cubic-wizard/release -y
sudo apt update -y
sudo apt install cubic -y
```

---

## 📥 3. Download Base ISO

Download the official Ubuntu 24.04 LTS Desktop ISO:
```bash
wget https://releases.ubuntu.com/24.04/ubuntu-24.04-desktop-amd64.iso -O ~/Downloads/ubuntu-24.04-desktop-amd64.iso
```

---

## 🚀 4. Step-by-Step Remastering Workflow

### Step A: Project Directory Setup
1. Launch Cubic from your application menu or terminal:
   ```bash
   cubic
   ```
2. Select an empty working directory for Cubic (e.g., `~/cubic-wirebus-project`).
3. Select `ubuntu-24.04-desktop-amd64.iso` as your original ISO source.
4. Set custom metadata:
   - **OS Name**: `WireBusOS`
   - **Version**: `24.04.1-LTS`
   - **Volume ID**: `WireBusOS_24_04`
   - **Release Filename**: `WireBusOS-24.04-amd64.iso`

### Step B: Chroot Environment Execution
Cubic will extract the root filesystem and launch a interactive root shell inside the chroot environment.

Inside the Cubic chroot terminal:

```bash
# 1. Navigate to root
cd /root

# 2. Clone the WireBusOS repository
git clone https://github.com/wirebustech/WireBusOS.git
cd WireBusOS

# 3. Make the build script executable
chmod +x build-scripts/install-wirebus.sh

# 4. Run the installer script with --chroot flag
./build-scripts/install-wirebus.sh --chroot
```

### Why `--chroot` mode is crucial:
Inside Cubic's chroot, `systemd` is not active, and Docker daemons cannot run live background containers or perform `systemctl start` commands. The `--chroot` flag:
1. Installs all APT packages, scientific toolkits, and Python energy libraries.
2. Bakes the `first-boot-wirebus.service` unit directly into `/etc/systemd/system/multi-user.target.wants/`.
3. Pre-stages container definitions (`docker-compose.yml`) to automatically pull and launch on the machine's actual first boot.

### Step C: ISO Packaging
1. Exit the chroot shell by typing `exit`.
2. Cubic will prompt you to select packages for the **removable-package list** (minimal installation option). Leave your energy tools untouched.
3. Select Linux Kernel version (default current kernel).
4. Click **Generate** to compress into `WireBusOS-24.04-amd64.iso`.

---

## 🧪 5. Testing the ISO

Boot your generated `WireBusOS-24.04-amd64.iso` in a new VirtualBox or VMware VM:

1. Verify desktop environment boots cleanly.
2. Open terminal and run:
   ```bash
   wirebus-python -c "import pvlib, pypsa, pybamm; print('WireBusOS Python Suite loaded successfully!')"
   ```
3. Check status of background telemetry stack:
   ```bash
   docker ps
   ```
   Grafana will be accessible at `http://localhost:3000`, InfluxDB at `http://localhost:8086`, and Home Assistant at `http://localhost:8123`.
