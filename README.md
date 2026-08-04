# WireBusOS ⚡🌱

**WireBusOS** is a specialized, open-source Linux distribution remastered using **Cubic (Custom Ubuntu ISO Creator)** engineered specifically for power systems engineering, renewable energy dispatch modeling, microgrid optimal power flow (OPF), battery electrochemistry, SCADA telemetry (Modbus/DNP3/MQTT), and electrical/mechanical CAD design.

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
                         +-----------------------------------------------+
                         | SINGLE-LINE DIAGRAM (SLD) & MODBUS SCADA CORE |
                         | Grafana / InfluxDB / Home Assistant / MQTT    |
                         +-----------------------------------------------+
```

---

## ⚡ Technical Modules & Physics Engines

WireBusOS unifies over 30+ domain-specific open-source libraries into an integrated Ubuntu 24.04 LTS kernel environment:

### 1. Power Systems & Grid Optimal Power Flow (OPF)
- **PyPSA** (`PyPSA/PyPSA`) — Solves AC/DC Optimal Power Flow with network constraints ($P_i + jQ_i = V_i \sum_{j=1}^N Y_{ij}^* V_j^*$).
- **pandapower** (`e2nIEE/pandapower`) — Industrial network calculation engine for line overloading, short-circuit, and switchyard analysis.
- **ANDES** (`cuihantao/andes`) — Transient stability & differential-algebraic equation (DAE) dynamic simulator.
- **OpenDSS** & **GridLAB-D** — Multiphase unbalanced distribution feeder analysis.

### 2. Photovoltaic & Irradiance Engineering
- **pvlib-python** (`pvlib/pvlib-python`) — Solves solar positioning (SPA), plane-of-array (POA) transposition (Hay-Davies/Perez), and cell temperature modeling.
- **NREL SAM & PySAM** (`NREL/SAM`, `NREL/pysam`) — Financial techno-economic analysis & LCOE optimization.

### 3. Aero-Elastic Wind Turbine Dynamics
- **OpenFAST** (`OpenFAST/openfast`) — NREL aero-hydro-servo-elastic solver coupling BEMT (Blade Element Momentum Theory) aerodynamics with structural dynamics.
- **QBlade** (`qblade/qblade`) — Blade polar generation, lift/drag ($C_L / C_D$) curves, and structural finite element analysis (FEA).

### 4. Battery Electrochemistry & Storage
- **PyBaMM** (`pybamm-team/PyBaMM`) — Solves Single Particle Model (SPM) and Doyle-Fuller-Newman (DFN) continuum partial differential equations for lithium-ion cell degradation.
- **OpenEMS** (`OpenEMS/openems`) — Microgrid energy management system with real-time controller loops.

### 5. Industrial SCADA Telemetry & Protocols
- **Modbus TCP / DNP3 / MQTT Stack** — Native support for SunSpec inverter registers, PLC protocol gateways, and Grafana time-series operational dashboards.
- **Home Assistant & emoncms** — Edge site automation and continuous energy logging.

### 6. Electrical & Mechanical CAD
- **KiCad** & **ngspice** — Power electronics PCB design, gate driver simulation, and thermal analysis.
- **FreeCAD** & **QElectroTech** — Mechanical solar mounting design and 3-phase single-line wiring schematics.

---

## 📐 Electrical Single-Line Diagram (SLD) Topology

```
 [ GRID TIE: 13.8kV ]
         |
    (Transformer: 13.8kV / 480V, 1.5 MVA)
         |
=================== MAIN 480V AC BUS =================== [f = 60.00 Hz, PF = 0.98]
    |               |               |               |
[PV Array]     [Wind Array]   [Battery BESS]  [Site Load]
 100 kW DC      150 kW AC      250 kWh / 100 kW 200 kW Peak
 (Inverter)    (Aero-Elastic)  (NMC SPM)
```

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
│   └── modbus_scada_map.json       # Modbus TCP SCADA register mapping
├── examples/                       # Runnable Technical Reference Models
│   ├── pvlib_irradiance.py         # Plane-of-array solar simulation script
│   ├── pypsa_powerflow.py          # 5-bus optimal power flow script
│   └── pybamm_battery_degradation.py# Battery SEI degradation script
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

## 💻 Running Technical Examples

Execute the pre-bundled power engineering simulation scripts directly:

```bash
# 1. Run Solar Irradiance Simulation
python3 examples/pvlib_irradiance.py

# 2. Run 5-Bus Optimal Power Flow
python3 examples/pypsa_powerflow.py

# 3. Run Lithium-ion Cell Degradation Model
python3 examples/pybamm_battery_degradation.py
```

---

## 🛠️ Remastering WireBusOS with Cubic

To create a bootable `.iso` image using Cubic:

1. **Host Requirements**: Ubuntu 24.04 Desktop VM with at least **100 GB** disk space and **8 GB** RAM.
2. **Install Cubic**:
   ```bash
   sudo apt-add-repository universe -y
   sudo apt-add-repository ppa:cubic-wizard/release -y
   sudo apt update -y
   sudo apt install cubic -y
   ```
3. **Launch Cubic** and select an official Ubuntu 24.04 LTS Desktop ISO.
4. In the **Cubic chroot terminal**, execute:
   ```bash
   cd /root
   git clone https://github.com/wirebustech/WireBusOS.git
   cd WireBusOS
   chmod +x build-scripts/install-wirebus.sh
   ./build-scripts/install-wirebus.sh --chroot
   ```
5. Click **Generate** to create `WireBusOS-24.04-amd64.iso`.

For full details, see [`docs/CUBIC_ISO_BUILD_GUIDE.md`](docs/CUBIC_ISO_BUILD_GUIDE.md).

---

## 🌐 WireBusOS Engineering Portal

Explore the web workstation portal featuring live single-line diagram (SLD) power flows, Modbus register explorer, and Python sandbox:

```bash
python3 -m http.server --directory website 8085
```
Access at [`http://localhost:8085`](http://localhost:8085).

---

## 📄 License

Licensed under the [MIT License](LICENSE).
