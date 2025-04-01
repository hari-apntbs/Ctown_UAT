import 'package:flutter/material.dart';

class FilterOptionItem extends StatelessWidget {
  final bool enabled;
  final Function? onTap;
  final bool? selected;
  final String? title;
  final bool isValid;

  const FilterOptionItem({
    Key? key,
    this.enabled = true,
    this.onTap,
    this.selected,
    this.title,
    this.isValid = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (enabled == true && onTap != null) {
          onTap!();
        }
      },
      child: Container(
        margin: const EdgeInsets.all(5.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 10.0),
          child: Text(
            title ?? "",
            style: isValid == true
                ? selected == true
                    ? const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        fontSize: 13,
                      )
                    : TextStyle(
                        color: Colors.black.withOpacity(0.3),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        fontSize: 13,
                      )
                : TextStyle(
                    color: Colors.black.withOpacity(0.3),
                    fontWeight: FontWeight.bold,
                  ),
          ),
        ),
        decoration: BoxDecoration(
          color: isValid == true
              ? selected == true
                  ? Colors.black.withOpacity(0.15)
                  : Colors.black.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(9.0),
        ),
      ),
    );
  }
}
