---
name: rapidapi
category: flights
summary: Cash flight prices, hotel/restaurant discovery, Airbnb stays + experiences, routing/geocoding, and destination guides via RapidAPI scrapers.
description: Search flights (Google Flights, Skyscanner, Booking.com), hotels (Booking.com, TripAdvisor, tripad-mate), short-term rentals (Airbnb stays + experiences via airbnb-data-api2 or homes-experiences-services-data), restaurants (Yelp, OpenTable), routing/geocoding (map-api7 OpenStreetMap), destinations (travel guide, atlas), and social/local (Instagram) via RapidAPI scrapers. Use for cash flight prices, hotel pricing, restaurant discovery, route planning, and destination research. Triggers on "RapidAPI", "Skyscanner", "Booking.com flights", "Yelp", "OpenTable", "TripAdvisor", "Instagram", "Airbnb", "travel guide", "routing", "geocoding", or when SerpAPI flight results need a second opinion.
license: MIT
---

# RapidAPI Skill

## Subscribed APIs (last tested 2026-06-04)

| Host | Category | Status | Notes |
|------|----------|--------|-------|
| `flights-sky.p.rapidapi.com` | Flights | ✅ | Google Flights, Skyscanner, Booking.com. 50 req/mo. Slow — use 30s timeout. |
| `sky-scrapper.p.rapidapi.com` | Flights | ✅ | Use airport-level entityIds (not city-level) for flight search. Status may be "incomplete" on first call — results still returned. |
| `google-flights2.p.rapidapi.com` | Flights | ✅ | Cleanest params — IATA codes directly, no entity ID lookup needed. |
| `booking-com15.p.rapidapi.com` | Hotels | ✅ | Requires destination lookup first to get `dest_id`. |
| `booking119.p.rapidapi.com` | Hotels | ✅ | Same API paths as `booking-com15`. Use as backup/alternate host. |
| `travel-advisor.p.rapidapi.com` | Hotels/Restaurants | ✅ | TripAdvisor scraper. Requires location lookup for `location_id`. |
| `tripad-mate.p.rapidapi.com` | Hotels/Restaurants | ✅ | TripAdvisor scraper. Query by city name directly — no location ID needed. |
| `opentable-data-api.p.rapidapi.com` | Restaurants | ✅ | Works via metroId or lat/long. 200 req/mo. Slow — use 30s timeout. |
| `yelp-business-api.p.rapidapi.com` | Restaurants | ✅ | Response key is `.business_search_result[]` (not `.results[]`). |
| `yelp-business-reviews.p.rapidapi.com` | Restaurants | ✅ | Returns `bizId` for review detail lookups. |
| `homes-experiences-services-data.p.rapidapi.com` | Short-term Rentals | ✅ | Airbnb listings. Requires Google Place ID. `/homes/search?placeId=PLACE_ID`. |
| `airbnb-data-api2.p.rapidapi.com` | Short-term Rentals | ✅ | Airbnb stays + experiences. Use `query=CITY` (not `placeId`, not `location`). |
| `travel-guide-api-city-guide-top-places.p.rapidapi.com` | Discovery | ✅ | POST endpoint. AI city guide with top places + coordinates. |
| `instagram-looter2.p.rapidapi.com` | Discovery | ✅ | tag-feeds path: `.data.hashtag.edge_hashtag_to_media.edges[]`. |
| `map-api7.p.rapidapi.com` | Maps/Routing | ✅ | OpenStreetMap-based routing + geocoding. NOT a places search API. Use for directions and address lookup. |
| `google-map-scraper11.p.rapidapi.com` | Maps | ❌ | Monthly quota exceeded on BASIC plan as of 2026-06-04. Cannot use until reset or upgrade. |
| `viator-api.p.rapidapi.com` | Tours/Activities | ❌ | MISLABELED — actually a Hostelworld scraper. Direct REST endpoints don't exist. MCP hub tools unreliable. Do not use for Viator tours. |
| `Foursquareserg-osipchukV1.p.rapidapi.com` | Discovery | ⚠️ | Subscribed but needs Foursquare `clientId`+`clientSecret` — not in `.env`. |

To add a new subscription: update this table, add a section below with working curl examples, and run a live test.

## Authentication

`RAPIDAPI_KEY` is set in `.env`. Every request uses:
```
x-rapidapi-key: $RAPIDAPI_KEY
x-rapidapi-host: <host>
```

---

## Flight APIs

### 1. Flights Scraper Sky (`flights-sky.p.rapidapi.com`)
Scrapes Google Flights, Skyscanner, and Booking.com. **50 req/mo free. Slow — use 30s timeout.**

#### Google Flights — One-Way
```bash
curl -s --max-time 30 "https://flights-sky.p.rapidapi.com/google/flights/search-one-way?departureId=JFK&arrivalId=LAX&departureDate=2026-07-15&adults=1&currency=USD" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: flights-sky.p.rapidapi.com" \
  | jq '{topFlights: .data.topFlights, otherFlights: .data.otherFlights}'
```

#### Google Flights — Round Trip
```bash
curl -s --max-time 30 "https://flights-sky.p.rapidapi.com/google/flights/search-roundtrip?departureId=JFK&arrivalId=LAX&departureDate=2026-07-15&returnDate=2026-07-25&adults=1&currency=USD" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: flights-sky.p.rapidapi.com" \
  | jq '{topFlights: .data.topFlights, otherFlights: .data.otherFlights}'
```

**Params:** `departureId`, `arrivalId` (IATA codes), `departureDate` (`YYYY-MM-DD`), `returnDate`, `adults`, `cabinClass` (integer: `1`=economy `2`=premium `3`=business `4`=first), `currency`

**Response keys:** `.data.topFlights[]` and `.data.otherFlights[]` — each has `price`, `airlineNames`, `segments[]`, `duration`, `departureTime`, `arrivalTime`

#### Price Calendar
```bash
curl -s --max-time 30 "https://flights-sky.p.rapidapi.com/google/price-calendar/for-one-way?departureId=JFK&arrivalId=CDG&currency=USD" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: flights-sky.p.rapidapi.com" | jq '.data'
```

#### Booking.com Flights
```bash
curl -s --max-time 30 "https://flights-sky.p.rapidapi.com/bookingcom/search-oneway?departureId=JFK&arrivalId=LAX&departureDate=2026-07-15&adults=1&currency=USD" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: flights-sky.p.rapidapi.com" | jq '.data'
```

#### Skyscanner Flights (may need polling)
If `data.context.status = "incomplete"`, poll `/flights/search-incomplete` with same params.
```bash
curl -s --max-time 30 "https://flights-sky.p.rapidapi.com/flights/search-one-way?departureId=JFK&arrivalId=LAX&date=2026-07-15&adults=1" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: flights-sky.p.rapidapi.com" \
  | jq '{status: .data.context.status, results: .data.itineraries.results}'
```

#### Hotels (Skyscanner)
```bash
# Step 1 — get entityId
curl -s --max-time 30 "https://flights-sky.p.rapidapi.com/hotels/auto-complete?query=Tokyo" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: flights-sky.p.rapidapi.com" | jq '.data[0]'

# Step 2 — search (poll until completionPercentage=100)
curl -s --max-time 30 "https://flights-sky.p.rapidapi.com/hotels/search?entityId=ENTITY_ID&checkin=2026-08-10&checkout=2026-08-13&adults=2&currency=USD" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: flights-sky.p.rapidapi.com" \
  | jq '{pct: .data.status.completionPercentage, hotels: .data.hotels}'
```

---

### 2. Sky Scrapper (`sky-scrapper.p.rapidapi.com`)
Another Skyscanner scraper. Requires `skyId` + `entityId` pairs (from airport autocomplete). Good fallback when flights-sky is rate-limited.

#### Airport Lookup (required before flight search)
**Must use city/airport name, NOT IATA code** — searching "SAN" returns SFO; search "San Diego" to get SAN.
Lookup returns both city-level AND airport-level IDs. **Use airport-level entityIds for `searchFlights`** — city-level returns 0 results.

```bash
curl -s "https://sky-scrapper.p.rapidapi.com/api/v1/flights/searchAirport?query=New+York+JFK" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: sky-scrapper.p.rapidapi.com" \
  | jq '.data[0:3] | .[] | {skyId: .navigation.relevantFlightParams.skyId, entityId: .navigation.relevantFlightParams.entityId, name: .presentation.title}'
```

**Known airport-level entity IDs (confirmed 2026-06-04):**

| Airport | skyId | entityId |
|---------|-------|----------|
| JFK | `JFK` | `95565058` |
| LAX | `LAX` | `95673368` |
| San Diego | `SANA` | `27545066` |
| Mexico City | `MEXA` | `39151418` |

#### Flight Search
Use `searchFlights` (not `searchFlightsComplete` — that endpoint no longer exists).
Response: `.data.itineraries[]` directly (not `.data.itineraries.results[]`).
Status `"incomplete"` on first call is normal — results still returned. Don't retry unnecessarily.

```bash
curl -s "https://sky-scrapper.p.rapidapi.com/api/v1/flights/searchFlights?originSkyId=JFK&destinationSkyId=LAX&originEntityId=95565058&destinationEntityId=95673368&date=2026-07-15&adults=1&cabinClass=economy&currency=USD" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: sky-scrapper.p.rapidapi.com" \
  | jq '{status: .data.context.status, itineraries: [.data.itineraries[0:3][] | {price: .price.formatted, airline: .legs[0].carriers.marketing[0].name, stops: .legs[0].stopCount}]}'
```

**Params:** `originSkyId`, `destinationSkyId`, `originEntityId`, `destinationEntityId` (airport-level from lookup), `date`, `adults`, `cabinClass` (string: `economy`/`premium_economy`/`business`/`first`), `currency`

#### Price Calendar
```bash
curl -s "https://sky-scrapper.p.rapidapi.com/api/v1/flights/getPriceCalendar?originSkyId=JFK&destinationSkyId=CDG&fromDate=2026-07-01&currency=USD" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: sky-scrapper.p.rapidapi.com" | jq '.data'
```

---

### 3. Google Flights 2 (`google-flights2.p.rapidapi.com`)
DataCrawler's Google Flights scraper. Simpler params than flights-sky — IATA codes directly, no entity IDs needed. **Fastest and most reliable for quick price checks.**

#### One-Way Search
```bash
curl -s "https://google-flights2.p.rapidapi.com/api/v1/searchFlights?departure_id=JFK&arrival_id=LAX&outbound_date=2026-07-15&adults=1&currency=USD" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: google-flights2.p.rapidapi.com" \
  | jq '{topFlights: .data.itineraries.topFlights[0:3]}'
```

#### Round Trip
```bash
curl -s "https://google-flights2.p.rapidapi.com/api/v1/searchFlights?departure_id=JFK&arrival_id=CDG&outbound_date=2026-07-15&return_date=2026-07-25&adults=1&currency=USD&cabin_class=business" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: google-flights2.p.rapidapi.com" \
  | jq '.data.itineraries.topFlights[0:3]'
```

**Params:** `departure_id`, `arrival_id` (IATA), `outbound_date` (`YYYY-MM-DD`), `return_date`, `adults`, `cabin_class` (string: `economy`/`premium_economy`/`business`/`first`), `stops` (`0`=nonstop `1`=1stop `2`=2stops), `currency`

**Response:** `.data.itineraries.topFlights[]` — same structure as flights-sky with price, airline, segments, times

#### Price Calendar
```bash
curl -s "https://google-flights2.p.rapidapi.com/api/v1/getPriceCalendar?origin=JFK&destination=CDG&currency=USD" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: google-flights2.p.rapidapi.com" | jq '.data'
```

---

## Hotel APIs

### 4. Booking.com 15 (`booking-com15.p.rapidapi.com`)
DataCrawler's Booking.com scraper. Hotels, flights, cars, attractions.

#### Destination Lookup (required before hotel search)
```bash
curl -s "https://booking-com15.p.rapidapi.com/api/v1/hotels/searchDestination?query=Tokyo" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: booking-com15.p.rapidapi.com" \
  | jq '.data[0] | {dest_id, name, dest_type, country}'
# Returns: {"dest_id": "-246227", "name": "Tokyo", "dest_type": "city", ...}
```

#### Hotel Search
```bash
curl -s "https://booking-com15.p.rapidapi.com/api/v1/hotels/searchHotels?dest_id=-246227&search_type=city&arrival_date=2026-08-10&departure_date=2026-08-13&adults=2&room_qty=1&currency_code=USD&sort_by=popularity" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: booking-com15.p.rapidapi.com" | jq '.data.hotels[0:3]'
```

**sort_by options:** `popularity`, `class_descending`, `class_ascending`, `distance`, `review_score`

#### Hotel Details / Rooms
```bash
curl -s "https://booking-com15.p.rapidapi.com/api/v1/hotels/getRoomList?hotel_id=HOTEL_ID&arrival_date=2026-08-10&departure_date=2026-08-13&adults=2&currency_code=USD" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: booking-com15.p.rapidapi.com" | jq '.data[0:3]'
```

#### Booking.com Flights
```bash
curl -s "https://booking-com15.p.rapidapi.com/api/v1/flights/searchFlights?fromId=JFK.AIRPORT&toId=LAX.AIRPORT&departDate=2026-07-15&adults=1&cabinClass=ECONOMY&currency_code=USD" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: booking-com15.p.rapidapi.com" | jq '.data[0:3]'
```

---

### 5. Booking 119 (`booking119.p.rapidapi.com`)
**Same API paths and response structure as `booking-com15`.** Use as a backup/alternate host when booking-com15 is rate-limited. All booking-com15 curl examples work verbatim with `booking119.p.rapidapi.com` substituted as the host.

```bash
# Destination lookup — identical to booking-com15
curl -s "https://booking119.p.rapidapi.com/api/v1/hotels/searchDestination?query=Tokyo" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: booking119.p.rapidapi.com" \
  | jq '.data[0] | {dest_id, name, dest_type}'

# Hotel search — identical to booking-com15
curl -s "https://booking119.p.rapidapi.com/api/v1/hotels/searchHotels?dest_id=-246227&search_type=city&arrival_date=2026-08-10&departure_date=2026-08-13&adults=2&room_qty=1&currency_code=USD" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: booking119.p.rapidapi.com" \
  | jq '{count: (.data.hotels | length), first: .data.hotels[0].property | {name, price: .priceBreakdown.grossPrice}}'
```

---

### 6. Travel Advisor / TripAdvisor (`travel-advisor.p.rapidapi.com`)
DataCrawler's TripAdvisor scraper. Hotels, restaurants, attractions. Uses `location_id` from location search.

#### Location Search (get location_id)
```bash
curl -s "https://travel-advisor.p.rapidapi.com/locations/search?query=Tokyo&limit=5&offset=0&units=km&currency=USD&lang=en_US" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: travel-advisor.p.rapidapi.com" \
  | jq '.data[0].result_object | {location_id, name, location_string}'
# Returns: {"location_id": "298184", "name": "Tokyo", ...}
```

#### Hotels by Lat/Long
```bash
curl -s "https://travel-advisor.p.rapidapi.com/hotels/list-by-latlng?latitude=35.68&longitude=139.72&limit=5&currency=USD&lang=en_US" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: travel-advisor.p.rapidapi.com" \
  | jq '.data[0:3] | map({name, location_id, rating, price_level, web_url})'
```

#### Restaurants by Lat/Long
```bash
curl -s "https://travel-advisor.p.rapidapi.com/restaurants/list-by-latlng?latitude=35.68&longitude=139.72&limit=5&currency=USD&lang=en_US" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: travel-advisor.p.rapidapi.com" \
  | jq '.data[0:3] | map({name, location_id, rating, cuisine})'
```

#### Attractions by Lat/Long
```bash
curl -s "https://travel-advisor.p.rapidapi.com/attractions/list-by-latlng?latitude=35.68&longitude=139.72&limit=5&currency=USD&lang=en_US" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: travel-advisor.p.rapidapi.com" \
  | jq '.data[0:3] | map({name, location_id, rating})'
```

#### Hotel/Restaurant Details
```bash
curl -s "https://travel-advisor.p.rapidapi.com/hotels/get-details?location_id=298184&currency=USD&lang=en_US" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: travel-advisor.p.rapidapi.com" | jq '.'
```

---

## Restaurant APIs

### 7. OpenTable Data API (`opentable-data-api.p.rapidapi.com`)
Real OpenTable availability. **200 req/mo free. Slow — use 30s timeout.**

```bash
curl -s --max-time 30 "https://opentable-data-api.p.rapidapi.com/search?dateTime=2026-07-15T19%3A00%3A00&covers=2&metroId=8&term=Italian&sortBy=rating&page=1" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: opentable-data-api.p.rapidapi.com" \
  | jq '{total: .data.totalRestaurantCount, restaurants: [.data.restaurants[] | {name, primaryCuisine, overallRating, priceBandName, neighborhood, isInstantBookable}]}'
```

**Common metro IDs:** `4`=SF/Bay Area, `8`=NYC, `13`=Chicago, `15`=LA, `20`=Boston, `24`=DC, `27`=Miami

**Or use lat/long instead of metroId:** `?latitude=40.75&longitude=-73.99&...`

#### Restaurant Details + Reviews
```bash
curl -s --max-time 30 "https://opentable-data-api.p.rapidapi.com/restaurant/SLUG" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: opentable-data-api.p.rapidapi.com" | jq '.'

curl -s --max-time 30 "https://opentable-data-api.p.rapidapi.com/restaurant/SLUG/reviews?sortBy=newestReview" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: opentable-data-api.p.rapidapi.com" | jq '.data.reviews[0:5]'
```

`SLUG` = `profileUrl` from search results (e.g. `nobu-new-york`)

---

### 8. Yelp Business Search (`yelp-business-api.p.rapidapi.com`)
Yelp business search and individual business details.

#### Search Businesses
```bash
curl -s "https://yelp-business-api.p.rapidapi.com/search?location=NYC&search_term=sushi&page=1" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: yelp-business-api.p.rapidapi.com" \
  | jq '{total: .total, results: [.business_search_result[0:5][] | {name, avg_rating, review_count, categories}]}'
```

**Critical:** param is `search_term` (underscore), NOT `query`, NOT `search-term` (hyphen).

**Response:** `.total`, `.searched_Location`, `.searched_Term`, `.business_search_result[]` (NOT `.results[]`) with `name`, `avg_rating`, `review_count`, `lat`, `lon`, `alias`, `id`

#### Business Details by URL
```bash
curl -s "https://yelp-business-api.p.rapidapi.com/eachbusiness?url=https://www.yelp.com/biz/nobu-new-york-city" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: yelp-business-api.p.rapidapi.com" | jq '.'
```

---

### 9. Yelp Business Reviews (`yelp-business-reviews.p.rapidapi.com`)
Yelp search and reviews. Returns `bizId` you can use for reviews.

#### Search (get bizId)
```bash
curl -s "https://yelp-business-reviews.p.rapidapi.com/search?query=sushi&location=NYC" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: yelp-business-reviews.p.rapidapi.com" \
  | jq '{total: .resultCount, results: [.results[0:3] | .[] | {bizId, name, rating}]}'
```

#### Get Reviews (requires bizId from search)
```bash
curl -s "https://yelp-business-reviews.p.rapidapi.com/reviews/klAhw3xLQi9GF1tf_HnS7w?sortBy=yelp&page=1" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: yelp-business-reviews.p.rapidapi.com" | jq '.reviews[0:3]'
```

**sortBy options:** `yelp`, `newest`, `oldest`, `highestRated`, `lowestRated`, `elites`

#### Business Details
```bash
curl -s "https://yelp-business-reviews.p.rapidapi.com/details?business_aliases=nobu-new-york-city" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: yelp-business-reviews.p.rapidapi.com" | jq '.'
```

---

## Destination / Discovery APIs

### 10. Travel Guide (`travel-guide-api-city-guide-top-places.p.rapidapi.com`)
AI-generated city guides with top places, coordinates, and visit tips. Single endpoint.

```bash
curl -s -X POST "https://travel-guide-api-city-guide-top-places.p.rapidapi.com/check?noqueue=1" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: travel-guide-api-city-guide-top-places.p.rapidapi.com" \
  -H "Content-Type: application/json" \
  -d '{"region":"Paris","language":"en","interests":["historical","cultural","food"]}' \
  | jq '.result[] | {name, type, coordinates, comments}'
```

**interests options:** `historical`, `cultural`, `food`, `nature`, `shopping`, `nightlife`, `adventure`, `art`, `religious`

**Response:** `.result[]` with `name`, `description`, `coordinates` (lat/lng), `type`, `comments` (visit tips)

Use this as a quick destination intelligence layer — pair with Atlas Obscura for weirder finds.

---

### 11. Instagram Looter 2 (`instagram-looter2.p.rapidapi.com`)
Instagram public profile and post scraper.

#### Profile Info
```bash
curl -s "https://instagram-looter2.p.rapidapi.com/profile?username=natgeotravel" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: instagram-looter2.p.rapidapi.com" \
  | jq '{biography, followers: .edge_followed_by.count, posts: .edge_owner_to_timeline_media.count}'
```

#### User Posts Feed
```bash
# First get user ID from profile
curl -s "https://instagram-looter2.p.rapidapi.com/id?username=natgeotravel" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: instagram-looter2.p.rapidapi.com" | jq '.id'

# Then fetch posts
curl -s "https://instagram-looter2.p.rapidapi.com/user-feeds?id=USER_ID&count=12" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: instagram-looter2.p.rapidapi.com" | jq '.data[0:3]'
```

#### Hashtag Feeds
Response is nested under `.data.hashtag` — NOT a direct array.
```bash
curl -s "https://instagram-looter2.p.rapidapi.com/tag-feeds?query=tokyo&count=12" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: instagram-looter2.p.rapidapi.com" \
  | jq '{hashtag: .data.hashtag.name, post_count: .data.hashtag.edge_hashtag_to_media.count, posts: [.data.hashtag.edge_hashtag_to_media.edges[0:3][] | {shortcode: .node.shortcode, likes: .node.edge_liked_by.count}]}'
```

**Other endpoints:** `/post?link=URL`, `/search?query=term`, `/related-profiles?id=USER_ID`

---

## Short-term Rental APIs

### 12. Tripad-Mate (`tripad-mate.p.rapidapi.com`)
TripAdvisor scraper — simpler than `travel-advisor` as no location lookup step needed, just pass city name directly.

#### Hotel Search
```bash
curl -s "https://tripad-mate.p.rapidapi.com/hotels/search?query=Mexico+City&checkIn=2026-07-15&checkOut=2026-07-22&adults=2" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: tripad-mate.p.rapidapi.com" \
  | jq '{total: .totalResultCount, hotels: [.data.hotels[0:5][] | {name: .cardTitle.string, rating: .bubbleRating.rating, reviews: .bubbleRating.numberReviews.string}]}'
```

#### Restaurant Search
```bash
curl -s "https://tripad-mate.p.rapidapi.com/restaurants/search?query=Mexico+City" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: tripad-mate.p.rapidapi.com" \
  | jq '{total: .totalResultCount, restaurants: [.data.restaurants[0:5][] | {name: .cardTitle.string, rating: .bubbleRating.rating}]}'
```

**Response paths:** hotels at `.data.hotels[]`, restaurants at `.data.restaurants[]`. Both have `cardTitle.string` for name and `bubbleRating.rating` for score.

---

### 13. Homes/Experiences/Services Data (`homes-experiences-services-data.p.rapidapi.com`)
Airbnb listings scraper. Requires a Google Place ID — NOT a city name string.

#### Get Google Place ID First
Search "Google Place ID [city]" and use the Maps embed to extract it.
Known Place IDs: Mexico City = `ChIJB3UJ2yYAzoURQeQMKgW4H9E`, Tokyo = `ChIJ51cu8IcbXWARiRtXIothAS4`

#### Search Homes
```bash
curl -s "https://homes-experiences-services-data.p.rapidapi.com/homes/search?placeId=ChIJB3UJ2yYAzoURQeQMKgW4H9E" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: homes-experiences-services-data.p.rapidapi.com" \
  | jq '{total: .totalResultCount, listings: [.data.searchResults[0:5][] | {name: .listing.name, type: .listing.roomType, price: .pricingQuote.structuredStayDisplayPrice.primaryLine.price}]}'
```

**Response path:** `.data.searchResults[]` → `.listing.name`, `.listing.roomType`, `.pricingQuote.structuredStayDisplayPrice.primaryLine.price`

---

### 14. Airbnb Data API 2 (`airbnb-data-api2.p.rapidapi.com`)
Second Airbnb scraper — stays search, experiences, and trending. **Use `query=` (not `placeId=` or `location=`).**

#### Search Stays
```bash
curl -s "https://airbnb-data-api2.p.rapidapi.com/search/stays?query=Tokyo&adults=2&checkin=2026-07-10&checkout=2026-07-15" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: airbnb-data-api2.p.rapidapi.com" \
  | jq '{count: (.results | length), first: .results[0] | {name, roomType}}'
```

**Critical:** param must be `query=CITY` — not `placeId`, not `location`. Returns 422 validation error otherwise.

#### Search Experiences
```bash
curl -s "https://airbnb-data-api2.p.rapidapi.com/experiences?query=Tokyo" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: airbnb-data-api2.p.rapidapi.com" \
  | jq '{count: (.results | length), first: .results[0] | {name, id}}'
```

#### Experience Detail
```bash
curl -s "https://airbnb-data-api2.p.rapidapi.com/experiences/EXPERIENCE_ID" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: airbnb-data-api2.p.rapidapi.com" \
  | jq '{name, duration, rating, reviewCount, highlights}'
```

#### Trending Destinations
```bash
curl -s "https://airbnb-data-api2.p.rapidapi.com/trending" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: airbnb-data-api2.p.rapidapi.com" \
  | jq '.sections[0:3]'
```

**Note:** `/autocomplete` endpoint returns a fixed list of popular US beach destinations regardless of query — not a true autocomplete. Don't use for city lookup.

**Available endpoints (confirmed via MCP hub tools/list):** `/search/stays`, `/experiences`, `/experiences/{id}`, `/listings/{id}`, `/listings/{id}/reviews`, `/trending`, `/autocomplete`

---

## Maps / Geocoding APIs

### 15. Map API 7 (`map-api7.p.rapidapi.com`)
OpenStreetMap-based routing, geocoding, and address lookup. **This is NOT a places search API** — don't use it to find restaurants or hotels. Use it for turn-by-turn routing, address geocoding, and travel time calculations.

#### Geocode (Place Name → Lat/Lon)
```bash
curl -s "https://map-api7.p.rapidapi.com/geocode-search.php?text=Eiffel+Tower+Paris&limit=3" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: map-api7.p.rapidapi.com" \
  | jq '{count: (.features | length), first: .features[0] | {name: .properties.name, lat: .geometry.coordinates[1], lon: .geometry.coordinates[0]}}'
```

#### Routing / Directions
```bash
curl -s "https://map-api7.p.rapidapi.com/routing.php?waypoints=48.8566,2.3522|48.8606,2.3376&mode=walk" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: map-api7.p.rapidapi.com" \
  | jq '{type, features: (.features | length)}'
```

**mode options:** `drive`, `truck`, `bicycle`, `walk`, `transit`

**waypoints format:** `LAT,LON|LAT,LON` (pipe-separated, two or more points)

**Available endpoints (confirmed via MCP hub):** `/geocode-search.php` (geocode), `/routing.php` (directions), `/isoline.php` (travel time isochrone), `/address-auto-complete.php`, `/places.php` (places by type — limited reliability), `/reverse.php` (reverse geocode), `/tile.php` (map tiles)

---

## Non-Functional / Blocked APIs

### `google-map-scraper11.p.rapidapi.com`
**Status: ❌ Monthly quota exceeded on BASIC plan (as of 2026-06-04).** Cannot use until quota resets or plan upgraded. Previously documented as needing a `GOOGLE_MAPS_API_KEY` — the actual blocker is the quota wall.

### `viator-api.p.rapidapi.com`
**Status: ❌ Mislabeled subscription.** Despite the name, this API is actually a Hostelworld scraper (tool descriptions reference "Hostelworld website" explicitly). Only 2 MCP tools exist — both Hostelworld-specific. Direct REST endpoints return 404 for all paths tested. MCP hub tool calls time out. **Do not use for Viator tour content.**

If tours/activities search is needed, check the RapidAPI marketplace for a correctly-labeled Viator or GetYourGuide scraper.

---

## Requires Additional Credentials

### Foursquare (`Foursquareserg-osipchukV1.p.rapidapi.com`)
**Status: Subscribed but requires Foursquare app credentials (`clientId` + `clientSecret`) not in `.env`.** Skip unless user has Foursquare developer credentials.

If credentials are available, venue search uses POST:
```bash
curl -s -X POST "https://foursquareserg-osipchukv1.p.rapidapi.com/searchVenues" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: Foursquareserg-osipchukV1.p.rapidapi.com" \
  -H "Content-Type: application/json" \
  -d '{"clientId":"YOUR_FSQ_CLIENT_ID","clientSecret":"YOUR_FSQ_CLIENT_SECRET","near":"New York","query":"coffee","limit":5}' | jq '.'
```

---

## MCP Hub Configuration

All RapidAPI servers in `.mcp.json` connect via `mcp-remote` to `https://mcp.rapidapi.com` (hub version v0.1.12) with `x-api-host` and `x-api-key` headers routing to the specific API. To discover available tools for any subscribed API without testing endpoints:

```bash
curl -s -X POST "https://mcp.rapidapi.com" \
  -H "x-api-host: SOME-HOST.p.rapidapi.com" \
  -H "x-api-key: $RAPIDAPI_KEY" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"tools/list","params":{},"id":1}' \
  | jq '.result.tools[] | {name, endpoint: .inputSchema.properties._endpoint.default}'
```

---

## Rate Limit Summary

| API | Free/mo | Best Use |
|-----|---------|----------|
| `flights-sky` | 50 | Google/Skyscanner/Booking flights + hotels |
| `sky-scrapper` | check | Skyscanner backup; use airport-level entity IDs |
| `google-flights2` | check | **Primary** — cleanest params, fastest for Google Flights prices |
| `booking-com15` | check | Booking.com hotels + flights |
| `booking119` | check | Backup to booking-com15, identical API paths |
| `travel-advisor` | check | TripAdvisor hotels/restaurants/attractions |
| `tripad-mate` | check | TripAdvisor — simpler, no location ID lookup |
| `opentable-data-api` | 200 | OpenTable reservations; slow, use 30s timeout |
| `yelp-business-api` | check | Yelp business search |
| `yelp-business-reviews` | check | Yelp reviews |
| `travel-guide` | check | AI city guides |
| `instagram-looter2` | check | Destination inspiration, travel accounts |
| `homes-experiences-services-data` | check | Airbnb listings via Google Place ID |
| `airbnb-data-api2` | check | Airbnb stays + experiences via `query=` param |
| `map-api7` | check | Routing + geocoding (OpenStreetMap); NOT places search |
| `google-map-scraper11` | ❌ quota | Monthly quota exceeded — skip |
| `viator-api` | ❌ broken | Mislabeled Hostelworld scraper — skip |

**Flight source priority:** `google-flights2` first (fastest, cleanest), then `flights-sky` for Skyscanner and Booking.com coverage, then `sky-scrapper` as Skyscanner fallback.

**Hotel source priority:** `tripad-mate` for quick TripAdvisor results, `booking-com15` or `booking119` for Booking.com rates, `homes-experiences-services-data` for Airbnb listings.

**Airbnb source choice:** Use `homes-experiences-services-data` for stays (placeId-based), `airbnb-data-api2` for experiences search or when you only have a city name (`query=`).
