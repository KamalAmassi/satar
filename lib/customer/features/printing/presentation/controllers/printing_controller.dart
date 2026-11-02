import 'dart:async';

import 'package:get/get.dart';
import 'package:project/core/config/remote_config.dart';
import 'package:project/core/config/remote_config_repository.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/storage/session_store.dart';
import 'package:project/core/uploads/picked_file.dart';
import 'package:project/customer/features/cart/presentation/controllers/cart_controller.dart';
import 'package:project/customer/features/printing/domain/entities/file_check.dart';
import 'package:project/customer/features/printing/domain/entities/print_spec.dart';

/// ملف رُفض قبل الرفع، مع سببه، لعرضه في شاشة الخطأ.
class RejectedFile {
  const RejectedFile(this.name, this.size, this.reason);

  final String name;
  final int size;
  final FileRejection reason;
}

class PrintingController extends GetxController {
  PrintingController({
    required this.cart,
    required RemoteConfigRepository config,
    required SessionStore session,
    required FileSource files,
  })  : _config = config,
        _session = session,
        _files = files;

  final CartController cart;
  final RemoteConfigRepository _config;
  final SessionStore _session;
  final FileSource _files;

  final printing = Rxn<PrintingConfig>();
  final remoteConfig = Rxn<RemoteConfig>();
  final configLoading = false.obs;
  final configFailure = Rxn<Failure>();
  final rejected = <RejectedFile>[].obs;
  final limitReached = false.obs;
  final picking = false.obs;

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load({bool refresh = false}) async {
    await cart.ensureLoaded();
    configLoading.value = true;
    configFailure.value = null;
    final guard = _session.guard();
    final result = await _config.load(refresh: refresh);
    if (!guard.isCurrent) return;
    configLoading.value = false;
    result.fold((f) => configFailure.value = f, (c) {
      remoteConfig.value = c;
      printing.value = c.printing;
    });
  }

  int get maxJobs => printing.value?.maxJobs ?? 0;
  int get remainingSlots => maxJobs - cart.printJobs.length;

  Future<void> pickFiles() async {
    final config = printing.value;
    if (config == null || picking.value) return;
    if (remainingSlots <= 0) {
      limitReached.value = true;
      return;
    }
    picking.value = true;
    rejected.clear();
    limitReached.value = false;
    try {
      final picked = await _files.pick(multiple: true);
      for (final file in picked) {
        if (remainingSlots <= 0) {
          limitReached.value = true;
          break;
        }
        // فحص الحجم قبل قراءة الملف: الخادم يستغرق ~24 ثانية ليرفض 11MB.
        if (file.size > config.maxFileBytes) {
          rejected
              .add(RejectedFile(file.name, file.size, FileRejection.tooLarge));
          continue;
        }
        final bytes = await file.readBytes();
        final check = FileCheck.check(
          size: file.size,
          header: bytes.length > 16 ? bytes.sublist(0, 16) : bytes,
          allowedMimes: config.fileMimes,
          maxBytes: config.maxFileBytes,
        );
        if (!check.isAccepted) {
          rejected.add(RejectedFile(file.name, file.size, check.rejection!));
          continue;
        }
        cart.addPrintFile(
          fileName: file.name,
          size: file.size,
          mime: check.mime!,
          bytes: bytes,
          spec: CartController.defaultSpec(config),
        );
      }
    } finally {
      picking.value = false;
    }
  }

  /// يعيد الزبون اختيار ملف انقطع رفعه (لا يمكن استعادة الوصول إليه بعد
  /// إعادة تشغيل التطبيق). يُفحص كأي ملف جديد ويحتفظ بمواصفاته.
  Future<void> reselect(String jobId) async {
    final config = printing.value;
    if (config == null || picking.value) return;
    picking.value = true;
    rejected.clear();
    try {
      final picked = await _files.pick(multiple: false);
      if (picked.isEmpty) return;
      final file = picked.first;
      if (file.size > config.maxFileBytes) {
        rejected.add(RejectedFile(file.name, file.size, FileRejection.tooLarge));
        return;
      }
      final bytes = await file.readBytes();
      final check = FileCheck.check(
        size: file.size,
        header: bytes.length > 16 ? bytes.sublist(0, 16) : bytes,
        allowedMimes: config.fileMimes,
        maxBytes: config.maxFileBytes,
      );
      if (!check.isAccepted) {
        rejected.add(RejectedFile(file.name, file.size, check.rejection!));
        return;
      }
      // الرفع يكمل في الخلفية كما في إضافة ملف جديد.
      unawaited(cart.reselectPrintFile(
        jobId,
        fileName: file.name,
        size: file.size,
        mime: check.mime!,
        bytes: bytes,
      ));
    } finally {
      picking.value = false;
    }
  }

  void dismissRejections() => rejected.clear();
  void dismissLimit() => limitReached.value = false;

  void updateSpec(String jobId, PrintSpec Function(PrintSpec) change) {
    final job = cart.printJobs.firstWhereOrNull((j) => j.id == jobId);
    if (job == null) return;
    final config = printing.value;
    var spec = change(job.spec);
    if (config != null) {
      spec = spec.copyWith(copies: spec.copies.clamp(1, config.maxCopies));
    }
    cart.updateSpec(jobId, spec);
  }
}
