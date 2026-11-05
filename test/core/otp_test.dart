import 'dart:convert';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/core/otp/data/mock_otp_gateway.dart';
import 'package:project/core/otp/data/twilio_verify_gateway.dart';
import 'package:project/core/otp/domain/otp_failures.dart';
import 'package:project/core/utils/phone_normalizer.dart';

/// محوّل Dio وهمي: يعيد ردًا ثابتًا ويسجل آخر طلب (بلا شبكة).
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.status, this.body, {this.error});
  final int status;
  final Object body;
  final DioExceptionType? error;
  RequestOptions? last;
  String? lastBody;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    last = options;
    if (requestStream != null) lastBody = utf8.decode(await requestStream.expand((b) => b).toList());
    if (error != null) throw DioException(requestOptions: options, type: error!);
    return ResponseBody.fromString(jsonEncode(body), status, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

TwilioVerifyGateway _gw(_FakeAdapter a) {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://verify.twilio.com/v2/Services/VA_test',
    contentType: Headers.formUrlEncodedContentType,
    validateStatus: (_) => true,
  ))
    ..httpClientAdapter = a;
  return TwilioVerifyGateway(accountSid: 'AC_test', authToken: 'secret', serviceSid: 'VA_test', dio: dio);
}

Object? _left<L, R>(Either<L, R> e) => e.fold((l) => l, (_) => null);

void main() {
  group('PhoneNormalizer', () {
    test('local Palestinian formats → +970', () {
      expect(PhoneNormalizer.toE164('0599123456'), '+970599123456');
      expect(PhoneNormalizer.toE164('599123456'), '+970599123456');
      expect(PhoneNormalizer.toE164('059-912 3456'), '+970599123456');
      expect(PhoneNormalizer.toE164('00970599123456'), '+970599123456');
      expect(PhoneNormalizer.toE164('970599123456'), '+970599123456');
      expect(PhoneNormalizer.toE164('+970 59 912 3456'), '+970599123456');
      expect(PhoneNormalizer.toE164('٠٥٩٩١٢٣٤٥٦'), '+970599123456');
    });

    test('+972 inputs and a +972 default', () {
      expect(PhoneNormalizer.toE164('+972521234567'), '+972521234567');
      expect(PhoneNormalizer.toE164('00972521234567'), '+972521234567');
      expect(PhoneNormalizer.toE164('0521234567', defaultCountryCode: '+972'), '+972521234567');
    });

    test('rejects invalid numbers', () {
      expect(PhoneNormalizer.toE164(''), isNull);
      expect(PhoneNormalizer.toE164('12345'), isNull);
      expect(PhoneNormalizer.toE164('05991234'), isNull); // قصير
      expect(PhoneNormalizer.toE164('+970499123456'), isNull); // ليس جوالًا
      expect(PhoneNormalizer.toE164('+97059912345678'), isNull); // طويل
      expect(PhoneNormalizer.toE164('05991234ab'), isNull);
      expect(PhoneNormalizer.toE164('+1234567890123456'), isNull); // > 15
    });

    test('mask hides the middle', () {
      expect(PhoneNormalizer.mask('+970599123456'), '+9705******56');
      expect(PhoneNormalizer.mask('+970599123456'), isNot(contains('91234')));
    });
  });

  group('TwilioVerifyGateway', () {
    test('send: 201 + pending → success, form-encoded To/Channel, basic auth', () async {
      final a = _FakeAdapter(201, {'status': 'pending'});
      expect((await _gw(a).send('+970599123456')).isRight(), isTrue);
      expect(a.last!.path, endsWith('/Verifications'));
      expect(a.last!.headers['Authorization'], startsWith('Basic '));
      expect(a.lastBody, contains('To=%2B970599123456'));
      expect(a.lastBody, contains('Channel=sms'));
    });

    test('verify: approved → success; pending → invalid code', () async {
      expect((await _gw(_FakeAdapter(200, {'status': 'approved'})).verify('+970599123456', '123456')).isRight(), isTrue);
      expect(_left(await _gw(_FakeAdapter(200, {'status': 'pending'})).verify('+970599123456', '000000')), isA<OtpInvalidCode>());
    });

    test('maps Twilio errors', () async {
      Future<Object?> send(int s, Map<String, Object> b) async => _left(await _gw(_FakeAdapter(s, b)).send('+970599123456'));
      Future<Object?> check(int s, Map<String, Object> b) async => _left(await _gw(_FakeAdapter(s, b)).verify('+970599123456', '1'));
      expect(await check(404, {'code': 20404, 'status': 404}), isA<OtpExpired>());
      expect(await send(429, {'code': 60203, 'status': 429}), isA<OtpTooManyAttempts>());
      expect(await check(429, {'code': 60202, 'status': 429}), isA<OtpTooManyAttempts>());
      expect(await send(400, {'code': 21608, 'status': 400}), isA<OtpPhoneNotAllowed>());
      expect(await send(403, {'code': 60605, 'status': 403}), isA<OtpPhoneNotAllowed>());
      expect(await send(400, {'code': 60410, 'status': 400}), isA<OtpPhoneNotAllowed>());
      expect(await send(401, {'code': 20003, 'status': 401}), isA<OtpUnavailable>());
      expect(await send(500, {}), isA<OtpUnavailable>());
    });

    test('network and timeout → OtpNetwork', () async {
      expect(_left(await _gw(_FakeAdapter(0, {}, error: DioExceptionType.connectionError)).send('+970599123456')), isA<OtpNetwork>());
      expect(_left(await _gw(_FakeAdapter(0, {}, error: DioExceptionType.receiveTimeout)).verify('+970599123456', '1')), isA<OtpNetwork>());
    });
  });

  group('MockOtpGateway', () {
    const g = MockOtpGateway();
    test('send always succeeds; only 1234 verifies', () async {
      expect((await g.send('+970599123456')).isRight(), isTrue);
      expect((await g.verify('+970599123456', '1234')).isRight(), isTrue);
      expect(_left(await g.verify('+970599123456', '0000')), isA<OtpInvalidCode>());
    });
  });
}
