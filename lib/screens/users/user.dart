import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_model.dart';
import '../settings/settings.dart';

class UserScreen extends StatefulWidget {
  final String? background;
  final List<dynamic>? settings;
  final bool? showChat;
  final String? notifyScreen;
  UserScreen({this.settings, this.background, this.showChat, this.notifyScreen});

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  //   with AutomaticKeepAliveClientMixin<UserScreen> {
  // @override
  // bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    // super.build(context);
    final userModel = Provider.of<UserModel>(context);

    return ListenableProvider.value(
      value: userModel,
      child: Consumer<UserModel>(
        builder: (context, value, child) {
          return SettingScreen(
            settings: widget.settings,
            background: widget.background,
            showChat: widget.showChat,
            user: value.user,
            notifyScreen: widget.notifyScreen,
          );
        },
      ),
    );
  }
}
