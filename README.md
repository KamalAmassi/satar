# سطر (SATR) — تطبيق Flutter

تطبيق واحد بدورين: **زبون** و**سائق توصيل**. الواجهة مبنية حرفيًا على التصميم المعتمد (`SATR-Approved-Design`)،
والمنطق والبيانات على منطق الفريق وعلى API سطر الحقيقي (`satr-openapi.json`).

## التشغيل

مفاتيح البيئة تُمرَّر وقت البناء ولا تُحفظ في المستودع:

```bash
flutter pub get
flutter run \
  --dart-define=SATR_PROJECT_KEY=pk_test_... \
  --dart-define=SATR_BASE_URL=https://masar.toldpath.com \
  --dart-define=GEMINI_API_KEY=...          # للمساعد الذكي فقط (اختياري)
```

| المتغيّر | الوظيفة |
|---|---|
| `SATR_PROJECT_KEY` | مطلوب. ترويسة `X-Project-Key` في كل طلب |
| `SATR_BASE_URL` | الافتراضي `https://masar.toldpath.com` |
| `SATR_DEV_MEMBER` | اختياري. `X-Dev-Member` لبيئة التجربة |
| `GEMINI_API_KEY` | اختياري. استخراج طلبات المساعد (نص وصوت) |
| `SATR_PICKUP_LAT/LNG/LABEL/DETAILS` | نقطة استلام التسعيرة (قرار مفتوح في التصميم) |
| `SATR_APP_ID` | معرّف التطبيق لرابط تحديث المتجر |

## إعداد الأسرار محليًا (للفريق)

ملفات الأسرار غير موجودة في المستودع. انسخ ملفات الأمثلة واملأ قيمك الخاصة:

```bash
cp .env.example .env
cp config/dev.example.json config/dev.json
flutter run --dart-define-from-file=config/dev.json
```

- ضع ملف `android/app/google-services.json` الخاص بمشروع Firebase يدويًا (من مسؤول المشروع).
- ممنوع رفع `.env` أو `config/dev.json` أو `google-services.json` أو `key.properties` أو `*.jks`؛ كلها مدرجة في `.gitignore`.
- لا تضع مفاتيح حقيقية داخل ملفات `*.example`؛ استخدم `YOUR_API_KEY_HERE`.

## البنية

```
lib/
  core/design/      نظام التصميم: tokens (ألوان فاتح/داكن)، icons (SVG المعتمد)، illustrations، widgets، shell (صفحة/تبويبات/ورقة/حوار/Toast)
  core/{network,errors,config,storage,uploads}   عميل Dio واحد، Idempotency، Failure، RemoteConfig (من /v1/app/config)
  data/             Backend (كل نقاط الـ API) + models
  customer/features/{cart,checkout,printing,library_offer,payment,ai_assistant}/{domain,data}   منطق الفريق (Hala/Kamal)
  features/         شاشات التصميم المعتمد + المتحكمات: entry, catalog, cart, printing, checkout, payment, orders, assistant, account, driver
  app/              AppBinding + AppRouter (GetX)
```

## ما لم يُبنَ لأن الـ API لا يدعمه
لا مفضلة، لا تقييم منتجات، لا محادثة، لا بثّ لحظي (التتبع استعلام دوري)، لا محفظة داخلية، لا تعديل طلب بعد إنشائه،
لا استعادة كلمة مرور للسائق (يتواصل مع المشغّل)، ولا إشعارات دفع FCM (تحتاج مشروع Firebase غير متوفر في المستودع).
