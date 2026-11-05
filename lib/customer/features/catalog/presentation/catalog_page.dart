import 'dart:async';

import 'package:project/core/animations/fly_to_cart/cart_target.dart';
import 'package:project/core/animations/fly_to_cart/fly_to_cart.dart';
import 'package:project/core/animations/fly_to_cart/fly_to_cart_button.dart';
import 'package:project/core/design/pressable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/config/remote_config_repository.dart';
import 'package:project/core/design/icons.dart';
import 'package:project/core/design/illustrations.dart';
import 'package:project/core/design/shell.dart';
import 'package:project/core/design/tokens.dart';
import 'package:project/core/design/widgets.dart';
import 'package:project/core/extensions/context_extensions.dart';
import 'package:project/core/widgets/image_viewer.dart';
import 'package:project/core/widgets/product_hero.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/storage/session_store.dart';
import 'package:project/core/utils/haptics.dart';
import 'package:project/customer/features/cart/domain/entities/cart_product_line.dart';
import 'package:project/customer/features/cart/presentation/controllers/cart_controller.dart';
import 'package:project/core/data/models.dart';
import 'package:project/core/widgets/common_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _catIcons = ['book', 'layers', 'box', 'grid', 'printer'];
String catIcon(CategoryModel c, int i) {
  final n = c.name;
  if (n.contains('طباع')) return 'printer';
  if (n.contains('كتب') || n.contains('كتاب')) return 'layers';
  if (n.contains('هد') || n.contains('ألعاب')) return 'box';
  if (n.contains('مكتب') || n.contains('أدوات')) return 'grid';
  return _catIcons[i % _catIcons.length];
}

void quickAdd(ProductModel p, {BuildContext? context, GlobalKey? sourceKey}) {
  if (p.hasRequiredOptions || p.isInspection || p.isService) {
    Get.toNamed('/product', arguments: {'id': p.id});
    return;
  }
  final line = cartCtl.addProduct(CartItemRequest(productId: p.id), maxQty: p.maxQty);
  if (line == null) return;
  if (context != null && sourceKey != null && context.mounted) {
    FlyToCart.run(context, sourceKey: sourceKey, image: FlyToCart.productImage(context, sourceKey, p.imageUrl));
  } else {
    Haptics.confirm();
  }
  showToast('أضيف «${p.name}» إلى السلة', actionLabel: 'عرض', onAction: () => Get.toNamed('/cart'));
}

Map<String, Object?> productRouteArgs(ProductModel p, String heroScope) =>
    {'id': p.id, 'image': p.imageUrl, 'name': p.name, 'heroScope': heroScope};

class ProductCard extends StatelessWidget {
  const ProductCard(this.p, {super.key, this.width, this.heroScope = 'card'});
  final ProductModel p;
  final double? width;
  final String heroScope;

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final disc = p.discountPct;
    return FlyToCartSource(builder: (context, flyKey) => SizedBox(
      width: width,
      child: GestureDetector(
        onTapDown: (_) => precacheProductImage(context, p.imageUrl),
        onTap: () => Get.toNamed('/product', arguments: productRouteArgs(p, heroScope)),
        behavior: HitTestBehavior.opaque,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Rad.l),
              child: Stack(fit: StackFit.expand, children: [
                KeyedSubtree(key: flyKey, child: ProductHero(tag: productHeroTag(heroScope, p.id), radius: Rad.l, child: ProductArt(imageUrl: p.imageUrl, name: p.name, seed: p.id))),
                if (disc != null) PositionedDirectional(top: 10, start: 10, child: STag('خصم $disc٪')),
                if (!p.inStock)
                  Container(
                    color: c.bg.withValues(alpha: .62),
                    alignment: Alignment.center,
                    child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: c.tx, borderRadius: BorderRadius.circular(999)), child: Text('غير متوفر', style: TextStyle(fontFamily: Fonts.ui, fontSize: 13, fontWeight: FontWeight.w700, color: c.bg))),
                  ),
              ]),
            ),
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: Fonts.ui, fontSize: 14.5, fontWeight: FontWeight.w600, height: 1.5, color: c.tx)),
          ),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                p.isInspection ? Text('بعد المعاينة', style: T.sm(c.tx2)) : Mny(p.price.amount),
                if (p.comparePrice != null && (disc ?? 0) > 0) Mny(p.comparePrice!.amount, strike: true, size: 14),
              ]),
            ),
            if (p.inStock)
              GestureDetector(
                onTap: () => quickAdd(p, context: context, sourceKey: flyKey),
                child: PressableScale(child: Container(width: 44, height: 44, decoration: BoxDecoration(color: c.pri, shape: BoxShape.circle), child: Center(child: SIcon('plus', size: 22, color: c.onPri)))),
              ),
          ]),
        ]),
      ),
    ));
  }
}

class CartBadgeButton extends StatelessWidget {
  const CartBadgeButton({super.key});
  @override
  Widget build(BuildContext context) => CartTargetAnchor(
        child: Obx(() {
          cartCtl.revision.value;
          final n = cartCtl.itemCount;
          return Semantics(
            label: context.l10n.cartBadgeLabel(n),
            button: true,
            excludeSemantics: true,
            child: SIconBtn('bag', badge: n > 0 ? '$n' : null, onTap: () => Get.toNamed('/cart')),
          );
        }),
      );
}

Widget stickyCartOverlay() => Obx(() {
      cartCtl.revision.value;
      cartCtl.productInfo.length;
      if (cartCtl.isEmpty) return const SizedBox.shrink();
      final e = cartEstimate();
      return StickyCart(count: cartCtl.itemCount, totalMinor: e.products + e.printing, onTap: () => Get.toNamed('/cart'));
    });

class HomeController extends GetxController {
  final loading = true.obs;
  final failure = Rxn<Failure>();
  final categories = <CategoryModel>[].obs;
  final products = <ProductModel>[].obs;
  final activeOrder = Rxn<OrderSummaryModel>();
  final unread = 0.obs;
  final address = Rxn<AddressModel>();
  final userName = RxnString();

  @override
  void onInit() {
    super.onInit();
    cartCtl.ensureLoaded();
    load();
  }

  Future<void> load() async {
    failure.value = null;
    if (categories.isEmpty) loading.value = true;
    final results = await Future.wait([
      backend.categories(),
      backend.products(perPage: 10),
      backend.orders(scope: 'active', perPage: 5),
      backend.notifications(unread: true, perPage: 20),
      backend.addresses(),
      backend.me(),
    ]);
    results[0].fold((f) => failure.value = f, (v) => categories.assignAll(v as List<CategoryModel>));
    results[1].fold((f) => failure.value ??= f, (v) => products.assignAll((v as ProductsPage).items));
    results[2].fold((_) {}, (v) {
      final l = v as List<OrderSummaryModel>;
      activeOrder.value = l.isEmpty ? null : l.firstWhereOrNull((o) => o.status.key == 'priced') ?? l.first;
    });
    results[3].fold((_) {}, (v) => unread.value = (v as List).length);
    results[4].fold((_) {}, (v) {
      final l = v as List<AddressModel>;
      address.value = l.firstWhereOrNull((a) => a.isDefault) ?? (l.isEmpty ? null : l.first);
    });
    results[5].fold((_) {}, (v) => userName.value = (v as UserModel).name);
    loading.value = false;
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final ctl = Get.put(HomeController());
    return Obx(() {
      if (ctl.loading.value) return const HomeSkeleton();
      if (ctl.failure.value != null && ctl.categories.isEmpty) {
        return Page2(
          tab: 'home',
          center: true,
          body: EmptyState(ill: 'offline', title: 'تعذّر التحميل', text: failureText(ctl.failure.value!), cta: SBtn('أعد المحاولة', icon: 'refresh', full: true, onTap: ctl.load)),
        );
      }
      final inits = (ctl.userName.value ?? '').trim();
      return Page2(
        tab: 'home',
        onRefresh: ctl.load,
        floating: stickyCartOverlay(),
        body: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              GestureDetector(
                onTap: () => Get.toNamed('/addresses'),
                behavior: HitTestBehavior.opaque,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48, maxWidth: 220),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Avatar(inits.isEmpty ? 'س' : firstCh(inits)),
                    const SizedBox(width: 10),
                    Flexible(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                      Text('التوصيل إلى', style: T.cap(c.tx2)),
                      Row(mainAxisSize: MainAxisSize.min, children: [Flexible(child: Text(ctl.address.value?.title ?? 'أضف عنوانًا', maxLines: 1, overflow: TextOverflow.ellipsis, style: T.h3(c.tx, size: 15.5))), const SizedBox(width: 4), SIcon('chevD', size: 16, color: c.tx)]),
                    ])),
                  ]),
                ),
              ),
              Row(children: [SIconBtn('bell', badge: ctl.unread.value > 0 ? '${ctl.unread.value}' : null, onTap: () => Get.toNamed('/notifications')), const CartBadgeButton()]),
            ]),
            const SizedBox(height: 24),
            _SearchField(label: 'ابحث عن دفتر، قلم، كتاب…', onTap: () => Get.toNamed('/search')),
            if (ctl.activeOrder.value != null) ...[const SizedBox(height: 24), _ActiveOrderCard(ctl.activeOrder.value!)],
            const SizedBox(height: 24),
            HeroBox(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 8, 20),
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('المساعد الذكي', style: T.eyebrow(c.onHero.withValues(alpha: .75))),
                    const SizedBox(height: 8),
                    Text('قُل ما تحتاج،\nونجهّز السلة', style: T.d2(c.onHero, size: 25, height: 1.4)),
                    const SizedBox(height: 14),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      SBtn('تحدّث', size: BtnSize.sm, icon: 'mic', onTap: () => Get.toNamed('/assistant', arguments: {'listen': true})),
                      Material(
                        color: c.onHero.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(Rad.m),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(Rad.m),
                          onTap: () => goTab('/assistant'),
                          child: Container(height: 44, padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(mainAxisSize: MainAxisSize.min, children: [SIcon('edit', size: 20, color: c.onHero), const SizedBox(width: 8), Text('اكتب', style: TextStyle(fontFamily: Fonts.ui, fontSize: 14.5, fontWeight: FontWeight.w600, color: c.onHero))])),
                        ),
                      ),
                    ]),
                  ]),
                ),
                const Ill('assist', width: 112),
              ]),
            ),
            const SizedBox(height: 24),
            Panel(
              onTap: () => goTab('/print'),
              child: Row(children: [
                Container(width: 52, height: 52, decoration: BoxDecoration(color: c.sf, borderRadius: BorderRadius.circular(16)), child: Center(child: SIcon('printer', size: 28, color: c.plumInk))),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('اطبع ملفاتك', style: T.h3(c.tx)), Text('PDF وصور، بتجليد وبأحجام ورق مختلفة', style: T.sm(c.tx2))])),
                SIcon('chevL', size: 20, color: c.tx),
              ]),
            ),
            const SizedBox(height: 24),
            SecHead('التصنيفات', trailing: SLink('عرض الكل', onTap: () => Get.toNamed('/categories'))),
            const SizedBox(height: 8),
            SizedBox(
              height: 112,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: ctl.categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (_, i) {
                  final cat = ctl.categories[i];
                  return GestureDetector(
                    onTap: () => Get.toNamed('/products', arguments: {'category': cat.id, 'title': cat.name}),
                    child: SizedBox(
                      width: 78,
                      child: Column(children: [
                        Container(width: 68, height: 68, decoration: BoxDecoration(color: i.isEven ? c.hero : c.sf2, borderRadius: BorderRadius.circular(22)), child: Center(child: SIcon(catIcon(cat, i), size: 28, color: c.plumInk))),
                        const SizedBox(height: 8),
                        Text(cat.name, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: Fonts.ui, fontSize: 13, fontWeight: FontWeight.w600, height: 1.35, color: c.tx)),
                      ]),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SecHead('الأكثر طلبًا', trailing: SLink('المزيد', onTap: () => Get.toNamed('/products', arguments: {'title': 'المنتجات'}))),
            const SizedBox(height: 8),
            SizedBox(
              height: 290,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: ctl.products.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (_, i) => ProductCard(ctl.products[i], width: 150, heroScope: 'home'),
              ),
            ),
            SizedBox(height: cartCtl.isEmpty ? 0 : 60),
          ]),
        ),
      );
    });
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(color: c.sf2, borderRadius: BorderRadius.circular(999)),
        child: Row(children: [SIcon('search', size: 22, color: c.tx2), const SizedBox(width: 10), Text(label, style: TextStyle(fontFamily: Fonts.ui, fontSize: 15, color: c.tx2))]),
      ),
    );
  }
}

class _ActiveOrderCard extends StatelessWidget {
  const _ActiveOrderCard(this.o);
  final OrderSummaryModel o;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Card2(
      onTap: () => Get.toNamed('/order', arguments: {'order_id': o.id}),
      child: Row(children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(color: c.plumSoft, shape: BoxShape.circle), child: Center(child: SIcon('truck', size: 24, color: c.plumInk))),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('طلبك الحالي · ${o.code}', style: T.cap(c.tx2)), Text(kStatusTone[o.status.key]?.$2 ?? statusLabel(o.status), style: T.h3(c.tx, size: 15.5))])),
        SIcon('chevL', size: 20, color: c.tx),
      ]),
    );
  }
}

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});
  @override
  Widget build(BuildContext context) => const Page2(
        tab: 'home',
        body: Padding(
          padding: EdgeInsets.only(top: 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Skel(w: 200, h: 44, r: 14),
            SizedBox(height: 24),
            Skel(h: 52, r: 26),
            SizedBox(height: 24),
            Skel(h: 150, r: 28),
            SizedBox(height: 24),
            Row(children: [Skel(w: 68, h: 90, r: 20), SizedBox(width: 14), Skel(w: 68, h: 90, r: 20), SizedBox(width: 14), Skel(w: 68, h: 90, r: 20), SizedBox(width: 14), Skel(w: 68, h: 90, r: 20)]),
            SizedBox(height: 24),
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Skel(h: 150, r: 20), SizedBox(height: 8), Skel(h: 14), SizedBox(height: 8), Skel(w: 80, h: 14)])),
              SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Skel(h: 150, r: 20), SizedBox(height: 8), Skel(h: 14), SizedBox(height: 8), Skel(w: 80, h: 14)])),
            ]),
          ]),
        ),
      );
}

class CategoriesController extends GetxController {
  final kind = 'product'.obs;
  final list = <CategoryModel>[].obs;
  final loading = true.obs;
  final failure = Rxn<Failure>();
  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    failure.value = null;
    final r = await backend.categories(kind: kind.value);
    r.fold((f) => failure.value = f, (v) => list.assignAll(v));
    loading.value = false;
  }
}

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final ctl = Get.put(CategoriesController());
    return Page2(
      tab: 'home',
      top: const TopBar(title: 'التصنيفات', right: CartBadgeButton()),
      onRefresh: ctl.load,
      body: Obx(() {
        final bgs = [c.hero, c.sf2, c.amberSoft, c.sf2, c.plumSoft];
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Seg(items: const [('product', 'منتجات'), ('service', 'خدمات')], value: ctl.kind.value, onChanged: (k) {
            ctl.kind.value = k;
            ctl.load();
          }),
          const SizedBox(height: 16),
          if (ctl.loading.value)
            const Row(children: [Expanded(child: Skel(h: 120, r: 20)), SizedBox(width: 12), Expanded(child: Skel(h: 120, r: 20))])
          else if (ctl.failure.value != null)
            EmptyState(ill: 'offline', title: 'تعذّر التحميل', text: failureText(ctl.failure.value!), cta: SBtn('أعد المحاولة', onTap: ctl.load, full: true))
          else if (ctl.list.isEmpty)
            const EmptyState(ill: 'books', title: 'لا تصنيفات هنا', text: 'جرّب النوع الآخر.')
          else
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.25,
              children: [
                for (var i = 0; i < ctl.list.length; i++)
                  Panel(
                    color: bgs[i % bgs.length],
                    onTap: () => Get.toNamed('/products', arguments: {'category': ctl.list[i].id, 'title': ctl.list[i].name, 'kind': ctl.kind.value}),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      SIcon(catIcon(ctl.list[i], i), size: 30, color: c.plumInk),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(ctl.list[i].name, style: T.h3(c.tx)), Text('${ctl.list[i].productsCount} منتجًا', style: T.sm(c.tx2))]),
                    ]),
                  ),
              ],
            ),
        ]);
      }),
    );
  }
}

class ProductsController extends GetxController {
  int? category;
  String? kind;
  String title = 'المنتجات';
  final items = <ProductModel>[].obs;
  final loading = true.obs;
  final loadingMore = false.obs;
  final failure = Rxn<Failure>();
  final onlyInStock = false.obs;
  final categories = <CategoryModel>[].obs;
  int _page = 1;
  bool _hasMore = true;
  final scroll = ScrollController();

  @override
  void onInit() {
    super.onInit();
    final a = Get.arguments;
    if (a is Map) {
      category = a['category'] as int?;
      kind = a['kind'] as String?;
      title = a['title'] as String? ?? title;
    }
    scroll.addListener(() {
      if (scroll.position.pixels > scroll.position.maxScrollExtent - 300) more();
    });
    backend.categories().then((r) => r.fold((_) {}, (v) => categories.assignAll(v)));
    load();
  }

  Future<void> load() async {
    loading.value = true;
    failure.value = null;
    _page = 1;
    final r = await backend.products(category: category, kind: kind, perPage: 50);
    r.fold((f) => failure.value = f, (p) {
      items.assignAll(p.items);
      _hasMore = p.hasMore;
    });
    loading.value = false;
  }

  Future<void> more() async {
    if (!_hasMore || loadingMore.value || loading.value) return;
    loadingMore.value = true;
    final r = await backend.products(category: category, kind: kind, page: _page + 1);
    r.fold((_) {}, (p) {
      _page = p.page;
      final fresh = p.items.where((n) => items.every((e) => e.id != n.id)).toList();
      items.addAll(fresh);
      _hasMore = p.hasMore && fresh.isNotEmpty;
    });
    loadingMore.value = false;
  }

  List<ProductModel> get shown => onlyInStock.value ? items.where((p) => p.inStock).toList() : items.toList();
  void setCategory(int? id, String name) {
    category = id;
    title = id == null ? 'المنتجات' : name;
    load();
  }

  void setKind(String? k) {
    kind = k;
    load();
  }

  @override
  void onClose() {
    scroll.dispose();
    super.onClose();
  }
}

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final ctl = Get.put(ProductsController());
    return Obx(() {
      final l = ctl.shown;
      return Page2(
        tab: 'home',
        top: TopBar(title: ctl.title, right: const CartBadgeButton()),
        floating: stickyCartOverlay(),
        scroll: false,
        body: RefreshIndicator(
          onRefresh: hapticRefresh(ctl.load),
          child: ListView(controller: ctl.scroll, padding: const EdgeInsets.only(bottom: 90), children: [
            _SearchField(label: 'ابحث في ${ctl.title}', onTap: () => Get.toNamed('/search', arguments: {'category': ctl.category})),
            const SizedBox(height: 16),
            SizedBox(
              height: 44,
              child: ListView(scrollDirection: Axis.horizontal, children: [
                SChip('الفلاتر', icon: 'sliders', onTap: () => showFilters(context, ctl)),
                const SizedBox(width: 8),
                SChip('الكل', on: ctl.category == null, onTap: () => ctl.setCategory(null, '')),
                for (final cat in ctl.categories.take(8)) ...[const SizedBox(width: 8), SChip(cat.name, on: ctl.category == cat.id, onTap: () => ctl.setCategory(cat.id, cat.name))],
              ]),
            ),
            const SizedBox(height: 16),
            if (ctl.loading.value)
              const _ProductsSkeleton()
            else if (ctl.failure.value != null && l.isEmpty)
              EmptyState(ill: 'offline', title: 'تعذّر التحميل', text: failureText(ctl.failure.value!), cta: SBtn('أعد المحاولة', onTap: ctl.load, full: true))
            else if (l.isEmpty)
              const EmptyState(ill: 'books', title: 'لا منتجات هنا', text: 'جرّب تصنيفًا آخر أو ابحث بكلمة أخرى.')
            else
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: .56,
                children: [for (final p in l) ProductCard(p, heroScope: 'grid')],
              ),
            if (ctl.loadingMore.value)
              Padding(padding: const EdgeInsets.all(16), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: context.sc.tx3)), const SizedBox(width: 8), Text('جارٍ تحميل المزيد…', style: T.sm(context.sc.tx3))])),
          ]),
        ),
      );
    });
  }

  void showFilters(BuildContext context, ProductsController ctl) {
    final c = context.sc;
    showSheet(context, title: 'الفلاتر', body: Obx(() => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('النوع', style: TextStyle(fontFamily: Fonts.ui, fontSize: 14, fontWeight: FontWeight.w600, color: c.tx)),
          const SizedBox(height: 8),
          Seg(items: const [('all', 'الكل'), ('product', 'منتجات'), ('service', 'خدمات')], value: ctl.kind ?? 'all', onChanged: (k) => ctl.setKind(k == 'all' ? null : k)),
          const SizedBox(height: 24),
          Text('التصنيف', style: TextStyle(fontFamily: Fonts.ui, fontSize: 14, fontWeight: FontWeight.w600, color: c.tx)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            SChip('الكل', on: ctl.category == null, onTap: () => ctl.setCategory(null, '')),
            for (final cat in ctl.categories) SChip(cat.name, on: ctl.category == cat.id, onTap: () => ctl.setCategory(cat.id, cat.name)),
          ]),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('المتوفر فقط', style: T.h3(c.tx, size: 15.5)), Text('إخفاء المنتجات غير المتوفرة', style: T.sm(c.tx2))])),
            SSwitch(ctl.onlyInStock.value, onChanged: (v) => ctl.onlyInStock.value = v),
          ]),
        ])), foot: [
      SBtn('عرض ${ctl.shown.length} منتجًا', full: true, onTap: () => Get.back()),
      SBtn('إعادة ضبط', kind: BtnKind.ghost, full: true, onTap: () {
        ctl.onlyInStock.value = false;
        ctl.kind = null;
        ctl.setCategory(null, '');
        Get.back();
      }),
    ]);
  }
}

class _ProductsSkeleton extends StatelessWidget {
  const _ProductsSkeleton();
  @override
  Widget build(BuildContext context) => GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: .56,
        children: [for (var i = 0; i < 4; i++) const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Skel(h: 150, r: 20), SizedBox(height: 8), Skel(h: 14), SizedBox(height: 8), Skel(w: 80, h: 14)])],
      );
}

class SearchController2 extends GetxController {
  final text = TextEditingController();
  final results = <ProductModel>[].obs;
  final loading = false.obs;
  final searched = ''.obs;
  final failure = Rxn<Failure>();
  final recent = <String>[].obs;
  int? category;
  Timer? _debounce;
  int _seq = 0;
  late final SharedPreferences _prefs = Get.find<SharedPreferences>();

  @override
  void onInit() {
    super.onInit();
    final a = Get.arguments;
    if (a is Map) category = a['category'] as int?;
    recent.assignAll(_prefs.getStringList('recent_searches') ?? const []);
  }

  void onChanged(String v) {
    _debounce?.cancel();
    final q = v.trim();
    if (q.isEmpty) {
      results.clear();
      searched.value = '';
      loading.value = false;
      return;
    }
    loading.value = true;
    _debounce = Timer(const Duration(milliseconds: 350), () => run(q));
  }

  Future<void> run(String q) async {
    final seq = ++_seq;
    failure.value = null;
    final r = await backend.products(q: q, category: category, perPage: 30);
    if (seq != _seq) return;
    r.fold((f) => failure.value = f, (p) => results.assignAll(p.items));
    searched.value = q;
    loading.value = false;
    if (failure.value == null && results.isNotEmpty) _remember(q);
  }

  void _remember(String q) {
    final l = [q, ...recent.where((e) => e != q)].take(8).toList();
    recent.assignAll(l);
    _prefs.setStringList('recent_searches', l);
  }

  void clear() {
    text.clear();
    onChanged('');
  }

  @override
  void onClose() {
    _debounce?.cancel();
    text.dispose();
    super.onClose();
  }
}

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final ctl = Get.put(SearchController2());
    return Page2(
      top: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: SizedBox(
          height: 56,
          child: Row(children: [
            SIconBtn('back', onTap: () => Get.back()),
            Expanded(
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(color: c.sf, borderRadius: BorderRadius.circular(999), border: Border.all(color: c.pri, width: 2), boxShadow: [BoxShadow(color: c.pri.withValues(alpha: .14), spreadRadius: 4)]),
                child: Row(children: [
                  SIcon('search', size: 20, color: c.tx2),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: ctl.text, autofocus: true, maxLength: 60, onChanged: ctl.onChanged, textInputAction: TextInputAction.search, onSubmitted: (v) => ctl.run(v.trim()), cursorColor: c.pri, style: TextStyle(fontFamily: Fonts.ui, fontSize: 16, fontWeight: FontWeight.w500, color: c.tx), decoration: InputDecoration(border: InputBorder.none, counterText: '', hintText: 'ابحث عن دفتر، قلم، كتاب…', hintStyle: TextStyle(fontFamily: Fonts.ui, color: c.tx3), isCollapsed: true))),
                  SIconBtn('x', size: 18, box: 36, onTap: ctl.clear),
                ]),
              ),
            ),
          ]),
        ),
      ),
      body: Obx(() {
        final q = ctl.searched.value;
        if (ctl.loading.value && ctl.results.isEmpty) {
          return Column(children: [for (var i = 0; i < 4; i++) const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Row(children: [Skel(w: 64, h: 64, r: 14), SizedBox(width: 14), Expanded(child: Skel(h: 16))]))]);
        }
        if (ctl.failure.value != null) {
          return EmptyState(ill: 'offline', title: 'تعذّر البحث', text: failureText(ctl.failure.value!), cta: SBtn('أعد المحاولة', full: true, onTap: () => ctl.run(ctl.text.text.trim())));
        }
        if (q.isNotEmpty && ctl.results.isEmpty) {
          return EmptyState(
            ill: 'books',
            title: 'لم نجد «$q»',
            text: 'جرّب كلمة أخرى، أو اطلب من المساعد أن يبحث لك ويقترح بدائل.',
            cta: Column(children: [SBtn('اسأل المساعد', icon: 'sparkles', full: true, onTap: () => goTab('/assistant')), const SizedBox(height: 8), SBtn('تصفّح التصنيفات', kind: BtnKind.sec, full: true, onTap: () => Get.toNamed('/categories'))]),
          );
        }
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (ctl.results.isNotEmpty) ...[
            Eyebrow('${ctl.results.length} نتائج'),
            for (var i = 0; i < ctl.results.length; i++)
              InkWell(
                onTapDown: (_) => precacheProductImage(context, ctl.results[i].imageUrl),
                onTap: () => Get.toNamed('/product', arguments: productRouteArgs(ctl.results[i], 'search')),
                child: Container(
                  decoration: BoxDecoration(border: i == 0 ? null : Border(top: BorderSide(color: c.ln))),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(children: [
                    ProdThumb(imageUrl: ctl.results[i].imageUrl, name: ctl.results[i].name, seed: ctl.results[i].id, heroTag: productHeroTag('search', ctl.results[i].id)),
                    const SizedBox(width: 14),
                    Expanded(child: _Highlight(ctl.results[i].name, q)),
                    Mny(ctl.results[i].price.amount),
                  ]),
                ),
              ),
          ],
          if (ctl.recent.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(children: [Expanded(child: Container(height: 1, color: c.ln)), Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('عمليات بحث سابقة', style: T.cap(c.tx3))), Expanded(child: Container(height: 1, color: c.ln))]),
            const SizedBox(height: 16),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final r in ctl.recent)
                SChip(r, icon: 'clock', onTap: () {
                  ctl.text.text = r;
                  ctl.onChanged(r);
                }),
            ]),
          ],
        ]);
      }),
    );
  }
}

class _Highlight extends StatelessWidget {
  const _Highlight(this.text, this.q);
  final String text;
  final String q;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final i = q.isEmpty ? -1 : text.indexOf(q);
    final base = TextStyle(fontFamily: Fonts.ui, fontWeight: FontWeight.w600, fontSize: 15.5, height: 1.5, color: c.tx);
    if (i < 0) return Text(text, style: base);
    return Text.rich(TextSpan(style: base, children: [
      TextSpan(text: text.substring(0, i)),
      TextSpan(text: text.substring(i, i + q.length), style: TextStyle(backgroundColor: c.amberSoft)),
      TextSpan(text: text.substring(i + q.length)),
    ]));
  }
}

class ProductController extends GetxController {
  final product = Rxn<ProductModel>();
  final loading = true.obs;
  final failure = Rxn<Failure>();
  final qty = 1.obs;
  final selected = <String, Set<String>>{}.obs;
  final showErrors = false.obs;
  final note = TextEditingController();
  late final int id;

  @override
  void onInit() {
    super.onInit();
    final a = Get.arguments;
    id = a is Map ? (a['id'] as int? ?? 0) : (a is int ? a : (int.tryParse(Get.parameters['id'] ?? '') ?? 0));
    load();
  }

  Future<void> load() async {
    loading.value = true;
    failure.value = null;
    final r = await backend.product(id);
    r.fold((f) => failure.value = f, (p) {
      product.value = p;
      for (final o in p.options) {
        if (o.required && !o.multi && o.choices.isNotEmpty) {}
      }
    });
    loading.value = false;
  }

  void pick(OptionModel o, String key) {
    final cur = Set<String>.from(selected[o.key] ?? {});
    if (o.multi) {
      cur.contains(key) ? cur.remove(key) : cur.add(key);
    } else {
      cur
        ..clear()
        ..add(key);
    }
    selected[o.key] = cur;
    selected.refresh();
  }

  bool get missingRequired => (product.value?.options ?? const []).any((o) => o.required && (selected[o.key] ?? {}).isEmpty);

  int get extra {
    var sum = 0;
    for (final o in product.value?.options ?? const <OptionModel>[]) {
      for (final k in selected[o.key] ?? const <String>{}) {
        sum += o.choices.where((c) => c.key == k).firstOrNull?.price.amount ?? 0;
      }
    }
    return sum;
  }

  int get unit => (product.value?.price.amount ?? 0) + extra;

  final imageKey = GlobalKey(debugLabel: 'product-image');

  void add({BuildContext? context}) {
    final p = product.value;
    if (p == null) return;
    if (missingRequired) {
      showErrors.value = true;
      return;
    }
    final line = cartCtl.addProduct(
      CartItemRequest(
        productId: p.id,
        quantity: qty.value,
        options: {for (final e in selected.entries) if (e.value.isNotEmpty) e.key: e.value.toList()..sort()},
        note: note.text,
      ),
      maxQty: p.maxQty,
    );
    if (line == null) return;
    if (context != null && context.mounted) {
      FlyToCart.run(context, sourceKey: imageKey, image: FlyToCart.productImage(context, imageKey, p.imageUrl, decodeWidth: largeImageCacheWidth(context)));
    } else {
      Haptics.confirm();
    }
    showToast('أضيف إلى السلة · ${qty.value} × ${p.name}', actionLabel: 'عرض السلة', onAction: () => Get.toNamed('/cart'));
    qty.value = 1;
  }

  @override
  void onClose() {
    note.dispose();
    super.onClose();
  }
}

class _ProductImageBox extends StatelessWidget {
  const _ProductImageBox({required this.tag, required this.id, required this.url, required this.name, this.service = false, this.overlay, this.onOpen, this.flyKey});
  final GlobalKey? flyKey;
  final Object tag;
  final int id;
  final String? url;
  final String name;
  final bool service;
  final Widget? overlay;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final l = context.l10n;
    final art = service && url == null
        ? Center(child: Ill('tools', width: 230))
        : ProductArt(imageUrl: url, name: name, seed: id, fit: true, decodeWidth: largeImageCacheWidth(context), semanticLabel: name.isEmpty ? null : l.productImageSemantics(name));
    final box = Container(
      height: 240,
      width: double.infinity,
      decoration: BoxDecoration(color: c.hero, borderRadius: BorderRadius.circular(Rad.xl)),
      clipBehavior: Clip.antiAlias,
      child: Stack(fit: StackFit.expand, children: [
        ProductHero(tag: tag, radius: Rad.xl, child: art),
        if (overlay != null) overlay!,
      ]),
    );
    return Semantics(
      button: onOpen != null,
      hint: onOpen == null ? null : l.productImageOpen,
      child: GestureDetector(onTap: onOpen, behavior: HitTestBehavior.opaque, child: KeyedSubtree(key: flyKey, child: box)),
    );
  }
}

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final ctl = Get.put(ProductController());
    final args = ModalRoute.settingsOf(context)?.arguments ?? Get.arguments;
    final a = args is Map ? args : const {};
    final heroTag = productHeroTag(a['heroScope'] as String? ?? 'details', ctl.id);
    final previewUrl = a['image'] as String?;
    final previewName = a['name'] as String? ?? '';
    return Obx(() {
      final p = ctl.product.value;
      final top = Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: SizedBox(height: 56, child: Row(children: [SIconBtn('back', tonal: true, onTap: () => Get.back()), const Spacer(), const CartBadgeButton()])));
      if (ctl.loading.value) return Page2(top: top, body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_ProductImageBox(tag: heroTag, id: ctl.id, url: previewUrl, name: previewName, flyKey: ctl.imageKey), const SizedBox(height: 24), const Skel(h: 24), const SizedBox(height: 12), const Skel(w: 120, h: 24)]));
      if (p == null) return Page2(top: top, center: true, body: EmptyState(ill: 'offline', title: 'تعذّر عرض المنتج', text: failureText(ctl.failure.value ?? const UnknownFailure()), cta: SBtn('أعد المحاولة', onTap: ctl.load, full: true)));
      final oos = !p.inStock;
      final price = ctl.unit;
      return Page2(
        top: top,
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _ProductImageBox(
            flyKey: ctl.imageKey,
            tag: heroTag,
            id: p.id,
            url: p.imageUrl,
            name: p.name,
            service: p.isService,
            overlay: oos ? Container(color: c.bg.withValues(alpha: .62), alignment: Alignment.center, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: c.tx, borderRadius: BorderRadius.circular(999)), child: Text('غير متوفر حاليًا', style: TextStyle(fontFamily: Fonts.ui, fontSize: 13, fontWeight: FontWeight.w700, color: c.bg)))) : null,
            onOpen: (p.imageUrl ?? '').isEmpty
                ? null
                : () => ProductImageViewer.open(context, urls: [p.imageUrl!], name: p.name, heroTag: heroTag, placeholderCacheWidth: largeImageCacheWidth(context)),
          ),
          const SizedBox(height: 24),
          if (p.isService) const STag('خدمة', kind: 'soft'),
          if (p.isService) const SizedBox(height: 8),
          Text(p.name, style: T.h1(c.tx)),
          const SizedBox(height: 8),
          if (p.isInspection)
            const SizedBox.shrink()
          else
            Row(children: [
              Mny(price, size: 24),
              const SizedBox(width: 10),
              if (!oos) ...[const PinDot(), const SizedBox(width: 10), Text(p.stock == null ? 'متوفر' : 'متوفر · ${p.stock} قطع', style: T.sm(c.tx2))],
            ]),
          if ((p.description ?? '').isNotEmpty) ...[const SizedBox(height: 8), Text(p.description!, style: T.bd(c.tx2))],
          if (p.isInspection) ...[
            const SizedBox(height: 24),
            Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [SIcon('tag', size: 22, color: c.tx), const SizedBox(width: 10), Text('السعر بعد المعاينة', style: T.h3(c.tx))]),
              const SizedBox(height: 8),
              Text('لا تدفع شيئًا الآن. ترسل المكتبة عرض سعر خلال وقت قصير، وأنت توافق عليه أو ترفضه.', style: T.sm(c.tx2)),
            ])),
          ],
          if (oos) ...[const SizedBox(height: 24), const Note('warn', text: 'هذا المنتج غير متوفر الآن. يمكن للمساعد اقتراح بدائل قريبة.')],
          for (final o in p.options) ...[
            const SizedBox(height: 24),
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(o.label, style: TextStyle(fontFamily: Fonts.ui, fontSize: 14, fontWeight: FontWeight.w600, color: c.tx)),
                if (o.required) STag('مطلوب', kind: (ctl.showErrors.value && (ctl.selected[o.key] ?? {}).isEmpty) ? 'err' : 'gray'),
              ]),
              const SizedBox(height: 8),
              for (final ch in o.choices) ...[
                OptCard(on: (ctl.selected[o.key] ?? {}).contains(ch.key), title: ch.label, sub: ch.price.amount == 0 ? 'السعر الأساسي' : '+ ${fmtMinor(ch.price.amount)}', onTap: oos ? null : () => ctl.pick(o, ch.key)),
                const SizedBox(height: 8),
              ],
              if (ctl.showErrors.value && o.required && (ctl.selected[o.key] ?? {}).isEmpty) FieldError('اختر ${o.label} للمتابعة.'),
            ]),
          ],
          const SizedBox(height: 24),
          Fld(label: p.isService ? 'تفاصيل الخدمة' : 'ملاحظة للمكتبة', hint: p.isService ? 'عدد النسخ، لون الغلاف…' : 'مثال: بدون ملصقات على الغلاف', controller: ctl.note, optional: true, maxLines: 3),
          const SizedBox(height: 6),
        ]),
        foot: FootBar(
          child: oos
              ? Column(mainAxisSize: MainAxisSize.min, children: [SBtn('اطلب بديلًا من المساعد', icon: 'sparkles', full: true, onTap: () => goTab('/assistant')), const SizedBox(height: 8), const SBtn('غير متوفر', kind: BtnKind.sec, full: true, disabled: true)])
              : p.isInspection
                  ? SBtn('اطلب تسعيرة', full: true, onTap: () => ctl.add(context: context))
                  : Row(children: [
                      Stepper2(value: ctl.qty.value, lg: true, maxed: ctl.qty.value >= p.maxQty, onInc: () => ctl.qty.value = (ctl.qty.value + 1).clamp(1, p.maxQty), onDec: () => ctl.qty.value = (ctl.qty.value - 1).clamp(1, p.maxQty)),
                      const SizedBox(width: 14),
                      Expanded(child: SBtn('أضف إلى السلة · ${(price * ctl.qty.value / 100).toStringAsFixed(2)} ₪', full: true, onTap: () => ctl.add(context: context), disabled: ctl.missingRequired && ctl.showErrors.value)),
                    ]),
        ),
      );
    });
  }
}

SessionStore get session0 => Get.find<SessionStore>();
RemoteConfigRepository get cfgRepo => Get.find<RemoteConfigRepository>();
