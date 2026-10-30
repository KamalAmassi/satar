/// نقطة الاستلام (المكتبة) المطلوبة في POST /orders/quote.
///
/// الخادم يرفض التسعيرة بدون pickup حتى مع سلة الكتالوج لأن منتجات هذا
/// المشروع بلا vendor_id، ولا يوفّر /app/config موقع المكتبة.
/// القيم الافتراضية هي نفس نقطة مجموعة Postman التدريبية.
/// TODO(kamal): استبدالها بمصدر من الخادم عند توفره.
class PickupPoint {
  const PickupPoint({
    required this.lat,
    required this.lng,
    this.label,
    this.details,
  });

  final double lat;
  final double lng;
  final String? label;
  final String? details;

  static final library = PickupPoint(
    lat: double.parse(
      const String.fromEnvironment('SATR_PICKUP_LAT', defaultValue: '31.5'),
    ),
    lng: double.parse(
      const String.fromEnvironment('SATR_PICKUP_LNG', defaultValue: '34.46'),
    ),
    label: const String.fromEnvironment(
      'SATR_PICKUP_LABEL',
      defaultValue: 'Shop',
    ),
    details: const String.fromEnvironment(
      'SATR_PICKUP_DETAILS',
      defaultValue: 'Omar Al-Mukhtar St.',
    ),
  );

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
        if (label != null && label!.isNotEmpty) 'label': label,
        if (details != null && details!.isNotEmpty) 'details': details,
      };
}
