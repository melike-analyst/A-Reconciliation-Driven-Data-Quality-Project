# Data Quality Report

**Objective:** Identify discrepancies between `objects.funding_total_usd` and the aggregated funding total calculated from `funding_rounds`.

## Priority Anomalies (Top 10)

| Company | Discrepancy | Possible Root Cause | Recommended Action |
| :--- | :--- | :--- | :--- |
| **Clearwire** | 4.70B USD | Missing funding rounds or incomplete ETL load. | Verify `funding_rounds` and ETL logs. |
| **Verizon Communications, Inc.** | 3.84B USD | `objects` total may include funding types outside `funding_rounds`. | Review calculation logic. |
| **sigmacare** | 2.60B USD | Amount field NULL/0 or join issue. | Manual inspection. |
| **Carestream** | 2.40B USD | Incomplete funding data. | Validate source records. |
| **Facebook** | 1.50B USD | Snapshot missing historical rounds. | Compare with source dataset. |
| **Terra-Gen Power** | 1.20B USD | Aggregation missing records. | Review funding rounds. |
| **Xerox** | 1.10B USD | Funding type excluded. | Validate mapping rules. |
| **Wave Broadband** | 1.05B USD | Aggregation returned zero. | Check joins and amounts. |
| **BlackBerry** | 1.00B USD | Historical records missing. | Review completeness. |
| **AOL** | 1.00B USD | Business rule differences. | Review funding definitions. |

---

## Key Findings

- **25 companies** have discrepancies between `objects.funding_total_usd` and the calculated funding total. [cite: 2]
- Largest discrepancies range from **USD 1B to USD 4.7B**. [cite: 2]
- Several records have a calculated funding total of zero despite high reported totals. [cite: 2]
- Some companies contain funding rounds but their aggregated values remain significantly lower than expected. [cite: 2]
- Snapshot limitations or differences in funding definitions may explain part of the discrepancies. [cite: 2]

---

## Analyst Action Summary

1. Manually review the top 10 discrepancies. [cite: 2]
2. Investigate records where the calculated funding total equals zero. [cite: 2]
3. Validate ETL completeness for `funding_rounds`. [cite: 2]
4. Review business rules used to populate `funding_total_usd`. [cite: 2]
5. Assess dataset snapshot limitations. [cite: 2]

---

## Recommended Records for Manual Review

- Clearwire [cite: 2]
- Verizon Communications, Inc. [cite: 2]
- sigmacare [cite: 2]
- Carestream [cite: 2]
- Facebook [cite: 2]
- Terra-Gen Power [cite: 2]
- Xerox [cite: 2]
- Wave Broadband [cite: 2]
- BlackBerry [cite: 2]
- AOL [cite: 2]
