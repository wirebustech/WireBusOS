// WireBusOS Top 20 Commercial Vendors & Custom Driver Extension SDK

document.addEventListener('DOMContentLoaded', () => {
    initTop20Vendors();
    initModalForm();
    initSldSimulator();
    initModbusTable();
    initToolsCatalog();
    initTerminalReplay();
    initCopyButtons();
});

// Top 20 Commercial Renewable Energy Vendors Dataset
const TOP_20_VENDORS = [
    { name: "Victron Energy", category: "solar", ecosystem: "VE.Direct / VE.Bus / VRM Cloud API", devices: "MultiPlus-II, Quattro, SmartSolar MPPT, Cerbo GX", driver: "vendor-drivers/victron_vrm_bridge.py" },
    { name: "Pylontech", category: "storage", ecosystem: "CANbus 250kbps / RS485 Console", devices: "US2000C, US3000C, US5000, Force L1/L2 Stacks", driver: "vendor-drivers/pylontech_bms_reader.py" },
    { name: "Siemens Energy", category: "hydro", ecosystem: "S7comm TCP 102 / Spectrum Power SCADA", devices: "S7-1200, S7-1500 PLC, WinCC, Penstock Actuators", driver: "vendor-drivers/siemens_s7_scada.py" },
    { name: "LuxpowerTek", category: "solar", ecosystem: "Lux Cloud API / Modbus RTU RS485", devices: "LXP Hybrid 12k, SNA 5000, LXP-LB 5k Inverters", driver: "vendor-drivers/luxpower_cloud_client.py" },
    { name: "SMA Solar Technology", category: "solar", ecosystem: "Speedwire UDP Multicast / SunSpec", devices: "Sunny Boy, Sunny Tripower CORE1, Sunny Island", driver: "vendor-drivers/sma_fronius_drivers.py" },
    { name: "Fronius International", category: "solar", ecosystem: "Fronius Solar.API REST / SunSpec Modbus", devices: "Fronius Symo, Primo, Eco Inverters", driver: "vendor-drivers/sma_fronius_drivers.py" },
    { name: "SolarEdge Technologies", category: "solar", ecosystem: "SunSpec Modbus TCP / Monitoring API", devices: "SE10000H, SE33.3K, Energy Bank Storage", driver: "Built-in SunSpec Engine" },
    { name: "Tesla Energy", category: "storage", ecosystem: "Tesla Local Gateway 2 API / Fleet API", devices: "Powerwall 2, Powerwall 3, Megapack 2XL", driver: "Built-in Tesla Bridge" },
    { name: "Enphase Energy", category: "solar", ecosystem: "Envoy IQ Gateway Local API", devices: "IQ7+, IQ8M Microinverters, IQ Battery 5P", driver: "Built-in Envoy Driver" },
    { name: "Growatt New Energy", category: "solar", ecosystem: "ShineServer API / Modbus RTU RS485", devices: "MIN 5000TL-XH, SPH 10000, MAX 125KTL3", driver: "Built-in Growatt Gateway" },
    { name: "Deye / Sol-Ark", category: "solar", ecosystem: "Hybrid Inverter CANbus & Modbus RTU", devices: "Deye SUN-12K-SG04, Sol-Ark 15K Hybrid", driver: "Built-in Hybrid Adapter" },
    { name: "Solis (Ginlong)", category: "solar", ecosystem: "SolisCloud API / Modbus RS485", devices: "S5-GC60K, RHI-5K-Plus Hybrid Inverter", driver: "Built-in Solis Adapter" },
    { name: "Schneider Electric", category: "grid", ecosystem: "EcoStruxure Microgrid Advisor / Conext", devices: "Conext XW Pro, EcoStruxure PLC Gateway", driver: "Built-in Schneider Gateway" },
    { name: "ABB / Fimer", category: "solar", ecosystem: "PVS Inverter SunSpec Modbus TCP", devices: "PVS-100/120 Commercial, REACT 2 Storage", driver: "Built-in ABB Modbus Driver" },
    { name: "Vestas Wind Systems", category: "wind", ecosystem: "Vestas VMP / Online SCADA Gateway", devices: "V150-4.2 MW, V162-6.2 MW EnVentus Turbines", driver: "Built-in Vestas SCADA" },
    { name: "GE Vernova", category: "wind", ecosystem: "Mark VIe Control SCADA / Hydro & Wind", devices: "GE Haliade-X 12MW, GE 3.4MW, GE Hydro Governor", driver: "Built-in GE Mark VIe Driver" },
    { name: "BYD Energy", category: "storage", ecosystem: "Battery-Box Premium CANbus Protocol", devices: "Battery-Box Premium HVS/HVM, LVS Stacks", driver: "Built-in BYD CAN Driver" },
    { name: "CATL", category: "storage", ecosystem: "EnerOne / EnerC Grid Storage Modbus TCP", devices: "EnerOne LFP BESS, EnerC Storage Container", driver: "Built-in CATL Storage Core" },
    { name: "Andritz Hydro", category: "hydro", ecosystem: "Metris DiOMera Hydro SCADA", devices: "Francis Hydro Turbine, Pelton Wheel, Kaplan", driver: "Built-in Andritz Hydro Driver" },
    { name: "LF Energy EVerest / OpenEVSE", category: "ev", ecosystem: "OCPP 1.6J / 2.0.1 EV Charger Gateway", devices: "EVerest Core Station, OpenEVSE WiFi v5", driver: "Built-in OCPP Engine" }
];

// Unified Equipment Registers
const ALL_REGISTERS = [
    { vendor: "Victron Energy", address: "0xED8D", name: "VE_Bus_State", type: "UINT16", unit: "enum", desc: "0=Off, 3=Inverting, 4=Bulk, 5=Absorption" },
    { vendor: "Victron Energy", address: "0x0304", name: "VE_Direct_PV_Power", type: "UINT16", unit: "W", desc: "MPPT Real-time Panel Yield" },
    { vendor: "Pylontech", address: "CAN 0x355", name: "BMS_SOC_SOH", type: "UINT16", unit: "%", desc: "Stack SOC & SOH Percentage" },
    { vendor: "Pylontech", address: "CAN 0x356", name: "BMS_Voltage_Current", type: "INT16", unit: "V / A", desc: "Stack Voltage & Current" },
    { vendor: "Siemens Energy", address: "DB10.DBD0", name: "Hydro_Flow_Rate", type: "REAL", unit: "m3/s", desc: "Penstock Hydro Turbine Flow Rate" },
    { vendor: "Siemens Energy", address: "DB10.DBD4", name: "Penstock_Pressure", type: "REAL", unit: "bar", desc: "Hydraulic Penstock Pressure" },
    { vendor: "LuxpowerTek", address: "REG 040", name: "Lux_PV1_Power", type: "UINT16", unit: "W", desc: "Solar String 1 DC Power" },
    { vendor: "SMA Solar", address: "30775", name: "SMA_Grid_Power", type: "INT32", unit: "W", desc: "Total AC Output Power" },
    { vendor: "Tesla Energy", address: "API_SOC", name: "Tesla_Battery_SOC", type: "FLOAT", unit: "%", desc: "Powerwall State of Charge" },
    { vendor: "Vestas Wind", address: "VMP_P_Act", name: "Vestas_Active_Power", type: "FLOAT", unit: "kW", desc: "Wind Turbine Power Output" },
    { vendor: "CATL", address: "40201", name: "CATL_Rack_SOC", type: "UINT16", unit: "%", desc: "EnerOne Storage Rack SOC" }
];

// Initialize Top 20 Vendors Cards
function initTop20Vendors() {
    const grid = document.getElementById('top20-vendors-grid');
    const tabs = document.querySelectorAll('#vendor-category-tabs .filter-btn');

    let activeCategory = 'all';

    // Load custom vendors saved in localStorage if any
    const savedCustomVendors = JSON.parse(localStorage.getItem('wirebus_custom_vendors') || '[]');
    const combinedVendors = [...TOP_20_VENDORS, ...savedCustomVendors];

    function renderVendors() {
        grid.replaceChildren();

        const filtered = combinedVendors.filter(v => {
            return activeCategory === 'all' || v.category === activeCategory;
        });

        filtered.forEach(v => {
            const card = document.createElement('div');
            card.className = 'glass-card tool-card';

            const cardTop = document.createElement('div');

            const tag = document.createElement('span');
            tag.className = 'tool-tag';
            tag.textContent = (v.category || 'GENERAL').toUpperCase();

            const title = document.createElement('h3');
            title.className = 'tool-name';
            title.textContent = v.name;

            const eco = document.createElement('p');
            eco.className = 'tool-desc';
            eco.textContent = `📡 ${v.ecosystem}`;

            const dev = document.createElement('p');
            dev.style.fontSize = '0.78rem';
            dev.style.color = '#64748b';
            dev.style.marginTop = '6px';
            dev.textContent = `⚙️ Devices: ${v.devices}`;

            cardTop.appendChild(tag);
            cardTop.appendChild(title);
            cardTop.appendChild(eco);
            cardTop.appendChild(dev);

            const driver = document.createElement('div');
            driver.className = 'tool-repo';
            driver.textContent = `📄 ${v.driver}`;

            card.appendChild(cardTop);
            card.appendChild(driver);

            grid.appendChild(card);
        });
    }

    tabs.forEach(tab => {
        tab.addEventListener('click', () => {
            tabs.forEach(t => t.classList.remove('active'));
            tab.classList.add('active');
            activeCategory = tab.getAttribute('data-vcat');
            renderVendors();
        });
    });

    renderVendors();
}

// Modal Form Handler for Adding Custom Vendor Application
function initModalForm() {
    const modal = document.getElementById('add-vendor-modal');
    const openBtn1 = document.getElementById('btn-open-add-vendor');
    const openBtn2 = document.getElementById('btn-trigger-modal-sec');
    const closeBtn = document.getElementById('btn-close-modal');
    const cancelBtn = document.getElementById('btn-cancel-modal');
    const form = document.getElementById('add-vendor-form');

    function openModal() { modal.classList.add('active'); }
    function closeModal() { modal.classList.remove('active'); }

    if (openBtn1) openBtn1.addEventListener('click', openModal);
    if (openBtn2) openBtn2.addEventListener('click', openModal);
    if (closeBtn) closeBtn.addEventListener('click', closeModal);
    if (cancelBtn) cancelBtn.addEventListener('click', closeModal);

    form.addEventListener('submit', (e) => {
        e.preventDefault();

        const name = document.getElementById('vendor-name-input').value.trim();
        const category = document.getElementById('vendor-cat-select').value;
        const protocol = document.getElementById('vendor-proto-select').value;
        const devices = document.getElementById('vendor-devices-input').value.trim();
        const regInput = document.getElementById('vendor-reg-input').value.trim();

        const safeFilename = name.toLowerCase().replace(/ /g, '_').replace(/-/g, '_') + '_driver.py';

        const newVendorObj = {
            name: `${name} (Custom)`,
            category: category,
            ecosystem: `${protocol} Custom Integration`,
            devices: devices,
            driver: `vendor-drivers/${safeFilename}`
        };

        // Save custom vendor to local storage
        const saved = JSON.parse(localStorage.getItem('wirebus_custom_vendors') || '[]');
        saved.push(newVendorObj);
        localStorage.setItem('wirebus_custom_vendors', JSON.stringify(saved));

        // Add to Modbus Register Explorer
        if (regInput) {
            const parts = regInput.split(',');
            if (parts.length >= 4) {
                ALL_REGISTERS.unshift({
                    vendor: name,
                    address: parts[0].trim(),
                    name: parts[1].trim(),
                    type: parts[2].trim(),
                    unit: parts[3].trim(),
                    desc: `Custom ${protocol} Signal`
                });
            }
        }

        alert(`✅ Custom Vendor Driver successfully generated!\nFile: vendor-drivers/${safeFilename}\nRegistered in WireBusOS SDK.`);
        form.reset();
        closeModal();

        // Refresh UI
        initTop20Vendors();
        initModbusTable();
    });
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

// Tools Catalog Renderer
function initToolsCatalog() {
    // Keep clean
}

// Replay Terminal Simulator
function initTerminalReplay() {
    const termBody = document.getElementById('terminal-output');
    const replayBtn = document.getElementById('btn-replay-term');

    const lines = [
        { text: "[WireBusOS SDK] Loaded WireBusOS Top 20 Vendor Registry...", type: "" },
        { text: "[WireBusOS SDK] Victron Energy | Solar | VE.Bus / VE.Direct / VRM", type: "info" },
        { text: "[WireBusOS SDK] Siemens Energy | Hydro | S7comm TCP 102 / Spectrum SCADA", type: "success" },
        { text: "[WireBusOS SDK] Vestas Wind | Wind | VMP SCADA Gateway", type: "highlight" },
        { text: "[WireBusOS SDK] CATL BESS | Storage | EnerOne Modbus TCP", type: "" }
    ];

    function runReplay() {
        termBody.replaceChildren();
        lines.forEach((line, index) => {
            setTimeout(() => {
                const lineDiv = document.createElement('div');
                lineDiv.className = `term-line ${line.type}`;

                const promptSpan = document.createElement('span');
                promptSpan.className = 'prompt';
                promptSpan.textContent = line.text.substring(0, 18);

                const contentText = document.createTextNode(line.text.substring(18));

                lineDiv.appendChild(promptSpan);
                lineDiv.appendChild(contentText);
                termBody.appendChild(lineDiv);
            }, index * 350);
        });
    }

    if (replayBtn) replayBtn.addEventListener('click', runReplay);
}

// Copy Buttons Helper
function initCopyButtons() {
    document.querySelectorAll('.copy-btn').forEach(btn => {
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
