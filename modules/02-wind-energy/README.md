# Wind Energy Engineering Module

This module contains aero-elastic wind turbine solvers, rotor aerodynamic blade element momentum theory (BEMT) tools, farm-level wake flow models, and wind power curve calculators.

## Included Open Source Tools

| Tool | Upstream Repository | Description |
|---|---|---|
| **OpenFAST** | [`OpenFAST/openfast`](https://github.com/OpenFAST/openfast) | NREL's aero-hydro-servo-elastic wind turbine simulation engine |
| **FAST.Farm** | Bundled with OpenFAST | Wind farm-level wake and atmospheric dynamic simulation |
| **QBlade** | [`qblade/qblade`](https://github.com/qblade/qblade) | Wind turbine blade design and aero-elastic simulation |
| **windpowerlib** | [`wind-python/windpowerlib`](https://github.com/wind-python/windpowerlib) | Python wind power output modeling based on weather data |

## Running the Wind Energy Suite Model

```bash
python3 modules/02-wind-energy/wind_energy_suite.py
```
