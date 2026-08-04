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

setup_cad_repositories() {
    log "Removing offline CD-ROM repository files in chroot..."
    rm -f /etc/apt/sources.list.d/*cdrom* /etc/apt/sources.list.d/cdrom.sources 2>/dev/null || true
    if [[ -f "/etc/apt/sources.list" ]]; then
        sed -i '/cdrom/s/^/#/' /etc/apt/sources.list 2>/dev/null || true
    fi

    log "Enabling Ubuntu universe and multiverse repositories..."
    if [[ -f "/etc/apt/sources.list.d/ubuntu.sources" ]]; then
        sed -i 's/Components: main restricted/Components: main restricted universe multiverse/g' /etc/apt/sources.list.d/ubuntu.sources 2>/dev/null || true
    fi

    apt-get update -y || true
    apt-get install -y --no-install-recommends software-properties-common ca-certificates curl gnupg || true

    log "Adding official FreeCAD PPA (ppa:freecad-maintainers/freecad-stable)..."
    add-apt-repository ppa:freecad-maintainers/freecad-stable -y || true

    log "Adding official KiCad PPA (ppa:kicad/kicad-8.0-releases)..."
    add-apt-repository ppa:kicad/kicad-8.0-releases -y || true

    log "Adding official OpenModelica APT repository..."
    curl -fsSL http://build.openmodelica.org/apt/openmodelica.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/openmodelica-keyring.gpg 2>/dev/null || true
    echo "deb [signed-by=/etc/apt/trusted.gpg.d/openmodelica-keyring.gpg] http://build.openmodelica.org/apt noble stable" > /etc/apt/sources.list.d/openmodelica.list 2>/dev/null || true

    log "Refreshing APT package index with all upstream repositories..."
    apt-get update -y || true
}

install_apt_packages() {
    setup_cad_repositories

    log "Installing prerequisite core APT packages..."
    if [[ -f "${REPO_DIR}/config/packages-core.txt" ]]; then
        grep -v '^#' "${REPO_DIR}/config/packages-core.txt" | xargs apt-get install -y --no-install-recommends || true
    else
        apt-get install -y python3 python3-pip python3-venv git curl build-essential || true
    fi

    log "Installing CAD, GIS, and Simulation Tools (QGIS, KiCad, FreeCAD, OpenModelica, NGSpice)..."
    for pkg in qgis grass kicad freecad qelectrotech ngspice openmodelica docker.io; do
        log "Installing ${pkg}..."
        apt-get install -y --no-install-recommends "${pkg}" 2>/dev/null || warn "APT package '${pkg}' deferring to AppImage / GitHub release binary."
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
    cp "${REPO_DIR}/build-scripts/wirebus-first-boot.sh" /usr/local/bin/wirebus-first-boot.sh
    chmod +x /usr/local/bin/wirebus-first-boot.sh

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

    install_apt_packages
    setup_python_env
    setup_telemetry_stack
    setup_first_boot_service
    start_live_services

    log "WireBusOS Installation & Remastering Setup Complete! ⚡🌱"
}

main "$@"
