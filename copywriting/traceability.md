# Copy Traceability (Stage 4)

Every line of final copy points to a source. Sources: **F** = verified Sephora fact (product_facts.md, 2026-10-12); **R** = review evidence (insights/coded_sample.csv or sql/08); **S3** = Stage 3 observation; **G** = general guidance, labeled as a suggestion, not a product claim.

| Asset | Line | Source |
|---|---|---|
| LP-01 | Two steps. Fewer guesses. | S3 audience hypothesis (first-time shoppers); 3-star reviewers undecided on scent (53%) and price (43%) |
| LP-01 | Compare one cleanser and two moisturizers, with scent, texture and price in one place. | F (3 products); S3 obs 2 and 3 |
| LP-02 | Know the scent first. Cucumber scent, light lather, removes mascara (per the brand). Try the mini first. | F scent, mascara, mini; R light lather (P7880-L-20, L-22, L-26); S3 obs 2 |
| LP-02 | Prone to pilling? Go thin. Rich cream, thin layer, let serums dry. Fragrance free. | S3 obs 1 (pilling 2% to 28%); R T13 layering (L-04, L-12); G layering tips; F fragrance free |
| LP-02 | See the price per size. $72 for 50 mL, mini, refill pod. | F price, sizes, refill; S3 obs 3 |
| LP-03 | Not ready to buy? Get a short guide... | S3 undecided 3-star reviewers; guide = SEO article (assumption, checkable in GA4) |
| LP-04 | Start with the cleanser, then one moisturizer that lists your skin type. | F listed skin types (Protini excludes dry) |
| LP-04 | Some reviewers report pilling, especially over serums. Try a thinner layer... | R L-04, L-12, T13; G suggestion only |
| LP-04 | Each product has a mini size. | F mini listed for all 3 |
| PDP-01 | If it pills: some reviewers see pilling, especially over serums or retinol. Try... | R L-04, L-12, L-24; G suggestion; does not promise (contradicted by L-04, L-17, L-22) |
| PDP-02 | What to expect: cucumber scent, light lather, removes mascara per the brand; start with the 1.6 oz mini | F scent, mascara, 1.6 oz mini; R light lather (P7880-L-20, L-22, L-26); S3 obs 2 |
| SEO-01 | ...what to try if your moisturizer pills | S3 obs 1; SEO theme Q2 (hypothesis) |
| EM-02 | Why moisturizers pill, and what to try | S3 obs 1 |
| EM-03 | Minis for each step | F |
| EM-06 | Two months / 60 days | Win-back timing from guide p.22-24, not data |
| AD-01 B | A thin layer and a dry serum may help | G suggestion; simulated ad only |
| UI-04 | Demo order complete. No payment collected. | Guide p.12 starter copy |
| EM-01 | I analyzed thousands of reviews of these products (150 hand-coded, the rest by SQL counts) | R public_reviews subset (Stage 2 load log); S3 |
| EM-01 | A lot of the 1 and 2 star reviews came from people surprised by something they could have checked first | S3 obs 1 and 2; "a lot of", not "most" (breakouts are common too) |
| EM-01 | The fresh Soy cleanser smells of cucumber, and some people really don't like it | F scent; R scent complaints (S3 obs 2) |
| EM-01 | One of the creams can pill for some people when it goes over a serum | R T13 layering (L-04, L-12); S3 obs 1 |
| EM-01, EM-03 | All three products have a mini (1.6 oz, 2 oz, 15 mL) | F mini sizes |
| EM-02 | Pilling is when a cream rolls into small flakes instead of sinking in | G definition, not a product claim |
| EM-02 | Some reviewers of First Aid Beauty see it, especially over serums | R L-04, L-12, T13 |
| EM-02 | Thin layer; let earlier steps dry; press, don't rub | G suggestion ("may help"); matches PDP-01 |
| EM-02 | Some reviewers still saw pilling after trying this | R L-04, L-17, L-22 |
| EM-04 | $42 · mini available; rich and fragrance free | F price, mini, fragrance free (brand claim) |
| EM-04 | Some reviewers see pilling over serums, so use a thin layer | R T13; G suggestion |
| EM-04 | First Aid Beauty shown in the bag | Example cart item only; a real build inserts the cart's own item |
| EM-05 | Cucumber scent, not fragrance free; rich cream; Protini lists normal, combination, oily, not dry | F scent, skin types |
| EM-05 | This is the last reminder about this bag | Cart flow = 2 emails (guide p.22-24) |
| EM-06 | Pilling fix; check your moisturizer lists your skin type | G suggestion; F Protini skin types |
| EM-07 | Each product has a mini; Protini comes as a refill pod | F sizes and refill |
| EM-07 | You won't hear from me again for a while | Win-back 60-day cooldown (guide p.22-24) |
| All emails | Not affiliated; test email; prices checked Oct 12, 2026; unsubscribe | Guide honesty rules; F check date |

## Errors caught by this check (2026-10-12)
- Pilling copy promised a fix ("so it doesn't pill", "stop your moisturizer from pilling", "a 30-second fix", "make the difference"). Review evidence contradicts it: L-04 tried less product and waited 20 minutes and it still pilled; L-17 and L-22 pilled on clean skin. Six lines rewritten to suggest, not promise.

## Known tension (kept, explained)
- Protini is a $72 firming cream inside a beginner routine. Kept as the premium option because it had the most price discussion, so it tests value messaging. Copy states its listed skin types and price plainly.
