import 'dart:async';

import 'package:flutter/material.dart';

import '../../common/constants.dart';
import 'adaptive.dart';

class MainLayout extends StatefulWidget {
  final Widget? menu;
  final Widget? content;

  MainLayout({
    Key? key,
    this.menu,
    this.content,
  }) : super(key: key);

  @override
  _LayoutWebCustomState createState() => _LayoutWebCustomState();
}

class _LayoutWebCustomState extends State<MainLayout>
    with SingleTickerProviderStateMixin {
  bool showMenu = false;
  bool isFirstRun = false;
  double menuWidth = 0;

  Duration duration = const Duration(milliseconds: 600);

  StreamSubscription? _subOpenCustomDrawer;
  StreamSubscription? _subCloseCustomDrawer;
  StreamSubscription? _subSwitchStateCustomDrawer;

  @override
  void initState() {
    super.initState();
    _subOpenCustomDrawer = eventBus.on<EventOpenCustomDrawer>().listen((event) {
      if (!showMenu) {
        setState(() {
          showMenu = true;
        });
      }
    });
    _subCloseCustomDrawer =
        eventBus.on<EventCloseCustomDrawer>().listen((event) {
      if (showMenu) {
        setState(() {
          showMenu = false;
        });
      }
    });
    _subSwitchStateCustomDrawer =
        eventBus.on<EventSwitchStateCustomDrawer>().listen((event) {
      if (showMenu) {
        eventBus.fire(const EventCloseCustomDrawer());
      } else {
        eventBus.fire(const EventOpenCustomDrawer());
      }
    });
  }

  void initLayout() {
    if (!isFirstRun) {
      if (isDisplayDesktop(context)) {
        showMenu = true;
        isFirstRun = true;
      }
    }
    /*   if (isDisplayDesktop(context)) {
      if (showMenu && isBigScreen(context)) {
        menuWidth = 250;
      } else {
        menuWidth = 0;
      }
    }*/
    menuWidth = 0;
  }

  @override
  void dispose() {
    _subOpenCustomDrawer?.cancel();
    _subCloseCustomDrawer?.cancel();
    _subSwitchStateCustomDrawer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    initLayout();

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            /* if (isBigScreen(context))
              AnimatedContainer(
                width: menuWidth,
                curve: Curves.easeInOutQuint,
                duration: duration,
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.only(bottom: 32),
                child: OverflowBox(
                  child: widget.menu,
                  maxWidth: 250,
                  maxHeight: 1000,
                  alignment: Alignment.topRight,
                ),
                color: Theme.of(context).primaryColorLight.withOpacity(0.7),
              ),*/
            Expanded(
              child: widget.content!,
            ),
          ],
        ),
      ),
    );
  }
}
