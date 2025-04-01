import 'package:country_pickers/country_pickers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common/config.dart';
import '../common/constants.dart';
import '../common/tools.dart';
import '../generated/l10n.dart';
import '../models/index.dart'
    show
    CartModel,
    OrderNote,
    AfterShip,
    UserModel,
    Order,
    Product,
    TaxModel,
    AppModel;
import '../screens/index.dart'
    show
    FullSizeLayout,
    HalfSizeLayout,
    ShippingMethods,
    SimpleLayout,
    SearchScreen;
import '../services/index.dart';
import '../widgets/common/webview.dart';
import '../widgets/orders/tracking.dart';
import '../widgets/product/product_card_view.dart';

mixin FrameworkMixin {
  /// Support Affiliate product
  void openWebView(BuildContext context, Product product) {
    if (product.affiliateUrl == null || product.affiliateUrl!.isEmpty) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back_ios),
            ),
          ),
          body: const Center(
            child: Text("Not found"),
          ),
        );
      }));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InAppWebView(
          url: product.affiliateUrl,
          title: product.name,
          appBarRequire: true,
        ),
      ),
    );
  }

  Future<Product> getProductDetail(
      BuildContext context, Product product) async =>
      product;

  Widget renderCurrentPassInputforEditProfile(
      {required BuildContext context,
        TextEditingController? currentPasswordController}) =>
      Container();

  Future<AfterShip?> getAllTracking() async => null;

  Future<List<OrderNote>?> getOrderNote(
      {UserModel? userModel, dynamic orderId}) async =>
      null;

  Future createReview({String? productId, Map<String, dynamic>? data}) async {}

  Future<Null>? getHomeCache(String lang) => null;

  Future<void>? onLoadedAppConfig(String lang, Function callback) => null;

  Future<void> syncCartFromWebsite(
      String token, CartModel cartModel, BuildContext contex, String lang) async =>
      null;

  Future<void> syncCartToWebsite(CartModel cartModel) async => null;

  Widget renderTaxes(TaxModel taxModel, BuildContext context) => Container();

  void OnFinishOrder(BuildContext context, Function onSuccess, Order order) {
    onSuccess();
  }

  Widget renderVendorInfo(Product? product) => Container();

  Widget renderVendorOrder(BuildContext context) => Container();

  Widget renderFeatureVendor(config) => Container();

  Widget renderShippingMethods(BuildContext context,
      {Function? onBack, Function? onNext}) {
    return ShippingMethods(onBack: onBack, onNext: onNext);
  }

  Widget renderVendorCategoriesScreen(data) => Container();

  Widget renderMapScreen() => Container();

  Future<void>? resetPassword(BuildContext context, String username) => null;

  Product updateProductObject(Product product, Map json) => product;

  Future<Order?> cancelOrder(BuildContext context, Order order) async => null;

  Widget renderButtons(Order order, cancelOrder, createRefund) => Container();

  Widget renderShippingMethodInfo(BuildContext context) {
    final currencyRate = Provider.of<AppModel>(context, listen: false).currencyRate;
    final model = Provider.of<CartModel>(context);

    return kPaymentConfig['EnableShipping'] as bool
        ? Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Services().widget?.renderShippingPaymentTitle(
                context,
                "${model.shippingMethod!.title == 'Shipping charge' ? Provider.of<AppModel>(context, listen: false).langCode == 'en' ? "Delivery Fee" : 'رسوم التوصيل' : model.shippingMethod!.title}")
                ?? const SizedBox.shrink(),
          ),
          Text(
            Tools.getCurrencyFormatted(
                model.getShippingCost(), currencyRate,
                currency: model.currency)!,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontSize: 14,
              color: Theme.of(context).colorScheme.secondary,
            ),
          )
        ],
      ),
    )
        : const SizedBox.shrink();
  }

  Widget renderShippingPaymentTitle(BuildContext context, String? title) {
    return Text(title!,
        style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.secondary));
  }

  Widget renderRewardInfo(BuildContext context) {
    final currencyRate =
        Provider.of<AppModel>(context, listen: false).currencyRate;
    final currency = Provider.of<AppModel>(context, listen: false).currency;
    final rewardTotal =
        Provider.of<CartModel>(context, listen: false).rewardTotal;

    if (rewardTotal > 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              S.of(context).cartDiscount,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            Text(
              Tools.getCurrencyFormatted(rewardTotal, currencyRate,
                  currency: currency)!,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontSize: 14,
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.w600,
              ),
            )
          ],
        ),
      );
    }
    return Container();
  }

  Widget renderNewListing(context) => Container();
  Widget renderBookingHistory(context) => Container();

  Widget renderDetailScreen(context, product, layoutType, {variations}) {
    switch (layoutType) {
      case 'halfSizeImageType':
        return HalfSizeLayout(product: product);
      case 'fullSizeImageType':
        return FullSizeLayout(product: product);
      default:
        return SimpleLayout(product: product, productVariationList: variations,);
    }
  }

  Widget renderSearchScreen(context, {showChat}) {
    return SearchScreen(
      key: const Key("search"),
      showChat: showChat,
    );
  }

  Future<String> getCountryName(context, countryCode) async {
    return CountryPickerUtils.getCountryByIsoCode(countryCode).name;
  }

  String? getAdminVendorUrl(String? cookie) {
    return null;
  }

  /// For booking feature
  Future<Map<String, dynamic>>? getCurrencyRate() => null;

  Future<bool>? createBooking(dynamic bookingInfo) => null;

  Future<List<dynamic>>? getListStaff(String idProduct) => null;

  Future<List<String>>? getSlotBooking(
      String idProduct, String idStaff, String date) =>
      null;

  Widget renderOrderTimelineTracking(BuildContext context, Order? order) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.topLeft,
          child: Text(
            S.of(context).status,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 15),
        Align(
          child: TimelineTracking(
            axisTimeLine: kIsWeb ? Axis.horizontal : Axis.vertical,
            orderId: order?.id,
            // status: order.status,
            // createdAt: order.createdAt,
            // dateModified: order.dateModified,
            // description: order.customerNote,
          ),
          alignment: Alignment.center,
        ),
      ],
    );
  }

  Widget renderProductCardView({
    Product? item,
    double? width,
    double? maxWidth,
    double? height,
    bool showCart = false,
    bool showHeart = false,
    bool showProgressBar = false,
    double? marginRight,
    double? ratioProductImage,
    bool? fromHome
  }) {
    return ProductCard(
      item: item,
      width: width,
      maxWidth: maxWidth,
      height: height,
      showCart: showCart,
      showHeart: showHeart,
      showProgressBar: showProgressBar,
      marginRight: marginRight,
      ratioProductImage: 1.2,
      fromHome: fromHome,
    );
  }
}
