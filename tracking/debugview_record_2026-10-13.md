# GA4 DebugView record (2026-10-13)

Property: Routine Guide DEMO (test), G-84Y4B5ERNJ. Read from Admin > DebugView at 8:54 PM CT, during the GTM Preview session (unpublished container).

Top events, last 30 minutes (23 total):

| Event | Count | Expected from the test clicks |
|---|---|---|
| add_to_cart | 11 | 11 (repeat clicks, see QA-21) |
| view_item | 2 | 2 |
| select_content | 2 | 2 |
| begin_checkout | 1 | 1 |
| purchase | 1 | 1 |
| sign_up | 1 | 1 |
| page_view, session_start, first_visit, scroll, form_start | 1 each | Automatic (enhanced measurement) |

Timeline: page_view 8:34:09 PM, add_to_cart 8:34:52 to 8:35:38, begin_checkout 8:40:01, purchase 8:40:04, select_content 8:40:38 and 8:40:42, sign_up 8:41:33.

Result: every custom event sent from the data layer reached GA4, with counts matching Tag Assistant exactly.
Note: form_start is an automatic enhanced-measurement event from the signup form. It isn't one of the 6 tracked events.
