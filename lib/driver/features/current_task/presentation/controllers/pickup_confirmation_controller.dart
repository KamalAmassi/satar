import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/driver/features/current_task/domain/usecases/upload_proof_photo_usecase.dart';
import 'package:project/driver/features/current_task/presentation/controllers/current_task_controller.dart';
import 'package:project/driver/shared/domain/order_extensions.dart';

class DriverPickupConfirmationController extends GetxController {
  DriverPickupConfirmationController(this._upload);

  final UploadProofPhotoUseCase _upload;

  final photoId = RxnInt();
  final isUploading = false.obs;
  final isSubmitting = false.obs;
  final error = Rxn<Failure>();

  DriverCurrentTaskController get _task => Get.find<DriverCurrentTaskController>();

  bool get photoRequired => _task.task.value?.nextAction?.requiresPhoto ?? false;

  Future<void> pickPhoto() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );
    if (file == null) return;
    isUploading.value = true;
    error.value = null;
    final result = await _upload(file.path);
    isUploading.value = false;
    result.fold((f) => error.value = f, (id) => photoId.value = id);
  }

  Future<void> confirm() async {
    if (isSubmitting.value) return;
    if (photoRequired && photoId.value == null) {
      await pickPhoto();
      if (photoId.value == null) return;
    }
    isSubmitting.value = true;
    error.value = null;
    final ok = await _task.transitionTo(
      _task.task.value?.nextAction?.to ?? 'picked_up',
      uploadIds: photoId.value == null ? const [] : [photoId.value!],
    );
    isSubmitting.value = false;
    if (ok) {
      Get.back<void>();
    } else {
      error.value = _task.transitionFailure.value;
    }
  }
}
