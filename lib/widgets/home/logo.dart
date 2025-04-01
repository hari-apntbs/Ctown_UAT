import 'package:barcode_scan2/platform_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../common/constants.dart';
import '../../common/tools.dart';
// import '../../screens/users/user_jamaeyti.dart';
import '../../screens/users/user_loyalty.dart';
import '../../values/values.dart';

class Logo extends StatefulWidget {
  final config;
  Logo({
    Key? key,
    required this.config,
  }) : super(key: key);

  @override
  _LogoState createState() => _LogoState();
}

class _LogoState extends State<Logo> {
  late TextEditingController _textController;
  // String _scanBarcode = 'Go on search for it...';
  String _scanBarcode = 'Search';

  @override
  void initState() {
    super.initState();
  }

  double get widthButtonCancel =>
      _textController.text.isEmpty ?? true ? 0 : 50;

  Widget renderLogo() {
    if (widget.config['image'] != null) {
      if (widget.config['image'].indexOf('http') != -1) {
        return Tools.image(
          url: widget.config['image'],
          height: 150,
        );
      }
      return Image.asset(
        widget.config['image'],
        height: 150,
      );
    }
    return Image.asset(kLogoImage, height: 150);
  }

  void onChangePressed(BuildContext context) => Navigator.push(
      context, MaterialPageRoute(builder: (context) => JamaeytiWidget()));

  void onLoupePressed(BuildContext context) => Navigator.push(
      context, MaterialPageRoute(builder: (context) => JamaeytiWidget()));

  Future<void> onBarcodePressed(BuildContext context) async {
    var barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await BarcodeScanner.scan();
      if (barcodeScanRes != "-1") {
        // ignore: unawaited_futures
        Navigator.of(context)
            .pushNamed(RouteList.homeSearch, arguments: barcodeScanRes.rawContent);
      }
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      if (barcodeScanRes.rawContent != '-1') _scanBarcode = barcodeScanRes.rawContent;
    });
  }

  void onBarcodeTwoPressed(BuildContext context) => Navigator.push(
      context, MaterialPageRoute(builder: (context) => JamaeytiWidget()));
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    final isRotate = screenSize.width > screenSize.height;

    return Builder(
      builder: (context) {
        return Container(
          width: screenSize.width,
          child: FittedBox(
            fit: BoxFit.cover,
            child: Container(
                width: screenSize.width /
                    ((isRotate ? 1.25 : 2) /
                        (screenSize.height / screenSize.width)),
                constraints: const BoxConstraints(
                  minHeight: 40.0,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          width: 31,
                          height: 31,
                          margin: const EdgeInsets.only(top: 3),
                          child: Image.asset(
                            "assets/images/icon.png",
                            //fit: BoxFit.none,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 11,
                        child: Container(
                          // width: 280,
                          // width: MediaQuery.of(context).size.width - 120,
                          height: 34,
                          margin: const EdgeInsets.only(left: 10),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              Shadows.primaryShadow,
                            ],
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 30,
                                height: 18,
                                margin: const EdgeInsets.only(left: 5),
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pushNamed(
                                        RouteList.homeSearch,
                                        arguments: _scanBarcode);
                                  },
                                  // onPressed: () => this.onLoupePressed(context),
                                  style: TextButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(0, 0, 0, 0),
                                    shape: const RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.all(Radius.circular(0)),
                                    ),
                                    foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                                    padding: const EdgeInsets.all(0),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        "assets/images/search.png",
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                      RouteList.homeSearch,
                                      arguments: '');
                                },
                                child: Text(
                                  ' $_scanBarcode',
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    // fontFamily: "Poppins",
                                    fontWeight: FontWeight.w400,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              // const Spacer(),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    margin: const EdgeInsets.only(left: 70),
                                    child: TextButton(
                                      // ignore: unnecessary_this
                                      onPressed: () => onBarcodePressed(context),
                                      style: TextButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(0, 0, 0, 0),
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(0)),
                                        ),
                                        foregroundColor:
                                        const Color.fromARGB(255, 0, 0, 0),
                                        padding: const EdgeInsets.all(0),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Image.asset(
                                            "assets/images/barcode.png",
                                          ),
                                          const SizedBox(
                                            width: 0,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ),
        );
      },
    );
  }
}
