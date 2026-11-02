class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.requestId,
    this.code,
    this.fields = const {},
    this.cause,
  });

  final String message;
  final int? statusCode;
  final String? requestId;

  /// error.code القادم من السيرفر (مثل already_taken / cash_limit_reached).
  final String? code;
  final Map<String, dynamic> fields;
  final Object? cause;

  @override
  String toString() => message;
}
