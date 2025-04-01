import '../../common/constants.dart';

/// Default app config, it's possible to set as URL
// const kAppConfig = 'lib/config/config_en.json';
const kAppConfig = 'https://up.ctown.jo/api/mobilebannersection.php';

// TODO: 4-Update Google Map Address
/// The Google API Key to support Pick up the Address automatically
/// We recommend to generate both ios and android to restrict by bundle app id
/// The download package is remove these keys, please use your own key
const kGoogleAPIKey = {
  'android': 'AIzaSyD3aB7FcaMNt6sx_-P6DqK32vYgO6QA4n4',
  'ios': 'AIzaSyD3aB7FcaMNt6sx_-P6DqK32vYgO6QA4n4',
  'web': 'AIzaSyD3aB7FcaMNt6sx_-P6DqK32vYgO6QA4n4'
};

const kHuaweiAPIKey = {
  'android':
      'DAEDADiiv9gpwhAw6nh6cwbn9co7%2FHPpBYs0olxf3Vhgawc%2BfNzk4KHFYd5juW1bXklcy24cXe1oCv4WNRYXZzwGzdJBPPVLaEMCzQ%3D%3D',
};

/// user for upgrader version of app, remove the comment from lib/app.dart to enable this feature
/// https://tppr.me/5PLpD
const kUpgradeURLConfig = {
  'android': 'https://play.google.com/store/apps/details?id=jo.ctown.ecom',
  'ios': 'https://apps.apple.com/in/app/ctown-jordan/id1602258988'
};

/// use for rating app on store feature
const kStoreIdentifier = {'android': 'jo.ctown.ecom', 'ios': '1469772800'};

const kAdvanceConfig = {
  'DefaultLanguage': 'en',
  'DetailedBlogLayout': kBlogLayout.halfSizeImageType,
  'EnablePointReward': true,
  'EnableVoucher': true,
  'EnableCoupon': true,
  'hideOutOfStock': false,
  'EnableRating': true,
  'EnableAddressbook': false,
  'hideEmptyProductListRating': false,
  'EnableShipping': true,

  /// Enable search by SKU in search screen
  'EnableSkuSearch': true,

  /// Show stock Status on product List & Product Detail
  'showStockStatus': true,

  /// Gird count setting on Category screen
  'GridCount': 3,

  // TODO: 4.Upgrade App Performance & Image Optimize
  /// set isCaching to true if you have upload the config file to store-api
  /// set kIsResizeImage to true if you have finished running Re-generate image plugin
  'isCaching': true,
  'kIsResizeImage': false,

  // TODO: 3.Update Mutli-Currencies and Default Currency
  /// Stripe payment only: set currencyCode and smallestUnitRate.
  /// All API requests expect amounts to be provided in a currency’s smallest unit.
  /// For example, to charge 10 USD, provide an amount value of 1000 (i.e., 1000 cents).
  /// Reference: https://stripe.com/docs/currencies#zero-decimal
  ///
  ///

  /* "DefaultCurrency": {
    "symbol": "AED ",
    "decimalDigits": 2,
    "symbolBeforeTheNumber": true,
    "currency": "AED ",
    "currencyCode": "usd",
    "smallestUnitRate": 100, // 100 cents = 1 usd
  },
  "Currencies": [
    {
      "symbol": "AED ",
      "decimalDigits": 2,
      "symbolBeforeTheNumber": true,
      "currency": "AED ",
      "currencyCode": "aed",
      "smallestUnitRate": 100, // 100 cents = 1 usd
    },

    */
  'DefaultCurrency': {
    'symbol': 'JOD ',
    'decimalDigits': 2,
    'symbolBeforeTheNumber': true,
    'currency': 'JOD',
    'currencyCode': 'jod',
    'smallestUnitRate': 100, // 100 cents = 1 usd
  },
  'Currencies': [
    {
      'symbol': 'JOD ',
      'decimalDigits': 2,
      'symbolBeforeTheNumber': true,
      'currency': 'JOD ',
      'currencyCode': 'jod',
      'smallestUnitRate': 100, // 100 cents = 1 usd
    },
    // {
    //   "symbol": "đ",
    //   "decimalDigits": 2,
    //   "symbolBeforeTheNumber": false,
    //   "currency": "VND"
    // },
    // {
    //   "symbol": "€",
    //   "decimalDigits": 2,
    //   "symbolBeforeTheNumber": true,
    //   "currency": "Euro"
    // },
    // {
    //   "symbol": "£",
    //   "decimalDigits": 2,
    //   "symbolBeforeTheNumber": true,
    //   "currency": "Pound sterling",
    //   "currencyCode": "gbp",
    //   "smallestUnitRate": 100, // 100 pennies = 1 pound
    // }
  ],

  // TODO: 3.Update Magento Config Product
  /// Below config is used for Magento store
  'DefaultStoreViewCode': '',
  'EnableAttributesConfigurableProduct': ['color', 'size', 'product_weight'],
  'EnableAttributesLabelConfigurableProduct': [
    'color',
    'size',
    'product_weight'
  ],

  /// if the woo commerce website supports multi languages
  /// set false if the website only have one language
  'isMultiLanguages': true,

  ///Review gets approved automatically on woocommerce admin without requiring administrator to approve.
  'EnableApprovedReview': true,

  /// Sync Cart from website and mobile
  'EnableSyncCartFromWebsite': true,
  'EnableSyncCartToWebsite': true,

  /// Disable shopping Cart due to Listing Users request
  'EnableShoppingCart': true,

  /// Enable firebase to support FCM, realtime chat for store MV
  'EnableFirebase': false,

  /// ratio Product Image, default value is 1.2 = height / width
  'RatioProductImage': 1.21,

  /// Enable Coupon Code When checkout
  'EnableCouponCode': true,
};

// TODO: 3.Update Social Login Login
const kLoginSetting = {
  'IsRequiredLogin': false,
  'showAppleLogin': false,
  'showFacebook': false,
  'showSMSLogin': true,
  'showGoogleLogin': false,
  'showPhoneNumberWhenRegister': true,
  'requirePhoneNumberWhenRegister': true,
};

// TODO: 3.Update Left Menu Setting
const kDefaultDrawer = {
  'logo': 'assets/images/logo.png',
  'background': null,
  'items': [
    {'type': 'home', 'show': true},
    {'type': 'blog', 'show': true},
    {'type': 'categories', 'show': true},
    {'type': 'cart', 'show': true},
    {'type': 'profile', 'show': true},
    {'type': 'login', 'show': true},
    {'type': 'category', 'show': true},
  ]
};

// TODO: 3.Update The Setting Screens Menu
/// you could order the position to change menu
const kDefaultSettings = [
  // 'addressbook',
  'products',
  // 'chat',
  'language',
  'order',
  'point',
  'voucher',
  'feedback',
  'wishlist',
  'shoppinglist',
  // 'notifications',
  // 'currencies',
  'darkTheme',

  /*'coupon',*/
  'switchstore',
  'rating',
  // 'privacy',
  'helpsupport',
  'legal',
  // 'about',
];

// TODO: 3.Update Push Notification For OneSignal
const kOneSignalKey = {
  'enable': false,
  'appID': '8b45b6db-7421-45e1-85aa-75e597f62714',
};

/// Use for set default SMS Login
class LoginSMSConstants {
  static const String countryCodeDefault = 'VN';
  static const String dialCodeDefault = '+84';
  static const String nameDefault = 'Vietnam';
}

/// update default dark theme
/// advance color theme could be changed from common/styles.dart
const kDefaultDarkTheme = false;
