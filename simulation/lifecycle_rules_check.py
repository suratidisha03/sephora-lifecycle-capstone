"""
Stage 7 desk test: applies the rules in emails/lifecycle_flow_spec.md to 10 practice contacts
and compares the result with the expected sends written BEFORE running.
Evidence layer: TEST (rules prototype). No email is sent by this script.
Run: python3 lifecycle_rules_check.py <crm_csv> <out_csv>
"""
import sys, csv
from datetime import datetime, timedelta

H = datetime(2026, 12, 31, 23, 59)  # test horizon
D = lambda s: datetime.strptime(s, "%Y-%m-%d %H:%M")
PRIO = {"cart": 0, "welcome": 1, "win_back": 2}

# Event timelines per contact (permission, events). Matches crm/practice_contacts.csv.
CONTACTS = {
 "RG01": (True, [("2026-10-14 09:00", "signup", None)]),
 "RG02": (True, [("2026-10-14 09:00", "signup", None), ("2026-10-15 12:00", "purchase", None)]),
 "RG03": (True, [("2026-10-14 09:00", "signup", None), ("2026-10-15 08:00", "unsubscribe", None)]),
 "RG04": (True, [("2026-10-13 09:00", "signup", None), ("2026-10-14 10:00", "add_to_cart", "cart/RG04-a")]),
 "RG05": (True, [("2026-10-14 10:00", "add_to_cart", "cart/RG05-a"), ("2026-10-15 08:00", "add_to_cart", "cart/RG05-b")]),
 "RG06": (True, [("2026-10-14 10:00", "add_to_cart", None)]),
 "RG07": (True, [("2026-09-30 10:00", "purchase", None)]),
 "RG08": (True, [("2026-08-10 10:00", "purchase", None)]),
 "RG09": (True, [("2026-08-01 10:00", "purchase", None), ("2026-10-03 11:00", "purchase", None)]),
 "RG10": (False, [("2026-10-14 09:00", "signup", None), ("2026-10-14 10:00", "add_to_cart", "cart/RG10-a")]),
}

# Expected sends, written before running (email_id@date)
EXPECTED = {
 "RG01": ["EM-01@2026-10-14", "EM-02@2026-10-16", "EM-03@2026-10-19"],
 "RG02": ["EM-01@2026-10-14", "EM-06@2026-12-14", "EM-07@2026-12-21"],
 "RG03": ["EM-01@2026-10-14"],
 "RG04": ["EM-01@2026-10-13", "EM-04@2026-10-14", "EM-05@2026-10-15", "EM-02@2026-10-20", "EM-03@2026-10-22"],
 "RG05": ["EM-04@2026-10-14", "EM-05@2026-10-15"],
 "RG06": [],
 "RG07": ["EM-06@2026-11-29", "EM-07@2026-12-06"],
 "RG08": ["EM-06@2026-10-09", "EM-07@2026-10-16"],
 "RG09": ["EM-06@2026-09-30", "EM-06@2026-12-02", "EM-07@2026-12-09"],
 "RG10": [],
}

def run(perm, evs):
    evs = [(D(t), k, v) for t, k, v in evs]
    unsub = min([t for t, k, _ in evs if k == "unsubscribe"], default=None)
    buys = sorted(t for t, k, _ in evs if k == "purchase")
    carts = [(t, v) for t, k, v in evs if k == "add_to_cart"]
    cand, log = [], []
    if not perm:
        return [], ["R1: no permission, all emails blocked"]
    for t, k, _ in evs:  # welcome
        if k == "signup":
            for i, dd in enumerate([0, 2, 5]):
                cand.append(("welcome", f"EM-0{i+1}", t + timedelta(days=dd), t))
    last_entry = None  # cart recovery, 7-day cooldown
    for t, link in sorted(carts):
        if any(t <= b <= t + timedelta(hours=4) for b in buys):
            continue
        if last_entry and t < last_entry + timedelta(days=7):
            log.append(f"R6: cart at {t:%m-%d %H:%M} inside cooldown, no restart")
            continue
        last_entry = t
        cand += [("cart", "EM-04", t + timedelta(hours=4), t), ("cart", "EM-05", t + timedelta(hours=24), t)]
    flow_end = None  # win-back, 60-day cooldown
    for b in buys:
        entry = b + timedelta(days=60)
        nxt = [x for x in buys if x > b]
        if nxt and nxt[0] < entry:
            continue
        if flow_end and entry < flow_end + timedelta(days=60):
            continue
        cand += [("win_back", "EM-06", entry, entry), ("win_back", "EM-07", entry + timedelta(days=7), entry)]
        stop = min([x for x in buys if x > entry], default=None)
        flow_end = stop if stop and stop < entry + timedelta(days=7) else entry + timedelta(days=7)
    sent = []
    for flow, eid, due, entry in sorted(cand, key=lambda c: (c[2].date(), PRIO[c[0]], c[2])):
        t, done = due, False
        while t <= min(due + timedelta(days=7), H):
            if unsub and t >= unsub:
                log.append(f"R1: {eid} blocked, unsubscribed"); done = True; break
            if any(entry <= b <= t for b in buys):
                log.append(f"R2: {eid} cancelled, purchase"); done = True; break
            if flow == "cart":
                link = [v for c, v in carts if c <= t][-1]
                if not link:
                    log.append(f"R5: {eid} held, missing cart link"); done = True; break
            same_day = any(s.date() == t.date() for s, _, _ in sent)
            in7 = sum(1 for s, _, _ in sent if t - timedelta(days=7) < s <= t)
            if not same_day and in7 < 3:
                sent.append((t, eid, link if flow == "cart" else ""))
                if t != due:
                    log.append(f"R3/R4: {eid} moved {due:%m-%d} to {t:%m-%d}")
                done = True; break
            t += timedelta(days=1)
        if not done:
            log.append(f"R4: {eid} skipped, cap")
    sent.sort()
    return sent, log

rows = list(csv.DictReader(open(sys.argv[1])))
out, allpass = [], True
for r in rows:
    cid = r["contact_id"]
    sent, log = run(*CONTACTS[cid])
    got = [f"{e}@{t:%Y-%m-%d}" for t, e, _ in sent]
    ok = got == EXPECTED[cid]
    allpass &= ok
    links = "; ".join(f"{e}->{l}" for _, e, l in sent if l)
    out.append({"contact_id": cid, "scenario": r["test_scenario"], "expected": " | ".join(EXPECTED[cid]) or "no emails",
                "actual": " | ".join(got) or "no emails", "cart_links_used": links, "rules_fired": " ; ".join(log),
                "status": "Pass" if ok else "FAIL"})
    print(cid, "Pass" if ok else "FAIL", got, log, links)
with open(sys.argv[2], "w", newline="") as f:
    w = csv.DictWriter(f, fieldnames=list(out[0].keys())); w.writeheader(); w.writerows(out)
print("ALL PASS" if allpass else "SOME FAILED")
