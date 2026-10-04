# Data Engineering, Telemetry & Visualisation Module

This module contains analytical in-process SQL engines, spatial & time-series relational databases, operational SCADA dashboards, and GIS visualization tools.

## Included Open Source Tools

| Tool | Upstream Repository | Description |
|---|---|---|
| **DuckDB** | [`duckdb/duckdb`](https://github.com/duckdb/duckdb) | In-process analytical SQL database for high-performance energy data processing |
| **PostgreSQL** | [`postgres/postgres`](https://github.com/postgres/postgres) | Relational database server with PostGIS spatial and TimescaleDB time-series extensions |
| **Grafana** | [`grafana/grafana`](https://github.com/grafana/grafana) | Operational telemetry visualization & interactive SCADA dashboards |
| **QGIS** | [`qgis/QGIS`](https://github.com/qgis/QGIS) | Geospatial GIS data visualization, spatial analysis, and map rendering engine |
| **Home Assistant** | [`home-assistant/core`](https://github.com/home-assistant/core) | Smart home & energy inverter integration platform |
| **emoncms** | [`openenergymonitor/emoncms`](https://github.com/openenergymonitor/emoncms) | OpenEnergyMonitor logging & graphing platform |

## Running the Data Engineering & Visualisation Suite

```bash
python3 modules/06-monitoring-scada-iot/monitoring_scada_suite.py
```

