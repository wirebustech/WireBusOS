// WireBusOS Technical Energy Engineering Web Application

document.addEventListener('DOMContentLoaded', () => {
    initSldSimulator();
    initSandboxEditor();
    initModbusTable();
    initToolsCatalog();
    initTerminalReplay();
    initCopyButtons();
});

// Modbus TCP Register Data
const MODBUS_REGISTERS = [
    { address: 40071, name: "AC_Active_Power", type: "INT16", unit: "W", scale: 1, desc: "Total Real Power Output (P)" },
    { address: 40072, name: "AC_Frequency", type: "UINT16", unit: "Hz", scale: 0.01, desc: "Line AC Operating Frequency (f)" },
    { address: 40073, name: "AC_Reactive_Power", type: "INT16", unit: "VAR", scale: 1, desc: "Total Reactive Power Output (Q)" },
    { address: 40074, name: "Power_Factor", type: "INT16", unit: "cos phi", scale: 0.001, desc: "Grid Power Factor (cos φ)" },
    { address: 40101, name: "Battery_SOC", type: "UINT16", unit: "%", scale: 0.1, desc: "Battery State of Charge" },
    { address: 40102, name: "Battery_SOH", type: "UINT16", unit: "%", scale: 0.1, desc: "Battery State of Health" },
    { address: 40103, name: "DC_Bus_Voltage", type: "UINT16", unit: "V", scale: 0.1, desc: "Common DC Bus Operating Voltage" }
];

// Python Sandbox Code Snippets
const PYTHON_MODELS = {
    pvlib: {
        filename: "examples/pvlib_irradiance.py",
        code: `import pvlib
import pandas as pd

# Solar PV Transposition & Irradiance Model
times = pd.date_range('2026-06-21 06:00', '2026-06-21 19:00', freq='1h', tz='America/Los_Angeles')
solpos = pvlib.solarposition.get_solarposition(times, lat=37.7749, lon=-122.4194)
ineichen = pvlib.clearsky.ineichen(solpos['apparent_zenith'], airmass=1.5)

poa = pvlib.irradiance.get_total_irradiance(
    surface_tilt=30, surface_azimuth=180,
    solar_zenith=solpos['apparent_zenith'], solar_azimuth=solpos['azimuth'],
    dni=ineichen['dni'], ghi=ineichen['ghi'], dhi=ineichen['dhi']
)

print(f"Peak POA Irradiance: {poa['poa_global'].max():.2f} W/m²")`
    },
    pypsa: {
        filename: "examples/pypsa_powerflow.py",
        code: `import pypsa

# 5-Bus AC/DC Microgrid Optimal Power Flow (OPF)
network = pypsa.Network()
for i in range(1, 6):
    network.add("Bus", f"Bus {i}", v_nom=0.48) # 480V AC

network.add("Generator", "Solar PV", bus="Bus 2", p_nom=200, marginal_cost=0.01)
network.add("Generator", "Wind Turbine", bus="Bus 5", p_nom=150, marginal_cost=0.02)
network.add("StorageUnit", "Battery BESS", bus="Bus 4", p_nom=100, max_hours=4)
network.add("Load", "Industrial Load", bus="Bus 3", p_set=280)

status, condition = network.optimize()
print(f"Optimal Dispatch Status: {status}")`
    },
    pybamm: {
        filename: "examples/pybamm_battery_degradation.py",
        code: `import pybamm

# Lithium-ion Single Particle Model (SPM) with SEI Degradation
model = pybamm.lithium_ion.SPM({
    "SEI": "ec reaction limited",
    "SEI film resistance": "distributed"
})

parameter_values = pybamm.ParameterValues("Chen2020")
sim = pybamm.Simulation(model, parameter_values=parameter_values)
sol = sim.solve([0, 3600])

print(f"Final Terminal Voltage: {sol['Terminal voltage [V]'].entries[-1]:.3f} V")`
    }
};

// Tool Catalog Data
const ENERGY_TOOLS = [
    { name: "pvlib-python", category: "solar", repo: "pvlib/pvlib-python", desc: "Core Python library for PV performance, irradiance, and degradation modeling." },
    { name: "NREL SAM", category: "solar", repo: "NREL/SAM", desc: "System Advisor Model techno-economic engine for solar PV, CSP, and wind." },
    { name: "PySAM", category: "solar", repo: "NREL/pysam", desc: "Python wrapper for NREL SAM simulation engine." },
    { name: "r.sun", category: "solar", repo: "OSGeo/grass", desc: "Solar radiation raster calculations integrated into GRASS GIS." },

    { name: "OpenFAST", category: "wind", repo: "OpenFAST/openfast", desc: "NREL wind turbine aero-hydro-servo-elastic simulator." },
    { name: "FAST.Farm", category: "wind", repo: "OpenFAST/openfast", desc: "Wind farm-level wake and atmospheric dynamic simulation." },
    { name: "QBlade", category: "wind", repo: "qblade/qblade", desc: "Wind turbine blade aerodynamics & aero-elastic design tool." },
    { name: "windpowerlib", category: "wind", repo: "wind-python/windpowerlib", desc: "Python library to model wind turbine power output from weather data." },

    { name: "PyPSA", category: "grid", repo: "PyPSA/PyPSA", desc: "Power system analysis, optimal power flow, and sector-coupled grid planning." },
    { name: "oemof-solph", category: "grid", repo: "oemof/oemof-solph", desc: "Linear optimization framework for cross-sector energy systems." },
    { name: "Calliope", category: "grid", repo: "calliope-project/calliope", desc: "Multi-scale energy system optimization modeling framework." },
    { name: "pandapower", category: "grid", repo: "e2nIEE/pandapower", desc: "Power system flow, optimal power flow, and short-circuit analysis in Python." },
    { name: "OpenDSS", category: "grid", repo: "electricdss/electricdss-src", desc: "Electric power distribution system simulator." },
    { name: "ANDES", category: "grid", repo: "cuihantao/andes", desc: "Power system dynamic simulation & differential-algebraic equation solver." },

    { name: "PyBaMM", category: "storage", repo: "pybamm-team/PyBaMM", desc: "Physics-based electrochemical battery continuum modeling." },
    { name: "OpenEMS", category: "storage", repo: "OpenEMS/openems", desc: "Energy management system for energy storage deployments." },

    { name: "Home Assistant", category: "scada", repo: "home-assistant/core", desc: "Inverter, battery, meter, and EV charger automation engine." },
    { name: "emoncms", category: "scada", repo: "openenergymonitor/emoncms", desc: "Energy monitoring visual logging dashboard." },
    { name: "ThingsBoard", category: "scada", repo: "thingsboard/thingsboard", desc: "Enterprise IoT & SCADA telemetry platform." },

    { name: "KiCad", category: "cad", repo: "KiCad/kicad-source-mirror", desc: "Schematic capture & PCB layout for inverters & BMS electronics." },
    { name: "FreeCAD", category: "cad", repo: "FreeCAD/FreeCAD", desc: "Parametric 3D mechanical CAD for solar mounts and turbine parts." },
    { name: "QElectroTech", category: "cad", repo: "QElectroTech/qelectrotech", desc: "Electrical single-line diagrams and schematics." },
    { name: "ngspice", category: "cad", repo: "ngspice/ngspice", desc: "Open-source SPICE circuit simulator." }
];

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
    const metricGrid = document.getElementById('metric-grid');

    const telFreq = document.getElementById('tel-freq');
    const telPgen = document.getElementById('tel-pgen');
    const telQgen = document.getElementById('tel-qgen');

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
            metricGrid.textContent = `P_grid = 0.0 kW`;
        } else {
            const deficit = Math.abs(netDeltaP);
            if (deficit <= 50.0) {
                metricBattery.textContent = `Discharging: -${deficit.toFixed(1)} kW`;
                metricBattery.style.color = '#ffb700';
                metricGrid.textContent = `P_grid = 0.0 kW`;
            } else {
                const gridImport = deficit - 50.0;
                metricBattery.textContent = `Max Discharge: -50.0 kW`;
                metricBattery.style.color = '#ff5f56';
                metricGrid.textContent = `Grid Import: ${gridImport.toFixed(1)} kW`;
            }
        }

        // Update header telemetry bar values
        const freqOffset = (netDeltaP * 0.002).toFixed(2);
        const freqVal = (60.00 + parseFloat(freqOffset)).toFixed(2);
        telFreq.textContent = `${freqVal} Hz`;
        telPgen.textContent = `${totalGen.toFixed(1)} kW`;
        telQgen.textContent = `+${(totalGen * 0.15).toFixed(1)} kVAR`;
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

    let activeKey = 'pvlib';

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

    loadSnippet('pvlib');
}

// SCADA Modbus Table Renderer
function initModbusTable() {
    const tableBody = document.getElementById('modbus-table-body');
    const searchInput = document.getElementById('modbus-search');

    function renderTable(filterTerm = '') {
        tableBody.replaceChildren();

        const filtered = MODBUS_REGISTERS.filter(reg => {
            return reg.address.toString().includes(filterTerm) ||
                   reg.name.toLowerCase().includes(filterTerm) ||
                   reg.unit.toLowerCase().includes(filterTerm) ||
                   reg.desc.toLowerCase().includes(filterTerm);
        });

        filtered.forEach(reg => {
            const tr = document.createElement('tr');

            const tdAddr = document.createElement('td');
            tdAddr.textContent = reg.address;
            tdAddr.style.fontWeight = '700';
            tdAddr.style.color = '#00f0ff';

            const tdName = document.createElement('td');
            tdName.textContent = reg.name;

            const tdType = document.createElement('td');
            tdType.textContent = reg.type;

            const tdScale = document.createElement('td');
            tdScale.textContent = reg.scale;

            const tdUnit = document.createElement('td');
            tdUnit.textContent = reg.unit;
            tdUnit.style.color = '#00ff9d';

            const tdDesc = document.createElement('td');
            tdDesc.textContent = reg.desc;

            tr.appendChild(tdAddr);
            tr.appendChild(tdName);
            tr.appendChild(tdType);
            tr.appendChild(tdScale);
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

// Tools Catalog Renderer
function initToolsCatalog() {
    const gridContainer = document.getElementById('tools-grid');
    const filterBtns = document.querySelectorAll('.filter-btn');
    const searchInput = document.getElementById('suite-search');

    let currentCategory = 'all';
    let currentSearch = '';

    function renderCards() {
        gridContainer.replaceChildren();

        const filtered = ENERGY_TOOLS.filter(tool => {
            const matchesCategory = (currentCategory === 'all' || tool.category === currentCategory);
            const matchesSearch = tool.name.toLowerCase().includes(currentSearch) ||
                                  tool.desc.toLowerCase().includes(currentSearch) ||
                                  tool.repo.toLowerCase().includes(currentSearch);
            return matchesCategory && matchesSearch;
        });

        filtered.forEach(tool => {
            const card = document.createElement('div');
            card.className = 'glass-card tool-card';

            const cardTop = document.createElement('div');

            const tag = document.createElement('span');
            tag.className = 'tool-tag';
            tag.textContent = tool.category.toUpperCase();

            const title = document.createElement('h3');
            title.className = 'tool-name';
            title.textContent = tool.name;

            const desc = document.createElement('p');
            desc.className = 'tool-desc';
            desc.textContent = tool.desc;

            cardTop.appendChild(tag);
            cardTop.appendChild(title);
            cardTop.appendChild(desc);

            const repo = document.createElement('div');
            repo.className = 'tool-repo';
            repo.textContent = `📦 ${tool.repo}`;

            card.appendChild(cardTop);
            card.appendChild(repo);

            gridContainer.appendChild(card);
        });
    }

    filterBtns.forEach(btn => {
        btn.addEventListener('click', () => {
            filterBtns.forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            currentCategory = btn.getAttribute('data-category');
            renderCards();
        });
    });

    searchInput.addEventListener('input', (e) => {
        currentSearch = e.target.value.toLowerCase().trim();
        renderCards();
    });

    renderCards();
}

// Replay Terminal Simulator
function initTerminalReplay() {
    const termBody = document.getElementById('terminal-output');
    const replayBtn = document.getElementById('btn-replay-term');

    const lines = [
        { text: "[WireBusOS Grid Engine] Initializing 5-Bus Microgrid Model...", type: "" },
        { text: "[WireBusOS Grid Engine] AC Bus Nominal Voltage: 0.48 kV (480V)", type: "" },
        { text: "[WireBusOS Grid Engine] Solving LOPF equations (P_net = V_i * sum(V_j * Y_ij))...", type: "info" },
        { text: "[WireBusOS Grid Engine] Solar PV: 28.5 kW | Wind: 20.0 kW | Battery: +6.5 kW Charging", type: "success" },
        { text: "[WireBusOS Grid Engine] Grid Balance Reached: f = 60.00 Hz | Line Loading: < 45%", type: "highlight" }
    ];

    function runReplay() {
        termBody.replaceChildren();
        lines.forEach((line, index) => {
            setTimeout(() => {
                const lineDiv = document.createElement('div');
                lineDiv.className = `term-line ${line.type}`;

                const promptSpan = document.createElement('span');
                promptSpan.className = 'prompt';
                promptSpan.textContent = line.text.substring(0, 23);

                const contentText = document.createTextNode(line.text.substring(23));

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
