import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/constants.dart';
import '../../models/index.dart';
import '../../services/index.dart' show Config;

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';

class MagentoPayment extends StatefulWidget {
  final Order? order;
  final Function? onFinish;

  MagentoPayment({this.order, this.onFinish});

  @override
  State<StatefulWidget> createState() {
    return MagentoPaymentState();
  }
}

class MagentoPaymentState extends State<MagentoPayment> {
  late InAppWebViewController _webViewController;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var checkoutUrl = "";
    final paymentMethod = Provider.of<CartModel>(context).paymentMethod!.id;
    if (paymentMethod == "HyperPay_SadadPayware") {
      checkoutUrl = Config().url! +
          "/mspayment/resolver_hyperpay/sadad?order_id=" +
          widget.order!.number!;
    } else {
      checkoutUrl = Config().url! +
          "/mspayment/resolver_hyperpay/request?order_id=" +
          widget.order!.number!;
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        backgroundColor: kGrey200,
        elevation: 0.0,
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(checkoutUrl)),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          cacheEnabled: true,
        ),
        onWebViewCreated: (controller) {
          _webViewController = controller;
        },
        onLoadStart: (controller, url) {
          if (url.toString().contains("mspayment/resolver/notify")) {
            final uri = Uri.parse(url.toString());
            final status = uri.queryParameters['status'];
            if (status == 'success') {
              widget.onFinish?.call(widget.order);
              Navigator.of(context).pop();
            }
          }
        },
        onLoadStop: (controller, url) async {
          // Handle any additional logic if needed when the page finishes loading
        },
      ),
    );
  }
}

