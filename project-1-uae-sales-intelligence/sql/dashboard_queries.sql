-- =====================================================================
-- Project 1 — UAE Sales Intelligence Dashboard
-- Queries that feed each dashboard panel. Import results into Power
-- Query (Get Data > SQLite/ODBC or a native connector for your RDBMS),
-- then build the visuals/measures listed in README.md.
-- =====================================================================

-- PANEL: Total Revenue (single-value card)
SELECT ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0)), 2) AS total_revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status = 'Completed';

-- PANEL: Gross Profit (single-value card)
SELECT ROUND(SUM(oi.quantity * (oi.unit_price * (1 - oi.discount_pct/100.0) - p.unit_cost)), 2) AS gross_profit
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
JOIN orders o ON o.order_id = oi.order_id
WHERE o.status = 'Completed';

-- PANEL: Sales by Emirate (bar/map chart)
SELECT o.emirate,
       ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0)), 2) AS revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status = 'Completed'
GROUP BY o.emirate
ORDER BY revenue DESC;

-- PANEL: Customer Segmentation (donut chart — revenue by segment)
SELECT c.segment,
       ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0)), 2) AS revenue,
       COUNT(DISTINCT c.customer_id) AS num_customers
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status = 'Completed'
GROUP BY c.segment;

-- PANEL: Product Performance (table, top 15 by revenue)
SELECT p.product_name, p.category,
       SUM(oi.quantity) AS units_sold,
       ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0)), 2) AS revenue,
       ROUND(SUM(oi.quantity * (oi.unit_price * (1 - oi.discount_pct/100.0) - p.unit_cost)), 2) AS gross_profit
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
JOIN orders o ON o.order_id = oi.order_id
WHERE o.status = 'Completed'
GROUP BY p.product_name, p.category
ORDER BY revenue DESC
LIMIT 15;

-- PANEL: YoY Growth (line/column combo, 2024 vs 2025 by calendar month)
SELECT strftime('%m', o.order_date) AS month_num,
       SUM(CASE WHEN strftime('%Y', o.order_date) = '2024'
                THEN oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0) ELSE 0 END) AS revenue_2024,
       SUM(CASE WHEN strftime('%Y', o.order_date) = '2025'
                THEN oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0) ELSE 0 END) AS revenue_2025
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status = 'Completed'
GROUP BY month_num
ORDER BY month_num;

-- PANEL: Monthly Trend (line chart, full history)
SELECT strftime('%Y-%m', o.order_date) AS month,
       ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0)), 2) AS revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status = 'Completed'
GROUP BY month
ORDER BY month;

-- PANEL: Top 10 Customers (table)
SELECT c.customer_name, c.emirate, c.segment,
       ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0)), 2) AS revenue
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status = 'Completed'
GROUP BY c.customer_name, c.emirate, c.segment
ORDER BY revenue DESC
LIMIT 10;

-- PANEL: Bottom 10 Customers (table — accounts needing attention)
SELECT c.customer_name, c.emirate, c.segment,
       ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0)), 2) AS revenue
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status = 'Completed'
GROUP BY c.customer_name, c.emirate, c.segment
ORDER BY revenue ASC
LIMIT 10;

-- PANEL: Simple 6-month trailing average forecast baseline
-- Use as a reference line, then refine in Power BI with a native
-- forecast visual or a Python/R analytics visual for exponential smoothing.
WITH monthly AS (
    SELECT strftime('%Y-%m', o.order_date) AS month,
           SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0)) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'Completed'
    GROUP BY month
    ORDER BY month DESC
    LIMIT 6
)
SELECT ROUND(AVG(revenue), 2) AS trailing_6mo_avg
FROM monthly;
