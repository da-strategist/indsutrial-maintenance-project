# Industrial Maintenance Analytics

A dbt project for centralising and modelling industrial maintenance data in Google BigQuery.

## Project Overview

This project ingests raw industrial maintenance data via dbt seeds and builds a layered analytics model following dbt best practices.

## Data Sources

| Seed | Description |
|------|-------------|
| `asset_master` | Master data for all physical assets |
| `environmental_conditions` | Environmental readings (temperature, humidity, dust) per asset |
| `equipment_specs` | Specifications and lifecycle data for equipment types |
| `maintenance_logs` | Records of completed maintenance activities |
| `sensor_telemetry` | Time-series sensor readings (temperature, vibration, pressure) |
| `service_contracts` | Service contract details and annual values |
| `spare_parts_usage` | Spare parts consumed per work order |
| `usage_cycles` | Equipment usage cycle records |
| `work_orders` | Work orders for maintenance activities |

## Project Structure

```
inds_proj/
├── seeds/          # Raw CSV data loaded into BigQuery (<schema>_raw)
├── models/
│   └── staging/    # Staging models — typed and renamed views over raw seeds
├── macros/         # Reusable Jinja macros (e.g. cents_to_dollars)
└── dbt_project.yml
```

## Roadmap

See [project_brief.md](project_brief.md) for the full roadmap and objectives.

- **Phase 1** — Data ingestion and warehouse setup ✅
- **Phase 2** — Staging models for all source tables ✅
- **Phase 3** — Core and mart models for reporting
- **Phase 4** — Predictive maintenance and anomaly detection
- **Phase 5** — Dashboarding and BI integration

## Key Metrics & KPIs

- Mean Time Between Failures (MTBF)
- Mean Time To Repair (MTTR)
- Asset Utilisation Rate
- Maintenance Cost per Asset
- Work Order Completion Rate
- Sensor Anomaly Rate

## Getting Started

```bash
# Install dbt packages
cd inds_proj && dbt deps

# Load seed data
dbt seed

# Build staging models
dbt run --select staging

# Run tests
dbt test --select staging
```
