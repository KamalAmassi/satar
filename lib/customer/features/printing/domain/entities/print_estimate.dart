import 'package:project/core/config/remote_config.dart';
import 'package:project/core/utils/money.dart';
import 'package:project/customer/features/printing/domain/entities/page_range.dart';
import 'package:project/customer/features/printing/domain/entities/print_job.dart';

/// تقدير محلي للعرض فقط من أسعار الإعداد. التسعيرة من الخادم هي المرجع.
///
/// السعر لكل وجه مطبوع: الطباعة على وجهين لا تقلل عدد الأوجه المطبوعة،
/// والتجليد يُحسب لكل نسخة (مطابق لما لوحظ في تسعيرات الخادم التجريبية).
abstract final class PrintEstimate {
  static Money? forJob(PrintJob job, PrintingConfig config) {
    final total = job.knownPages;
    if (total == null) return null;
    final pages = PageRange.parse(job.spec.pageRange, totalPages: total);
    if (pages == null || pages.isEmpty) return null;
    final paper = config.paper(job.spec.paperSize);
    if (paper == null) return null;
    final side =
        job.spec.color == 'color' ? paper.colorSidePrice : paper.bwSidePrice;
    var printing = side.amount * pages.length;
    final discount = config.duplexDiscountPercent;
    if (job.spec.sides == 'double' && discount > 0) {
      printing -= printing * discount ~/ 100;
    }
    final binding = config.binding(job.spec.binding)?.price.amount ?? 0;
    return Money(amount: (printing + binding) * job.spec.copies);
  }

  /// عدد الصفحات المختارة لعرض "٤٠ صفحة × ٢ نسخة".
  static int? selectedPages(PrintJob job) {
    final total = job.knownPages;
    if (total == null) return null;
    return PageRange.parse(job.spec.pageRange, totalPages: total)?.length;
  }
}
