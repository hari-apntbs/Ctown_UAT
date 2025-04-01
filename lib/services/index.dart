import 'package:ctown/widgets/home/clickandcollect_provider.dart';

import '../frameworks/magento/services/magento_mixin.dart';
import '../models/entities/listing_booking.dart';
import '../models/index.dart';
import '../models/vendor/store_model.dart';
import '../widgets/common/internet_connectivity.dart';
import 'base_services.dart';
import 'service_config.dart';

export 'service_config.dart';

class Services with ConfigMixin, MagentoMixin implements BaseServices {
  static final Services _instance = Services._internal();

  factory Services() => _instance;

  Services._internal();

  @override
  Future<List<Product>> fetchProductsByCategory(
      {categoryId,
        tagId,
        page = 1,
        minPrice,
        maxPrice,
        orderBy,
        order,
        lang,
        sort,
        featured,
        onSale,
        attribute,
        attributeTerm}) async {
    MyConnectivity.checking();
    return (serviceApi?.fetchProductsByCategory(
        categoryId: categoryId,
        tagId: tagId,
        page: page,
        minPrice: minPrice,
        maxPrice: maxPrice,
        orderBy: orderBy,
        lang: lang,
        sort: sort,
        order: order,
        featured: featured,
        onSale: onSale,
        attribute: attribute,
        attributeTerm: attributeTerm))!;
  }

  @override
  Future<List<Product>> fetchProductsLayout({required config, lang = "en"}) async {
    return (serviceApi?.fetchProductsLayout(config: config, lang: lang))!;
  }

  @override
  Future<List<Category>> getCategories({lang = "en"}) async {
    MyConnectivity.checking();
    return (serviceApi?.getCategories(lang: lang))!;
  }

  @override
  Future<List<Product>> getProducts() async {
    MyConnectivity.checking();
    return (serviceApi?.getProducts())!;
  }

  @override
  Future<List<Product>> getProductsonDeal(
      {int? page,
        int? categoryId,
        orderBy,
        order,
        featured,
        onSale,
        lang = "en"}) async {
    MyConnectivity.checking();
    return (serviceApi?.getProductsonDeal(
        page: page,
        categoryId: categoryId,
        orderBy: orderBy,
        order: order,
        featured: featured,
        onSale: onSale,
        lang: lang))!;
  }

  @override
  Future<User?> loginFacebook({String? token}) async {
    MyConnectivity.checking();
    return serviceApi?.loginFacebook(token: token);
  }

  @override
  Future<User?> loginSMS({String? token}) async {
    MyConnectivity.checking();
    return serviceApi?.loginSMS(token: token);
  }

  @override
  Future<User?> loginApple({String? email, String? fullName}) async {
    MyConnectivity.checking();
    return serviceApi?.loginApple(email: email, fullName: fullName);
  }

  @override
  Future<User?> loginGoogle({String? token}) async {
    MyConnectivity.checking();
    return serviceApi?.loginGoogle(token: token);
  }

  @override
  Future<List<Review>?> getReviews(productId) async {
    MyConnectivity.checking();
    return serviceApi?.getReviews(productId);
  }

  @override
  Future<List<ProductVariation>?> getProductVariations(
      Product product, String? lang) async {
    MyConnectivity.checking();
    return serviceApi?.getProductVariations(product, lang);
  }

  @override
  Future<List<ShippingMethod>> getShippingMethods(
      {CartModel? cartModel,
        String? token,
        String? checkoutId,
        ClickNCollectProvider? clickNCollectProvider, String? lang}) async {
    MyConnectivity.checking();
    return (serviceApi?.getShippingMethods(
        cartModel: cartModel,
        token: token,
        checkoutId: checkoutId,
        clickNCollectProvider: clickNCollectProvider))!;
  }

  @override
  Future<List<PaymentMethod>> getPaymentMethods(
      {CartModel? cartModel,
        ShippingMethod? shippingMethod,
        String? token, required String lang}) async {
    MyConnectivity.checking();
    return (serviceApi?.getPaymentMethods(
        cartModel: cartModel, shippingMethod: shippingMethod, token: token, lang: lang))!;
  }

  @override
  Future<List<Order>> getMyOrders({UserModel? userModel, int? page, String? lang}) async {
    MyConnectivity.checking();
    return (serviceApi?.getMyOrders(userModel: userModel, page: page))!;
  }

  @override
  Future<Order?> createOrder(
      {CartModel? cartModel,
        UserModel? user,
        bool? paid,
        ClickNCollectProvider? clickNCollectProvider, String? lang}) async {
    MyConnectivity.checking();
    return serviceApi?.createOrder(
        cartModel: cartModel,
        user: user,
        paid: paid,
        clickNCollectProvider: clickNCollectProvider);
  }

  @override
  Future updateOrder(orderId, lang,{status, token}) async {
    MyConnectivity.checking();
    return serviceApi?.updateOrder(orderId,lang, status: status, token: token);
  }

  @override
  Future<List<Product>> searchProducts(
      {name,
        categoryId,
        tag,
        attribute,
        attributeId,
        page,
        lang,
        isBarcode}) async {
    MyConnectivity.checking();
    return (serviceApi?.searchProducts(
        name: name,
        categoryId: categoryId,
        tag: tag,
        attribute: attribute,
        attributeId: attributeId,
        page: page,
        lang: lang,
        isBarcode: isBarcode))!;
  }

  /// Create new user, use for Registration screen
  @override
  Future<User?> createUser({
    String? firstName,
    String? lastName,
    String? username,
    String? password,
    String? countryCode,
    String? phoneNumber,
    String? otp,
    String? loyalty_card_number,
    bool isVendor = false,
  }) async {
    MyConnectivity.checking();
    return serviceApi?.createUser(
      firstName: firstName,
      lastName: lastName,
      username: username,
      password: password,
      countryCode: countryCode,
      phoneNumber: phoneNumber,
      otp: otp,
      loyalty_card_number: loyalty_card_number,
      isVendor: isVendor,
    );
  }

  /// Get user info
  @override
  Future<User?> getUserInfo(cookie) async {
    MyConnectivity.checking();
    return serviceApi?.getUserInfo(cookie);
  }

  /// Login by username and password
  @override
  Future<User?> login({username, password, lang}) async {
    MyConnectivity.checking();
    return serviceApi?.login(username: username, password: password, lang: lang);
  }

  /// Get product by ID and current select language
  @override
  Future<Product?> getProduct(id, {lang}) async {
    MyConnectivity.checking();
    return serviceApi?.getProduct(id, lang: lang);
  }

  /// Get list of Coupon code, for Checkout Screen
  @override
  Future<Coupons?> getCoupons() async {
    MyConnectivity.checking();
    return serviceApi?.getCoupons();
  }

  /// Get all tracking info, use for Oder Screen
  @override
  Future<AfterShip?> getAllTracking() async {
    MyConnectivity.checking();
    return serviceApi?.getAllTracking();
  }

  /// Get Order Note, use for Checkout Screen
  @override
  Future<List<OrderNote>?> getOrderNote(
      {UserModel? userModel, String? orderId}) async {
    MyConnectivity.checking();
    final orderNote = await serviceApi?.getOrderNote(userModel: userModel, orderId: orderId);
    if(orderNote !=  null){
      return orderNote;
    }
    else {
      return [];
    }
  }

  /// Add new Product Review, available for purchased product
  @override
  Future createReview({String? productId, Map<String, dynamic>? data}) async {
    MyConnectivity.checking();
    return serviceApi?.createReview(productId: productId, data: data);
  }

  @override
  Future<Map<String, dynamic>?> getHomeCache(String lang) async {
    MyConnectivity.checking();
    return serviceApi?.getHomeCache(lang);
  }

  /// Update user info, for the Setting Screen
  @override
  Future<Map<String, dynamic>?> updateUserInfo(
      Map<String, dynamic> json, User? user) async {
    MyConnectivity.checking();
    return serviceApi?.updateUserInfo(json, user);
  }

  @override
  Future? getCategoryWithCache() {
    MyConnectivity.checking();
    return serviceApi?.getCategoryWithCache();
  }

  @override
  Future<List<FilterAttribute>?>? getFilterAttributes() {
    MyConnectivity.checking();
    return serviceApi?.getFilterAttributes();
  }

  @override
  Future<List<SubAttribute>?>? getSubAttributes({int? id}) {
    MyConnectivity.checking();
    return serviceApi?.getSubAttributes(id: id);
  }

  @override
  Future<List<FilterTag>?>? getFilterTags() {
    MyConnectivity.checking();
    return serviceApi?.getFilterTags();
  }

  @override
  Future<String?>? getCheckoutUrl(Map<String, dynamic> params, String lang) {
    MyConnectivity.checking();
    return serviceApi?.getCheckoutUrl(params, lang);
  }

  @override
  Future<String?>? submitForgotPassword(
      {String? forgotPwLink, Map<String, dynamic>? data}) {
    MyConnectivity.checking();
    return serviceApi?.submitForgotPassword(
        forgotPwLink: forgotPwLink, data: data);
  }

  @override
  Future? logout() {
    MyConnectivity.checking();
    return serviceApi?.logout();
  }

  /// Checkout by using Credit Cart, only available for Shopify App
  @override
  checkoutWithCreditCard(String? vaultId, CartModel cartModel, Address address,
      PaymentSettingsModel paymentSettingsModel) async {
    MyConnectivity.checking();
    return serviceApi?.checkoutWithCreditCard(
        vaultId, cartModel, address, paymentSettingsModel);
  }

  @override
  getPaymentSettings() {
    MyConnectivity.checking();
    return serviceApi?.getPaymentSettings();
  }

  /// Add new Credit Cart, only available for Shopify App
  @override
  addCreditCard(PaymentSettingsModel paymentSettingsModel,
      CreditCardModel creditCardModel) {
    MyConnectivity.checking();
    return serviceApi?.addCreditCard(paymentSettingsModel, creditCardModel);
  }

  /// Get the current Rate exchange, use for multi currency
  @override
  Future<Map<String, dynamic>>? getCurrencyRate() {
    MyConnectivity.checking();
    return serviceApi?.getCurrencyRate();
  }

  /// Get cart info, only available for Shopify App
  @override
  Future? getCartInfo(String token) {
    MyConnectivity.checking();
    return serviceApi?.getCartInfo(token);
  }

  /// Sync the checkout care info back the Website
  @override
  Future? syncCartToWebsite(CartModel cartModel, User user) {
    MyConnectivity.checking();
    return serviceApi?.syncCartToWebsite(cartModel, user);
  }

  Future<Map<String, dynamic>>? getCustomerInfo(String? id, String? cookie, String? lang) {
    MyConnectivity.checking();
    return serviceApi?.getCustomerInfo(id, cookie, lang);
  }

  @override
  Future<Map<String, dynamic>>? getTaxes(CartModel cartModel) {
    MyConnectivity.checking();
    return serviceApi?.getTaxes(cartModel);
  }

  @override
  Future<Map<String, Tag>>? getTags({String? lang}) {
    return serviceApi?.getTags(lang: lang);
  }

  @override
  Future getCountries() async {
    MyConnectivity.checking();
    return serviceApi?.getCountries();
  }

  @override
  Future getStatesByCountryId(countryId) async {
    MyConnectivity.checking();
    return serviceApi?.getStatesByCountryId(countryId);
  }

  /// Vendor Features: Create new product
  @override
  Future<Product>? createProduct(
      String cookie, Map<String, dynamic> data) async {
    MyConnectivity.checking();
    return (serviceApi?.createProduct(cookie, data))!;
  }

  /// Vendor Features: Get Feature Vendor
  @override
  Future<List<Store>>? getFeaturedStores() async {
    MyConnectivity.checking();
    final store = await serviceApi?.getFeaturedStores();
    if(store != null){
      return store;
    }
    else{
      return [];
    }
  }

  /// Vendor Features:
  /// Get Vendor products
  Future<List<Product>>? getOwnProducts(String cookie, {int? page}) async {
    MyConnectivity.checking();
    final product = await serviceApi?.getOwnProducts(cookie, page: page);
    if(product != null) {
      return product;
    }
    else {
      return [];
    }
  }

  /// Vendor Features:
  /// Get all product by Store/Vendors
  @override
  Future<List<Product>>? getProductsByStore({storeId, page}) async {
    MyConnectivity.checking();
    final product = await serviceApi?.getProductsByStore(storeId: storeId, page: page);
    if(product != null){
      return product;
    }
    else{
      return [];
    }
  }

  /// Vendor Features:
  /// Upload Image when create new product
  @override
  Future<dynamic>? uploadImage(dynamic data) async {
    MyConnectivity.checking();
    return serviceApi?.uploadImage(data);
  }

  /// Vendor Features:
  /// Get Store Review Rating
  @override
  Future<List<Review>>? getReviewsStore({storeId}) async {
    MyConnectivity.checking();
    final reviews = await serviceApi?.getReviewsStore(storeId: storeId);
    if (reviews != null) {
      return reviews;
    } else {
      // Handle the case where the serviceApi call returns null
      // You can return an empty list or throw an exception if appropriate
      return []; // or throw Exception('Failed to retrieve reviews');
    }
  }

  /// Vendor Features: Push notification when using chat feature
  @override
  Future<bool> pushNotification({receiverEmail, senderName, message}) async {
    MyConnectivity.checking();
    var value = serviceApi?.pushNotification(
        receiverEmail: receiverEmail, senderName: senderName, message: message);
    if(value != null){
      return value;
    }
    else {
      return false;
    }
  }

  /// Vendor Features: Get Store information
  @override
  Future<Store>? getStoreInfo(storeId) async {
    MyConnectivity.checking();
    return (serviceApi?.getStoreInfo(storeId))!;
  }

  /// Vendor Features: Search the Stores
  @override
  Future<List<Store>>? searchStores({String? keyword, int? page}) {
    MyConnectivity.checking();
    return serviceApi?.searchStores(keyword: keyword, page: page);
  }

  /// Vendor Features: Get the Vendor Orders
  @override
  Future<List<Order>>? getVendorOrders({UserModel? userModel, int? page}) {
    MyConnectivity.checking();
    return serviceApi?.getVendorOrders(userModel: userModel, page: page);
  }

  @override
  Future<Point>? getMyPoint(String? token) {
    MyConnectivity.checking();
    return serviceApi?.getMyPoint(token);
  }

  @override
  Future? updatePoints(String? token, Order? order) {
    MyConnectivity.checking();
    return serviceApi?.updatePoints(token, order);
  }

  @override
  Future<dynamic>? bookService({userId, value, message}) {
    MyConnectivity.checking();
    return serviceApi?.bookService(
        userId: userId, value: value, message: message);
  }

  @override
  Future<List<Product>>? getProductNearest(location) {
    MyConnectivity.checking();
    return serviceApi?.getProductNearest(location);
  }

  @override
  Future<List<ListingBooking>>? getBooking({userId, page, perPage}) {
    MyConnectivity.checking();
    return serviceApi?.getBooking(userId: userId, page: page, perPage: perPage);
  }

  /// BOOKING FEATURE
  @override
  Future<bool>? createBooking(dynamic bookingInfo) {
    return serviceApi?.createBooking(bookingInfo);
  }

  @override
  Future<List<dynamic>>? getListStaff(String idProduct) {
    return serviceApi?.getListStaff(idProduct);
  }

  @override
  Future<List<String>>? getSlotBooking(
      String idProduct, String idStaff, String date) {
    return serviceApi?.getSlotBooking(idProduct, idStaff, date);
  }

  @override
  Future<Map<String, dynamic>>? checkBookingAvailability({data}) {
    return serviceApi?.checkBookingAvailability(data: data);
  }

  @override
  Future<void>? addAddress(
      Address address, User? user, String? lang, String? lati, String? lan) {
    return serviceApi?.addAddress(address, user, lang, lati, lan);
  }

  @override
  Future<void>? editAddress(
      Address address, User? user, String? lang, String? lat, String? lan) {
    return serviceApi?.editAddress(address, user, lang, lat, lan);
  }

  @override
  Future<void>? deleteAddress(Address address) {
    return serviceApi?.deleteAddress(address);
  }

  @override
  Future<bool> deleteItemFromCart(key, token, lang) async {
    MyConnectivity.checking();
    return (serviceApi?.deleteItemFromCart(key, token, lang))!;
  }

  @override
  Future<List<String>>? getProductAddtionalInfo(productId) async {
    MyConnectivity.checking();
    final value = await serviceApi?.getProductAddtionalInfo(productId);
    if(value != null){
      return value;
    }
    else {
      return [];
    }
  }

  @override
  var blogApi;
}
