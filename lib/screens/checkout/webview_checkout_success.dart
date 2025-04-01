import 'package:flutter/material.dart';


import '../../models/index.dart' show Order;
import 'success.dart';

class WebviewCheckoutSuccess extends StatelessWidget {
  final Order? order;
  WebviewCheckoutSuccess({this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        // leading: IconButton(
        //     icon: const Icon(Icons.arrow_back),
        //     onPressed: () {
        //       Navigator.of(context).pop();
        //     }),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0.0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: OrderedSuccess(
          order: order,
          isModal: true,
        ),
      ),
    );
  }
}
