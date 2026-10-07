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
        log "Penguin's Eggs (eggs) is not installed. Installing dependencies & eggs..."
        
        apt-get update -y
        apt-get install -y curl squashfs-tools xorriso genisoimage isolinux syslinux-utils

        # Import repository key and add APT source for penguins-eggs
        log "Adding Penguin's Eggs APT repository..."
        curl -fsSL https://pieroproietti.github.io/eggs-repo/KEY.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/penguins-eggs.gpg --overwrite
        echo "deb [signed-by=/etc/apt/trusted.gpg.d/penguins-eggs.gpg] https://pieroproietti.github.io/eggs-repo/ debian main" | tee /etc/apt/sources.list.d/penguins-eggs.list
        
        apt-get update -y
        if apt-get install -y eggs; then
            log "Penguin's Eggs installed successfully via APT."
        else
            warn "APT installation of eggs failed. Attempting npm global installation..."
            if command -v npm &> /dev/null; then
                npm install -g penguins-eggs || true
            fi
            if ! command -v eggs &> /dev/null; then
                warn "Attempting direct deb download from GitHub..."
                TEMP_DEB="/tmp/penguins-eggs.deb"
                EGGS_LATEST_URL=$(curl -s https://api.github.com/repos/pieroproietti/penguins-eggs/releases/latest | grep "browser_download_url.*_amd64.deb" | cut -d : -f 2,3 | tr -d \")
                if [[ -n "${EGGS_LATEST_URL}" ]]; then
                    curl -L "${EGGS_LATEST_URL}" -o "${TEMP_DEB}"
                    apt-get install -y "${TEMP_DEB}"
                    rm -f "${TEMP_DEB}"
                else
                    error "Failed to fetch Penguin's Eggs package automatically. Please install manually: npm i -g penguins-eggs"
                fi
            fi
        fi
    else
        log "Penguin's Eggs (eggs) is already installed: $(eggs --version 2>/dev/null || echo 'active')"
    fi
}

# 3. Apply System Customization and Branding
apply_wirebus_customization() {
    log "Applying WireBusOS branding, system scripts, and module dependencies..."

    if [[ -f "${SCRIPT_DIR}/install-wirebus.sh" ]]; then
        bash "${SCRIPT_DIR}/install-wirebus.sh" --full --chroot || warn "install-wirebus.sh completed with warnings."
    fi

    if [[ -f "${SCRIPT_DIR}/customize-distro.sh" ]]; then
        bash "${SCRIPT_DIR}/customize-distro.sh" || warn "customize-distro.sh completed with warnings."
    fi
}

# 4. Configure Eggs Settings for WireBusOS
configure_eggs() {
    log "Configuring Penguin's Eggs for WireBusOS build..."

    # Run eggs dad in unattended mode to create base configuration if missing
    if [[ ! -f "/etc/eggs/eggs.yaml" && ! -f "/etc/eggs/penguins-eggs.yaml" ]]; then
        eggs dad --unattended || true
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

# 5. Produce Live ISO
produce_iso() {
    log "Starting ISO generation with Penguin's Eggs (eggs produce)..."
    
    # Execute eggs produce in clone or standard mode
    eggs produce --unattended --prefix wirebusos-1.0.0
    
    log "ISO build complete! ISO files are stored in ${ISO_OUTPUT_DIR}"
    ls -lh ${ISO_OUTPUT_DIR}/wirebusos*.iso 2>/dev/null || ls -lh ${ISO_OUTPUT_DIR}/*.iso || true
}

main() {
    log "=== WireBusOS Penguin's Eggs Build System ==="
    install_eggs_if_missing
    apply_wirebus_customization
    configure_eggs
    produce_iso
    
    log "=== SUCCESS: WireBusOS Live ISO Ready! ==="
    echo "To test the ISO in QEMU run:"
    echo "  qemu-system-x86_64 -enable-kvm -m 4096 -cdrom /home/eggs/*.iso -boot d"
}

main "$@"
