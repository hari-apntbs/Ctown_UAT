
import 'package:configurable_expansion_tile_null_safety/configurable_expansion_tile_null_safety.dart';
import 'package:flutter/material.dart';

class ExpansionInfo extends StatelessWidget {
  final String title;
  final bool expand;
  final List<Widget> children;

  ExpansionInfo(
      {required this.title, required this.children, this.expand = false});

  @override
  Widget build(BuildContext context) {
    return ConfigurableExpansionTile(
      initiallyExpanded: expand,
      headerExpanded: Flexible(
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(width: 15),
                  Text(title,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Icon(
                    Icons.keyboard_arrow_up,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 20,
                  ),
                  const SizedBox(width: 15),
                ])),
      ),
      header: (val, animate1, animate2, controller) {
        return Flexible(
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(title,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    Icon(
                      Icons.keyboard_arrow_right,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 20,
                    )
                  ])),
        );
      },
      childrenBody: children[0],
    );
  }
}
