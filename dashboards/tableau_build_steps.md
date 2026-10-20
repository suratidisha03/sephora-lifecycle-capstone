# Tableau Public: cohort dashboard (Stage 8, guide step 2)
Built by Disha in Tableau Public Desktop. About 45 minutes. Data is SIMULATED (seed 42).

## Data files (already in dashboards/data/)
- `tableau_cohort_long.csv`: 36 rows, one per cohort month x months since first order (0 to 5). `pct_ordering` is empty for months not reached yet.
- `dash_customers.csv`: 747 rows, one per purchasing customer.

## 1. Connect
1. Open Tableau Public. Connect > Text file > `tableau_cohort_long.csv`.
2. Data > New Data Source > Text file > `dash_customers.csv`. (Two separate sources. Don't join them.)
3. In the cohort source, right-click `months_since_first_order` > Convert to Dimension, then Convert to Discrete.

## 2. Sheet "Cohort heatmap" (source: tableau_cohort_long)
1. Drag `months_since_first_order` to Columns and `cohort_month` to Rows.
2. Drag `months_since_first_order` to Filters and untick 0. (Month 0 is 100% by definition; the SQL table starts at month 1.)
3. Marks card: change Automatic to Square.
4. Drag `pct_ordering` to Color and again to Label. Right-click each pill > Measure > Average.
5. Color > Edit Colors: a single-color sequential palette (any brand-neutral one). Skip red/green.
6. Keep future months blank. Click the small "nulls" indicator at the bottom right > Hide indicator. Don't use ZN(), because it turns blanks into 0.
7. Format the label: right-click Label pill > Format > Numbers > Number (custom), 1 decimal, suffix `%`.
8. Title: "% of each first-purchase cohort who ordered again N months later".

**Check against SQL (sql/13):** Jan m1 23.9, m2 29.3, m5 10.4. Feb m2 33.9. Jun row has no colored cells. Feb m5, Mar m4 and m5, Apr m3 to m5, May m2 to m5 are blank, not 0.

## 3. Sheet "Customers by order count" (source: dash_customers)
1. `order_bucket` to Columns. `customer_id` to Rows > right-click > Measure > Count (Distinct).
2. Show labels (toolbar T button). Sort order: 1 order, 2 orders, 3+ orders.
3. Title: "Purchasing customers by number of orders".

**Check:** 431 / 180 / 136, total 747.

## 4. Sheet "Revenue per customer by cohort" (source: dash_customers)
1. Analysis > Create Calculated Field, name `Observed revenue per customer`: `SUM([net_revenue]) / COUNTD([customer_id])`.
2. `cohort_month` to Columns, the new field to Rows. Bar chart. Labels on, currency, 2 decimals.
3. Title: "Observed revenue per customer by first-purchase cohort (not lifetime value)".

**Check:** Jan $129.46, Feb $128.53, Mar $123.38, Apr $103.40, May $82.57, Jun $72.00. Later cohorts are lower because they've had less time, not because they're worse customers. Say this in a caption.

## 5. Dashboard
1. New Dashboard, size Fixed 1200 x 900.
2. Text box at top: **Sephora capstone: customer cohorts and repeat buying**, then on the next line: *SIMULATED data (seed 42), Jan 1 to Jun 30, 2026. Independent portfolio concept by Disha Surati. Not affiliated with Sephora.*
3. Heatmap across the top; the two bar charts side by side below.
4. Text box at bottom, definitions:
   - Cohort = month of a customer's first purchase. Cell = % of that cohort who placed an order N months later. Blank = month not reached by Jun 30, 2026 (never 0).
   - Observed revenue per customer = net revenue / purchasing customers, as of Jun 30, 2026. Not lifetime value.
   - Source: sql/15_dashboard_extracts.sql (same logic as sql/12 and sql/13).

## 6. Publish and check
1. File > Save to Tableau Public As > `Sephora Capstone - Cohorts (Simulated)`. Sign in if asked.
2. Also File > Save As a `.twbx` copy into `dashboards/`.
3. Open the public link in an Incognito window (signed out). Check it loads and the numbers match the checks above.
4. Send Claude the public link. Claude logs it in the QA log.
