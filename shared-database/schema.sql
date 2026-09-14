-- =====================================================================
-- MEP Trading Company — Database Schema
-- Portable ANSI SQL. Tested on SQLite; works with minor tweaks on
-- SQL Server, PostgreSQL, and MySQL (see notes at bottom).
-- =====================================================================

CREATE TABLE customers (
    customer_id     INTEGER PRIMARY KEY,
    customer_name   VARCHAR(100) NOT NULL,
    emirate         VARCHAR(50),
    segment         VARCHAR(50),          -- Contractor, Retailer, Distributor, Government, Real Estate Developer
    industry        VARCHAR(50),
    credit_limit    DECIMAL(12,2),
    onboard_date    DATE
);

CREATE TABLE suppliers (
    supplier_id     INTEGER PRIMARY KEY,
    supplier_name   VARCHAR(100) NOT NULL,
    country         VARCHAR(50),
    category        VARCHAR(50),
    rating          DECIMAL(2,1),          -- 1.0 - 5.0
    onboard_date    DATE
);

CREATE TABLE products (
    product_id      INTEGER PRIMARY KEY,
    product_name    VARCHAR(100) NOT NULL,
    category        VARCHAR(50),
    subcategory     VARCHAR(50),
    unit_cost       DECIMAL(10,2),
    unit_price      DECIMAL(10,2),
    uom             VARCHAR(10)
);

CREATE TABLE employees (
    employee_id     INTEGER PRIMARY KEY,
    employee_name   VARCHAR(100),
    role            VARCHAR(50),
    department      VARCHAR(50),
    hire_date       DATE
);

CREATE TABLE orders (
    order_id        INTEGER PRIMARY KEY,
    customer_id     INTEGER REFERENCES customers(customer_id),
    order_date      DATE,
    emirate         VARCHAR(50),
    employee_id     INTEGER REFERENCES employees(employee_id),
    status          VARCHAR(20)             -- Completed, Cancelled
);

CREATE TABLE order_items (
    order_item_id   INTEGER PRIMARY KEY,
    order_id        INTEGER REFERENCES orders(order_id),
    product_id      INTEGER REFERENCES products(product_id),
    quantity        INTEGER,
    unit_price      DECIMAL(10,2),
    discount_pct    DECIMAL(5,2)
);

CREATE TABLE invoices (
    invoice_id      INTEGER PRIMARY KEY,
    order_id        INTEGER REFERENCES orders(order_id),
    invoice_date    DATE,
    due_date        DATE,
    amount          DECIMAL(12,2),
    paid_amount     DECIMAL(12,2),
    payment_date    DATE,
    status          VARCHAR(20)             -- Paid, Partially Paid, Unpaid
);

CREATE TABLE purchase_orders (
    po_id                   INTEGER PRIMARY KEY,
    supplier_id             INTEGER REFERENCES suppliers(supplier_id),
    product_id              INTEGER REFERENCES products(product_id),
    po_date                 DATE,
    quantity                INTEGER,
    unit_cost               DECIMAL(10,2),
    expected_delivery_date  DATE,
    actual_delivery_date    DATE,
    status                  VARCHAR(20)      -- Delivered, In Transit
);

CREATE TABLE rfqs (
    rfq_id              INTEGER PRIMARY KEY,
    customer_id         INTEGER REFERENCES customers(customer_id),
    product_id          INTEGER REFERENCES products(product_id),
    rfq_date            DATE,
    quantity            INTEGER,
    quoted_price        DECIMAL(10,2),
    status              VARCHAR(20),         -- Converted, Lost, Pending, Expired
    converted_order_id  INTEGER
);

CREATE TABLE inventory (
    product_id          INTEGER REFERENCES products(product_id),
    warehouse           VARCHAR(50),
    quantity_on_hand    INTEGER,
    reorder_level       INTEGER,
    last_updated        DATE
);

CREATE TABLE opex (
    opex_id     INTEGER PRIMARY KEY,
    month       VARCHAR(7),                  -- 'YYYY-MM'
    category    VARCHAR(50),
    amount      DECIMAL(12,2)
);

CREATE TABLE budget (
    budget_id       INTEGER PRIMARY KEY,
    month           VARCHAR(7),
    category        VARCHAR(50),
    budget_amount   DECIMAL(12,2)
);

-- =====================================================================
-- Notes for other RDBMS:
--   SQL Server : use DATETIME/DATE as-is; IDENTITY(1,1) instead of
--                autoincrement if not pre-seeding IDs.
--   PostgreSQL : VARCHAR/DECIMAL are supported as-is; consider SERIAL
--                for auto-incrementing PKs.
--   MySQL      : swap DECIMAL(p,s) as-is; use AUTO_INCREMENT for PKs.
-- =====================================================================
