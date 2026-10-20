# Project Brief: Sephora, From Customer Insights to Lifecycle Strategy

**Owner:** Disha Surati
**Type:** Independent portfolio project (capstone)
**Status:** Stage 1, scope frozen on Oct 8, 2026

## Disclosure
This is an independent, speculative portfolio project. It is not commissioned by or affiliated with Sephora. Public review data is historical. Campaign and customer performance data are simulated. Actual spend is $0.

## Business question
How could customer-review insights guide clearer product discovery, useful lifecycle emails, and better acquisition-to-repeat-purchase decisions?

This is a proposed research question. It is not evidence that Sephora has a performance problem.

## Scope
| Decision | Specification |
|---|---|
| Subject | Sephora skincare shopping experience. Sephora is the retailer. No new brand identity is invented. |
| Product scope | Cleansers and moisturizers. Three focal products are chosen after inspecting the dataset. Current product facts are verified on official pages before writing copy. |
| Audience | Hypothesis: first-time skincare shoppers looking for clear product guidance. This is validated with review evidence, not assumed demographics. |
| Public data | Sephora Products and Skincare Reviews (Kaggle, by nadyinky). Collected March 2023. |
| Simulation | Jan 1 to Jun 30, 2026, in USD. Hypothetical paid spend of $3,000 during Jan 1 to 30 only ($1,800 search, $1,200 social). Zero paid spend on all other dates. Seed 42. |
| Actual budget | $0. No live ads, product purchases, paid connectors, store subscription, domain, AI upgrade, or paid automation. |

## Evidence layers (kept separate at all times)
1. **Public:** historical Sephora product and review data from Kaggle.
2. **Simulated:** campaigns, sessions, events, orders, and email records, used for metric practice.
3. **Test:** my own controlled website (GA4/GTM) and Mailchimp tests.

Rules:
- Public reviewers are never joined to synthetic customers.
- Reviews are never treated as purchases.
- No claims of affiliation, real sales lift, live media buying, or automated deployment without evidence.

## Core outputs
- Public-review SQL and an insight brief
- SEO and copy deck
- Demo website with GA4/GTM tracking tests
- Synthetic data and SQL analyses
- CRM practice module (HubSpot Free or a Sheets prototype)
- Mailchimp lifecycle prototypes: welcome, cart recovery, win-back
- Looker Studio report (acquisition and conversion)
- Tableau Public dashboard (customers, cohorts, observed value)
- QA log and an evidence-linked case study

## Naming convention
- Project folder: `independent_sephora_capstone`
- `public_` = downloaded review and product records
- `sim_` = generated records
- `test_` = controlled implementation logs
- Every chart states its evidence layer, period, filters, and denominator.

## Tools ($0)
SQLite, Google Sheets, GA4 + GTM, Mailchimp Free, HubSpot Free (or a Sheets CRM prototype), Looker Studio, Tableau Public, Claude.

## Timeline
Six weeks at 8 to 10 hours a week. Move to the next stage only when its gate is passed (guide page 33).

| Week | Stages |
|---|---|
| 1 | 1 to 2: brief, public data, SQL load |
| 2 | 3 to 4: insights, SEO, copy |
| 3 | 5: demo site and GA4/GTM |
| 4 | 6 to 7: simulation, SQL, CRM, email |
| 5 | 8: Looker Studio, Tableau, QA |
| 6 | 9: case study and resume bullets |

## Working logs
- `decisions.csv`: what was decided and why
- `assumptions.md`: every assumption, especially for the simulated data
- `qa/qa_log.csv`: test ID, component, scenario, expected result, actual result, status, evidence, fix, retest date
- `ai_log/ai_log.md`: task, prompt, draft, error found, correction, final check
