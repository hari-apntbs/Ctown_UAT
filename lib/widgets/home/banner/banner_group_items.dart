import 'package:flutter/material.dart';

import '../../../widgets/home/banner/banner_items.dart';

/// The Banner Group type to display the image as multi columns
class BannerGroupItems extends StatelessWidget {
  final config;

  BannerGroupItems({this.config, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List items = config['items'];
    int len = items.length;
    double? _leftPadding;
    double? _rightPadding;
    if (len == 2) {
      _leftPadding =
          (items.first["padding"] is String ? double.parse(items.first["padding"]) : items.first["padding"]) * len;
      _rightPadding =
          (items.first["padding"] is String ? double.parse(items.first["padding"]) : items.first["padding"]) * len;
    }

    return Container(
      color: Theme.of(context).colorScheme.surface,
      //padding: EdgeInsets.all(Tools.formatDouble(config['padding'] ?? 10.0)),
      padding: const EdgeInsets.only(top: 0.0, bottom: 5.0, left: 0.0, right: 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          for (int i = 0; i < items.length; i++)
            Expanded(
              child: BannerImageItem(
                config: items[i],
                leftPadding: i == 0 ? _leftPadding : null,
                rightPadding: i == len - 1 ? _rightPadding : null,
              ),
            ),
        ],
      ),
    );
  }
}
