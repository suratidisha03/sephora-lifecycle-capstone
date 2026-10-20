# Sephora: From Customer Insights to Lifecycle Strategy

Independent capstone by Disha Surati, October 2026.

> Independent capstone using Sephora as the subject of a speculative project. Public review data is historical. Campaign and customer performance are simulated. I built the linked analysis, dashboards and email prototypes; tracking and test-send evidence is labeled separately. Not affiliated with Sephora. Actual spend: $0.

This repo holds the SQL, QA log, metric definitions and simulated data behind the project, so anyone can check or rerun the numbers.

## Start here
| Link | What it shows |
|---|---|
| [Case study](https://suratidisha03.github.io/PORTFOLIO/work-sephora.html) | Problem, method, 3 findings, decisions, validation, limits |
| [Looker Studio report](https://datastudio.google.com/reporting/7f7a22b2-0624-46f8-b9d5-4b598d8d3266) | Acquisition, funnel, customers and email (simulated) |
| [Tableau Public dashboard](https://public.tableau.com/app/profile/disha.surati/viz/Sephora_Capstone_Cohorts_twbx/Cohortsdashboard) | Repeat buying by first-purchase cohort (simulated) |
| [Live demo site](https://suratidisha03.github.io/routine-guide-demo/) | GA4 and GTM events, cart email link (test traffic only) |
| [`qa/qa_log.csv`](qa/qa_log.csv) | 53 logged checks: data, SQL, tracking, email, dashboards |

## Three evidence layers (never mixed)
| Layer | What it is | Prefix |
|---|---|---|
| Public | 9,999 Sephora reviews of 3 skincare products ([Kaggle, nadyinky](https://www.kaggle.com/datasets/nadyinky/sephora-products-and-skincare-reviews), collected March 2023, CC BY 4.0) | `public_` |
| Simulated | Jan 1 to Jun 30, 2026, seed 42: 1,000 customers, 40,000 sessions, 1,251 orders, 3,126 emails, $3,000 hypothetical ad spend | `sim_` |
| Test | My own demo site and Mailchimp test sends | `test_` |

Reviewers are never joined to simulated customers, and reviews are never treated as purchases.

## Folders
```
sql/               01-08 public review cleaning and theme checks; 09-14 simulated analyses; 15 dashboard extracts
simulation/        metric definitions (locked before analysis), simulation assumptions, generator and rules-check scripts
data/sim/          simulated tables (sim_sessions and sim_events left out for size; rerun simulation/generate_sim_data.py, seed 42)
dashboards/data/   the extracts behind Looker Studio and Tableau
insights/          review theme rubric, insight log, simulated-data findings
emails/            lifecycle flow rules, flow diagram, scenario tests
tracking/          GA4/GTM tracking spec and DebugView record
copywriting/       copy deck and line-by-line traceability to evidence
qa/                QA log
case_study/        case study (markdown)
ai_log/            where AI helped and how each output was checked
brief/, sources/   scope and data source notes
dictionary.csv     table and field dictionary
decisions.csv      decision log
```

Raw Kaggle files are not included. Download them from the link above to rerun `sql/01` to `sql/08` in SQLite.

## Key definitions
- **Attribution:** same-session last click.
- **ROAS:** attributed net revenue / paid spend. Not profit.
- **Funnel:** a step counts only after the previous step in the same session.
- **Cohorts:** by first-purchase month; months not yet reached are blank, never 0.
- **Revenue per customer and 90-day value:** observed only. Never called lifetime value.

Full list: [`simulation/metric_definitions.md`](simulation/metric_definitions.md).
