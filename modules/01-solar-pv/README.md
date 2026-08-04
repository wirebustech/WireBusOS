# Solar PV Design & Simulation Module

This module contains tools, libraries, and reference models for solar irradiance transposition, photovoltaic array performance, degradation analysis, and techno-economic modeling.

## Included Open Source Tools

| Tool | Upstream Repository | Description |
|---|---|---|
| **pvlib-python** | [`pvlib/pvlib-python`](https://github.com/pvlib/pvlib-python) | Core Python library for PV modeling, irradiance, system performance & degradation |
| **NREL SAM** | [`NREL/SAM`](https://github.com/NREL/SAM) | System Advisor Model techno-economic engine for PV, CSP & geothermal |
| **PySAM** | [`NREL/pysam`](https://github.com/NREL/pysam) | Python wrapper for SAM's simulation engine |
| **PVGIS API** | EU JRC Web Service | Solar resource mapping & PV performance calculation web service |
| **r.sun** | GRASS GIS Module | Solar radiation raster modeling integrated into GRASS GIS |

## Running the Solar PV Suite Model

```bash
python3 modules/01-solar-pv/solar_pv_suite.py
```
