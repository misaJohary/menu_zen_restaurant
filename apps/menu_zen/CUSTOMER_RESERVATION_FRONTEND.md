# Customer Reservation — Frontend Implementation Guide

Companion to [CUSTOMER_RESERVATION_PLAN.md](CUSTOMER_RESERVATION_PLAN.md). The backend implements a **request-and-approve** model: the customer submits a reservation request, it lands in `waiting`, the restaurant owner accepts or refuses it from their dashboard. The backend does **no** capacity or opening-hours enforcement — the frontend owns that UX.

Two distinct surfaces:
- **Customer app** — customers browse a restaurant, request a reservation, see their request list, cancel if they change their mind.
- **Restaurant dashboard** — staff see incoming requests, accept or refuse them. Table binding is still done from the existing tables screen on arrival.

---

## 1. Domain types

Mirror these exactly — the backend will return / accept them verbatim.

```ts
// Status of a reservation REQUEST (customer-facing lifecycle)
export type ReservationStatus =
  | "waiting"
  | "accepted"
  | "refused"
  | "canceled";

// Status of a TABLE binding (set later by staff via PATCH /tables/{id}/status)
export type TableReservationStatus =
  | "active"
  | "honored"
  | "cancelled"   // note: double-l, distinct from reservation "canceled"
  | "no_show";

export interface TableAssignmentPublic {
  id: number;
  table_id: number;
  status: TableReservationStatus;
}

export interface RestaurantPublic {
  id: number;
  name: string;
  // ...other RestaurantBase fields (logo, cover, opening_hours, phone, email, city, lat, long, disabled, ...)
  opening_hours: OpeningHours | null;
}

export interface OpeningHours {
  timezone: string;                 // IANA, e.g. "Europe/Paris"
  periods: OpeningPeriod[];
}
export interface OpeningPeriod {
  day: number;                      // 0 = Monday ... 6 = Sunday
  slots: { open: string; close: string }[]; // "HH:MM"
}

export interface CustomerReservationPublic {
  id: number;
  reserved_at: string;              // ISO datetime
  status: ReservationStatus;
  party_size: number | null;
  note: string | null;
  created_at: string;
  restaurant: RestaurantPublic;
  assigned_tables: TableAssignmentPublic[];
}

export interface StaffReservationPublic {
  id: number;
  name: string;
  phone: string;
  reserved_at: string;
  status: ReservationStatus;
  party_size: number | null;
  note: string | null;
  customer_id: number | null;
  created_at: string;
  updated_at: string;
  assigned_tables: TableAssignmentPublic[];
}

export interface CustomerReservationCreate {
  restaurant_id: number;
  reserved_at: string;              // ISO datetime, MUST be strictly future
  phone: string;                    // see validation rules below
  party_size: number;               // 1..200
  note?: string;                    // max 500 chars
}
```

### `canceled` vs `cancelled`

Two enums, two spellings — not a typo:
- `ReservationStatus.canceled` — single `l` — the request was canceled by the customer.
- `TableReservationStatus.cancelled` — double `l` — a table binding was cancelled.

Keep these strings exact when comparing.

---

## 2. Endpoints

Base URL: same host as the rest of the API. Auth: all endpoints below require the relevant bearer token (customer JWT for `/customers/me/*`, staff JWT for `/restaurants/me/*`).

### Customer

| Method | Path | Notes |
| --- | --- | --- |
| `POST` | `/customers/me/reservations` | Body: `CustomerReservationCreate`. Returns `201` + `CustomerReservationPublic` with `status: "waiting"`. |
| `GET` | `/customers/me/reservations?status=&limit=&offset=` | `status` optional (filter by `waiting`/`accepted`/`refused`/`canceled`). `limit` 1..100 (default 50), `offset` >= 0. Returns array sorted by `reserved_at` desc. |
| `GET` | `/customers/me/reservations/{id}` | 404 if not owned by current customer. |
| `PATCH` | `/customers/me/reservations/{id}/cancel` | Allowed when status is `waiting` or `accepted`. Idempotent when already `canceled`. `409` when `refused`. |

### Restaurant (staff)

Requires the `reservations:manage` permission and a user attached to a restaurant. `403` otherwise.

| Method | Path | Notes |
| --- | --- | --- |
| `GET` | `/restaurants/me/reservations?status=&limit=&offset=` | **`status` defaults to `waiting`** (this is the inbox). Pass `status=accepted` etc. to switch tabs. |
| `PATCH` | `/restaurants/me/reservations/{id}/accept` | Only from `waiting` → `accepted`. `409` otherwise. |
| `PATCH` | `/restaurants/me/reservations/{id}/refuse` | Only from `waiting` → `refused`. `409` otherwise. |

> Removed in this revision: `GET /public/restaurants/{id}/availability` no longer exists. Don't call it.

---

## 3. Customer app — reservation request flow

### 3.1 Entry point — restaurant detail page

Add a **"Request a reservation"** CTA. On tap, push the request form.

### 3.2 The form

Fields (all required unless noted):

- **Date & time** (`reserved_at`)
  - Single date+time picker.
  - **Disable past dates/times** in the picker. The backend will reject anything `<= now` with `422`.
  - **Render — and softly restrict — to opening hours.** The backend does not enforce them. Read `restaurant.opening_hours` and:
    - Display the weekly schedule next to the picker.
    - Grey out / disable times outside any slot of the chosen weekday.
    - Use `opening_hours.timezone` to interpret slots; convert to the user's locale for display.
  - If `opening_hours` is `null`, allow any future time and show an "Opening hours not provided" note.
- **Party size** (`party_size`) — integer stepper, min 1, max 200.
- **Phone** (`phone`)
  - Pre-fill with the customer's profile phone if present.
  - Allowed characters: digits, space, `-`, `(`, `)`, `+`. Must contain at least 6 digits. Strip on blur, validate before submit.
  - The backend reconciles this with `customer.phone`: if the profile phone is empty, this value is written there; if it differs, it's stored only on the reservation and the profile is untouched. The user does not need to know this — just don't surprise them by mutating their profile silently in the UI.
- **Note** (`note`, optional) — multiline, max 500 chars, character counter.

### 3.3 Submit

- `POST /customers/me/reservations`.
- On `201`: navigate to the new reservation's detail page (or back to the list) and show a toast like _"Request sent — the restaurant will confirm shortly."_ Status will be `waiting`.
- Error handling:
  - `404` — restaurant missing or disabled. Surface as "This restaurant is no longer available."
  - `422` with `detail: "reserved_at must be in the future"` — re-open the picker.
  - `422` from Pydantic (phone/party_size validation) — surface field-level errors. Body shape is FastAPI's standard `{detail: [{loc, msg, type}, ...]}`.
  - `401` — token expired, re-auth.

### 3.4 "My reservations" screen

`GET /customers/me/reservations`.

- Tabs or filter chips: **Waiting · Accepted · Refused · Canceled** (or "All"). Hitting a tab re-fetches with `?status=`.
- Sort is already `reserved_at` desc from the server.
- Each card: restaurant name + logo, formatted date/time (use `restaurant.opening_hours.timezone` if present, else device tz), party size, status badge, note preview.
- Status badge colors (suggested): `waiting` amber, `accepted` green, `refused` red, `canceled` grey.
- Pagination: `limit=20&offset=…`, infinite scroll or pager.

### 3.5 Reservation detail

`GET /customers/me/reservations/{id}`.

- Show full info + the **Cancel** button when `status in {waiting, accepted}`.
- Cancel button: `PATCH …/cancel`. Confirm in a modal ("Cancel this reservation?"). On success, refresh the row.
- If the response indicates `409` (refused), hide the button and show a "This reservation was refused by the restaurant." note instead.
- If `assigned_tables` is non-empty (means staff already bound tables for an `accepted` reservation), show a small "Table(s) assigned" indicator. The customer doesn't need to act on it.

---

## 4. Restaurant dashboard — staff side

### 4.1 New menu entry — "Reservations"

Sits next to the existing Tables screen. Requires the `reservations:manage` permission; hide the menu entry if the current staff user lacks it.

### 4.2 Inbox view

`GET /restaurants/me/reservations` with no `status` query returns waiting requests by default.

- Tabs: **Pending (waiting) · Accepted · Refused · Canceled · All**.
- Pending tab should be the landing tab and visually prominent (badge with count if you want, computed from the response length on the current page or a separate count call later).
- Row content: customer name, phone (tap-to-call), party size, requested date/time (in restaurant timezone — use the restaurant's `opening_hours.timezone`), note, created_at relative ("2h ago"), status badge.
- Two primary actions inline on the pending tab: **Accept** and **Refuse** (icon buttons + confirm).
- Sort is `reserved_at` desc from the server.

### 4.3 Accept / Refuse

- **Accept**: `PATCH /restaurants/me/reservations/{id}/accept`. On success, row moves to the Accepted tab; refresh both tab counts.
- **Refuse**: `PATCH /restaurants/me/reservations/{id}/refuse`. Same flow; consider a confirmation modal because it's terminal for the request.
- Error handling:
  - `409` — someone (probably another staff member) already changed the status. Refetch the row, surface "This request was already updated."
  - `403` — the user lost permission or isn't attached to a restaurant. Send to an unauthorized screen.
  - `404` — the reservation was deleted or never belonged to this restaurant.

### 4.4 No table binding here

Accepting a request does **not** bind a table. When the guest arrives, staff still go to the **Tables** screen and use the existing `PATCH /tables/{id}/status` flow to attach a `TableReservation`. The reservation's `assigned_tables` array will populate from there. Mention this once in onboarding tooltip if helpful, but don't duplicate the table flow on this screen.

### 4.5 Notifications

The backend already fires an email to `restaurant.email` on every new request (via fastapi-mail + background task). The dashboard doesn't need polling for v1 — a simple "Refresh" button on the inbox is fine. If you want fancier UX, poll `GET /restaurants/me/reservations?status=waiting` every 30–60s while the inbox is open and diff against the local set to flash new arrivals.

---

## 5. Cross-cutting concerns

### 5.1 Timezones

`reserved_at` is sent / received as ISO 8601. The backend stores and returns UTC where possible; treat any naive datetime in a response as UTC. **Always display in the restaurant's timezone** (`restaurant.opening_hours?.timezone`) when one exists — that's the booking's reference clock. Fall back to the device timezone only when the restaurant has none.

When the customer picks a time, build the ISO string in the restaurant's timezone, then submit. Don't send the device-local time blindly — a customer in Tokyo booking a Paris restaurant must see and submit Paris time.

### 5.2 Permissions

- Customer endpoints require the customer auth token (separate from staff JWT).
- Staff endpoints require `reservations:manage`. Read the permission set from the existing `/users/me` (or whichever current call returns user permissions) and gate the menu entry + buttons accordingly.

### 5.3 Error surface

FastAPI returns either `{ "detail": "string" }` or `{ "detail": [ {loc, msg, type}, ... ] }` (Pydantic field errors). Build one error parser used across all reservation calls.

### 5.4 Optimistic updates

Safe to do for cancel/accept/refuse — the only failure modes are `409` (already in a terminal state) or `403/404`. On error, revert and refetch.

---

## 6. State machine reference

```
            customer creates
                  │
                  ▼
              ┌────────┐
              │waiting │
              └───┬────┘
       staff      │      staff      customer
       accept     │      refuse     cancel
         ┌───────┴───────┐        ┌──────────┐
         ▼               ▼        ▼
     ┌────────┐     ┌────────┐   ┌────────┐
     │accepted│     │refused │   │canceled│
     └───┬────┘     └────────┘   └────────┘
         │ customer cancel
         ▼
     ┌────────┐
     │canceled│
     └────────┘
```

Terminal states: `refused`, `canceled`. `accepted` can still go to `canceled` (by the customer); it cannot go to `refused`.

Table-binding lifecycle (`TableReservationStatus`) is independent and managed via the existing tables screen — it does not change the parent `Reservation.status`.

---

## 7. Out of scope (for parity with backend plan)

- No availability endpoint to call — opening-hours rendering is purely a client concern using `restaurant.opening_hours`.
- No SMS / phone verification.
- No automatic table assignment on accept.
- No real-time push for staff (v1 = email + manual refresh / optional polling).

---

## 8. Suggested implementation order

1. Types + API client wrappers for all 7 endpoints.
2. Customer "Request a reservation" form (with the opening-hours-aware picker — this is the biggest piece of UI work).
3. Customer "My reservations" list + detail + cancel.
4. Staff inbox (waiting tab) + accept/refuse.
5. Staff tabs for accepted/refused/canceled + filtering.
6. Polish: timezone display, error toasts, empty states, loading skeletons.
