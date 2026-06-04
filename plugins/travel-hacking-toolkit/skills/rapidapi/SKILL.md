---
name: rapidapi
description: Search flights (Google Flights, Skyscanner, Booking.com), hotels (Booking.com, TripAdvisor), restaurants (Yelp, OpenTable), destinations (travel guide, atlas), and social/local (Instagram, Foursquare) via RapidAPI scrapers. Use for cash flight prices, hotel pricing, restaurant discovery, and destination research. Triggers on "RapidAPI", "Skyscanner", "Booking.com flights", "Yelp", "OpenTable", "TripAdvisor", "Instagram", "travel guide", or when SerpAPI flight results need a second opinion.
license: MIT
---

# RapidAPI Skill

## Subscribed APIs (last tested 2026-06-04)

| Host | Category | Status | Notes |
|------|----------|--------|-------|
| `flights-sky.p.rapidapi.com` | Flights | ✅ | Google Flights, Skyscanner, Booking.com. 50 req/mo. |
| `sky-scrapper.p.rapidapi.com` | Flights | ✅ | Use `searchFlights` (not `searchFlightsComplete`). Search by city name, not IATA code. |
| `google-flights2.p.rapidapi.com` | Flights | ✅ | Cleanest params. Airline name occasionally null (cosmetic). |
| `booking-com15.p.rapidapi.com` | Hotels | ✅ | Requires destination lookup first to get `dest_id`. |
| `travel-advisor.p.rapidapi.com` | Hotels/Restaurants | ✅ | TripAdvisor scraper. Requires location lookup for `location_id`. |
| `opentable-data-api.p.rapidapi.com` | Restaurants | ✅ | Works internationally via lat/long. 200 req/mo. |
| `yelp-business-api.p.rapidapi.com` | Restaurants | ✅ | Response key is `.business_search_result[]` (not `.results[]`). |
| `yelp-business-reviews.p.rapidapi.com` | Restaurants | ✅ | Returns `bizId` for review detail lookups. |
| `travel-guide-api-city-guide-top-places.p.rapidapi.com` | Discovery | ✅ | POST endpoint. AI city guide with top places + coordinates. |
| `instagram-looter2.p.rapidapi.com` | Discovery | ✅ | tag-feeds path: `.data.hashtag.edge_hashtag_to_media.edges[]`. |
| `Foursquareserg-osipchukV1.p.rapidapi.com` | Discovery | ⚠️ | Subscribed but needs Foursquare `clientId`+`clientSecret` — not in `.env`. |

To add a new subscription, update this table and add a section below with working curl examples.

## Authentication

`RAPIDAPI_KEY` is set in `.env`. Every request uses:
```
x-rapidapi-key: $RAPIDAPI_KEY
x-rapidapi-host: <host>
```

---

## Flight APIs

### 1. Flights Scraper Sky (`flights-sky.p.rapidapi.com`)
Scrapes Google Flights, Skyscanner, and Booking.com. **50 req/mo free.**

#### Google Flights — One-Way
```bash
curl -s "https://flights-sky.p.rapidapi.com/google/flights/search-one-way?departureId=JFK&arrivalId=LAX&departureDate=2026-07-15&adults=1&currency=USD" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: flights-sky.p.rapidapi.com" \
  | jq '{topFlights: .data.topFlights, otherFlights: .data.otherFlights}'
```

#### Google Flights — Round Trip
```bash
curl -s "https://flights-sky.p.rapidapi.com/google/flights/search-roundtrip?departureId=JFK&arrivalId=LAX&departureDate=2026-07-15&returnDate=2026-07-25&adults=1&currency=USD" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: flights-sky.p.rapidapi.com" \
  | jq '{topFlights: .data.topFlights, otherFlights: .data.otherFlights}'
```

**Params:** `departureId`, `arrivalId` (IATA codes), `departureDate` (`YYYY-MM-DD`), `returnDate`, `adults`, `cabinClass` (integer: `1`=economy `2`=premium `3`=business `4`=first), `currency`

**Response keys:** `.data.topFlights[]` and `.data.otherFlights[]` — each has `price`, `airlineNames`, `segments[]`, `duration`, `departureTime`, `arrivalTime`

#### Price Calendar
```bash
curl -s "https://flights-sky.p.rapidapi.com/google/price-calendar/for-one-way?departureId=JFK&arrivalId=CDG&currency=USD" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: flights-sky.p.rapidapi.com" | jq '.data'
```

#### Booking.com Flights
```bash
curl -s "https://flights-sky.p.rapidapi.com/bookingcom/search-oneway?departureId=JFK&arrivalId=LAX&departureDate=2026-07-15&adults=1&currency=USD" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: flights-sky.p.rapidapi.com" | jq '.data'
```

#### Skyscanner Flights (may need polling)
If `data.context.status = "incomplete"`, poll `/flights/search-incomplete` with same params.
```bash
curl -s "https://flights-sky.p.rapidapi.com/flights/search-one-way?departureId=JFK&arrivalId=LAX&date=2026-07-15&adults=1" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: flights-sky.p.rapidapi.com" \
  | jq '{status: .data.context.status, results: .data.itineraries.results}'
```

#### Hotels (Skyscanner)
```bash
# Step 1 — get entityId
curl -s "https://flights-sky.p.rapidapi.com/hotels/auto-complete?query=Tokyo" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: flights-sky.p.rapidapi.com" | jq '.data[0]'

# Step 2 — search (poll until completionPercentage=100)
curl -s "https://flights-sky.p.rapidapi.com/hotels/search?entityId=ENTITY_ID&checkin=2026-08-10&checkout=2026-08-13&adults=2&currency=USD" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: flights-sky.p.rapidapi.com" \
  | jq '{pct: .data.status.completionPercentage, hotels: .data.hotels}'
```

---

### 2. Sky Scrapper (`sky-scrapper.p.rapidapi.com`)
Another Skyscanner scraper. Requires `skyId` + `entityId` pairs (from airport autocomplete). Good fallback when flights-sky is rate-limited. **Rate limit: check plan.**

#### Airport Lookup (required before flight search)
**Must use city/airport name, NOT IATA code** — searching "SAN" returns SFO; search "San Diego" to get SAN.
Returns city-level skyIds (e.g. `SANA` for San Diego, `MEXA` for Mexico City).
```bash
curl -s "https://sky-scrapper.p.rapidapi.com/api/v1/flights/searchAirport?query=San+Diego" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: sky-scrapper.p.rapidapi.com" \
  | jq '.data[0].navigation.relevantFlightParams'
# Returns: {"skyId": "SANA", "entityId": "27545066", "localizedName": "San Diego", ...}
```

#### Flight Search
Use `searchFlights` (not `searchFlightsComplete` — that endpoint no longer exists).
Response: `.data.itineraries[]` directly (not `.data.itineraries.results[]`).
```bash
curl -s "https://sky-scrapper.p.rapidapi.com/api/v1/flights/searchFlights?originSkyId=SANA&destinationSkyId=MEXA&originEntityId=27545066&destinationEntityId=39151418&date=2026-07-15&adults=1&cabinClass=economy&currency=USD" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: sky-scrapper.p.rapidapi.com" \
  | jq '{status: .data.context.status, itineraries: [.data.itineraries[0:3][] | {price: .price.formatted, airline: .legs[0].carriers.marketing[0].name, stops: .legs[0].stopCount}]}'
```

**Params:** `originSkyId`, `destinationSkyId`, `originEntityId`, `destinationEntityId` (all from airport lookup), `date`, `adults`, `cabinClass` (string: `economy`/`premium_economy`/`business`/`first`), `currency`

#### Price Calendar
```bash
curl -s "https://sky-scrapper.p.rapidapi.com/api/v1/flights/getPriceCalendar?originSkyId=JFK&destinationSkyId=CDG&fromDate=2026-07-01&currency=USD" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: sky-scrapper.p.rapidapi.com" | jq '.data'
```

---

### 3. Google Flights 2 (`google-flights2.p.rapidapi.com`)
DataCrawler's Google Flights scraper. Simpler params than flights-sky — IATA codes directly, no entity IDs needed. **Rate limit: check plan.**

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
DataCrawler's Booking.com scraper. Hotels, flights, cars, attractions. **Rate limit: check plan.**

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
# First get fromId/toId
curl -s "https://booking-com15.p.rapidapi.com/api/v1/flights/searchDestination?query=JFK" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: booking-com15.p.rapidapi.com" | jq '.data[0]'

curl -s "https://booking-com15.p.rapidapi.com/api/v1/flights/searchFlights?fromId=JFK.AIRPORT&toId=LAX.AIRPORT&departDate=2026-07-15&adults=1&cabinClass=ECONOMY&currency_code=USD" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: booking-com15.p.rapidapi.com" | jq '.data[0:3]'
```

---

### 5. Travel Advisor / TripAdvisor (`travel-advisor.p.rapidapi.com`)
DataCrawler's TripAdvisor scraper. Hotels, restaurants, attractions. Uses `location_id` from location search. **Rate limit: check plan.**

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

### 6. OpenTable Data API (`opentable-data-api.p.rapidapi.com`)
Real OpenTable availability. **200 req/mo free.**

```bash
curl -s "https://opentable-data-api.p.rapidapi.com/search?dateTime=2026-07-15T19%3A00%3A00&covers=2&metroId=8&term=Italian&sortBy=rating&page=1" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: opentable-data-api.p.rapidapi.com" \
  | jq '{total: .data.totalRestaurantCount, restaurants: [.data.restaurants[] | {name, primaryCuisine, overallRating, priceBandName, neighborhood, isInstantBookable}]}'
```

**Common metro IDs:** `4`=SF/Bay Area, `8`=NYC, `13`=Chicago, `15`=LA, `20`=Boston, `24`=DC, `27`=Miami

**Or use lat/long instead of metroId:** `?latitude=40.75&longitude=-73.99&...`

#### Restaurant Details + Reviews
```bash
curl -s "https://opentable-data-api.p.rapidapi.com/restaurant/SLUG" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: opentable-data-api.p.rapidapi.com" | jq '.'

curl -s "https://opentable-data-api.p.rapidapi.com/restaurant/SLUG/reviews?sortBy=newestReview" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: opentable-data-api.p.rapidapi.com" | jq '.data.reviews[0:5]'
```

`SLUG` = `profileUrl` from search results (e.g. `nobu-new-york`)

---

### 7. Yelp Business Search (`yelp-business-api.p.rapidapi.com`)
Yelp business search and individual business details. **Rate limit: check plan.**

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

### 8. Yelp Business Reviews (`yelp-business-reviews.p.rapidapi.com`)
Yelp search and reviews. Returns `bizId` you can use for reviews. **Rate limit: check plan.**

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

### 9. Travel Guide (`travel-guide-api-city-guide-top-places.p.rapidapi.com`)
AI-generated city guides with top places, coordinates, and visit tips. Single endpoint. **Rate limit: check plan.**

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

### 10. Instagram Looter 2 (`instagram-looter2.p.rapidapi.com`)
Instagram public profile and post scraper. **Rate limit: check plan.**

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

## Requires Additional Credentials

### 11. Foursquare (`Foursquareserg-osipchukV1.p.rapidapi.com`)
**Status: Subscribed but requires Foursquare app credentials (`clientId` + `clientSecret`) not in `.env`.** Skip unless user has Foursquare developer credentials.

If credentials are available, venue search uses POST:
```bash
curl -s -X POST "https://foursquareserg-osipchukv1.p.rapidapi.com/searchVenues" \
  -H "x-rapidapi-key: $RAPIDAPI_KEY" -H "x-rapidapi-host: Foursquareserg-osipchukV1.p.rapidapi.com" \
  -H "Content-Type: application/json" \
  -d '{"clientId":"YOUR_FSQ_CLIENT_ID","clientSecret":"YOUR_FSQ_CLIENT_SECRET","near":"New York","query":"coffee","limit":5}' | jq '.'
```

---

## Rate Limit Summary

| API | Free/mo | Best Use |
|-----|---------|----------|
| `flights-sky` | 50 | Google/Skyscanner/Booking flights + hotels |
| `sky-scrapper` | check | Skyscanner backup |
| `google-flights2` | check | Cleanest params for Google Flights |
| `booking-com15` | check | Booking.com hotels + attractions |
| `travel-advisor` | check | TripAdvisor hotels/restaurants/attractions |
| `opentable-data-api` | 200 | OpenTable reservations |
| `yelp-business-api` | check | Yelp business search |
| `yelp-business-reviews` | check | Yelp reviews |
| `travel-guide` | check | AI city guides |
| `instagram-looter2` | check | Destination inspiration, travel accounts |

Use flights-sky and google-flights2 as primary flight sources. Prefer opentable over yelp for reservation availability. Use travel-advisor for TripAdvisor content.
