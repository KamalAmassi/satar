import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:project/core/config/remote_config.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/network/idempotency.dart';
import 'package:project/core/storage/session_store.dart';
import 'package:project/core/uploads/upload_repository.dart';
import 'package:project/core/utils/money.dart';
import 'package:project/customer/features/cart/domain/entities/cart_product_line.dart';
import 'package:project/customer/features/cart/domain/entities/product_info.dart';
import 'package:project/customer/features/cart/domain/entities/stored_cart.dart';
import 'package:project/customer/features/cart/domain/repositories/cart_repository.dart';
import 'package:project/customer/features/printing/domain/entities/print_job.dart';
import 'package:project/customer/features/printing/domain/entities/print_spec.dart';

/// حالة السلة المشتركة بين الطباعة والسلة والدفع. خدمة دائمة.
///
/// عقد الكتالوج/المساعد → السلة: [addProduct] مع productId والكمية ومفاتيح
/// الخيارات والملاحظة فقط. لا أسعار من الواجهة.
class CartController extends GetxService {
  CartController(this._repository, this._uploads, this._session);

  final CartRepository _repository;
  final UploadRepository _uploads;
  final SessionStore _session;

  final products = <CartProductLine>[].obs;
  final printJobs = <PrintJob>[].obs;
  final substitutionPreference = RxnString();
  final note = ''.obs;

  /// معلومات العرض لكل منتج (null أثناء التحميل).
  final productInfo = <int, ProductInfo>{}.obs;
  final productInfoFailures = <int, Failure>{}.obs;

  /// يزيد مع كل تغيير يؤثر على التسعيرة.
  final revision = 0.obs;

  int? _loadedUserId;
  final Map<String, Uint8List> _pendingBytes = {};
  final Map<String, CancelToken> _uploadTokens = {};

  bool get isEmpty => products.isEmpty && printJobs.isEmpty;
  int get itemCount =>
      products.fold<int>(0, (n, l) => n + l.quantity) + printJobs.length;
  bool get hasUploadsInFlight =>
      printJobs.any((j) => j.status == UploadStatus.uploading);
  bool get hasFailedUploads =>
      printJobs.any((j) => j.status == UploadStatus.failed);
  bool get hasInterruptedUploads =>
      printJobs.any((j) => j.status == UploadStatus.interrupted);

  /// يُستدعى عند فتح أي شاشة شراء؛ يعيد التحميل إذا تغيّر الحساب.
  Future<void> ensureLoaded() async {
    final userId = _session.userId;
    if (userId == _loadedUserId) return;
    _resetMemory();
    _loadedUserId = userId;
    if (userId == null) return;
    final guard = _session.guard();
    final result = await _repository.load(userId);
    if (!guard.isCurrent) return;
    result.fold((_) {}, (cart) {
      products.assignAll(cart.products);
      printJobs.assignAll(cart.printJobs);
      substitutionPreference.value = cart.substitutionPreference;
      note.value = cart.note;
    });
    for (final line in products) {
      _loadProductInfo(line.productId);
    }
  }

  void _resetMemory() {
    for (final t in _uploadTokens.values) {
      t.cancel();
    }
    _uploadTokens.clear();
    _pendingBytes.clear();
    products.clear();
    printJobs.clear();
    productInfo.clear();
    productInfoFailures.clear();
    substitutionPreference.value = null;
    note.value = '';
    revision.value++;
  }

  // ---------------------------------------------------------------- products

  /// عقد الإضافة. نفس المنتج بنفس الخيارات يزيد كمية السطر الموجود.
  CartProductLine? addProduct(CartItemRequest request, {int maxQty = 99}) {
    final identity =
        CartProductLine.identityOf(request.productId, request.options);
    final index = products.indexWhere((l) => l.identity == identity);
    CartProductLine line;
    if (index >= 0) {
      final current = products[index];
      final note = request.note?.trim();
      line = current.copyWith(
        quantity: (current.quantity + request.quantity).clamp(1, maxQty),
        note: (note == null || note.isEmpty) ? null : note,
        fieldErrors: const {},
        bumpRevision: true,
      );
      products[index] = line;
    } else {
      line = CartProductLine(
        id: IdempotencyKey.generate(),
        productId: request.productId,
        quantity: request.quantity.clamp(1, maxQty),
        options: request.options,
        note: request.note?.trim() ?? '',
      );
      products.add(line);
      _loadProductInfo(request.productId);
    }
    _changed();
    return line;
  }

  void setQuantity(String lineId, int quantity, {int maxQty = 99}) {
    final i = products.indexWhere((l) => l.id == lineId);
    if (i < 0) return;
    final q = quantity.clamp(1, maxQty);
    if (q == products[i].quantity) return;
    products[i] = products[i].copyWith(
      quantity: q,
      fieldErrors: const {},
      bumpRevision: true,
    );
    _changed();
  }

  /// تغيير الخيارات قد يجعل السطر مطابقًا لسطر آخر فيُدمجان.
  void setOptions(String lineId, Map<String, List<String>> options) {
    final i = products.indexWhere((l) => l.id == lineId);
    if (i < 0) return;
    final updated = products[i].copyWith(
      options: options,
      fieldErrors: const {},
      bumpRevision: true,
    );
    final twin = products.indexWhere(
      (l) => l.id != lineId && l.identity == updated.identity,
    );
    if (twin >= 0) {
      products[twin] = products[twin].copyWith(
        quantity: products[twin].quantity + updated.quantity,
        bumpRevision: true,
      );
      products.removeAt(i);
    } else {
      products[i] = updated;
    }
    _changed();
  }

  void setLineNote(String lineId, String value) {
    final i = products.indexWhere((l) => l.id == lineId);
    if (i < 0 || products[i].note == value) return;
    products[i] = products[i].copyWith(note: value, bumpRevision: true);
    _changed();
  }

  void removeProduct(String lineId) {
    products.removeWhere((l) => l.id == lineId);
    _changed();
  }

  Future<void> refreshProductInfo() async {
    for (final id in {for (final l in products) l.productId}) {
      await _loadProductInfo(id);
    }
  }

  Future<void> _loadProductInfo(int productId) async {
    final guard = _session.guard();
    productInfoFailures.remove(productId);
    final result = await _repository.product(productId);
    if (!guard.isCurrent) return;
    result.fold(
      (f) => productInfoFailures[productId] = f,
      (info) => productInfo[productId] = info,
    );
  }

  /// مجموع المنتجات للعرض فقط من أسعار الكتالوج (التسعيرة هي المرجع).
  Money? get displayedProductsTotal {
    var total = 0;
    for (final line in products) {
      final info = productInfo[line.productId];
      if (info == null || info.isInspectionPriced) return null;
      var unit = info.price.amount;
      line.options.forEach((key, choices) {
        final option = info.option(key);
        for (final c in choices) {
          unit += option?.choices
                  .where((x) => x.key == c)
                  .firstOrNull
                  ?.price
                  .amount ??
              0;
        }
      });
      total += unit * line.quantity;
    }
    return Money(amount: total);
  }

  // ---------------------------------------------------------------- printing

  /// يضيف ملفًا تم فحصه محليًا ويبدأ رفعه فورًا.
  PrintJob addPrintFile({
    required String fileName,
    required int size,
    required String mime,
    required Uint8List bytes,
    required PrintSpec spec,
  }) {
    final job = PrintJob(
      id: IdempotencyKey.generate(),
      fileName: fileName,
      size: size,
      localMime: mime,
      spec: spec,
    );
    printJobs.add(job);
    _pendingBytes[job.id] = bytes;
    // تُحفظ البيانات الوصفية فورًا حتى لا يختفي الملف إن أُغلق التطبيق أثناء رفعه.
    _changed();
    _upload(job.id);
    return job;
  }

  /// يستبدل ملفًا انقطع رفعه بالملف الذي أعاد الزبون اختياره، مع إبقاء
  /// مواصفاته، ثم يرفعه من جديد.
  Future<void> reselectPrintFile(
    String jobId, {
    required String fileName,
    required int size,
    required String mime,
    required Uint8List bytes,
  }) async {
    final job = printJobs.firstWhereOrNull((j) => j.id == jobId);
    if (job == null || !job.needsAttention) return;
    _updateJob(
        jobId,
        (j) => j.withReselectedFile(
            fileName: fileName, size: size, localMime: mime));
    _pendingBytes[jobId] = bytes;
    _changed();
    await _upload(jobId);
  }

  Future<void> retryUpload(String jobId) async {
    if (!_pendingBytes.containsKey(jobId)) return;
    _updateJob(
        jobId,
        (j) => j.copyWith(
              status: UploadStatus.uploading,
              progress: 0,
              clearFailure: true,
            ));
    await _upload(jobId);
  }

  Future<void> _upload(String jobId) async {
    final job = printJobs.firstWhereOrNull((j) => j.id == jobId);
    final bytes = _pendingBytes[jobId];
    if (job == null || bytes == null) return;
    final guard = _session.guard();
    final token = CancelToken();
    _uploadTokens[jobId] = token;
    final result = await _uploads.upload(
      bytes: bytes,
      fileName: job.fileName,
      mime: job.localMime,
      purpose: UploadPurpose.printFile,
      cancelToken: token,
      onProgress: (p) {
        if (guard.isCurrent) _updateJob(jobId, (j) => j.copyWith(progress: p));
      },
    );
    _uploadTokens.remove(jobId);
    if (!guard.isCurrent) return;
    result.fold(
      (failure) {
        if (failure is CancelledFailure) return;
        _updateJob(
            jobId,
            (j) => j.copyWith(
                  status: UploadStatus.failed,
                  failure: failure,
                ));
      },
      (uploaded) {
        _pendingBytes.remove(jobId);
        _updateJob(
            jobId,
            (j) => j.copyWith(
                  status: UploadStatus.uploaded,
                  progress: 1,
                  uploadId: uploaded.uploadId,
                  serverMime: uploaded.mime,
                  pages: uploaded.pages,
                  clearFailure: true,
                  bumpRevision: true,
                ));
        _changed();
      },
    );
  }

  void updateSpec(String jobId, PrintSpec spec) {
    final job = printJobs.firstWhereOrNull((j) => j.id == jobId);
    if (job == null || job.spec == spec) return;
    _updateJob(
        jobId,
        (j) => j.copyWith(
              spec: spec,
              fieldErrors: const {},
              bumpRevision: true,
            ));
    _changed();
  }

  void removePrintJob(String jobId) {
    _uploadTokens.remove(jobId)?.cancel();
    _pendingBytes.remove(jobId);
    printJobs.removeWhere((j) => j.id == jobId);
    _changed();
  }

  void _updateJob(String jobId, PrintJob Function(PrintJob) update) {
    final i = printJobs.indexWhere((j) => j.id == jobId);
    if (i >= 0) printJobs[i] = update(printJobs[i]);
  }

  // --------------------------------------------------------- order details

  void setSubstitutionPreference(String? value) {
    if (substitutionPreference.value == value) return;
    substitutionPreference.value = value;
    _changed();
  }

  /// الملاحظة تُرسل مع إنشاء الطلب فقط، فلا تُبطل التسعيرة.
  void setNote(String value) {
    if (note.value == value) return;
    note.value = value;
    _persist();
  }

  // ------------------------------------------------------------ server errors

  /// يربط أخطاء التسعيرة بالسطر أو الملف الصحيح حسب الفهرس المرسل.
  void applyFieldErrors({
    required Map<int, String> productIndexToLineId,
    required Map<int, String> printIndexToJobId,
    required Map<String, String> fieldErrors,
  }) {
    final lineErrors = <String, Map<String, String>>{};
    final jobErrors = <String, Map<String, String>>{};
    final pattern = RegExp(r'^(cart|print_items)\.(\d+)\.(.+)$');
    for (final e in fieldErrors.entries) {
      final m = pattern.firstMatch(e.key);
      if (m == null) continue;
      final index = int.parse(m.group(2)!);
      final field = m.group(3)!;
      if (m.group(1) == 'cart') {
        final id = productIndexToLineId[index];
        if (id != null) (lineErrors[id] ??= {})[field] = e.value;
      } else {
        final id = printIndexToJobId[index];
        if (id != null) (jobErrors[id] ??= {})[field] = e.value;
      }
    }
    for (var i = 0; i < products.length; i++) {
      products[i] = products[i].copyWith(
        fieldErrors: lineErrors[products[i].id] ?? const {},
      );
    }
    for (var i = 0; i < printJobs.length; i++) {
      printJobs[i] = printJobs[i].copyWith(
        fieldErrors: jobErrors[printJobs[i].id] ?? const {},
      );
    }
  }

  // ------------------------------------------------------- after submission

  /// يحذف فقط ما أُرسل فعلًا (نفس المعرّف ونفس رقم التعديل).
  /// ما عُدّل أثناء الإرسال يبقى في السلة.
  void removeSubmitted({
    required Map<String, int> productRevisions,
    required Map<String, int> printRevisions,
  }) {
    products.removeWhere((l) => productRevisions[l.id] == l.revision);
    printJobs.removeWhere((j) => printRevisions[j.id] == j.revision);
    if (isEmpty) {
      note.value = '';
      substitutionPreference.value = null;
    }
    _changed();
  }

  // ----------------------------------------------------------------- helpers

  /// خيارات الطباعة الافتراضية من الإعداد (أول قيمة في كل قائمة).
  static PrintSpec defaultSpec(PrintingConfig config) => PrintSpec(
        paperSize: config.paperSizes.first.key,
        color: config.colors.first,
        sides: config.sides.first,
        binding: config.bindings.first.key,
      );

  void _changed({bool persist = true}) {
    revision.value++;
    if (persist) _persist();
  }

  Future<void> _persist() async {
    final userId = _loadedUserId;
    if (userId == null || userId != _session.userId) return;
    await _repository.save(
      userId,
      StoredCart(
        products: products.toList(),
        printJobs: printJobs.toList(),
        substitutionPreference: substitutionPreference.value,
        note: note.value,
      ),
    );
  }

  @override
  void onClose() {
    for (final t in _uploadTokens.values) {
      t.cancel();
    }
    super.onClose();
  }
}
