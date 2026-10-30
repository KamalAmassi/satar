import 'package:flutter_test/flutter_test.dart';
import 'package:project/core/config/remote_config.dart';
import 'package:project/core/utils/money.dart';
import 'package:project/customer/features/printing/domain/entities/page_range.dart';
import 'package:project/customer/features/printing/domain/entities/print_estimate.dart';
import 'package:project/customer/features/printing/domain/entities/print_job.dart';
import 'package:project/customer/features/printing/domain/entities/print_spec.dart';

/// Values copied from the sandbox GET /v1/app/config response (config v8).
const printing = PrintingConfig(
  paperSizes: [
    PaperSizeOption(
      key: 'a4',
      label: 'A4',
      bwSidePrice: Money(amount: 25),
      colorSidePrice: Money(amount: 50),
    ),
    PaperSizeOption(
      key: 'a3',
      label: 'A3',
      bwSidePrice: Money(amount: 100),
      colorSidePrice: Money(amount: 400),
    ),
  ],
  bindings: [
    BindingOption(key: 'none', label: 'None', price: Money(amount: 0)),
    BindingOption(key: 'staple', label: 'Staple', price: Money(amount: 100)),
    BindingOption(key: 'spiral', label: 'Spiral', price: Money(amount: 500)),
    BindingOption(key: 'thermal', label: 'Thermal', price: Money(amount: 1000)),
  ],
  colors: ['bw', 'color'],
  sides: ['single', 'double'],
  maxJobs: 20,
  maxCopies: 500,
  maxPages: 2000,
  fileMimes: ['application/pdf', 'image/png'],
  maxFileBytes: 10 * 1024 * 1024,
  duplexDiscountPercent: 0,
);

PrintJob job({
  int? pages,
  String mime = 'application/pdf',
  PrintSpec spec = const PrintSpec(
    paperSize: 'a4',
    color: 'bw',
    sides: 'single',
    binding: 'none',
  ),
}) =>
    PrintJob(
      id: 'j',
      fileName: 'f',
      size: 1,
      localMime: mime,
      spec: spec,
      status: UploadStatus.uploaded,
      uploadId: 1,
      serverMime: mime == 'application/pdf' ? mime : 'image/webp',
      pages: pages,
    );

void main() {
  group('PageRange', () {
    test('accepts the server format and counts unique pages', () {
      expect(PageRange.parse('1-5, 8, 10-12', totalPages: 12)!.length, 9);
      expect(PageRange.parse('3,3', totalPages: 12), {3});
    });

    test('rejects what the sandbox rejected', () {
      for (final bad in ['2-1', '0', '13', '1-13', 'abc', '1,,2', '1-']) {
        expect(PageRange.isValid(bad, totalPages: 12), isFalse, reason: bad);
      }
    });

    test('"All" means empty: the server rejects the literal word', () {
      expect(PageRange.toRequest('All'), isNull);
      expect(PageRange.toRequest('الكل'), isNull);
      expect(PageRange.toRequest(''), isNull);
      expect(PageRange.toRequest(' 1 - 5 ,8 '), '1-5,8');
      expect(PageRange.parse('', totalPages: 3), {1, 2, 3});
    });
  });

  group('PrintEstimate matches observed sandbox quotes', () {
    test('per printed side: 3 pages A4 bw = 75, single or double', () {
      expect(PrintEstimate.forJob(job(pages: 3), printing)!.amount, 75);
      final duplex = job(
        pages: 3,
        spec: const PrintSpec(
          paperSize: 'a4',
          color: 'bw',
          sides: 'double',
          binding: 'none',
        ),
      );
      expect(PrintEstimate.forJob(duplex, printing)!.amount, 75);
    });

    test('binding is charged per copy (two-file quote = 1800)', () {
      final a = job(
        pages: 3,
        spec: const PrintSpec(
          paperSize: 'a4',
          color: 'color',
          sides: 'single',
          binding: 'staple',
          copies: 2,
          pageRange: '1-2',
        ),
      );
      final b = job(
        pages: 12,
        spec: const PrintSpec(
          paperSize: 'a3',
          color: 'bw',
          sides: 'double',
          binding: 'spiral',
          pageRange: '1-5, 8, 10-12',
        ),
      );
      final total = PrintEstimate.forJob(a, printing)!.amount +
          PrintEstimate.forJob(b, printing)!.amount;
      expect(total, 1800);
    });

    test('images count as one page; thermal 12 pages = 1300', () {
      final image = job(
        mime: 'image/png',
        spec: const PrintSpec(
          paperSize: 'a4',
          color: 'color',
          sides: 'single',
          binding: 'none',
        ),
      );
      expect(image.knownPages, 1);
      expect(PrintEstimate.forJob(image, printing)!.amount, 50);
      final thermal = job(
        pages: 12,
        spec: const PrintSpec(
          paperSize: 'a4',
          color: 'bw',
          sides: 'single',
          binding: 'thermal',
        ),
      );
      expect(PrintEstimate.forJob(thermal, printing)!.amount, 1300);
    });

    test('no estimate while pages are unknown or the range is invalid', () {
      final uploading = PrintJob(
        id: 'u',
        fileName: 'f.pdf',
        size: 1,
        localMime: 'application/pdf',
        spec: const PrintSpec(
          paperSize: 'a4',
          color: 'bw',
          sides: 'single',
          binding: 'none',
        ),
      );
      expect(PrintEstimate.forJob(uploading, printing), isNull);
      final badRange = job(
        pages: 3,
        spec: const PrintSpec(
          paperSize: 'a4',
          color: 'bw',
          sides: 'single',
          binding: 'none',
          pageRange: '5',
        ),
      );
      expect(PrintEstimate.forJob(badRange, printing), isNull);
    });
  });
}
