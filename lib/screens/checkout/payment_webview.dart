import 'package:flutter/material.dart';

import '../../common/constants.dart';
import '../../screens/base.dart';
import '../../services/index.dart';
//
// class PaymentWebview extends StatefulWidget {
//   final String? url;
//   final Function? onFinish;
//   final Function? onClose;
//
//   PaymentWebview({this.onFinish, this.onClose, this.url});
//
//   @override
//   State<StatefulWidget> createState() {
//     return PaymentWebviewState();
//   }
// }
//
// class PaymentWebviewState extends BaseScreen<PaymentWebview> {
//   @override
//   Future<void> afterFirstLayout(BuildContext context) async {
//     initWebView();
//   }
//
//   void initWebView() {
//     final flutterWebviewPlugin = FlutterWebviewPlugin();
//
//     flutterWebviewPlugin.onUrlChanged.listen((String url) {
//       if (url.contains("/order-received/")) {
//         final items = url.split("/order-received/");
//         if (items.length > 1) {
//           final number = items[1].split("/")[0];
//           widget.onFinish!(number);
//           Navigator.of(context).pop();
//         }
//       }
//       if (url.contains("checkout/success")) {
//         widget.onFinish!("0");
//         Navigator.of(context).pop();
//       }
//
//       // shopify url final checkout
//       if (url.contains("thank_you")) {
//         widget.onFinish!("0");
//         Navigator.of(context).pop();
//       }
//     });
//
//     // this code to hide some classes in website, change site-header class based on the website
//     flutterWebviewPlugin.onStateChanged.listen((viewState) {
//       if (viewState.type == WebViewState.finishLoad) {
//         flutterWebviewPlugin.evalJavascript(
//             "document.getElementsByClassName(\"site-header\")[0].style.display='none';");
//         flutterWebviewPlugin.evalJavascript(
//             "document.getElementsByClassName(\"site-footer\")[0].style.display='none';");
//       }
//     });
//
// //    var givenJS = rootBundle.loadString('assets/extra_webview.js');
// //    // ignore: missing_return
// //    givenJS.then((String js) {
// //      flutterWebviewPlugin.onStateChanged.listen((viewState) async {
// //        if (viewState.type == WebViewState.finishLoad) {
// //          await flutterWebviewPlugin.evalJavascript(js);
// //        }
// //      });
// //    });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Map<dynamic, dynamic> checkoutMap = {
//       "url": "",
//       "headers": Map<String, String>()
//     };
//
//     if (widget.url != null) {
//       checkoutMap['url'] = widget.url;
//     } else {
//       final paymentInfo = Services().widget?.getPaymentUrl(context)!;
//       checkoutMap['url'] = paymentInfo!['url'];
//       if (paymentInfo['headers'] != null) {
//         checkoutMap["headers"] =
//             Map<String, String>.from(paymentInfo["headers"]);
//       }
//     }
//
//     return WebviewScaffold(
//       withJavascript: true,
//       appCacheEnabled: true,
//       url: checkoutMap['url'],
//       headers: checkoutMap['headers'],
//       // it's possible to add the Agent to fix the payment in some cases
//       // userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36',
//       appBar: AppBar(
//         leading: IconButton(
//             icon: const Icon(Icons.arrow_back),
//             onPressed: () {
//               Navigator.of(context).pop();
//
//               widget.onClose!();
//             }),
//         backgroundColor: Theme.of(context).colorScheme.surface,
//         elevation: 0.0,
//       ),
//       withZoom: true,
//       withLocalStorage: true,
//       hidden: true,
//       initialChild: Container(child: kLoadingWidget(context)),
//     );
//   }
// }
