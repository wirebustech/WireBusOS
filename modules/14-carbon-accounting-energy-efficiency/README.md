# Carbon Content & Energy Efficiency Measurement Module

This module contains open-source repositories and tools for measuring regional grid carbon intensity ($gCO_2eq/kWh$), Scope 1/2/3 corporate greenhouse gas (GHG) accounting, energy efficiency Measurement & Verification (M&V), and Life Cycle Assessment (LCA).

## Included Open Source GitHub Repositories

| Tool | Upstream Repository | Description |
|---|---|---|
| **CodeCarbon** | [`mlco2/codecarbon`](https://github.com/mlco2/codecarbon) | Real-time carbon emissions ($kgCO_2eq$) & power tracking ($kW$) based on local grid intensity |
| **openEEmeter** | [`LF-Energy/openEEmeter`](https://github.com/LF-Energy/openEEmeter) | Standardized energy efficiency measurement & verification (M&V) implementing CalTRACK & IPMVP |
| **Green Metrics Tool** | [`green-coding-solutions/green-metrics-tool`](https://github.com/green-coding-solutions/green-metrics-tool) | Software pipeline energy efficiency & carbon emissions metrics engine |
| **ghg-calculator** | [`starrybodies/ghg-calculator`](https://github.com/starrybodies/ghg-calculator) | Open-source GHG Protocol corporate emissions standard (Scope 1, Scope 2, Scope 3) |
| **OWID CO2 Dataset** | [`owid/co2-data`](https://github.com/owid/co2-data) | Global power grid carbon intensity datasets ($gCO_2/kWh$), energy mix, and historical emissions |
| **Kepler** | [`sustainable-computing-io/kepler`](https://github.com/sustainable-computing-io/kepler) | Kubernetes & eBPF system workload energy efficiency and carbon exporter |

## Carbon Accounting Metrics Covered

- **Grid Carbon Intensity ($I_{grid}$)**: $gCO_2eq / kWh$
- **Scope 1 Emissions**: Direct combustion emissions (boilers, generators, natural gas)
- **Scope 2 Emissions**: Location-based & market-based indirect electricity grid emissions
- **Scope 3 Emissions**: Supply chain, transmission & distribution losses
- **CalTRACK Energy Savings**: Verified weather-normalized kWh energy efficiency savings

## Running the Carbon & Efficiency Suite

```bash
python3 modules/14-carbon-accounting-energy-efficiency/carbon_efficiency_suite.py
```
