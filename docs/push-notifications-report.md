# Satr Push Notifications & Deep-Link System Architecture

## 1. Executive Overview

The Satr Push Notification module integrates Firebase Cloud Messaging (FCM) and Local Notifications into the existing application architecture cleanly, maintaining full compliance with the codebase design tokens, routing scheme, and privacy requirements.

---

## 2. Architecture & File Breakdown

```
lib/core/services/push/
├── push_service.dart               # Central FCM lifecycle, permission check, token sync
├── local_notifications_service.dart # Heads-up banner display & Android notification channel
├── notification_router.dart        # Route mapping from FCM payload to GetX navigation
└── notification_pagination_parser.dart # Tolerant pagination & unread badge parser
```

- **[push_service.dart](file:///E:/satar/lib/core/services/push/push_service.dart):** Manages FCM initialization safely across platforms (`kIsWeb`, `Windows` degradation). Syncs tokens via `Backend.setFcmToken()` without logging tokens into terminal streams.
- **[local_notifications_service.dart](file:///E:/satar/lib/core/services/push/local_notifications_service.dart):** Manages foreground notification banners on Android channel `satr_high_importance_channel`.
- **[notification_router.dart](file:///E:/satar/lib/core/services/push/notification_router.dart):** Translates payload maps (`order_id`, `destination`) to navigation targets (`/order`, `/offer`, `/driver/available`, `/driver/order`, `/notifications`).
- **[notification_pagination_parser.dart](file:///E:/satar/lib/core/services/push/notification_pagination_parser.dart):** Defensive parser extracting `items`, `unreadCount`, `currentPage`, `lastPage`, and `hasMore` at `per_page=20`.

---

## 3. Deep-Link Payload Table

| Event Payload (`destination` / `event`) | Target Path | Arguments | Notes |
|---|---|---|---|
| `order_detail` / `order` | `/order` (Customer) / `/driver/order` (Driver) | `{'order_id': orderId}` | Opens order detail screen |
| `price_offer` / `offer` | `/offer` | `{'order_id': orderId}` | Opens customer price offer screen |
| `driver_available` / `available_orders` | `/driver/available` | None | Opens driver available orders list |
| `driver_order` | `/driver/order` | `{'order_id': orderId}` | Opens driver preview / task screen |
| `notifications` | `/notifications` / `/driver/notifications` | None | Notifications screen fallback |

---

## 4. Manual Setup Steps

1. Open **Firebase Console** and select project `qader-4ee5d`.
2. Add an Android app with package name `com.example.project` (from `android/app/build.gradle`).
3. Place `google-services.json` inside `android/app/google-services.json`.
4. Run `flutterfire configure` if updating default platform definitions.
5. Generate a service account private key (JSON) in Firebase Console and upload it to the backend Notification Lab.
