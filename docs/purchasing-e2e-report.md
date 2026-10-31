# SATR purchasing: end-to-end test report

- **Branch:** `feature/hala-customer-purchasing` (committed in five phases: foundation, cart and printing, checkout, offers and payment, dev tools and docs).
- **Overall (retest 31 Oct):**
  - The **bank-transfer** purchase now completes through normal actions only. Today's **full receipt flow** passed through **API and dashboard testing** on STR-000028: receipt, correction with note, resubmit, approval and `preparing`.
  - The **phone test** on STR-000031 passed offer approval and the auto-updating payment screen, then **stopped at file selection**: the phone killed the app while the system picker was open.
  - The **cash** purchase still does **not** complete: there is no cash accept/prepare action, and the only offered action sends a cash order to `awaiting_payment`, where it gets stuck.
  - See "Retest 31 Oct" below. The sections after it describe the 30 Oct run.
- **Device:** Redmi 8 "olive", Android 10, 720×1520 (360 dp wide). Profile builds, purchasing dev hub as the entry point (the teammate login, catalog, address and order screens do not exist yet).
- **API:** sandbox `https://masar.toldpath.com/api/v1`, config v8.
- **Dashboard:** `https://masar.toldpath.com/p/satr`, the same sandbox project.
- **Dates:** 30 Oct 2026; retest 31 Oct 2026.
- **Screenshots:** `docs/e2e-screenshots/`, 14 images. Cropped below the status bar. No account details, receiving-account data, personal files or notifications.

## Retest 31 Oct: platform update against the three reported blockers

**Inputs:**
- The platform developer's `satr-customizations.html` is dated **27 Oct**, before the blockers were reported on 30 Oct. It describes the generic bank-transfer and printing modules. It does not mention offer ids on approve, a library-accept button or cash acceptance.
- The live contract was read from `GET /app/config` and from the dashboard API docs (`/p/satr/docs`).

**Contract comparison:**
- **Config:** still **v8**, and the 27 transitions are unchanged and published.
- **Approval module:** still active (`awaiting_pricing` → `priced`, 60-minute offers).
- **Docs changed since 30 Oct:**
  - `POST /orders/{order}/offer/approve` now **requires `offer_id`**, the id of the offer the customer saw. It returns **409 `conflict`, reason `offer_changed`**, with the current `offer_id`, `seen_offer_id` and `total`. Without `offer_id` it returns **422 "offer_id required"**.
  - `offer/reject` takes an optional `offer_id`.
- **Conflict with the document:**
  - The document says transfer orders *start* at `awaiting_payment`.
  - Deployed behaviour (STR-000028, STR-000029, STR-000031): **transfer orders start at `awaiting_pricing`**, and pricing plus customer approval come first.
  - Our implementation already follows the deployed behaviour. No change was made to bypass pricing or consent.

**Orders used:** all were created for this retest.
- STR-000028 to STR-000030 belong to a new fictional sandbox customer (#81) and were driven through the API.
- STR-000031 belongs to the phone test account (#72) and was driven through the app.

| Scenario | Order | Expected | Actual | Evidence | Result |
|---|---|---|---|---|---|
| Stale offer: approve with old id | STR-000028 (#78) | Server rejects; revised offer stays unapproved | Offer A′ id 40 (29.00) was shown; the dashboard revised it to B id 41 (30.00). Approving with `offer_id: 40` gave **409 conflict `offer_changed`** (`offer_id 41`, `seen_offer_id 40`, `total 3000`). B stayed `sent` and the order stayed `priced` | API log; dashboard "تعديل السعر" | **PASS** |
| Stale offer: explicit approval of reviewed B | STR-000028 | Approving B with its id succeeds | `offer_id: 41` gave 200; offer `approved`, order `pending` 30.00 | API log | **PASS** |
| Approve without `offer_id` (old app behaviour) | STR-000029 (#79) | Server must not blindly approve | **422 validation `offer_id` required**; order stays `priced` | API log | **PASS** (server). The old app could no longer approve at all → Flutter change F9 |
| Transfer: normal accept by the library | STR-000028 | `pending` → `awaiting_payment` with no force | Dashboard **"قبول الطلب وطلب التحويل"** + confirm → `awaiting_payment` / `transfer_pending`, amount **30.00 = approved offer B** | Dashboard, API | **PASS** |
| Transfer: receipt, correction, resubmit, approval | STR-000028 | `payment_review` → correction with note → `awaiting_payment` → resubmit → approval → `preparing` | Synthetic `fixtures/photo.png` → `payment_review`/`transfer_review`. "طلب تصحيح" with note → `awaiting_payment` + `review_note`. Resubmit → `payment_review` (note cleared). "اعتماد الدفع" (dialog showed 30.00 and both receipts) → **`preparing`, `paid`** | Dashboard, API | **PASS** |
| Transfer in the app: offer approval | STR-000031 (#81) | App shows the offer by polling; approval sends `offer_id` | Offer 28.00 appeared without refresh; "وافق على السعر" → "تمت الموافقة على العرض", order `pending` | Phone | **PASS** (fixed build) |
| Transfer in the app: accept → payment screen | STR-000031 | App updates to awaiting payment with the approved amount | After the dashboard accept, the open payment screen switched by polling to "حوّل المبلغ وارفع الإشعار" with **28.00** and upload enabled | Phone | **PASS** |
| Transfer in the app: receipt upload, correction, approval | STR-000031 | Same as the backend steps, shown in the app | The app was killed three times while the system file picker was open (logcat 14:14, 14:16, 14:18 "has died: prev LAST" amid signal-9 kills), even after background apps were closed. The synthetic receipt was found by exact-name search each time, but the selection was lost | logcat | **NOT TESTED today** (these app steps passed live on 30 Oct, STR-000025, unchanged code; server steps passed today on STR-000028). STR-000031 left in `awaiting_payment` |
| Cash: approve offer | STR-000030 (#80) | Customer approves; order `pending` | `offer_id: 43` gave 200 → `pending`, cash on delivery, 28.00 | API | **PASS** |
| Cash: receipt not allowed | STR-000030 | Transfer receipt refused | `payment-receipt` gave **409 `not_a_transfer_order`** (both in `pending` and in `awaiting_payment`) | API | **PASS** |
| Cash: normal accept → `preparing` | STR-000030 | A cash accept/prepare action | The only action is **"قبول الطلب وطلب التحويل"** (also shown on cash order STR-000023). Pressing it moved the cash order to **`awaiting_payment`** ("بانتظار التحويل ورفع إشعار الدفع") while payment stays cash. Receipts are refused, and only "cancel" / "force status" remain, so the order is **stuck** | Dashboard, API | **FAIL / BLOCKED** (backend/config) |

**Verified backend fixes since 30 Oct:**
- **B3 fixed:** approval is validated against the displayed offer id; stale approvals get 409, and approval without an id is refused.
- **B1 fixed for transfer orders:** the order page now renders the operator transition "قبول الطلب وطلب التحويل". The normal transfer lifecycle completes to `preparing` with no force.
- Offer revision is now labelled "تعديل السعر" in the dashboard and states that the customer must approve again.

**Flutter changes (this retest):**
- **F9:** approve sends `{"offer_id": <shown offer>}`, and reject sends `offer_id` too. A server `409 offer_changed` refetches and shows "تم تحديث العرض", so a revision that lands after the app's own pre-check still needs fresh consent.
- Regression tests: "approve and reject send the id of the offer the customer saw" and "server offer_changed … shows the new offer".
- `flutter analyze` is clean; `flutter test` passes **97/97**. Verified live on STR-000031.

**Unresolved blockers:**
- **B2 (cash):** there is still no cash transition out of `pending`.
  - The newly rendered transfer action is offered on cash orders too and puts them in `awaiting_payment`, a dead end (STR-000030).
  - **Needed:** a cash transition such as `pending → preparing` (with collect-cash handling), and the transfer action restricted to `payment_method = bank_transfer`.
- **Dashboard:** the payment-review screen now shows two correction buttons: the module's "طلب تصحيح" and the generic transition "طلب تصحيح إشعار الدفع". Only the first was used and verified.
- **Device limitation, not a product defect:** the Redmi 8 kills the app while the system picker is open, so live receipt selection is unreliable on this phone.

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

## 4. Blocked (backend or dashboard; Flutter cannot fix these), as of 30 Oct

> Status on 31 Oct: **B1 fixed** for transfer orders, **B3 fixed**, **B2 still open** and now worse (cash orders can be sent to `awaiting_payment`). See "Retest 31 Oct".

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
