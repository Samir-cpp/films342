# Economy and reproducibility

All values are lakh BDT. All pure formulas live in `scripts/sim/economy.gd` and are exercised by GUT. Numerical parameters for box office, shares, rights, cost tiers, borrowing and balancing live in `data/economy.json`. State progression and stage-specific modifiers live in GameState.

## Script / production quality

Script = clamp(0.45 × Script stat + 0.25 × Vision + min(4 × drafting weeks, 20) + 0.15 × writer support + 5 × genre trend, 5, 100).

Final base quality = clamp(0.38 × script + 0.32 × direction + 0.10 × cast power + 0.20 × average crew skill, 1, 100). Post polish and events modify this; high burnout reduces it. Industry / critics / audience reputations update after release. Direction and Script gain experience. Training and failed pitches improve skills; annual aging reduces stamina and grows network.

Weekly shoot cost = days × tier daily cost × (1 + risk) × trait factor. Tier schedules are 8 / 22 / 40 days, in blocks of at most six per week. Lean coverage costs 0.82× but loses script quality; reshooting costs 1.25× and gains it. A frugal trait reduces cost. Prep, location permits, casting, consultants, post and marketing add actual expenses. Budget is a planning ceiling; `spent` is the true break-even cost.

Pitch probability = clamp(base + 0.003 × Business + 0.002 × (industry + relationship) − 0.4 × max(0, budget − capacity) / capacity, 0.08, 0.94), then reduced by aggressive negotiation terms. Acceptance never becomes certain. Weekly loan interest = positive debt × 0.002; total bridge borrowing is capped at 240 lakh. Paid work remains available after failure.

## Theatrical opening and retention

Opening occupancy = clamp((0.10 + 0.003 × cast + 0.003 × hype + 0.002 × (quality − 50)) × holiday multiplier / (1 + competition), 0.015, 0.95).

Retention = clamp(0.69 + ((quality − 50) / 50) × 0.33, 0.25, 1.15).

Weekly gross = screens × 230 seats × 3 shows × 7 days × 200 BDT / 100,000 × clamp(opening × retention^(week − 1) × (1 − piracy), 0, 0.95).

Restricted certificates reduce available screens to 75%. Weekly piracy is 0.08 by default. Quality 100 can grow occupancy; quality below 50 decays quickly. These formulas are estimates for a game, not a forecast. Eid increases opening demand but cannot eliminate costs or guarantee profit.

## Producer versus director accounting

35% of modeled ticket sales use multiplex shares: 31%, or 38% in the first week for cast power ≥80. Remaining single-screen sales use a 20% producer share. An outstanding theatrical advance is recouped against the single-screen share before additional producer payments. A pure formula tests that recoupment independently; this edition does not yet expose separate hall-by-hall advance negotiation.

Public gross is not profit. Producer profit = aggregate receipts (theatrical plus paid licenses) − actual spent.

For an externally financed film the director receives a negotiated fee up front, then backend × max(0, receipts − spent). The fee is a separate director contract payment, not included again in the final payout. For self-financing, spending has already reduced personal cash; actual receipts are returned on completion. Do not subtract the film budget from cash a second time.

License price = max(0, buyer base + 0.5 × quality + 0.25 × hype), capped by buyer range. OTT / TV / music categories are exclusive; each overseas territory is independent. Deals carry windows relative to actual release. Pending payments follow a film into the archive. Late backend pays the difference between profit shares before and after a payment, so a loss-making production does not pay an unearned backend. Paid flags prevent duplicate collection. The final profit and director income are refreshed after late payment.

Catalog income arrives every four weeks and is intentionally modest. Restored-cut releases cost 5 lakh, can recur only after 12 weeks, and return quality-sensitive income. Awards use quality + critics contribution + seeded jury variation against an editable threshold. A campaign is not a guaranteed win; attempts and outcomes are retained separately.

## Determinism / test isolation

All simulation random calls share a single GameState RNG. Save both seed-derived world and the RNG state; preserve the RNG's 64-bit signed state as a string. JSON floats are written with full precision. Loading pauses Clock. UI rendering, procedural sound and art do not change the simulation sequence.

`tools/test.sh` uses its own XDG data directory so a regression run cannot overwrite player slots. Tests explicitly exercise eight theatrical weeks, deferred licenses, an award win, catalog monetization, serialization and a second completed film from the first film's sequel source. Financial outcomes still need longer human playtesting and balancing.
