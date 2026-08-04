#!/usr/bin/env bash
# WireBusOS First-Boot Provisioning Script
# Executed by systemd unit on initial boot of live ISO / fresh install

set -euo pipefail

MARKER_FILE="/var/lib/wirebus/first-boot-done"

if [[ -f "${MARKER_FILE}" ]]; then
    echo "[WireBusOS] First-boot initialization already completed. Exiting."
    exit 0
fi

echo "[WireBusOS] Executing initial system provisioning..."

mkdir -p /var/lib/wirebus

# Ensure Docker daemon is up
if command -v systemctl >/dev/null 2>&1; then
    systemctl start docker || true
    systemctl enable docker || true
fi

# Pull and start docker-compose telemetry containers if present
if [[ -f "/opt/wirebus/telemetry/docker-compose.yml" ]] && command -v docker >/dev/null 2>&1; then
    echo "[WireBusOS] Launching telemetry & home energy containers..."
    (cd /opt/wirebus/telemetry && docker compose up -d) || echo "[WireBusOS] Docker container pull failed or offline."
fi

# Add default user to docker group if exists
for u in ubuntu wirebus user; do
    if id "${u}" &>/dev/null; then
        usermod -aG docker "${u}" || true
    fi
done

touch "${MARKER_FILE}"
echo "[WireBusOS] First-boot initialization finished successfully."
