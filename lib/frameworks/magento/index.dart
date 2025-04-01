import 'dart:async';

import 'package:ctown/widgets/home/clickandcollect_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:localstorage/localstorage.dart';

import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/app_model.dart';
import '../../models/entities/states.dart';
import '../../models/index.dart'
    show
        CartModel,
        Country,
        CountryState,
        Coupon,
        Coupons,
        Discount,
        ListCountry,
        Order,
        OrderModel,
        PaymentMethod,
        Product,
        ProductVariation,
        ShippingMethodModel,
        User,
        UserModel;
import '../../screens/index.dart' show MyCart;
import '../../services/index.dart';
import '../framework_mixin.dart';
import '../frameworks.dart';
import '../product_variant_mixin.dart';
import 'magento_payment.dart';
import 'magento_variant_mixin.dart';
import 'services/magento.dart';

class MagentoWidget
    with FrameworkMixin, ProductVariantMixin, MagentoVariantMixin
    implements BaseFrameworks {
  static final MagentoWidget _instance = MagentoWidget._internal();

  factory MagentoWidget() => _instance;

  MagentoWidget._internal();

  @override
  bool get enableProductReview => true;

  Future<void> applyCoupon(context,
      {Coupons? coupons, String? code, Function? success, Function? error}) async {
    try {
      final cartModel = Provider.of<CartModel>(context, listen: false);
      final userModel = Provider.of<UserModel>(context, listen: false);
      final lang = Provider.of<AppModel>(context, listen: false).langCode ?? "";
      //await MagentoApi().addItemsToCart(cartModel, userModel.user != null ? userModel.user.cookie : null);
      final discountAmount = await MagentoApi().applyCoupon(userModel.user?.cookie, code, lang);
      cartModel.discountAmount = discountAmount;
      //fix for coupon giving type coupon is not a subtype of discount
      Coupon coupon = Coupon.fromJson({
        "amount": discountAmount,
        "code": code,
        "discount_type": "fixed_cart"
      });
      Discount discount = Discount(coupon: coupon, discount: discountAmount);
      success!(discount);
    } catch (err) {
      error!(err.toString());
    }
  }

  Future<void> doCheckout(context,
      {Function? success, Function? error, Function? loading}) async {
    final cartModel = Provider.of<CartModel>(context, listen: false);
    final userModel = Provider.of<UserModel>(context, listen: false);
    final lang = Provider.of<AppModel>(context, listen: false).langCode ?? "";
    try {
      //await MagentoApi().addItemsToCart(cartModel, userModel.user != null ? userModel.user.cookie : null);
      if (cartModel.couponObj != null) {
        final discountAmount = await MagentoApi().applyCoupon(
            userModel.user?.cookie,
            cartModel.couponObj!.code, lang);
        cartModel.discountAmount = discountAmount;
      }
      success!();
    } catch (e, trace) {
      error!(e.toString());
      printLog(trace.toString());
    }
  }

  Future<void> createOrder(context,
      {Function? onLoading,
      Function? success,
      Function? error,
      paid = false,
      cod = false, String? lang}) async {
    final LocalStorage storage = LocalStorage('data_order');
    var listOrder = [];
    bool isLoggedIn = Provider.of<UserModel>(context, listen: false).loggedIn;
    final cartModel = Provider.of<CartModel>(context, listen: false);
    final userModel = Provider.of<UserModel>(context, listen: false);

    try {
      onLoading!(true);

      final order = await Services().createOrder(
          cartModel: cartModel,
          user: userModel,
          paid: paid,
          clickNCollectProvider:
              Provider.of<ClickNCollectProvider>(context, listen: false), lang: lang);

      if (!isLoggedIn) {
        var items = await storage.getItem('orders');
        if (items != null) {
          listOrder = items;
        }
        listOrder.add(order?.toOrderJson(cartModel, null));
        await storage.setItem('orders', listOrder);
      }
      // if (cartModel.paymentMethod.id == 'ngeniusonline' && order.id != null) {
      //   await MagentoApi().submitPaymentSuccess(order.id);
      // }
      if (kMagentoPayments.contains(cartModel.paymentMethod!.id)) {
        onLoading(false);
        printLog("cod success");
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MagentoPayment(
                    onFinish: (order) => success!(order),
                    order: order,
                  )),
        );
      } else {
        success!(order);
      }
    } catch (e, trace) {
      error!(e.toString());
      printLog(trace.toString());
      final snackBar = SnackBar(
        content: Text(e.toString()),
        duration: const Duration(seconds: 10),
        action: SnackBarAction(
          label: S.of(context).close,
          onPressed: () {},
        ),
      );
      // ignore: deprecated_member_use
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void placeOrder(
    context, {
    CartModel? cartModel,
    PaymentMethod? paymentMethod,
    Function? onLoading,
    Function? success,
    Function? error,
        String? lang
  }) {
    Provider.of<CartModel>(context, listen: false)
        .setPaymentMethod(paymentMethod);
    printLog(paymentMethod!.id);

    createOrder(context,
        cod: true, onLoading: onLoading, success: success, error: error, lang: lang);
  }

  Map<String, dynamic>? getPaymentUrl(context) {
    return null;
  }

  @override
  Widget renderCartPageView({context, isModal, isBuyNow, pageController}) {
    return PageView(
      controller: pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: <Widget>[
        MyCart(
          controller: pageController,
          isBuyNow: isBuyNow,
          isModal: isModal,
        ),
        //Checkout(controller: pageController, isModal: isModal),
      ],
    );
  }

  @override
  void updateUserInfo(
      {User? loggedInUser,
      context,
      onError,
      onSuccess,
      required currentPassword,
      userDisplayName,
      userEmail,
      userNiceName,
      userPhonenumber,
      userUrl,
      userPassword}) {
    if (currentPassword.isEmpty && !loggedInUser!.isSocial!) {
      onError!('Please enter current password');
      return;
    }

    var params = {
      "user_id": loggedInUser!.id,
      "display_name": userDisplayName,
      "user_email": userEmail,
      "user_nicename": userNiceName,
      "user_url": userUrl,
    };
    if (userEmail == loggedInUser.email && !loggedInUser.isSocial!) {
      params["user_email"] = "";
    }
    if (!loggedInUser.isSocial! && userPassword!.isNotEmpty) {
      params["user_pass"] = userPassword;
    }
    if (!loggedInUser.isSocial! && currentPassword.isNotEmpty) {
      params["current_pass"] = currentPassword;
    }
    Services().updateUserInfo(params, loggedInUser).then((value) {
      var param = value!['data'] ?? value;
      param['password'] = userPassword;
      if (param["user_email"] == "") {
        param["user_email"] = loggedInUser.email;
      }
      onSuccess!(param);
    }).catchError((e) {
      onError!(e.toString());
    });
  }

  @override
  Widget renderCurrentPassInputforEditProfile(
      {required BuildContext context, TextEditingController? currentPasswordController}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(S.of(context).currentPassword,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.secondary,
            )),
        const SizedBox(
          height: 5,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                  color: Theme.of(context).primaryColorLight, width: 1.5)),
          child: TextField(
            obscureText: true,
            decoration: const InputDecoration(border: InputBorder.none),
            controller: currentPasswordController,
          ),
        ),
        const SizedBox(
          height: 15,
        ),
      ],
    );
  }

  @override
  Future<void> onLoadedAppConfig(String? lang, Function callback) async {
    await MagentoApi().getAllAttributes(lang ?? "en");
    final countries = await MagentoApi().getCountries();
    final LocalStorage storage = LocalStorage("store");
    try {
      // save the user Info as local storage
      final ready = await storage.ready;
      if (ready) {
        await storage.setItem(kLocalKey["countries"]!, countries);
      }
    } catch (err) {
      printLog(err);
    }
    return;
  }

  @override
  Widget renderVariantCartItem(variation, Map<String, dynamic>? options) {
    return Container();
  }

  @override
  void loadShippingMethods(context, CartModel cartModel, bool beforehand) {
//    if (!beforehand) return;
    final cartModel = Provider.of<CartModel>(context, listen: false);
    Future.delayed(Duration.zero, () {
      final token = Provider.of<UserModel>(context, listen: false).user != null
          ? Provider.of<UserModel>(context, listen: false).user!.cookie
          : null;
      Provider.of<ShippingMethodModel>(context, listen: false)
          .getShippingMethods(
              cartModel: cartModel,
              token: token,
              checkoutId: cartModel.getCheckoutId(),
              clickNCollectProvider:
                  Provider.of<ClickNCollectProvider>(context, listen: false));
    });
  }

  @override
  Future<Order> cancelOrder(BuildContext context, Order? order) async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    final langCode = Provider.of<AppModel>(context, listen: false).langCode ?? "en";
    if (order?.status == 'cancelled' || order?.status == 'canceled') return order!;
    await Services().updateOrder(order?.id, langCode,
        status: 'cancelled', token: userModel.user!.cookie);
    order?.status = "canceled";
    await Provider.of<OrderModel>(context, listen: false)
        .getMyOrder(userModel: userModel, lang: Provider.of<AppModel>(context, listen: false).langCode ?? "en");
    return order!;
  }

  Widget renderButtons(Order? order, cancelOrder, createRefund) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Center(
            child: GestureDetector(
              onTap: cancelOrder,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: (order?.status == 'cancelled' ||
                            order?.status == 'canceled')
                        ? Colors.blueGrey
                        : Colors.red),
                child: Text(
                  'Cancel'.toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  String? getPriceItemInCart(Product product, ProductVariation? variation,
      Map<String, dynamic> currencyRate, String? currency) {
    return variation != null && variation.id != null
        ? Tools.getVariantPriceProductValue(variation, currencyRate, currency,
            onSale: variation.onSale)
        : Tools.getPriceProduct(product, currencyRate, currency, onSale: product.onSale);
  }

  @override
  Future<List<Country>?> loadCountries(BuildContext context) async {
    final LocalStorage storage = LocalStorage("store");
    List<Country>? countries = [];
    try {
      // save the user Info as local storage
      final ready = await storage.ready;
      if (ready) {
        final items = await storage.getItem(kLocalKey["countries"]!);
        countries = ListCountry.fromMagentoJson(items).list;
      }
    } catch (err) {
      printLog(err);
    }
    return countries;
  }

  @override
  Future<List<CountryState>> loadStates(Country country) async {
    return country.states ?? [];
  }

  Future<List<Data>> loadStatenCities() async {
    //return country.states ?? [];
    try {
      List<Data> states = await MagentoApi().getStatenCities();
      return states;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> forgotPasswordEmail(
      BuildContext context, String username) async {
    try {
      bool isSuccess = await MagentoApi().forgotPasswordEmail(username);
      if (isSuccess == true) {
        Tools.showSnackBar(
            ScaffoldMessenger.of(context), 'Success Please Check Your Email');
        Future.delayed(
            const Duration(seconds: 2), () => Navigator.of(context).pop());
      } else {
        Tools.showSnackBar(ScaffoldMessenger.of(context), 'Please Enter Correct Email');
      }
      return;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> forgotPasswordMobile(BuildContext context, String phone,
      String? countryCode, String? storeid) async {
    try {
      final result =
          await MagentoApi().forgotPasswordMobile(phone, countryCode, storeid);
      if (result.isNotEmpty) {
        // Tools.showSnackBar(Scaffold.of(context), 'OTP sent to your mobile');
        // await Future.delayed(const Duration(seconds: 2), () => Navigator.of(context).pop());
      } else {
        Tools.showSnackBar(
            ScaffoldMessenger.of(context), 'Please Enter Correct Phone Number');
      }
      return result;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> resetPasswordMobile(
      BuildContext context, String? customerId, String password) async {
    try {
      bool isSuccess =
          await MagentoApi().resetPasswordMobile(customerId, password);
      if (isSuccess == true) {
        Tools.showSnackBar(
            ScaffoldMessenger.of(context), 'Password updated successfully');
        await Future.delayed(
            const Duration(seconds: 2), () => Navigator.of(context).pop());
      } else {
        Tools.showSnackBar(ScaffoldMessenger.of(context),
            'Could not update password. Please try again in sometime or contact support');
      }
      return;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> verifyOTP(
      BuildContext context, String? customerId, String otp) async {
    try {
      bool isSuccess = await MagentoApi().verifyOTP(customerId, otp);
      if (isSuccess == true) {
        // Tools.showSnackBar(
        //     Scaffold.of(context), 'Success Please Check Your Email');
        // Future.delayed(
        //     const Duration(seconds: 2), () => Navigator.of(context).pop());
      } else {
        Tools.showSnackBar(
            ScaffoldMessenger.of(context), 'Incorrect OTP. Retry with correct OTP');
      }
      return;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Product> getProductDetail(context, Product? product) async {
    try {
      product?.inStock = await MagentoApi().getStockStatus(product.sku);
      return product!;
    } catch (e) {
      rethrow;
    }
  }

  @override
  void OnFinishOrder(
      BuildContext context, Function onSuccess, Order order) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MagentoPayment(
                onFinish: (order) {
                  onSuccess(order);
                },
                order: order,
              )),
    );
  }


  @override
  Future<void> syncCartFromWebsite(
      String? token, CartModel cartModel, BuildContext context, String lang) async {
    try {
      cartModel.clearCart();
      var response = await Services().getCartInfo(token!);

      // Clear cart if response is empty or null
      if (response == null) {
        cartModel.clearCart();
        return;
      }

      // Extract items from response and clear existing cart details
      List? items = response["items"];
      cartModel.cartId = response["cartId"];

      // Proceed only if there are items in the response
      if (items == null || items.isEmpty) return;

      // Collect SKUs from the items and join them into a comma-separated string
      List<dynamic> skuList = items.map((item) => item['sku']).toList();
      String skuString = skuList.join(',');

      // Fetch product details and sort by quantity
      var allProducts = await MagentoApi().getListOfProductsForCartSync(skuString, lang);
      // allProducts.sort((a, b) => a.qty!.compareTo(b.qty!));

      // Map SKU to quantity for quick lookups
      Map<String, int> itemQuantities = {
        for (var item in items) item['sku']: item['qty']
      };

      if(allProducts.isNotEmpty) {
        for(var item in items) {
          int quantity = itemQuantities[item["sku"]] ?? 0;
          var matchedItem = allProducts.firstWhere((element) => element.sku == item["sku"]);
          cartModel.addProductToCart(
            context: context,
            product: matchedItem,
            quantity: quantity,
            variation: item["variation"] != null
                ? ProductVariation.fromJson(item["variation"])
                : null,
          );
        }
      }
      // Add each product to the cart with its corresponding quantity and variation if available
      // for (var product in allProducts) {
      //   int quantity = itemQuantities[product.sku] ?? 0;
      //   var matchedItem = items.firstWhere((item) => item['sku'] == product.sku, orElse: () => null);
      //   cartModel.addProductToCart(
      //     context: context,
      //     product: product,
      //     quantity: quantity,
      //     variation: matchedItem?['variation'] != null
      //         ? ProductVariation.fromJson(matchedItem['variation'])
      //         : null,
      //   );
      // }

      printLog("My items in cart: ${itemQuantities.entries.map((e) => {"sku": e.key, "qty": e.value})}");
    } catch (e) {
      printLog(e.toString());
      rethrow;
    }
  }


  @override
  void addToCart(BuildContext context, Product product, int quantity,
      ProductVariation productVariation, Map<String, String> mapAttribute,
      [bool buyNow = false, bool inStock = false]) {
    // TODO: implement addToCart
  }
}
