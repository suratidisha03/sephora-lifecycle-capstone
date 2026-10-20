# Lifecycle Flow Spec (Stage 7)

Status: v1, 2026-10-14. **Prototype.** Mailchimp Free doesn't run multi-step automations, so the flows below are specified, desk-tested with a rules check, and test-sent by hand. They are not live automations.
Sender for all emails: "Disha from The Routine Guide". Only Disha's own addresses (suratidisha+...@gmail.com) ever receive emails.
Source of timings: the guide (Stage 7, steps 3 and 4). Copy: copywriting/copy_deck.md (EM-01 to EM-07). Designs: emails/final/.

## 1. Segments (CRM field: lifecycle_segment)
The guide lists 5 segments. A 6th, "Repeat buyer, active", is added because a customer with 2+ orders in the last 60 days fits none of the 5.
| Segment | Rule | Flow it can enter |
|---|---|---|
| New subscriber | Signed up with email permission, no order yet | Welcome |
| Cart abandoner | Added to cart, no purchase within 4 hours | Cart recovery |
| First-time buyer | Exactly 1 order, last order under 60 days ago | None (waits; win-back at day 60) |
| Repeat buyer, active | 2+ orders, last order under 60 days ago | None (waits; win-back at day 60) |
| Lapsed buyer | 1+ orders, last order 60+ days ago | Win-back |
| Suppressed | Unsubscribed, bounced, or no email permission | None, ever |

## 2. Flows
| Flow | Trigger | Emails and timing | Exits early when | Cooldown |
|---|---|---|---|---|
| Welcome | Signup with permission | EM-01 day 0, EM-02 day 2, EM-03 day 5 | Purchase, unsubscribe, bounce | Once per person |
| Cart recovery | add_to_cart with no purchase in 4 hours | EM-04 at +4 hours, EM-05 at +24 hours (4 + 20) | Purchase, unsubscribe | 7 days from flow start: a new cart inside 7 days does not restart the flow |
| Win-back | 60 days since last order | EM-06 at day 60, EM-07 at day 67 | Purchase, unsubscribe | 60 days after the flow ends before re-entry |

## 3. Rules (apply to every marketing email)
| ID | Rule |
|---|---|
| R1 | Suppressed people get no emails. Unsubscribing exits every flow at once. |
| R2 | A purchase exits the welcome, cart and win-back flows at once. Emails not yet sent are cancelled. |
| R3 | At most 1 marketing email per person per day. If two are due the same day, priority decides: **cart, then welcome, then win-back**. The other moves to the next free day. |
| R4 | Max 3 marketing emails per person in any rolling 7 days. An email that would be the 4th waits for the first day it fits. If it can't go out within 7 days of its due date, it is skipped and logged. |
| R5 | A cart email is never sent without a working cart link. If the link is missing, the email is held and logged as an error. A broken email never goes out. Cart link format: `index.html?cart=<item_id>:<qty>,...`; the demo page rebuilds the bag from it (QA-33). |
| R6 | A second cart during the cart flow does not restart it. The next cart email uses the latest cart link. |
| R7 | Every email has an unsubscribe link and the "independent concept, not affiliated with Sephora" label. |

## 4. Required test scenarios (guide step 7)
| ID | Scenario | Expected result |
|---|---|---|
| S1 | Buys before welcome email 2 | Gets EM-01 only; EM-02 and EM-03 cancelled (R2) |
| S2 | Unsubscribes after email 1 | Gets EM-01 only; moves to Suppressed; no future emails (R1) |
| S3 | Second cart mid-flow | No restart; EM-05 uses the second cart's link; 2 cart emails total (R6) |
| S4 | Win-back customer repurchases | EM-06 sent; EM-07 cancelled; win-back can start again 60 days after the new order (R2, cooldown) |
| S5 | Missing cart link | No cart email sent; error logged (R5) |
Extra checks: priority and cap together (R3, R4); a no-permission contact gets nothing (R1).

## 5. Known differences from Stage 6
The Stage 6 simulation used simplified email timing for metric practice: 1 cart email at 24 hours, and 1 win-back email on the 1st of each month for buyers lapsed 60+ days. **This spec is the real design.** The Stage 6 email numbers (click rate 2.07%) measure the metric correctly but don't come from these exact flows. Decided by Disha, 2026-10-14.

## 6. Tools
- **HubSpot Free:** 10 practice contacts with source, permission, segment, purchase facts and next action (crm/practice_contacts.csv).
- **Mailchimp Free:** 7 templates built, each test-sent to Disha's own inbox, screenshots saved. No live automation (paid feature).
