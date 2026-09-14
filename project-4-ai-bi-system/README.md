# Project 4 — AI-Powered Business Intelligence System

**This is the differentiator project.** It shows you can go beyond building
static dashboards toward the direction BI is heading: automated diagnosis
of *why* a number changed, with the evidence shown alongside the
explanation so it can be verified — not a black-box answer.

## Architecture

```
SQL Database (mep_trading.db)
        ↓
Pandas / SQL aggregation  (stands in for Power Query in this script)
        ↓
Structured diagnostic breakdown
   (by emirate, product category, customer — current vs. prior month)
        ↓
AI narrative layer (optional — Anthropic API, with a rule-based fallback)
        ↓
Verifiable explanation + raw supporting numbers printed together
```

## Why "you verify the answer" matters

An LLM asked "why did revenue fall?" will produce a fluent, confident-sounding
paragraph whether or not it's actually grounded in your data. This project
is built so that **every claim in the explanation is traceable to a number
you can check** — the script always prints the raw breakdown (by emirate,
category, and customer) beneath the narrative. That's the difference between
"AI-powered" as a buzzword and AI-powered as an actual, defensible analytics
practice — a distinction worth raising explicitly in an interview.

## Try it

```bash
cd project-4-ai-bi-system/scripts
python3 generate_insight.py --month 2026-08
```

This targets a deliberate revenue dip built into the sample dataset
(August 2026) and prints:
1. Total revenue change vs. the prior month
2. The top 5 emirates, product categories, and customers driving that change
3. A plain-English explanation (rule-based by default; if you set
   `ANTHROPIC_API_KEY` and `pip install anthropic`, it instead asks Claude
   to turn the same structured data into a narrative)

## Extending this into a full "automated management report"

- Schedule the script (e.g. via cron or Power Automate) to run on the 1st
  of each month against the latest data.
- Feed its structured JSON output into a Power BI paginated report or an
  emailed summary.
- Add more dimensions to investigate (sales rep, discount level, RFQ
  conversion) as additional drill-down candidates.
- If wiring up the real Anthropic API, always keep the raw diagnostic table
  in the output — never ship the narrative alone.

## Skills demonstrated

Python (pandas/sqlite3), programmatic root-cause analysis, prompt design
for a verifiable (not hallucination-prone) AI output, and an understanding
of where AI fits into a BI pipeline as an accelerant for analysis — not a
replacement for it.
