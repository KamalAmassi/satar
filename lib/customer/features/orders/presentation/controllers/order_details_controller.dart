import 'package:get/get.dart';
import 'package:project/customer/features/orders/data/datasources/orders_remote_datasource.dart';
import 'package:project/customer/features/orders/data/repositories/orders_repository_impl.dart';
import 'package:project/customer/features/orders/domain/entities/order_entity.dart';
import 'package:project/customer/features/orders/domain/usecases/get_order_details_usecase.dart';

class OrderDetailsController extends GetxController {
  late final GetOrderDetailsUseCase getOrderDetailsUseCase;

  final orderId = 'ST-2048'.obs;
  final orderDetails = Rxn<OrderEntity>();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final repository = OrdersRepositoryImpl(remoteDatasource: OrdersRemoteDatasourceImpl());
    getOrderDetailsUseCase = GetOrderDetailsUseCase(repository);

    if (Get.arguments != null) {
      orderId.value = Get.arguments.toString();
    }
    fetchDetails();
  }

  void fetchDetails() async {
    isLoading.value = true;
    try {
      final details = await getOrderDetailsUseCase(orderId.value);
      orderDetails.value = details;
    } finally {
      isLoading.value = false;
    }
  }

  void reviewOffer() {
    Get.snackbar('مراجعة السعر', 'جاري عرض تفاصيل السعر');
  }

  void rateOrder() {
    Get.snackbar('تقييم الطلب', 'شكراً لتقييمك!');
  }
}
