import 'dart:typed_data';

/// يحدد نوع الملف من بايتاته الأولى لا من امتداده.
/// الخادم يفحص المحتوى أيضًا وقراره هو النهائي.
abstract final class FileSignature {
  static const pdf = 'application/pdf';
  static const png = 'image/png';
  static const jpeg = 'image/jpeg';
  static const webp = 'image/webp';

  static String? sniff(Uint8List bytes) {
    bool starts(List<int> sig, [int offset = 0]) {
      if (bytes.length < offset + sig.length) return false;
      for (var i = 0; i < sig.length; i++) {
        if (bytes[offset + i] != sig[i]) return false;
      }
      return true;
    }

    if (starts(const [0x25, 0x50, 0x44, 0x46, 0x2D])) return pdf; // %PDF-
    if (starts(const [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])) {
      return png;
    }
    if (starts(const [0xFF, 0xD8, 0xFF])) return jpeg;
    if (starts(const [0x52, 0x49, 0x46, 0x46]) && // RIFF....WEBP
        starts(const [0x57, 0x45, 0x42, 0x50], 8)) {
      return webp;
    }
    return null;
  }

  static bool isImage(String? mime) =>
      mime != null && mime.startsWith('image/');
}
