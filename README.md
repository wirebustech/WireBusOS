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
| INDUSTRIAL SCADA & MODBUS CORE     |                         | TOP 20 COMMERCIAL VENDOR SUITE    |
| Grafana / InfluxDB / Home Assistant|                         | Victron, Pylontech, Siemens, SMA, |
| MQTT / DNP3 Gateways               |                         | Tesla, Vestas, GE, BYD, CATL, etc.|
+------------------------------------+                         +-----------------------------------+
```

---

## 🏭 Top 20 Renewable Energy Vendor Integrations

WireBusOS provides pre-mapped registers, protocol drivers, and SDK tools for the **Top 20 Commercial Vendors** in solar, wind, hydro, battery storage, and EV infrastructure:

| Category | Commercial Vendor & Ecosystem | Supported Hardware & Protocols | Driver Module |
|---|---|---|---|
| ☀️ **Solar** | **Victron Energy** | MultiPlus-II, Quattro, SmartSolar MPPT, Cerbo GX (VE.Direct / VE.Bus / VRM) | `vendor-drivers/victron_vrm_bridge.py` |
| ☀️ **Solar** | **LuxpowerTek** | LXP Hybrid 12k, SNA 5000, LXP-LB 5k (Lux Cloud / Modbus RTU) | `vendor-drivers/luxpower_cloud_client.py` |
| ☀️ **Solar** | **SMA Solar Technology** | Sunny Boy, Sunny Tripower CORE1, Sunny Island (Speedwire UDP) | `vendor-drivers/sma_fronius_drivers.py` |
| ☀️ **Solar** | **Fronius International** | Fronius Symo, Primo, Eco (Fronius Solar.API REST) | `vendor-drivers/sma_fronius_drivers.py` |
| ☀️ **Solar** | **SolarEdge** | SE10000H, SE33.3K, Energy Bank (SunSpec Modbus TCP) | Integrated via SunSpec Core |
| ☀️ **Solar** | **Enphase Energy** | IQ7+, IQ8M, IQ Battery 5P (Envoy Local API) | Integrated via Envoy Bridge |
| ☀️ **Solar** | **Growatt** | MIN 5000TL-XH, SPH 10000, MAX 125KTL3 (ShineServer API) | Integrated via Modbus RTU |
| ☀️ **Solar** | **Deye / Sol-Ark** | Deye SUN-12K, Sol-Ark 15K Hybrid Inverters (CANbus / Modbus) | Integrated via Hybrid Gateway |
| ☀️ **Solar** | **Solis (Ginlong)** | S5-GC60K, RHI-5K-Plus (SolisCloud API) | Integrated via Solis Adapter |
| ☀️ **Solar** | **ABB / Fimer** | PVS-100/120, REACT 2 Inverters (SunSpec Modbus TCP) | Integrated via Modbus Engine |
| 🔋 **Storage** | **Pylontech** | US2000C, US3000C, US5000, Force L1/L2 (CANbus 250kbps / RS485) | `vendor-drivers/pylontech_bms_reader.py` |
| 🔋 **Storage** | **Tesla Energy** | Powerwall 2, Powerwall 3, Megapack 2XL (Local Gateway API) | Integrated via Tesla Fleet API |
| 🔋 **Storage** | **BYD Energy** | Battery-Box Premium HVS/HVM/LVS (CANbus Protocol) | Integrated via CAN Adapter |
| 🔋 **Storage** | **CATL** | EnerOne LFP BESS, EnerC Grid Storage Containers (Modbus TCP) | Integrated via Storage Core |
| ⚙️ **Hydro** | **Siemens Energy** | S7-1200 / S7-1500 PLC, Spectrum Power SCADA (S7comm TCP 102) | `vendor-drivers/siemens_s7_scada.py` |
| ⚙️ **Hydro** | **Andritz Hydro** | Francis & Pelton Turbines, Metris DiOMera SCADA (Modbus TCP) | Integrated via Hydro Engine |
| 💨 **Wind** | **Vestas Wind Systems** | V150-4.2 MW, V162-6.2 MW EnVentus (VMP SCADA Gateway) | Integrated via Wind Gateway |
| 💨 **Wind** | **GE Vernova** | Haliade-X 12MW, GE 3.4MW, Mark VIe SCADA System | Integrated via Mark VIe Client |
| ⚡ **Grid** | **Schneider Electric** | Conext XW Pro, EcoStruxure Microgrid Advisor (Modbus TCP) | Integrated via EcoStruxure |
| 🔌 **EV** | **LF Energy EVerest / OpenEVSE** | EVerest Core Station, OpenEVSE (OCPP 1.6J / 2.0.1 Engine) | Integrated via EV Gateway |

---

## 🛠️ Adding Custom Vendor Applications (Extension SDK & CLI)

WireBusOS includes a modular **Vendor Extension SDK & CLI tool** allowing engineers to add custom vendor applications with auto-generated driver boilerplates:

### Command Line Interface (CLI):
```bash
# 1. List all registered vendors
python3 vendor-drivers/vendor_registry.py list

# 2. Register a new custom equipment vendor
python3 vendor-drivers/vendor_registry.py add --name "HydroTech" --category "hydro" --protocol "ModbusTCP" --devices "HydroTurbine-V1"
```
This automatically registers the equipment in `config/vendor_registers.json` and creates a runnable driver boilerplate in `vendor-drivers/hydrotech_driver.py`.

### Web Portal Interactive Builder:
Click the **"➕ Add Custom Vendor"** button on the WireBusOS Web Portal to define new equipment, specify register parameters, and generate Python driver code dynamically!

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
│   └── vendor_registers.json       # Top 20 Commercial Vendor registry
├── vendor-drivers/                 # Vendor Driver Suite & Extension SDK
│   ├── vendor_registry.py          # CLI Manager & Extension SDK
│   ├── victron_vrm_bridge.py       # Victron VE.Direct / VE.Bus / VRM API driver
│   ├── pylontech_bms_reader.py     # Pylontech CANbus & RS485 BMS decoder
│   ├── siemens_s7_scada.py         # Siemens S7-1200/1500 PLC S7comm driver
│   ├── luxpower_cloud_client.py    # LuxpowerTek inverter & Lux Cloud client
│   ├── sma_fronius_drivers.py      # SMA Speedwire & Fronius Solar.API drivers
│   └── templates/
│       └── custom_vendor_template.py # Boilerplate template for new custom vendors
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

## 📄 License

Licensed under the [MIT License](LICENSE).
