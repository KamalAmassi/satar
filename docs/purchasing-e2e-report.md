# SATR purchasing: end-to-end test report

- **Branch:** `feature/hala-customer-purchasing` (committed in five phases: foundation, cart and printing, checkout, offers and payment, dev tools and docs).
- **Overall:** the complete end-to-end purchase flow does **not** pass through normal actions. The transfer journey stops at `pending` (B1), and cash orders have no next step (B2); see "Blocked".
- **Device:** Redmi 8 "olive", Android 10, 720×1520 (360 dp wide). Profile builds, purchasing dev hub as the entry point (the teammate login, catalog, address and order screens do not exist yet).
- **API:** sandbox `https://masar.toldpath.com/api/v1`, config v8.
- **Dashboard:** `https://masar.toldpath.com/p/satr`, the same sandbox project.
- **Dates:** 30 Oct 2026.
- **Screenshots:** `docs/e2e-screenshots/`, 14 images. Cropped below the status bar. No account details, receiving-account data, personal files or notifications.

## How to read the results

| Category | Meaning |
|---|---|
| **Passed live** | On the phone against the sandbox, using normal customer actions and normal dashboard actions only |
| **Passed (controlled)** | Automated tests in `test/` with fakes. Used where a live trigger is unsafe or impractical |
| **Passed after a forced transition** | Correct behaviour, but the order reached that state through the dashboard support override "فرض حالة". **Not a normal-flow pass.** |
| **Blocked** | Cannot be done through normal actions because of a backend or dashboard gap |
| **Not tested** | Not exercised live or in a test |

## Orders used

| Order | Payment | Purpose | State now |
|---|---|---|---|
| STR-000023 (#73) | cash | Scenario A, double tap, changed price | `pending` 43.00. Cash has no next step (B2) |
| STR-000024 (#74) | cash | Scenarios B and C, reject | `cancelled` |
| STR-000025 (#75) | transfer | first stale-offer bug, correction loop | `preparing`, paid. **`pending → awaiting_payment` was forced** |
| STR-000026 (#76) | transfer | payment-method fix, stale-offer retest, normal accept | `pending` 42.00. **Blocked (B1)** |
| STR-000027 (#77) | cash | English pass, Back after created | `awaiting_pricing` 31.00 (left unpriced) |

STR-000020 to 022 were not touched. No order was deleted, no sandbox reset was made, no dashboard configuration was changed, and the dashboard simulators were not used.

## 1. Passed live

**Products, cart, checkout**
- **Mixed print + product order (STR-000023).**
  - Independent per-file specs and page ranges.
  - Quote 41.00, then 46.00 after an edit, with explicit acceptance (shot 01).
  - A double tap on Confirm created one order.
- **Quote expiry and refresh** (shot 07).
- **Payment-method change** re-issues the quote, shows "payment method changed, amount unchanged" and no price warning (shot 08).
- **English/LTR:** mirroring, required option enforced, phone validation, keyboard over the notes field.
  - Bottom-bar label shown in full on the final build (shot 12).
  - Back from "order created" returns to the hub.
- **Above-stock quantity:** the cart stops at the API stock (10 for "30 Piece Wooden Building Blocks") and + becomes disabled (shot 12).
- **No duplicates:** the Order Inspector shows one `POST /orders` per order.

**Offers**
- Scenario A (approve) and Scenarios B and C (unavailable line plus replacement need explicit consent; reject with a confirmation dialog) (shot 02).
- The waiting state switches to the offer by polling (shot 03).
- **Stale offer (STR-000026):**
  - The dashboard revised 40.00 → 42.00, and Approve was tapped on the stale screen.
  - The app showed "تم تحديث العرض" and **no approve was sent** (Inspector: the only approve call is the later one for 42.00) (shots 09, 10).

**Payment**
- **Cash order:** "not a transfer order", no upload (shot 11).
- **Transfer order before acceptance:** "payment not open yet".
- **Receipt rejections (oversize, wrong type), preview, replace and delete, and the payment-approved auto-refresh:** these ran on STR-000025, so the order had been forced into `awaiting_payment`. The actions themselves were normal (shots 04–06).

**Printing and recovery**
- **Interrupted upload after process death:**
  - A 9 MB print upload was in progress (server processing at 100%) and the app process was killed (`am force-stop`).
  - After relaunch, the file is kept, marked "Upload interrupted — choose the file again", and Continue is disabled (shot 13).
  - On the specs screen the specs are locked, and a banner offers "Choose file" (shot 14).
  - Choosing a file again replaced the interrupted entry, uploaded it, and enabled "Review price" (see the limitations on this run).
- **Session and cart** survive app reinstall and process death.

## 2. Passed (controlled tests)

`flutter test`: **95 / 95 passed** (88 in the previous report, 65 before the end-to-end work). `flutter analyze`: no issues.

| Area | Test | What it proves |
|---|---|---|
| Interrupted uploads | `cart_controller_test` "restored as interrupted", "never shown as uploaded" | Only metadata is persisted (no file bytes). An upload without a server id comes back `interrupted`, never `uploaded`. Retry without bytes does nothing; reselect keeps the id and specs, re-uploads, and adds no duplicate |
| Interrupted uploads | `printing_controller_test` "interrupted upload after process death" (3) | Blocks quoting; reselect runs the same size and type checks; an unsupported reselect stays interrupted |
| Upload failure | `cart_controller_test` retry; `transfer_payment_test` | Print and receipt retry reuse the same file; the receipt reuses its upload and idempotency key |
| File limit, oversize, unsupported, cancel | `printing_controller_test` | 20-file limit; 11 MB rejected without being read; fake PDF rejected; cancel changes nothing |
| Quote failure | `checkout_controller_test` "quote network failure … retry recovers" | Failed state, no confirm, retry gives a ready quote |
| Server out-of-stock | `checkout_controller_test` "out_of_stock on quote" | Stock fell after the cart was filled: no quote, code kept, confirm blocked |
| Out-of-zone address | `checkout_controller_test` "out_of_zone remembers the address" | The address is marked for the delivery screen |
| Quote used, submission uncertain | `checkout_controller_test` | Own states; recheck with the same key and body; restored after restart |
| Offer expired | `offer_controller_test` | Cannot approve |
| Payment-method change | `checkout_controller_test` (2) | No price warning when amounts are equal; acceptance still needed when the total changes |
| Back after created | `created_back_test` | Leaves the purchase flow |
| Large text, small screen | `purchase_layout_test` (12) | Offer and transfer screens at 320×568, text 1/1.5/2×, Arabic and English: no overflow |
| Bottom bar | `purchase_bottom_bar_test` (3, real font) | Long English labels are not cut off at 360 dp |

## 3. Passed only after a forced transition

STR-000025 entered `awaiting_payment` through "فرض حالة" because of B1. After that, every step used normal actions:
- payment screen (amount, account from config, copy)
- receipt rejections, preview, replace and delete
- dashboard "طلب تصحيح" with a note, which the app picked up by polling
- resubmit → `payment_review`
- dashboard "اعتماد الدفع" → `preparing`, paid, with an app auto-refresh

**This journey is not a normal-flow pass**, because entering `awaiting_payment` normally is blocked.

## 4. Blocked (backend or dashboard; Flutter cannot fix these)

- **B1: no dashboard action for `pending → awaiting_payment`.**
  - Transition 136 "قبول الطلب وطلب التحويل" (operator, no conditions) is configured.
  - On **STR-000026 (#76, `pending`, 42.00)** the order page offers only "إلغاء الطلب" and "فرض حالة", and the order list offers only "عرض".
  - Blocked as a result: the normal transfer journey from acceptance through correction to approval.
- **B2: cash orders have no configured exit from `pending`** other than cancel. STR-000023 and the other cash orders cannot progress without a force. The cash lifecycle (accept → prepare → deliver → collect cash) needs a config decision.
- **B3: offer approval is not atomic.**
  - `POST /orders/{id}/offer/approve` has no offer id or version.
  - The app refetches and compares before approving, which narrows the race but cannot remove it: a revision committed between that refetch and the POST is still approved.
  - **Needed:** an expected `offer_id` or version on approve, with 409 when it no longer matches. **Unresolved.**
- **Out-of-zone saved address:** the API refuses to create one ("This location is outside the service area", live, 18:12). The delivery screen's out-of-zone state can only occur if zones change after an address is saved, which needs a dashboard config change. It is covered by the controlled test only.

## 5. Not tested

- **Quote failure live:** no safe live trigger. Changing network settings on the device was avoided. Controlled test only.
- **Server `out_of_stock` live:** would need product stock to be edited on the dashboard. Controlled test only.
- **Large text on the device:** the system font scale was not changed. Controlled test only.
- **Offer expiry live** (60-minute TTL): controlled test only.

## Defects fixed in this work

| # | Defect | Fix | Evidence |
|---|---|---|---|
| F1 | Approving could approve a revision the customer never saw | Refetch and compare before approve/reject | Live (shots 09, 10) + test |
| F2 | Receipt card never showed preview or errors | Card wrapped in `Obx` | Live (shot 05) |
| F3 | "Price changed 40.00 → 40.00" after a payment-method change | Compare amounts only; separate payment-terms notice | Live (shot 08) + 2 tests |
| F4 | System Back after "order created" returned to checkout | Created state leaves the flow; reactive `PopScope` | Live + test |
| F5 | 2× text overflow (41 px) | `SummaryRow` value expanded and end-aligned | 12 layout tests |
| F6 | English bottom-bar label cut off | Button takes 2/3 of the bar (shared `AppButton` unchanged) | Live (shot 12) + 3 tests |
| F7 | Mid-upload print file vanished after process death | Metadata persisted; `interrupted` state; reselect flow | Live (shots 13, 14) + 5 tests |
| F8 | Release builds had no `INTERNET` permission | One `uses-permission` line in `src/main/AndroidManifest.xml` | Merged release manifest (`processReleaseMainManifest`) contains it |

## Process death during file selection
- Logcat shows `Zygote: Process … exited due to signal 9 (Killed)` while DocumentsUI was in front.
  - This happened during a wave of signal-9 kills of other background apps, with `am_low_memory` events and `am_mem_factor [3,2]`.
  - There was no crash entry and no Dart or Java exception.
- **Consistent with termination under memory pressure.** The exact killer is unconfirmed: Android 10 has no `ApplicationExitInfo`, and kernel logs need root.
- It happened again three times during this run, while choosing a file. F7 means any file whose upload was interrupted is now kept and flagged instead of lost. A pick that was still in the system picker when the app died is simply not added.

## Limitations of this run
- **Live reselect after the interrupted upload:** the replacement chosen was not the original file. While the app kept being killed in the picker, a mis-tap selected an unrelated personal PDF from the phone's Downloads. It was removed from the cart immediately. Its upload record remains in the sandbox: there is no customer endpoint to delete it, and I did not delete data. No screenshot of it is kept. The reselect logic itself is covered by the controlled tests above.
- Picker steps on this low-RAM phone are unreliable, because the app is often killed while the picker is open (see above).
- The cart of the test account currently holds 10 × "30 Piece Wooden Building Blocks" from the stock check.
