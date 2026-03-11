# Project Brief: Industrial Maintenance Analytics

## Roadmap
- Phase 1: Data ingestion and warehouse setup
- Phase 2: Build staging and core models for asset, maintenance, and telemetry data
- Phase 3: Develop marts for reporting and analytics
- Phase 4: Implement advanced analytics (predictive maintenance, anomaly detection)
- Phase 5: Dashboarding and business intelligence integration

## Objectives
- Centralize all industrial maintenance data in a single analytics warehouse (BigQuery)
- Enable robust reporting on asset health, maintenance activities, and operational efficiency
- Support data-driven decision making for maintenance planning and resource allocation
- Lay the foundation for predictive maintenance and advanced analytics

## Metrics & KPIs
- Mean Time Between Failures (MTBF)
- Mean Time To Repair (MTTR)
- Asset Utilization Rate
- Maintenance Cost per Asset
- Number of Unplanned Downtimes
- Spare Parts Usage Rate
- Work Order Completion Rate
- Sensor Anomaly Rate

## Other Relevant Information
- Data sources: asset master, maintenance logs, sensor telemetry, work orders, spare parts, environmental conditions, equipment specs, service contracts
- All data is loaded via dbt seeds and modeled in dbt
- Project follows dbt best practices: modularity, documentation, testing, and version control
- Collaboration via GitHub (feature branches, PRs, code review)
- Warehouse: Google BigQuery

---
This file should be updated as the project evolves to reflect new objectives, deliverables, and learnings.
