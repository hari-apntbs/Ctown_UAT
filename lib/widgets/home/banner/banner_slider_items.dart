import 'dart:async';
import 'dart:convert' as convert;
import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../common/constants.dart';
import '../../../common/tools.dart';
import '../../../generated/l10n.dart';
import '../../../models/app_model.dart';
import '../../../models/category_model.dart';
import '../../../models/entities/user.dart';
import '../../../models/user_model.dart';
import '../../../screens/users/login.dart';
import '../../../screens/users/user_loyalty.dart';
import '../../../widgets/home/banner/banner_items.dart';
import '../../../widgets/home/header/header_text.dart';

/// The Banner Group type to display the image as multi columns
class BannerSliderItems extends StatefulWidget {
  final config;
  final User? user;

  BannerSliderItems({this.config, this.user, Key? key}) : super(key: key);

  @override
  _StateBannerSlider createState() => _StateBannerSlider();
}

class _StateBannerSlider extends State<BannerSliderItems> {
  int position = 0;

  late PageController _controller;
  bool? autoPlay;
  Timer? timer;
  int? intervalTime;
  Map? response;

  void initState() {
    autoPlay = widget.config['autoPlay'] ?? false;
    _controller = PageController();
    intervalTime = widget.config['intervalTime'] ?? 3;
    autoPlayBanner();
    if (Provider.of<UserModel>(context, listen: false).user != null) {
      getData(context, 'https://up.ctown.jo/api/getloyalty.php', Provider.of<UserModel>(context, listen: false).user?.id);
    }

    super.initState();
  }

  void autoPlayBanner() {
    List items = widget.config['items'];
    timer = Timer.periodic(Duration(seconds: intervalTime ?? 0), (callback) {
      if (widget.config['design'] != 'default' || !autoPlay!) {
        timer?.cancel();
      } else if (widget.config['design'] == 'default' && autoPlay!) {
        if (position >= items.length - 1 && (_controller?.hasClients)!) {
          _controller?.jumpToPage(0);
        } else {
          if (position != null && (_controller?.hasClients)!) {
            _controller?.animateToPage(position + 1, duration: const Duration(seconds: 1), curve: Curves.easeInOut);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    if (timer != null) {
      timer?.cancel();
    }

    _controller?.dispose();
    super.dispose();
  }

  Future getData(BuildContext context, String url, id) async {
    // print("user id $id");
    Map<String, dynamic> _queryParams = {};
    _queryParams['id'] = id;
    var uri = "$url?id=$id&nocache=${DateTime.now().microsecond}${DateTime.now().microsecond}${DateTime.now().microsecond}";
    printLog("xcbvcgersdfgdfg");
    printLog(uri);

    var res = await http.get(Uri.parse(uri));
    //res = res.replace(queryParameters: _queryParams);
    // var res=http.post(
    //   url,
    //   headers: <String, String>{
    //     'Content-Type': 'application/json; charset=UTF-8',
    //   },
    //   body: jsonEncode(<String, String>{
    //     'id': '34',
    //   }),
    // );
    if (res.statusCode == 200) {
      response = convert.jsonDecode(res.body);
      setState(() {});
      //return convert.jsonDecode(res.body);
    } else {
      final body = convert.jsonDecode(res.body);

      Tools.showSnackBar(
        ScaffoldMessenger.of(context),
        body["message"] != null ? body["message"] : 'Incorrect OTP. Retry with correct OTP',
      );
    }
  }

  Widget getBannerPageView(width) {
    List items = widget.config['items'];
    bool showNumber = widget.config['showNumber'] ?? false;

    return Padding(
      child: Stack(
        children: <Widget>[
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                position = index;
              });
            },
            children: <Widget>[
              for (int i = 0; i < items.length; i++)
                BannerImageItem(
                  config: items[i],
                  width: width,
                  boxFit: BoxFit.cover,
                  padding: Tools.formatDouble(widget.config['padding'] ?? 0.0),
                  radius: Tools.formatDouble(widget.config['radius'] ?? 6.0),
                ),
            ],
          ),
          Positioned(
              bottom: 10,
              right: 150,
              child: SmoothPageIndicator(
                controller: _controller,
                count: items.length,
                effect: const ScrollingDotsEffect(
                  activeStrokeWidth: 2.6,
                  activeDotColor: Colors.black87,
                  dotColor: Colors.black12,
                  activeDotScale: 1.5,
                  radius: 7,
                  spacing: 10,
                  dotHeight: 2,
                  dotWidth: 15,
                ),
              )),
          showNumber
              ? Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 0, right: 0),
                    child: Container(
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.6)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        child: Text(
                          "${position + 1}/${items.length}",
                          style: const TextStyle(fontSize: 11, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                )
              : Container()
        ],
      ),
      padding: const EdgeInsets.only(top: 5, bottom: 5),
    );
  }

  Widget renderBanner(width) {
    List items = widget.config['items'];
    switch (widget.config['design']) {
      case 'swiper':
        return Swiper(
          onIndexChanged: (index) {
            setState(() {
              position = index;
            });
          },
          autoplay: autoPlay ?? false,
          itemBuilder: (BuildContext context, int index) {
            return BannerImageItem(
              config: items[index],
              width: width,
              boxFit: BoxFit.cover,
              radius: Tools.formatDouble(widget.config['radius'] ?? 6.0),
            );
          },
          itemCount: items.length,
          viewportFraction: 0.85,
          scale: 0.9,
          duration: intervalTime ?? 0,
        );
      case 'tinder':
        return Swiper(
          onIndexChanged: (index) {
            setState(() {
              position = index;
            });
          },
          autoplay: autoPlay ?? false,
          itemBuilder: (BuildContext context, int index) {
            return BannerImageItem(
              config: items[index],
              width: width,
              boxFit: BoxFit.cover,
              radius: Tools.formatDouble(widget.config['radius'] ?? 6.0),
            );
          },
          itemCount: items.length,
          itemWidth: width,
          itemHeight: width * 1.2,
          layout: SwiperLayout.TINDER,
          duration: intervalTime ?? 0,
        );
      case 'stack':
        return Swiper(
          onIndexChanged: (index) {
            setState(() {
              position = index;
            });
          },
          autoplay: autoPlay ?? false,
          itemBuilder: (BuildContext context, int index) {
            return BannerImageItem(
              config: items[index],
              width: width,
              boxFit: BoxFit.cover,
              radius: Tools.formatDouble(widget.config['radius'] ?? 6.0),
            );
          },
          itemCount: items.length,
          itemWidth: width - 40,
          layout: SwiperLayout.STACK,
          duration: intervalTime ?? 0,
        );
      case 'custom':
        return Swiper(
          onIndexChanged: (index) {
            setState(() {
              position = index;
            });
          },
          autoplay: autoPlay ?? false,
          itemBuilder: (BuildContext context, int index) {
            return BannerImageItem(
              config: items[index],
              width: width,
              boxFit: BoxFit.cover,
              radius: Tools.formatDouble(widget.config['radius'] ?? 6.0),
            );
          },
          itemCount: items.length,
          itemWidth: width - 40,
          itemHeight: width + 100,
          duration: intervalTime ?? 0,
          layout: SwiperLayout.CUSTOM,
          customLayoutOption: CustomLayoutOption(startIndex: -1, stateCount: 3).addRotate([-45.0 / 180, 0.0, 45.0 / 180]).addTranslate(
            [const Offset(-370.0, -40.0), const Offset(0.0, 0.0), const Offset(370.0, -40.0)],
          ),
        );
      default:
        return getBannerPageView(width);
    }
  }

  double? bannerPercent(width) {
    final screenSize = MediaQuery.of(context).size;
    return Tools.formatDouble(widget.config['height'] ?? 0.5 / (screenSize.height / width));
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    bool isBlur = widget.config['isBlur'] == true;
    bool loggedIn = Provider.of<UserModel>(context).loggedIn;
    String lang = Provider.of<AppModel>(context, listen: false).langCode ?? "en";
    List items = widget.config['items'];
    double bannerExtraHeight = screenSize.height * (widget.config['title'] != null ? 0.12 : 0.0);
    double? upHeight = Tools.formatDouble(widget.config['upHeight'] ?? 0.0);

    //Set autoplay for default template
    autoPlay = widget.config['autoPlay'] ?? false;
    if (widget.config['design'] == 'default' && timer != null) {
      if (!autoPlay!) {
        if ((timer?.isActive)!) {
          timer?.cancel();
        }
      } else {
        if (!(timer?.isActive)!) {
          Future.delayed(Duration(seconds: intervalTime ?? 0), () => autoPlayBanner);
        }
      }
    }

    return Column(
      children: [
        Container(
          child: LayoutBuilder(
            builder: (context, constraint) {
              double? _bannerPercent = bannerPercent(constraint.maxWidth);
              return FractionallySizedBox(
                widthFactor: 1.0,
                child: SizedBox(
                  height: screenSize.height * _bannerPercent! + bannerExtraHeight + upHeight!,
                  child: Stack(
                    children: <Widget>[
                      if (widget.config['showBackground'] == true)
                        SizedBox(
                          height: screenSize.height * _bannerPercent + bannerExtraHeight + upHeight,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 50),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.elliptical(100, 6),
                              ),
                              child: Stack(children: <Widget>[
                                isBlur
                                    ? Transform.scale(
                                        scale: 3,
                                        child: ExtendedImage.network(
                                          items[position]['background'] ?? items[position]['image'],
                                          fit: BoxFit.fill,
                                          cache: true,
                                          width: screenSize.width + upHeight,
                                        ),
                                      )
                                    : ExtendedImage.network(
                                        items[position]['background'] ?? items[position]['image'],
                                        fit: BoxFit.fill,
                                        cache: true,
                                        width: constraint.maxWidth,
                                        height: screenSize.height * _bannerPercent + bannerExtraHeight + upHeight,
                                      ),
                                ClipRect(
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: isBlur ? 12 : 0, sigmaY: isBlur ? 12 : 0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(isBlur ? 0.6 : 0.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                          ),
                        ),
                      if (widget.config['title'] != null)
                        HeaderText(
                          config: widget.config,
                        ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: screenSize.height * _bannerPercent,
                          child: renderBanner(constraint.maxWidth),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        if (widget.user == null)
          if (!loggedIn)
            Container(
                padding: const EdgeInsets.all(2),
                margin: const EdgeInsets.only(left: 10, right: 10),
                height: 50,
                width: screenSize.width * 1,
                decoration: BoxDecoration(color: Colors.yellow, borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 5),
                      height: 35,
                      child: Image.asset("assets/images/logo.png"),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      child: Center(
                          child: Text(S.of(context).earnpoints, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600))),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(builder: (context) => LoginScreen(reLogin: true))
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(1),
                        margin: const EdgeInsets.only(left: 5),
                        height: 30,
                        width: screenSize.width * .35,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)),
                        child: Center(
                            child: Text(
                          S.of(context).loginorregister.toUpperCase(),
                          style: const TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                        )),
                      ),
                    )
                  ],
                )),
        if (loggedIn)
          Container(
            margin: const EdgeInsets.only(left: 3, right: 3),
            padding: const EdgeInsets.only(left: 7, right: 7),
            height: 50,
            width: screenSize.width * 1,
            decoration: BoxDecoration(color: Colors.yellow, borderRadius: BorderRadius.circular(10)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              // FutureBuilder(
              //   future: getData(
              //       context,
              //       'https://up.ctown.jo/api/getloyalty.php',
              //       Provider.of<UserModel>(context, listen: false).user.id),
              //   builder: (context, snap) {
              //     if (!snap.hasData) {
              //       return Container(
              //         margin: EdgeInsets.only(left: 10),
              //         child: Text('Available Points : 0.00',
              //             style: TextStyle(color: Colors.black)),
              //       );
              //     }
              //     if (snap.data.isEmpty) {
              //       return const Center(
              //         child: Text("No data"),
              //       );
              //     }
              //     Map map = jsonDecode(snap.data);
              //
              //     return Row(
              //       children: [
              //         Container(
              //           child: map['programName'] == 'Gold'
              //               ? Container(
              //                   child: Row(children: [
              //                   Container(
              //                     margin: EdgeInsets.only(left: 10),
              //                     child: Text(
              //                       S.of(context).available_points,
              //                       style: TextStyle(color: Colors.black),
              //                     ),
              //                   ),
              //                   Container(
              //                       margin: EdgeInsets.only(left: 5),
              //                       child: Text(
              //                         map['availablePoints'].toString(),
              //                         style: TextStyle(color: Colors.black),
              //                       )),
              //                 ]))
              //               : Container(
              //                   child: Row(children: [
              //                   Container(
              //                     margin: EdgeInsets.only(left: 10),
              //                     child: Text(
              //                       S.of(context).available_points,
              //                       style: TextStyle(color: Colors.black),
              //                     ),
              //                   ),
              //                   Container(
              //                       margin: EdgeInsets.only(left: 5),
              //                       child: Text(
              //                         map['availablePoints'].toString(),
              //                         style: TextStyle(color: Colors.black),
              //                       )),
              //                 ])),
              //         ),
              //       ],
              //     );
              //   },
              // ),
              response == null
                  ? Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: Text(lang == "en" ? 'Available Points : 0.00' : "النقاط المتاحة:0.00",
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: Colors.black)))
                  : (response?.isEmpty)!
                      ? const Center(child: Text("No data"))
                      : Container(
                          child: response!['programName'] == 'Gold'
                              ? Row(children: [
                                  Text(S.of(context).available_points,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: Colors.black)),
                                  Container(
                                      margin: const EdgeInsets.only(left: 5),
                                      child: Text(response!['availablePoints'].toString(),
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: Colors.black))),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Image.asset(
                                    "assets/images/coins.png",
                                    height: 40,
                                    width: 40,
                                    fit: BoxFit.fill,
                                  )
                                ])
                              : Row(children: [
                                  Text(S.of(context).available_points,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: Colors.black)),
                                  Container(
                                      margin: const EdgeInsets.only(left: 5),
                                      child: Text(response!['availablePoints'].toString(),
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: Colors.black))),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Image.asset(
                                    "assets/images/coins.png",
                                    height: 40,
                                    width: 40,
                                    fit: BoxFit.fill,
                                  )
                                ]),
                        ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JamaeytiWidget(),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(left: 8, right: 10),
                  height: 30,
                  width: 130,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)),
                  child: Center(
                      child: Text(
                    S.of(context).viewdetails,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  )),
                ),
              ),
            ]),
          ),
        const SizedBox(height: 10),
      ],
    );
  }
}
