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
  String get errorTimeout => 'The connection timed out. Please try again.';

  @override
  String get errorSessionExpired =>
      'Your session has ended. Please sign in again.';

  @override
  String get errorRateLimited =>
      'Too many requests. Please wait a moment and try again.';

  @override
  String errorRateLimitedSeconds(int seconds) {
    return 'Too many requests. Try again in $seconds seconds.';
  }

  @override
  String get errorAppNotConfigured =>
      'The app is not configured to reach the server right now.';

  @override
  String get errorOutOfZone =>
      'This address is outside the delivery area. Choose another address.';

  @override
  String get errorOutOfStock =>
      'The requested quantity is not available right now.';

  @override
  String errorOutOfStockAvailable(int count) {
    return 'Not enough stock. Available now: $count.';
  }

  @override
  String get errorStateChanged =>
      'The order status changed. We refreshed it — please review and continue.';

  @override
  String get remove => 'Remove';

  @override
  String get reject => 'Reject';

  @override
  String get quoteExpiredBody =>
      'Refresh the price and availability before confirming.';

  @override
  String get quoteUsedBody =>
      'Check your orders before trying to place a new one.';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get increase => 'Increase';

  @override
  String get decrease => 'Decrease';

  @override
  String get deliveryFee => 'Delivery fee';

  @override
  String get printingServicesTitle => 'Printing services';

  @override
  String get printingHeroEyebrow => 'From file to paper';

  @override
  String get printingHeroTitle => 'Leave your files to us!';

  @override
  String get printingHeroBody =>
      'Upload your file, choose the options, and we’ll handle the printing.';

  @override
  String printingServiceBw(String paper) {
    return 'Black & white $paper';
  }

  @override
  String printingServiceColor(String paper) {
    return 'Color printing $paper';
  }

  @override
  String perPrintedSide(String price) {
    return '$price / printed side';
  }

  @override
  String perCopy(String price) {
    return '$price / copy';
  }

  @override
  String get printingFinalPriceNote =>
      'Review the final price before confirming your order.';

  @override
  String get printingStart => 'Start a print order';

  @override
  String get printSpecsTitle => 'File specifications';

  @override
  String get printSpecsHint =>
      'Choose the options for each file, then review the price before confirming.';

  @override
  String get whatToPrint => 'What would you like to print?';

  @override
  String get supportedFiles => 'Supported files';

  @override
  String get supportedFileTypes => 'PDF, JPG, PNG, WebP';

  @override
  String get maxFileSize => 'Maximum size';

  @override
  String maxPerFile(String size) {
    return '$size per file';
  }

  @override
  String get maxFiles => 'Files allowed';

  @override
  String get tapToChooseFile => 'Tap to choose a file';

  @override
  String get addAnotherFile => 'Add another file with different options';

  @override
  String fileLimitBody(int max) {
    return 'You reached the file limit ($max). Remove a file before adding a new one.';
  }

  @override
  String get uploadTooLargeTitle => 'The file is too large';

  @override
  String uploadTooLargeBody(String size) {
    return 'Each file must be $size or smaller. Reduce the file size and try again.';
  }

  @override
  String get uploadUnsupportedTitle => 'Unsupported file type';

  @override
  String get uploadUnsupportedBody => 'Upload a PDF, JPG, PNG or WebP file.';

  @override
  String get uploadEmptyBody => 'The file is empty. Choose another file.';

  @override
  String get chooseAnotherFile => 'Choose another file';

  @override
  String uploadingPercent(int percent) {
    return 'Uploading… $percent%';
  }

  @override
  String get uploadFailed => 'The file could not be uploaded.';

  @override
  String pagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pages',
      one: '1 page',
    );
    return '$_temp0';
  }

  @override
  String get paperSize => 'Paper size';

  @override
  String get printColor => 'Color';

  @override
  String get printColorBw => 'Black & white';

  @override
  String get printColorColor => 'Color';

  @override
  String get printSides => 'Sides';

  @override
  String get printSidesSingle => 'Single-sided';

  @override
  String get printSidesDouble => 'Double-sided';

  @override
  String get binding => 'Binding';

  @override
  String get pageRange => 'Pages to print';

  @override
  String get pageRangeAllHint => 'All';

  @override
  String pageRangeHelper(int pages) {
    return 'Leave empty for all pages, or write e.g. 1-5, 8. The file has $pages pages.';
  }

  @override
  String get pageRangeInvalid =>
      'Check the page range: use a format like 1-5, 8 within the file’s pages.';

  @override
  String get copies => 'Copies';

  @override
  String pagesTimesCopies(int pages, int copies) {
    return 'Pages: $pages · Copies: $copies';
  }

  @override
  String get fileNotes => 'Notes for this file';

  @override
  String get fileNotesHint => 'Any extra details?';

  @override
  String get estimateForFile => 'Estimate for this file';

  @override
  String get estimateLabel => 'Estimate';

  @override
  String get reviewPrice => 'Review price';

  @override
  String get cartTitle => 'Your cart';

  @override
  String get cartEmptyTitle => 'Your cart is empty';

  @override
  String get cartEmptyBody => 'Add products or print files to continue.';

  @override
  String get startShopping => 'Start shopping';

  @override
  String get productsSection => 'Products';

  @override
  String get printingSection => 'Printing';

  @override
  String productNumber(int id) {
    return 'Product #$id';
  }

  @override
  String get pricedByLibrary => 'Priced by the library';

  @override
  String get productUnavailable => 'This product is currently unavailable.';

  @override
  String onlyAvailable(int count) {
    return 'Only $count available now. Adjust the quantity.';
  }

  @override
  String chooseOption(String label) {
    return 'Choose $label';
  }

  @override
  String get illustrativePrice => 'Illustrative price';

  @override
  String get printingIllustrative => 'Printing (estimate)';

  @override
  String get notesForLibrary => 'Notes for the library';

  @override
  String get notesForLibraryHint => 'Anything you’d like to add?';

  @override
  String get ifOutOfStock => 'If an item is out of stock';

  @override
  String get deliveryByAddress => 'Based on address';

  @override
  String get totalBeforeDelivery => 'Total before delivery';

  @override
  String get finalPriceAtReview =>
      'Prices here are for display. The final price appears at order review.';

  @override
  String get continueToDelivery => 'Continue to delivery';

  @override
  String get waitForUploads =>
      'Wait for the files to finish uploading before continuing.';

  @override
  String get fixFailedUploads =>
      'Some files failed to upload. Retry or remove them.';

  @override
  String get uploadInterrupted =>
      'This upload was interrupted because the app closed before it finished. Choose the same file again or remove it.';

  @override
  String get uploadInterruptedShort =>
      'Upload interrupted — choose the file again.';

  @override
  String get chooseFileAgain => 'Choose file';

  @override
  String get fixInterruptedUploads =>
      'Some print files were not fully uploaded. Open the print specs and choose them again or remove them.';

  @override
  String get total => 'Total';

  @override
  String get discount => 'Discount';

  @override
  String get payment => 'Payment';

  @override
  String get orderCode => 'Order code';

  @override
  String get orderStatus => 'Order status';

  @override
  String get viewOrder => 'View order';

  @override
  String get viewMyOrders => 'View my orders';

  @override
  String get deliveryTitle => 'Delivery address';

  @override
  String get whereToDeliver => 'Where should we deliver?';

  @override
  String get addAddress => 'Add address';

  @override
  String get noAddresses => 'No saved addresses. Add one to continue.';

  @override
  String addressNumber(int id) {
    return 'Address $id';
  }

  @override
  String get insideDeliveryArea => 'Inside the delivery area';

  @override
  String get outsideDeliveryArea => 'Outside the delivery area';

  @override
  String get recipientNameOptional => 'Recipient name (optional)';

  @override
  String get recipientNameHint => 'Name';

  @override
  String get recipientPhoneOptional => 'Phone number (optional)';

  @override
  String get phoneInvalid => 'The phone number is not valid.';

  @override
  String get deliveryNotes => 'Delivery notes';

  @override
  String get deliveryNotesHint => 'A landmark or directions';

  @override
  String get deliveryFeeAtReview =>
      'The delivery fee and final total appear at order review.';

  @override
  String get continueToPayment => 'Continue to payment';

  @override
  String get paymentMethodTitle => 'Payment method';

  @override
  String get howToPay => 'How would you like to pay?';

  @override
  String get payCashOnDelivery => 'Cash on delivery';

  @override
  String get payBankTransfer => 'Bank transfer or wallet';

  @override
  String get paymentMethodNote =>
      'The amount and details appear before you confirm the order.';

  @override
  String get transferAfterOrderNote =>
      'Upload the transfer receipt after the library confirms the order price.';

  @override
  String get reviewOrder => 'Review order';

  @override
  String get reviewBeforeConfirm => 'Review your order before confirming';

  @override
  String get orderType => 'Order type';

  @override
  String get orderTypeProducts => 'Products';

  @override
  String get orderTypePrinting => 'Printing';

  @override
  String get orderTypeMixed => 'Products and printing';

  @override
  String quoteValidFor(int minutes, String seconds) {
    return 'This quote is valid for $minutes:$seconds';
  }

  @override
  String get libraryConfirmsNote =>
      'After you confirm, the library reviews your order and sends the final price for your approval.';

  @override
  String get confirmOrder => 'Confirm order';

  @override
  String get quoteLoadingTitle => 'Calculating the price';

  @override
  String get quoteLoadingBody => 'Getting the current price and availability.';

  @override
  String get quoteFailedTitle => 'Couldn’t calculate the price';

  @override
  String get quoteFailedBody =>
      'Check your connection, address and order options, then try again.';

  @override
  String get quoteNotReady =>
      'Complete the cart, address and payment method, and wait for uploads before requesting a price.';

  @override
  String get fixHighlightedItems =>
      'Fix the highlighted items in your cart, then try again.';

  @override
  String get backToCart => 'Back to cart';

  @override
  String get changeAddress => 'Change address';

  @override
  String get quoteExpiredTitle => 'The quote has expired';

  @override
  String get quoteStaleTitle => 'Your order changed';

  @override
  String get quoteStaleBody =>
      'You changed the cart or delivery after the quote. Get a new price and review it.';

  @override
  String get quoteUsedTitle => 'This quote was already used';

  @override
  String get refreshQuote => 'Refresh quote';

  @override
  String get priceChangedBody =>
      'The price changed. Review the new price before continuing.';

  @override
  String get paymentMethodChangedBody =>
      'You changed the payment method, so we issued a new quote for it. The amount is unchanged.';

  @override
  String get previousPrice => 'Previous price';

  @override
  String get currentPrice => 'Current price';

  @override
  String get acceptNewPrice => 'Accept the new price';

  @override
  String get submittingTitle => 'Placing your order';

  @override
  String get submittingBody => 'Confirming your order details and price.';

  @override
  String get uncertainTitle => 'We couldn’t confirm the result';

  @override
  String get uncertainBody =>
      'Your order may have been placed. Check again or review your orders before retrying to avoid a duplicate.';

  @override
  String get checkAgain => 'Check again';

  @override
  String get checkMyOrders => 'Check my orders';

  @override
  String get orderCreatedTitle => 'Order placed';

  @override
  String get orderCreatedBody => 'Follow the order status for the next step.';

  @override
  String get orderAwaitingPaymentTitle => 'Your order was placed';

  @override
  String get orderCreatedTransferBody =>
      'The library will review the order; then transfer the amount and upload the receipt when payment opens.';

  @override
  String get viewTransferDetails => 'View transfer details';
}
