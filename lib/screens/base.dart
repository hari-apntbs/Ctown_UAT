import 'package:flutter/material.dart';

abstract class BaseScreen<T extends StatefulWidget> extends State<T> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if the widget is still mounted before calling afterFirstLayout
      if (mounted) {
        afterFirstLayout(context);
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void afterFirstLayout(BuildContext context);
}
