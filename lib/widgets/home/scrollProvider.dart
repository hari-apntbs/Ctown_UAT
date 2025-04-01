import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScrollProvider extends ChangeNotifier {
  ScrollController? homeScrollController;
  ScrollProvider() {
    homeScrollController = ScrollController();
  }

  setPositionToTop() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var result = await prefs.getString('savedStore')!;
    print("saved store $result");
    print(jsonDecode(result));

    Timer(
        Duration.zero,
        () => homeScrollController!.animateTo(
            homeScrollController!.position.minScrollExtent,
            duration: Duration.zero,
            curve: Curves.ease));
  }
}
