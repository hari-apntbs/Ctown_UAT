import 'dart:async';

import 'package:flash/flash.dart';
import 'package:flash/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FlashHelper {
  static Completer<BuildContext> _buildCompleter = Completer<BuildContext>();

  static void init(BuildContext context) {
    if (_buildCompleter.isCompleted == false) {
      _buildCompleter.complete(context);
    }
  }

  static void dispose() {
    if (_buildCompleter.isCompleted == false) {
      _buildCompleter.completeError(FlutterError('disposed'));
    }
    _buildCompleter = Completer<BuildContext>();
  }

  static Future<T?> toast<T>(String message) async {
    final context = await _buildCompleter.future;
    return context.showToast(
      DefaultTextStyle(
        style: const TextStyle(fontSize: 16.0, color: Colors.white),
        child: Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(message),
        ),
      ),
      duration: const Duration(seconds: 3),
      shape: const StadiumBorder(),
      queue: false,
      alignment: const Alignment(0, 0.5),
      backgroundColor: Colors.black87,
    );
  }

  static Color _backgroundColor(BuildContext context) {
    var theme = Theme.of(context);
    return theme.dialogTheme.backgroundColor ?? theme.dialogBackgroundColor;
  }

  static TextStyle _titleStyle(BuildContext context, [Color? color]) {
    var theme = Theme.of(context);
    return (theme.dialogTheme.titleTextStyle ?? theme.textTheme.titleMedium)!
        .copyWith(color: color);
  }

  static TextStyle _contentStyle(BuildContext context, [Color? color]) {
    var theme = Theme.of(context);
    return (theme.dialogTheme.contentTextStyle ?? theme.textTheme.bodyLarge)!
        .copyWith(color: color);
  }

  static Future<T?> successBar<T>(
      BuildContext context, {
        String? title,
        String? message,
        Duration duration = const Duration(seconds: 3),
      }) {
    return showFlash<T>(
      context: context,
      duration: duration,
      builder: (_, controller) {
        return Flash(
          controller: controller,
          dismissDirections: const [FlashDismissDirection.startToEnd],
          child: FlashBar(
            controller: controller,
            title: title == null
                ? null
                : Text(title, style: _titleStyle(context, Colors.white)),
            content: Text(message!, style: _contentStyle(context, Colors.white)),
            icon: Icon(Icons.check_circle, color: Colors.yellow[300]),
            indicatorColor: Colors.yellow[300],
          ),
        );
      },
    );
  }

  static Future<T?> informationBar<T>(
      BuildContext context, {
        String? title,
        String? message,
        Duration duration = const Duration(seconds: 3),
      }) {
    return showFlash<T>(
      context: context,
      duration: duration,
      builder: (_, controller) {
        return Flash(
          controller: controller,
          dismissDirections: const [FlashDismissDirection.startToEnd],
          // backgroundColor: Colors.black87,
          child: FlashBar(
            controller: controller,
            title: title == null
                ? null
                : Text(title, style: _titleStyle(context, Colors.white)),
            content: Text(message!, style: _contentStyle(context, Colors.white)),
            icon: const Icon(Icons.info_outline, color: Colors.black),
            indicatorColor: Colors.black,
          ),
        );
      },
    );
  }

  static Future<T?> errorBar<T>(
      BuildContext context, {
        String? title,
        String? message,
        Duration duration = const Duration(seconds: 3),
      }) {
    return showFlash<T>(
      context: context,
      duration: duration,
      builder: (_, controller) {
        return Flash(
          controller: controller,
          dismissDirections: const [FlashDismissDirection.startToEnd],
          // backgroundColor: Colors.black87,
          child: FlashBar(
            controller: controller,
            title: title == null
                ? null
                : Text(title, style: _titleStyle(context, Colors.white)),
            content: Text(message!, style: _contentStyle(context, Colors.white)),
            icon: Icon(Icons.warning, color: Colors.red[300]),
            indicatorColor: Colors.red[300],
          ),
        );
      },
    );
  }

  static Future<T?> actionBar<T>(
      BuildContext context, {
        String? title,
        String? message,
        Widget? primaryAction,
        ActionCallback? onPrimaryActionTap,
        Duration duration = const Duration(seconds: 3),
      }) {
    return showFlash<T>(
      context: context,
      duration: duration,
      builder: (_, controller) {
        return Flash(
          controller: controller,
          dismissDirections: const [FlashDismissDirection.startToEnd],
          // backgroundColor: Colors.black87,
          child: FlashBar(
            controller: controller,
            title: title == null
                ? null
                : Text(title, style: _titleStyle(context, Colors.white)),
            content: Text(message!, style: _contentStyle(context, Colors.white)),
            primaryAction: TextButton(
              onPressed: onPrimaryActionTap == null
                  ? null
                  : () => onPrimaryActionTap(controller),
              child: primaryAction!,
            ),
          ),
        );
      },
    );
  }

  static Future<T?> simpleDialog<T>(
      BuildContext context, {
        String? title,
        String? message,
        Widget? negativeAction,
        ActionCallback? onNegativeActionTap,
        Widget? positiveAction,
        ActionCallback? positiveActionTap,
      }) {
    return context.showFlash(
      barrierColor: _backgroundColor(context),
      barrierDismissible: true,
      builder: (context, controller) => FadeTransition(
        opacity: controller.controller,
        child: AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            side: BorderSide(),
          ),
          title: title == null ? null : Text(title, style: _titleStyle(context)),
          content: Text(message!, style: _contentStyle(context)),
          actions: <Widget>[
            if (negativeAction != null)
              TextButton(
                onPressed: onNegativeActionTap == null
                    ? null
                    : () => onNegativeActionTap(controller),
                child: negativeAction,
              ),
            if (positiveAction != null)
              TextButton(
                onPressed: positiveActionTap == null
                    ? null
                    : () => positiveActionTap(controller),
                child: positiveAction,
              ),
          ],
        ),
      ),
    );
  }

  static Future<T?> blockDialog<T>(
      BuildContext context, {
        Completer<T>? dismissCompleter,
      }) {
    return context.showBlockDialog(dismissCompleter: dismissCompleter);
  }
}

typedef ActionCallback = void Function(FlashController controller);
