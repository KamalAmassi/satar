import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/core/config/app_env.dart';
import 'package:project/core/errors/api_error_codes.dart';
import 'package:project/core/errors/error_handler.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/network/idempotency.dart';
import 'package:project/core/uploads/file_signature.dart';
import 'package:project/core/utils/money.dart';
import 'package:project/customer/features/printing/domain/entities/file_check.dart';

DioException _bad(int status, Map<String, dynamic> body) {
  final options = RequestOptions(path: '/x');
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: options, statusCode: status, data: body),
  );
}

Map<String, dynamic> _error(String code, [Map<String, dynamic>? details]) => {
      'success': false,
      'message': 'server message',
      'error': {'code': code, 'details': details},
      'request_id': 'req_1',
    };

void main() {
  group('Money', () {
    test('parses integer minor units and keeps server formatting', () {
      final m = Money.fromJson({'amount': 2375, 'formatted': '23.75 ₪'});
      expect(m.amount, 2375);
      expect(m.display(const CurrencyFormat()), '23.75 ₪');
    });

    test('formats locally with integer arithmetic only', () {
      const c = CurrencyFormat(symbol: '₪', minorUnits: 100);
      expect(c.format(25), '0.25 ₪');
      expect(c.format(1800), '18.00 ₪');
      expect(c.format(-505), '-5.05 ₪');
      expect(const CurrencyFormat(minorUnits: 1).format(7), '7 ₪');
    });

    test('adds without floating point drift', () {
      var total = Money.zero;
      for (var i = 0; i < 10; i++) {
        total = total + const Money(amount: 10); // 0.10 × 10
      }
      expect(total.amount, 100);
    });
  });

  group('AppEnv.normalizeApiBase', () {
    test('never duplicates /api or /v1', () {
      expect(AppEnv.normalizeApiBase('https://masar.toldpath.com'),
          'https://masar.toldpath.com/api');
      expect(AppEnv.normalizeApiBase('https://masar.toldpath.com/'),
          'https://masar.toldpath.com/api');
      expect(AppEnv.normalizeApiBase('https://masar.toldpath.com/api'),
          'https://masar.toldpath.com/api');
      expect(AppEnv.normalizeApiBase('https://masar.toldpath.com/api/'),
          'https://masar.toldpath.com/api');
      expect(AppEnv.normalizeApiBase('https://masar.toldpath.com/api/v1'),
          'https://masar.toldpath.com/api');
    });
  });

  group('ErrorHandler keeps business errors distinct', () {
    test('422 out_of_stock stays a ServerFailure with details', () {
      final f = ErrorHandler.fromDio(
        _bad(422, _error('out_of_stock', {'product_id': 59, 'available': 30})),
      );
      expect(f, isA<ServerFailure>());
      expect(f.code, ApiErrorCodes.outOfStock);
      expect(f.details!['available'], 30);
    });

    test('422 invalid_transition and out_of_zone keep their codes', () {
      expect(
        ErrorHandler.fromDio(_bad(
                422, _error('invalid_transition', {'reason': 'no_open_offer'})))
            .reason,
        'no_open_offer',
      );
      expect(ErrorHandler.fromDio(_bad(422, _error('out_of_zone'))).code,
          ApiErrorCodes.outOfZone);
    });

    test('validation_failed maps field errors per path', () {
      final f = ErrorHandler.fromDio(_bad(
          422,
          _error('validation_failed', {
            'fields': {
              'print_items.1.print_page_range': ['bad range'],
              'cart.0.options.cover_color': ['Choose Cover Color'],
            },
          })));
      expect(f, isA<ValidationFailure>());
      final v = f as ValidationFailure;
      expect(
          v.fieldsUnder('print_items.1.'), {'print_page_range': 'bad range'});
      expect(v.fieldErrors['cart.0.options.cover_color'], 'Choose Cover Color');
    });

    test('409 conflict exposes details.reason', () {
      final f = ErrorHandler.fromDio(
        _bad(409, _error('conflict', {'reason': 'quote_payload_mismatch'})),
      );
      expect(f.code, ApiErrorCodes.conflict);
      expect(f.reason, 'quote_payload_mismatch');
    });

    test('410 quote_expired and quote_used keep their codes', () {
      expect(ErrorHandler.fromDio(_bad(410, _error('quote_expired'))).code,
          ApiErrorCodes.quoteExpired);
      expect(ErrorHandler.fromDio(_bad(410, _error('quote_used'))).code,
          ApiErrorCodes.quoteUsed);
    });

    test('429 exposes retry_after', () {
      final f = ErrorHandler.fromDio(
        _bad(429, _error('too_many_requests', {'retry_after': 51})),
      ) as ServerFailure;
      expect(f.retryAfterSeconds, 51);
    });

    test('timeouts and cancellation have no response', () {
      final options = RequestOptions(path: '/x');
      final timeout = ErrorHandler.fromDio(DioException(
        requestOptions: options,
        type: DioExceptionType.transformTimeout,
      ));
      expect(timeout, isA<TimeoutFailure>());
      expect(timeout.hasNoResponse, isTrue);
      expect(
        ErrorHandler.fromDio(DioException.requestCancelled(
          requestOptions: options,
          reason: 'user',
        )),
        isA<CancelledFailure>(),
      );
    });
  });

  group('File type is read from content, not the extension', () {
    Uint8List b(List<int> v) => Uint8List.fromList(v);

    test('sniffs pdf, png, jpeg and webp', () {
      expect(FileSignature.sniff(b('%PDF-1.4'.codeUnits)), FileSignature.pdf);
      expect(
          FileSignature.sniff(
              b([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])),
          FileSignature.png);
      expect(
          FileSignature.sniff(b([0xFF, 0xD8, 0xFF, 0xE0])), FileSignature.jpeg);
      expect(
        FileSignature.sniff(
            b([...'RIFF'.codeUnits, 0, 0, 0, 0, ...'WEBP'.codeUnits])),
        FileSignature.webp,
      );
      expect(FileSignature.sniff(b('plain text pretending'.codeUnits)), isNull);
    });

    test('FileCheck rejects by size, type and emptiness', () {
      const mimes = ['application/pdf', 'image/png'];
      final pdf = b('%PDF-1.4 rest'.codeUnits);
      expect(
        FileCheck.check(
                size: 100, header: pdf, allowedMimes: mimes, maxBytes: 1000)
            .mime,
        'application/pdf',
      );
      expect(
        FileCheck.check(
                size: 2000, header: pdf, allowedMimes: mimes, maxBytes: 1000)
            .rejection,
        FileRejection.tooLarge,
      );
      expect(
        FileCheck.check(
          size: 10,
          header: b('not a pdf'.codeUnits),
          allowedMimes: mimes,
          maxBytes: 1000,
        ).rejection,
        FileRejection.unsupportedType,
      );
      expect(
        FileCheck.check(
                size: 0, header: pdf, allowedMimes: mimes, maxBytes: 1000)
            .rejection,
        FileRejection.empty,
      );
    });
  });

  test('IdempotencyKey generates distinct UUID v4 values', () {
    final a = IdempotencyKey.generate();
    final b = IdempotencyKey.generate();
    expect(a, isNot(b));
    expect(
      RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')
          .hasMatch(a),
      isTrue,
    );
  });
}
