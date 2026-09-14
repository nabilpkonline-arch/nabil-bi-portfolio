# Project 3 — Management Financial (FP&A) Dashboard

**Goal:** make this candidate profile attractive for Business Analyst /
FP&A Analyst / BI Analyst roles, not just "Data Analyst."

## Business objective

Give management a monthly view of profitability (revenue, COGS, gross
margin), operating expenses vs. budget, and a simplified cash-flow picture —
the core outputs of an FP&A function.

## Data source

`orders`, `order_items`, `products`, `invoices`, `opex`, `budget`.

## SQL

See [`sql/dashboard_queries.sql`](sql/dashboard_queries.sql).

## Dashboard panels to build in Power BI

| Panel | Visual type | Source query |
|---|---|---|
| Revenue / COGS / Gross Margin trend | Combo line + column | Revenue, COGS, Gross Margin by month |
| Opex by Category | Stacked column | Operating Expenses by Category |
| EBITDA Proxy trend | Line/waterfall | EBITDA Proxy by Month |
| Budget vs Actual | Clustered bar with variance labels | Budget vs Actual |
| Cash Flow Proxy | Line chart (invoiced vs collected) | Cash Flow Proxy |
| DSO | Card / gauge | Days Sales Outstanding proxy |
| Variance Analysis | Table sorted by absolute variance | Variance Analysis Summary |

## Suggested DAX measures

```
Gross Margin % = DIVIDE ( [Gross Profit], [Total Revenue] )

EBITDA Proxy = [Gross Profit] - [Total Opex]

Budget Variance = [Actual Opex] - [Budget Opex]

Budget Variance % = DIVIDE ( [Budget Variance], [Budget Opex] )
```

## Notes on scope (important for interviews)

This models EBITDA and cash flow as **simplified proxies** using the data
available (no depreciation, tax, or full balance-sheet detail is modeled).
Being explicit about that in an interview is a strength, not a weakness —
it shows you understand the difference between a real EBITDA calculation
and a directional approximation built for a dashboard exercise.

## Skills demonstrated

Financial statement literacy (revenue, COGS, gross margin, opex, EBITDA),
budget-vs-actual variance analysis, basic cash-flow / DSO concepts, building
finance-oriented dashboards a controller or FP&A manager would recognize.
