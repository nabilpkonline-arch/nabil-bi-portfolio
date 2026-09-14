-- =====================================================================
-- Project 2 — MEP Procurement Intelligence Dashboard
-- =====================================================================

-- PANEL: Supplier Scorecard (table)
SELECT s.supplier_name, s.country, s.rating,
       COUNT(po.po_id) AS total_pos,
       ROUND(AVG(julianday(po.actual_delivery_date) - julianday(po.expected_delivery_date)), 1) AS avg_delay_days,
       SUM(CASE WHEN po.status='Delivered'
                AND julianday(po.actual_delivery_date) > julianday(po.expected_delivery_date)
                THEN 1 ELSE 0 END) AS late_deliveries
FROM suppliers s
LEFT JOIN purchase_orders po ON po.supplier_id = s.supplier_id
GROUP BY s.supplier_name, s.country, s.rating
ORDER BY avg_delay_days DESC;

-- PANEL: RFQ Pipeline & Conversion Funnel
SELECT status, COUNT(*) AS num_rfqs
FROM rfqs
GROUP BY status
ORDER BY num_rfqs DESC;

-- PANEL: Quotation Conversion Rate by Month (trend)
SELECT strftime('%Y-%m', rfq_date) AS month,
       COUNT(*) AS total_rfqs,
       SUM(CASE WHEN status='Converted' THEN 1 ELSE 0 END) AS converted,
       ROUND(100.0 * SUM(CASE WHEN status='Converted' THEN 1 ELSE 0 END) / COUNT(*), 2) AS conversion_pct
FROM rfqs
GROUP BY month
ORDER BY month;

-- PANEL: Purchase Order Value by Product Category
SELECT p.category,
       COUNT(po.po_id) AS num_pos,
       SUM(po.quantity) AS total_units_ordered,
       ROUND(SUM(po.quantity * po.unit_cost), 2) AS total_po_value
FROM purchase_orders po
JOIN products p ON p.product_id = po.product_id
GROUP BY p.category
ORDER BY total_po_value DESC;

-- PANEL: Delivery Delay Distribution (histogram source)
SELECT
    CASE
        WHEN delay_days <= 0 THEN 'On Time / Early'
        WHEN delay_days BETWEEN 1 AND 5 THEN '1-5 Days Late'
        WHEN delay_days BETWEEN 6 AND 15 THEN '6-15 Days Late'
        ELSE '15+ Days Late'
    END AS delay_bucket,
    COUNT(*) AS num_pos
FROM (
    SELECT (julianday(actual_delivery_date) - julianday(expected_delivery_date)) AS delay_days
    FROM purchase_orders
    WHERE status = 'Delivered'
)
GROUP BY delay_bucket;

-- PANEL: Inventory Health (products below reorder level)
SELECT p.product_name, p.category, i.quantity_on_hand, i.reorder_level,
       (i.reorder_level - i.quantity_on_hand) AS units_short
FROM inventory i
JOIN products p ON p.product_id = i.product_id
WHERE i.quantity_on_hand < i.reorder_level
ORDER BY units_short DESC;

-- PANEL: Customer Profitability (revenue vs. cost to serve, proxy via gross margin)
SELECT c.customer_name, c.segment,
       ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0)), 2) AS revenue,
       ROUND(SUM(oi.quantity * (oi.unit_price * (1 - oi.discount_pct/100.0) - p.unit_cost)), 2) AS gross_profit,
       ROUND(100.0 * SUM(oi.quantity * (oi.unit_price * (1 - oi.discount_pct/100.0) - p.unit_cost))
             / NULLIF(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0)), 0), 2) AS margin_pct
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE o.status = 'Completed'
GROUP BY c.customer_name, c.segment
ORDER BY gross_profit DESC
LIMIT 15;

-- PANEL: Pipe & Fitting Sales Trend (category deep-dive, as named in the brief)
SELECT strftime('%Y-%m', o.order_date) AS month,
       SUM(oi.quantity) AS units_sold,
       ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0)), 2) AS revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE o.status = 'Completed' AND p.category = 'Pipes & Fittings'
GROUP BY month
ORDER BY month;
