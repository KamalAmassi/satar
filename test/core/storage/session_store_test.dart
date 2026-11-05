import 'package:flutter_test/flutter_test.dart';
import 'package:project/core/storage/session_store.dart';
import 'package:project/core/storage/user_data_reset.dart';
import 'package:project/customer/features/cart/data/datasources/cart_local_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;
  late SessionStore s;
  var resets = 0;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    s = SessionStore(prefs);
    resets = 0;
    UserDataReset.clearHooks();
    UserDataReset.register(() => resets++);
  });

  test('role is stored together with the token; chosenRole follows', () async {
    await s.signIn(token: 't', userId: 1, role: 'driver');
    expect(s.isSignedIn, isTrue);
    expect(s.role, 'driver');
    expect(s.chosenRole, 'driver');
    expect(s.loginRoute, '/driver/login');
  });

  test('signOut clears session but keeps onboardingSeen and chosen role', () async {
    await s.markOnboardingSeen();
    await s.signIn(token: 't', userId: 1, role: 'customer');
    await s.signOut();
    expect(s.isSignedIn, isFalse);
    expect(s.role, isNull);
    expect(s.onboardingSeen, isTrue);
    expect(s.loginRoute, '/auth/phone');
    expect(resets, 1);
  });

  test('different user (or role) on same device wipes previous state first', () async {
    await s.signIn(token: 'a', userId: 1, role: 'customer');
    expect(resets, 0);
    await s.signIn(token: 'a2', userId: 1, role: 'customer'); // نفس الحساب
    expect(resets, 0);
    await s.signIn(token: 'b', userId: 2, role: 'customer');
    expect(resets, 1);
    await s.signIn(token: 'c', userId: 2, role: 'driver'); // نفس المعرّف بدور آخر
    expect(resets, 2);
  });

  test('cart is per user: A -> B empty -> A restored; roles do not share', () async {
    final ds = CartLocalDataSourceImpl(prefs, role: () => s.role ?? 'customer');
    await s.signIn(token: 'a', userId: 1, role: 'customer');
    await ds.write(1, {'products': [1, 2]});
    await s.signOut();
    await s.signIn(token: 'b', userId: 2, role: 'customer');
    expect(ds.read(2), isNull);
    await s.signOut();
    await s.signIn(token: 'a', userId: 1, role: 'customer');
    expect(ds.read(1), {'products': [1, 2]});
    await s.signOut();
    await s.signIn(token: 'd', userId: 1, role: 'driver');
    expect(ds.read(1), isNull);
  });

  test('legacy cart key migrates once', () async {
    await prefs.setString('customer_cart_v1_5', '{"x":1}');
    final ds = CartLocalDataSourceImpl(prefs);
    expect(ds.read(5), {'x': 1});
    expect(prefs.getString('customer_cart_v1_5'), isNull);
    expect(prefs.getString('cart_customer_5'), isNotNull);
  });

  test('no session / expired token resolves to the saved role login', () async {
    await s.markOnboardingSeen();
    expect(s.loginRoute, '/role');
    await s.setChosenRole('driver');
    expect(s.loginRoute, '/driver/login');
  });
}
