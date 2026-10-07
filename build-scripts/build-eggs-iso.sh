#!/usr/bin/env bash
# WireBusOS Penguin's Eggs ISO Builder Script
# Automates live ISO creation using Penguin's Eggs (eggs) remastering tool.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "${SCRIPT_DIR}")"
ISO_OUTPUT_DIR="/home/eggs"
ISO_NAME="wirebusos-1.0.0-amd64.iso"

log() {
    echo -e "\033[1;32m[WireBusOS Eggs Builder]\033[0m $1"
}

warn() {
    echo -e "\033[1;33m[WARNING]\033[0m $1"
}

error() {
    echo -e "\033[1;31m[ERROR]\033[0m $1"
    exit 1
}

# 1. Check Root Privileges
if [[ $EUID -ne 0 ]]; then
   error "This script must be run as root (use: sudo ./build-scripts/build-eggs-iso.sh)"
fi

# 2. Check and Install Penguin's Eggs
install_eggs_if_missing() {
    if ! command -v eggs &> /dev/null; then
        log "Penguin's Eggs (eggs) is not installed. Installing build dependencies & penguins-eggs..."
        
        apt-get update -y
        apt-get install -y curl squashfs-tools xorriso genisoimage isolinux syslinux-utils unzip

        log "Installing penguins-eggs via npm global package manager..."
        if command -v npm &> /dev/null; then
            npm install -g penguins-eggs
        else
            error "npm is required to install penguins-eggs. Please install Node.js/npm."
        fi

        if ! command -v eggs &> /dev/null; then
            error "Failed to install penguins-eggs via npm. Please install manually with: sudo npm install -g penguins-eggs"
        else
            log "Penguin's Eggs (eggs) successfully installed: $(eggs --version 2>/dev/null || echo 'active')"
        fi
    else
        log "Penguin's Eggs (eggs) is already installed: $(eggs --version 2>/dev/null || echo 'active')"
    fi
}

# 3. Ensure Kernel and Bootloader packages exist in /boot
ensure_kernel_and_bootloader() {
    log "Ensuring Linux kernel image and bootloader packages (GRUB EFI & PC) are present in /boot..."

    apt-get update -y
    apt-get install -y grub-efi-amd64-bin grub-pc-bin grub-common mtools dosfstools isolinux syslinux-utils initramfs-tools || warn "Bootloader dependencies installation warning."

    # Check if vmlinuz is present in /boot
    if ! ls /boot/vmlinuz* 1>/dev/null 2>&1; then
        log "Installing kernel package (linux-image-amd64 / linux-image-generic)..."
        apt-get install -y linux-image-amd64 || apt-get install -y linux-image-generic || warn "Kernel installation completed with warning."
    fi

    # Ensure initrd / initramfs image exists
    if ! ls /boot/initrd* 1>/dev/null 2>&1; then
        log "Generating initramfs images for kernel..."
        update-initramfs -c -k all || true
    fi

    # Verify kernel presence
    if ls /boot/vmlinuz* 1>/dev/null 2>&1; then
        log "Kernel image verified in /boot: $(ls /boot/vmlinuz* | head -n 1)"
    else
        warn "Notice: vmlinuz is still not detected directly in /boot."
    fi
}

# 4. Apply System Customization and Branding
apply_wirebus_customization() {
    log "Applying WireBusOS branding, system scripts, and module dependencies..."

    if [[ -f "${SCRIPT_DIR}/install-wirebus.sh" ]]; then
        bash "${SCRIPT_DIR}/install-wirebus.sh" --full --chroot || warn "install-wirebus.sh completed with warnings."
    fi

    if [[ -f "${SCRIPT_DIR}/customize-distro.sh" ]]; then
        bash "${SCRIPT_DIR}/customize-distro.sh" || warn "customize-distro.sh completed with warnings."
    fi
}

# 5. Configure Eggs Settings for WireBusOS
configure_eggs() {
    log "Configuring Penguin's Eggs for WireBusOS build..."

    # Run eggs dad in non-interactive mode to create base configuration if missing
    if [[ ! -f "/etc/eggs/eggs.yaml" && ! -f "/etc/eggs/penguins-eggs.yaml" ]]; then
        eggs dad --nointeractive || true
    fi

    # Create/override custom penguins-eggs config directory
    mkdir -p /etc/eggs

    cat << 'EOF' > /etc/eggs/eggs.yaml
# WireBusOS Penguin's Eggs Configuration
name: wirebusos
version: 1.0.0
snapshot_basename: wirebusos-1.0.0-amd64
user_opt: wirebus
user_fullname: WireBusOS Live User
user_password: wirebus
root_password: wirebus
theme: calamares
compression: zstd
EOF

    log "Penguin's Eggs configuration updated at /etc/eggs/eggs.yaml"
}

# 6. Produce Live ISO
produce_iso() {
    log "Starting ISO generation with Penguin's Eggs (eggs produce)..."
    
    # Execute eggs produce in non-interactive mode
    eggs produce --nointeractive --prefix wirebusos-1.0.0
    
    log "ISO build complete! ISO files are stored in ${ISO_OUTPUT_DIR}"
    ls -lh ${ISO_OUTPUT_DIR}/wirebusos*.iso 2>/dev/null || ls -lh ${ISO_OUTPUT_DIR}/*.iso || true
}

main() {
    log "=== WireBusOS Penguin's Eggs Build System ==="
    install_eggs_if_missing
    ensure_kernel_and_bootloader
    apply_wirebus_customization
    configure_eggs
    produce_iso
    
    log "=== SUCCESS: WireBusOS Live ISO Ready! ==="
    echo "To test the ISO in QEMU run:"
    echo "  qemu-system-x86_64 -enable-kvm -m 4096 -cdrom /home/eggs/*.iso -boot d"
}

main "$@"
