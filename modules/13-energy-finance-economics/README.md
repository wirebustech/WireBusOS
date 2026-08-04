# Energy Finance, Techno-Economics & PPA Modeling Module

This module contains open-source repositories, financial calculation engines, Levelized Cost of Energy (LCOE) models, Power Purchase Agreement (PPA) cash flow simulators, and project feasibility tools.

## Included Open Source GitHub Repositories

| Repository | GitHub Path | Description |
|---|---|---|
| **pyPPA** | [`PLANiT-Institute/pyPPA`](https://github.com/PLANiT-Institute/pyPPA) | PPA modeling, renewable procurement, storage arbitrage, and tariff optimization |
| **PySAM Financials** | [`NREL/pysam`](https://github.com/NREL/pysam) | NREL PPA Single Owner, Merchant Plant, Residential/Commercial DCF cash flows |
| **levelisedcost** | [`PLANiT-Institute/levelisedcost`](https://github.com/PLANiT-Institute/levelisedcost) | Integrated Levelized Cost of Energy (LCOE) & Hydrogen (LCOH) framework |
| **PyThermoNomics** | [`pythermonomics/pythermonomics`](https://github.com/pythermonomics/pythermonomics) | Geothermal & thermal project NPV, LCOE, and cash flow analysis |
| **lazard_lcoe** | [`fraboniface/lazard_lcoe`](https://github.com/fraboniface/lazard_lcoe) | Python reproduction of Lazard's Levelized Cost of Energy benchmark model |
| **OpenPyTEA** | [`OpenPyTEA/OpenPyTEA`](https://github.com/OpenPyTEA/OpenPyTEA) | Open toolkit for transparent techno-economic analysis (TEA) workflows |
| **BioSTEAM** | [`BioSTEAMDevelopmentGroup/biosteam`](https://github.com/BioSTEAMDevelopmentGroup/biosteam) | Agile techno-economic analysis and life-cycle assessment (LCA) engine |
| **ppa_analysis** | [`EllieKallmier/ppa_analysis`](https://github.com/EllieKallmier/ppa_analysis) | Commercial & Industrial (C&I) PPA portfolio structuring & risk assessment |
| **Sustainable Finance** | [`open-risk/awesome-sustainable-finance`](https://github.com/open-risk/awesome-sustainable-finance) | Curated hub for climate finance, ESG metrics, and carbon risk accounting |

## Financial Modeling Metrics Covered

- **LCOE ($/MWh)**: $\text{LCOE} = \frac{\sum_{t=0}^{N} \frac{\text{CAPEX}_t + \text{OPEX}_t}{(1 + r)^t}}{\sum_{t=1}^{N} \frac{\text{Energy}_t}{(1 + r)^t}}$
- **Net Present Value (NPV)** & **Internal Rate of Return (IRR)**
- **Discounted Cash Flow (DCF)** over 20-30 year project lifetimes
- **Debt Service Coverage Ratio (DSCR)** & Debt Sculpting
- **P50 / P75 / P90 Yield Risk Sensitivity**

## Running the Energy Finance Suite

```bash
python3 modules/13-energy-finance-economics/energy_finance_suite.py
```
