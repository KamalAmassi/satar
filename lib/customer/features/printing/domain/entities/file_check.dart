import 'dart:typed_data';

import 'package:project/core/uploads/file_signature.dart';

enum FileRejection { tooLarge, unsupportedType, empty }

/// نتيجة الفحص المبكر قبل الرفع. حكم الخادم هو النهائي.
class FileCheckResult {
  const FileCheckResult.accepted(this.mime) : rejection = null;
  const FileCheckResult.rejected(this.rejection) : mime = null;

  final String? mime;
  final FileRejection? rejection;

  bool get isAccepted => rejection == null;
}

abstract final class FileCheck {
  /// [header] أول بايتات الملف (تكفي 16 بايت).
  static FileCheckResult check({
    required int size,
    required Uint8List header,
    required List<String> allowedMimes,
    required int maxBytes,
  }) {
    if (size <= 0) return const FileCheckResult.rejected(FileRejection.empty);
    if (size > maxBytes) {
      return const FileCheckResult.rejected(FileRejection.tooLarge);
    }
    final mime = FileSignature.sniff(header);
    if (mime == null || !allowedMimes.contains(mime)) {
      return const FileCheckResult.rejected(FileRejection.unsupportedType);
    }
    return FileCheckResult.accepted(mime);
  }
}
