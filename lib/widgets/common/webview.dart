import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../../common/constants.dart';

class InAppWebView extends StatefulWidget {
  final String? url;
  final String? title;
  final String? javaScript;
  bool? appBarRequire;

  InAppWebView({Key? key, this.title, this.url, this.javaScript, this.appBarRequire}) : super(key: key);

  @override
  _InAppWebViewState createState() => _InAppWebViewState();
}

class _InAppWebViewState extends State<InAppWebView> {
  bool isLoading = true;
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();
    PlatformWebViewControllerCreationParams params = const PlatformWebViewControllerCreationParams();;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }
    final WebViewController controller =
    WebViewController.fromPlatformCreationParams(params);
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
            debugPrint('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('allowing navigation to ${request.url}');
            return NavigationDecision.navigate;
          },
          onUrlChange: (UrlChange change) {
            debugPrint('url change to ${change.url}');
          },
        ),
      )
      ..runJavaScript(widget.javaScript ?? "")
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..loadRequest(Uri.parse(widget.url!));

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features
    _controller = controller;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBarRequire! ?
      AppBar(
        title: Text(widget.title ?? ""),
        backgroundColor: Theme.of(context).primaryColorLight,
        leading: GestureDetector(
          child: const Icon(Icons.arrow_back_ios),
          onTap: () => Navigator.pop(context),
        ),
      ) : null,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: <Widget>[
          WebViewWidget(controller: _controller),
          if (isLoading) Center(
            child: kLoadingWidget(context),
          ),
        ],
      ),
    );
  }
}
