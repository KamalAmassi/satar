import 'package:equatable/equatable.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/network/idempotency.dart';
import 'package:project/customer/features/checkout/domain/entities/placed_order.dart';

/// محاولة إنشاء طلب منطقية واحدة.
///
/// المفتاح يُولَّد مرة واحدة لكل تسعيرة ويُعاد استخدامه عند إعادة المحاولة،
/// ولا يتغيّر بسبب انتهاء مهلة الرد. الخادم يعيد نفس الطلب لنفس المفتاح.
class OrderSubmission extends Equatable {
  const OrderSubmission({
    required this.idempotencyKey,
    required this.quoteToken,
    required this.note,
    this.productRevisions = const {},
    this.printRevisions = const {},
  });

  factory OrderSubmission.start({
    required String quoteToken,
    required String note,
    Map<String, int> productRevisions = const {},
    Map<String, int> printRevisions = const {},
  }) =>
      OrderSubmission(
        idempotencyKey: IdempotencyKey.generate(),
        quoteToken: quoteToken,
        note: note,
        productRevisions: productRevisions,
        printRevisions: printRevisions,
      );

  final String idempotencyKey;
  final String quoteToken;

  /// جزء من جسم الطلب: يجب أن يبقى مطابقًا عند إعادة المحاولة بنفس المفتاح.
  final String note;

  /// ما أُرسل من السلة، لحذفه وحده بعد التأكد من النجاح.
  final Map<String, int> productRevisions;
  final Map<String, int> printRevisions;

  Map<String, dynamic> toBody() => {
        'quote_token': quoteToken,
        if (note.trim().isNotEmpty) 'note': note.trim(),
      };

  Map<String, dynamic> toJson() => {
        'key': idempotencyKey,
        'quote_token': quoteToken,
        'note': note,
        'products': productRevisions,
        'prints': printRevisions,
      };

  factory OrderSubmission.fromJson(Map<String, dynamic> json) =>
      OrderSubmission(
        idempotencyKey: json['key'] as String,
        quoteToken: json['quote_token'] as String,
        note: json['note'] as String? ?? '',
        productRevisions: Map<String, int>.from(json['products'] as Map? ?? {}),
        printRevisions: Map<String, int>.from(json['prints'] as Map? ?? {}),
      );

  @override
  List<Object?> get props => [idempotencyKey, quoteToken, note];
}

sealed class SubmitOutcome {
  const SubmitOutcome();

  /// يصنّف نتيجة محاولة إنشاء الطلب.
  static SubmitOutcome fromFailure(Failure failure) {
    final status = failure.statusCode;
    if (failure.hasNoResponse || (status != null && status >= 500)) {
      return SubmitUncertain(failure);
    }
    return SubmitRejected(failure);
  }
}

/// أُنشئ الطلب وتأكدنا منه.
class SubmitCreated extends SubmitOutcome {
  const SubmitCreated(this.order);
  final PlacedOrder order;
}

/// رد صريح من الخادم: لم يُنشأ الطلب بهذه المحاولة.
class SubmitRejected extends SubmitOutcome {
  const SubmitRejected(this.failure);
  final Failure failure;
}

/// لا نعرف إن أُنشئ الطلب (انقطاع، مهلة، خطأ خادم).
class SubmitUncertain extends SubmitOutcome {
  const SubmitUncertain(this.failure);
  final Failure failure;
}
