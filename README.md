# Nabil P K — Data Analytics & BI Portfolio

Four end-to-end analytics projects built to demonstrate SQL, Power Query,
Power BI, and applied AI skills against a realistic UAE MEP trading
business — the same domain I worked in at Hydro Sanitary Ware Trading.

All four projects share **one dataset** (`/shared-database`) so the numbers
are consistent across dashboards, the way they would be in a real company.

## Why this portfolio exists

A generic "Data Analyst portfolio" usually shows the same Titanic or
Superstore dataset everyone else uses. This one uses a synthetic-but-realistic
**UAE MEP trading dataset** — customers, suppliers, RFQs, purchase orders,
inventory, and financials — because that combination of domain knowledge and
analytics is what makes a Junior Data Analyst / BI Analyst candidate stand
out from other freshers.

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

A deliberate revenue dip is built into **August 2026** — this is what
Project 4's AI insight engine investigates and explains.

## How to use this repo

1. **SQL practice**: open `sql-practice/50_sql_queries.sql` in any SQLite
   client (e.g. [DB Browser for SQLite](https://sqlitebrowser.org/), free)
   pointed at `shared-database/mep_trading.db`, or paste the schema +
   queries into SQL Server / PostgreSQL / MySQL (see notes in `schema.sql`).
2. **Power BI dashboards**: each project folder has a `README.md` with the
   exact fields, measures (DAX), and visuals to build. Connect Power BI to
   the CSVs in `shared-database/data/` (or the SQLite file via an ODBC
   driver), shape with Power Query, then build the dashboard as specified.
3. **AI insight engine**: `project-4-ai-bi-system/scripts/generate_insight.py`
   runs standalone — try `python3 generate_insight.py --month 2026-08` to
   see it diagnose the built-in revenue dip.

## Publishing to GitHub

```bash
cd nabil-bi-portfolio
git init
git add .
git commit -m "Initial commit: UAE MEP trading analytics portfolio"
git branch -M main
git remote add origin https://github.com/<your-username>/nabil-bi-portfolio.git
git push -u origin main
```

A `.gitignore` is included to keep generated `__pycache__/` and OS files out
of the repo. The `mep_trading.db` file (~1 MB) is small enough to commit
directly; if you regenerate a larger dataset later, consider Git LFS.

## Skills demonstrated (maps to resume bullets)

- **SQL**: joins, subqueries, CTEs, window functions (RANK, LAG, ROW_NUMBER,
  moving averages), date functions, aggregate + HAVING logic — see
  `sql-practice/50_sql_queries.sql`.
- **Power Query / ETL**: importing multi-table CSV/SQL sources, shaping,
  building a star-schema style model — see each project README.
- **Power BI**: KPI cards, trend lines, YoY comparisons, segmentation,
  ranking tables, budget-vs-actual variance visuals.
- **Financial analysis**: gross margin, EBITDA proxy, DSO, variance analysis
  — see Project 3.
- **Applied AI in BI**: a working Python pipeline that investigates a
  metric change and produces a human-verifiable explanation — see Project 4.
