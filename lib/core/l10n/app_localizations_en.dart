// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Satr';

  @override
  String get appTitle => 'Satr Smart Library';

  @override
  String get errorGeneral => 'An unexpected error occurred. Please try again.';

  @override
  String get errorNetwork =>
      'Network connection error. Please check your connection.';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get loading => 'Loading...';

  @override
  String get splashTagline => 'Everything you need, in one line';

  @override
  String get splashContinue => 'Continue';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Let’s start';

  @override
  String onboardingPageCounter(int current, int total) {
    return '$current of $total';
  }

  @override
  String get onboarding1Title => 'Everything you need, in one line';

  @override
  String get onboarding1Body =>
      'Books, stationery, toys and gifts… all in one place.';

  @override
  String get onboarding2Title => 'Your files, ready to print';

  @override
  String get onboarding2Body =>
      'Upload your file, pick the print options, and we prepare your order.';

  @override
  String get onboarding3Title => 'Order easily, we handle the rest';

  @override
  String get onboarding3Body =>
      'Type or speak your request, and Satr builds your cart and delivers it.';

  @override
  String get roleWelcomeTitle => 'Welcome to Satr!';

  @override
  String get roleWelcomeSubtitle => 'Choose how you want to continue';

  @override
  String get roleCustomer => 'I’m a customer';

  @override
  String get roleDriver => 'I’m a driver';

  @override
  String get roleTermsNote =>
      'By continuing you agree to the Terms of Use and Privacy Policy';

  @override
  String get driverLoginTitle => 'Driver Login';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get loginSubtitle => 'Log in and start receiving delivery orders.';

  @override
  String get phoneNumberLabel => 'Phone Number';

  @override
  String get passwordLabel => 'Password';

  @override
  String get enterPasswordHint => 'Enter your password';

  @override
  String get loginButton => 'Log In';

  @override
  String get driverAppTag => 'Driver App';

  @override
  String get showPassword => 'Show';

  @override
  String get hidePassword => 'Hide';

  @override
  String get phoneValidationError => 'Please enter your phone number';

  @override
  String get passwordValidationError => 'Please enter your password';

  @override
  String get authInvalidCredentialsError =>
      'Incorrect phone number or password. Please check your data and try again.';

  @override
  String get loggingInStatus => 'Logging in...';

  @override
  String get availableOrdersTitle => 'Available Orders';

  @override
  String get noAvailableOrders => 'No available orders at the moment';

  @override
  String get pickupFrom => 'From:';

  @override
  String get deliverTo => 'To:';

  @override
  String get deliveryFeeLabel => 'Delivery Fee';

  @override
  String get acceptOrderButton => 'Accept Order';

  @override
  String get orderCodeLabel => 'Order Code #';

  @override
  String get notConnectedStatus => 'Disconnected';

  @override
  String get connectDesc =>
      'Connect to see available delivery requests near you.';

  @override
  String get connectNow => 'Connect Now';

  @override
  String get connectedStatus => 'You\'re Online';

  @override
  String get connectedDesc => 'Ready to receive orders';

  @override
  String get disconnectBtn => 'Go Offline';

  @override
  String get todaySummary => 'Today\'s Summary';

  @override
  String get completedOrders => 'Completed Orders';

  @override
  String get activeTask => 'Active Task';

  @override
  String get hiddenOrdersTitle => 'Available Orders Are Hidden';

  @override
  String get hiddenOrdersDesc =>
      'You cant load the orders list while youre offline.';

  @override
  String get locationNeedTitle => 'We Need Your Current Location';

  @override
  String get locationNeedDesc =>
      'Enable location permission and update your location before connecting.';

  @override
  String get updateLocationBtn => 'Update Location';

  @override
  String get nearbyOrdersTitle => 'Orders Near You';

  @override
  String get nearbyOrdersDesc => 'The list is updated based on your location.';

  @override
  String get viewDetailsBtn => 'View Details';

  @override
  String get noOrdersNow => 'No Orders Available Right Now';

  @override
  String get noOrdersNowDesc =>
      'Stay online, and we\'ll update the list as soon as a nearby order becomes available.';

  @override
  String get failLoadOrders => 'Failed to Load Orders';

  @override
  String get failLoadOrdersDesc =>
      'Check your connection and try refreshing the list.';

  @override
  String get orderDetailsTitle => 'Order Details';

  @override
  String get availableOrderTag => 'Available Order';

  @override
  String distanceAway(Object distance) {
    return '$distance km away';
  }

  @override
  String get pickupZone => 'Pickup Zone';

  @override
  String get deliveryZone => 'Delivery Zone';

  @override
  String get orderSummary => 'Order Summary';

  @override
  String get orderTypeLabel => 'Order Type';

  @override
  String get itemsCountLabel => 'Items Count';

  @override
  String itemsCountValue(Object count) {
    return '$count items';
  }

  @override
  String get hideOrderBtn => 'Hide this order';

  @override
  String get acceptOrderBtn => 'Accept Order';

  @override
  String get detailsHiddenNotice =>
      'Only brief information is shown before acceptance. Contact info, exact address, and attachments remain hidden.';

  @override
  String get detailsHiddenAlert =>
      'Detailed address and customer data appear only after accepting the order.';

  @override
  String get acceptingOrderTitle => 'Accepting Order';

  @override
  String get acceptingOrderDesc =>
      'One moment, we are confirming the order is still available.';

  @override
  String get orderAcceptedTitle => 'Order Accepted';

  @override
  String get orderAcceptedDesc =>
      'The order is now your task. Review task details before moving.';

  @override
  String get viewActiveTaskBtn => 'View Active Task';

  @override
  String get alreadyTakenTitle => 'Another Driver Ahead';

  @override
  String get alreadyTakenDesc =>
      'The order was accepted by another driver. Go back and choose another.';

  @override
  String get busyStatusTitle => 'You Have an Active Task';

  @override
  String get busyStatusDesc =>
      'Complete your current task before accepting a new order.';

  @override
  String get cashLimitTitle => 'Cash Collection Limit Reached';

  @override
  String get cashLimitDesc =>
      'Cannot accept order due to collection limit. Check your balance or contact the office.';

  @override
  String get unexpectedErrorTitle => 'Could Not Accept Order';

  @override
  String get unexpectedErrorDesc =>
      'An unexpected error occurred. Please try again or go back.';

  @override
  String get backToOrdersBtn => 'Back to Orders';

  @override
  String get drAcceptActiveTaskBody =>
      'Finish your current task before accepting a new order';

  @override
  String get drAcceptActiveTaskTitle => 'You have an active task';

  @override
  String get drAcceptBackToOrders => 'Back to orders';

  @override
  String get drAcceptCashLimitBody =>
      'Hand over the collected cash to continue receiving orders';

  @override
  String get drAcceptCashLimitTitle => 'Cash collection limit reached';

  @override
  String get drAcceptFailedBody => 'Something went wrong. Please try again';

  @override
  String get drAcceptFailedTitle => 'We could not accept the order';

  @override
  String get drAcceptGoOnline => 'Go online';

  @override
  String get drAcceptOfflineBody => 'Go online first to accept orders';

  @override
  String get drAcceptOfflineTitle => 'You need to be online';

  @override
  String get drAcceptTakenBody =>
      'Another driver accepted this order. Try another one';

  @override
  String get drAcceptTakenTitle => 'Another driver was faster';

  @override
  String get drAcceptViewCash => 'View cash balance';

  @override
  String get drAcceptedBody =>
      'The order is now your current task. Head to the pickup point';

  @override
  String get drAcceptedGoTask => 'View current task';

  @override
  String get drAcceptedTitle => 'Order accepted';

  @override
  String get drAcceptingBody => 'One moment…';

  @override
  String get drAcceptingTitle => 'Accepting order';

  @override
  String get drAddPhoto => 'Add photo';

  @override
  String get drAmountToCollect => 'Amount to collect';

  @override
  String get drCallAction => 'Call';

  @override
  String get drCashEmptyTitle => 'No cash transactions';

  @override
  String get drCashErrorTitle => 'Could not load balance';

  @override
  String get drCashLimit => 'Collection limit';

  @override
  String get drCashNearLimit =>
      'You are close to the collection limit. Hand over cash to the office';

  @override
  String get drCashOnHand => 'Cash on hand';

  @override
  String get drCashTab => 'Cash';

  @override
  String get drCommonBack => 'Back';

  @override
  String get drDeliveryCashReceived => 'I received the full amount';

  @override
  String get drDeliveryCodeHint => 'Enter the code from the customer';

  @override
  String get drDeliveryCodeInvalid => 'Invalid delivery code';

  @override
  String get drDeliveryCodeLabel => 'Delivery code';

  @override
  String get drDeliveryCollectCash => 'Collect from the customer';

  @override
  String get drDeliveryConfirmButton => 'Confirm delivery';

  @override
  String get drDeliveryConfirmTitle => 'Confirm delivery';

  @override
  String get drDeliveryNeedCash => 'Confirm you received the cash first';

  @override
  String get drDeliveryNoCashNote =>
      'This order is prepaid, do not collect any cash';

  @override
  String get drDeliverySuccessCollected => 'Collected';

  @override
  String get drDeliverySuccessHistory => 'View task history';

  @override
  String get drDeliverySuccessHome => 'Back to home';

  @override
  String get drDeliverySuccessOrder => 'Order';

  @override
  String get drDeliverySuccessTitle => 'Delivered successfully';

  @override
  String get drDetailsTitle => 'Order details';

  @override
  String get drEarningsEmptyBody =>
      'Your earnings will appear here after your first task';

  @override
  String get drEarningsEmptyTitle => 'No earnings yet';

  @override
  String get drEarningsErrorTitle => 'Could not load earnings';

  @override
  String get drEarningsTab => 'Earnings';

  @override
  String get drEarningsThisWeek => 'This week';

  @override
  String get drEarningsTitle => 'Earnings & cash';

  @override
  String get drFailureBannerTitle => 'Delivery failed';

  @override
  String get drFailureNotesHint => 'Additional notes (optional)';

  @override
  String get drFailurePickReason => 'Pick a reason first';

  @override
  String get drFailureReasonNotHome => 'Nobody at the address';

  @override
  String get drFailureReasonOther => 'Other reason';

  @override
  String get drFailureReasonRefused => 'Customer refused the order';

  @override
  String get drFailureReasonUnreachable => 'Customer is unreachable';

  @override
  String get drFailureReasonWrongAddress => 'Wrong address';

  @override
  String get drFailureRecordedBody =>
      'We recorded the reason and will follow up with the office';

  @override
  String get drFailureRecordedTitle => 'Delivery failure recorded';

  @override
  String get drFailureSubmit => 'Record delivery failure';

  @override
  String get drFailureTitle => 'Why could the delivery not be completed?';

  @override
  String get drFailureViewTask => 'View task';

  @override
  String get drHistoryDetailsTitle => 'Past task details';

  @override
  String get drHistoryEmptyBody => 'Your completed tasks will appear here';

  @override
  String get drHistoryEmptyTitle => 'No past tasks';

  @override
  String get drHistoryErrorTitle => 'Could not load history';

  @override
  String get drHistoryTitle => 'Task history';

  @override
  String get drHomeCash => 'Cash on hand';

  @override
  String get drHomeEarnings => 'Earnings';

  @override
  String get drHomeGoOffline => 'Go offline';

  @override
  String get drHomeGoOnline => 'Go online';

  @override
  String get drHomeNearbyOrders => 'Orders near you';

  @override
  String get drHomeOffline => 'Offline';

  @override
  String get drHomeOfflineBody =>
      'Go online to start receiving nearby delivery orders';

  @override
  String get drHomeOnline => 'Online';

  @override
  String get drHomeOnlineBody => 'Ready to receive orders';

  @override
  String get drHomeSeeAll => 'See all';

  @override
  String get drHomeTodaySummary => 'Today summary';

  @override
  String get drLocationGrant => 'Allow location access';

  @override
  String get drLocationOpenSettings => 'Open settings';

  @override
  String get drLocationRequiredBody =>
      'Enable location permission so we can match you with nearby orders';

  @override
  String get drLocationRequiredTitle => 'We need your location';

  @override
  String get drLocationServiceOffBody =>
      'Turn on GPS from your device settings';

  @override
  String get drLocationServiceOffTitle => 'Location service is off';

  @override
  String get drLoginPasswordHint => 'Enter your password';

  @override
  String get drLoginPasswordLabel => 'Password';

  @override
  String get drLoginPhoneHint => '05XXXXXXXX';

  @override
  String get drLoginPhoneLabel => 'Phone number';

  @override
  String get drLoginRequiredField => 'This field is required';

  @override
  String get drLoginTitle => 'Welcome';

  @override
  String get drMapArrived => 'I have arrived';

  @override
  String get drMapDestination => 'Destination';

  @override
  String get drMapNoCoords => 'Destination coordinates are not available';

  @override
  String get drMapOpenExternal => 'Open in Maps';

  @override
  String get drMapTitle => 'On the way';

  @override
  String get drNavEarnings => 'Earnings';

  @override
  String get drNavHistory => 'History';

  @override
  String get drNavHome => 'Home';

  @override
  String get drNavOrders => 'Orders';

  @override
  String get drNavTask => 'Task';

  @override
  String get drNextArrivedBody =>
      'Confirm your arrival so the customer is notified';

  @override
  String get drNextArrivedButton => 'I have arrived';

  @override
  String get drNextArrivedTitle => 'Arrived at the customer?';

  @override
  String get drNextDeliveredBody => 'Confirm after handing over the order';

  @override
  String get drNextDeliveredButton => 'Confirm delivery';

  @override
  String get drNextDeliveredTitle => 'Hand the order to the customer';

  @override
  String get drNextGenericButton => 'Continue';

  @override
  String get drNextOnTheWayBody =>
      'Start the delivery and we will guide you to the customer';

  @override
  String get drNextOnTheWayButton => 'Start delivery';

  @override
  String get drNextOnTheWayTitle => 'Ready to go?';

  @override
  String get drNextPickedUpBody =>
      'Go to the pickup point and confirm you received the order';

  @override
  String get drNextPickedUpButton => 'I picked up the order';

  @override
  String get drNextPickedUpTitle => 'Ready to pick up?';

  @override
  String get drNotificationsEmptyBody => 'Task notifications will appear here';

  @override
  String get drNotificationsEmptyTitle => 'No notifications';

  @override
  String get drNotificationsErrorTitle => 'Could not load notifications';

  @override
  String get drNotificationsTitle => 'Notifications';

  @override
  String get drOpenMap => 'Open map';

  @override
  String get drOrderAccept => 'Accept order';

  @override
  String get drOrderIgnore => 'Ignore';

  @override
  String get drOrderNotes => 'Notes';

  @override
  String get drOrderTotal => 'Order total';

  @override
  String get drOrdersEmptyBody =>
      'We will let you know when a new order is available nearby';

  @override
  String get drOrdersEmptyTitle => 'No orders available right now';

  @override
  String get drOrdersErrorBody => 'Check your connection and try again';

  @override
  String get drOrdersErrorTitle => 'Could not load orders';

  @override
  String get drOrdersNearby => 'Orders near you';

  @override
  String get drOrdersOfflineBody => 'Go online to see available orders';

  @override
  String get drOrdersOfflineTitle => 'You are offline';

  @override
  String get drOrdersViewDetails => 'View details';

  @override
  String get drPhotoAdded => 'Photo added';

  @override
  String get drPhotoOptional => 'Proof photo (optional)';

  @override
  String get drPickupConfirmBody =>
      'Make sure the order is complete before confirming';

  @override
  String get drPickupConfirmButton => 'Confirm pickup';

  @override
  String get drPickupConfirmTitle => 'Did you pick up the order?';

  @override
  String get drPickupConfirming => 'Confirming pickup…';

  @override
  String get drPickupNotYet => 'Not yet';

  @override
  String get drProfileLogout => 'Sign out';

  @override
  String get drProfileLogoutConfirm => 'Do you want to sign out?';

  @override
  String get drProfilePhone => 'Phone number';

  @override
  String get drProfileTitle => 'My account';

  @override
  String get drProfileVehicle => 'Vehicle';

  @override
  String get drReportFailure => 'Report delivery failure';

  @override
  String get drRetryDelivery => 'Retry delivery';

  @override
  String get drStepAccepted => 'Accepted';

  @override
  String get drStepArrived => 'Arrived';

  @override
  String get drStepDelivered => 'Delivered';

  @override
  String get drStepOnTheWay => 'On the way';

  @override
  String get drStepPickedUp => 'Picked up';

  @override
  String get drStopDropoff => 'Drop-off';

  @override
  String get drStopPickup => 'Pickup';

  @override
  String get drTaskDetailsTitle => 'Task details';

  @override
  String get drTaskEmptyBody => 'Accept an order from the list to start';

  @override
  String get drTaskEmptyTitle => 'No current task';

  @override
  String get drTaskErrorTitle => 'Could not load the task';

  @override
  String get drTaskGoOrders => 'Browse orders';

  @override
  String get drTaskOfflineTitle => 'Connection lost';

  @override
  String get drTaskRefresh => 'Refresh task';

  @override
  String get drTaskStaleBody =>
      'The task status changed. Refresh to see the latest';

  @override
  String get drTaskStaleTitle => 'Status changed';

  @override
  String get drTaskTitle => 'Current task';

  @override
  String get drYourEarning => 'Your earning';

  @override
  String get drKmUnit => 'km';

  @override
  String get drOrderItems => 'Order items';

  @override
  String get drPhotoRequired => 'Proof photo (required)';

  @override
  String get drOrdersUnit => 'orders';

  @override
  String get drCashCollected => 'Cash collected';

  @override
  String get drCashRemaining => 'Remaining before limit';

  @override
  String get drCashUnsettled => 'Unsettled orders';

  @override
  String get drCashSettlement => 'Cash settlement';

  @override
  String get drCollectAmount => 'Amount to collect';

  @override
  String get drCollectFromCustomerHint => 'Collected from the customer';

  @override
  String get drYourFeeHint => 'Your fee for this task';

  @override
  String get drCurrentTaskTitle => 'Current task';

  @override
  String get drHomeEarningsHint => 'Track your earnings and cash balance';

  @override
  String get drHomeOrdersHint => 'See orders near you';

  @override
  String get drHomeTaskHint => 'Continue your current task';

  @override
  String get drLogout => 'Sign out';

  @override
  String get drLogoutConfirm => 'Do you want to sign out?';

  @override
  String get drNavProfile => 'Account';

  @override
  String get drStepA => 'A';

  @override
  String get drStepB => 'B';

  @override
  String get drViewCash => 'View cash balance';

  @override
  String get drFailureNotice =>
      'Make sure you tried calling the customer before reporting a failed delivery.';
}
