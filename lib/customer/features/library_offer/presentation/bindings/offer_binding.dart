import 'package:get/get.dart';
import 'package:project/core/network/api_client.dart';
import 'package:project/core/storage/session_store.dart';
import 'package:project/customer/features/library_offer/data/datasources/offer_remote_datasource.dart';
import 'package:project/customer/features/library_offer/data/repositories/offer_repository_impl.dart';
import 'package:project/customer/features/library_offer/presentation/controllers/offer_controller.dart';
import 'package:project/core/routes/route_args.dart';

class OfferBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(
      OfferController(
        orderId: RouteArgs.readOrderId() ?? 0,
        repository: OfferRepositoryImpl(
          OfferRemoteDataSourceImpl(Get.find<ApiClient>()),
        ),
        session: Get.find<SessionStore>(),
      ),
    );
  }
}
