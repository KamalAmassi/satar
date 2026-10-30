import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

/// ملف اختاره المستخدم، مستقل عن مكتبة الاختيار.
class PickedFile {
  const PickedFile({
    required this.name,
    required this.size,
    required this.readBytes,
  });

  final String name;
  final int size;
  final Future<Uint8List> Function() readBytes;
}

/// مصدر الملفات (يُستبدل في الاختبارات).
abstract class FileSource {
  Future<List<PickedFile>> pick({required bool multiple});
}

class FilePickerSource implements FileSource {
  const FilePickerSource();

  static const _extensions = ['pdf', 'jpg', 'jpeg', 'png', 'webp'];

  @override
  Future<List<PickedFile>> pick({required bool multiple}) async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: _extensions,
    );
    final picked = <PickedFile>[];
    for (final f in multiple ? files : files.take(1)) {
      picked.add(
        PickedFile(
          name: f.name,
          size: f.lengthSync() ?? await f.length() ?? 0,
          readBytes: f.readAsBytes,
        ),
      );
    }
    return picked;
  }
}
