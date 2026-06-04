# RapidAPI Subscribed APIs

All tested 2026-06-04 against Mexico City. 10/10 working.

## Flight APIs

| Host | Status | Notes |
|------|--------|-------|
| `flights-sky.p.rapidapi.com` | ✅ | Google Flights, Skyscanner, Booking.com. 50 req/mo. |
| `sky-scrapper.p.rapidapi.com` | ✅ | Use `searchFlights` (not `searchFlightsComplete`). Search by city name, not IATA. |
| `google-flights2.p.rapidapi.com` | ✅ | Cleanest params. Airline name occasionally null (cosmetic). |

## Hotel APIs

| Host | Status | Notes |
|------|--------|-------|
| `booking-com15.p.rapidapi.com` | ✅ | Requires destination lookup first. Mexico City dest_id: `-1658079`. |
| `travel-advisor.p.rapidapi.com` | ✅ | TripAdvisor hotels/restaurants/attractions. Mexico City location_id: `150800`. |

## Restaurant APIs

| Host | Status | Notes |
|------|--------|-------|
| `opentable-data-api.p.rapidapi.com` | ✅ | Works internationally via lat/long. 782 results for Mexico City. 200 req/mo. |
| `yelp-business-api.p.rapidapi.com` | ✅ | Response key is `.business_search_result[]` (not `.results[]`). |
| `yelp-business-reviews.p.rapidapi.com` | ✅ | Returns `bizId` for review lookups. |

## Discovery APIs

| Host | Status | Notes |
|------|--------|-------|
| `travel-guide-api-city-guide-top-places.p.rapidapi.com` | ✅ | POST endpoint. AI city guide with top places + visit tips. |
| `instagram-looter2.p.rapidapi.com` | ✅ | tag-feeds path: `.data.hashtag.edge_hashtag_to_media.edges[]` (not `.data[]`). |

## Requires External Credentials

| Host | Status | Notes |
|------|--------|-------|
| `Foursquareserg-osipchukV1.p.rapidapi.com` | ⚠️ | Subscribed but needs Foursquare `clientId`+`clientSecret`. Not in `.env`. |
