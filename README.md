# A-Reconciliation-Driven-Data-Quality-Project

Cleaning, modeling, and cross-checking $6.7B+ in startup funding data from the Crunchbase 2013 Snapshot — and catching a data quality bug my own anomaly-detection method introduced.

Why this project

Most data cleaning tutorials stop at "remove nulls, flag outliers." This project goes one step further: it uses an independent reconciliation check to actually verify whether the cleaning method worked — and in doing so, uncovers a genuine ETL/data-quality issue in a handful of billion-dollar companies.

What's inside
A 6-table relational model (SQLite in dev / SQL Server for production) built from the raw Crunchbase 2013 CSVs — companies, funding rounds, investments, funds, acquisitions, and IPOs, connected with real foreign keys.
A full cleaning pipeline in Python/pandas: missing-value audits, duplicate removal, date validation, and two competing outlier-detection methods (raw IQR vs. log-transformed IQR).
A reconciliation engine: cross-checks objects.funding_total_usd (a pre-computed summary field) against an independently recalculated total from funding_rounds, across three different cleaning scenarios.
SQL analytics: category-level funding trends, year-over-year volume, top investors, and an outlier-methodology comparison query.
An AI-assisted quality review: a Claude-based agent that takes the reconciliation output and produces a prioritized, action-oriented anomaly report.
The finding that made this project worth doing

I started with a simple hypothesis: log-transforming amounts before running IQR should reduce false positives from skewed, large-but-legitimate funding rounds (Series C, post-IPO, etc.).

The result was the opposite of what I expected — log-IQR flagged more rows than raw IQR (6,054 vs. 5,400). Instead of assuming my hypothesis was wrong and moving on, I dug into which rows each method flagged:

Method	Rows flagged (uniquely)	Amount distribution
Raw IQR only	5,388	median ~$28M, max $950M — legitimate large rounds
Log-IQR only	6,042	median $0, max $1,700 — negligible/likely-erroneous amounts

So the two methods weren't competing — they were catching two different problems. Raw IQR was flagging real money as fake anomalies. Log-IQR was catching genuinely bad data that raw IQR missed entirely.

To confirm which method was actually more trustworthy, I ran a reconciliation test: recompute funding_total_usd from funding_rounds, once excluding rows flagged by each method, and see which produces fewer contradictions with the pre-existing summary field.

Scenario	Companies with mismatched totals
No rows excluded (baseline)	0
Excluding raw-IQR-flagged rows	3,778
Excluding log-IQR-flagged rows	25

Excluding rows flagged by raw IQR broke the totals for 3,778 companies — proof those rows were real data being incorrectly treated as noise. Excluding log-IQR-flagged rows left only 25 real discrepancies. The reconciliation check didn't just validate a cleaning choice — it caught the raw IQR method in the act of manufacturing false anomalies.

An AI agent that reads the mess for you

I fed those 25 remaining discrepancies to a Claude-based "Data Quality Reviewer" agent (see ai_agent/data_quality_agent.md). Without being told anything about the underlying schema, it independently split the 25 companies into two distinct failure patterns:

10 companies with funding_rounds = 1 but a computed total of $0 — a join or missing-amount issue at the single-record level.
15 companies with multiple funding rounds where the totals still don't reconcile — pointing to partial data loss across records.

It then produced a ranked table (top companies by deviation — Clearwire at $4.7B, Verizon at $3.84B, Facebook at $1.5B, etc.), a plausible root cause for each, and a 5-step action checklist for a human analyst to follow up on. Full report in docs/ai_agent_report.md.

Tech stack

Python (pandas, numpy) · Jupyter · SQL Server / SQLite · SQL · Claude (AI agent)

Repo structure
notebooks/          # exploration & cleaning process
scripts/queries.sql  # SQL analytics
data/raw/            # raw Crunchbase CSVs
data/processed/      # cleaned intermediate outputs
docs/                # ER diagram, data dictionary, AI agent report
ai_agent/            # Claude agent instructions
Ideas for extending this
Formalize a is_negligible_amount threshold (0 < amount < $1,000) as an explicit validation rule rather than an implicit log-IQR side effect.
Bring in investments and funds tables for investor-network analysis.
Build a trend dashboard (Power BI or Python/plotly).
