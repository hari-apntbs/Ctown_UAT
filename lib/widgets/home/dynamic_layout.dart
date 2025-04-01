import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../common/constants/general.dart';
import '../../common/packages.dart' show StoryWidget;
import '../../common/tools.dart';
import '../../models/cart/cart_model.dart';
import '../../models/home_product_model.dart';
import '../../models/index.dart' show AppModel, UserModel;
import '../../models/product_model.dart';
import '../../screens/cart/address_selector_widget.dart';
import '../../screens/users/user_loyalty.dart';
import '../../services/index.dart';
import '../common/webview.dart';
import 'banner/banner_animate_items.dart';
import 'banner/banner_group_items.dart';
import 'banner/banner_slider_items.dart';
import 'clickandcollect_provider.dart';
import 'header/header_search.dart';
import 'header/header_text.dart';
import 'horizontal/horizontal_list_items.dart';
import 'horizontal/simple_list.dart';
import 'logo.dart';
import 'product_list_layout.dart';
import 'promotionbanner.dart';

class PromotionWidget extends StatelessWidget {
  final String? url;
  PromotionWidget({this.url});
  WebViewController? _controller;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: InAppWebView(
          appBarRequire: true,
          url: url,
          javaScript: 'document.getElementById("header").style.display = "none"; document.getElementsByClassName("nav-breadcrumbs")[0].style.display = "none"; document.getElementsByClassName("page-footer")[0].style.display = "none";document.querySelector("#mobilePhonePopup").style.display = "none";document.querySelector(".page-wrapper").style.display = "";localStorage.setItem("useBrowser", "granted");',

          // onPageFinished: (e) {
          //   printLog("web view finsished");
          //   Future.delayed(Duration(seconds: 4), () {
          //     // _controller.evaluateJavascript('alert(hello from flutter)');
          //     _controller.evaluateJavascript(
          //         'document.getElementById("header").style.display = "none"; document.getElementsByClassName("nav-breadcrumbs")[0].style.display = "none"; document.getElementsByClassName("page-footer")[0].style.display = "none";');
          //     // _controller.evaluateJavascript(
          //     //     '\$("#header").hide(); \$(".header")[0].hide();\$(".page-footer")[0].hide();');
          //     // _controller.evaluateJavascript(
          //     //     'Jquery("#header").hide(); Jquery(".header")[0].hide();Jquery(".page-footer")[0].hide();');
          //   });
          // },
          // 'https://flutter.dev',
        ),
      ),
    );
  }
}

class DynamicLayout extends StatefulWidget {
  final config;
  final setting;
  final album;
  final user;
  final Function? changeTabTo;
  DynamicLayout(
      this.config,
      this.setting,
      this.album,
      this.user,
      this.changeTabTo,
      );

  @override
  _DynamicLayoutState createState() => _DynamicLayoutState();
}

class _DynamicLayoutState extends State<DynamicLayout> {
  final ScrollController _scrollController1 = ScrollController();
  final ScrollController _scrollController = ScrollController();
  final ScrollController verticalScroll = ScrollController();
  // CarouselController buttonCarouselController = CarouselController();

  //  @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
  //     double minScrollExtent1 = _scrollController1.position.minScrollExtent;
  //     double maxScrollExtent1 = _scrollController1.position.maxScrollExtent;

  //     //
  //     animateToMaxMin(maxScrollExtent1, minScrollExtent1, maxScrollExtent1, 25,
  //         _scrollController1);

  //   });
  // }

  // void scrollcontroller(){
  //   _scrollController.animateTo(_scrollController. ,duration: Duration(seconds:1),curve: Curves.fastOutSlowIn);
  // }

  void onPin1Pressed(BuildContext context) {}

  void onChangePressed(BuildContext context) => Navigator.push(
      context, MaterialPageRoute(builder: (context) => JamaeytiWidget()));

  void onLoupePressed(BuildContext context) => Navigator.push(
      context, MaterialPageRoute(builder: (context) => JamaeytiWidget()));

  void onBarcodePressed(BuildContext context) => Navigator.push(
      context, MaterialPageRoute(builder: (context) => JamaeytiWidget()));

  void onBarcodeTwoPressed(BuildContext context) => Navigator.push(
      context, MaterialPageRoute(builder: (context) => JamaeytiWidget()));

  //      animateToMaxMin(double max, double min, double direction, int seconds,
  //     ScrollController scrollController) {
  //   scrollController
  //       .animateTo(direction,
  //           duration: Duration(seconds: seconds), curve: Curves.linear)
  //       .then((value) {
  //     direction = direction == max ? min : max;
  //     animateToMaxMin(max, min, direction, seconds, scrollController);
  //   });
  // }

  @override
  void dispose() {
    _scrollController1.dispose();
    _scrollController.dispose();
    verticalScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List? items = widget.config["brand_details"];
    final List? bloglist = widget.config["blog_details"];
    final List? circle_category_details =
    widget.config["circle_category_details"] ?? [];
    final screensize = MediaQuery.of(context).size.width * .9;
    var item = 1;
    var appModel = Provider.of<AppModel>(context);
    var isDarkTheme = appModel.darkTheme ?? false;

    String? url = widget.config["brand_image_base_url"];
    String? blogurl = widget.config["blog_image_base_url"];
    //bool loggedIn = Provider.of<UserModel>(context).loggedIn;
    //printLog(widget.album);

    switch (widget.config["layout"]) {
      case 'promotion_banner':
        return GestureDetector(
            onTap: () {
              printLog(widget.config["banner_url"]);
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => Promotionbanner()));
            },
            child: Container(
              // height: 150,
              // color: Colors.black,
              width: double.infinity,
              child: Image.network(widget.config["banner_image"]),
            ));
      case 'mobile_circle_category':
        List circle_category_details1 = [];
        List circle_category_details2 = [];
        if(circle_category_details!.length > 0) {
          int itemLength = circle_category_details.length ~/ 2;
          circle_category_details1 = circle_category_details.sublist(0, itemLength);
          circle_category_details2 = circle_category_details.sublist(itemLength);
        }
        return Container(
          height: 260,
          child: RawScrollbar(
            controller: _scrollController1,
            thumbVisibility: true,
            thumbColor: Colors.grey,
            radius: Radius.circular(5),
            mainAxisMargin: 100,
            child: ListView(
              controller: _scrollController1,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    circle_category_details1.length > 0 ?Expanded(
                      child: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          itemCount: circle_category_details1.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    HomeProductModel.showList(
                                        context: context,
                                        cateId: circle_category_details1[index]
                                        ['category_id'],
                                        cateName:
                                        Provider.of<AppModel>(context, listen: false)
                                            .langCode ==
                                            'en'
                                            ? circle_category_details1[index]['title_en']
                                            : circle_category_details1[index]
                                        ['title_ar']);
                                  },
                                  child: Container(
                                      margin: const EdgeInsets.only(right: 8.0),
                                      child: CircleAvatar(
                                          radius: 38,
                                          backgroundColor: Colors.grey[200],
                                          child: Container(
                                            padding: const EdgeInsets.all(5.0),
                                            height: 150,
                                            width: 150,
                                            child: ClipOval(
                                              child: ExtendedImage.network(
                                                Provider.of<AppModel>(context, listen: false)
                                                    .langCode ==
                                                    'en'
                                                    ? circle_category_details1[index]
                                                ["full_image_en"]
                                                    : circle_category_details1[index]
                                                ["full_image_ar"],
                                                cache: true,
                                                enableLoadState: false,
                                                scale: 9,
                                                width: 150,
                                                height: 150,
                                                cacheWidth: 150,
                                                cacheHeight: 150,
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          ))),
                                ),
                                const SizedBox(height: 5),
                                Container(
                                    width: 80,
                                    child: Text(
                                      Provider.of<AppModel>(context, listen: false)
                                          .langCode ==
                                          'en'
                                          ? circle_category_details1[index]['title_en']
                                          .toString()
                                          .toUpperCase()
                                          : circle_category_details1[index]['title_ar'],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Theme.of(context).colorScheme.secondary,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold),
                                    ))
                              ],
                            );
                          }),
                    ) :const SizedBox.shrink(),
                    circle_category_details2.length > 0 ?Expanded(
                        child: ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            itemCount: circle_category_details2.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      HomeProductModel.showList(
                                          context: context,
                                          cateId: circle_category_details2[index]
                                          ['category_id'],
                                          cateName:
                                          Provider.of<AppModel>(context, listen: false)
                                              .langCode ==
                                              'en'
                                              ? circle_category_details2[index]['title_en']
                                              : circle_category_details2[index]
                                          ['title_ar']);
                                    },
                                    child: Container(
                                        margin: const EdgeInsets.only(right: 8.0),
                                        child: CircleAvatar(
                                            radius: 38,
                                            backgroundColor: Colors.grey[200],
                                            child: Container(
                                              padding: const EdgeInsets.all(5.0),
                                              height: 150,
                                              width: 150,
                                              child: ClipOval(
                                                child: ExtendedImage.network(
                                                  Provider.of<AppModel>(context, listen: false)
                                                      .langCode ==
                                                      'en'
                                                      ? circle_category_details2[index]
                                                  ["full_image_en"]
                                                      : circle_category_details2[index]
                                                  ["full_image_ar"],
                                                  enableLoadState: false,
                                                  cache: true,
                                                  scale: 9,
                                                  width: 150,
                                                  height: 150,
                                                  cacheWidth: 150,
                                                  cacheHeight: 150,
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                            ))),
                                  ),
                                  SizedBox(height: 5),
                                  Container(
                                      width: 80,
                                      child: Text(
                                        Provider.of<AppModel>(context, listen: false)
                                            .langCode ==
                                            'en'
                                            ? circle_category_details2[index]['title_en']
                                            .toString()
                                            .toUpperCase()
                                            : circle_category_details2[index]['title_ar'],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Theme.of(context).colorScheme.secondary,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold),
                                      ))
                                ],
                              );
                            })
                    ) :SizedBox.shrink()
                  ],
                ),
              ],
            ),
          ),
        );

      case 'brand_slider':
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.only(left: 10),
              child: Text(
                Provider.of<AppModel>(context, listen: false).langCode == 'en'
                    ? "Shop By Brands"
                    : "تسوق حسب الماركات",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            SizedBox(height: 10),
            Stack(children: [
              Container(
                height: 50,
                width: screensize,
                decoration: BoxDecoration(
                  // border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: EdgeInsets.only(right: 20, left: 20),
                child: Container(
                  height: 50,
                  child: ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      // physics: const ClampingScrollPhysics(),
                      itemCount: items!.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            // Navigator.of(context).push(MaterialPageRoute(
                            //     builder: (context) => Brand(
                            //         config: items[index]["category_id"])));
                            // printLog(items[index]["category_id"]);
                            var category = {
                              "category": items[index]["category_id"]
                            };
                            ProductModel.showList(
                                context: context, config: category, products: null);
                          },
                          child: Card(
                            elevation: 2,
                            child: Container(
                              margin: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: CachedNetworkImage(
                                  imageUrl: url! + items[index]['image'],
                                  placeholder: (context, url) =>
                                      CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                ),

                                // Image.network(
                                //   url + items[index]['image'],
                                //   width: 78,
                                // ),
                              ),
                            ),
                          ),
                        );
                      }),
                ),
              ),
              Positioned(
                  left: 2,
                  child: Container(
                      margin: EdgeInsets.only(top: 12),
                      child: InkWell(
                        onTap: () {
                          if (item > 0) {
                            printLog("clicked");
                            item -= 1;
                            printLog(item);
                            item >= 0
                                ? _scrollController
                                .jumpTo(item * screensize.toDouble())
                                : printLog("error");
                          }
                          ;
                        },
                        child: Provider.of<AppModel>(context, listen: false)
                            .langCode ==
                            'en'
                            ? Transform.rotate(
                            angle: 360 * pi / 180,
                            child: Icon(Icons.arrow_back_ios))
                            : Transform.rotate(
                            angle: 360 * pi / 360,
                            child: Icon(Icons.arrow_back_ios)),
                      ))),
              Positioned(
                  right: 2,
                  child: InkWell(
                      onTap: () {
                        printLog("clicked");
                        if (item < items.length / 3) {
                          item += 1;
                          printLog(item);
                          item >= 0
                              ? _scrollController
                              .jumpTo(item * screensize.toDouble())
                              : printLog("error");

                          // animateTo( _scrollController.position.minScrollExtent.remainder(10), duration: const Duration(seconds:1),curve: Curves.fastOutSlowIn);
                        }
                        ;
                      },
                      child: Container(
                        margin: EdgeInsets.only(top: 12),
                        child: Provider.of<AppModel>(context, listen: false)
                            .langCode ==
                            'en'
                            ? Transform.rotate(
                            angle: 360 * pi / 360,
                            child: Icon(Icons.arrow_back_ios))
                            : Transform.rotate(
                            angle: 360 * pi / 180,
                            child: Icon(Icons.arrow_back_ios)),
                      ))),
            ]),
            SizedBox(height: 10),
          ],
        );

      case 'logo':
        return Logo(
          config: widget.config,
          key: widget.config['key'] != null ? Key(widget.config['key']) : null,
        );

      case 'header_text':
        if (kIsWeb) return Container();
        return HeaderText(
          config: widget.config,
          key: widget.config['key'] != null ? Key(widget.config['key']) : null,
        );

      case 'header_search':
        if (kIsWeb) return Container();
        return HeaderSearch(
          config: widget.config,
          key: widget.config['key'] != null ? Key(widget.config['key']) : null,
        );
      case 'featuredVendors':
        return Services().widget?.renderFeatureVendor(widget.config) ?? SizedBox.shrink();

    // case 'category':
    //  // var widget;
    //   return Container();

      case 'category':
        if (Provider.of<UserModel>(context, listen: false).loggedIn) {
          if (Provider.of<CartModel>(context, listen: false).address != null) {
            if (Provider.of<CartModel>(context, listen: false).address?.street !=
                "") {
              printLog("Setting to home delivery by default");
              Provider.of<ClickNCollectProvider>(context, listen: false)
                  .setDeliveryTypeAndStoreId("", "homedelivery");
            }
          }
        }
        return const AddressSelectorWidget(true);

      case 'categorys':
        return Container(
          height: 100,
          color: Colors.yellow,
        );

      case "bannerAnimated":
        if (kIsWeb) return Container();
        return BannerAnimated(
          config: widget.config,
          key: widget.config['key'] != null ? Key(widget.config['key']) : null,
        );
    //

    //
      case "bannerImage":
        if (widget.config['isSlider'] == true) {
          return BannerSliderItems(
              config: widget.config,
              key: widget.config['key'] != null
                  ? Key(widget.config['key'])
                  : null);
        }
        return BannerGroupItems(
          config: widget.config,
          key: widget.config['key'] != null ? Key(widget.config['key']) : null,
        );

      case "largeCardHorizontalListItems":
        return LargeCardHorizontalListItems(
          config: widget.config,
          key: widget.config['key'] != null ? Key(widget.config['key']) : null,
        );

      case "simpleVerticalListItems":
        return SimpleVerticalProductList(
          config: widget.config,
          key: widget.config['key'] != null ? Key(widget.config['key']) : null,
        );

      case "story":
        return StoryWidget(
          config: widget.config,
          onTapStoryText: (cfg) {
            Utils.onTapNavigateOptions(context: context, config: cfg);
          },
        );
      case "deals":
      case "fourColumn":
      case "threeColumn":
      case "twoColumn":
      case "staggered":
      case "recentView":
      case "saleOff":
        return ProductListLayout(
          config: widget.config,
          key: widget.config['key'] != null ? Key(widget.config['key']) : null,
          changeTabTo: widget.changeTabTo,
        );

      default:
        return const SizedBox();
    }
  }
}
