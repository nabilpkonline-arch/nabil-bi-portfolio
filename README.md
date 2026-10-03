# Nabil P K — Data Analytics & BI Portfolio

Four end-to-end analytics projects built to demonstrate SQL, Power Query,
Power BI, and applied AI skills against a realistic UAE MEP trading
business — the same domain I worked in at Hydro Sanitary Ware Trading.

**UAE MEP trading dataset** — customers, suppliers, RFQs, purchase orders,
inventory, and financials

## Repository structure

```
nabil-bi-portfolio/
├── README.md                              <- you are here
├── shared-database/
│   ├── generate_data.py                   <- builds the dataset (seeded, reproducible)
│   ├── schema.sql                         <- portable schema (SQL Server / Postgres / MySQL notes included)
│   ├── mep_trading.db                     <- ready-to-use SQLite database
│   └── data/*.csv                         <- 12 CSV tables (also usable directly in Power Query)
├── sql-practice/
│   ├── 50_sql_queries.sql                 <- 55 queries, basic → intermediate, all tested
│   └── build_and_test_queries.py          <- proof they all execute without error
├── project-1-uae-sales-intelligence/
├── project-2-mep-procurement-analytics/
├── project-3-finance-fpa-dashboard/
└── project-4-ai-bi-system/
```

## The dataset

12 related tables covering ~2.7 years of activity (Jan 2024 – Aug 2026):

| Table | Rows | Purpose |
|---|---|---|
| customers | 41 | Contractors, retailers, distributors, government, developers |
| suppliers | 15 | International MEP brands |
| products | 37 | Pipes & fittings, valves, sanitary ware, HVAC, pumps, etc. |
| employees | 6 | Sales reps for rep-performance analysis |
| orders / order_items | 728 / 2,174 | Sales transactions |
| invoices | 533 | AR / cash collection |
| purchase_orders | 323 | Procurement, supplier lead times |
| rfqs | 446 | Quotation pipeline & conversion |
| inventory | 37 | Stock levels vs. reorder point |
| opex / budget | 192 / 192 | Monthly operating expense & budget by category |
