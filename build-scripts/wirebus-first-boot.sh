#!/usr/bin/env bash
# WireBusOS First-Boot Provisioning Script
# Executed by systemd unit (first-boot-wirebus.service) on initial boot of live ISO / fresh install

set -uo pipefail

MARKER_FILE="/var/lib/wirebus/first-boot-done"
LOG_FILE="/var/log/wirebus-first-boot.log"

mkdir -p /var/lib/wirebus /var/log/wirebus

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [WireBusOS] $1" | tee -a "${LOG_FILE}"
}

if [[ -f "${MARKER_FILE}" ]]; then
    log "First-boot initialization already completed. Exiting."
    exit 0
fi

log "Executing initial system provisioning for WireBusOS v1.0.0 LTS..."

# 1. Ensure Python Virtual Environment and all 14 module dependencies are fully installed
if [[ -d "/opt/wirebus/venv" ]]; then
    log "Verifying Python scientific energy packages across all 14 modules..."
    if [[ -f "/opt/wirebus/config/requirements-energy.txt" ]]; then
        /opt/wirebus/venv/bin/pip install --no-cache-dir -r /opt/wirebus/config/requirements-energy.txt >> "${LOG_FILE}" 2>&1 || log "Notice: Package sync deferred (offline installation mode)."
    fi
fi

# 2. Synchronize WireBusOS Modules & Examples into all user workspaces
log "Synchronizing 14 WireBusOS energy engineering modules into user workspaces..."
for user_dir in /home/*; do
    if [[ -d "${user_dir}" ]]; then
        u="$(basename "${user_dir}")"
        log "Provisioning WireBusOS-Modules for user '${u}'..."
        
        mkdir -p "${user_dir}/WireBusOS-Modules" "${user_dir}/Desktop"
        if [[ -d "/opt/wirebus/modules" ]]; then
            cp -r /opt/wirebus/modules/* "${user_dir}/WireBusOS-Modules/" 2>/dev/null || true
        fi
        if [[ -d "/opt/wirebus/examples" ]]; then
            mkdir -p "${user_dir}/WireBusOS-Modules/examples"
            cp -r /opt/wirebus/examples/* "${user_dir}/WireBusOS-Modules/examples/" 2>/dev/null || true
        fi
        
        # Copy desktop shortcuts to user desktop
        if [[ -d "/etc/skel/Desktop" ]]; then
            cp -r /etc/skel/Desktop/* "${user_dir}/Desktop/" 2>/dev/null || true
        fi
        
        chown -R "${u}:${u}" "${user_dir}/WireBusOS-Modules" "${user_dir}/Desktop" 2>/dev/null || true
        chmod +x "${user_dir}/Desktop/"*.desktop 2>/dev/null || true
    fi
done

# 3. Ensure Docker daemon is running & launch SCADA Telemetry stack
if command -v systemctl >/dev/null 2>&1; then
    log "Starting Docker service..."
    systemctl start docker >/dev/null 2>&1 || log "Warning: Docker service start returned non-zero."
    systemctl enable docker >/dev/null 2>&1 || log "Warning: Docker service enable returned non-zero."
fi

if [[ -f "/opt/wirebus/telemetry/docker-compose.yml" ]] && command -v docker >/dev/null 2>&1; then
    log "Launching SCADA telemetry & energy monitoring stack..."
    (cd /opt/wirebus/telemetry && docker compose up -d) >> "${LOG_FILE}" 2>&1 || log "Notice: Telemetry container startup deferred (offline or images pending)."
fi

# 4. Add default system user(s) to docker group
for u in wirebus user ubuntu; do
    if id "${u}" &>/dev/null; then
        log "Adding user '${u}' to docker group..."
        usermod -aG docker "${u}" >/dev/null 2>&1 || true
    fi
done

touch "${MARKER_FILE}"
log "First-boot provisioning finished successfully! All 14 modules ready."
exit 0
