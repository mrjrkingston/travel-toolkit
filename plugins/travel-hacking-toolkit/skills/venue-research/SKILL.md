---
name: venue-research
description: Use when researching a specific venue (restaurant, bar, club, rooftop, activity) discovered via Instagram, word-of-mouth, or a URL — to find hours, address, neighborhood, vibe, booking platforms, contact info, and reservation method. Also use when building or updating a trip planning document with venue details.
---

# Venue Research

## Overview

Structured workflow for turning a venue name or Instagram handle into a complete, actionable entry in a trip planning doc. Combines WebSearch + WebFetch for real-world context and booking info, RapidAPI tools for structured ratings/reviews data, and a standard output format that persists across sessions.

## When to Use

- User drops an Instagram link or handle for a restaurant, bar, club, or activity
- User asks "how do I book this place?"
- Building or updating a trip planning doc with venue details
- Verifying hours, neighborhood, or booking method before making a reservation

## Workflow

### Step 1 — WebSearch (always first)

Run two parallel searches:

```
"{venue name} {city} reservations booking"
"{venue name} {city} hours address contact"
```

Look for: Resy, OpenTable, Tock, SevenRooms links; phone/WhatsApp numbers; email; website. Note review platforms that surface (Yelp, TripAdvisor, Time Out).

### Step 2 — WebFetch key pages

Hit 2–3 of the most promising URLs from Step 1 in parallel:

| Target | What to extract |
|--------|----------------|
| Venue's own website | Hours, address, booking method, vibe description |
| Resy / OpenTable / Tock page | Confirmed booking platform, party size options, available slots |
| Time Out / local guide | Vibe, neighborhood context, what makes it notable |
| CDMX Reservas / local booking aggregator | WhatsApp number, table minimums, cover info |

Skip Instagram.com — it requires auth and WebFetch will fail.

### Step 3 — RapidAPI (structured data layer)

Run in parallel with or after Step 2. Use available keys:

**Yelp** (ratings + price level):
```bash
curl -s "https://yelp-business-api.p.rapidapi.com/search?location={CITY}&search_term={VENUE_NAME}&page=1" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: yelp-business-api.p.rapidapi.com" \
  | jq '[.business_search_result[0:3][] | {name, avg_rating, review_count, price}]'
```

**TripAdvisor** (ranking + subratings, if venue is on TA):
```bash
curl -s "https://tripad-mate.p.rapidapi.com/restaurants/search?query={CITY}" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: tripad-mate.p.rapidapi.com" \
  | jq '[.data.restaurants[0:5][] | {name: .cardTitle.string, rating: .bubbleRating.rating}]'
```

**OpenTable** (check if bookable, metro ID required):
```bash
# Common metro IDs: Mexico City = use lat/long fallback
curl -s --max-time 30 "https://opentable-data-api.p.rapidapi.com/search?latitude={LAT}&longitude={LON}&dateTime=2026-{MM}-{DD}T19:00:00&covers=6" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: opentable-data-api.p.rapidapi.com" \
  | jq '[.data.restaurants[] | select(.name | test("{VENUE}"; "i")) | {name, isInstantBookable, neighborhood}]'
```

**Instagram Looter** (pull bio/booking info from handle):
```bash
curl -s "https://instagram-looter2.p.rapidapi.com/profile?username={HANDLE}" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: instagram-looter2.p.rapidapi.com" \
  | jq '{bio: .biography, followers: .edge_followed_by.count, external_url: .external_url}'
```

Skip RapidAPI if WebSearch + WebFetch already returned complete info. Don't burn quota unnecessarily.

### Step 4 — Compile the venue entry

Write a full notes block to the trip planning doc using this format:

```markdown
### {Venue Name} — Full Research Notes

**IG:** [@handle](https://www.instagram.com/handle)
**Recommended by / source:** [friend / Instagram reel / etc.]

**The concept:** [1–2 sentences on what makes it notable or unique]

**Inside / experience:** [bullet list of rooms, features, signature items, notable traditions]

| | |
|---|---|
| **Address** | Full address |
| **Neighborhood** | Name (~X min from {other venue} in {other neighborhood}) |
| **Hours** | Days + times ✅/❌ [target date] works |
| **Price range** | $ / $$ / $$$ / $$$$ |
| **How to book** | |
| 🥇 Primary method | [Resy/OpenTable/WhatsApp link or number] |
| 🥈 Backup | [Secondary option] |
| 📞 Phone | +X XX XXXX XXXX |
| 📧 Email | email@venue.com |

⚠️ **[Any warnings from reviews — seating delays, cover charge, dress code, etc.]**
```

### Step 5 — Update itinerary and venue tracker

- Update the day-by-day table with venue status (❌ Needs reservation / ✅ Booked)
- Update the On Deck / Floating table with the condensed row
- Add neighborhood proximity note if relevant to night logistics

## Neighborhood Proximity Rule

Always note travel time between venues on the same night. If two venues are in different neighborhoods, flag it and suggest which night makes more logistical sense. ~15–20 min cab is fine; >30 min starts to fragment the night.

## Booking Platform Priority (CDMX)

1. **Resy** — most common for trendy CDMX spots
2. **WhatsApp** — extremely common; send name, date, time, party size
3. **OpenTable** — less common but present
4. **Instagram DM** — accepted at many spots
5. **Phone** — always a fallback

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Trying to fetch Instagram.com directly | Use Instagram Looter RapidAPI instead, or just skip — IG bio info usually surfaces in WebSearch results |
| Stopping after WebSearch without checking Resy/OpenTable pages | WebFetch the booking platform page to confirm it's actually active and has slots |
| Missing neighborhood context | Always include which neighborhood and proximity to other planned venues |
| No warning about weekend seating | Reviews on popular spots almost always flag this — include it |
| Leaving price range blank | Yelp `price` field or TripAdvisor `price_level` fills this in 1 API call |
