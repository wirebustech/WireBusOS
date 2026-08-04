// WireBusOS Commercial Vendor & Technical Energy Web Application

document.addEventListener('DOMContentLoaded', () => {
    initVendorNavigator();
    initSldSimulator();
    initSandboxEditor();
    initModbusTable();
    initToolsCatalog();
    initTerminalReplay();
    initCopyButtons();
});

// Vendor Data Dictionary
const VENDOR_DETAILS = {
    victron: {
        title: "Victron Energy Ecosystem Driver",
        filename: "vendor-drivers/victron_vrm_bridge.py",
        devices: [
            "MultiPlus-II & Quattro Inverter-Chargers (VE.Bus)",
            "SmartSolar & BlueSolar MPPT Charge Controllers (VE.Direct)",
            "Cerbo GX, Ekrano GX & Color Control GX Gateways",
            "SmartShunt & BMV Battery Monitors"
        ],
        protocols: ["VE.Direct RS232", "VE.Bus CAN", "VRM REST API", "Venus OS dbus"],
        cmd: "python3 vendor-drivers/victron_vrm_bridge.py"
    },
    pylontech: {
        title: "Pylontech Lithium BMS Protocol Decoder",
        filename: "vendor-drivers/pylontech_bms_reader.py",
        devices: [
            "US2000C / US3000C / US5000 48V Rack Battery Modules",
            "Force L1 & Force L2 High Voltage Battery Stacks",
            "Pelio Home Energy Storage System"
        ],
        protocols: ["CANbus (250 kbps)", "RS485 Console (115200)", "Modbus RTU"],
        cmd: "python3 vendor-drivers/pylontech_bms_reader.py"
    },
    siemens: {
        title: "Siemens Energy S7comm & SCADA Gateway",
        filename: "vendor-drivers/siemens_s7_scada.py",
        devices: [
            "Siemens S7-1200 / S7-1500 Industrial PLCs",
            "Spectrum Power SCADA Control Systems",
            "WinCC Open Architecture HMI Gateways",
            "SIPROTEC 5 Substation Protection Relays"
        ],
        protocols: ["S7comm (TCP 102)", "PROFINET", "IEC 60870-5-104", "DNP3"],
        cmd: "python3 vendor-drivers/siemens_s7_scada.py"
    },
    luxpower: {
        title: "LuxpowerTek Hybrid Inverter & Cloud API Client",
        filename: "vendor-drivers/luxpower_cloud_client.py",
        devices: [
            "Luxpower LXP Hybrid 12k & LXP-LB 5k",
            "SNA 5000 Off-Grid Inverters",
            "Wi-Fi & LAN Dongle Gateways"
        ],
        protocols: ["Lux Cloud REST API", "Modbus RTU (RS485)", "TCP Port 8000"],
        cmd: "python3 vendor-drivers/luxpower_cloud_client.py"
    },
    sma: {
        title: "SMA Speedwire & Fronius Solar.API Drivers",
        filename: "vendor-drivers/sma_fronius_drivers.py",
        devices: [
            "SMA Sunny Boy, Sunny Tripower CORE1 & Sunny Island",
            "Fronius Symo, Primo, and Eco Inverters",
            "Fronius Datamanager 2.0 & Smart Meter"
        ],
        protocols: ["Speedwire UDP Multicast", "Fronius Solar.API JSON", "SunSpec Modbus"],
        cmd: "python3 vendor-drivers/sma_fronius_drivers.py"
    }
};

// Unified Equipment Registers
const ALL_REGISTERS = [
    { vendor: "Victron Energy", address: "0xED8D", name: "VE_Bus_State", type: "UINT16", unit: "enum", desc: "0=Off, 3=Inverting, 4=Bulk, 5=Absorption" },
    { vendor: "Victron Energy", address: "0x0304", name: "VE_Direct_PV_Power", type: "UINT16", unit: "W", desc: "SmartSolar MPPT Real-time Yield" },
    { vendor: "Pylontech", address: "CAN 0x355", name: "BMS_SOC_SOH", type: "UINT16", unit: "%", desc: "Stack SOC & SOH Percentage" },
    { vendor: "Pylontech", address: "CAN 0x356", name: "BMS_Voltage_Current", type: "INT16", unit: "V / A", desc: "Stack Voltage (0.01V) & Current (0.1A)" },
    { vendor: "Siemens Energy", address: "DB10.DBD0", name: "Hydro_Flow_Rate", type: "REAL", unit: "m3/s", desc: "Hydro Turbine Volumetric Flow" },
    { vendor: "Siemens Energy", address: "DB10.DBD4", name: "Penstock_Pressure", type: "REAL", unit: "bar", desc: "Hydraulic Penstock Pressure" },
    { vendor: "LuxpowerTek", address: "REG 040", name: "Lux_PV1_Power", type: "UINT16", unit: "W", desc: "Solar String 1 DC Power" },
    { vendor: "LuxpowerTek", address: "REG 080", name: "Lux_Battery_SOC", type: "UINT16", unit: "%", desc: "Lithium Battery SOC Percentage" },
    { vendor: "SMA Solar", address: "30775", name: "SMA_Grid_Power", type: "INT32", unit: "W", desc: "Total AC Output Power" },
    { vendor: "SunSpec", address: "40071", name: "AC_Active_Power", type: "INT16", unit: "W", desc: "Total Real Power Output (P)" },
    { vendor: "SunSpec", address: "40072", name: "AC_Frequency", type: "UINT16", unit: "Hz", desc: "Line AC Operating Frequency (f)" }
];

// Python Sandbox Code Snippets
const PYTHON_MODELS = {
    victron: {
        filename: "vendor-drivers/victron_vrm_bridge.py",
        code: `import os, json

# Victron Energy VE.Direct & VRM Cloud API Driver
def fetch_victron_data(vrm_site_id="12345"):
    ve_direct_frame = {
        "PID": "0xA042",     # SmartSolar MPPT 250/100
        "V": "53.40",        # Battery Volts
        "PPV": "4192",       # Solar Array Yield (W)
        "CS": "3"            # State: Bulk
    }
    print(f"Victron MPPT Yield: {ve_direct_frame['PPV']} W")
    return ve_direct_frame

fetch_victron_data()`
    },
    pylontech: {
        filename: "vendor-drivers/pylontech_bms_reader.py",
        code: `# Pylontech CANbus BMS Frame Decoder (US2000/US3000/US5000/Force L1)
def parse_pylon_can(can_id="0x355"):
    bms_data = {
        "stack_voltage_v": 52.8,
        "soc_percent": 82,
        "soh_percent": 98,
        "max_charge_a": 100.0
    }
    print(f"Pylontech Battery Stack SOC: {bms_data['soc_percent']}%")
    return bms_data

parse_pylon_can()`
    },
    siemens: {
        filename: "vendor-drivers/siemens_s7_scada.py",
        code: `# Siemens S7comm Protocol Driver (S7-1200 / S7-1500 PLC)
def read_siemens_db(db_num=10):
    s7_data = {
        "hydro_flow_m3s": 14.5,
        "pressure_bar": 12.8,
        "generator_rpm": 750
    }
    print(f"Siemens S7 DB{db_num}: Hydro Flow={s7_data['hydro_flow_m3s']} m³/s")
    return s7_data

read_siemens_db()`
    },
    pvlib: {
        filename: "examples/pvlib_irradiance.py",
        code: `import pvlib, pandas as pd

# Solar PV Irradiance Transposition Model
times = pd.date_range('2026-06-21 06:00', '2026-06-21 19:00', freq='1h', tz='America/Los_Angeles')
solpos = pvlib.solarposition.get_solarposition(times, lat=37.7749, lon=-122.4194)
poa = pvlib.irradiance.get_total_irradiance(30, 180, solpos['apparent_zenith'], solpos['azimuth'], 900, 100, 100)
print(f"Peak POA: {poa['poa_global'].max():.2f} W/m²")`
    }
};

// Vendor Ecosystem Navigator Switcher
function initVendorNavigator() {
    const btns = document.querySelectorAll('.vendor-card-btn');
    const titleEl = document.getElementById('vendor-detail-title');
    const fileEl = document.getElementById('vendor-detail-file');
    const listEl = document.getElementById('vendor-device-list');
    const protoEl = document.getElementById('vendor-proto-tags');
    const codeEl = document.getElementById('vendor-code-snippet');

    function selectVendor(vendorKey) {
        const details = VENDOR_DETAILS[vendorKey];
        if (!details) return;

        titleEl.textContent = details.title;
        fileEl.textContent = details.filename;
        codeEl.textContent = details.cmd;

        listEl.replaceChildren();
        details.devices.forEach(dev => {
            const li = document.createElement('li');
            li.textContent = dev;
            listEl.appendChild(li);
        });

        protoEl.replaceChildren();
        details.protocols.forEach(proto => {
            const span = document.createElement('span');
            span.className = 'proto-badge';
            span.textContent = proto;
            protoEl.appendChild(span);
        });
    }

    btns.forEach(btn => {
        btn.addEventListener('click', () => {
            btns.forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            selectVendor(btn.getAttribute('data-vendor'));
        });
    });

    selectVendor('victron');
}

// Single Line Diagram Physics Simulator
function initSldSimulator() {
    const solarSlider = document.getElementById('solar-slider');
    const windSlider = document.getElementById('wind-slider');
    const loadSlider = document.getElementById('load-slider');

    const solarVal = document.getElementById('solar-val');
    const windVal = document.getElementById('wind-val');
    const loadVal = document.getElementById('load-val');

    const metricPv = document.getElementById('metric-pv');
    const metricWind = document.getElementById('metric-wind');
    const metricBus = document.getElementById('metric-bus');
    const metricBattery = document.getElementById('metric-battery');
    const metricLoad = document.getElementById('metric-load');

    function updatePhysics() {
        const irr = parseFloat(solarSlider.value);
        const windSpeed = parseFloat(windSlider.value);
        const load = parseFloat(loadSlider.value);

        solarVal.textContent = `${irr} W/m²`;
        windVal.textContent = `${windSpeed} m/s`;
        loadVal.textContent = `${load.toFixed(1)} kW`;

        const pvKw = (irr / 1000.0) * 35.0;
        const windKw = windSpeed < 3.0 ? 0 : Math.min(45.0, Math.pow(windSpeed / 12.0, 3) * 25.0);
        const totalGen = pvKw + windKw;
        const netDeltaP = totalGen - load;

        metricPv.textContent = `P = ${pvKw.toFixed(1)} kW`;
        metricWind.textContent = `P = ${windKw.toFixed(1)} kW`;
        metricLoad.textContent = `P = ${load.toFixed(1)} kW`;

        metricBus.textContent = `Total Gen: ${totalGen.toFixed(1)} kW | Net Delta P: ${netDeltaP >= 0 ? '+' : ''}${netDeltaP.toFixed(1)} kW`;

        if (netDeltaP >= 0) {
            metricBattery.textContent = `Charging: +${netDeltaP.toFixed(1)} kW`;
            metricBattery.style.color = '#00ff9d';
        } else {
            const deficit = Math.abs(netDeltaP);
            metricBattery.textContent = `Discharging: -${deficit.toFixed(1)} kW`;
            metricBattery.style.color = '#ffb700';
        }
    }

    solarSlider.addEventListener('input', updatePhysics);
    windSlider.addEventListener('input', updatePhysics);
    loadSlider.addEventListener('input', updatePhysics);
    updatePhysics();
}

// Sandbox Editor Code Switcher
function initSandboxEditor() {
    const tabs = document.querySelectorAll('.tab-btn');
    const filenameEl = document.getElementById('sandbox-filename');
    const codeDisplay = document.getElementById('sandbox-code-display');
    const copyBtn = document.getElementById('btn-copy-sandbox');

    let activeKey = 'victron';

    function loadSnippet(key) {
        activeKey = key;
        const model = PYTHON_MODELS[key];
        filenameEl.textContent = model.filename;
        codeDisplay.textContent = model.code;
    }

    tabs.forEach(tab => {
        tab.addEventListener('click', () => {
            tabs.forEach(t => t.classList.remove('active'));
            tab.classList.add('active');
            loadSnippet(tab.getAttribute('data-model'));
        });
    });

    copyBtn.addEventListener('click', () => {
        navigator.clipboard.writeText(PYTHON_MODELS[activeKey].code).then(() => {
            const orig = copyBtn.textContent;
            copyBtn.textContent = 'Copied!';
            setTimeout(() => copyBtn.textContent = orig, 2000);
        });
    });

    loadSnippet('victron');
}

// SCADA Modbus Table Renderer
function initModbusTable() {
    const tableBody = document.getElementById('modbus-table-body');
    const searchInput = document.getElementById('modbus-search');

    function renderTable(filterTerm = '') {
        tableBody.replaceChildren();

        const filtered = ALL_REGISTERS.filter(reg => {
            return reg.vendor.toLowerCase().includes(filterTerm) ||
                   reg.address.toLowerCase().includes(filterTerm) ||
                   reg.name.toLowerCase().includes(filterTerm) ||
                   reg.unit.toLowerCase().includes(filterTerm) ||
                   reg.desc.toLowerCase().includes(filterTerm);
        });

        filtered.forEach(reg => {
            const tr = document.createElement('tr');

            const tdVendor = document.createElement('td');
            tdVendor.textContent = reg.vendor;
            tdVendor.style.fontWeight = '700';
            tdVendor.style.color = '#00ff9d';

            const tdAddr = document.createElement('td');
            tdAddr.textContent = reg.address;
            tdAddr.style.fontWeight = '700';
            tdAddr.style.color = '#00f0ff';

            const tdName = document.createElement('td');
            tdName.textContent = reg.name;

            const tdType = document.createElement('td');
            tdType.textContent = reg.type;

            const tdUnit = document.createElement('td');
            tdUnit.textContent = reg.unit;

            const tdDesc = document.createElement('td');
            tdDesc.textContent = reg.desc;

            tr.appendChild(tdVendor);
            tr.appendChild(tdAddr);
            tr.appendChild(tdName);
            tr.appendChild(tdType);
            tr.appendChild(tdUnit);
            tr.appendChild(tdDesc);

            tableBody.appendChild(tr);
        });
    }

    searchInput.addEventListener('input', (e) => {
        renderTable(e.target.value.toLowerCase().trim());
    });

    renderTable();
}

// Tools Catalog Dummy Renderer
function initToolsCatalog() {
    const filterBtns = document.querySelectorAll('.filter-btn');
    filterBtns.forEach(btn => {
        btn.addEventListener('click', () => {
            filterBtns.forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
        });
    });
}

// Replay Terminal Simulator
function initTerminalReplay() {
    const termBody = document.getElementById('terminal-output');
    const replayBtn = document.getElementById('btn-replay-term');

    const lines = [
        { text: "[WireBusOS Gateway] Connecting to Victron Cerbo GX & Pylontech CANbus...", type: "" },
        { text: "[WireBusOS Gateway] VE.Direct: SmartSolar MPPT 250/100 -> PV Yield: 4,192 W", type: "info" },
        { text: "[WireBusOS Gateway] Pylontech CAN 0x355: US5000 Stack SOC: 82% | SOH: 98%", type: "success" },
        { text: "[WireBusOS Gateway] Siemens S7-1500 DB10: Penstock Pressure: 12.8 bar", type: "highlight" },
        { text: "[WireBusOS Gateway] Streaming commercial vendor telemetry to InfluxDB / Grafana", type: "" }
    ];

    function runReplay() {
        termBody.replaceChildren();
        lines.forEach((line, index) => {
            setTimeout(() => {
                const lineDiv = document.createElement('div');
                lineDiv.className = `term-line ${line.type}`;

                const promptSpan = document.createElement('span');
                promptSpan.className = 'prompt';
                promptSpan.textContent = line.text.substring(0, 20);

                const contentText = document.createTextNode(line.text.substring(20));

                lineDiv.appendChild(promptSpan);
                lineDiv.appendChild(contentText);
                termBody.appendChild(lineDiv);
            }, index * 350);
        });
    }

    replayBtn.addEventListener('click', runReplay);
}

// Copy Buttons Helper
function initCopyButtons() {
    document.querySelectorAll('.copy-btn').forEach(btn => {
        if (btn.id === 'btn-copy-sandbox') return;
        btn.addEventListener('click', () => {
            const textToCopy = btn.getAttribute('data-copy');
            if (textToCopy) {
                navigator.clipboard.writeText(textToCopy).then(() => {
                    const orig = btn.textContent;
                    btn.textContent = 'Copied!';
                    setTimeout(() => btn.textContent = orig, 2000);
                });
            }
        });
    });
}
