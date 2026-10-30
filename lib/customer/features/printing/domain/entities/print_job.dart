import 'package:equatable/equatable.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/uploads/file_signature.dart';
import 'package:project/customer/features/printing/domain/entities/print_spec.dart';

enum UploadStatus {
  uploading,
  uploaded,
  failed,

  /// كان الرفع جاريًا أو فاشلًا عندما أُغلق التطبيق؛ البايتات لم تعد متاحة،
  /// فيلزم أن يختار الزبون الملف مرة أخرى.
  interrupted,
}

/// ملف طباعة في السلة: حالة رفعه ومواصفاته وأخطاؤه خاصة به وحده.
class PrintJob extends Equatable {
  const PrintJob({
    required this.id,
    required this.fileName,
    required this.size,
    required this.localMime,
    required this.spec,
    this.status = UploadStatus.uploading,
    this.progress = 0,
    this.uploadId,
    this.serverMime,
    this.pages,
    this.failure,
    this.fieldErrors = const {},
    this.revision = 0,
  });

  /// معرّف محلي ثابت للملف داخل السلة.
  final String id;
  final String fileName;
  final int size;

  /// النوع المكتشف من بايتات الملف قبل الرفع.
  final String localMime;
  final PrintSpec spec;
  final UploadStatus status;
  final double progress;
  final int? uploadId;

  /// النوع بعد معالجة الخادم.
  final String? serverMime;

  /// عدد صفحات PDF كما أعاده الخادم؛ null للصور.
  final int? pages;
  final Failure? failure;

  /// أخطاء التحقق من الخادم لهذا الملف فقط (paper_size، print_page_range…).
  final Map<String, String> fieldErrors;

  /// يزيد مع كل تعديل؛ يُستخدم لمعرفة إن تغيّر الملف أثناء إرسال الطلب.
  final int revision;

  bool get isUploaded => status == UploadStatus.uploaded && uploadId != null;

  /// يحتاج تدخل الزبون قبل التسعير (إعادة المحاولة أو إعادة الاختيار).
  bool get needsAttention =>
      status == UploadStatus.failed || status == UploadStatus.interrupted;

  /// نفس الملف في السلة (المعرّف والمواصفات) بعد أن أعاد الزبون اختياره.
  PrintJob withReselectedFile({
    required String fileName,
    required int size,
    required String localMime,
  }) =>
      PrintJob(
        id: id,
        fileName: fileName,
        size: size,
        localMime: localMime,
        spec: spec,
        revision: revision + 1,
      );
  bool get isImage => FileSignature.isImage(serverMime ?? localMime);

  /// الصفحات المعروفة: PDF من الخادم، والصورة صفحة واحدة.
  int? get knownPages => pages ?? (isUploaded && isImage ? 1 : null);

  PrintJob copyWith({
    PrintSpec? spec,
    UploadStatus? status,
    double? progress,
    int? uploadId,
    String? serverMime,
    int? pages,
    Failure? failure,
    bool clearFailure = false,
    Map<String, String>? fieldErrors,
    bool bumpRevision = false,
  }) =>
      PrintJob(
        id: id,
        fileName: fileName,
        size: size,
        localMime: localMime,
        spec: spec ?? this.spec,
        status: status ?? this.status,
        progress: progress ?? this.progress,
        uploadId: uploadId ?? this.uploadId,
        serverMime: serverMime ?? this.serverMime,
        pages: pages ?? this.pages,
        failure: clearFailure ? null : (failure ?? this.failure),
        fieldErrors: fieldErrors ?? this.fieldErrors,
        revision: bumpRevision ? revision + 1 : revision,
      );

  /// تُحفظ الملفات المرفوعة فقط؛ الرفع غير المكتمل لا يُستأنف بعد إعادة التشغيل.
  /// بيانات وصفية فقط، بلا محتوى الملف. الرفع غير المكتمل يُحفظ ليظهر بعد
  /// إعادة التشغيل كـ"منقطع" بدل أن يختفي أو يظهر كأنه مرفوع.
  Map<String, dynamic> toJson() => {
        'status': isUploaded ? 'uploaded' : 'interrupted',
        'id': id,
        'file_name': fileName,
        'size': size,
        'local_mime': localMime,
        'upload_id': uploadId,
        'server_mime': serverMime,
        'pages': pages,
        'spec': spec.toJson(),
        'revision': revision,
      };

  factory PrintJob.fromJson(Map<String, dynamic> json) => PrintJob(
        id: json['id'] as String,
        fileName: json['file_name'] as String,
        size: json['size'] as int? ?? 0,
        localMime: json['local_mime'] as String? ?? '',
        spec:
            PrintSpec.fromJson(Map<String, dynamic>.from(json['spec'] as Map)),
        status: _restoredStatus(json),
        progress: _restoredStatus(json) == UploadStatus.uploaded ? 1 : 0,
        uploadId: json['upload_id'] as int?,
        serverMime: json['server_mime'] as String?,
        pages: json['pages'] as int?,
        revision: json['revision'] as int? ?? 0,
      );

  /// مرفوع فقط إن أكّده الخادم (upload_id)؛ أي شيء آخر منقطع.
  static UploadStatus _restoredStatus(Map<String, dynamic> json) =>
      json['upload_id'] != null && json['status'] != 'interrupted'
          ? UploadStatus.uploaded
          : UploadStatus.interrupted;

  @override
  List<Object?> get props => [
        id,
        fileName,
        size,
        localMime,
        spec,
        status,
        progress,
        uploadId,
        serverMime,
        pages,
        failure,
        fieldErrors,
        revision,
      ];
}
