import 'package:dio/dio.dart';
import 'package:project/core/network/api_client.dart';
import 'package:project/core/network/api_endpoints.dart';
import 'package:project/core/utils/json_utils.dart';

/// رفع صور الإثبات: POST /uploads (purpose=proof_photo) → upload_id
class UploadService {
  const UploadService(this._api);

  final ApiClient _api;

  Future<int> uploadProofPhoto(String path) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(path),
      'purpose': 'proof_photo',
    });
    final data = await _api.postData(ApiEndpoints.uploads, data: form);
    // نقرأ upload_id فقط (لا نفرض باقي حقول Upload حتى لا يفشل الرفع).
    final id = asInt(pick(unwrapKey(data, 'upload'), const ['upload_id', 'id']));
    if (id == null) throw const FormatException('upload_id missing');
    return id;
  }
}
