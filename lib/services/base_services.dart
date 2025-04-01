import 'package:ctown/widgets/home/clickandcollect_provider.dart';

import '../models/entities/listing_booking.dart';
import '../models/index.dart';
import '../models/vendor/store_model.dart';
// import 'wordpress/blognews_api.dart';

export 'empty_service_mixin.dart';

abstract class BaseServices {
  // BlogNewsApi blogApi;

  Future<List<Category>> getCategories({lang});

  Future<List<Product>> getProducts();

  Future<List<Product>> getProductsonDeal(
      {int? page,
        int? categoryId,
        orderBy,
        order,
        featured,
        onSale,
        lang});


  Future<List<Product>> fetchProductsLayout({required config, lang});

  Future<List<Product>> fetchProductsByCategory(
      {categoryId,
        tagId,
        page,
        minPrice,
        maxPrice,
        orderBy,
        lang,
        sort,
        order,
        featured,
        onSale,
        attribute,
        attributeTerm});

  Future<User?> loginFacebook({String? token});

  Future<User?> loginSMS({String? token});

  Future<User?> loginApple({String? email, String? fullName});

  Future<User?> loginGoogle({String? token});

  Future<List<Review>?> getReviews(productId);

  Future<List<ProductVariation>?> getProductVariations(Product product,
      String? lang);

  Future<List<ShippingMethod>> getShippingMethods(
      {CartModel? cartModel, String? token, String? checkoutId, ClickNCollectProvider? clickNCollectProvider});

  Future<List<PaymentMethod>> getPaymentMethods(
      {CartModel? cartModel, ShippingMethod? shippingMethod, String? token, required String lang});

  Future<Order?> createOrder(
      {CartModel? cartModel,
        UserModel? user,
        bool? paid,
        ClickNCollectProvider? clickNCollectProvider});

  Future<List<Order>> getMyOrders({
    UserModel? userModel,
    int? page
  });

  Future updateOrder(orderId, lang,{status, token});

  Future<List<Product>> searchProducts(
      {name, categoryId, tag, attribute, attributeId, page, lang, isBarcode});
  Future<User?> getUserInfo(cookie);

  Future<User?> createUser({
    String? firstName,
    String? lastName,
    String? username,
    String? countryCode,
    String? password,
    String? phoneNumber,
    String? otp,
    String? loyalty_card_number,
    bool isVendor = false,
  });

  Future<Map<String, dynamic>?> updateUserInfo(
      Map<String, dynamic> json, User? user);

  Future<User?> login({username, password,lang});

  Future<Product?> getProduct(id, {lang});

  Future<Coupons?> getCoupons();

  Future<AfterShip?> getAllTracking();

  Future<List<OrderNote>?> getOrderNote({UserModel? userModel, String? orderId});

  Future createReview({String? productId, Map<String, dynamic>? data});

  Future<Map<String, dynamic>?> getHomeCache(String lang);

  // Future<List<BlogNews>> fetchBlogLayout({config, lang});

  // Future<BlogNews> getPageById(int pageId);

  Future? getCategoryWithCache();

  Future<List<FilterAttribute>?>? getFilterAttributes();

  Future<List<SubAttribute>?>? getSubAttributes({int? id});

  Future<List<FilterTag>?>? getFilterTags();

  Future<String?>? getCheckoutUrl(Map<String, dynamic> params, String lang);

  Future<String?>? submitForgotPassword(
      {String? forgotPwLink, Map<String, dynamic>? data});

  Future? logout();

  checkoutWithCreditCard(String? vaultId, CartModel cartModel, Address address,
      PaymentSettingsModel paymentSettingsModel) {}

  getPaymentSettings() {}

  addCreditCard(PaymentSettingsModel paymentSettingsModel,
      CreditCardModel creditCardModel) {}

  Future<Map<String, dynamic>>? getCurrencyRate();

  Future? getCartInfo(String token);

  Future? syncCartToWebsite(CartModel cartModel, User user);

  Future<Map<String, dynamic>>? getCustomerInfo(String? id, String? cookie, String? lang);

  Future<Map<String, dynamic>>? getTaxes(CartModel cartModel);

  Future<Map<String, Tag>>? getTags({String? lang});

  Future getCountries();

  Future getStatesByCountryId(countryId);

  Future<Point>? getMyPoint(String? token);

  Future? updatePoints(String? token, Order? order);

  //For vendor
  Future<Store>? getStoreInfo(storeId);

  Future<bool>? pushNotification({receiverEmail, senderName, message});

  Future<List<Review>>? getReviewsStore({storeId});

  Future<List<Product>>? getProductsByStore({storeId, page});

  Future<List<Store>>? searchStores({String? keyword, int? page});

  Future<List<Store>>? getFeaturedStores();

  Future<List<Order>>? getVendorOrders({UserModel? userModel, int? page});

  Future<Product>? createProduct(String cookie, Map<String, dynamic> data);

  Future<List<Product>>? getOwnProducts(String cookie, {int? page});

  Future<dynamic>? uploadImage(dynamic data);

  ///----store LISTING----///
  Future<dynamic>? bookService({userId, value, message});

  Future<List<Product>>? getProductNearest(location);

  Future<List<ListingBooking>>? getBooking({userId, page, perPage});

  Future<Map<String, dynamic>>? checkBookingAvailability({data});

  /// BOOKING FEATURE
  Future<bool>? createBooking(dynamic bookingInfo);

  Future<List<dynamic>>? getListStaff(String idProduct);

  Future<List<String>>? getSlotBooking(
      String idProduct, String idStaff, String date);
  Future<void>? addAddress(Address address, User? user,String? lang,String? lati,String? lan);

  Future<void>? editAddress(Address address, User? user,String? lang,String? lat,String? lan);

  Future<void>? deleteAddress(Address address);

  Future<bool> deleteItemFromCart(List<String?> key, String? token, String? lang);

  Future<List<String>>? getProductAddtionalInfo(productId);
}
