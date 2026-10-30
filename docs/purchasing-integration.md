# Customer purchasing — integration notes (Hala)

Printing, cart, checkout, transfer payment and library offers.
API: `https://masar.toldpath.com/api`, config version observed: **8** (read from
`GET /v1/app/config`, never sent as a header).

## Running

```bash
flutter run \
  --dart-define=SATR_PROJECT_KEY=<pk_test_… from the team environment file> \
  --dart-define=SATR_DEV_MEMBER=<your dev handle>
```

Optional: `SATR_BASE_URL` (host only; `/api` is appended once),
`SATR_LOCALE=en`, `SATR_PICKUP_LAT/LNG/LABEL/DETAILS`.
Development hub (debug builds, or `SATR_DEV_TOOLS=true`):
`--dart-define=SATR_INITIAL_ROUTE=/dev/purchasing` (or the Android Studio run
configuration *Satr purchasing (dev)*, reading the git-ignored `config/dev.json`).
Temporary entry points until login, catalog, addresses and orders exist: phone +
code sign-in, the live catalog with options, your addresses (plus a form for
one you type in), and your orders with Offer/Payment buttons. No made-up data and
no operator tools; it is never registered otherwise.

## Contracts with other features

| From → to | Contract |
|---|---|
| Catalog / AI → cart (Mohammed, Kamal) | `Get.find<CartController>().addProduct(CartItemRequest(productId:, quantity:, options: {key: [choiceKey]}, note:))`. Same product + same options merges quantity. Never pass prices. Register with `CartBinding.ensureCart()`. |
| Addresses → checkout (Mohammed) | Checkout reads `GET /v1/addresses` (read-only adapter). "Add address" opens `CustomerRoutes.addressForm`; return the saved address id with `Get.back(result: id)` and checkout selects it. |
| Checkout → orders (Eman) | After a confirmed `201`, checkout opens `CustomerRoutes.orderDetails` (cash) with `arguments: {'order_id': id}` (`RouteArgs.order(id)`). Uncertain results route to `CustomerRoutes.orders`. |
| Orders / correction → payment (Eman) | Open `CustomerRoutes.payment` with `{'order_id': id}`. The screen refreshes the order itself and allows a receipt only in `awaiting_payment` for a `bank_transfer` order. |
| Orders → library offer (Eman) | Open `CustomerRoutes.offer` with `{'order_id': id}` when the order is `priced`. |

## Shared code added (Kamal please review)

- `core/config/app_env.dart`, `core/config/remote_config*.dart` — env + typed `/app/config`.
- `core/network/api_client.dart` — the single Dio client (project key, locale, bearer; no `X-Config-Version`, no automatic retries). `idempotency.dart`.
- `core/storage/session_store.dart` — token/user + `SessionGuard` to drop responses from a previous session.
- `core/uploads/*` — `POST /v1/uploads` with progress/cancel, content sniffing, file picker abstraction.
- `core/errors/*` — 422 no longer collapses into form validation; `details`, `reason`, `retry_after` preserved; `transformTimeout` no longer throws; `CancelledFailure`.
- `core/utils/money.dart` — integer minor units, server `formatted` first.
- `core/widgets/purchase_widgets.dart`, `app/bindings/app_binding.dart` (wired in `main.dart`).

## Verified against the sandbox (pk_test, fictional users)

- Config: 200 with `X-Project-Key` only; `config_version` 8. Printing prices are **per printed side**; binding is charged **per copy**; duplex discount 0.
- Uploads: content is sniffed (text named `.pdf` → 422; PNG named `.pdf` accepted as image); images re-encoded to `image/webp`, `pages: null`; PDFs return `pages`; >10240 KB → 422 (server takes ~24 s, so the app checks size first); unknown `purpose` values are accepted — always send `print_file` / `payment_receipt`. An upload can be attached once.
- Quote: `pickup` is **required** even for catalog carts (products have no vendor). Required options, invalid choices, `out_of_stock {product_id, available}`, `max_qty` 99, `max_copies` 500, page ranges (`"All"` rejected — omit for all pages), `out_of_zone`, another user's address (404), unknown fields, phone pattern all verified. Server does **not** check `order_type` against contents and **accepts an empty cart** — the app enforces both. Client prices are ignored. `cash_on_delivery`/`cash`/omitted → `cash`. Quotes expire after 600 s → `410 quote_expired`.
- Orders: same `Idempotency-Key` + body → same order; same quote with a new key → `410 quote_used`; same key, different body → `409 idempotency_mismatch`; extra `fields` at order time → `409 conflict / quote_payload_mismatch` (fields belong in the quote; `note` is order-only).
- Every order (fixed-price too) starts at `awaiting_pricing`: library offer → approve → `pending` → `awaiting_payment` (transfer) → receipt → `payment_review` → operator → `preparing/paid`. Reject → `cancelled`.
- Receipts: cash order → `409 not_a_transfer_order`; wrong state or a second receipt during review → `422 invalid_transition` with `details.allowed`; same key replay → same 200.
- Offers: before pricing `404 no_offer_yet`; after a decision `422 invalid_transition / no_open_offer`; approve replay with same key → same 200.
- Rate limit: ~30 requests/min → `429` with `retry_after`.

## Not verified / open

- Payment **correction** (`payment_review_note` → back to `awaiting_payment`): the sandbox helper only approves; built from the documented contract.
- `409 offer_expired` (60-minute TTL not reached) and offers with real substitutions (sandbox offers had none).
- Pickup point source: no server field exists; defaults to the training collection's point. **Needs a decision from Kamal / the API owner.**
- `fields.order_item` in config uses transliterated enums (`abyd_oasod_black_and_white`…) and no thermal binding, but the quote endpoint only accepts `modules_config.printing` values (`bw`, `single`, `thermal`…). The app uses `modules_config.printing`.
- Supplied `fixtures/document.pdf` is structurally malformed (no xref); the server still accepts it.
