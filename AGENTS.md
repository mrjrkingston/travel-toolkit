# Travel Hacking Toolkit

Reference guide for the travel-hacking-toolkit. Skills, data files, source priority, and booking procedures for award and cash travel research.

## Tools at Your Disposal

### MCP Servers (always available, call directly)
- **Skiplagged** — Flight search with hidden city ticketing. Zero config.
- **Kiwi.com** — Flight search with virtual interlining (creative cross-airline routings). Zero config.
- **Trivago** — Hotel metasearch across booking sites. Zero config.
- **Ferryhopper** — Ferry routes across 33 countries, 190+ operators. Zero config.
- **Airbnb** — Search listings and get property details. Zero config.
- **LiteAPI** — Hotel search with real-time rates and booking.

### Skills (load from `skills/` directory when needed)
- **duffel** — GDS flight search via Duffel API. Real airline inventory with cabin class, multi-city, time preferences.
- **google-flights** — Browser-automated Google Flights search via agent-browser. Covers ALL airlines including Southwest. Free, no API key. Supports economy/business comparison, market selection, and booking link extraction.
- **ignav** — Fast REST API flight search. 1,000 free requests. Structured JSON with prices, itineraries, booking links. Supports market selection for price arbitrage.
- **southwest** — Southwest.com fare search via Patchright (undetected Playwright). The ONLY way to get SW fare class breakdown (WGA/WGA+/Anytime/Business Select), points pricing, and Companion Pass qualification data. Also includes a logged-in change flight monitor that checks existing reservations for price drops. Requires headed mode or Docker+xvfb.
- **seats-aero** — Award flight availability across 25+ mileage programs. The crown jewel. Shows how many miles a flight costs.
- **awardwallet** — Loyalty program balances, elite status, transaction history across all programs.
- **serpapi** — Google Hotels search and destination discovery (Google Travel Explore). Optional. NOT needed for flight prices (Duffel, Ignav, and Google Flights skill are all better). Still the best tool for hotel metasearch and "where should I go?" style queries.
- **rapidapi** — Optional. Booking.com hotel prices only. NOT needed for flights (superseded by Duffel/Ignav/Google Flights). 100 requests/month free tier.
- **atlas-obscura** — Hidden gems and unusual attractions near any destination.
- **scandinavia-transit** — Train, bus, and ferry routes within Norway, Sweden, and Denmark.
- **wheretocredit** — Mileage earning rates by airline and booking class. Shows redeemable and qualifying miles across 50+ programs. Essential for "where should I credit this flight?" decisions.
- **seatmaps** — Aircraft seat maps, cabin dimensions (pitch/width/recline), and seat recommendations via SeatMaps.com (browser automation) and AeroLOPA (visual complement). Search by flight number or airline+aircraft. Identifies the correct aircraft variant for your specific flight.
- **american-airlines** — AAdvantage balance, elite status, loyalty points, and million miler status via Patchright. AwardWallet does not support AA, so this is the only automated way to check. Uses persistent browser profiles to skip 2FA on repeat runs. Docker image: `ghcr.io/borski/aa-miles-check`.
- **premium-hotels** — Search Amex FHR (1,807), THC (1,299), and Chase Edit (1,553) hotel properties by city. Coordinate-based search for FHR/THC, text search for Chase Edit. Flags hotels in multiple programs for benefit stacking. All data local, no API key needed.
- **transfer-partners** — Find the cheapest way to book an award flight using transferable credit card points. Cross-references seats.aero award prices with transfer ratios from 6 card issuers (Chase, Amex, Bilt, Capital One, Citi, Wells Fargo) to calculate the real cost in each currency.
- **trip-calculator** — "Should I pay cash or use points?" answered with math. Compares cash prices vs award costs factoring in transfer ratios, taxes, point valuations (floor/ceiling from 4 sources), and opportunity cost.
- **compare-flights** — Unified flight comparison across ALL sources. Orchestrates Duffel, Ignav, Google Flights, Skiplagged, Kiwi, seats.aero, Southwest (cash + points), Chase Travel, and Amex Travel in parallel. Applies transfer partner optimization automatically. Outputs one comparison table with CPP ratings and recommendations. Use this instead of running individual skills when the user wants the full picture.
- **compare-hotels** — Unified hotel comparison across portals, direct booking, and Airbnb. Orchestrates Chase Edit, Amex FHR/THC, SerpAPI, Trivago, LiteAPI, and Airbnb MCP. Identifies stacking opportunities (hotels in both FHR and Edit). Calculates benefit-adjusted prices. Use this for any "find me a hotel" request.
- **award-calendar** — Find the cheapest award dates for a route across a date range. Searches seats.aero, groups by date, applies transfer partner optimization, and shows a calendar grid with the best deals highlighted. Use when dates are flexible.
- **trip-planner** — Full trip planning: flights + hotels + points optimization in one shot. Orchestrates compare-flights, compare-hotels, transfer-partners, and trip-calculator into a unified trip cost analysis. Use for "plan a trip to Paris Aug 11-15."
- **chase-travel** — Chase UR travel portal search via Patchright. Flight and hotel search with Points Boost detection (1.5x to 2.0x cpp), Edit hotel benefits ($100 credit, breakfast, upgrade), and UR points pricing. Auto-selects Sapphire Reserve (1.5x) or Sapphire Preferred (1.25x). Auto-extracts all account identifiers from cookies (zero config beyond username/password). Uses session/create + API interception for flights, shadow DOM pagination, and Points Boost toggle. Sessions don't persist (re-login per run, 2FA skipped after device trust). Docker: `ghcr.io/borski/chase-travel`.
- **amex-travel** — Amex Travel portal search via Patchright. Flight and hotel search with IAP (International Airline Program) discount detection on Platinum, FHR/THC hotel benefits, and MR points pricing. Flights extracted from `window.appData` (627KB Redux store). Hotels parsed from DOM (`data-testid` attributes). Email 2FA with optional command hook (`AMEX_2FA_COMMAND`). Docker: `ghcr.io/borski/amex-travel`.

## Flight Source Priority

**Search ALL sources for EVERY flight search.** This is not a pick-one list. Each source returns different results, different prices, and different airlines. Missing a source means missing options. The priority order determines which price to trust when sources disagree, not which sources to skip.

| Priority | Source | Strengths | Blind Spots |
|----------|--------|-----------|-------------|
| 1 | **Duffel** (skill) | Most accurate cash prices. Real GDS per-fare-class data. Bookable. | No Southwest. No award pricing. Offers expire in 15-30 min. |
| 2 | **Ignav** (skill) | Fast REST API. Market selection for price arbitrage. Free. | No Southwest. No award pricing. |
| 3 | **Google Flights** (skill, agent-browser) | Covers ALL airlines including Southwest cash prices. Free. Economy/business comparison. | Prices can be inflated vs GDS. No points pricing. |
| 4 | **Skiplagged** (MCP) | Hidden city fares. Zero config. | No Southwest. Can be noisy on small markets. |
| 5 | **Kiwi.com** (MCP) | Virtual interlining (creative cross-airline routings). Zero config. | Returns garbage on small markets. No Southwest. |
| 6 | **Seats.aero** (skill) | Award flight availability across 25+ programs. The crown jewel for points. | Cached data, not live. No cash prices. No Southwest. |
| 7 | **SerpAPI** (skill, optional) | Google Hotels search. Destination discovery (Google Travel Explore). | NOT for flights (inflated prices). Hotels and "where should I go?" only. |
| 8 | **Southwest** (skill, Patchright) | Fare classes, points pricing, Companion Pass. All 4 fare classes, cash + points. | Pre-built Docker image: `ghcr.io/borski/sw-fares`. Or local Patchright (headed mode). ~20s per search. |

**For a standard flight search:** Run ALL of these: Duffel + Ignav + Google Flights + Skiplagged + Kiwi in parallel. Always add Seats.aero for award comparison. Always run the Southwest skill if SW flies the route. Don't skip sources. Don't assume one source has everything. Present the combined results with the best options highlighted regardless of which source found them.

**For Southwest specifically:** Use the southwest skill (`docker run --rm ghcr.io/borski/sw-fares` or `python3 skills/southwest/scripts/search_fares.py`). Returns all 4 fare classes, cash and points pricing. Google Flights via google-flights skill is a faster fallback for SW cash prices only.

**For monitoring existing SW reservations:** Use `docker run --rm -e SW_USERNAME -e SW_PASSWORD ghcr.io/borski/sw-fares change --conf ABC123 --first Jane --last Doe --json`. Logs in, selects both legs, and shows fare diffs for every available flight. Negative diffs = savings opportunity. Use `--list` to discover all upcoming confirmation numbers. Read-only. Never modifies reservations.

## Output Format

**Always use markdown tables for flight and hotel search results.** Tables make it easy to scan and compare options at a glance.

- One row per flight/hotel/option
- Include columns for price, duration, stops, airline, and any relevant metadata
- For connections, show stop cities in the Stops column (e.g., "1 stop via ICN")
- No code blocks around tables. Render as actual markdown.
- After the table, highlight the cheapest, fastest, and best value options
- Call out tradeoffs (e.g., "$40 cheaper but adds a 4-hour layover in Rome")
- Offer booking links or next steps

## Market Selection Strategy

Different country markets return different prices for the same route. Searching from Thailand (`&gl=TH`) vs the US (`&gl=US`) can save hundreds of dollars.

**Always try multiple markets for international flights:**

1. **Departure country market first** (e.g., `&gl=US` for flights from the US)
2. **Destination country market** (e.g., `&gl=JP` for flights to Japan)
3. **Ask the user before trying more** (e.g., third countries, VPN markets)

This applies to google-flights (via `&gl=XX` URL parameter) and ignav (via `market` field). Duffel and SerpAPI don't support market selection.

## Points Valuations

**Reference data:** `data/points-valuations.json`

Four sources: The Points Guy (optimistic), Upgraded Points (moderate), One Mile at a Time (conservative), View From The Wing (most conservative and theoretically rigorous).

Each entry has:
- `floor` — conservative minimum (use this for decision-making)
- `ceiling` — optimistic maximum
- `sources` — individual values from each publication

**Rules:**
- Default to the floor for "should I burn points on this?" decisions. If a redemption beats the ceiling, it's genuinely exceptional. Say so.
- Below the floor is objectively poor value. Flag it and suggest alternatives.
- TPG systematically overvalues (affiliate incentive). VFTW and OMAAT are more useful for real decisions.
- **Staleness check:** Look at `_meta.last_updated`. If it's more than 45 days old, re-fetch from the source URLs in `_meta.sources` and update the file.
- When floor and ceiling are within 0.1cpp, the value is well-established. When they're 0.3cpp+ apart, mention the range and let the user decide.

## API Keys

Provided via environment variables. See `.env.example` for every key and where to get it. Not all are required. Minimum viable setup: Seats.aero + SerpAPI.

**Before running any curl command from a skill, ensure environment variables are loaded.** If variables like `$AWARDWALLET_API_KEY` or `$SEATS_AERO_API_KEY` are empty, source the `.env` file first:

```bash
source .env
```

Run this once at the start of a session. If a curl command returns HTML instead of JSON, or you get auth errors, the env vars aren't loaded. Source `.env` and retry.

## Partner Awards

**Reference data:** `data/partner-awards.json`

When recommending award bookings, check this file to verify:
1. The booking program can actually ticket the airline you're recommending
2. Whether the partnership is alliance-based or bilateral
3. Cross-alliance highlights (VA→ANA, Etihad→AA, Alaska→Starlux, etc.)
4. Which credit card currencies can reach the booking program

**Cross-alliance bookings are where the real value hides.** The best redemptions often involve booking an airline through a program in a DIFFERENT alliance (or no alliance at all). Always check the `cross_alliance_highlights` section.

## Hotel Chain Recognition

**Reference data:** `data/hotel-chains.json`

Use the `quick_lookup` section to instantly identify which loyalty program a hotel belongs to when it appears in search results. When you see "Westin" you need to know that's Marriott Bonvoy. When you see "The Standard" you need to know that's Hyatt.

**Booking windows reference:** `data/sweet-spots.json` has a `booking_windows` section. When a user asks about flights far in advance, check when award space opens for that airline.

## Alliance Awareness

**Reference data:** `data/alliances.json`

Star Alliance, oneworld, and SkyTeam determine which loyalty programs can book which airlines. This is fundamental to award travel. When recommending an award booking, always verify the airline and the booking program are in the same alliance (or have a bilateral partnership).

**Key relationships to know:**
- **United MileagePlus** books Star Alliance (ANA, Lufthansa, Singapore, Turkish, etc.)
- **Aeroplan** books Star Alliance plus extended partners (including Etihad, Emirates on some routes)
- **Virgin Atlantic Flying Club** books ANA, Delta, Air France, KLM (cross-alliance)
- **AAdvantage** books oneworld (Cathay, JAL, Qantas, Qatar, BA, etc.)
- **Flying Blue** books SkyTeam (Air France, KLM, Delta, Korean Air, etc.)
- **Korean Air SKYPASS** books SkyTeam
- **Avianca LifeMiles** books Star Alliance (often cheaper than United/Aeroplan)

**Recent alliance changes (verify against data file for current state):**
- SAS moved from Star Alliance to SkyTeam (September 2024)
- ITA Airways left SkyTeam (early 2025), joining Star Alliance (first half 2026)
- Fiji Airways upgraded to full oneworld member (2025)
- Hawaiian Airlines joining oneworld (April 2026)

## Sweet Spots

**Reference data:** `data/sweet-spots.json`

When making recommendations, cross-reference against known sweet spots. If a route matches a sweet spot, flag it prominently. Sweet spots are ranked by tier:

- **Legendary:** Outsized value that travel hackers build entire trips around (ANA First via Virgin Atlantic, Hyatt All-Inclusive)
- **Excellent:** Consistently great value, reliable availability (Iberia J to Madrid, Qatar Qsuites, Virgin Atlantic economy to London)
- **Good:** Solid value but may have caveats like devaluations, limited availability, or surcharges

**Always check the devaluation_date field.** If a sweet spot was recently devalued, mention the old vs new rates so users understand the change.

## Cabin Codes

When reading Seats.aero results or discussing award inventory, these cabin codes appear:

| Code | Cabin | Notes |
|------|-------|-------|
| F | First Class | Includes true first class suites |
| J | Business Class | Lie-flat seats on long-haul |
| W | Premium Economy | Also sometimes coded as "P" |
| Y | Economy | Standard seating |

**Fare class codes for saver awards (critical for partner bookings):**

| Code | Meaning | Programs That Use It |
|------|---------|---------------------|
| X | Economy Saver | United MileagePlus, bookable through partners |
| I | Business Saver | United MileagePlus, bookable through Turkish M&S and others |
| O | First Saver | United MileagePlus |

If you see these fare codes available on united.com, the flight is bookable through partner programs at their (often lower) rates.

## Fallback and Resilience

Tools go down. APIs break. Have a backup plan for every search:

| Primary Tool | When It Fails | Fallback |
|-------------|---------------|----------|
| Duffel | API error or timeout | Ignav, Google Flights skill, Skiplagged |
| Ignav | API error | Duffel, Google Flights skill, Skiplagged |
| Google Flights | agent-browser error | Duffel, Ignav, Skiplagged |
| Skiplagged | 502/timeout (Cloudflare issues) | Kiwi.com MCP, Duffel, Ignav |
| Kiwi.com | Server error | Skiplagged MCP, Duffel |
| Seats.aero | API error or stale data | Check airline website directly, use Duffel for GDS inventory |
| Southwest | SW rate limiting or bot detection | Wait a few minutes and retry. Use Docker (`ghcr.io/borski/sw-fares`) if running locally fails. Google Flights skill for SW cash prices as a fast fallback. |
| SerpAPI | Rate limit (100/mo free) | Trivago for hotels, web search for destination discovery |
| Trivago | Server error | LiteAPI for hotels, SerpAPI Google Hotels |
| LiteAPI | Auth error (401) | Trivago MCP, SerpAPI Google Hotels |
| Airbnb | Scraping blocked | Suggest user check airbnb.com directly |
| AwardWallet | API error | Read `data/points-balances.yaml` — user maintains balances there manually |
| Ferryhopper | Server error | SerpAPI or web search for ferry routes |
| Atlas Obscura | Script error | Web search for "unusual things to do in [destination]" |
| Chase Travel | Login failure or CSRF issues | Use Duffel/Ignav for cash prices. Note that Points Boost and Edit detection are Chase-only. |
| Amex Travel | Login failure or form changes | Use Duffel/Ignav for cash prices. Note that IAP fares and FHR/THC detection are Amex-only. |

**General rules:**
- If an MCP server returns an error, try the curl-based skill equivalent (or vice versa)
- If a paid API hits its rate limit, switch to a free alternative
- Never give up after one tool fails. Always try at least one fallback.
- Tell the user which source you used. "Skiplagged was down, so I checked Kiwi.com instead."

## Booking Guidance

Finding the deal is half the battle. Telling the user how to actually book it is the other half. **Every recommendation should include a booking path.**

**Reference data:** `data/alliances.json` has booking details for major programs in `key_booking_relationships`.

**General booking flow:**
1. Find availability (Seats.aero, airline website, or MCP tool)
2. Verify the program you want to book through shows the same availability
3. If transferring points: get a HOLD on the award ticket FIRST, then transfer
4. Transfer points from credit card to loyalty program
5. Call or go online to complete the booking

**Critical rule: Never transfer points without a hold or confirmed availability.** Transfers are instant with most programs but IRREVERSIBLE. If availability disappears, points are stuck in the loyalty program.

**Phone numbers for major programs:**

| Program | Phone | Online Booking? |
|---------|-------|-----------------|
| Virgin Atlantic (ANA awards) | 1-800-365-9500 | No (ANA must be by phone) |
| United MileagePlus | 1-800-864-8331 | Yes (united.com) |
| Aeroplan | 1-888-247-2262 | Yes (aircanada.com) |
| Turkish Miles&Smiles | 1-800-874-8875 | Yes (turkishairlines.com) |
| Korean Air SKYPASS | 1-800-438-5000 | No (partner awards by phone) |
| Flying Blue | 1-800-237-2747 | Yes (stopovers by phone) |
| AAdvantage | 1-800-882-8880 | Yes (aa.com) |
| Japan Airlines | 1-800-525-3663 | No (find space on ba.com or qantas.com, call JAL to book) |
| Iberia Avios | N/A | Yes (iberia.com) |
| Qatar Privilege Club | N/A | Yes (qatarairways.com) |
| Hyatt | N/A | Yes (hyatt.com or app) |

## Premium Hotel Programs

Three data files cover hotel programs with elite-like benefits for cardholders:

| File | Program | Properties | Benefits |
|------|---------|-----------|----------|
| `data/fhr-properties.json` | Amex Fine Hotels & Resorts | 1,807 | $600/yr Plat credit (2x $300 semi-annual), $100 property credit, daily breakfast for 2, 12pm checkin, guaranteed 4pm checkout, room upgrade, wifi |
| `data/thc-properties.json` | Amex The Hotel Collection | 1,299 | $600/yr Plat credit (2x $300 semi-annual, shared with FHR), $100 property credit, 12pm checkin, room upgrade, late checkout (2-night min) |
| `data/chase-edit-properties.json` | Chase Edit (Sapphire Reserve) | 1,553 | $500/yr statement credit (2x $250), $100 property credit, daily breakfast, wifi, room upgrade, early/late checkout |

**When recommending hotels, cross-reference these lists.** If a property is in FHR, THC, or Chase Edit, mention it. The credit alone ($100-150) can meaningfully offset the nightly rate.

**Chase Sapphire Reserve hotel credits (2026):**

**The Edit credit: $500/yr** (two separate $250 credits, usable anytime during the calendar year). Two-night minimum, prepaid through Chase Travel. Each stay also gets the $100 property credit + daily breakfast + room upgrade. Points Boost gives 2cpp when redeeming UR at Edit hotels. **Always compare Chase Travel rates against direct booking.**

**Select Hotels credit: $250 one-time (2026 only).** Prepaid 2+ night stay at: IHG, Minor Hotels, Montage, Omni, Pan Pacific, Pendry, or Virgin Hotels. Booked through Chase Travel. Expires Dec 31, 2026. Earns hotel loyalty points AND elite night credits on the full purchase amount.

**Stacking strategy:** Properties that are both Edit hotels AND one of the 7 Select Hotels brands can trigger BOTH credits on a single stay ($250 Edit + $250 Select = $500 back). Use [awardhelper.com/csr-hotels](https://www.awardhelper.com/csr-hotels) to find stackable properties.

**Budget option:** Use the $250 Select Hotels credit at affordable IHG properties (Holiday Inn, Holiday Inn Express). A 2-night prepaid stay around $250 total gets nearly fully covered by the credit alone.

**Amex Platinum hotel credit (FHR or THC):** $600 annual total, split $300 per half-year (Jan-Jun and Jul-Dec). Use it or lose it, does not roll over. Prepaid bookings through Amex Travel with Platinum or Business Platinum. FHR and THC share the same $600 pool.
- **FHR = 1-night minimum.** THC = 2-night minimum.
- **Credit triggers on booking/prepayment, not stay date.** Book in June for a September trip and the H1 credit still fires.
- **5x MR points still earned** on Amex Travel bookings that trigger the credit.
- **No enrollment needed.** Just book through Amex Travel and pay with your Platinum.
- **Can split across multiple bookings** if a stay costs less than $300 per half.
- **Cancellation = clawback** unless you rebook before the credit expires.
- **Elite status recognition is hit or miss** through Amex Travel. Plug in loyalty numbers anyway.
- **MaxFHR.com** is a great tool for finding the cheapest FHR/THC properties by date and destination.
- **Always compare Amex Travel rates against booking direct.** Portal rates can be higher.

**FHR data includes:** coordinates, Amex reservation links, Google Travel price calendar links, and credit details.
**Chase Edit data includes:** 190 properties tagged `budget_friendly` from the "Potentially Cheaper Ones" category.

**Data source:** 美卡指南 (US Card Guide) Google My Maps, maintained by Scott. To refresh, re-pull the KML files:
- FHR/THC: `https://www.google.com/maps/d/kml?mid=1HygPCP9ghtDptTNnpUpd_C507Mq_Fhec&forcekml=1`
- Chase Edit: `https://www.google.com/maps/d/kml?mid=1Ickidw1Z6ACres9EnbM2CmPObYsuijM&forcekml=1`

## Important Notes

- Seats.aero data is cached, not live. Check `ComputedLastSeen` for freshness. Stale data (24h+) means verify on the airline site before booking.
- Always search for 2+ seats when booking for multiple people. Award availability for 1 seat doesn't guarantee 2.
- RapidAPI free tier is 100 requests/month. Use sparingly. Prefer SerpAPI.
- Atlas Obscura and Airbnb scrape websites. Be respectful with request volume.
- Skiplagged, Kiwi.com, Trivago, and Ferryhopper need no setup. They just work.
- Ferryhopper focuses on European/Mediterranean routes. Great for Greek islands, Croatia, Scandinavia.
