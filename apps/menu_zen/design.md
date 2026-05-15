# Menu Zen — Customer App Design

> Working title: **Menu Zen Customer** (`apps/menu_zen_customer`)
> Status: design proposal, v0.1 — 2026-05-07
> Audience: diners discovering, reserving, and ordering from registered
> Menu Zen restaurants.

---

## 1. Vision

**A pocket concierge for the next meal.**
Menu Zen Customer is not a food-delivery app with a reservation tab bolted on,
and not a reservation app with a menu attached. It is a single, calm surface
for the question *"where do I eat tonight?"* — answered with proximity, taste,
and trust.

The app already inherits a real backend: a rich `domain` model
(restaurants, menus, menu items with translations, kitchens, reservations,
tables, orders). The customer app is the missing third client that turns that
backend into a marketplace.

### Positioning, in one sentence

> Yelp's discovery × OpenTable's booking × DoorDash's ordering — but quiet,
> editorial, and built for the diner, not the platform.

### Three product principles

1. **Decide in 30 seconds.** The home screen must let an indecisive user pick
   a restaurant in under half a minute. Discovery is the product.
2. **One restaurant, two intents.** From any restaurant page, *Reserve* and
   *Order delivery* are equally one tap away. We never make the user re-pick.
3. **Show food, not chrome.** Imagery is the UI. Cards breathe. Text is
   editorial. Controls disappear until needed.

---

## 2. Personas & primary journeys

| Persona | Primary need | Critical journey |
|---|---|---|
| **Léa, 28, urbanite** | "Somewhere new, walking distance, tonight." | Open app → Near you → tap → Reserve 8pm × 2 |
| **Antoine, 41, parent** | "Family-friendly, kids menu, delivery in 40 min." | Open app → filter Family → Order delivery |
| **Hira, 34, traveller** | "Best in this city, no idea where I am." | Open app → Popular this week → save 3 to favorites |
| **Régulier**, returning | "My usual, faster than last time." | Open app → Recents → reorder previous cart |

Each journey defines a tier of the home screen (see §6.1).

---

## 3. Brand & visual language

### 3.1 Mood: "Ember & Linen"

Warm, editorial, restrained. Think: a candle on a linen tablecloth, not a
neon menu board. The interface should feel like *reading* a good restaurant
guide, with the speed of a modern app.

### 3.2 Color tokens

Defined in `packages/design_system` as `AppColors.*`. Light theme below;
dark theme inverts surface/ink and shifts terracotta to a warmer ember.

| Token | Hex (light) | Role | Coverage |
|---|---|---|---|
| `surface.canvas` | `#F7F2EC` | App background, "linen" | 60% |
| `surface.card` | `#FFFFFF` | Cards, sheets | — |
| `ink.primary` | `#1A1714` | Body text, icons | 30% |
| `ink.muted` | `#6B6258` | Secondary text, captions | — |
| `brand.terracotta` | `#C2461E` | Primary actions, "Reserve", "Order" | 10% |
| `brand.ember` | `#E07A3B` | Accent, highlights, badges | — |
| `accent.sage` | `#7A8B6F` | Success, "Open now", confirmations | — |
| `accent.bordeaux` | `#5C1A1B` | Promotion, "Chef's pick" labels | — |
| `signal.warning` | `#D4A24C` | Slow kitchen, low availability | — |
| `signal.error` | `#A8261C` | Hard errors, allergens | — |

The 60-30-10 rule from `CLAUDE.md` is respected: linen canvas (60%),
ink + cards (30%), terracotta + ember accents (10%).

### 3.3 Typography

Two families, no more (per `CLAUDE.md`):

- **Display / editorial**: `Fraunces` (variable, optical sizing) — used for
  restaurant names, hero headlines, menu section titles. Gives the magazine
  feel.
- **UI / body**: `Inter` — used for everything else.

Scale (mobile, 14pt base):

| Style | Family | Size / line-height | Use |
|---|---|---|---|
| `display.xl` | Fraunces 600 | 32 / 38 | Restaurant detail hero |
| `display.l` | Fraunces 500 | 24 / 30 | Section headers ("Near you") |
| `title.m` | Inter 600 | 18 / 24 | Card titles, page titles |
| `body.l` | Inter 400 | 16 / 24 | Body text |
| `body.m` | Inter 400 | 14 / 20 | Default UI |
| `caption` | Inter 500 | 12 / 16 | Distance, ETA, meta |
| `mono.price` | Inter 600 tabular | 16 / 20 | Prices, totals |

### 3.4 Spacing, radii, elevation

- Spacing scale (4-pt base): `2, 4, 8, 12, 16, 20, 24, 32, 40, 56, 80`.
- Radii: `r.sm = 8`, `r.md = 14`, `r.lg = 20`, `r.xl = 28`, `r.pill = 999`.
- Elevation: we avoid Material drop shadows. Cards use a 1-px hairline
  (`ink.primary @ 8%`) plus a soft, large-y shadow for hero cards only.
- Default card radius is `r.lg`. The hero photo uses `r.xl`. Pills are pill.

### 3.5 Imagery rules

- Restaurant covers: 16:9 minimum, served at 2x, lazy-loaded, blurhash
  placeholder while decoding.
- Menu items: 1:1, never letterboxed; if missing, fall back to a
  type-only "letter card" using the dish initial and a category color.
- No stock photos in fallbacks. A typographic placeholder always beats a
  generic plate-of-pasta image.

### 3.6 Iconography

Phosphor icons (regular weight 1.5px stroke). Custom glyphs only for:
booking confirmed (knife-and-fork in a circle), delivery rider, the
"Chef's pick" laurel.

---

## 4. Motion language

Motion is restrained but consistent. Three timings, three curves:

| Token | Duration | Curve | Use |
|---|---|---|---|
| `motion.tap` | 120 ms | `easeOut` | Pressed states, chip selection |
| `motion.transition` | 280 ms | `easeOutQuint` | Sheet, page, hero transitions |
| `motion.ambient` | 600 ms | `easeInOutCubic` | Background photos, parallax |

Signature moments:

- **Hero transition** from restaurant card to detail page (Flutter `Hero`
  on the cover image).
- **Parallax** on the detail hero — 0.5× scroll factor.
- **Sticky CTA reveal** — `Reserve` / `Order` bar fades in once the user
  scrolls past the hero.
- **Heart-favorite** — spring scale + 6-particle confetti, only on add.
- **Pull to refresh** — custom "steam rising from a cup" indicator instead
  of the default Cupertino spinner.

If `MediaQuery.disableAnimations` is true, all of the above collapse to
opacity-only crossfades.

---

## 5. Information architecture

```
[Bottom Nav, 4 tabs]
├── Discover    (home)
├── Search      (map + filters)
├── Bookings    (reservations + orders, segmented)
└── Profile

[Modal flows, full-screen]
├── Restaurant detail        ← hero from a card
├── Menu item sheet          ← bottom sheet from menu list
├── Reservation wizard       ← from "Reserve" CTA
├── Cart & Checkout          ← from "Order" CTA
└── Order tracking           ← from a confirmed order
```

Why 4 tabs and not 5: a "Favorites" tab is tempting but redundant —
favorites live inside *Discover* (a collection at the top) and inside
*Profile*. We don't make a tab for a list that's empty 80% of the time.

---

## 6. Screen-by-screen

### 6.1 Discover (home)

Three layered tiers, each answering a different mental state:

1. **"Where am I?"** — sticky top: location chip + greeting + search shortcut.
2. **"What am I in the mood for?"** — horizontal mood rail (chips).
3. **Three editorial rails** — Near you · Trending this week · Picked for you.

```
┌──────────────────────────────────────────┐
│  Bonjour, Léa                Antananarivo│   greeting + city
│  ┌────────────────────────────────────┐  │
│  │  Search dishes, places…   [filter]│  │   search field (tap → Search tab)
│  └────────────────────────────────────┘  │
│  ╭─Tonight─╮ ╭─Quick lunch─╮ ╭─Veggie─╮  │   mood chips (horizontal scroll)
│                                          │
│  Near you                       See all →│   editorial section header
│  ┌────────┐ ┌────────┐ ┌────────┐        │
│  │ cover  │ │ cover  │ │ cover  │        │   wide cards, 1.4 visible
│  │ Anjara │ │ La Var…│ │ Sakafo │        │
│  │ 0.3 km · ★4.7 · $$                    │
│  └────────┘ └────────┘ └────────┘        │
│                                          │
│  Trending this week             See all →│
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐     │   compact cards, 2.5 visible
│                                          │
│  Picked for you                 See all →│
│  ┌──────────────────────────────────┐    │   one large editorial card
│  │  hero cover                       │    │   "Tonight, try…" + reason
│  │  Le Comptoir des Saveurs          │    │
│  │  Because you liked Sakafo & Mai…  │    │
│  └──────────────────────────────────┘    │
│                                          │
│  Cuisines                                │   2-col grid of icon tiles
└──────────────────────────────────────────┘
```

**Card anatomy** (Near you variant):

- 16:9 cover with rounded `r.lg` corners
- Status pill bottom-left of cover: `Open · Closes 22h` or `Closed`
- Heart top-right
- Below cover: name (Fraunces 18), then a single meta line:
  `0.3 km · ★ 4.7 · $$ · French`

**Distance source**: device GPS via `geolocator`. If permission denied, we
substitute the city the user picked at onboarding and hide all distance
chips. Never show "0 km" or "—".

**Recommendation source**: backend ranks "Picked for you" by a mix of
favorited cuisines, prior orders, prior reservations, and city. Until the
user has any history (cold start), we substitute "New on Menu Zen".

### 6.2 Search (map + list)

A two-mode screen. Top has a segmented control: **List** | **Map**.

- List mode: same card style as Discover, infinite scroll, sort menu
  (Distance / Rating / Popular).
- Map mode: cluster pins, bottom sheet (peek 24%, expand 70%) holding
  the result list. Pin tap centers the map and scrolls the sheet to that
  card. Swipe the sheet horizontally and the map pans to follow. We use
  `flutter_map` (OSM tiles) — no Google Maps SDK lock-in.

**Filter sheet** (slides up):

- Cuisine (multi-select)
- Price `$ · $$ · $$$ · $$$$`
- Open now / Open at <time>
- Distance slider (0.2 – 10 km)
- Capabilities: `Accepts reservations`, `Delivers`, `Takeaway`
- Dietary: `Vegetarian`, `Halal`, `Vegan`, `Gluten-free`

Filters apply with a single "Show 24 places" sticky button at the bottom of
the sheet — never on chip-tap, to avoid jank.

### 6.3 Restaurant detail

```
┌──────────────────────────────────────────┐
│ [parallax cover, 280pt]      ♡ ⤴︎ ⋯     │   hero with back/share/heart
│                                          │
│  Anjara                                  │   Fraunces 32
│  Malagasy · $$ · 0.3 km · ★ 4.7 (212)   │
│  Open · Closes at 22h                    │
│                                          │
│  ┌──────────────────────────────────┐    │
│  │ Menu  Reserve  Reviews  About    │    │   sticky tab bar after scroll
│  └──────────────────────────────────┘    │
│                                          │
│  [tab content]                           │
│                                          │
│ ───────────────────────────────────────  │
│ ┌─────────────┐  ┌──────────────────┐    │   sticky bottom bar
│ │  Reserve    │  │  Order delivery  │    │
│ └─────────────┘  └──────────────────┘    │
└──────────────────────────────────────────┘
```

Tabs:

- **Menu** — sectioned by `CategoryEntity` from the existing
  `MenuItemEntity.category`. Each item is a row: thumbnail · name ·
  description (2-line clamp) · price. Tap → bottom sheet.
- **Reserve** — inline date strip (next 14 days) + party size stepper +
  available time slots. CTA opens reservation confirmation.
- **Reviews** — average breakdown (food / service / ambience), then
  the reviews list. Reviews are read-only at v1; writing reviews is v2.
- **About** — address with a small map snippet, phone, opening hours,
  social media links, languages spoken.

**Menu item bottom sheet**:

- Large image (4:3)
- Name, description, price
- Allergens & dietary tags (chips)
- Quantity stepper
- "Add to cart — Ar 18 000" CTA

If the restaurant doesn't deliver, the CTA becomes "Save to wishlist" and
the reservation tab carries the conversion.

### 6.4 Reservation wizard

Three steps, one screen each, with a top progress dotted line.

1. **When & how many** — calendar (next 60 days), time grid for the chosen
   day, party-size stepper. Slots are loaded per-day from the backend.
2. **Who** — name, phone, optional notes ("anniversary", "wheelchair
   access"). Pre-filled from profile.
3. **Confirm** — restaurant card + summary + Reserve button.

Confirmation screen shows a circular sage check, the booking details, a QR
code (for the host), and CTAs: *Add to calendar* and *Get directions*.

State machine for a reservation maps to the existing `ReservationStatus`
enum from `domain`: `pending → confirmed → seated → completed`,
plus `cancelled` / `no_show`. The customer can cancel up to N hours before
(restaurant policy).

### 6.5 Cart & Checkout

```
┌──────────────────────────────────────────┐
│  Your order from Anjara                  │
│                                          │
│  ┌────────────────────────────────────┐  │
│  │ 2 × Romazava               36 000 │  │
│  │ 1 × Mofo akondro           4 000  │  │
│  └────────────────────────────────────┘  │
│  + Add another item                      │
│                                          │
│  Deliver to                              │
│  ┌────────────────────────────────────┐  │
│  │ Home · 12 Lalana Rainandriamampandry│  │
│  └────────────────────────────────────┘  │
│  Delivery in ~ 35 min · Ar 3 000         │
│                                          │
│  Payment                                 │
│  ┌────────────────────────────────────┐  │
│  │  Cash on delivery                  │  │
│  │  Mobile money (MVola, Orange…)     │  │
│  │  Card                              │  │
│  └────────────────────────────────────┘  │
│                                          │
│  Subtotal               Ar 40 000        │
│  Delivery                Ar 3 000        │
│  ──────────────────────────────────      │
│  Total                  Ar 43 000        │
│                                          │
│  [   Place order   ]                     │
└──────────────────────────────────────────┘
```

Cart is **single-restaurant**: starting an order at a second restaurant
prompts to discard the first cart. This keeps order math, fees, and ETAs
sane (industry standard).

### 6.6 Order tracking

Live status timeline driven by the backend's existing order events
(WebSocket, the same channel used by the staff app):

```
●───────●───────●───────○───────○
Confirmed Preparing Out    Arriving  Delivered
```

Each node has its own copy and an estimated time. We show a map only when
status is `out_for_delivery`, with the rider's position. Until then we
show a kitchen illustration with subtle animated steam.

### 6.7 Bookings

One screen, one segmented control: **Upcoming · Past**. Both reservations
and delivery orders appear in the same chronological list, distinguished
by an icon (knife-and-fork vs. shopping bag). Tap → detail view, which
either re-opens the reservation confirmation or the order tracking.

### 6.8 Profile

Sections: My favorites · Addresses · Payment methods · Language · Dietary
preferences · Notifications · Help · Sign out.

Language selection writes to `domain` `LanguageEntity` and immediately
re-renders translated content via the existing `MenuItemTranslation`
infrastructure.

### 6.9 Onboarding & auth

Three swipeable cards on first launch (skippable):

1. *Discover* — hero photo, "Find places worth your appetite."
2. *Reserve* — "Hold a table in three taps."
3. *Deliver* — "Or stay in. We'll bring it."

Then auth: phone-OTP first (most reliable in target markets), Google
sign-in second, email/password third. Guests can browse Discover without
auth; auth is required only at the moment of reservation or checkout.

---

## 7. Empty, loading, and error states

A real product is the empty states. Every list defines all four:

| State | Treatment |
|---|---|
| **Loading** | Skeletonizer (already in `pubspec.yaml`) — never spinners on lists. |
| **Empty (cold)** | Editorial illustration + one action. e.g. "No places match these filters. *Loosen filters →*" |
| **Empty (after action)** | Friendly: "Your favorites live here. Tap ♡ on a place you love." |
| **Error** | Inline retry. Network errors say "We couldn't reach the kitchen." with a retry chip. |
| **Offline** | A banner under the app bar: "You're offline — showing your last view." Cached lists remain readable. |

Special states worth designing now:

- **Location denied** — Discover swaps "Near you" for "Browse by city".
- **Restaurant offline / closed** — detail page disables the order CTA, the
  reserve CTA stays active for future dates.
- **Item out of stock mid-cart** — soft warning when checkout is tapped,
  not silently dropped.
- **Payment fails** — order is preserved, we don't dump the cart.

---

## 8. Accessibility

Hard requirements (also stated in `CLAUDE.md`):

- Contrast ≥ 4.5:1 (normal) / 3:1 (large). All brand pairings above pass.
- Dynamic type up to 200%. Cards reflow vertically rather than truncating.
- All interactive widgets wrapped in `Semantics` with role + label.
- Reduce-motion mode honored (see §4).
- Tap targets ≥ 44 × 44 logical pixels.
- Color is never the only signal: status pills also use shape + text.
- Screen-reader walkthrough tested on iOS VoiceOver and Android TalkBack
  before each release.

---

## 9. Internationalization

The backend already speaks multiple languages
(`MenuItemTranslation`, `LanguageEntity`). The customer app must:

- Detect the device locale on first launch, fall back to the restaurant's
  default language when a translation is missing for an item.
- Show the language picker in onboarding *and* in profile.
- Format prices with `intl` `NumberFormat.currency` from the restaurant's
  currency, not the device's.
- Format times in the restaurant's timezone for reservations.

Initial supported languages: French, Malagasy, English. RTL is out of
scope for v1 but the layout doesn't preclude it.

---

## 10. Technical foundation

This section is intentionally short — it sketches the architecture so the
implementation plan can refine it. Full Clean Architecture / BLoC rules
come from `CLAUDE.md`.

### 10.1 Where the app lives

```
apps/
└── menu_zen_customer/
    ├── pubspec.yaml          # depends on domain, data, design_system
    ├── lib/
    │   ├── main.dart
    │   ├── app.dart
    │   ├── core/{di,error,utils,router}/
    │   └── presentation/
    │       ├── pages/{discover,search,restaurant,menu,reservation,
    │       │         order,bookings,profile,auth,onboarding}/
    │       ├── bloc/<feature>/  # one cubit/bloc per feature
    │       └── widgets/         # cross-feature widgets
    └── assets/                  # illustrations, lottie, fonts
```

### 10.2 What we add to shared packages

Net-new entities (in `packages/domain/lib/entities/`):

- `address_entity.dart` — saved customer addresses
- `cart_entity.dart`, `cart_item_entity.dart`
- `delivery_order_entity.dart` (if not already covered by `OrderEntity`)
- `review_entity.dart`
- `availability_slot_entity.dart` — reservation time slots
- `customer_entity.dart` — distinct from staff `UserEntity`

Net-new repositories (in `packages/domain/lib/repositories/`):

- `discovery_repository.dart` — `nearestRestaurants`, `popular`,
  `recommended`, `searchRestaurants`
- `reservations_repository.dart` (customer-side; the existing
  `ReservationEntity` is reused)
- `delivery_repository.dart`
- `reviews_repository.dart`
- `addresses_repository.dart`
- `geolocation_repository.dart` (thin wrapper over `geolocator`)

Their `data` implementations follow the same pattern as the existing
ones.

### 10.3 What we add to `design_system`

- `AppColors`, `AppTypography`, `AppSpacing`, `AppRadii`, `AppMotion`
  tokens (some already exist — extended where needed).
- Shared widgets: `RestaurantCard` (3 variants), `MenuItemTile`,
  `MenuItemSheet`, `TimeSlotPill`, `PartySizeStepper`,
  `DeliveryStatusTimeline`, `MoodChip`, `EmptyState`, `SteamLoader`.

### 10.4 BLoC inventory (per-feature)

| Feature | Cubit/BLoC | Reason |
|---|---|---|
| Discover | `DiscoverCubit` | Linear: load 3 rails, refresh. |
| Search | `SearchBloc` | Multi-event: query, filter changed, mode toggled. |
| Restaurant detail | `RestaurantDetailCubit` | One restaurant in / one state out. |
| Menu cart | `CartCubit` | App-scoped; survives navigation. |
| Reservation wizard | `ReservationBloc` | Multi-step events. |
| Order tracking | `OrderTrackingBloc` | Stream-driven via WebSocket. |
| Auth | `AuthBloc` | Existing pattern from mobile/tablet apps. |
| Profile | `ProfileCubit` | Linear. |

### 10.5 New third-party packages

Beyond what's already in `menu_zen_mobile`'s `pubspec.yaml`:

- `geolocator` — device location
- `flutter_map` + `latlong2` — OSM map (no Google Maps SDK)
- `flutter_blurhash` — image placeholders
- `lottie` — onboarding illustrations
- `qr_flutter` — reservation QR
- `flutter_svg` — illustration assets
- `flutter_animate` — micro-interactions (favorite spring, etc.)

### 10.6 Routing

`go_router`, declarative tree:

```
/onboarding
/auth/{phone|otp|email}
/  (shell with bottom nav)
   /discover
   /search
   /bookings
   /profile
/restaurant/:id        (modal-style page)
   /menu/:itemId       (bottom sheet, sub-route)
   /reserve            (wizard)
   /order              (cart → checkout)
/order/:id/track       (live tracking)
/booking/:id           (reservation detail)
```

`redirect` enforces auth on `/reserve`, `/order`, `/order/*`, `/bookings`,
`/profile`. Discover, Search, and any restaurant detail are public.

---

## 11. What we are deliberately NOT doing in v1

To keep the first ship credible:

- No social feed, no following users.
- No in-app reviews authoring (read-only at v1).
- No group ordering / split bills.
- No loyalty points or referral programs.
- No table-side QR ordering (that's the staff/tablet domain).
- No web/desktop builds (mobile only — flagged for later because the
  `domain` and `design_system` are platform-agnostic).

Each is a deliberate cut, not an oversight. They become a v2 backlog.

---

## 12. Open questions for the next session

These should be resolved before the implementation plan is finalized:

1. **App name** — "Menu Zen Customer" is a placeholder. Better candidates:
   *Menu Zen*, *Zen Table*, *Zen*, *Saveur*. User to decide; the directory
   name follows.
2. **Geographic scope at launch** — Antananarivo only, or all cities the
   restaurants register in? Affects the city-picker design.
3. **Auth provider** — does the existing backend already issue customer
   tokens, or do we need a new identity service? The staff apps use JWT;
   we likely reuse the same shape with a `customer` role.
4. **Payments** — which providers? MVola, Orange Money, Airtel Money, and
   Stripe for cards are the natural choices in the target market. The
   checkout sheet's options list is parameterized on this answer.
5. **Recommendation engine** — purely backend, or do we need a small
   client-side model? v1 should be backend-only; we just consume a
   ranked list.
6. **Reviews** — write at v1 or v2? Shifts the scope by ~1 sprint.
7. **Map provider** — confirm OSM is acceptable (no contractual obligation
   to use Google Maps from the existing apps).

---

## 13. What "done" looks like for this design phase

- [ ] User signs off on the brand mood (Ember & Linen) or asks for a
      variant, and on the typographic pair.
- [ ] User confirms the four-tab IA and the cut list in §11.
- [ ] Open questions in §12 are answered.
- [ ] We produce a Figma file (or equivalent) for the eight pivot screens
      from §6 in light + dark + reduce-motion.
- [ ] We produce a separate `plan.md` translating this design into a
      sequenced implementation plan against the existing monorepo.

Then we build.
