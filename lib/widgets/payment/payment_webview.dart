import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../common/constants/colors.dart';
import '../../common/constants/route_list.dart';
import '../../generated/l10n.dart';
import '../../models/entities/order.dart';
import '../../screens/checkout/webview_checkout_success.dart';

class PaymentWebView extends StatefulWidget {
  final Function? onFinish;
  final Function(bool)? onLoading;
  final Order? newOrder;
  final String? url;
  bool? isPaying2;

  PaymentWebView({
    Key? key,
    this.onFinish,
    this.onLoading,
    this.isPaying2,
    this.newOrder,
    this.url,
  }) : super(key: key);

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late InAppWebViewController webViewController;
  Size? screenSize;
  bool? isPaying;

  @override
  void initState() {
    super.initState();
    isPaying = widget.isPaying2;
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: kTeal100, // Status bar color
    ));

    return WillPopScope(
      onWillPop: () async => false,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(statusBarBrightness: Brightness.light),
        child: SafeArea(
          child: WillPopScope(
            onWillPop: () async {
              if (widget.onLoading != null) {
                widget.onLoading!(false);
              }
              isPaying = false;
              return true;
            },
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.grey[200],
              body: Stack(
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: InAppWebView(
                      initialUrlRequest: URLRequest(
                        url: WebUri(widget.url ?? ""),
                      ),
                      initialSettings: InAppWebViewSettings(
                        javaScriptEnabled: true,
                        cacheEnabled: true
                      ),
                      onWebViewCreated: (controller) {
                        webViewController = controller;
                        InAppWebViewController.clearAllCache();
                      },
                      onLoadStart: (controller, url) {
                        debugPrint("Request started: $url");
                        if (widget.onLoading != null) {
                          widget.onLoading!(true);
                        }
                      },
                      onLoadStop: (controller, url) async {
                        debugPrint("Request finished: $url");
                        if (widget.onLoading != null) {
                          widget.onLoading!(false);
                        }
                        if (url != null) {
                          _handleNavigation(url.toString());
                        }
                      },
                      onReceivedError: (controller, url, error) {
                        debugPrint("Error loading URL: $url, Error: ${error.description}");
                        if (widget.onLoading != null) {
                          widget.onLoading!(false);
                        }
                      },
                      onReceivedServerTrustAuthRequest: (controller, challenge) async {
                        return ServerTrustAuthResponse(
                          action: ServerTrustAuthResponseAction.PROCEED,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleNavigation(String url) async {
    if (url.contains("tnssuccess.php")) {
      // Handle payment success
      if (widget.onFinish != null) {
        widget.onFinish!(widget.newOrder);
      }
      if (widget.onLoading != null) {
        widget.onLoading!(false);
      }
      isPaying = false;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => WebviewCheckoutSuccess(order: widget.newOrder),
        ),
      );
    } else if (url.contains("cancel.php") || url.contains("cancel")) {
      // Handle payment cancel
      if (widget.onLoading != null) {
        widget.onLoading!(false);
      }
      isPaying = false;
      await _showCancelDialog();
    }
  }

  Future<void> _showCancelDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(S.of(context).orderStatusFailed),
          content: const Text("Your payment has been cancelled."),
          actions: <Widget>[
            TextButton(
              child: Text(
                S.of(context).ok,
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              onPressed: () {
                Navigator.of(context).pushReplacementNamed(RouteList.dashboard);
              },
            ),
          ],
        );
      },
    );
  }
}
