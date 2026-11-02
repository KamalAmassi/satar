import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/config/app_env.dart';
import 'package:project/core/errors/error_handler.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/network/api_client.dart';
import 'package:project/core/routes/app_routes.dart';
import 'package:project/core/routes/route_args.dart';
import 'package:project/core/storage/session_store.dart';
import 'package:project/customer/features/cart/domain/entities/cart_product_line.dart';
import 'package:project/customer/features/cart/domain/entities/product_info.dart';
import 'package:project/customer/features/cart/presentation/controllers/cart_controller.dart';

/// أداة تطوير فقط. ليست جزءًا من تطبيق الزبون ولا تُترجم عمدًا.
///
/// لا بيانات مختلقة: كل ما يظهر هنا يأتي من الـ API أو يكتبه المطوّر.
/// - الدخول برقم الهاتف ورمز التحقق (بدل شاشات محمد حتى تكتمل).
/// - المنتجات وخياراتها من GET /v1/products (عقد الكتالوج → السلة).
/// - العناوين من GET /v1/addresses، وإضافة عنوان ببيانات يدخلها المطوّر.
/// - الطلبات من GET /v1/orders لفتح عرض المكتبة أو الدفع بالتحويل.
/// لا تحتوي أي أداة مشغّل (مثل sandbox advance).
class PurchasingDevHub extends StatefulWidget {
  const PurchasingDevHub({super.key});

  @override
  State<PurchasingDevHub> createState() => _PurchasingDevHubState();
}

class _PurchasingDevHubState extends State<PurchasingDevHub> {
  final session = Get.find<SessionStore>();
  final api = Get.find<ApiClient>();
  final cart = Get.find<CartController>();

  final phone = TextEditingController();
  final name = TextEditingController();
  final code = TextEditingController();
  final addrLabel = TextEditingController();
  final addrDetails = TextEditingController();
  final addrLat = TextEditingController();
  final addrLng = TextEditingController();

  bool codeSent = false;
  bool busy = false;
  String status = '';
  List<ProductInfo> products = const [];
  List<Map<String, dynamic>> addresses = const [];
  List<Map<String, dynamic>> orders = const [];
  final Map<int, Map<String, List<String>>> chosen = {};

  @override
  void initState() {
    super.initState();
    _refreshAll();
  }

  @override
  void dispose() {
    for (final c in [
      phone,
      name,
      code,
      addrLabel,
      addrDetails,
      addrLat,
      addrLng
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String _err(Failure f) => f.message ?? f.code ?? '${f.runtimeType}';

  Future<void> _run(Future<void> Function() action) async {
    setState(() => busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _refreshAll() => _run(() async {
        await cart.ensureLoaded();
        final p = await ErrorHandler.guard(() async {
          final res = await api.dio
              .get<dynamic>('v1/products', queryParameters: {'per_page': 50});
          return [
            for (final e in ApiClient.unwrap<List>(res))
              ProductInfo.fromJson(Map<String, dynamic>.from(e as Map)),
          ];
        });
        p.fold((f) => status = 'Products: ${_err(f)}', (v) => products = v);
        if (!session.isSignedIn) {
          addresses = const [];
          orders = const [];
          return;
        }
        final a = await ErrorHandler.guard(() async => [
              for (final e in ApiClient.unwrap<List>(
                  await api.dio.get<dynamic>('v1/addresses')))
                Map<String, dynamic>.from(e as Map),
            ]);
        a.fold((f) => status = 'Addresses: ${_err(f)}', (v) => addresses = v);
        final o = await ErrorHandler.guard(() async => [
              for (final e in ApiClient.unwrap<List>(await api.dio.get<dynamic>(
                  'v1/orders',
                  queryParameters: {'per_page': 20})))
                Map<String, dynamic>.from(e as Map),
            ]);
        o.fold((f) => status = 'Orders: ${_err(f)}', (v) => orders = v);
      });

  Future<void> _sendCode() => _run(() async {
        final r = await ErrorHandler.guard(() => api.dio.post<dynamic>(
              'v1/auth/send-otp',
              data: {'phone': phone.text.trim()},
              options: Options(extra: {'auth': false}),
            ));
        r.fold((f) => status = 'Send code: ${_err(f)}', (res) {
          codeSent = true;
          status = '${res.data['message']}';
        });
      });

  Future<void> _verify() => _run(() async {
        final r = await ErrorHandler.guard(() async {
          final res = await api.dio.post<dynamic>(
            'v1/auth/verify-otp',
            data: {
              'phone': phone.text.trim(),
              'code': code.text.trim(),
              if (name.text.trim().isNotEmpty) 'name': name.text.trim(),
            },
            options: Options(extra: {'auth': false}),
          );
          return ApiClient.unwrapMap(res);
        });
        await r.fold((f) async => status = 'Verify: ${_err(f)}', (data) async {
          final user = Map<String, dynamic>.from(data['user'] as Map);
          await session.signIn(
              token: data['token'] as String, userId: user['id'] as int);
          code.clear();
          codeSent = false;
          status = 'Signed in as ${user['name'] ?? user['phone']}';
        });
      }).then((_) => _refreshAll());

  Future<void> _signOut() async {
    await ErrorHandler.guard(() => api.dio.post<dynamic>('v1/auth/logout'));
    await session.signOut();
    setState(() => status = 'Signed out');
    await _refreshAll();
  }

  Future<void> _addAddress() async {
    final lat = double.tryParse(addrLat.text.trim());
    final lng = double.tryParse(addrLng.text.trim());
    if (addrLabel.text.trim().isEmpty || lat == null || lng == null) {
      setState(
          () => status = 'Address: label, latitude and longitude are required');
      return;
    }
    await _run(() async {
      final r = await ErrorHandler.guard(() => api.dio.post<dynamic>(
            'v1/addresses',
            data: {
              'label': addrLabel.text.trim(),
              'lat': lat,
              'lng': lng,
              if (addrDetails.text.trim().isNotEmpty)
                'details': addrDetails.text.trim(),
            },
          ));
      r.fold((f) => status = 'Address: ${_err(f)}', (res) {
        status = '${res.data['message']}';
        for (final c in [addrLabel, addrDetails, addrLat, addrLng]) {
          c.clear();
        }
      });
    });
    await _refreshAll();
  }

  void _addToCart(ProductInfo p) {
    cart.addProduct(
      CartItemRequest(productId: p.id, options: Map.of(chosen[p.id] ?? {})),
      maxQty: p.stock == null || p.stock! <= 0 ? 99 : p.stock!,
    );
    setState(() => status = 'Added “${p.name}” to cart');
  }

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('DEV · Purchasing hub'),
            actions: [
              IconButton(
                tooltip: 'Refresh from API',
                onPressed: busy ? null : _refreshAll,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.amber.shade100,
                child: const Text(
                  'DEVELOPMENT ONLY — temporary entry points until the login, '
                  'catalog, address and orders screens exist. Everything shown '
                  'comes from the API or is typed by you.',
                ),
              ),
              const SizedBox(height: 8),
              Text('API: ${AppEnv.apiBaseUrl}'),
              Text(
                  'Project key: ${AppEnv.hasProjectKey ? (AppEnv.isSandboxKey ? 'sandbox key' : 'NON-sandbox key') : 'MISSING'}'),
              if (busy) const LinearProgressIndicator(),
              if (status.isNotEmpty)
                Text(status,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              const Divider(),
              ..._account(),
              const Divider(),
              ..._products(),
              const Divider(),
              ..._addresses(),
              const Divider(),
              ..._orders(),
            ],
          ),
        ),
      );

  List<Widget> _account() {
    if (session.isSignedIn) {
      return [
        Text('Signed in (user #${session.userId})'),
        OutlinedButton(
            onPressed: busy ? null : _signOut, child: const Text('Sign out')),
      ];
    }
    return [
      const Text('Sign in', style: TextStyle(fontWeight: FontWeight.bold)),
      TextField(
        controller: phone,
        keyboardType: TextInputType.phone,
        decoration: const InputDecoration(labelText: 'Phone (e.g. 059…)'),
      ),
      TextField(
        controller: name,
        decoration: const InputDecoration(labelText: 'Name (new accounts)'),
      ),
      if (codeSent)
        TextField(
          controller: code,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Verification code'),
        ),
      const SizedBox(height: 8),
      FilledButton(
        onPressed: busy ? null : (codeSent ? _verify : _sendCode),
        child: Text(codeSent ? 'Verify and sign in' : 'Send code'),
      ),
    ];
  }

  List<Widget> _products() => [
        Row(children: [
          const Expanded(
            child: Text('Catalog (GET /v1/products) → cart',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () => Get.toNamed(CustomerRoutes.cart),
            child: Obx(() => Text('Cart (${cart.itemCount})')),
          ),
        ]),
        Wrap(spacing: 8, children: [
          OutlinedButton(
              onPressed: () => Get.toNamed(CustomerRoutes.printing),
              child: const Text('Printing')),
          OutlinedButton(
              onPressed: () => Get.toNamed(CustomerRoutes.printPreview),
              child: const Text('Upload files')),
        ]),
        for (final p in products)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('${p.price.formatted ?? p.price.amount} · '
                      '${p.inStock ? 'in stock${p.stock == null ? '' : ' (${p.stock})'}' : 'out of stock'}'
                      '${p.isInspectionPriced ? ' · priced by library' : ''}'),
                  for (final o in p.options)
                    Wrap(spacing: 6, children: [
                      Text('${o.label}${o.required ? ' *' : ''}: '),
                      for (final c in o.choices)
                        ChoiceChip(
                          label: Text(c.label),
                          selected:
                              chosen[p.id]?[o.key]?.contains(c.key) ?? false,
                          onSelected: (_) => setState(() {
                            final opts = chosen.putIfAbsent(p.id, () => {});
                            final cur = [...?opts[o.key]];
                            if (o.multi) {
                              cur.contains(c.key)
                                  ? cur.remove(c.key)
                                  : cur.add(c.key);
                            } else {
                              cur
                                ..clear()
                                ..add(c.key);
                            }
                            cur.isEmpty
                                ? opts.remove(o.key)
                                : opts[o.key] = cur;
                          }),
                        ),
                    ]),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: p.inStock ? () => _addToCart(p) : null,
                      child: const Text('Add to cart'),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ];

  List<Widget> _addresses() => [
        const Text('Addresses (GET /v1/addresses)',
            style: TextStyle(fontWeight: FontWeight.bold)),
        if (!session.isSignedIn) const Text('Sign in to see your addresses.'),
        for (final a in addresses)
          ListTile(
            dense: true,
            title: Text('${a['label'] ?? 'Address #${a['id']}'}'),
            subtitle: Text('${a['details'] ?? ''}  (${a['lat']}, ${a['lng']})'),
          ),
        if (session.isSignedIn) ...[
          const Text('Add address — temporary until the address screen exists'),
          TextField(
              controller: addrLabel,
              decoration: const InputDecoration(labelText: 'Label')),
          TextField(
              controller: addrDetails,
              decoration: const InputDecoration(labelText: 'Details')),
          Row(children: [
            Expanded(
              child: TextField(
                controller: addrLat,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true, signed: true),
                decoration: const InputDecoration(labelText: 'Latitude'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: addrLng,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true, signed: true),
                decoration: const InputDecoration(labelText: 'Longitude'),
              ),
            ),
          ]),
          OutlinedButton(
              onPressed: busy ? null : _addAddress,
              child: const Text('Save address')),
        ],
      ];

  List<Widget> _orders() => [
        const Text('My orders (GET /v1/orders)',
            style: TextStyle(fontWeight: FontWeight.bold)),
        if (session.isSignedIn && orders.isEmpty) const Text('No orders yet.'),
        for (final o in orders)
          Builder(builder: (_) {
            final id = o['id'] as int;
            final st = Map<String, dynamic>.from(o['status'] as Map? ?? {});
            final key = st['key'] as String? ?? '';
            final total = (o['total'] as Map?)?['formatted'] ?? '';
            return ListTile(
              dense: true,
              title: Text('${o['code']} (#$id) · ${st['label'] ?? key}'),
              subtitle: Text('$total · $key'),
              trailing: Wrap(spacing: 4, children: [
                if (const {'awaiting_pricing', 'priced'}.contains(key))
                  TextButton(
                    onPressed: () => Get.toNamed(CustomerRoutes.offer,
                        arguments: RouteArgs.order(id)),
                    child: const Text('Offer'),
                  ),
                TextButton(
                  onPressed: () => Get.toNamed(CustomerRoutes.payment,
                      arguments: RouteArgs.order(id)),
                  child: const Text('Payment'),
                ),
              ]),
            );
          }),
      ];
}
