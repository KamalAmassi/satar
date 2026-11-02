import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/core/errors/api_error_codes.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/routes/app_routes.dart';
import 'package:project/driver/features/current_task/domain/usecases/upload_proof_photo_usecase.dart';
import 'package:project/driver/features/current_task/presentation/controllers/current_task_controller.dart';
import 'package:project/driver/features/delivery_confirmation/domain/usecases/deliver_order_usecase.dart';
import 'package:project/driver/features/delivery_confirmation/presentation/delivery_success_args.dart';
import 'package:project/driver/features/home/presentation/controllers/driver_session_controller.dart';
import 'package:project/driver/shared/driver_models.dart';

class DriverDeliveryConfirmationController extends GetxController {
  DriverDeliveryConfirmationController(this._deliver, this._upload);

  final DeliverOrderUseCase _deliver;
  final UploadProofPhotoUseCase _upload;

  final codeController = TextEditingController();
  final cashReceived = false.obs;
  final photoId = RxnInt();
  final isUploading = false.obs;
  final isSubmitting = false.obs;

  final codeError = RxnString();
  final generalFailure = Rxn<Failure>();

  DriverCurrentTaskController get _task => Get.find<DriverCurrentTaskController>();
  DriverOrder? get order => _task.task.value;
  bool get needsCash => order?.hasCashToCollect ?? false;

  Future<void> pickPhoto() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );
    if (file == null) return;
    isUploading.value = true;
    generalFailure.value = null;
    final result = await _upload(file.path);
    isUploading.value = false;
    result.fold((f) => generalFailure.value = f, (id) => photoId.value = id);
  }

  Future<void> submit({
    required String codeRequired,
    required String cashRequired,
    required String codeInvalid,
  }) async {
    final current = order;
    if (current == null || isSubmitting.value) return;
    codeError.value = null;
    generalFailure.value = null;

    final code = codeController.text.trim();
    if (code.isEmpty) {
      codeError.value = codeRequired;
      return;
    }
    if (needsCash && !cashReceived.value) {
      generalFailure.value = ValidationFailure(message: cashRequired);
      return;
    }

    isSubmitting.value = true;
    final result = await _deliver(
      DeliverParams(
        orderId: current.id,
        otp: code,
        uploadIds: photoId.value == null ? const [] : [photoId.value!],
      ),
    );
    isSubmitting.value = false;

    result.fold(
          (f) {
        if (f is ValidationFailure && f.fieldErrors.containsKey('otp')) {
          codeError.value = f.fieldErrors['otp'];
        } else if (f.code == ApiErrorCodes.otpInvalid ||
            f.code == ApiErrorCodes.otpExpired) {
          codeError.value = f.message ?? codeInvalid;
        } else {
          generalFailure.value = f;
        }
      },
          (delivered) {
        final collected = current.cashToCollect;
        _task.load(silent: true);
        Get.find<DriverSessionController>().refreshAll();
        Get.offNamed(
          DriverRoutes.deliverySuccess,
          arguments: DeliverySuccessArgs(
            orderNumber: delivered.code,
            collected: current.hasCashToCollect ? collected : null,
          ),
        );
      },
    );
  }

  @override
  void onClose() {
    codeController.dispose();
    super.onClose();
  }
}
