<p align="center">
  <img src="assets/wirebusos_horizontal_logo.svg" alt="WireBusOS — Energy Systems Platform Logo" width="650">
</p>

<p align="center">
  <b>A specialized open-source Linux distribution engineered for power systems analysis, renewable microgrids, battery electrochemistry, and SCADA automation.</b>
</p>

---

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
| Grafana / InfluxDB / Home Assistant|                         | Victron, Pylontech, Siemens, SMA, |
| MQTT / DNP3 Gateways               |                         | Tesla, Vestas, GE, BYD, CATL, etc.|
+------------------------------------+                         +-----------------------------------+
```

---

## 🏭 Commercial Renewable Energy Vendor Integrations

WireBusOS provides pre-mapped registers, protocol drivers, and SDK tools for commercial vendors in solar, wind, hydro, battery storage, and EV infrastructure:

| Category | Commercial Vendor & Ecosystem | Supported Hardware & Protocols | Driver Module |
|---|---|---|---|
| ☀️ **Solar** | **Victron Energy** | MultiPlus-II, Quattro, SmartSolar MPPT, Cerbo GX (VE.Direct / VE.Bus / VRM) | `vendor-drivers/victron_vrm_bridge.py` |
| ☀️ **Solar** | **LuxpowerTek** | LXP Hybrid 12k, SNA 5000, LXP-LB 5k (Lux Cloud / Modbus RTU) | `vendor-drivers/luxpower_cloud_client.py` |
| ☀️ **Solar** | **SMA Solar Technology** | Sunny Boy, Sunny Tripower CORE1, Sunny Island (Speedwire UDP) | `vendor-drivers/sma_fronius_drivers.py` |
| ☀️ **Solar** | **Fronius International** | Fronius Symo, Primo, Eco (Fronius Solar.API REST) | `vendor-drivers/sma_fronius_drivers.py` |
| ☀️ **Solar** | **SolarEdge** | SE10000H, SE33.3K, Energy Bank (SunSpec Modbus TCP) | Integrated via SunSpec Engine |
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

## 📂 12 Functional Module Directories

WireBusOS is organized into 12 functional tool directories:

```
WireBusOS/
├── assets/                         # Official Logo & Graphic Assets
│   ├── wirebusos_icon.svg          # 512x512 Icon Badge
│   └── wirebusos_horizontal_logo.svg # 900x220 Horizontal Logo
├── modules/                        # 12 Functional Tool Directories
│   ├── 01-solar-pv/                # pvlib-python, NREL SAM, PySAM, PVGIS, r.sun
│   ├── 02-wind-energy/             # OpenFAST, FAST.Farm, QBlade, windpowerlib
│   ├── 03-microgrid-energy-systems/# PyPSA, oemof, Calliope, OSeMOSYS, SWITCH, Temoa, etc.
│   ├── 04-battery-storage/         # PyBaMM, OpenEMS
│   ├── 05-building-energy/         # EnergyPlus, OpenStudio
│   ├── 06-monitoring-scada-iot/    # Home Assistant, emoncms, Node-RED, Grafana, ThingsBoard
│   ├── 07-cad-electronics-design/  # KiCad, FreeCAD, QElectroTech, ngspice
│   ├── 08-simulation-framework/    # OpenModelica
│   ├── 09-gis-spatial/             # QGIS, GRASS GIS
│   ├── 10-lf-energy-projects/      # GridAPPS-D, OpenSTEF, PowerGridModel, OperatorFabric, openEEmeter
│   ├── 11-ev-charging/             # EVerest Core, OpenEVSE
│   └── 12-data-science-base/       # NumPy, pandas, SciPy, matplotlib, JupyterLab
├── vendor-drivers/                 # Vendor Driver Suite & Extension SDK
│   ├── vendor_registry.py          # CLI Manager & Extension SDK
│   ├── victron_vrm_bridge.py       # Victron VE.Direct / VE.Bus / VRM API driver
│   ├── pylontech_bms_reader.py     # Pylontech CANbus & RS485 BMS decoder
│   ├── siemens_s7_scada.py         # Siemens S7-1200/1500 PLC S7comm driver
│   ├── luxpower_cloud_client.py    # LuxpowerTek inverter & Lux Cloud client
│   ├── sma_fronius_drivers.py      # SMA Speedwire & Fronius Solar.API drivers
│   └── templates/
│       └── custom_vendor_template.py # Boilerplate template for new custom vendors
├── build-scripts/                  # Installer & Systemd provisioning hooks
├── docs/                           # ISO build guide & package catalog
├── website/                        # Technical Workstation Portal & Microgrid Visualizer
├── LICENSE
└── README.md
```

---

## 📄 License

Licensed under the [MIT License](LICENSE).
