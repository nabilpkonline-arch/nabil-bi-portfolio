# Project 1 — UAE Sales Intelligence Dashboard

**Pipeline:** SQL → Power Query → Power BI → AI-assisted commentary (verified by analyst)

## Business objective

Give sales leadership a single view of revenue, profitability, and customer
performance across the UAE, so they can spot trends and act on them monthly
rather than waiting for a quarterly report.

## Data source

`shared-database/mep_trading.db` (or the CSVs in `shared-database/data/`):
`customers`, `orders`, `order_items`, `products`.

## SQL

See [`sql/dashboard_queries.sql`](sql/dashboard_queries.sql) — one query per
dashboard panel, all tested against the sample database.

## Dashboard panels to build in Power BI

| Panel | Visual type | Source query |
|---|---|---|
| Total Revenue | Card | Total Revenue |
| Gross Profit | Card | Gross Profit |
| Sales by Emirate | Map or clustered bar | Sales by Emirate |
| Customer Segmentation | Donut chart | Customer Segmentation |
| Product Performance | Table, top 15 | Product Performance |
| YoY Growth | Line/column combo (2024 vs 2025) | YoY Growth |
| Monthly Trend | Line chart | Monthly Trend |
| Top 10 Customers | Table | Top 10 Customers |
| Bottom 10 Customers | Table | Bottom 10 Customers |
| Sales Forecast | Line chart with Power BI's built-in forecast, or a Python/R visual | Monthly Trend + trailing average baseline |

## Suggested DAX measures

```
Total Revenue =
SUMX ( OrderItems, OrderItems[quantity] * OrderItems[unit_price] * (1 - OrderItems[discount_pct]/100) )

Gross Profit =
SUMX (
    OrderItems,
    OrderItems[quantity] * ( OrderItems[unit_price] * (1 - OrderItems[discount_pct]/100) - RELATED ( Products[unit_cost] ) )
)

Gross Margin % = DIVIDE ( [Gross Profit], [Total Revenue] )

Revenue YoY % =
VAR CurrentYearRevenue = [Total Revenue]
VAR PriorYearRevenue = CALCULATE ( [Total Revenue], SAMEPERIODLASTYEAR ( 'Date'[Date] ) )
RETURN DIVIDE ( CurrentYearRevenue - PriorYearRevenue, PriorYearRevenue )
```

(Build a standalone `Date` table and mark it as a Date table for
time-intelligence functions like `SAMEPERIODLASTYEAR` to work.)

## The "what changed and why" step

Once the dashboard is built, export the current month's numbers (or connect
directly) and ask an AI assistant: *"What changed this month and why?"* —
then **verify the answer yourself** against the underlying data before
presenting it. Project 4 in this portfolio builds a small script that does
this investigation step programmatically and shows its raw evidence
alongside the narrative, which is the safer pattern to describe in an
interview than "the AI just tells me."

## Skills demonstrated

SQL joins & aggregation, Power Query data shaping, Power BI DAX measures,
time-intelligence, YoY analysis, dashboard design, applied AI with human
verification.
