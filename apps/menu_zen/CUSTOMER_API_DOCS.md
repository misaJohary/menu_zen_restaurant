# Customer App API Reference

This document lists every HTTP endpoint relevant when building the customer-facing
application. It covers:

- **Public endpoints** under `/public/*` — no auth required, used for discovery,
  browsing menus, reading reviews.
- **Customer endpoints** under `/customers/*` and `/customers/me/*` — auth
  required with a customer-scoped JWT.
- **Shared utility endpoints** (`/languages`, `/health`).

Staff/admin routers (`/auth`, `/restaurants` write paths, `/orders` staff
side, `/stats`, `/kitchens`, `/restaurant-tables` write paths, etc.) are out
of scope for the customer app and are not documented here.

---

## Conventions

- **Base URL**: whatever host the FastAPI app is mounted on (e.g.
  `http://localhost:8000` in dev).
- **Content type**: `application/json` everywhere except `POST /customers/login`,
  which uses `application/x-www-form-urlencoded` (`OAuth2PasswordRequestForm`).
- **Auth header**: `Authorization: Bearer <access_token>` for any
  `/customers/me/*` endpoint.
- **Token scope**: the customer JWT carries `typ: "customer"`. Staff tokens are
  rejected on `/customers/me/*` and vice versa.
- **Pagination**: list endpoints accept `limit` and `offset` query parameters.
- **Timestamps**: ISO-8601 strings (UTC unless otherwise noted).
- **Errors**: standard FastAPI error shape `{ "detail": "<message>" }`.

---

## 1. Auth & Customer Profile — [app/routers/customers_auth.py](app/routers/customers_auth.py)

All endpoints share the prefix `/customers`. Profile endpoints (`/me*`)
require the `Authorization: Bearer …` header.

### 1.1 POST `/customers/register`

Create a new customer account.

**Request body** (`CustomerCreate`):

```json
{
  "email": "jane@example.com",
  "phone": "+261340000000",
  "full_name": "Jane Doe",
  "password": "min8chars"
}
```

**Response 201** (`CustomerToken`):

```json
{
  "access_token": "<jwt>",
  "token_type": "bearer",
  "customer": {
    "id": 1,
    "email": "jane@example.com",
    "phone": "+261340000000",
    "full_name": "Jane Doe",
    "avatar": null,
    "created_at": "2026-05-13T10:00:00"
  }
}
```

**Errors**

| Code | When |
|------|------|
| 409  | Email already registered |
| 422  | Validation failed (e.g. password < 8 chars) |

### 1.2 POST `/customers/login`

OAuth2 password flow. `username` may be the customer's email **or** phone.

**Request** (form-urlencoded):

```
username=jane@example.com&password=...
```

**Response 200**: same `CustomerToken` shape as register.

**Errors**

| Code | When |
|------|------|
| 401  | Wrong credentials or disabled account |

### 1.3 GET `/customers/me`

Returns the current customer profile (`CustomerPublic`). Requires auth.

### 1.4 PATCH `/customers/me`

Update name / phone / avatar. Email cannot be changed.

**Body** (any subset, `CustomerUpdate`):

```json
{
  "phone": "+261...",
  "full_name": "Jane D.",
  "avatar": "https://.../avatar.png"
}
```

**Response 200**: updated `CustomerPublic`.

### 1.5 POST `/customers/me/password`

Change password.

**Body** (`CustomerPasswordChange`):

```json
{
  "old_password": "current",
  "new_password": "atleast8chars"
}
```

**Response**: `204 No Content`. Returns 400 if `old_password` does not match.

### 1.6 DELETE `/customers/me`

Soft-disables the current customer (sets `disabled = true`). Subsequent
requests with the same token return 401. Response `204`.

---

## 2. Public Discovery — [app/routers/public_restaurants.py](app/routers/public_restaurants.py)

All endpoints are unauthenticated and share the prefix `/public`. Disabled
restaurants and inactive menus/items are always hidden.

### 2.1 GET `/public/restaurants/search`

Geo-search for nearby restaurants. Required: caller's `lat`, `long`.

**Query**

| Name        | Type    | Required | Default | Notes |
|-------------|---------|----------|---------|-------|
| `lat`       | float   | yes      | —       | `-90..90` |
| `long`      | float   | yes      | —       | `-180..180` |
| `radius_km` | float   | no       | —       | `>0..500`, omit for unlimited |
| `q`         | string  | no       | —       | Name substring, max 120 chars |
| `type`      | enum    | no       | —       | `fastfood` \| `casual` \| `fine_dining` |
| `limit`     | int     | no       | 20      | 1..50 |
| `offset`    | int     | no       | 0       | ≥0 |

**Response 200** (`RestaurantSearchResponse`):

```json
{
  "total": 42,
  "items": [
    {
      "id": 7,
      "name": "Chez Mada",
      "description": "...",
      "type": "casual",
      "languages": ["fr", "en"],
      "logo": "uploads/...",
      "cover": "uploads/...",
      "pictures": [],
      "social_media": [],
      "opening_hours": { /* see §6 */ },
      "phone": "+261...",
      "email": "contact@chez-mada.mg",
      "city": "Antananarivo",
      "lat": -18.879,
      "long": 47.507,
      "disabled": false,
      "distance_km": 1.23
    }
  ]
}
```

Ordered by distance ascending. `distance_km` is `null` only when the
restaurant has no location (shouldn't happen since unlocated rows are
filtered out, but the field is nullable for safety).

### 2.2 GET `/public/restaurants/{restaurant_id}`

Full restaurant detail with computed live fields.

**Response 200** (`RestaurantDetailPublic`): identical to a search item, plus:

```json
{
  "avg_rating": 4.32,
  "review_count": 18,
  "is_open_now": true,
  "next_opening": null
}
```

When closed, `is_open_now` is `false` and `next_opening` carries the next slot:

```json
{
  "is_open_now": false,
  "next_opening": { "day": "tomorrow", "time": "11:00" }
}
```

`day` can be `"today"`, `"tomorrow"`, or a weekday name (`"Monday"` …
`"Sunday"`). Returns `404` if the restaurant is missing or disabled.

### 2.3 GET `/public/restaurants/{restaurant_id}/menus`

List active menus. Pagination via `limit` (1..50, default 50) and `offset`.

**Response 200**: `MenuPublic[]`

```json
[
  {
    "id": 3,
    "active": true,
    "restaurant_id": 7,
    "translations": [
      { "id": 11, "language_code": "fr", "name": "Carte du midi", "description": "..." }
    ]
  }
]
```

### 2.4 GET `/public/restaurants/{restaurant_id}/categories`

List active categories. Same pagination as §2.3.

**Response 200**: `CategoryPublic[]`

```json
[
  {
    "id": 12,
    "color": "#ff7043",
    "restaurant_id": 7,
    "active": true,
    "translations": [
      { "language_code": "fr", "name": "Entrées", "description": null }
    ]
  }
]
```

### 2.5 GET `/public/restaurants/{restaurant_id}/menu-items`

List active menu items for a restaurant, with optional filters.

**Query**

| Name          | Type    | Required | Default | Notes |
|---------------|---------|----------|---------|-------|
| `menu_id`     | int     | no       | —       | Items belonging to that menu |
| `category_id` | int     | no       | —       | Items in that category |
| `search`      | string  | no       | —       | Substring match on translated name |
| `limit`       | int     | no       | 50      | 1..50 |
| `offset`      | int     | no       | 0       | ≥0 |

**Response 200**: `MenuItemPublic[]`

```json
[
  {
    "id": 101,
    "price": 18000,
    "picture": "uploads/...",
    "pictures": [],
    "category_id": 12,
    "restaurant_id": 7,
    "kitchen_id": 3,
    "active": true,
    "category": { "id": 12, "color": "#ff7043", "active": true, "translations": [...] },
    "menus": [{ "id": 3, "active": true, "translations": [...] }],
    "translations": [
      { "id": 88, "language_code": "fr", "name": "Romazava", "description": "..." }
    ]
  }
]
```

### 2.6 GET `/public/menu-items/{menu_item_id}`

Single menu item by id. Hidden if the item or its restaurant is inactive/disabled
(returns 404).

### 2.7 GET `/public/restaurants/{restaurant_id}/reviews`

Paginated reviews.

**Query**

| Name     | Type | Required | Default   | Notes |
|----------|------|----------|-----------|-------|
| `sort`   | enum | no       | `recent`  | `recent` \| `top` \| `low` |
| `limit`  | int  | no       | 20        | 1..50 |
| `offset` | int  | no       | 0         | ≥0 |

**Response 200**: `ReviewPublic[]`

```json
[
  {
    "id": 5,
    "rating": 5,
    "comment": "Great food!",
    "created_at": "2026-05-10T12:00:00",
    "customer": { "id": 1, "display_name": "Jane Doe", "avatar": null }
  }
]
```

### 2.8 GET `/public/restaurants/{restaurant_id}/reviews/summary`

Aggregate ratings.

**Response 200** (`ReviewSummary`):

```json
{
  "avg": 4.32,
  "count": 18,
  "histogram": { "1": 0, "2": 1, "3": 2, "4": 5, "5": 10 }
}
```

---

## 3. Favorites — [app/routers/customers_favorites.py](app/routers/customers_favorites.py)

Prefix: `/customers/me/favorites`. All endpoints require the customer JWT.

### 3.1 GET `/customers/me/favorites`

List the caller's favorited restaurants, newest first. Pagination via
`limit` (1..100, default 50) and `offset`.

**Response 200**: `FavoritePublic[]`

```json
[
  { "id": 4, "created_at": "...", "restaurant": { /* RestaurantPublic */ } }
]
```

### 3.2 POST `/customers/me/favorites`

Add a favorite. Idempotent — if the favorite already exists, it is returned
without an error.

**Body** (`FavoriteCreate`):

```json
{ "restaurant_id": 7 }
```

**Response 200**: `FavoritePublic`. Returns 404 if the restaurant is missing/disabled.

### 3.3 DELETE `/customers/me/favorites/{restaurant_id}`

Remove a favorite. Idempotent — returns `204` whether the row existed or not.
Can never delete another customer's favorite.

---

## 4. Reviews (write) — [app/routers/customers_reviews.py](app/routers/customers_reviews.py)

Prefix: `/customers/me/reviews`. Reads of reviews go through the public
endpoints in §2.7 / §2.8.

### 4.1 POST `/customers/me/reviews`

Create a review. One review per (customer, restaurant) — a second attempt
returns 409.

**Body** (`ReviewCreate`):

```json
{
  "restaurant_id": 7,
  "rating": 5,
  "comment": "Great food!"
}
```

`rating` must be 1..5. `comment` is optional, max 2000 chars.

**Response 201**: `ReviewPublic` (same shape as §2.7).

### 4.2 GET `/customers/me/reviews`

List the caller's own reviews, newest first. Pagination via `limit` (1..100,
default 50) and `offset`.

### 4.3 PATCH `/customers/me/reviews/{review_id}`

Update rating / comment on your own review. 404 if the review id does not
belong to the caller.

**Body** (`ReviewUpdate`, any subset):

```json
{ "rating": 4, "comment": "Updated" }
```

### 4.4 DELETE `/customers/me/reviews/{review_id}`

Delete your own review. Response `204`. 404 if it does not belong to you.

---

## 5. Reservations — [app/routers/customers_reservations.py](app/routers/customers_reservations.py)

Prefix: `/customers/me/reservations`. Customer-driven booking.

`status` enum (`ReservationStatus`):

- `active`
- `honored`
- `cancelled`
- `no_show`

### 5.1 POST `/customers/me/reservations`

Create a reservation. The customer's `full_name` (or email) and `phone` are
copied from the profile so staff can see them. Initial status is `active`.

**Body** (`CustomerReservationCreate`):

```json
{
  "restaurant_id": 7,
  "reserved_at": "2026-05-20T19:30:00",
  "party_size": 4,
  "note": "Window seat please"
}
```

`party_size` is optional, 1..200. `note` is optional, max 500 chars.

**Response 201** (`CustomerReservationPublic`):

```json
{
  "id": 12,
  "reserved_at": "2026-05-20T19:30:00",
  "status": "active",
  "party_size": 4,
  "note": "Window seat please",
  "created_at": "...",
  "restaurant": { /* RestaurantPublic */ },
  "assigned_tables": []
}
```

`assigned_tables` is populated by staff later (table IDs and status).

### 5.2 GET `/customers/me/reservations`

List the caller's reservations, newest `reserved_at` first.

**Query**

| Name     | Type | Default | Notes |
|----------|------|---------|-------|
| `status` | enum | —       | Filter by `ReservationStatus` |
| `limit`  | int  | 50      | 1..100 |
| `offset` | int  | 0       | ≥0 |

### 5.3 GET `/customers/me/reservations/{reservation_id}`

Single reservation. 404 if not yours.

### 5.4 PATCH `/customers/me/reservations/{reservation_id}/cancel`

Cancel an `active` reservation. Already-cancelled reservations return 200
with the current state (idempotent). Anything else (`honored`, `no_show`)
returns 409. Cascades cancellation to any `TableReservation` rows.

---

## 6. Orders — [app/routers/customers_orders.py](app/routers/customers_orders.py)

Prefix: `/customers/me/orders`. Customer-placed orders.

### Enums

`OrderType`:

- `dine_in` — requires a `restaurant_table_id` belonging to the same restaurant.
- `pickup`
- `delivery`

`OrderStatus`:

- `created`
- `in_preparation`
- `ready`
- `served`
- `cancelled`

`PaymentStatus`:

- `unpaid`
- `paid`
- `prepaid`
- `refunded`

### 6.1 POST `/customers/me/orders`

Create an order. The server computes prices from the current `MenuItem.price`
— the client does not send prices.

**Body** (`CustomerOrderCreate`):

```json
{
  "restaurant_id": 7,
  "order_type": "dine_in",
  "restaurant_table_id": 3,
  "scheduled_for": null,
  "contact_name": null,
  "contact_phone": null,
  "items": [
    { "menu_item_id": 101, "quantity": 2, "note": "no onions" },
    { "menu_item_id": 105, "quantity": 1 }
  ]
}
```

Rules:

- `items` cannot be empty (422).
- For `dine_in`, `restaurant_table_id` is required, and the table must belong
  to the same restaurant (422 otherwise).
- For `pickup` / `delivery`, `restaurant_table_id` is ignored.
- Every `menu_item_id` must exist, be `active`, and belong to the restaurant.
- `contact_name` / `contact_phone` default to the customer's profile values.

**Response 201** (`CustomerOrderPublic`):

```json
{
  "id": 55,
  "restaurant_id": 7,
  "restaurant_table_id": 3,
  "order_type": "dine_in",
  "order_status": "created",
  "payment_status": "unpaid",
  "contact_name": "Jane Doe",
  "contact_phone": "+261340000000",
  "scheduled_for": null,
  "total_amount": 54000,
  "items": [
    { "id": 901, "menu_item_id": 101, "quantity": 2, "unit_price": 18000, "notes": "no onions" },
    { "id": 902, "menu_item_id": 105, "quantity": 1, "unit_price": 18000, "notes": null }
  ],
  "created_at": "..."
}
```

Side effect: a `new_order` WebSocket event is broadcast to the restaurant
channel (see §8).

### 6.2 GET `/customers/me/orders`

List the caller's orders, newest first.

**Query**

| Name     | Type | Default | Notes |
|----------|------|---------|-------|
| `status` | enum | —       | Filter by `OrderStatus` |
| `limit`  | int  | 50      | 1..100 |
| `offset` | int  | 0       | ≥0 |

### 6.3 GET `/customers/me/orders/{order_id}`

Single order. 404 if not yours.

### 6.4 PATCH `/customers/me/orders/{order_id}/cancel`

Cancel an order. Only allowed while the order is still `created` (staff
haven't started cooking). Already-cancelled orders are returned idempotently;
any other status returns 409 with a message telling the customer to contact
the restaurant. Broadcasts an `order_cancelled` WebSocket event on success.

---

## 7. Opening Hours Schema

Restaurants expose an `opening_hours` field (also used by `is_open_now` /
`next_opening` on §2.2). Shape:

```json
{
  "timezone": "Indian/Antananarivo",
  "periods": [
    {
      "day": 0,
      "slots": [
        { "open": "11:00", "close": "14:30" },
        { "open": "18:00", "close": "22:00" }
      ]
    },
    {
      "day": 5,
      "slots": [
        { "open": "09:00", "close": "15:00" },
        { "open": "17:00", "close": "23:00" }
      ]
    }
  ]
}
```

- `timezone` is any IANA zone name.
- `day` is `0 = Monday … 6 = Sunday`.
- Slots are in `HH:MM` 24-hour local time. `close` must be strictly greater
  than `open` (overnight slots are not supported).
- Omitting a day means closed.
- The server resolves `is_open_now` and `next_opening` using
  [app/services/opening_hours_service.py](app/services/opening_hours_service.py),
  so the client does not need to compute this itself for §2.2.

---

## 8. Real-time Updates — WebSocket — [app/routers/ws_connect.py](app/routers/ws_connect.py)

```
ws://<host>/ws/orders/{restaurant_id}
```

This WebSocket is currently scoped per-restaurant and is mainly consumed by
staff dashboards. The customer app can connect to receive the same broadcast
stream for a restaurant it is interacting with — useful for live order status
updates.

- Send `{"type": "ping"}` to receive `{"type": "pong"}`.
- Server pushes JSON messages such as:
  - `{ "type": "new_order", "order_id": …, "order": "...", "timestamp": "...", "message": "..." }`
  - `{ "type": "order_cancelled", "order_id": …, "order": "...", "timestamp": "...", "message": "..." }`

Note: this endpoint does not currently require auth and trusts the URL path.
If you need per-customer filtering, do it client-side from `order.customer_id`.

---

## 9. Misc Utility

### 9.1 GET `/languages` — [app/routers/languages.py](app/routers/languages.py)

Returns the list of supported language codes for translations.

```json
[ { "name": "French", "code": "fr" }, { "name": "English", "code": "en" } ]
```

### 9.2 GET `/language-codes`

Same list, just the codes.

### 9.3 GET `/health`

Liveness probe. Returns `{ "status": "ok" }`.

### 9.4 GET `/`

Returns `{ "message": "Hello Bigger Applications!" }`.

### 9.5 Static files

Uploaded media (logos, covers, menu item pictures, customer avatars) is served
under `/uploads/...`. Paths returned by the API are relative to the host —
prefix with the base URL on the client.

---

## 10. Auth Cheatsheet for the Mobile/Web Client

1. `POST /customers/register` **or** `POST /customers/login` → save
   `access_token`.
2. Send `Authorization: Bearer <access_token>` on every `/customers/me/*` call.
3. On `401 token expired`, log the user out and prompt re-login. (Refresh
   tokens are not implemented yet — token lifetime is controlled by
   `ACCESS_TOKEN_EXPIRE_MINUTES`.)
4. The same token works against every customer route — there is no separate
   scope per resource.

---

## 11. Endpoint Index

| Method | Path | Auth | Section |
|--------|------|------|---------|
| POST   | `/customers/register` | – | 1.1 |
| POST   | `/customers/login` | – | 1.2 |
| GET    | `/customers/me` | customer | 1.3 |
| PATCH  | `/customers/me` | customer | 1.4 |
| POST   | `/customers/me/password` | customer | 1.5 |
| DELETE | `/customers/me` | customer | 1.6 |
| GET    | `/public/restaurants/search` | – | 2.1 |
| GET    | `/public/restaurants/{id}` | – | 2.2 |
| GET    | `/public/restaurants/{id}/menus` | – | 2.3 |
| GET    | `/public/restaurants/{id}/categories` | – | 2.4 |
| GET    | `/public/restaurants/{id}/menu-items` | – | 2.5 |
| GET    | `/public/menu-items/{id}` | – | 2.6 |
| GET    | `/public/restaurants/{id}/reviews` | – | 2.7 |
| GET    | `/public/restaurants/{id}/reviews/summary` | – | 2.8 |
| GET    | `/customers/me/favorites` | customer | 3.1 |
| POST   | `/customers/me/favorites` | customer | 3.2 |
| DELETE | `/customers/me/favorites/{restaurant_id}` | customer | 3.3 |
| POST   | `/customers/me/reviews` | customer | 4.1 |
| GET    | `/customers/me/reviews` | customer | 4.2 |
| PATCH  | `/customers/me/reviews/{id}` | customer | 4.3 |
| DELETE | `/customers/me/reviews/{id}` | customer | 4.4 |
| POST   | `/customers/me/reservations` | customer | 5.1 |
| GET    | `/customers/me/reservations` | customer | 5.2 |
| GET    | `/customers/me/reservations/{id}` | customer | 5.3 |
| PATCH  | `/customers/me/reservations/{id}/cancel` | customer | 5.4 |
| POST   | `/customers/me/orders` | customer | 6.1 |
| GET    | `/customers/me/orders` | customer | 6.2 |
| GET    | `/customers/me/orders/{id}` | customer | 6.3 |
| PATCH  | `/customers/me/orders/{id}/cancel` | customer | 6.4 |
| WS     | `/ws/orders/{restaurant_id}` | – | 8 |
| GET    | `/languages` | – | 9.1 |
| GET    | `/language-codes` | – | 9.2 |
| GET    | `/health` | – | 9.3 |
| GET    | `/` | – | 9.4 |
