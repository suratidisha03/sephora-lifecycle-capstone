"""
Stage 6 simulated data generator.
Evidence layer: SIMULATED. Nothing here describes real Sephora performance.
Seed 42. Same script + same seed = same data, every time.
Every input below is listed in simulation/sim_assumptions.md with its source or label.
Run: python3 generate_sim_data.py <output_folder>
"""
import sys, csv, os, random, math
from datetime import datetime, timedelta, date

SEED = 42
rng = random.Random(SEED)

OUT = sys.argv[1] if len(sys.argv) > 1 else "data/sim"
os.makedirs(OUT, exist_ok=True)

# ---------- Fixed by brief ----------
START = date(2026, 1, 1)
END = date(2026, 6, 30)
PAID_LAST_DAY = date(2026, 1, 30)
DAYS = [(START + timedelta(d)) for d in range((END - START).days + 1)]
PAID_DAYS = [d for d in DAYS if d <= PAID_LAST_DAY]

# ---------- Campaigns (equal budget split inside each channel, so no campaign is favored) ----------
CAMPAIGNS = [
    # id, name, channel, budget
    ("C01", "SRCH_fresh_cleanser_scent_texture", "paid_search", 900.00),
    ("C02", "SRCH_fab_cream_pilling_tips", "paid_search", 900.00),
    ("C03", "SOC_protini_value_explainer", "paid_social", 600.00),
    ("C04", "SOC_two_step_routine_guide", "paid_social", 600.00),
]
# Sourced inputs (Triple Whale Beauty medians, Aug 2025 to Jul 2026)
CTR = {"paid_search": 0.0161, "paid_social": 0.0246}
CPM = {"paid_search": 18.38, "paid_social": 18.38}  # Meta beauty CPM not published; Google figure reused (flagged)
CVR = {"paid_search": 0.0433, "paid_social": 0.0179}

# ---------- Labeled assumptions (no public source) ----------
P_UTM_LOST = 0.03          # paid sessions that lose their tag
P_PAID_SIGNUP_ONLY = 0.04  # paid session signs up without buying
N_CUSTOMERS = 1000
P_FIRST_BUY_NONPAID = 0.85 # non-paid new customer buys in the first session (else signs up only)
NONPAID_CHANNEL_MIX = [("organic_search", 0.45), ("direct", 0.25), ("referral", 0.15), ("organic_social", 0.15)]
P_REPEAT = 0.55            # chance a buyer orders again after each order (direct/organic return)
REPEAT_GAP_MEAN, REPEAT_GAP_SD, REPEAT_GAP_MIN = 45, 15, 14  # days; skincare repurchase cycle assumption
REPEAT_CHANNEL_MIX = [("direct", 0.6), ("organic_search", 0.4)]
P_EMAIL_OPT_IN = 0.80
P_BOUNCE = 0.01
P_EMAIL_CLICK = 0.02       # Mailchimp: 2.62% all users, 1.74% e-commerce (Dec 2023)
P_EMAIL_SESSION_BUY = 0.08
MEAN_BROWSE_SESSIONS = 4   # extra non-buying sessions per customer
TARGET_SESSIONS = 40000    # approved option B (about 3% visit-to-order)
FUNNEL = {"view": 0.50, "cart_given_view": 0.18, "checkout_given_cart": 0.40}
P_REFUND = 0.05
REFUND_DELAY = (3, 30)
PRODUCTS = [("P7880", "Soy Hydrating Gentle Face Cleanser", "fresh", "Cleanser", 39.00),
            ("P248407", "Ultra Repair Cream Intense Hydration", "First Aid Beauty", "Moisturizer", 42.00),
            ("P427421", "Protini Polypeptide Firming Refillable Moisturizer", "Drunk Elephant", "Moisturizer", 72.00)]
N_ITEMS_MIX = [(1, 0.70), (2, 0.25), (3, 0.05)]
WELCOME_STEPS_DAYS = [0, 2, 5]
WINBACK_DATES = [date(2026, m, 1) for m in (3, 4, 5, 6)]
WINBACK_LAPSE_DAYS = 60
CART_EMAIL_DELAY_H = 24


def pick(mix):
    r = rng.random(); acc = 0
    for v, p in mix:
        acc += p
        if r < acc:
            return v
    return mix[-1][0]

def rand_ts(d, h0=7, h1=23):
    return datetime(d.year, d.month, d.day, rng.randint(h0, h1 - 1), rng.randint(0, 59), rng.randint(0, 59))

def lognorm(sd):
    return math.exp(rng.gauss(0, sd) - sd * sd / 2)

def binom(n, p):
    # normal approximation for large n, exact loop for small
    if n < 200:
        return sum(1 for _ in range(n) if rng.random() < p)
    mu, sd = n * p, math.sqrt(n * p * (1 - p))
    return max(0, min(n, int(round(rng.gauss(mu, sd)))))

# ---------- 1. Daily ad data (all 181 days x 4 campaigns, zeros outside Jan 1-30) ----------
ad_rows = []
for cid, name, ch, budget in CAMPAIGNS:
    raw = [lognorm(0.10) for _ in PAID_DAYS]
    s = sum(raw)
    spends = [round(budget * x / s, 2) for x in raw]
    spends[-1] = round(budget - sum(spends[:-1]), 2)  # exact budget
    for d in DAYS:
        if d <= PAID_LAST_DAY:
            sp = spends[PAID_DAYS.index(d)]
            impr = int(round(sp / (CPM[ch] * lognorm(0.10)) * 1000))
            clicks = binom(impr, CTR[ch] * lognorm(0.15))
        else:
            sp, impr, clicks = 0.0, 0, 0
        ad_rows.append({"date": d.isoformat(), "campaign_id": cid, "impressions": impr, "clicks": clicks, "spend": f"{sp:.2f}"})

# ---------- Builders ----------
sessions, events, orders, customers, identity, emails = [], [], [], [], [], []
counters = {"s": 0, "e": 0, "o": 0, "a": 0, "c": 0, "m": 0}

def new_id(k, prefix, width):
    counters[k] += 1
    return f"{prefix}{counters[k]:0{width}d}"

def add_event(sid, ts, name, item=None):
    events.append({"event_id": new_id("e", "E", 7), "session_id": sid, "event_ts": ts.isoformat(sep=" "), "event_name": name, "item_id": item or ""})

def make_session(anon, ts, channel, campaign_id, kind):
    """kind: 'buy', 'signup', 'browse'. Returns (session_id, last_ts, cart_abandoned)."""
    sid = new_id("s", "S", 6)
    sessions.append({"session_id": sid, "anon_id": anon, "session_start": ts.isoformat(sep=" "), "channel": channel, "campaign_id": campaign_id or ""})
    t = ts
    add_event(sid, t, "page_view")
    item = rng.choice(PRODUCTS)[0]
    abandoned = False
    if kind == "buy":
        for name in ("view_item", "add_to_cart", "begin_checkout", "purchase"):
            t += timedelta(seconds=rng.randint(15, 180)); add_event(sid, t, name, item if name != "purchase" else None)
    else:
        if rng.random() < FUNNEL["view"]:
            t += timedelta(seconds=rng.randint(15, 180)); add_event(sid, t, "view_item", item)
            if rng.random() < FUNNEL["cart_given_view"]:
                t += timedelta(seconds=rng.randint(15, 180)); add_event(sid, t, "add_to_cart", item)
                abandoned = True
                if rng.random() < FUNNEL["checkout_given_cart"]:
                    t += timedelta(seconds=rng.randint(15, 180)); add_event(sid, t, "begin_checkout")
        if kind == "signup":
            t += timedelta(seconds=rng.randint(15, 120)); add_event(sid, t, "sign_up")
    return sid, t, abandoned

def make_order(cust_id, sid, ts):
    oid = new_id("o", "O", 5)
    n = pick(N_ITEMS_MIX)
    chosen = rng.sample(PRODUCTS, n)
    qty = {p[0]: 0 for p in PRODUCTS}
    for p in chosen:
        qty[p[0]] = 1
    gross = round(sum(p[4] * qty[p[0]] for p in PRODUCTS), 2)
    refunded, rdate, ramt = 0, "", 0.0
    if rng.random() < P_REFUND:
        rd = ts.date() + timedelta(days=rng.randint(*REFUND_DELAY))
        if rd <= END:
            refunded, rdate, ramt = 1, rd.isoformat(), gross
    orders.append({"order_id": oid, "customer_id": cust_id, "session_id": sid, "order_ts": ts.isoformat(sep=" "),
                   "qty_P7880": qty["P7880"], "qty_P248407": qty["P248407"], "qty_P427421": qty["P427421"],
                   "gross_revenue": f"{gross:.2f}", "refunded": refunded, "refund_date": rdate,
                   "refund_amount": f"{ramt:.2f}", "net_revenue": f"{gross - ramt:.2f}"})
    return oid

cust_info = {}  # cust_id -> dict(anon, acq_ts, opt_in, orders[list of ts])

def new_customer(acq_ts, channel, campaign_id, buys):
    anon = new_id("a", "A", 6)
    cid = new_id("c", "CU", 4)
    kind = "buy" if buys else "signup"
    sid, t, _ = make_session(anon, acq_ts, channel, campaign_id, kind)
    opt = rng.random() < P_EMAIL_OPT_IN
    customers.append({"customer_id": cid, "created_ts": t.isoformat(sep=" "), "acquisition_channel": channel,
                      "acquisition_campaign_id": campaign_id or "", "email_opt_in": int(opt)})
    identity.append({"anon_id": anon, "customer_id": cid, "linked_ts": t.isoformat(sep=" ")})
    cust_info[cid] = {"anon": anon, "acq_ts": t, "opt_in": opt, "orders": []}
    if buys:
        make_order(cid, sid, t); cust_info[cid]["orders"].append(t)
    return cid

# ---------- 2. Paid sessions (one per click) ----------
camp_ch = {c[0]: c[2] for c in CAMPAIGNS}
for r in ad_rows:
    if r["clicks"] == 0:
        continue
    d = date.fromisoformat(r["date"]); ch = camp_ch[r["campaign_id"]]
    for _ in range(r["clicks"]):
        ts = rand_ts(d)
        lost = rng.random() < P_UTM_LOST
        s_ch, s_camp = ("unassigned", None) if lost else (ch, r["campaign_id"])
        u = rng.random()
        if u < CVR[ch]:
            new_customer(ts, s_ch, s_camp, buys=True)
        elif u < CVR[ch] + P_PAID_SIGNUP_ONLY:
            new_customer(ts, s_ch, s_camp, buys=False)
        else:
            make_session(new_id("a", "A", 6), ts, s_ch, s_camp, "browse")

# ---------- 3. Non-paid new customers, spread over the period ----------
remaining = N_CUSTOMERS - len(customers)
for _ in range(remaining):
    d = rng.choice(DAYS)
    new_customer(rand_ts(d), pick(NONPAID_CHANNEL_MIX), None, buys=rng.random() < P_FIRST_BUY_NONPAID)

# ---------- 4. Repeat orders (direct / organic return) ----------
for cid, info in cust_info.items():
    if not info["orders"]:
        continue
    last = info["orders"][-1]
    while rng.random() < P_REPEAT:
        gap = max(REPEAT_GAP_MIN, int(rng.gauss(REPEAT_GAP_MEAN, REPEAT_GAP_SD)))
        nd = last.date() + timedelta(days=gap)
        if nd > END:
            break
        ts = rand_ts(nd)
        sid, t, _ = make_session(info["anon"], ts, pick(REPEAT_CHANNEL_MIX), None, "buy")
        make_order(cid, sid, t); info["orders"].append(t); last = t

# ---------- 5. Customer browse sessions (+ cart abandonment for cart emails) ----------
abandon = []  # (cid, ts)
for cid, info in cust_info.items():
    n = sum(1 for _ in range(MEAN_BROWSE_SESSIONS * 2) if rng.random() < 0.5)
    span = (END - info["acq_ts"].date()).days
    for _ in range(n):
        if span < 1:
            break
        d = info["acq_ts"].date() + timedelta(days=rng.randint(1, span))
        sid, t, ab = make_session(info["anon"], rand_ts(d), pick(REPEAT_CHANNEL_MIX), None, "browse")
        if ab:
            abandon.append((cid, t))

# ---------- 6. Emails ----------
def add_email(cid, etype, step, ts):
    if ts.date() > END:
        return
    delivered = int(rng.random() >= P_BOUNCE)
    clicked = int(delivered and rng.random() < P_EMAIL_CLICK)
    click_ts = ts + timedelta(hours=rng.randint(1, 48)) if clicked else None
    if click_ts and click_ts.date() > END:
        clicked, click_ts = 0, None
    emails.append({"email_id": new_id("m", "M", 5), "customer_id": cid, "email_type": etype, "step": step,
                   "send_ts": ts.isoformat(sep=" "), "delivered": delivered, "clicked": clicked,
                   "click_ts": click_ts.isoformat(sep=" ") if click_ts else ""})
    if click_ts:
        info = cust_info[cid]
        buys = rng.random() < P_EMAIL_SESSION_BUY
        sid, t, _ = make_session(info["anon"], click_ts, "email", None, "buy" if buys else "browse")
        if buys:
            make_order(cid, sid, t); info["orders"].append(t)

for cid, info in list(cust_info.items()):
    if not info["opt_in"]:
        continue
    for i, dd in enumerate(WELCOME_STEPS_DAYS, start=1):
        add_email(cid, "welcome", i, info["acq_ts"] + timedelta(days=dd, hours=1))
last_cart = {}
for cid, t in sorted(abandon, key=lambda x: x[1]):
    if not cust_info[cid]["opt_in"]:
        continue
    if cid in last_cart and (t - last_cart[cid]).days < 7:
        continue
    last_cart[cid] = t
    add_email(cid, "cart_recovery", 1, t + timedelta(hours=CART_EMAIL_DELAY_H))
for wd in WINBACK_DATES:
    wts = datetime(wd.year, wd.month, wd.day, 10, 0, 0)
    for cid, info in cust_info.items():
        prior = [o for o in info["orders"] if o < wts]
        if info["opt_in"] and prior and (wts - max(prior)).days >= WINBACK_LAPSE_DAYS:
            add_email(cid, "win_back", 1, wts)

# ---------- 7. Anonymous visitors fill to target sessions ----------
need = TARGET_SESSIONS - len(sessions)
anon_mix = [("organic_search", 0.50), ("direct", 0.25), ("referral", 0.10), ("organic_social", 0.15)]
while need > 0:
    anon = new_id("a", "A", 6)
    k = min(need, pick([(1, 0.7), (2, 0.2), (3, 0.1)]))
    ch = pick(anon_mix)
    for _ in range(k):
        make_session(anon, rand_ts(rng.choice(DAYS)), ch, None, "browse")
    need -= k

# ---------- Write ----------
def write(name, rows, fields):
    rows = sorted(rows, key=lambda r: (r[fields[0]], r[fields[1]]))
    with open(os.path.join(OUT, name), "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=fields); w.writeheader(); w.writerows(rows)
    return len(rows)

counts = {
    "sim_campaigns.csv": write("sim_campaigns.csv", [{"campaign_id": c[0], "campaign_name": c[1], "channel": c[2], "budget": f"{c[3]:.2f}", "start_date": "2026-01-01", "end_date": "2026-01-30"} for c in CAMPAIGNS], ["campaign_id", "campaign_name", "channel", "budget", "start_date", "end_date"]),
    "sim_ad_daily.csv": write("sim_ad_daily.csv", ad_rows, ["date", "campaign_id", "impressions", "clicks", "spend"]),
    "sim_customers.csv": write("sim_customers.csv", customers, ["customer_id", "created_ts", "acquisition_channel", "acquisition_campaign_id", "email_opt_in"]),
    "sim_identity_map.csv": write("sim_identity_map.csv", identity, ["anon_id", "customer_id", "linked_ts"]),
    "sim_sessions.csv": write("sim_sessions.csv", sessions, ["session_id", "anon_id", "session_start", "channel", "campaign_id"]),
    "sim_events.csv": write("sim_events.csv", events, ["event_id", "session_id", "event_ts", "event_name", "item_id"]),
    "sim_orders.csv": write("sim_orders.csv", orders, ["order_id", "customer_id", "session_id", "order_ts", "qty_P7880", "qty_P248407", "qty_P427421", "gross_revenue", "refunded", "refund_date", "refund_amount", "net_revenue"]),
    "sim_email_deliveries.csv": write("sim_email_deliveries.csv", emails, ["email_id", "customer_id", "email_type", "step", "send_ts", "delivered", "clicked", "click_ts"]),
}
for k, v in counts.items():
    print(f"{k}: {v} rows")
