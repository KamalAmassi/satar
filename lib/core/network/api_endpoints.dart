class ApiEndpoints {
  ApiEndpoints._();

  static const appConfig = '/api/v1/app/config';

  // Authentication / profile
  static const sendOtp = '/api/v1/auth/send-otp';
  static const verifyOtp = '/api/v1/auth/verify-otp';
  static const logout = '/api/v1/auth/logout';
  static const me = '/api/v1/me';
  static const fcmToken = '/api/v1/me/fcm-token';

  // Addresses / catalog
  static const addresses = '/api/v1/addresses';
  static const categories = '/api/v1/categories';
  static const products = '/api/v1/products';

  // Uploads / orders
  static const uploads = '/api/v1/uploads';
  static const quoteOrder = '/api/v1/orders/quote';
  static const orders = '/api/v1/orders';
  static const cancelReasons = '/api/v1/cancel-reasons';
  static const notifications = '/api/v1/notifications';
  static const readAllNotifications = '/api/v1/notifications/read-all';

  // Driver
  static const driverLogin = '/api/v1/driver/auth/login';
  static const driverLogout = '/api/v1/driver/auth/logout';
  static const driverMe = '/api/v1/driver/me';
  static const driverLocation = '/api/v1/driver/location';
  static const driverStatus = '/api/v1/driver/status';
  static const availableDriverOrders = '/api/v1/driver/orders/available';
  static const currentDriverOrder = '/api/v1/driver/orders/current';
  static const driverEarnings = '/api/v1/driver/earnings';
  static const driverCash = '/api/v1/driver/cash';
  static const driverHistory = '/api/v1/driver/orders/history';
  static const driverNotifications = '/api/v1/driver/notifications';
  static const settleDriverCash = '/api/v1/driver/sandbox/settle-cash';

  static String addressById(Object id) => '$addresses/$id';
  static String productById(Object id) => '$products/$id';
  static String orderById(Object id) => '$orders/$id';
  static String orderEvents(Object id) => '${orderById(id)}/events';
  static String shareOrder(Object id) => '${orderById(id)}/share-link';
  static String track(String token) => '/api/v1/track/$token';
  static String orderOffer(Object id) => '${orderById(id)}/offer';
  static String approveOffer(Object id) => '${orderOffer(id)}/approve';
  static String orderTracking(Object id) => '${orderById(id)}/tracking';
  static String rateOrder(Object id) => '${orderById(id)}/rate';
  static String orderReceipt(Object id) => '${orderById(id)}/receipt';
  static String cancelOrder(Object id) => '${orderById(id)}/cancel';
  static String paymentReceipt(Object id) => '${orderById(id)}/payment-receipt';
  static String sandboxAdvance(Object id) => '/api/v1/sandbox/orders/$id/advance';
  static String acceptDriverOrder(Object id) => '/api/v1/driver/orders/$id/accept';
  static String transitionDriverOrder(Object id) => '/api/v1/driver/orders/$id/transition';
  static String deliverDriverOrder(Object id) => '/api/v1/driver/orders/$id/deliver';
}
