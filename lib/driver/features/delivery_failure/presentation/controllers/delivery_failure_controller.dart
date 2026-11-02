import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/routes/app_routes.dart';
import 'package:project/core/services/app_config_service.dart';
import 'package:project/driver/features/current_task/presentation/controllers/current_task_controller.dart';
import 'package:project/driver/features/delivery_failure/domain/entities/failure_reason.dart';
import 'package:project/driver/shared/driver_models.dart';

class DriverDeliveryFailureController extends GetxController {
  final selected = Rxn<FailureReason>();

  /// الخيارات من إعدادات السيرفر أو القائمة الاحتياطية.
  late final List<FailureReason> reasons =
  FailureReasons.from(Get.find<AppConfigService>());
  final notesController = TextEditingController();
  final isSubmitting = false.obs;
  final error = Rxn<Failure>();
  final pickError = false.obs;

  DriverCurrentTaskController get _task => Get.find<DriverCurrentTaskController>();

  void select(FailureReason r) {
    selected.value = r;
    pickError.value = false;
  }

  Future<void> submit() async {
    final reason = selected.value;
    if (reason == null) {
      pickError.value = true;
      return;
    }
    if (isSubmitting.value) return;
    isSubmitting.value = true;
    error.value = null;

    final allowed = _task.task.value?.nextAction?.fields ?? const <String>[];
    final notes = notesController.text.trim();
    final fields = <String, dynamic>{
      'delivery_failure_reason': reason.key,
      // نرسل الملاحظات فقط لو السيرفر طلبها ضمن next_action.fields.
      if (notes.isNotEmpty && allowed.contains('delivery_failure_notes'))
        'delivery_failure_notes': notes,
      if (notes.isNotEmpty && allowed.contains('notes')) 'notes': notes,
    };

    // الوجهة من الإجراء الذي يسمح به السيرفر (actions) وإلا delivery_failed.
    final to = _task.task.value?.failureAction?.to ?? 'delivery_failed';
    final ok = await _task.transitionTo(to, fields: fields);
    isSubmitting.value = false;
    if (ok) {
      Get.offNamed(DriverRoutes.failureRecorded);
    } else {
      error.value = _task.transitionFailure.value;
    }
  }

  @override
  void onClose() {
    notesController.dispose();
    super.onClose();
  }
}
