import 'package:flutter/material.dart';

class SearchHeaderView extends StatelessWidget {
  const SearchHeaderView(
      {Key? key, required this.controller, this.onSubmitted, this.onChanged})
      : super(key: key);

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            autofocus: true,
            controller: controller,
            onSubmitted: onSubmitted,
            onChanged: onChanged,
            decoration: InputDecoration(
              suffix: controller.text.isNotEmpty ? IconButton(
                  onPressed: controller.clear,
                  icon: const Icon(Icons.clear),
                  color: Colors.black) :SizedBox.shrink(),
              fillColor: Colors.white,
                filled: true,
                border: InputBorder.none,
                hintText: "Search products, articles, faq, ..."),
          ),
        ),
      ],
    );
  }
}
