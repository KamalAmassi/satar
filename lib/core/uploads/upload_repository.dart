import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:project/core/errors/error_handler.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/network/api_client.dart';

/// غرض الرفع كما يتوقعه الخادم. الخادم يقبل أي نص مطابق للنمط،
/// لذلك يجب إرسال الغرض الصحيح دائمًا.
abstract final class UploadPurpose {
  static const printFile = 'print_file';
  static const paymentReceipt = 'payment_receipt';
}

/// نتيجة POST /v1/uploads.
class UploadedFile extends Equatable {
  const UploadedFile({
    required this.uploadId,
    required this.mime,
    required this.size,
    this.pages,
    this.purpose,
  });

  final int uploadId;

  /// النوع بعد معالجة الخادم (الصور تُعاد ترميزها إلى image/webp).
  final String mime;
  final int size;

  /// عدد صفحات PDF من الخادم؛ null للصور.
  final int? pages;
  final String? purpose;

  factory UploadedFile.fromJson(Map<String, dynamic> json) => UploadedFile(
        uploadId: json['upload_id'] as int,
        mime: json['mime'] as String? ?? '',
        size: json['size'] as int? ?? 0,
        pages: json['pages'] as int?,
        purpose: json['purpose'] as String?,
      );

  @override
  List<Object?> get props => [uploadId, mime, size, pages, purpose];
}

class UploadRepository {
  UploadRepository(this._api);

  final ApiClient _api;

  Future<Either<Failure, UploadedFile>> upload({
    required Uint8List bytes,
    required String fileName,
    required String mime,
    required String purpose,
    void Function(double progress)? onProgress,
    CancelToken? cancelToken,
  }) =>
      ErrorHandler.guard(() async {
        final form = FormData.fromMap({
          'purpose': purpose,
          'file': MultipartFile.fromBytes(
            bytes,
            filename: fileName,
            contentType: DioMediaType.parse(mime),
          ),
        });
        final res = await _api.dio.post<dynamic>(
          'v1/uploads',
          data: form,
          cancelToken: cancelToken,
          onSendProgress: (sent, total) {
            if (total > 0) onProgress?.call(sent / total);
          },
        );
        return UploadedFile.fromJson(ApiClient.unwrapMap(res));
      });
}
