import 'package:project/core/network/masar_model/masar_models.dart';

/// نتيجة تحليل دفعة من الإشعارات مع معلومات التصفح والعدد غير المقروء.
class NotificationPageResult {
  const NotificationPageResult({
    required this.items,
    required this.unreadCount,
    required this.currentPage,
    required this.lastPage,
    required this.hasMore,
  });

  final List<AppNotification> items;
  final int unreadCount;
  final int currentPage;
  final int lastPage;
  final bool hasMore;
}

/// محلل دفاعي لاستجابات قائمة الإشعارات والتصفح.
abstract final class NotificationPaginationParser {
  static const int defaultPerPage = 20;

  /// تحليل استجابة الباكند لاستخراج الإشعارات، عدد غير المقروء، وحالة التصفح.
  static NotificationPageResult parse({
    required Map<String, dynamic> responseMap,
    required List<AppNotification> existingItems,
    required int requestedPage,
    int perPage = defaultPerPage,
  }) {
    // 1. استخراج القائمة
    final rawData = responseMap['data'] ?? responseMap['items'] ?? responseMap['notifications'];
    final list = rawData is List ? rawData : [];

    final fetchedItems = <AppNotification>[];
    for (final e in list) {
      if (e is Map<String, dynamic>) {
        try {
          fetchedItems.add(AppNotification.fromJson(e));
        } catch (_) {
          // تجاوز أي عنصر غير متوافق بدلاً من إيقاف الصفحة
        }
      }
    }

    // 2. استخراج meta tolerantly
    final meta = responseMap['meta'] is Map<String, dynamic>
        ? responseMap['meta'] as Map<String, dynamic>
        : <String, dynamic>{};

    final unreadCount = (meta['unread'] as num?)?.toInt() ??
        (meta['unread_count'] as num?)?.toInt() ??
        fetchedItems.where((n) => n.unread).length;

    final currentPage = (meta['current_page'] as num?)?.toInt() ?? requestedPage;
    final lastPage = (meta['last_page'] as num?)?.toInt() ?? currentPage;
    final total = (meta['total'] as num?)?.toInt();

    // 3. منع التكرار وإمكانية الجلب الإضافي
    final existingIds = existingItems.map((e) => e.id).toSet();
    final newItems = fetchedItems.where((e) => !existingIds.contains(e.id)).toList();

    bool hasMore;
    if (meta.containsKey('last_page')) {
      hasMore = currentPage < lastPage;
    } else if (meta.containsKey('next_page')) {
      hasMore = meta['next_page'] != null;
    } else if (total != null) {
      hasMore = (existingItems.length + newItems.length) < total;
    } else {
      // الاعتماد الدفاعي على حجم الدفعة وعدم تكرار البيانات
      hasMore = fetchedItems.length >= perPage && newItems.isNotEmpty;
    }

    return NotificationPageResult(
      items: fetchedItems,
      unreadCount: unreadCount,
      currentPage: currentPage,
      lastPage: lastPage,
      hasMore: hasMore,
    );
  }
}
