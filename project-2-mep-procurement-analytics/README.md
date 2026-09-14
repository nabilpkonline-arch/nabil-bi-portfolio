# Project 2 — MEP Procurement Intelligence Dashboard

**Why this project matters:** it pairs real MEP/building-materials domain
knowledge from my time at Hydro Sanitary Ware Trading with analytics —
something most fresher portfolios don't have.

## Business objective

Give procurement and sales management visibility into supplier reliability,
quotation conversion, inventory risk, and which customers are actually
profitable to serve — not just which generate the most revenue.

## Data source

`suppliers`, `purchase_orders`, `rfqs`, `inventory`, `products`, `customers`,
`orders`, `order_items`.

## SQL

See [`sql/dashboard_queries.sql`](sql/dashboard_queries.sql).

## Dashboard panels to build in Power BI

| Panel | Visual type | Source query |
|---|---|---|
| Supplier Scorecard | Table (conditional formatting on delay) | Supplier Scorecard |
| RFQ Pipeline / Funnel | Funnel chart | RFQ Pipeline & Conversion Funnel |
| Quotation Conversion Rate Trend | Line chart | Conversion Rate by Month |
| PO Value by Category | Stacked bar | Purchase Order Value by Product Category |
| Delivery Delay Distribution | Histogram/bar | Delivery Delay Distribution |
| Inventory Health | Table with data bars | Inventory Health |
| Customer Profitability | Scatter (revenue vs margin %) | Customer Profitability |
| Pipe & Fitting Sales Trend | Line chart | Pipe & Fitting Sales Trend |

## Suggested DAX measures

```
Avg Supplier Delay (days) =
AVERAGEX ( PurchaseOrders, DATEDIFF ( PurchaseOrders[expected_delivery_date], PurchaseOrders[actual_delivery_date], DAY ) )

RFQ Conversion Rate =
DIVIDE (
    CALCULATE ( COUNTROWS ( RFQs ), RFQs[status] = "Converted" ),
    COUNTROWS ( RFQs )
)

Customer Margin % = DIVIDE ( [Gross Profit], [Total Revenue] )
```

## Interview talking points

- Explain the trade-off you'd flag to management: a supplier with a great
  price but consistently late deliveries (visible in the Delivery Delay
  panel) creates hidden project-delay costs that raw pricing doesn't show.
- Describe how the RFQ funnel identifies where deals are being lost
  (Pending vs. Lost vs. Expired) so sales can prioritize follow-up.

## Skills demonstrated

Supply-chain / procurement KPIs, funnel analysis, inventory risk logic,
customer profitability analysis, domain-specific storytelling for a
non-technical stakeholder audience.
