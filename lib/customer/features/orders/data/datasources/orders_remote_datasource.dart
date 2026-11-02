import 'package:project/customer/features/orders/data/models/order_model.dart';

abstract class OrdersRemoteDatasource {
  Future<List<OrderModel>> getOrders({required String tab, int page = 1});
  Future<OrderModel> getOrderDetails(String orderId);
}

class OrdersRemoteDatasourceImpl implements OrdersRemoteDatasource {
  @override
  Future<List<OrderModel>> getOrders({required String tab, int page = 1}) async {
    // Calling GET /v1/orders with query parameters
    await Future.delayed(const Duration(milliseconds: 300));
    if (tab == 'current') {
      return [
        const OrderModel(
          id: 'ST-2048',
          status: 'preparing',
          statusLabel: 'قيد التجهيز والطباعة',
          itemsCount: '5 عناصر',
          date: '٢٤ مايو ٢٠٢٥',
          price: '104.00 ₪',
          actionLabel: 'تابع طلبك',
        ),
        const OrderModel(
          id: 'ST-2051',
          status: 'awaiting_approval',
          statusLabel: 'بانتظار موافقة الزبون على السعر',
          itemsCount: '2 عناصر',
          date: 'اليوم',
          price: 'بانتظار العرض',
          actionLabel: 'راجع الطلب',
        ),
      ];
    } else if (tab == 'completed') {
      return [
        const OrderModel(
          id: 'ST-1980',
          status: 'delivered',
          statusLabel: 'تم التوصيل',
          itemsCount: '3 عناصر',
          date: '١٥ مايو ٢٠٢٥',
          price: '75.00 ₪',
          actionLabel: 'تقييم الطلب',
        ),
      ];
    } else {
      return [
        const OrderModel(
          id: 'ST-1950',
          status: 'cancelled',
          statusLabel: 'تم الإلغاء',
          itemsCount: '1 عناصر',
          date: '١٠ مايو ٢٠٢٥',
          price: '20.00 ₪',
          actionLabel: 'تفاصيل الطلب',
        ),
      ];
    }
  }

  @override
  Future<OrderModel> getOrderDetails(String orderId) async {
    // Calling GET /v1/orders/{order}
    await Future.delayed(const Duration(milliseconds: 300));
    return OrderModel(
      id: orderId,
      status: 'preparing',
      statusLabel: 'قيد التجهيز والطباعة',
      itemsCount: '5 عناصر',
      date: '٢٤ مايو ٢٠٢٥',
      price: '104.00 ₪',
      actionLabel: 'تابع طلبك',
    );
  }
}
