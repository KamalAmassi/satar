import 'package:get/get.dart';
import 'package:project/core/routes/app_routes.dart';
import 'package:project/customer/features/orders/data/datasources/orders_remote_datasource.dart';
import 'package:project/customer/features/orders/data/repositories/orders_repository_impl.dart';
import 'package:project/customer/features/orders/domain/entities/order_entity.dart';
import 'package:project/customer/features/orders/domain/usecases/get_orders_usecase.dart';

class OrdersController extends GetxController {
  late final GetOrdersUseCase getOrdersUseCase;

  final currentTab = 0.obs; // 0: الطلبات الحالية, 1: المكتملة, 2: الملغية
  final currentNavTab = 1.obs; // طلباتي tab in bottom bar

  final orders = <OrderEntity>[
    const OrderEntity(
      id: 'ST-2048',
      status: 'preparing',
      statusLabel: 'قيد التجهيز والطباعة',
      itemsCount: '5 عناصر',
      date: '٢٤ مايو ٢٠٢٥',
      price: '104.00 ₪',
      actionLabel: 'تابع طلبك',
    ),
    const OrderEntity(
      id: 'ST-2051',
      status: 'awaiting_approval',
      statusLabel: 'بانتظار موافقة الزبون على السعر',
      itemsCount: '2 عناصر',
      date: 'اليوم',
      price: 'بانتظار العرض',
      actionLabel: 'راجع الطلب',
    ),
  ].obs;

  final isLoading = false.obs;
  final isLoadingMore = true.obs;
  final hasMoreError = true.obs;

  @override
  void onInit() {
    super.onInit();
    final repository = OrdersRepositoryImpl(remoteDatasource: OrdersRemoteDatasourceImpl());
    getOrdersUseCase = GetOrdersUseCase(repository);
    loadOrders();
  }

  void selectTab(int index) {
    currentTab.value = index;
    loadOrders();
  }

  void loadOrders() async {
    try {
      final tabName = currentTab.value == 0
          ? 'current'
          : currentTab.value == 1
              ? 'completed'
              : 'cancelled';
      final result = await getOrdersUseCase(tab: tabName);
      if (result.isNotEmpty) {
        orders.value = result;
      }
    } catch (_) {}
  }

  void retryLoadMore() {
    hasMoreError.value = false;
    isLoadingMore.value = true;
    Future.delayed(const Duration(seconds: 2), () {
      isLoadingMore.value = false;
      hasMoreError.value = true;
    });
  }

  void changeNavTab(int index) {
    currentNavTab.value = index;
    if (index == 0) {
      Get.offAllNamed(CustomerRoutes.home);
    } else if (index == 2) {
      Get.toNamed(CustomerRoutes.categories);
    }
  }

  void goToOrderDetails(String id) {
    Get.toNamed(CustomerRoutes.orderDetails, arguments: id);
  }
}
