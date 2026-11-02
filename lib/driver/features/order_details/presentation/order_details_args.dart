import 'package:project/driver/shared/driver_models.dart';

/// offer: عرض طلب متاح (قبول/تجاهل) — task: المهمة الحالية — history: مهمة سابقة
enum OrderDetailsMode { offer, task, history }

class OrderDetailsArgs {
  const OrderDetailsArgs({required this.order, required this.mode});

  final DriverOrder order;
  final OrderDetailsMode mode;
}
