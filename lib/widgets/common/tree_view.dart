import 'package:ctown/models/entities/category.dart';
import 'package:ctown/models/product_model.dart';
import 'package:flutter/material.dart';

typedef void ParentSelectChanged(bool isSelected);

/// # Tree View
///
/// Creates a tree view widget. The widget is a List View with a [List] of
/// [Parent] widgets. The [TreeView] is nested inside a [Scrollbar] if the
/// [TreeView.hasScrollBar] property is true.
class TreeView extends StatelessWidget {
  final List<Parent> parentList;
  final bool hasScrollBar;

  TreeView({
    this.parentList = const <Parent>[],
    this.hasScrollBar = false,
  });

  @override
  Widget build(BuildContext context) {
    return hasScrollBar
        ? Scrollbar(child: _getTreeList(context))
        : _getTreeList(context);
  }

  Widget _getTreeList(BuildContext context) {
    return Column(
        children: <Widget>[for (var item in parentList) item]
          ..add(const SizedBox(height: 20)));
  }
}

/// # Parent widget
///
/// The [Parent] widget holds the [Parent.parent] widget and
/// [Parent.childList] which is a [List] of child widgets.
///
/// The [Parent] widget is wrapped around a [Column]. The [Parent.childList]
/// is collapsed by default. When clicked the child widget is expanded.
class Parent extends StatefulWidget {
  final Widget parent;
  final ChildList childList;
  Category? cate;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final ParentSelectChanged? callback;
  @override
  final Key? key;

  Parent({
    required this.parent,
    required this.childList,
    this.cate,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.min,
    this.callback,
    this.key,
  });

  @override
  ParentState createState() => ParentState();
}

class ParentState extends State<Parent> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: widget.mainAxisSize,
      crossAxisAlignment: widget.crossAxisAlignment,
      mainAxisAlignment: widget.mainAxisAlignment,
      children: <Widget>[
        InkWell(
          child: widget.parent,
          onTap: expand,
        ),
        _getChild(),
      ],
    );
  }

  void expand() {
    if (widget.childList.children.length < 1) {
      print("No further subitems");

      print(widget.cate);
      ProductModel.showList(
          context: context, cateId: widget.cate!.id, cateName: widget.cate!.name);
    }
    if (widget.callback != null) widget.callback!(_isSelected);
    setState(() {
      _isSelected = _toggleBool(_isSelected);
    });
  }

  bool _toggleBool(bool b) {
    return b ? false : true;
  }

  Widget _getChild() {
    return _isSelected ? widget.childList : Container();
  }
}

/// # ChildList widget
///
/// The [ChildList] widget holds a [List] of widget which will be displayed as
/// children of the [Parent] widget
class ChildList extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  ChildList({
    this.children = const <Widget>[],
    this.mainAxisSize = MainAxisSize.min,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children,
    );
  }
}
