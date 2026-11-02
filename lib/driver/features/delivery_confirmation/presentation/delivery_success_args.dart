import 'package:project/driver/shared/driver_models.dart';

class DeliverySuccessArgs {
  const DeliverySuccessArgs({required this.orderNumber, this.collected});

  final String orderNumber;
  final Money? collected;
}
