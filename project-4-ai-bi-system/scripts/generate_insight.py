"""
generate_insight.py
--------------------
AI-Powered Business Intelligence System — Insight Engine (Step 1: the
"investigation" layer, before the AI writes the summary).

Flow this script implements:

    SQL Database -> Power Query/pandas -> Data Model -> Automated Diagnostics -> AI Explanation

Given a target month, this script:
  1. Pulls revenue for the target month and the prior month from the
     shared SQLite database.
  2. Breaks the change down by customer, product category, and emirate
     to find the biggest drivers (this is the "verification" data a
     human analyst — or you — should check before trusting any AI
     explanation).
  3. Optionally sends that structured breakdown to the Claude API to
     generate a plain-English explanation. If no API key is set, it
     prints a rule-based explanation instead, so the script is fully
     runnable without any credentials or network access.

Usage:
    python3 generate_insight.py --month 2026-08

Environment variable (optional, for the AI narrative step):
    ANTHROPIC_API_KEY=sk-ant-...
"""

import argparse
import os
import sqlite3
from datetime import datetime

DB_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..",
                        "shared-database", "mep_trading.db")


def prev_month(month_str):
    y, m = map(int, month_str.split("-"))
    if m == 1:
        return f"{y-1}-12"
    return f"{y}-{m-1:02d}"


def fetch_revenue_by(conn, month, dimension_sql, dimension_label):
    """dimension_sql must select (dimension_value, revenue) for the given month."""
    cur = conn.cursor()
    cur.execute(dimension_sql, (month,))
    return {row[0]: row[1] for row in cur.fetchall()}


def get_total_revenue(conn, month):
    cur = conn.cursor()
    cur.execute("""
        SELECT ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0)), 2)
        FROM orders o
        JOIN order_items oi ON oi.order_id = o.order_id
        WHERE o.status = 'Completed' AND strftime('%Y-%m', o.order_date) = ?
    """, (month,))
    result = cur.fetchone()[0]
    return result or 0.0


def get_breakdown(conn, month, group_col, group_table_join):
    cur = conn.cursor()
    query = f"""
        SELECT {group_col} AS grp,
               ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100.0)), 2) AS revenue
        FROM orders o
        JOIN order_items oi ON oi.order_id = o.order_id
        {group_table_join}
        WHERE o.status = 'Completed' AND strftime('%Y-%m', o.order_date) = ?
        GROUP BY grp
        ORDER BY revenue DESC
    """
    cur.execute(query, (month,))
    return dict(cur.fetchall())


def diff_breakdown(current, prior):
    keys = set(current) | set(prior)
    diffs = []
    for k in keys:
        cur_v = current.get(k, 0.0)
        prior_v = prior.get(k, 0.0)
        diffs.append((k, cur_v - prior_v, cur_v, prior_v))
    diffs.sort(key=lambda x: x[1])  # most negative first (biggest declines)
    return diffs


def build_investigation(month):
    conn = sqlite3.connect(DB_PATH)
    p_month = prev_month(month)

    total_current = get_total_revenue(conn, month)
    total_prior = get_total_revenue(conn, p_month)
    total_change = total_current - total_prior
    total_change_pct = (100 * total_change / total_prior) if total_prior else 0

    by_emirate_cur = get_breakdown(conn, month, "o.emirate", "")
    by_emirate_prior = get_breakdown(conn, p_month, "o.emirate", "")

    by_category_cur = get_breakdown(conn, month, "p.category", "JOIN products p ON p.product_id = oi.product_id")
    by_category_prior = get_breakdown(conn, p_month, "p.category", "JOIN products p ON p.product_id = oi.product_id")

    by_customer_cur = get_breakdown(conn, month, "c.customer_name",
                                     "JOIN customers c ON c.customer_id = o.customer_id")
    by_customer_prior = get_breakdown(conn, p_month, "c.customer_name",
                                       "JOIN customers c ON c.customer_id = o.customer_id")

    order_count_cur = conn.execute(
        "SELECT COUNT(*) FROM orders WHERE status='Completed' AND strftime('%Y-%m', order_date)=?",
        (month,)).fetchone()[0]
    order_count_prior = conn.execute(
        "SELECT COUNT(*) FROM orders WHERE status='Completed' AND strftime('%Y-%m', order_date)=?",
        (p_month,)).fetchone()[0]

    conn.close()

    return {
        "month": month,
        "prior_month": p_month,
        "total_current": total_current,
        "total_prior": total_prior,
        "total_change": round(total_change, 2),
        "total_change_pct": round(total_change_pct, 2),
        "order_count_current": order_count_cur,
        "order_count_prior": order_count_prior,
        "emirate_diffs": diff_breakdown(by_emirate_cur, by_emirate_prior)[:5],
        "category_diffs": diff_breakdown(by_category_cur, by_category_prior)[:5],
        "customer_diffs": diff_breakdown(by_customer_cur, by_customer_prior)[:5],
    }


def rule_based_explanation(data):
    lines = []
    direction = "fell" if data["total_change"] < 0 else "rose"
    lines.append(
        f"Revenue {direction} from AED {data['total_prior']:,.0f} in {data['prior_month']} "
        f"to AED {data['total_current']:,.0f} in {data['month']} "
        f"({data['total_change_pct']:+.1f}%, AED {data['total_change']:,.0f})."
    )
    lines.append(
        f"Completed order count moved from {data['order_count_prior']} to {data['order_count_current']}."
    )
    lines.append("\nBiggest emirate-level movers:")
    for name, change, cur_v, prior_v in data["emirate_diffs"]:
        lines.append(f"  - {name}: AED {change:+,.0f} (from {prior_v:,.0f} to {cur_v:,.0f})")
    lines.append("\nBiggest product-category movers:")
    for name, change, cur_v, prior_v in data["category_diffs"]:
        lines.append(f"  - {name}: AED {change:+,.0f} (from {prior_v:,.0f} to {cur_v:,.0f})")
    lines.append("\nBiggest customer-level movers:")
    for name, change, cur_v, prior_v in data["customer_diffs"][:5]:
        lines.append(f"  - {name}: AED {change:+,.0f} (from {prior_v:,.0f} to {cur_v:,.0f})")
    lines.append(
        "\nNote: this is a rule-based summary of the underlying numbers. "
        "Always verify the top drivers above against the source orders before "
        "presenting to management — that verification step is what makes this "
        "trustworthy, not just automated."
    )
    return "\n".join(lines)


def ai_explanation(data):
    """Optional: call the Anthropic API to turn the structured diagnostics into
    a polished narrative. Requires ANTHROPIC_API_KEY. Falls back gracefully."""
    api_key = os.environ.get("ANTHROPIC_API_KEY")
    if not api_key:
        return None
    try:
        import anthropic
    except ImportError:
        print("[info] `anthropic` package not installed — skipping AI narrative step. "
              "Install with: pip install anthropic")
        return None

    client = anthropic.Anthropic(api_key=api_key)
    prompt = f"""You are a business intelligence analyst. Based on the structured data
below, write a short (4-6 sentence) plain-English explanation of what changed
in revenue this month and the most likely drivers. Be specific with numbers.
Do not invent any figures not present in the data.

DATA:
{data}
"""
    response = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=400,
        messages=[{"role": "user", "content": prompt}],
    )
    return "".join(block.text for block in response.content if hasattr(block, "text"))


def main():
    parser = argparse.ArgumentParser(description="Explain a month's revenue change.")
    parser.add_argument("--month", default=None, help="Target month as YYYY-MM (default: latest month with data)")
    args = parser.parse_args()

    month = args.month
    if month is None:
        conn = sqlite3.connect(DB_PATH)
        month = conn.execute(
            "SELECT strftime('%Y-%m', MAX(order_date)) FROM orders WHERE status='Completed'"
        ).fetchone()[0]
        conn.close()

    data = build_investigation(month)

    print("=" * 70)
    print(f"REVENUE INVESTIGATION: {data['month']} vs {data['prior_month']}")
    print("=" * 70)

    narrative = ai_explanation(data)
    if narrative:
        print("\n[AI-generated explanation — verify against the data below]\n")
        print(narrative)
    else:
        print("\n[Rule-based explanation — set ANTHROPIC_API_KEY to use the AI narrative step]\n")
        print(rule_based_explanation(data))

    print("\n" + "-" * 70)
    print("Raw diagnostic data (for verification):")
    print("-" * 70)
    for key in ["total_current", "total_prior", "total_change", "total_change_pct",
                "order_count_current", "order_count_prior"]:
        print(f"  {key}: {data[key]}")
    print("  emirate_diffs (name, change, current, prior):")
    for row in data["emirate_diffs"]:
        print(f"    {row}")
    print("  category_diffs (name, change, current, prior):")
    for row in data["category_diffs"]:
        print(f"    {row}")


if __name__ == "__main__":
    main()
