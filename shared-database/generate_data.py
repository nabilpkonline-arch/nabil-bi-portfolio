"""
generate_data.py
-----------------
Generates a realistic synthetic dataset for a UAE MEP (Mechanical, Electrical,
Plumbing) trading company — customers, suppliers, products, orders, purchase
orders, RFQs, invoices, inventory, opex and budget.

Deterministic (seeded) so results are reproducible. No external dependencies
beyond the Python standard library.

Run:
    python3 generate_data.py

Outputs CSVs into ./data/ and builds mep_trading.db (SQLite) in this folder.
"""

import csv
import random
import sqlite3
import os
from datetime import date, timedelta

random.seed(42)

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(BASE_DIR, "data")
DB_PATH = os.path.join(BASE_DIR, "mep_trading.db")
os.makedirs(DATA_DIR, exist_ok=True)

EMIRATES = ["Abu Dhabi", "Dubai", "Sharjah", "Ajman", "Ras Al Khaimah", "Fujairah", "Umm Al Quwain"]
SEGMENTS = ["Contractor", "Retailer", "Distributor", "Government", "Real Estate Developer"]
CUSTOMER_NAMES = [
    "Al Noor Building Contracting", "Gulf Horizon Trading", "Emirates Plumbing Works",
    "Al Wahda Construction Co", "Falcon MEP Services", "Desert Rose Developers",
    "Marina View Contractors", "Al Ain Infrastructure LLC", "Union Sanitary Trading",
    "Blue Wave Plumbing", "Al Reem Facilities Mgmt", "Sharjah Steel & Pipes",
    "Northern Emirates Builders", "Coastal Homes Development", "Al Maha Engineering",
    "Green Valley Construction", "RAK Municipal Projects", "Fujairah Port Authority",
    "Al Ittihad Real Estate", "Silver Sands Contracting", "Palm Grove Interiors",
    "Metro Plumbing Supplies", "Al Bateen Villas Project", "Yas Island Developers",
    "Skyline MEP Contractors", "Al Dhafra Municipality", "Downtown Retail Fitout Co",
    "Al Khaleej Trading LLC", "Sunrise Sanitary Ware", "Continental Builders UAE",
    "Al Jazira Public Works", "Harbor Point Construction", "Prime Villas Contracting",
    "Al Fahid Group", "Waterfront Estates", "Corniche Retail Group",
    "Al Salam Construction", "Barari Landscaping & MEP", "Etisalat Facilities Div",
    "National Housing Authority", "Desert Eagle Contracting",
]
SUPPLIER_NAMES = [
    "Grohe Middle East", "Kohler Gulf Distribution", "Jaquar UAE",
    "Viega Middle East", "Geberit Gulf FZE", "Ideal Standard MENA",
    "Wilo Pumps Gulf", "Grundfos Gulf", "Aliaxis Middle East",
    "RAK Ceramics Trading", "Hansgrohe Gulf", "Uponor Middle East",
    "Toto Middle East", "Danfoss Gulf FZE", "Rehau Gulf",
]
SUPPLIER_COUNTRIES = ["Germany", "USA", "India", "UAE", "Italy", "Finland", "Switzerland"]
PRODUCT_CATALOG = [
    ("Pipes & Fittings", ["PPR Pipe 20mm", "PPR Pipe 32mm", "PVC Pipe 4in", "Copper Pipe 15mm",
                          "Elbow Fitting PPR", "Tee Fitting PVC", "Coupling Brass"]),
    ("Valves", ["Gate Valve 2in", "Ball Valve 1in", "Check Valve 3in", "Pressure Reducing Valve",
                "Butterfly Valve 4in"]),
    ("Sanitary Ware", ["Wall-Hung WC", "One-Piece WC", "Pedestal Basin", "Counter-Top Basin",
                        "Urinal Standard"]),
    ("Bathroom Fixtures", ["Single Lever Basin Mixer", "Shower Mixer Set", "Bath Filler Spout",
                            "Concealed Shower System", "Bidet Mixer"]),
    ("HVAC Components", ["FCU 800CFM", "Duct Flexible 10in", "AHU Filter Panel", "VAV Box",
                          "Damper Actuator"]),
    ("Water Heaters", ["Electric Water Heater 50L", "Electric Water Heater 100L", "Solar Water Heater"]),
    ("Pumps", ["Circulation Pump", "Submersible Pump", "Booster Pump Set"]),
    ("Accessories", ["Pipe Clamp Set", "Teflon Tape", "Thread Sealant", "Insulation Wrap"]),
]

EMPLOYEE_NAMES = [
    ("Ahmed Al Mazrouei", "Sales Executive"), ("Fatima Al Suwaidi", "Sales Executive"),
    ("Ravi Menon", "Sales Executive"), ("Sara Al Hashemi", "Key Account Manager"),
    ("John Fernandes", "Sales Executive"), ("Meera Nair", "Key Account Manager"),
]

START_DATE = date(2024, 1, 1)
END_DATE = date(2026, 8, 31)  # data through last full month before "today" (Sep 2026)


def daterange_months(start, end):
    months = []
    y, m = start.year, start.month
    while (y, m) <= (end.year, end.month):
        months.append((y, m))
        m += 1
        if m > 12:
            m = 1
            y += 1
    return months


def random_date(start, end):
    delta = (end - start).days
    return start + timedelta(days=random.randint(0, delta))


def write_csv(filename, header, rows):
    path = os.path.join(DATA_DIR, filename)
    with open(path, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(header)
        w.writerows(rows)
    return path


# ---------- Dimension tables ----------

customers = []
for i, name in enumerate(CUSTOMER_NAMES, start=1):
    customers.append([
        i, name, random.choice(EMIRATES), random.choice(SEGMENTS),
        random.choice(["Construction", "Real Estate", "Facilities Mgmt", "Retail", "Government"]),
        round(random.uniform(50000, 1000000), 2),
        random_date(date(2022, 1, 1), date(2024, 6, 30)).isoformat(),
    ])
write_csv("customers.csv",
          ["customer_id", "customer_name", "emirate", "segment", "industry", "credit_limit", "onboard_date"],
          customers)

suppliers = []
for i, name in enumerate(SUPPLIER_NAMES, start=1):
    suppliers.append([
        i, name, random.choice(SUPPLIER_COUNTRIES),
        random.choice(["Pipes & Fittings", "Sanitary Ware", "Valves", "HVAC", "Pumps"]),
        round(random.uniform(3.0, 5.0), 1),
        random_date(date(2021, 1, 1), date(2023, 12, 31)).isoformat(),
    ])
write_csv("suppliers.csv",
          ["supplier_id", "supplier_name", "country", "category", "rating", "onboard_date"],
          suppliers)

products = []
pid = 1
for category, items in PRODUCT_CATALOG:
    for item in items:
        unit_cost = round(random.uniform(15, 1200), 2)
        margin_pct = random.uniform(0.20, 0.45)
        unit_price = round(unit_cost / (1 - margin_pct), 2)
        products.append([pid, item, category, item.split()[0], unit_cost, unit_price, "PCS"])
        pid += 1
write_csv("products.csv",
          ["product_id", "product_name", "category", "subcategory", "unit_cost", "unit_price", "uom"],
          products)

employees = []
for i, (name, role) in enumerate(EMPLOYEE_NAMES, start=1):
    employees.append([i, name, role, "Sales", random_date(date(2021, 1, 1), date(2023, 6, 30)).isoformat()])
write_csv("employees.csv", ["employee_id", "employee_name", "role", "department", "hire_date"], employees)

# ---------- Fact tables ----------

months = daterange_months(START_DATE, END_DATE)
n_customers = len(customers)
n_products = len(products)
n_employees = len(employees)
n_suppliers = len(suppliers)

orders = []
order_items = []
invoices = []
order_id = 1
order_item_id = 1
invoice_id = 1

# Slight seasonal + growth trend, with a deliberate dip in Aug 2026 for the "why did revenue fall" story
for (y, m) in months:
    days_in_month = 28 if m == 2 else (30 if m in (4, 6, 9, 11) else 31)
    month_start = date(y, m, 1)
    month_end = date(y, m, days_in_month)

    base_orders = 18 + months.index((y, m)) // 3  # gentle growth over time
    seasonal = 1.15 if m in (3, 4, 10, 11) else (0.85 if m in (7, 8) else 1.0)
    if (y, m) == (2026, 8):
        seasonal *= 0.65  # deliberate dip: project-4 will "explain" this
    n_orders_this_month = max(5, int(base_orders * seasonal))

    for _ in range(n_orders_this_month):
        cust = random.randint(1, n_customers)
        cust_emirate = customers[cust - 1][2]
        emp = random.randint(1, n_employees)
        odate = random_date(month_start, month_end)
        status = random.choices(["Completed", "Completed", "Completed", "Cancelled"], k=1)[0]
        orders.append([order_id, cust, odate.isoformat(), cust_emirate, emp, status])

        n_items = random.randint(1, 5)
        order_total = 0.0
        chosen_products = random.sample(range(1, n_products + 1), n_items)
        for p in chosen_products:
            prod = products[p - 1]
            unit_price = prod[5]
            qty = random.randint(2, 60)
            discount_pct = round(random.choice([0, 0, 0, 5, 10, 15]), 2)
            line_total = qty * unit_price * (1 - discount_pct / 100)
            order_total += line_total
            order_items.append([order_item_id, order_id, p, qty, unit_price, discount_pct])
            order_item_id += 1

        if status == "Completed":
            inv_date = odate + timedelta(days=random.randint(0, 3))
            due_date = inv_date + timedelta(days=30)
            paid_ratio = random.choices([1.0, 1.0, 0.5, 0.0], weights=[70, 15, 10, 5])[0]
            paid_amount = round(order_total * paid_ratio, 2)
            payment_date = (inv_date + timedelta(days=random.randint(5, 45))).isoformat() if paid_ratio > 0 else ""
            inv_status = "Paid" if paid_ratio == 1.0 else ("Partially Paid" if paid_ratio > 0 else "Unpaid")
            invoices.append([invoice_id, order_id, inv_date.isoformat(), due_date.isoformat(),
                              round(order_total, 2), paid_amount, payment_date, inv_status])
            invoice_id += 1

        order_id += 1

write_csv("orders.csv", ["order_id", "customer_id", "order_date", "emirate", "employee_id", "status"], orders)
write_csv("order_items.csv",
          ["order_item_id", "order_id", "product_id", "quantity", "unit_price", "discount_pct"], order_items)
write_csv("invoices.csv",
          ["invoice_id", "order_id", "invoice_date", "due_date", "amount", "paid_amount", "payment_date", "status"],
          invoices)

# Purchase orders (procurement side)
purchase_orders = []
po_id = 1
for (y, m) in months:
    days_in_month = 28 if m == 2 else (30 if m in (4, 6, 9, 11) else 31)
    month_start = date(y, m, 1)
    month_end = date(y, m, days_in_month)
    n_po = random.randint(6, 14)
    for _ in range(n_po):
        supplier = random.randint(1, n_suppliers)
        product = random.randint(1, n_products)
        po_date = random_date(month_start, month_end)
        qty = random.randint(50, 500)
        unit_cost = products[product - 1][4] * random.uniform(0.92, 1.05)
        lead_days = random.randint(7, 30)
        expected = po_date + timedelta(days=lead_days)
        delay = random.choices([0, 0, 0, random.randint(1, 10), random.randint(11, 25)], weights=[50, 15, 15, 12, 8])[0]
        actual = expected + timedelta(days=delay)
        status = "Delivered" if actual <= date.today() else "In Transit"
        purchase_orders.append([po_id, supplier, product, po_date.isoformat(), qty, round(unit_cost, 2),
                                 expected.isoformat(), actual.isoformat() if status == "Delivered" else "", status])
        po_id += 1
write_csv("purchase_orders.csv",
          ["po_id", "supplier_id", "product_id", "po_date", "quantity", "unit_cost",
           "expected_delivery_date", "actual_delivery_date", "status"], purchase_orders)

# RFQs (quotation pipeline)
rfqs = []
rfq_id = 1
order_ids_pool = [o[0] for o in orders]
for (y, m) in months:
    days_in_month = 28 if m == 2 else (30 if m in (4, 6, 9, 11) else 31)
    month_start = date(y, m, 1)
    month_end = date(y, m, days_in_month)
    n_rfq = random.randint(8, 20)
    for _ in range(n_rfq):
        cust = random.randint(1, n_customers)
        product = random.randint(1, n_products)
        rdate = random_date(month_start, month_end)
        qty = random.randint(10, 200)
        quoted_price = round(products[product - 1][5] * random.uniform(0.95, 1.1), 2)
        won = random.random() < 0.42
        status = "Converted" if won else random.choice(["Lost", "Pending", "Expired"])
        converted_order = random.choice(order_ids_pool) if won else ""
        rfqs.append([rfq_id, cust, product, rdate.isoformat(), qty, quoted_price, status, converted_order])
        rfq_id += 1
write_csv("rfqs.csv",
          ["rfq_id", "customer_id", "product_id", "rfq_date", "quantity", "quoted_price", "status",
           "converted_order_id"], rfqs)

# Inventory snapshot (current)
inventory = []
for p in products:
    qty_on_hand = random.randint(0, 800)
    reorder_level = random.randint(50, 150)
    inventory.append([p[0], "Abu Dhabi Main Warehouse", qty_on_hand, reorder_level, END_DATE.isoformat()])
write_csv("inventory.csv",
          ["product_id", "warehouse", "quantity_on_hand", "reorder_level", "last_updated"], inventory)

# Opex & Budget (for FP&A dashboard)
opex_categories = ["Salaries", "Rent", "Logistics", "Marketing", "Utilities", "IT & Software"]
opex_rows = []
budget_rows = []
opex_id = 1
budget_id = 1
base_opex = {"Salaries": 85000, "Rent": 30000, "Logistics": 18000, "Marketing": 9000,
             "Utilities": 6000, "IT & Software": 7000}
for (y, m) in months:
    month_label = f"{y}-{m:02d}"
    for cat in opex_categories:
        actual = base_opex[cat] * random.uniform(0.9, 1.15)
        budget = base_opex[cat] * random.uniform(0.97, 1.05)
        opex_rows.append([opex_id, month_label, cat, round(actual, 2)])
        budget_rows.append([budget_id, month_label, cat, round(budget, 2)])
        opex_id += 1
        budget_id += 1
write_csv("opex.csv", ["opex_id", "month", "category", "amount"], opex_rows)
write_csv("budget.csv", ["budget_id", "month", "category", "budget_amount"], budget_rows)

print(f"CSV files written to {DATA_DIR}")
print(f"orders={len(orders)}, order_items={len(order_items)}, invoices={len(invoices)}, "
      f"purchase_orders={len(purchase_orders)}, rfqs={len(rfqs)}")

# ---------- Build SQLite database ----------

if os.path.exists(DB_PATH):
    os.remove(DB_PATH)
conn = sqlite3.connect(DB_PATH)
cur = conn.cursor()

cur.executescript("""
CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    customer_name TEXT NOT NULL,
    emirate TEXT,
    segment TEXT,
    industry TEXT,
    credit_limit REAL,
    onboard_date TEXT
);

CREATE TABLE suppliers (
    supplier_id INTEGER PRIMARY KEY,
    supplier_name TEXT NOT NULL,
    country TEXT,
    category TEXT,
    rating REAL,
    onboard_date TEXT
);

CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category TEXT,
    subcategory TEXT,
    unit_cost REAL,
    unit_price REAL,
    uom TEXT
);

CREATE TABLE employees (
    employee_id INTEGER PRIMARY KEY,
    employee_name TEXT,
    role TEXT,
    department TEXT,
    hire_date TEXT
);

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(customer_id),
    order_date TEXT,
    emirate TEXT,
    employee_id INTEGER REFERENCES employees(employee_id),
    status TEXT
);

CREATE TABLE order_items (
    order_item_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id),
    product_id INTEGER REFERENCES products(product_id),
    quantity INTEGER,
    unit_price REAL,
    discount_pct REAL
);

CREATE TABLE invoices (
    invoice_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id),
    invoice_date TEXT,
    due_date TEXT,
    amount REAL,
    paid_amount REAL,
    payment_date TEXT,
    status TEXT
);

CREATE TABLE purchase_orders (
    po_id INTEGER PRIMARY KEY,
    supplier_id INTEGER REFERENCES suppliers(supplier_id),
    product_id INTEGER REFERENCES products(product_id),
    po_date TEXT,
    quantity INTEGER,
    unit_cost REAL,
    expected_delivery_date TEXT,
    actual_delivery_date TEXT,
    status TEXT
);

CREATE TABLE rfqs (
    rfq_id INTEGER PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(customer_id),
    product_id INTEGER REFERENCES products(product_id),
    rfq_date TEXT,
    quantity INTEGER,
    quoted_price REAL,
    status TEXT,
    converted_order_id INTEGER
);

CREATE TABLE inventory (
    product_id INTEGER REFERENCES products(product_id),
    warehouse TEXT,
    quantity_on_hand INTEGER,
    reorder_level INTEGER,
    last_updated TEXT
);

CREATE TABLE opex (
    opex_id INTEGER PRIMARY KEY,
    month TEXT,
    category TEXT,
    amount REAL
);

CREATE TABLE budget (
    budget_id INTEGER PRIMARY KEY,
    month TEXT,
    category TEXT,
    budget_amount REAL
);
""")


def load_csv(table, filename):
    path = os.path.join(DATA_DIR, filename)
    with open(path) as f:
        reader = csv.reader(f)
        header = next(reader)
        placeholders = ",".join("?" * len(header))
        cur.executemany(f"INSERT INTO {table} VALUES ({placeholders})", reader)


load_csv("customers", "customers.csv")
load_csv("suppliers", "suppliers.csv")
load_csv("products", "products.csv")
load_csv("employees", "employees.csv")
load_csv("orders", "orders.csv")
load_csv("order_items", "order_items.csv")
load_csv("invoices", "invoices.csv")
load_csv("purchase_orders", "purchase_orders.csv")
load_csv("rfqs", "rfqs.csv")
load_csv("inventory", "inventory.csv")
load_csv("opex", "opex.csv")
load_csv("budget", "budget.csv")

conn.commit()

# sanity check
for t in ["customers", "suppliers", "products", "employees", "orders", "order_items",
          "invoices", "purchase_orders", "rfqs", "inventory", "opex", "budget"]:
    cur.execute(f"SELECT COUNT(*) FROM {t}")
    print(t, cur.fetchone()[0])

conn.close()
print(f"SQLite database built at {DB_PATH}")
