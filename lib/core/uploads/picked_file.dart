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
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _extensions,
      allowMultiple: multiple,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return [];
    final picked = <PickedFile>[];
    for (final f in result.files) {
      picked.add(
        PickedFile(
          name: f.name,
          size: f.size,
          readBytes: () async => f.bytes ?? await f.xFile.readAsBytes(),
        ),
      );
    }
    return picked;
  }
}
