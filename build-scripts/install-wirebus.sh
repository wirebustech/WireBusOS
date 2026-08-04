#!/usr/bin/env bash
# WireBusOS v1.0.0 (Initial Release) Build & Installer Script
# Supported modes: --core (default), --full, --chroot, --desktop

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "${SCRIPT_DIR}")"

INSTALL_CORE=1
INSTALL_FULL=0
IS_CHROOT=0
INSTALL_DESKTOP=0

show_help() {
    cat << EOF
WireBusOS v1.0.0 (Initial Release) Build & Installer Script

Options:
  --core       Install core energy Python libraries & essential APT dependencies (default)
  --full       Install full CAD tools (FreeCAD, KiCad, QGIS) + preconfigured container stacks
  --chroot     Enable ISO remastering mode (bypasses running daemons, installs first-boot service)
  --desktop    Install extra GUI shortcuts and desktop wallpaper
  --help       Show this help message
EOF
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --core)
                INSTALL_CORE=1
                shift
                ;;
            --full)
                INSTALL_CORE=1
                INSTALL_FULL=1
                shift
                ;;
            --chroot)
                IS_CHROOT=1
                INSTALL_CORE=1
                INSTALL_FULL=1
                shift
                ;;
            --desktop)
                INSTALL_DESKTOP=1
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

log() {
    echo -e "\033[1;32m[WireBusOS]\033[0m $1"
}

warn() {
    echo -e "\033[1;33m[WARNING]\033[0m $1"
}

setup_os_branding() {
    log "Applying WireBusOS distribution branding and system identity..."
    
    # 1. /etc/os-release
    cat << 'EOF' > /etc/os-release
NAME="WireBusOS"
VERSION="1.0.0 (Noble Numbat Base)"
ID=wirebusos
ID_LIKE=ubuntu
PRETTY_NAME="WireBusOS 1.0.0 LTS (Energy & Microgrid Engineering OS)"
VERSION_ID="1.0.0"
VERSION_CODENAME=noble
UBUNTU_CODENAME=noble
HOME_URL="https://github.com/wirebustech/WireBusOS"
SUPPORT_URL="https://github.com/wirebustech/WireBusOS/issues"
BUG_REPORT_URL="https://github.com/wirebustech/WireBusOS/issues"
PRIVACY_POLICY_URL="https://github.com/wirebustech/WireBusOS"
LOGO=wirebusos-logo
EOF

    # 2. /etc/lsb-release
    cat << 'EOF' > /etc/lsb-release
DISTRIB_ID=WireBusOS
DISTRIB_RELEASE=1.0.0
DISTRIB_CODENAME=noble
DISTRIB_DESCRIPTION="WireBusOS 1.0.0 LTS (Energy Engineering Platform)"
EOF

    # 3. /etc/issue and /etc/issue.net
    echo -e "WireBusOS 1.0.0 LTS \\n \\l" > /etc/issue
    echo "WireBusOS 1.0.0 LTS" > /etc/issue.net

    # 4. Hostname
    echo "wirebus-os" > /etc/hostname
    if [[ -f "/etc/hosts" ]]; then
        if ! grep -q "wirebus-os" /etc/hosts; then
            echo "127.0.1.1 wirebus-os" >> /etc/hosts
        fi
    fi

    # 5. Casper installer defaults
    cat << 'EOF' > /etc/casper.conf
USERNAME="wirebus"
USERFULLNAME="WireBus OS User"
HOST="wirebus-os"
BUILD_SYSTEM="WireBusOS"
EOF

    # 6. MOTD Banner
    mkdir -p /etc/update-motd.d
    cat << 'EOF' > /etc/update-motd.d/00-wirebus-header
#!/bin/sh
echo "============================================================"
echo "  ⚡ WireBusOS v1.0.0 LTS - Microgrid & Energy Engineering OS"
echo "  🌱 Open-Source Energy Simulation & SCADA Control Platform"
echo "============================================================"
EOF
    chmod +x /etc/update-motd.d/00-wirebus-header 2>/dev/null || true
    cat << 'EOF' > /etc/motd
============================================================
  ⚡ WireBusOS v1.0.0 LTS - Microgrid & Energy Engineering OS
  🌱 Open-Source Energy Simulation & SCADA Control Platform
============================================================
EOF

    # 7. Pre-create installer log directory
    mkdir -p /var/log/installer
    chmod 755 /var/log/installer 2>/dev/null || true

    # 8. Ubiquity installer target module compatibility
    mkdir -p /usr/lib/ubiquity/ubiquity/targets /usr/share/ubiquity-slideshow 2>/dev/null || true
    ln -sf ubuntu.py /usr/lib/ubiquity/ubiquity/targets/wirebusos.py 2>/dev/null || true
    ln -sf ubuntu /usr/share/ubiquity-slideshow/wirebusos 2>/dev/null || true

    # 9. Desktop launchers & skeleton configuration
    mkdir -p /usr/share/applications /etc/skel/Desktop
    cat << 'EOF' > /usr/share/applications/wirebus-telemetry.desktop
[Desktop Entry]
Name=WireBusOS Telemetry Dashboard
Comment=Grafana & SCADA Monitoring Stack
Exec=xdg-open http://localhost:3000
Icon=utilities-system-monitor
Terminal=false
Type=Application
Categories=Development;Engineering;Science;
EOF
    cp /usr/share/applications/wirebus-telemetry.desktop /etc/skel/Desktop/ 2>/dev/null || true

    # Installer Desktop Launcher
    cat << 'EOF' > /usr/share/applications/ubiquity.desktop
[Desktop Entry]
Type=Application
Version=1.0
Name=Install WireBusOS 1.0.0 LTS
Comment=Install this system permanently to your hard disk
Exec=sudo -E ubiquity gtk_ui
Icon=ubiquity
Terminal=false
Categories=GTK;System;Core;
OnlyShowIn=GNOME;XFCE;Unity;
EOF
    cp /usr/share/applications/ubiquity.desktop /etc/skel/Desktop/ 2>/dev/null || true
    chmod +x /etc/skel/Desktop/ubiquity.desktop 2>/dev/null || true

    # Default bash environment aliases
    if [[ -f "/etc/skel/.bashrc" ]]; then
        if ! grep -q "WIREBUS_HOME" /etc/skel/.bashrc; then
            cat << 'EOF' >> /etc/skel/.bashrc

# WireBusOS Environment Settings
export WIREBUS_HOME="/opt/wirebus"
alias python3-wirebus="/opt/wirebus/venv/bin/python3"
EOF
        fi
    fi
}

setup_cad_repositories() {
    log "Cleaning offline CD-ROM entries in chroot..."
    rm -f /etc/apt/sources.list.d/*cdrom* /etc/apt/sources.list.d/cdrom.sources 2>/dev/null || true
    if [[ -f "/etc/apt/sources.list" ]]; then
        sed -i '/cdrom/s/^/#/' /etc/apt/sources.list 2>/dev/null || true
    fi

    log "Enabling WireBusOS universe and multiverse package repositories..."
    if [[ -f "/etc/apt/sources.list.d/ubuntu.sources" ]]; then
        sed -i 's/Components: main restricted/Components: main restricted universe multiverse/g' /etc/apt/sources.list.d/ubuntu.sources 2>/dev/null || true
    fi

    apt-get update -y 2>/dev/null || true
    apt-get install -y --no-install-recommends software-properties-common ca-certificates curl gnupg 2>/dev/null || true

    log "Attempting to add FreeCAD and OpenModelica repositories..."
    add-apt-repository ppa:freecad-maintainers/freecad-stable -y 2>/dev/null || true
    add-apt-repository ppa:kicad/kicad-8.0-releases -y 2>/dev/null || true

    curl -fsSL http://build.openmodelica.org/apt/openmodelica.asc 2>/dev/null | gpg --dearmor -o /etc/apt/trusted.gpg.d/openmodelica-keyring.gpg 2>/dev/null || true
    echo "deb [signed-by=/etc/apt/trusted.gpg.d/openmodelica-keyring.gpg] http://build.openmodelica.org/apt noble stable" > /etc/apt/sources.list.d/openmodelica.list 2>/dev/null || true
}

fix_chroot_kernel_hooks() {
    log "Disabling problematic chroot kernel postinst hooks (kdump-tools)..."
    chmod -x /etc/kernel/postinst.d/kdump-tools 2>/dev/null || true
    apt-get purge -y kdump-tools 2>/dev/null || true
    dpkg --configure -a 2>/dev/null || true
}

install_apt_packages() {
    fix_chroot_kernel_hooks
    setup_cad_repositories

    log "Installing core development dependencies..."
    if [[ -f "${REPO_DIR}/config/packages-core.txt" ]]; then
        while IFS= read -r pkg || [[ -n "$pkg" ]]; do
            [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
            apt-get install -y --no-install-recommends "${pkg}" 2>/dev/null || warn "Core dependency '${pkg}' skipped."
        done < "${REPO_DIR}/config/packages-core.txt"
    fi

    log "Installing CAD, GIS, and Simulation tools (ignoring missing packages)..."
    for pkg in qgis grass kicad freecad qelectrotech ngspice openmodelica docker.io; do
        if apt-get install -y --no-install-recommends --ignore-missing "${pkg}" 2>/dev/null; then
            log "Successfully installed ${pkg}."
        else
            warn "Package '${pkg}' not available in mirror, ignoring."
        fi
    done
}

setup_python_env() {
    log "Configuring system-wide Python environment for WireBusOS energy modeling..."
    local venv_dir="/opt/wirebus/venv"
    mkdir -p /opt/wirebus
    python3 -m venv "${venv_dir}"

    log "Upgrading pip and wheel inside virtualenv..."
    "${venv_dir}/bin/pip" install --upgrade pip setuptools wheel

    log "Installing WireBusOS scientific energy libraries across all 14 modules..."
    if [[ -f "${REPO_DIR}/config/requirements-energy.txt" ]]; then
        "${venv_dir}/bin/pip" install -r "${REPO_DIR}/config/requirements-energy.txt" || warn "Some PIP dependencies failed to install."
    fi

    # Create system-wide symlink for python3-wirebus
    ln -sf "${venv_dir}/bin/python3" /usr/local/bin/python3-wirebus
}

setup_telemetry_stack() {
    log "Deploying pre-configured telemetry container manifests..."
    mkdir -p /opt/wirebus/telemetry
    if [[ -f "${REPO_DIR}/config/docker-compose.yml" ]]; then
        cp "${REPO_DIR}/config/docker-compose.yml" /opt/wirebus/telemetry/docker-compose.yml
    fi

    log "Deploying SunSpec Modbus register map..."
    mkdir -p /opt/wirebus/scada
    if [[ -f "${REPO_DIR}/config/modbus_scada_map.json" ]]; then
        cp "${REPO_DIR}/config/modbus_scada_map.json" /opt/wirebus/scada/modbus_scada_map.json
    fi
    if [[ -f "${REPO_DIR}/config/vendor_registers.json" ]]; then
        cp "${REPO_DIR}/config/vendor_registers.json" /opt/wirebus/scada/vendor_registers.json
    fi
}

setup_first_boot_service() {
    log "Configuring WireBusOS first-boot systemd engine..."
    mkdir -p /opt/wirebus
    cp "${REPO_DIR}/build-scripts/wirebus-first-boot.sh" /opt/wirebus/wirebus-first-boot.sh
    chmod +x /opt/wirebus/wirebus-first-boot.sh
    ln -sf /opt/wirebus/wirebus-first-boot.sh /usr/local/bin/wirebus-first-boot.sh

    cp "${REPO_DIR}/build-scripts/first-boot-wirebus.service" /etc/systemd/system/first-boot-wirebus.service
    chmod 644 /etc/systemd/system/first-boot-wirebus.service

    # Enable service for systemd (in chroot this bakes into symlinks)
    if command -v systemctl >/dev/null 2>&1; then
        systemctl enable first-boot-wirebus.service || true
    else
        mkdir -p /etc/systemd/system/multi-user.target.wants
        ln -sf /etc/systemd/system/first-boot-wirebus.service /etc/systemd/system/multi-user.target.wants/first-boot-wirebus.service
    fi
}

start_live_services() {
    if [[ "${IS_CHROOT}" -eq 1 ]]; then
        warn "Running in CHROOT mode (ISO build). Skipping live service start & live docker pulls."
        warn "Services will automatically initialize on the booted machine via first-boot-wirebus.service."
    else
        log "Starting live background services..."
        if command -v systemctl >/dev/null 2>&1 && systemctl is-active --quiet docker; then
            if [[ -f "/opt/wirebus/telemetry/docker-compose.yml" ]]; then
                log "Pulling and launching telemetry stack (Grafana, InfluxDB, Home Assistant)..."
                (cd /opt/wirebus/telemetry && docker compose up -d) || warn "Docker stack launch deferred to startup."
            fi
        else
            warn "Docker daemon not running. Telemetry containers deferred to first boot."
        fi
    fi
}

main() {
    parse_args "$@"

    log "Starting WireBusOS Setup (Core=${INSTALL_CORE}, Full=${INSTALL_FULL}, Chroot=${IS_CHROOT})..."

    if [[ -x "${SCRIPT_DIR}/customize-distro.sh" ]]; then
        "${SCRIPT_DIR}/customize-distro.sh"
    else
        setup_os_branding
    fi

    install_apt_packages
    setup_python_env
    setup_telemetry_stack
    setup_first_boot_service
    start_live_services

    log "WireBusOS Installation & Remastering Setup Complete! ⚡🌱"
}

main "$@"
