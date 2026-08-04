#!/usr/bin/env bash
# WireBusOS Distribution Remastering & Visual Customization Script
# Applies complete OS branding, Plymouth theme, GRUB titles, GNOME overrides, wallpapers, and installer slides.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "${SCRIPT_DIR}")"
ASSETS_DIR="${REPO_DIR}/assets"

log() {
    echo -e "\033[1;32m[WireBusOS Customizer]\033[0m $1"
}

warn() {
    echo -e "\033[1;33m[WARNING]\033[0m $1"
}

setup_system_identity() {
    log "Configuring system identity and OS release metadata..."

    cat << 'EOF' > /etc/os-release
NAME="WireBusOS"
VERSION="1.0.0 (Noble Base)"
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

    cat << 'EOF' > /etc/lsb-release
DISTRIB_ID=WireBusOS
DISTRIB_RELEASE=1.0.0
DISTRIB_CODENAME=noble
DISTRIB_DESCRIPTION="WireBusOS 1.0.0 LTS (Energy Engineering Platform)"
EOF

    echo -e "WireBusOS 1.0.0 LTS \\n \\l" > /etc/issue
    echo "WireBusOS 1.0.0 LTS" > /etc/issue.net

    echo "wirebus-os" > /etc/hostname
    if [[ -f "/etc/hosts" ]]; then
        if ! grep -q "wirebus-os" /etc/hosts; then
            echo "127.0.1.1 wirebus-os" >> /etc/hosts
        fi
    fi

    cat << 'EOF' > /etc/casper.conf
USERNAME="wirebus"
USERFULLNAME="WireBus OS User"
HOST="wirebus-os"
BUILD_SYSTEM="WireBusOS"
EOF
}

setup_dpkg_vendor_origin() {
    log "Setting DPKG vendor identity to WireBusOS..."

    mkdir -p /etc/dpkg/origins
    cat << 'EOF' > /etc/dpkg/origins/wirebusos
Vendor: WireBusOS
Vendor-URL: https://github.com/wirebustech/WireBusOS
Bugs: https://github.com/wirebustech/WireBusOS/issues
Parent: Ubuntu
EOF

    ln -sf /etc/dpkg/origins/wirebusos /etc/dpkg/origins/default 2>/dev/null || true
}

setup_wallpapers_and_assets() {
    log "Installing system logos, renewable energy wallpapers, and icon themes..."

    mkdir -p /usr/share/backgrounds/wirebusos /usr/share/pixmaps /usr/share/icons/hicolor/scalable/apps /usr/share/gnome-background-properties

    if [[ -d "${ASSETS_DIR}" ]]; then
        [[ -f "${ASSETS_DIR}/wirebusos_wallpaper.svg" ]] && cp "${ASSETS_DIR}/wirebusos_wallpaper.svg" /usr/share/backgrounds/wirebusos/wirebusos_wallpaper.svg
        [[ -f "${ASSETS_DIR}/wirebusos_logo.svg" ]] && cp "${ASSETS_DIR}/wirebusos_logo.svg" /usr/share/pixmaps/wirebusos-logo.svg
        [[ -f "${ASSETS_DIR}/wirebusos_horizontal_logo.svg" ]] && cp "${ASSETS_DIR}/wirebusos_horizontal_logo.svg" /usr/share/pixmaps/wirebusos-horizontal-logo.svg
        [[ -f "${ASSETS_DIR}/wirebusos_icon.svg" ]] && cp "${ASSETS_DIR}/wirebusos_icon.svg" /usr/share/icons/hicolor/scalable/apps/wirebusos-icon.svg
    fi

    # Create GNOME XML background property manifest
    cat << 'EOF' > /usr/share/gnome-background-properties/wirebusos-wallpapers.xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE wallpapers SYSTEM "gnome-wp-list.dtd">
<wallpapers>
  <wallpaper deleted="false">
    <name>WireBusOS Renewable Energy Systems 4K</name>
    <filename>/usr/share/backgrounds/wirebusos/wirebusos_wallpaper.svg</filename>
    <options>zoom</options>
    <shade_type>solid</shade_type>
    <pcolor opacity="1.0">#0D1417</pcolor>
    <scolor opacity="1.0">#142127</scolor>
  </wallpaper>
</wallpapers>
EOF

    # Update GTK icon cache if binary exists
    if command -v gtk-update-icon-cache >/dev/null 2>&1; then
        gtk-update-icon-cache -f /usr/share/icons/hicolor 2>/dev/null || true
    fi
}

setup_gnome_defaults() {
    log "Configuring GNOME desktop GSettings overrides (theme, wallpaper, dark mode)..."

    mkdir -p /usr/share/glib-2.0/schemas

    cat << 'EOF' > /usr/share/glib-2.0/schemas/90_wirebusos.gschema.override
[org.gnome.desktop.interface]
color-scheme='prefer-dark'
gtk-theme='Yaru-viridian-dark'
icon-theme='Yaru-viridian'
cursor-theme='Yaru'
font-name='DejaVu Sans 10'
document-font-name='DejaVu Sans 10'
monospace-font-name='DejaVu Sans Mono 10'

[org.gnome.desktop.background]
picture-uri='file:///usr/share/backgrounds/wirebusos/wirebusos_wallpaper.svg'
picture-uri-dark='file:///usr/share/backgrounds/wirebusos/wirebusos_wallpaper.svg'
picture-options='zoom'
primary-color='#0D1417'

[org.gnome.desktop.screensaver]
picture-uri='file:///usr/share/backgrounds/wirebusos/wirebusos_wallpaper.svg'
primary-color='#0D1417'

[org.gnome.shell]
favorite-apps=['ubiquity.desktop', 'wirebus-telemetry.desktop', 'wirebus-control-center.desktop', 'org.gnome.Terminal.desktop', 'firefox.desktop', 'qgis.desktop', 'freecad.desktop', 'kicad.desktop']
EOF

    if command -v glib-compile-schemas >/dev/null 2>&1; then
        glib-compile-schemas /usr/share/glib-2.0/schemas 2>/dev/null || true
    fi
}

setup_plymouth_boot_splash() {
    log "Configuring WireBusOS Plymouth boot splash theme..."

    local theme_dir="/usr/share/plymouth/themes/wirebusos"
    mkdir -p "${theme_dir}"

    if [[ -f "${ASSETS_DIR}/wirebusos_icon.svg" ]]; then
        cp "${ASSETS_DIR}/wirebusos_icon.svg" "${theme_dir}/logo.svg"
    fi

    cat << 'EOF' > "${theme_dir}/wirebusos.plymouth"
[Plymouth Theme]
Name=WireBusOS Boot Splash
Description=Official WireBusOS Energy Engineering Boot Splash Theme
ModuleName=script

[script]
ImageDir=/usr/share/plymouth/themes/wirebusos
ScriptFile=/usr/share/plymouth/themes/wirebusos/wirebusos.script
EOF

    cat << 'EOF' > "${theme_dir}/wirebusos.script"
// WireBusOS Plymouth Boot Script
Window.SetBackgroundTopColor(0.05, 0.08, 0.09);
Window.SetBackgroundBottomColor(0.03, 0.05, 0.06);

logo.image = Image("logo.svg");
if (!logo.image) {
    logo.image = Image.Text("WireBusOS", 1, 1, 1);
}
logo.sprite = Sprite(logo.image);
logo.sprite.SetX(Window.GetWidth() / 2 - logo.image.GetWidth() / 2);
logo.sprite.SetY(Window.GetHeight() / 2 - logo.image.GetHeight() / 2 - 40);

status.image = Image.Text("WireBusOS v1.0.0 LTS - Initializing Energy Services...", 0.3, 0.89, 0.57);
status.sprite = Sprite(status.image);
status.sprite.SetX(Window.GetWidth() / 2 - status.image.GetWidth() / 2);
status.sprite.SetY(Window.GetHeight() / 2 + 100);
EOF

    if command -v update-alternatives >/dev/null 2>&1; then
        update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth "${theme_dir}/wirebusos.plymouth" 100 2>/dev/null || true
        update-alternatives --set default.plymouth "${theme_dir}/wirebusos.plymouth" 2>/dev/null || true
    fi
}

setup_grub_and_bootloader_debranding() {
    log "Updating GRUB bootloader identity and de-branding boot menu strings..."

    if [[ -f "/etc/default/grub" ]]; then
        sed -i 's/^GRUB_DISTRIBUTOR=.*/GRUB_DISTRIBUTOR="WireBusOS"/' /etc/default/grub 2>/dev/null || true
        if ! grep -q "GRUB_BACKGROUND" /etc/default/grub; then
            echo 'GRUB_BACKGROUND="/usr/share/backgrounds/wirebusos/wirebusos_wallpaper.svg"' >> /etc/default/grub
        fi
    fi

    # De-brand any boot menu config files in system or ISO root
    for cfg in /boot/grub/grub.cfg /boot/grub/loopback.cfg /isolinux/txt.cfg /isolinux/isolinux.cfg; do
        if [[ -f "${cfg}" ]]; then
            sed -i 's/Try or Install Ubuntu/Try or Install WireBusOS 1.0.0 LTS/g' "${cfg}" 2>/dev/null || true
            sed -i 's/Ubuntu (safe graphics)/WireBusOS 1.0.0 (Safe Graphics)/g' "${cfg}" 2>/dev/null || true
            sed -i 's/Ubuntu/WireBusOS/g' "${cfg}" 2>/dev/null || true
        fi
    done
}

setup_fastfetch_branding() {
    log "Deploying WireBusOS Fastfetch system summary configuration..."

    mkdir -p /etc/fastfetch /etc/skel/.config/fastfetch
    cat << 'EOF' > /etc/fastfetch/config.jsonc
{
  "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
  "logo": {
    "type": "small",
    "color": {
      "1": "green",
      "2": "cyan"
    }
  },
  "modules": [
    "title",
    "separator",
    "os",
    "host",
    "kernel",
    "uptime",
    "packages",
    "shell",
    "display",
    "de",
    "wm",
    "terminal",
    "cpu",
    "gpu",
    "memory"
  ]
}
EOF
    cp /etc/fastfetch/config.jsonc /etc/skel/.config/fastfetch/config.jsonc 2>/dev/null || true
}

setup_terminal_and_shell() {
    log "Customizing shell prompt, login MOTD, and terminal branding..."

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

    # Configure custom shell prompt in system-wide bashrc
    if [[ -f "/etc/bash.bashrc" ]]; then
        if ! grep -q "WireBusOS" /etc/bash.bashrc; then
            cat << 'EOF' >> /etc/bash.bashrc

# WireBusOS Shell Customization
export PS1='\[\033[01;32m\]⚡ WireBusOS \[\033[01;34m\]\u@\h\[\033[00m\]:\[\033[01;36m\]\w\[\033[00m\]\$ '
export WIREBUS_HOME="/opt/wirebus"
alias python3-wirebus="/opt/wirebus/venv/bin/python3"
EOF
        fi
    fi

    # Configure skeleton user .bashrc
    if [[ -f "/etc/skel/.bashrc" ]]; then
        if ! grep -q "WIREBUS_HOME" /etc/skel/.bashrc; then
            cat << 'EOF' >> /etc/skel/.bashrc

# WireBusOS Environment Settings
export PS1='\[\033[01;32m\]⚡ WireBusOS \[\033[01;34m\]\u@\h\[\033[00m\]:\[\033[01;36m\]\w\[\033[00m\]\$ '
export WIREBUS_HOME="/opt/wirebus"
alias python3-wirebus="/opt/wirebus/venv/bin/python3"
EOF
        fi
    fi
}

setup_ubiquity_installer_customization() {
    log "Customizing Ubiquity live installer slides and metadata..."

    mkdir -p /var/log/installer
    chmod 755 /var/log/installer 2>/dev/null || true

    mkdir -p /usr/lib/ubiquity/ubiquity/targets /usr/share/ubiquity-slideshow/wirebusos/slides 2>/dev/null || true
    ln -sf ubuntu.py /usr/lib/ubiquity/ubiquity/targets/wirebusos.py 2>/dev/null || true
    ln -sf wirebusos /usr/share/ubiquity-slideshow/ubuntu 2>/dev/null || true

    cat << 'EOF' > /usr/share/ubiquity-slideshow/wirebusos/slides/welcome.html
<!DOCTYPE html>
<html>
<head>
<style>
body { background-color: #0D1417; color: #F8FAFC; font-family: 'DejaVu Sans', sans-serif; padding: 30px; }
h1 { color: #4CE293; font-size: 32px; margin-bottom: 10px; }
p { color: #94A3B8; font-size: 18px; line-height: 1.6; }
</style>
</head>
<body>
<h1>Welcome to WireBusOS v1.0.0 LTS</h1>
<p>The specialized open-source operating system engineered for solar PV, wind energy, battery storage, and microgrid power system modeling.</p>
</body>
</html>
EOF

    cat << 'EOF' > /usr/share/ubiquity-slideshow/wirebusos/slides/telemetry.html
<!DOCTYPE html>
<html>
<head>
<style>
body { background-color: #0D1417; color: #F8FAFC; font-family: 'DejaVu Sans', sans-serif; padding: 30px; }
h1 { color: #4CE293; font-size: 32px; margin-bottom: 10px; }
p { color: #94A3B8; font-size: 18px; line-height: 1.6; }
</style>
</head>
<body>
<h1>Pre-configured SCADA &amp; Telemetry</h1>
<p>Includes built-in Grafana, InfluxDB, Home Assistant, and SunSpec Modbus register maps for real-time power system monitoring.</p>
</body>
</html>
EOF
}

setup_modules_workspace() {
    log "Provisioning all 14 WireBusOS energy engineering modules into system & skeleton paths..."

    mkdir -p /opt/wirebus/modules /opt/wirebus/examples /etc/skel/WireBusOS-Modules

    if [[ -d "${REPO_DIR}/modules" ]]; then
        cp -r "${REPO_DIR}/modules/"* /opt/wirebus/modules/ 2>/dev/null || true
        cp -r "${REPO_DIR}/modules/"* /etc/skel/WireBusOS-Modules/ 2>/dev/null || true
    fi

    if [[ -d "${REPO_DIR}/examples" ]]; then
        cp -r "${REPO_DIR}/examples/"* /opt/wirebus/examples/ 2>/dev/null || true
        mkdir -p /etc/skel/WireBusOS-Modules/examples
        cp -r "${REPO_DIR}/examples/"* /etc/skel/WireBusOS-Modules/examples/ 2>/dev/null || true
    fi
}

setup_desktop_launchers() {
    log "Deploying WireBusOS application launchers and desktop shortcuts..."

    mkdir -p /usr/share/applications /etc/skel/Desktop

    # 1. Telemetry Dashboard
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

    # 2. WireBusOS Control Center
    cat << 'EOF' > /usr/share/applications/wirebus-control-center.desktop
[Desktop Entry]
Name=WireBusOS Control Center
Comment=Manage microgrid simulation daemons and telemetry
Exec=gnome-terminal -- /bin/bash -c "python3-wirebus -m http.server 8080"
Icon=preferences-system
Terminal=false
Type=Application
Categories=System;Settings;
EOF

    # 3. Solar PV Modeling Launcher
    cat << 'EOF' > /usr/share/applications/wirebus-solar-pv.desktop
[Desktop Entry]
Name=Solar PV Simulation Suite
Comment=Module 01 - PVLib & PySAM Solar Energy Modeling
Exec=gnome-terminal -- /bin/bash -c "cd /opt/wirebus/modules/01-solar-pv && python3-wirebus -i solar_pv_suite.py"
Icon=weather-clear
Terminal=false
Type=Application
Categories=Engineering;Science;
EOF

    # 4. Microgrid Modeling Launcher
    cat << 'EOF' > /usr/share/applications/wirebus-microgrid.desktop
[Desktop Entry]
Name=Microgrid Energy Systems Suite
Comment=Module 03 - PyPSA & Pandapower Grid Solver
Exec=gnome-terminal -- /bin/bash -c "cd /opt/wirebus/modules/03-microgrid-energy-systems && python3-wirebus -i grid_modeling_suite.py"
Icon=network-transmit-receive
Terminal=false
Type=Application
Categories=Engineering;Science;
EOF

    # 5. Ubiquity Installer
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

    # Copy to skeleton Desktop directory
    cp /usr/share/applications/wirebus-telemetry.desktop /etc/skel/Desktop/ 2>/dev/null || true
    cp /usr/share/applications/wirebus-control-center.desktop /etc/skel/Desktop/ 2>/dev/null || true
    cp /usr/share/applications/wirebus-solar-pv.desktop /etc/skel/Desktop/ 2>/dev/null || true
    cp /usr/share/applications/wirebus-microgrid.desktop /etc/skel/Desktop/ 2>/dev/null || true
    cp /usr/share/applications/ubiquity.desktop /etc/skel/Desktop/ 2>/dev/null || true
    chmod +x /etc/skel/Desktop/*.desktop 2>/dev/null || true
}

main() {
    log "Starting WireBusOS Complete Distro Customization Process..."

    setup_system_identity
    setup_dpkg_vendor_origin
    setup_wallpapers_and_assets
    setup_gnome_defaults
    setup_plymouth_boot_splash
    setup_grub_and_bootloader_debranding
    setup_fastfetch_branding
    setup_terminal_and_shell
    setup_ubiquity_installer_customization
    setup_modules_workspace
    setup_desktop_launchers

    log "WireBusOS Complete Customization Applied Successfully! ⚡🌱"
}

main "$@"
