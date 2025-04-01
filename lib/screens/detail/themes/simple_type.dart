import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../common/index.dart';
import '../../../models/index.dart' show AppModel, Product, ProductModel, ProductVariation;
import '../../../screens/detail/product_grouped.dart';
import '../../../services/index.dart';
import '../../../widgets/common/image_galery.dart';
import '../../../widgets/product/heart_button.dart';
import '../image_feature.dart';
import '../listing_booking.dart';
import '../product_description.dart';
import '../product_title.dart';
import '../product_variant.dart';
import '../variant_image_feature.dart';
import '../video_feature.dart';

class SimpleLayout extends StatefulWidget {
  final Product? product;
  List<ProductVariation>? productVariationList;

  SimpleLayout({this.product, this.productVariationList});
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  _SimpleLayoutState createState() => _SimpleLayoutState(product: product);
}

class _SimpleLayoutState extends State<SimpleLayout>
    with SingleTickerProviderStateMixin {
  final _scrollController = ScrollController();
  final services = Services();
  Product? product;

  String? selectedUrl;
  bool isVideoSelected = false;

  _SimpleLayoutState({this.product});

  Map<String, String> mapAttribute = HashMap();
  AnimationController? _hideController;

  var top = 0.0;

  @override
  void initState() {
    super.initState();

    //if (kAdConfig['enable']) Ads().adInit();
    _hideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
      value: 1.0,
    );
  }

  @override
  void dispose() {
    // if (kAdConfig['enable']) {
    //   Ads.hideBanner();
    //   Ads.hideInterstitialAd();
    // }
    _hideController?.dispose();
    super.dispose();
  }

  /// Render product default: booking, group, variant, simple, booking
  renderProductInfo() {
    var body;

    /// enable the woocommerce booking
    // if (product.type == 'appointment') {
    //   ProductBooking(product: product);
    // }

    /// enable the listing booking
    if (product!.type == 'booking') {
      body = ListingBooking(product);
    } else if (product!.type != 'grouped') {
      body = ProductVariant(product, false);
    } else {
      body = GroupedProduct(product);
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: body,
      ),
    );
  }

  getSavedStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var result = await prefs.getString('savedStore')!;

    return jsonDecode(result);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double widthHeight = size.height;
    //special advertisement type
    // bool isGoogleBannerShown =
    //     kAdConfig['enable'] && kAdConfig['type'] == kAdType.googleBanner;
    // bool isFBNativeAdShown =
    //     kAdConfig['enable'] && kAdConfig['type'] == kAdType.facebookNative;

    return ChangeNotifierProvider(
      create: (_) => ProductModel(),
      child: Stack(
        children: <Widget>[
          Scaffold(
            // appBar: AppBar(
            //   title: Text(
            //     "Product Details",
            //     style: const TextStyle(
            //       fontSize: 16.0,
            //       color: Colors.white,
            //     ),
            //   ),
            //   leading: GestureDetector(
            //     child: const Icon(
            //       Icons.arrow_back_ios,
            //       color: Colors.white,
            //     ),
            //     onTap: () => Navigator.pop(context),
            //   ),
            // ),
            // appBar: AppBar(
            //   title: AppLocal(),
            //   leadingWidth: 0,
            //   // leading: Icon(Icons.add),
            //   leading: Container(),
            // ),
            // floatingActionButton: kConfigChat['EnableSmartChat']
            //     ? SmartChat(
            //         margin: EdgeInsets.only(
            //           bottom: kAdConfig['enable'] ? 130 : 45,
            //           right: Provider.of<AppModel>(context, listen: false)
            //                       .langCode ==
            //                   'ar'
            //               ? 30
            //               : 0.0,
            //         ),
            //       )
            //     : Container(),
            body: CustomScrollView(
              controller: _scrollController,
              slivers: <Widget>[
                SliverAppBar(
                  backgroundColor: Provider.of<AppModel>(context).darkTheme ? Colors.black12 : Colors.white,
                  elevation: 1.0,
                  expandedHeight:
                      kIsWeb ? 0 : widthHeight * (kProductDetail['height'] as num),
                  pinned: true,
                  floating: false,
                  leading: Padding(
                    padding: const EdgeInsets.all(8),
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.3),
                      child: IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Theme.of(context).primaryColor,
                        ),
                        onPressed: () {
                          Provider.of<ProductModel>(context, listen: false)
                              .changeProductVariation(null);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                  actions: <Widget>[
                    HeartButton(
                      product: product,
                      size: 18.0,
                      color: kGrey400,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.3),
                        child: IconButton(
                            icon: Icon(
                              Icons.share,
                              color: Theme.of(context).primaryColor,
                              // color: Color(0xfff7e813),
                            ),
                            // icon: const Icon(Icons.share, size: 19),
                            // color: Colors.orange,
                            // onPressed: () => ProductDetailScreen.showMenu(context, widget.product),
                            onPressed: () async {
                              var store1 = await getSavedStore();
                              var storeCode =
                                  Provider.of<AppModel>(context, listen: false)
                                              .langCode ==
                                          'en'
                                      ? store1["store_en"]["code"]
                                      : store1["store_ar"]["code"];
                              //Navigator.of(context).pop();
                              String uri = await DynamicLinkService().createDynamicLink(storeCode, product);
                              Share.share( uri,
                                // firebaseDynamicLinkConfig["link"].toString() +
                                //     "index.php/$storeCode/catalog/product/view/id/${product!.id}",
                                // https://up.ctown.jo/index.php/qatar_barwa_branch_en/catalog/product/view/id/23344/
                                sharePositionOrigin: Rect.fromLTWH(
                                    0, 0, size.width, size.height / 2),
                              );
                              printLog("ffff");
                              printLog(product!.permalink);
                              printLog("ffff");
                            }),
                      ),
                    ),
                  ],
                  flexibleSpace: kIsWeb
                      ? Container()
                      : _renderSelectedMedia(context, product, size),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    <Widget>[
                      const SizedBox(
                        height: 2,
                      ),
                      // ProductGallery(
                      //   product: product,
                      //   onSelect: (String url, bool isVideo) {
                      //     if (mounted) {
                      //       setState(() {
                      //         selectedUrl = url;
                      //         isVideoSelected = isVideo;
                      //       });
                      //     }
                      //   },
                      // ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 15.0,
                          right: 15.0,
                          top: 0.0,
                          bottom: 4.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            product!.type == 'simple'
                                ? ProductTitle(
                                    product, '', '', '', '', [], true)
                                : Container(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                renderProductInfo(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Services().widget?.renderVendorInfo(product) ?? const SizedBox.shrink(),
                        ProductDescription(product),
                        // //
                        // RelatedProduct(product),
                        // isFBNativeAdShown
                        //     ? Ads().facebookNative()
                        //     : Container(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Container(
          //   child: isGoogleBannerShown
          //       ? Positioned(
          //     child: ExpandingBottomSheet(
          //         hideController: _hideController,
          //         onInitController: (controller) {}),
          //     bottom: 80,
          //     right: 0,
          //   )
          //       : Align(
          //       child: ExpandingBottomSheet(
          //           hideController: _hideController,
          //           onInitController: (controller) {}),
          //       alignment: Alignment.bottomRight),
          // ),
        ],
      ),
    );
  }

  _renderSelectedMedia(BuildContext context, Product? product, Size size) {
    /// Render selected video
    if (selectedUrl != null && isVideoSelected) {
      return FeatureVideoPlayer(
        url: selectedUrl!.replaceAll("http://", "https://"),
        autoPlay: true,
      );
    }

    /// Render selected image
    if (selectedUrl != null && !isVideoSelected) {
      return GestureDetector(
        onTap: () {
          showDialog<void>(
              context: context,
              builder: (BuildContext context) {
                final int index = product!.images!.indexOf(selectedUrl);
                return ImageGalery(
                  images: product.images,
                  index: index == -1 ? 0 : index,
                );
              });
        },
        child: Tools.image(
          url: selectedUrl,
          fit: BoxFit.contain,
          width: size.width,
          size: kSize.large,
          hidePlaceHolder: true,
        ),
      );
    }

    /// Render default feature image
    return product!.type == 'variable'
        ? VariantImageFeature(product)
        : ImageFeature(product);
  }
}
