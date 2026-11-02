import 'package:get/get.dart';
import 'package:project/core/config/remote_config_repository.dart';
import 'package:project/core/network/api_client.dart';
import 'package:project/core/storage/session_store.dart';
import 'package:project/core/uploads/picked_file.dart';
import 'package:project/core/uploads/upload_repository.dart';
import 'package:project/customer/features/checkout/presentation/bindings/checkout_binding.dart';
import 'package:project/customer/features/payment/data/datasources/payment_remote_datasource.dart';
import 'package:project/customer/features/payment/data/repositories/payment_repository_impl.dart';
import 'package:project/customer/features/payment/domain/usecases/submit_receipt_usecase.dart';
import 'package:project/customer/features/payment/presentation/controllers/transfer_payment_controller.dart';
import 'package:project/core/routes/route_args.dart';

/// عقد التصحيح → الدفع: orderId في arguments.
class TransferPaymentBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(
      TransferPaymentController(
        orderId: RouteArgs.readOrderId() ?? 0,
        config: Get.find<RemoteConfigRepository>(),
        session: Get.find<SessionStore>(),
        getOrder: CheckoutBinding.getOrder(),
        uploads: Get.find<UploadRepository>(),
        submitReceipt: SubmitReceiptUseCase(
          PaymentRepositoryImpl(
              PaymentRemoteDataSourceImpl(Get.find<ApiClient>())),
        ),
        files: Get.find<FileSource>(),
      ),
    );
  }
}
