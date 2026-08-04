#!/usr/bin/env bash
# WireBusOS Automated Installer & ISO Remastering Script
# Author: WireBusOS Core Team
# Usage: ./install-wirebus.sh [--core | --full | --chroot | --desktop]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

IS_CHROOT=0
INSTALL_CORE=1
INSTALL_FULL=0
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

install_apt_packages() {
    log "Updating package index..."
    apt-get update -y

    log "Installing prerequisite APT packages..."
    if [[ -f "${REPO_DIR}/config/packages-core.txt" ]]; then
        grep -v '^#' "${REPO_DIR}/config/packages-core.txt" | xargs apt-get install -y --no-install-recommends
    else
        apt-get install -y python3 python3-pip python3-venv git curl build-essential
    fi
}

setup_python_env() {
    log "Configuring system-wide Python environment for WireBusOS energy modeling..."
    local venv_dir="/opt/wirebus/venv"
    mkdir -p /opt/wirebus
    python3 -m venv "${venv_dir}"

    log "Upgrading pip and wheel inside virtualenv..."
    "${venv_dir}/bin/pip" install --upgrade pip setuptools wheel

    if [[ -f "${REPO_DIR}/config/requirements-energy.txt" ]]; then
        log "Installing Python renewable energy suite (pvlib, PyPSA, PyBaMM, OpenFAST-io, etc.)..."
        "${venv_dir}/bin/pip" install -r "${REPO_DIR}/config/requirements-energy.txt"
    fi

    # Create symlink for energy python environment
    ln -sf "${venv_dir}/bin/python3" /usr/local/bin/wirebus-python
    ln -sf "${venv_dir}/bin/jupyter-lab" /usr/local/bin/wirebus-jupyter
}

deploy_wirebus_configs() {
    log "Deploying WireBusOS configuration files and service manifests..."
    mkdir -p /etc/wirebus /opt/wirebus/telemetry

    if [[ -f "${REPO_DIR}/config/docker-compose.yml" ]]; then
        cp "${REPO_DIR}/config/docker-compose.yml" /opt/wirebus/telemetry/docker-compose.yml
    fi

    cp "${SCRIPT_DIR}/wirebus-first-boot.sh" /opt/wirebus/wirebus-first-boot.sh
    chmod +x /opt/wirebus/wirebus-first-boot.sh
}

setup_first_boot_service() {
    log "Registering wirebus-first-boot systemd service..."
    cp "${SCRIPT_DIR}/first-boot-wirebus.service" /etc/systemd/system/first-boot-wirebus.service
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
            warn "Docker service not currently active. First-boot script will handle startup."
        fi
    fi
}

main() {
    parse_args "$@"
    
    log "Starting WireBusOS setup (Chroot mode: ${IS_CHROOT})..."
    install_apt_packages
    setup_python_env
    deploy_wirebus_configs
    setup_first_boot_service
    start_live_services

    log "----------------------------------------------------"
    log "WireBusOS installation & configuration completed!"
    log "Python Suite: /opt/wirebus/venv (alias: wirebus-python)"
    log "Telemetry Stack: /opt/wirebus/telemetry/docker-compose.yml"
    log "----------------------------------------------------"
}

main "$@"
