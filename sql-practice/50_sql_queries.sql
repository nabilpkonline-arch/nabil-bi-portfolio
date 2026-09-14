-- =====================================================================
-- 50+ SQL Practice Queries — Basic to Intermediate
-- Database: mep_trading.db (see /shared-database)
-- Every query below has been executed against the sample dataset and
-- verified to run without errors (see build_and_test_queries.py).
-- =====================================================================

-- ======================================================================
-- SECTION 1 — BASIC (SELECT, WHERE, ORDER BY, GROUP BY, Aggregates)
-- ======================================================================

-- 1. List all customers
SELECT customer_id, customer_name, emirate, segment
FROM customers;

-- 2. List all products with their category
SELECT product_name, category, unit_price
FROM products;

-- 3. Find all customers in Dubai
SELECT customer_name, segment, credit_limit
FROM customers
WHERE emirate = 'Dubai';

-- 4. Find products priced above 500
SELECT product_name, category, unit_price
FROM products
WHERE unit_price > 500
ORDER BY unit_price DESC;

-- 5. List distinct emirates customers are based in
SELECT DISTINCT emirate
FROM customers
ORDER BY emirate;

-- 6. List distinct product categories
SELECT DISTINCT category
FROM products;

-- 7. Count total number of customers
SELECT COUNT(*) AS total_customers
FROM customers;

-- 8. Count total number of orders
SELECT COUNT(*) AS total_orders
FROM orders;

-- 9. Find the average unit price of all products
SELECT ROUND(AVG(unit_price), 2) AS avg_unit_price
FROM products;

-- 10. Find the minimum and maximum product price
SELECT MIN(unit_price) AS min_price, MAX(unit_price) AS max_price
FROM products;

-- 11. List the 10 most recent orders
SELECT order_id, customer_id, order_date, status
FROM orders
ORDER BY order_date DESC
LIMIT 10;

-- 12. List orders with status 'Cancelled'
SELECT order_id, customer_id, order_date
FROM orders
WHERE status = 'Cancelled';

-- 13. Find customers with credit limit above 500,000
SELECT customer_name, emirate, credit_limit
FROM customers
WHERE credit_limit > 500000
ORDER BY credit_limit DESC;

-- 14. Find suppliers rated 4.5 or higher
SELECT supplier_name, country, rating
FROM suppliers
WHERE rating >= 4.5
ORDER BY rating DESC;

-- 15. Count customers per emirate
SELECT emirate, COUNT(*) AS num_customers
FROM customers
GROUP BY emirate
ORDER BY num_customers DESC;

-- 16. Count products per category
SELECT category, COUNT(*) AS num_products
FROM products
GROUP BY category
ORDER BY num_products DESC;

-- 17. Find total quantity ordered per product (order_items only)
SELECT product_id, SUM(quantity) AS total_quantity
FROM order_items
GROUP BY product_id
ORDER BY total_quantity DESC
LIMIT 10;

-- 18. Find invoices that are still unpaid
SELECT invoice_id, order_id, amount, due_date
FROM invoices
WHERE status = 'Unpaid';

-- 19. Search for customers whose name contains 'Trading'
SELECT customer_name, emirate
FROM customers
WHERE customer_name LIKE '%Trading%';

-- 20. Find products with NULL or zero stock (from inventory)
SELECT p.product_name, i.quantity_on_hand
FROM inventory i
JOIN products p ON p.product_id = i.product_id
WHERE i.quantity_on_hand = 0;

-- ======================================================================
-- SECTION 2 — INTERMEDIATE (Joins, Subqueries, CASE, HAVING, Date Functions)
-- ======================================================================

-- 21. Total revenue per order (join order_items to orders)
SELECT o.order_id, o.order_date, o.customer_id,
       ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0)), 2) AS order_revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY o.order_id, o.order_date, o.customer_id
ORDER BY order_revenue DESC
LIMIT 10;

-- 22. Total revenue by customer (top 10)
SELECT c.customer_name,
       ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0)), 2) AS total_revenue
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status = 'Completed'
GROUP BY c.customer_name
ORDER BY total_revenue DESC
LIMIT 10;

-- 23. Bottom 10 customers by revenue (still active, at least 1 order)
SELECT c.customer_name,
       ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0)), 2) AS total_revenue
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status = 'Completed'
GROUP BY c.customer_name
ORDER BY total_revenue ASC
LIMIT 10;

-- 24. Sales by emirate
SELECT o.emirate,
       ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0)), 2) AS revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status = 'Completed'
GROUP BY o.emirate
ORDER BY revenue DESC;

-- 25. Revenue and gross profit by product category
SELECT p.category,
       ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0)), 2) AS revenue,
       ROUND(SUM(oi.quantity * (oi.unit_price * (1 - oi.discount_pct/100.0) - p.unit_cost)), 2) AS gross_profit
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
JOIN orders o ON o.order_id = oi.order_id
WHERE o.status = 'Completed'
GROUP BY p.category
ORDER BY revenue DESC;

-- 26. Monthly revenue trend
SELECT strftime('%Y-%m', o.order_date) AS month,
       ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0)), 2) AS revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status = 'Completed'
GROUP BY month
ORDER BY month;

-- 27. Customers who have never placed an order
SELECT c.customer_name
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL;

-- 28. Products that have never been ordered
SELECT p.product_name
FROM products p
LEFT JOIN order_items oi ON oi.product_id = p.product_id
WHERE oi.order_item_id IS NULL;

-- 29. Customer segment performance (using CASE + aggregate)
SELECT c.segment,
       COUNT(DISTINCT o.order_id) AS num_orders,
       ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0)), 2) AS revenue,
       CASE
           WHEN SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0)) > 500000 THEN 'High Value'
           WHEN SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0)) > 100000 THEN 'Mid Value'
           ELSE 'Low Value'
       END AS value_tier
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status = 'Completed'
GROUP BY c.segment
ORDER BY revenue DESC;

-- 30. Categories with average order value above overall average (HAVING)
SELECT p.category, ROUND(AVG(oi.quantity * oi.unit_price), 2) AS avg_line_value
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.category
HAVING AVG(oi.quantity * oi.unit_price) > (
    SELECT AVG(quantity * unit_price) FROM order_items
)
ORDER BY avg_line_value DESC;

-- 31. RFQ to order conversion rate
SELECT
    COUNT(*) AS total_rfqs,
    SUM(CASE WHEN status = 'Converted' THEN 1 ELSE 0 END) AS converted_rfqs,
    ROUND(100.0 * SUM(CASE WHEN status = 'Converted' THEN 1 ELSE 0 END) / COUNT(*), 2) AS conversion_rate_pct
FROM rfqs;

-- 32. RFQ conversion rate by month
SELECT strftime('%Y-%m', rfq_date) AS month,
       COUNT(*) AS total_rfqs,
       SUM(CASE WHEN status='Converted' THEN 1 ELSE 0 END) AS converted,
       ROUND(100.0 * SUM(CASE WHEN status='Converted' THEN 1 ELSE 0 END) / COUNT(*), 2) AS conversion_pct
FROM rfqs
GROUP BY month
ORDER BY month;

-- 33. Supplier performance — average delivery delay in days
SELECT s.supplier_name,
       COUNT(*) AS total_pos,
       ROUND(AVG(julianday(po.actual_delivery_date) - julianday(po.expected_delivery_date)), 1) AS avg_delay_days
FROM purchase_orders po
JOIN suppliers s ON s.supplier_id = po.supplier_id
WHERE po.status = 'Delivered'
GROUP BY s.supplier_name
ORDER BY avg_delay_days DESC;

-- 34. Purchase orders delivered late (more than 5 days delay)
SELECT po.po_id, s.supplier_name, po.expected_delivery_date, po.actual_delivery_date,
       (julianday(po.actual_delivery_date) - julianday(po.expected_delivery_date)) AS delay_days
FROM purchase_orders po
JOIN suppliers s ON s.supplier_id = po.supplier_id
WHERE po.status = 'Delivered'
  AND (julianday(po.actual_delivery_date) - julianday(po.expected_delivery_date)) > 5
ORDER BY delay_days DESC;

-- 35. Products below reorder level (inventory risk)
SELECT p.product_name, i.quantity_on_hand, i.reorder_level
FROM inventory i
JOIN products p ON p.product_id = i.product_id
WHERE i.quantity_on_hand < i.reorder_level
ORDER BY i.quantity_on_hand ASC;

-- 36. Outstanding receivables per customer
SELECT c.customer_name,
       ROUND(SUM(inv.amount - inv.paid_amount), 2) AS outstanding_balance
FROM invoices inv
JOIN orders o ON o.order_id = inv.order_id
JOIN customers c ON c.customer_id = o.customer_id
WHERE inv.status IN ('Unpaid', 'Partially Paid')
GROUP BY c.customer_name
ORDER BY outstanding_balance DESC;

-- 37. Year-over-year revenue by month-number (2024 vs 2025)
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

-- 38. Top-selling product by quantity per category
SELECT p.category, p.product_name, SUM(oi.quantity) AS total_qty
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.category, p.product_name
ORDER BY p.category, total_qty DESC;

-- 39. Sales rep (employee) performance ranking
SELECT e.employee_name,
       COUNT(DISTINCT o.order_id) AS num_orders,
       ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0)), 2) AS revenue
FROM employees e
JOIN orders o ON o.employee_id = e.employee_id
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status = 'Completed'
GROUP BY e.employee_name
ORDER BY revenue DESC;

-- 40. Customers who ordered more than 5 times
SELECT c.customer_name, COUNT(o.order_id) AS num_orders
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
WHERE o.status = 'Completed'
GROUP BY c.customer_name
HAVING COUNT(o.order_id) > 5
ORDER BY num_orders DESC;

-- 41. Discount impact — total discount given per month
SELECT strftime('%Y-%m', o.order_date) AS month,
       ROUND(SUM(oi.quantity * oi.unit_price * oi.discount_pct/100.0), 2) AS total_discount_given
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY month
ORDER BY month;

-- 42. Budget vs Actual opex variance by category (latest month)
SELECT b.category,
       b.budget_amount,
       o.amount AS actual_amount,
       ROUND(o.amount - b.budget_amount, 2) AS variance,
       ROUND(100.0 * (o.amount - b.budget_amount) / b.budget_amount, 2) AS variance_pct
FROM budget b
JOIN opex o ON o.month = b.month AND o.category = b.category
WHERE b.month = (SELECT MAX(month) FROM budget)
ORDER BY variance_pct DESC;

-- 43. Customers with orders in every quarter of 2025 (advanced grouping)
SELECT c.customer_name, COUNT(DISTINCT ((CAST(strftime('%m', o.order_date) AS INTEGER)-1)/3)) AS quarters_active
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
WHERE strftime('%Y', o.order_date) = '2025' AND o.status = 'Completed'
GROUP BY c.customer_name
HAVING quarters_active = 4;

-- 44. Suppliers never delivered late (perfect record)
SELECT s.supplier_name
FROM suppliers s
WHERE s.supplier_id NOT IN (
    SELECT po.supplier_id
    FROM purchase_orders po
    WHERE po.status = 'Delivered'
      AND julianday(po.actual_delivery_date) > julianday(po.expected_delivery_date)
);

-- 45. Products with gross margin below 25% (pricing risk)
SELECT product_name, unit_cost, unit_price,
       ROUND(100.0 * (unit_price - unit_cost) / unit_price, 2) AS margin_pct
FROM products
WHERE (unit_price - unit_cost) / unit_price < 0.25
ORDER BY margin_pct ASC;

-- ======================================================================
-- SECTION 3 — WINDOW FUNCTIONS, CTEs & FORECASTING BASICS
-- ======================================================================

-- 46. Rank customers by revenue using RANK() window function
SELECT customer_name, revenue,
       RANK() OVER (ORDER BY revenue DESC) AS revenue_rank
FROM (
    SELECT c.customer_name,
           SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0)) AS revenue
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'Completed'
    GROUP BY c.customer_name
) rev
ORDER BY revenue_rank
LIMIT 10;

-- 47. Running total of monthly revenue (window function)
WITH monthly AS (
    SELECT strftime('%Y-%m', o.order_date) AS month,
           SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0)) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'Completed'
    GROUP BY month
)
SELECT month, revenue,
       ROUND(SUM(revenue) OVER (ORDER BY month), 2) AS running_total
FROM monthly
ORDER BY month;

-- 48. Month-over-month revenue growth % (LAG window function)
WITH monthly AS (
    SELECT strftime('%Y-%m', o.order_date) AS month,
           SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0)) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'Completed'
    GROUP BY month
)
SELECT month, revenue,
       LAG(revenue) OVER (ORDER BY month) AS prev_month_revenue,
       ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month)) / LAG(revenue) OVER (ORDER BY month), 2) AS mom_growth_pct
FROM monthly
ORDER BY month;

-- 49. 3-month moving average of revenue
WITH monthly AS (
    SELECT strftime('%Y-%m', o.order_date) AS month,
           SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0)) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'Completed'
    GROUP BY month
)
SELECT month, revenue,
       ROUND(AVG(revenue) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS moving_avg_3mo
FROM monthly
ORDER BY month;

-- 50. Top 3 products by revenue within each category (window PARTITION BY)
WITH product_revenue AS (
    SELECT p.category, p.product_name,
           SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0)) AS revenue
    FROM order_items oi
    JOIN products p ON p.product_id = oi.product_id
    GROUP BY p.category, p.product_name
),
ranked AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY category ORDER BY revenue DESC) AS rn
    FROM product_revenue
)
SELECT category, product_name, ROUND(revenue, 2) AS revenue
FROM ranked
WHERE rn <= 3
ORDER BY category, revenue DESC;

-- 51. Simple sales forecast — linear trend on last 6 months (CTE + basic projection)
WITH monthly AS (
    SELECT strftime('%Y-%m', o.order_date) AS month,
           SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0)) AS revenue,
           ROW_NUMBER() OVER (ORDER BY strftime('%Y-%m', o.order_date)) AS period_num
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'Completed'
    GROUP BY month
    ORDER BY month DESC
    LIMIT 6
)
SELECT ROUND(AVG(revenue), 2) AS avg_last_6mo,
       ROUND(AVG(revenue) * 1.05, 2) AS naive_next_month_forecast_5pct_growth
FROM monthly;

-- 52. Customer lifetime value (CTE combining orders + invoices)
WITH clv AS (
    SELECT c.customer_id, c.customer_name,
           SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0)) AS lifetime_revenue,
           COUNT(DISTINCT o.order_id) AS total_orders
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'Completed'
    GROUP BY c.customer_id, c.customer_name
)
SELECT customer_name, total_orders, ROUND(lifetime_revenue, 2) AS lifetime_revenue,
       ROUND(lifetime_revenue / total_orders, 2) AS avg_order_value
FROM clv
ORDER BY lifetime_revenue DESC
LIMIT 10;

-- 53. Percentage of total revenue contributed by each emirate (window SUM)
WITH emirate_rev AS (
    SELECT o.emirate,
           SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0)) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'Completed'
    GROUP BY o.emirate
)
SELECT emirate, ROUND(revenue, 2) AS revenue,
       ROUND(100.0 * revenue / SUM(revenue) OVER (), 2) AS pct_of_total
FROM emirate_rev
ORDER BY revenue DESC;

-- 54. Customers who haven't ordered in the last 90 days (churn risk)
WITH last_order AS (
    SELECT customer_id, MAX(order_date) AS last_order_date
    FROM orders
    WHERE status = 'Completed'
    GROUP BY customer_id
)
SELECT c.customer_name, lo.last_order_date,
       CAST(julianday('2026-09-15') - julianday(lo.last_order_date) AS INTEGER) AS days_since_last_order
FROM last_order lo
JOIN customers c ON c.customer_id = lo.customer_id
WHERE julianday('2026-09-15') - julianday(lo.last_order_date) > 90
ORDER BY days_since_last_order DESC;

-- 55. EBITDA-style monthly summary (revenue - COGS - opex, CTE combining 3 sources)
WITH monthly_revenue AS (
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
SELECT r.month,
       ROUND(r.revenue, 2) AS revenue,
       ROUND(r.cogs, 2) AS cogs,
       ROUND(r.revenue - r.cogs, 2) AS gross_profit,
       ROUND(o.total_opex, 2) AS opex,
       ROUND(r.revenue - r.cogs - o.total_opex, 2) AS ebitda_proxy
FROM monthly_revenue r
JOIN monthly_opex o ON o.month = r.month
ORDER BY r.month;
