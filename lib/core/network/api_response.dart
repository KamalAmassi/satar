class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    required this.message,
    required this.data,
    this.requestId,
    this.raw = const {},
  });

  final bool success;
  final String message;
  final T? data;
  final String? requestId;
  final Map<String, dynamic> raw;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    T? Function(dynamic json)? dataParser,
  }) {
    final dynamic rawData = json['data'];
    return ApiResponse<T>(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: dataParser != null
          ? dataParser(rawData)
          : rawData as T?,
      requestId: json['request_id']?.toString(),
      raw: json,
    );
  }
}
