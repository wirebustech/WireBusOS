# WireBusOS ⚡🌱

**WireBusOS** is a specialized, open-source Linux distribution remastered using **Cubic (Custom Ubuntu ISO Creator)** engineered for power systems engineering, renewable energy dispatch modeling, microgrid optimal power flow (OPF), battery electrochemistry, industrial SCADA telemetry (Modbus/DNP3/MQTT), and commercial equipment integrations.

```
                  +-------------------------------------------------------------+
                  |               WIREBUSOS SYSTEM ARCHITECTURE                 |
                  +-------------------------------------------------------------+
                                                 |
         +------------------------+--------------+--------------+------------------------+
         |                        |                             |                        |
+------------------+    +-------------------+         +-------------------+    +------------------+
| SOLAR PV ENGINE  |    | WIND AERO-ELASTIC |         | MICROGRID OPF     |    | ELECTROCHEMISTRY |
| pvlib / PySAM    |    | OpenFAST / QBlade |         | PyPSA / pandapower|    | PyBaMM / OpenEMS |
+------------------+    +-------------------+         +-------------------+    +------------------+
         |                        |                             |                        |
         +------------------------+--------------+--------------+------------------------+
                                                 |
         +---------------------------------------+---------------------------------------+
         |                                                                               |
+------------------------------------+                         +-----------------------------------+
| INDUSTRIAL SCADA & MODBUS CORE     |                         | COMMERCIAL VENDOR SUITE           |
| Grafana / InfluxDB / Home Assistant|                         | Victron / Pylontech / Siemens     |
| MQTT / DNP3 Gateways               |                         | Luxpower / SMA / Fronius / Tesla  |
+------------------------------------+                         +-----------------------------------+
```

---

## 🏭 Commercial & Industrial Vendor System Compatibility

WireBusOS includes native protocol drivers, serial frame parsers, and API bridge tools (`vendor-drivers/`) for leading commercial renewable energy equipment:

| Equipment Category | Vendor & Ecosystem | Protocol / Interface | Included WireBusOS Driver |
|---|---|---|---|
| **Inverters & Charge Controllers** | **Victron Energy** | VE.Direct / VE.Bus / VRM API | [`vendor-drivers/victron_vrm_bridge.py`](vendor-drivers/victron_vrm_bridge.py) |
| **Battery Stacks (BMS)** | **Pylontech** | CANbus (250kbps) / RS485 | [`vendor-drivers/pylontech_bms_reader.py`](vendor-drivers/pylontech_bms_reader.py) |
| **Industrial SCADA & Hydro/Wind** | **Siemens Energy** | S7comm (Port 102) / Spectrum SCADA | [`vendor-drivers/siemens_s7_scada.py`](vendor-drivers/siemens_s7_scada.py) |
| **Hybrid & Off-Grid Inverters** | **LuxpowerTek** | Lux Cloud / Modbus RTU | [`vendor-drivers/luxpower_cloud_client.py`](vendor-drivers/luxpower_cloud_client.py) |
| **Commercial Solar Inverters** | **SMA & Fronius** | Speedwire UDP / Solar.API | [`vendor-drivers/sma_fronius_drivers.py`](vendor-drivers/sma_fronius_drivers.py) |
| **Residential & Commercial BESS** | **Tesla Energy** | Powerwall / Megapack Gateway API | Integrated via Home Assistant Core |
| **Microinverters** | **Enphase Energy** | Envoy Local API (IQ Gateway) | Integrated via Home Assistant Core |
| **Enterprise Inverters** | **SolarEdge / Schneider / Deye / Solis** | SunSpec Modbus TCP / EcoStruxure | Integrated via Modbus SCADA Engine |

---

## ⚡ Technical Physics & Modeling Modules

- **PyPSA** (`PyPSA/PyPSA`) — Solves AC/DC Optimal Power Flow with network constraints ($P_i + jQ_i = V_i \sum_{j=1}^N Y_{ij}^* V_j^*$).
- **pandapower** — Industrial network calculation engine for line overloading, short-circuit, and switchyard analysis.
- **ANDES** — Dynamic transient stability & differential-algebraic equation (DAE) simulator.
- **pvlib-python** — Solar positioning (SPA), plane-of-array (POA) transposition, and cell temperature modeling.
- **OpenFAST & QBlade** — Aero-hydro-servo-elastic solver coupling BEMT (Blade Element Momentum Theory) aerodynamics.
- **PyBaMM** — Solves Single Particle Model (SPM) partial differential equations for lithium-ion cell degradation.

---

## 📦 Repository Structure

```
WireBusOS/
├── build-scripts/
│   ├── install-wirebus.sh          # Installer with --chroot Cubic remastering support
│   ├── wirebus-first-boot.sh       # First-boot provisioning engine
│   └── first-boot-wirebus.service  # Systemd deferred startup unit
├── config/
│   ├── packages-core.txt           # APT package manifest (QGIS, KiCad, FreeCAD, OpenModelica)
│   ├── requirements-energy.txt     # Python scientific library manifest
│   ├── docker-compose.yml          # Telemetry stack (Grafana, InfluxDB, Home Assistant)
│   ├── modbus_scada_map.json       # Modbus TCP SCADA register mapping
│   └── vendor_registers.json       # Commercial vendor (Victron, Pylontech, Siemens) registry
├── vendor-drivers/                 # Commercial Vendor Protocol Drivers
│   ├── victron_vrm_bridge.py       # Victron VE.Direct / VE.Bus / VRM API driver
│   ├── pylontech_bms_reader.py     # Pylontech CANbus & RS485 BMS decoder
│   ├── siemens_s7_scada.py         # Siemens S7-1200/1500 PLC S7comm driver
│   ├── luxpower_cloud_client.py    # LuxpowerTek inverter & Lux Cloud client
│   └── sma_fronius_drivers.py      # SMA Speedwire & Fronius Solar.API drivers
├── examples/                       # Technical Reference Models
│   ├── pvlib_irradiance.py         # Plane-of-array solar simulation
│   ├── pypsa_powerflow.py          # 5-bus optimal power flow
│   ├── pybamm_battery_degradation.py# Battery SEI degradation
│   ├── openfast_wind_simulation.py # BEMT wind turbine aerodynamic power curve
│   └── scada_modbus_client.py      # Modbus TCP SCADA telemetry logger
├── docs/
│   ├── CUBIC_ISO_BUILD_GUIDE.md    # Step-by-step ISO remastering guide
│   └── RENEWABLE_SUITE.md          # Detailed upstream package index
├── website/                        # Technical Workstation Portal & Microgrid Visualizer
│   ├── index.html
│   ├── style.css
│   └── app.js
├── LICENSE
└── README.md
```

---

## 🛠️ Remastering WireBusOS with Cubic

To create a bootable `.iso` image using Cubic:

```bash
# Inside the Cubic chroot shell:
cd /root
git clone https://github.com/wirebustech/WireBusOS.git
cd WireBusOS
chmod +x build-scripts/install-wirebus.sh
./build-scripts/install-wirebus.sh --chroot
```

For full details, see [`docs/CUBIC_ISO_BUILD_GUIDE.md`](docs/CUBIC_ISO_BUILD_GUIDE.md).

---

## 📄 License

Licensed under the [MIT License](LICENSE).
