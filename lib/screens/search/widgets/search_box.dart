import 'dart:async';

import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchBox extends StatefulWidget {
  final double? width;
  final bool showCancelButton;
  final bool showSearchIcon;
  final bool autoFocus;
  final String? initText;
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final Function()? onCancel;
  final Function(String value)? onChanged;
  final Function(String value)? onSubmitted;

  SearchBox({
    Key? key,
    this.focusNode,
    this.onCancel,
    this.width,
    this.onChanged,
    this.controller,
    this.initText,
    this.onSubmitted,
    this.autoFocus = false,
    this.showSearchIcon = true,
    this.showCancelButton = true,
  }) : super(key: key);

  @override
  _SearchBoxState createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  TextEditingController? _textController;

  double get widthButtonCancel =>
      _textController!.text.isEmpty ? 0 : 50;

  String _oldSearchText = '';
  Timer? _debounceQuery;

  Function(String value)? get onChanged => widget.onChanged;

  @override
  void initState() {
    super.initState();
    _textController =
        widget.controller ?? TextEditingController(text: widget.initText ?? '');
    _textController!.addListener(_onSearchTextChange);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _textController!.dispose();
    }
    super.dispose();
  }

  void _onSearchTextChange() {
    if (_oldSearchText != _textController!.text) {
      if (_textController!.text.isEmpty) {
        _oldSearchText = _textController!.text;
        setState(() {});
        widget.onChanged?.call(_textController!.text);
        return;
      }

      if (_debounceQuery?.isActive ?? false) _debounceQuery!.cancel();
      _debounceQuery = Timer(const Duration(milliseconds: 800), () {
        _oldSearchText = _textController!.text;
        widget.onChanged?.call(_textController!.text);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      child: Row(children: [
        Expanded(
          child: Container(
            height: 34,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColorLight,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Colors.black,
                width: .1,
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 5),
            margin: const EdgeInsets.only(left: 0, right: 10, bottom: 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                if (widget.showSearchIcon)
                  Image.asset(
                    "assets/icons/tabs/icon-search.png",
                    width: 20,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.secondary
                        //  Colors.black,
                        ),
                    decoration: InputDecoration(
                      fillColor: Theme.of(context).colorScheme.secondary,
                      // hintText: S.of(context).searchForItems,
                      enabledBorder: InputBorder.none,
                      border: InputBorder.none,
                    ),
                    controller: _textController,
                    autofocus: widget.autoFocus,
                    focusNode: widget.focusNode,
                    onSubmitted: (value) => widget.onSubmitted?.call(value),
                  ),
                ),
                if (widget.showCancelButton)
                  AnimatedContainer(
                    width: widthButtonCancel,
                    child: GestureDetector(
                      onTap: () {
                        widget.onCancel?.call();
                        _textController!.clear();
                        FocusScopeNode currentFocus = FocusScope.of(context);
                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                        }
                      },
                      child: Center(
                        child: Text(
                          S.of(context).cancel,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    duration: const Duration(milliseconds: 250),
                  )
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
