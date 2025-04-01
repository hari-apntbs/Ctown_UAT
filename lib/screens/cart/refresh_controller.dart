import 'package:flutter/material.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class RefreshControllerProvider with ChangeNotifier {
  final RefreshController _refreshController = RefreshController();

  RefreshController get refreshController => _refreshController;

  void triggerRefresh() {
    _refreshController.requestRefresh();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}



