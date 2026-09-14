-- =====================================================================
-- Project 3 — Management Financial (FP&A) Dashboard
-- =====================================================================

-- PANEL: Revenue, COGS, Gross Margin by month
SELECT strftime('%Y-%m', o.order_date) AS month,
       ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0)), 2) AS revenue,
       ROUND(SUM(oi.quantity * p.unit_cost), 2) AS cogs,
       ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0)) - SUM(oi.quantity * p.unit_cost), 2) AS gross_profit,
       ROUND(100.0 * (SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0)) - SUM(oi.quantity * p.unit_cost))
             / SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0)), 2) AS gross_margin_pct
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE o.status = 'Completed'
GROUP BY month
ORDER BY month;

-- PANEL: Operating Expenses by Category (stacked column)
SELECT month, category, amount
FROM opex
ORDER BY month, category;

-- PANEL: EBITDA Proxy (Revenue - COGS - Opex) by Month
WITH monthly_gp AS (
    SELECT strftime('%Y-%m', o.order_date) AS month,
           SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0)) AS revenue,
           SUM(oi.quantity * p.unit_cost) AS cogs
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN products p ON p.product_id = oi.product_id
    WHERE o.status = 'Completed'
    GROUP BY month
),
monthly_opex AS (
    SELECT month, SUM(amount) AS total_opex
    FROM opex
    GROUP BY month
)
SELECT g.month,
       ROUND(g.revenue, 2) AS revenue,
       ROUND(g.cogs, 2) AS cogs,
       ROUND(g.revenue - g.cogs, 2) AS gross_profit,
       ROUND(o.total_opex, 2) AS opex,
       ROUND(g.revenue - g.cogs - o.total_opex, 2) AS ebitda_proxy
FROM monthly_gp g
JOIN monthly_opex o ON o.month = g.month
ORDER BY g.month;

-- PANEL: Budget vs Actual (Opex) with variance
SELECT b.month, b.category,
       b.budget_amount,
       o.amount AS actual_amount,
       ROUND(o.amount - b.budget_amount, 2) AS variance,
       ROUND(100.0 * (o.amount - b.budget_amount) / b.budget_amount, 2) AS variance_pct
FROM budget b
JOIN opex o ON o.month = b.month AND o.category = b.category
ORDER BY b.month, b.category;

-- PANEL: Cash Flow Proxy — cash collected vs invoiced, by month
SELECT strftime('%Y-%m', invoice_date) AS month,
       ROUND(SUM(amount), 2) AS invoiced_amount,
       ROUND(SUM(paid_amount), 2) AS cash_collected,
       ROUND(SUM(amount) - SUM(paid_amount), 2) AS outstanding
FROM invoices
GROUP BY month
ORDER BY month;

-- PANEL: Days Sales Outstanding (DSO) proxy, most recent quarter
SELECT ROUND(
    (SUM(CASE WHEN status IN ('Unpaid','Partially Paid') THEN amount - paid_amount ELSE 0 END)
     / NULLIF(SUM(amount), 0)) * 90, 1
) AS approx_dso_days
FROM invoices
WHERE invoice_date >= date((SELECT MAX(invoice_date) FROM invoices), '-90 days');

-- PANEL: Variance Analysis Summary — categories most over/under budget (latest month)
SELECT b.category,
       b.budget_amount,
       o.amount AS actual_amount,
       ROUND(o.amount - b.budget_amount, 2) AS variance
FROM budget b
JOIN opex o ON o.month = b.month AND o.category = b.category
WHERE b.month = (SELECT MAX(month) FROM budget)
ORDER BY ABS(o.amount - b.budget_amount) DESC;
