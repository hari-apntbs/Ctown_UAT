import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../../models/index.dart' show Category;

class CategoryItem extends StatelessWidget {
  final Category category;
  final bool isLast;
  final bool isParent;
  final bool isSelected;
  final bool hasChild;
  final Function? onTap;
  final double leftMargin;

  CategoryItem(
    this.category, {
    this.isLast = false,
    this.isParent = false,
    this.isSelected = true,
    this.hasChild = false,
    this.onTap,
    this.leftMargin = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: hasChild
          ? null
          : () {
              onTap!(category.id);
            },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10.0),
        child: Row(
          children: <Widget>[
            Container(
              child: Icon(
                Icons.check,
                // color: isSelected && !isParent ? Colors.white : Colors.transparent,
                color: isSelected && !isParent
                    ? Theme.of(context).colorScheme.secondary
                    // Colors.black
                    : Colors.transparent,
                size: 20,
              ),
            ),

            SizedBox(width: 10.0 + leftMargin),
            // SizedBox(width: isLast ? 50 : 10),
            Expanded(
                child: Text(
              "${isParent ? S.of(context).seeAll : category.name}  ",
              //  "${category.totalProduct != null && !isParent ? '(${category.totalProduct})' : ''}",
              style: TextStyle(
                  // color: Colors.white,
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.secondary),
            )),
            if (hasChild)
              Icon(
                Icons.keyboard_arrow_right,
                // Icons.alarm,
                color: Theme.of(context).colorScheme.secondary,
                size: 20,
              ),
            const SizedBox(width: 20)
          ],
        ),
      ),
    );
  }
}
