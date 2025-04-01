import 'package:flutter/material.dart';

import '../../services/index.dart';

class CartScreen extends StatefulWidget {
  final bool? isModal;
  final bool isBuyNow;
  final bool? showChat;

  CartScreen({this.isModal, this.isBuyNow = false, this.showChat});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          top: true,
          bottom: false,
          child: Services().widget?.renderCartPageView(
              isModal: widget.isModal,
              isBuyNow: widget.isBuyNow,
              pageController: pageController,
              context: context) ?? const SizedBox.shrink(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }
}
