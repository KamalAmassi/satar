/// شاشات مشتركة بين الزبون والسائق
abstract final class SharedRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const roleChoice = '/role-choice';
}

/// تطبيق الزبون
abstract final class CustomerRoutes {
  static const languageOnboarding = '/customer/onboarding-language';
  static const login = '/customer/login';
  static const otp = '/customer/otp';
  static const completeProfile = '/customer/complete-profile';
  static const success = '/customer/success';
  static const home = '/customer/home';
  static const categories = '/customer/categories';
  static const products = '/customer/products';
  static const productDetails = '/customer/product-details';
  static const search = '/customer/search';
  static const searchResults = '/customer/search-results';
  static const aiAssistant = '/customer/ai-assistant';
  static const aiProposal = '/customer/ai-proposal';
  static const printing = '/customer/printing';
  static const uploadFiles = '/customer/upload-files';
  static const printSpecs = '/customer/print-specs';
  static const printPreview = '/customer/print-preview';
  static const cart = '/customer/cart';
  static const addresses = '/customer/addresses';
  static const addressForm = '/customer/address-form';
  static const priceReview = '/customer/price-review';
  static const payment = '/customer/payment';
  static const offer = '/customer/offer';
  static const orderDetails = '/customer/order-details';
  static const orders = '/customer/orders';
  static const notifications = '/customer/notifications';
  static const receipt = '/customer/receipt';
  static const profile = '/customer/profile';

  static const all = [
    languageOnboarding, login, otp, completeProfile, success, home, categories, products, productDetails,
    search, searchResults, aiAssistant, aiProposal, printing, uploadFiles, printSpecs, printPreview, cart, addresses,
    addressForm, priceReview, payment, offer, orderDetails, orders,
    notifications, receipt, profile,
  ];
}

/// تطبيق السائق
abstract final class DriverRoutes {
  static const login = '/driver/login';
  static const home = '/driver/home';
  static const availableOrders = '/driver/available-orders';
  static const orderDetails = '/driver/order-details';
  static const currentTask = '/driver/current-task';
  static const mapNavigation = '/driver/map';
  static const deliveryConfirmation = '/driver/delivery-confirmation';
  static const deliveryFailure = '/driver/delivery-failure';
  static const tasksHistory = '/driver/tasks-history';
  static const earningsCash = '/driver/earnings-cash';
  static const notifications = '/driver/notifications';

  static const all = [
    login, home, availableOrders, orderDetails, currentTask, mapNavigation,
    deliveryConfirmation, deliveryFailure, tasksHistory, earningsCash,
    notifications,
  ];
}