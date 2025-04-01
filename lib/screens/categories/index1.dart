import 'dart:io';

import 'package:barcode_scan2/platform_wrapper.dart';
import 'package:flutter/animation.dart';
import 'package:ctown/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../common/constants.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart' show AppModel, Category, CategoryModel;
import '../../widgets/cardlist/index.dart';
import 'card1.dart';

class CategoriesScreen1 extends StatefulWidget {
  final String? layout;
  final List<dynamic>? categories;
  final List<dynamic>? images;
  final bool? showChat;
  final bool showSearch;

  CategoriesScreen1(
      {Key? key,
      this.layout,
      this.categories,
      this.images,
      this.showChat,
      this.showSearch = true})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CategoriesScreen1State();
  }
}

class CategoriesScreen1State extends State<CategoriesScreen1>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => false;
  String _scanBarcode = 'Search';
  late FocusNode _focus;
  bool isVisibleSearch = false;
  String? searchText;
  var textController = TextEditingController();

  late Animation<double> animation;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    animation = Tween<double>(begin: 0, end: 60).animate(controller);
    animation.addListener(() {
      setState(() {});
    });

    _focus = FocusNode();
    _focus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_focus.hasFocus && animation.value == 0) {
      controller.forward();
      setState(() {
        isVisibleSearch = true;
      });
    }
  }

  Future<void> onBarcodePressed(BuildContext context) async {
    var barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await BarcodeScanner.scan();
      if (barcodeScanRes.rawContent != '-1') {
        Navigator.of(context)
            .pushNamed(RouteList.homeSearch, arguments: barcodeScanRes.rawContent);
      }
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      if (barcodeScanRes.rawContent != '-1') _scanBarcode = barcodeScanRes.rawContent;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final category = Provider.of<CategoryModel>(context);
    final bool showChat = widget.showChat ?? false;
    // final screenSize = MediaQuery.of(context).size;
    // final isRotate = screenSize.width > screenSize.height;
    return Scaffold(
      
        // appBar: AppBar(
        //     automaticallyImplyLeading: false,
        //     titleSpacing: 0,
        //     backgroundColor: Colors.white,
        //     title: AppLocal(
        //       scanBarcode: 'Search',
        //     )),

        appBar: Platform.isAndroid
            ? AppBar(
                backgroundColor: Theme.of(context).colorScheme.surface,
                //  Colors.white,
                automaticallyImplyLeading: false,
                titleSpacing: 0,
                title: AppLocal(
                  scanBarcode: "Search",
                ),
              )
            : AppBar(
                backgroundColor: Theme.of(context).primaryColor,
                automaticallyImplyLeading: false,
                titleSpacing: 0,
                title: Container(
                  padding: EdgeInsets.only(top: 4),
                  height: 55,
                  width: double.infinity,
                  color: Color(0xffda0c15),
                  child: AppLocal2(
                    scanBarcode: "Search",
                  ),
                ),
              ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        // floatingActionButton: showChat
        //     ? SmartChat(
        //         margin: EdgeInsets.only(
        //           right: Provider.of<AppModel>(context, listen: false).langCode ==
        //                   'ar'
        //               ? 30.0
        //               : 0.0,
        //         ),
        //       )
        //     : Container(),
        body: Container(
         
          // color: Colors.yellow,
          child: ListenableProvider.value(
              value: category,
              child: Consumer<CategoryModel>(
                builder: (context, value, child) {
                  if (value.isLoading) {
          return kLoadingWidget(context);
                  }

                  if (value.categories == null) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
            child: Text(S.of(context).dataEmpty),
          );
                  }

                  List<Category>? categories = value.categories;

                  return SafeArea(
          child:
              //  [
              //   GridCategory.type,
              //   ColumnCategories.type,
              //   SideMenuCategories.type,
              //   SubCategories.type,
              //   SideMenuSubCategories.type
              // ].contains(widget.layout)
              //     ? Column(
              //         children: <Widget>[
              //           //renderHeader(),
              //           Expanded(
              //             child: renderCategories(categories),
              //           )
              //         ],
              //       )
              //     :

             
              ListView(
                children: <Widget>[
                  //  renderHeader(),
                  CardCategories1(categories)
                ],
              ),
                  );
                },
              ),
            ),
        )
        );
  }

  // Widget renderHeader() {
  //   final screenSize = MediaQuery.of(context).size;
  //   return Container(
  //     width: screenSize.width,
  //     child: FittedBox(
  //       fit: BoxFit.cover,
  //       child: Container(
  //         width:
  //             screenSize.width / (2 / (screenSize.height / screenSize.width)),
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Padding(
  //               child: Text(
  //                 S.of(context).category,
  //                 style: Theme.of(context)
  //                     .textTheme
  //                     .headline4
  //                     .copyWith(fontWeight: FontWeight.w600)
  //                     .apply(fontSizeFactor: 0.9),
  //               ),
  //               padding: const EdgeInsets.only(
  //                   top: 10, left: 10, bottom: 20, right: 10),
  //             ),
  //             if (widget.showSearch)
  //               IconButton(
  //                 icon: Icon(
  //                   Icons.search,
  //                   color: Theme.of(context).accentColor.withOpacity(0.6),
  //                 ),
  //                 onPressed: () {
  //                   Navigator.of(context).pushNamed(RouteList.categorySearch);
  //                 },
  //               ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget renderCategories(List<Category> categories) {
    switch (widget.layout) {
      case CardCategories1.type:
        return CardCategories1(categories);
      // case ColumnCategories.type:
      //   return ColumnCategories(categories);
      // case SubCategories.type:
      //   return SubCategories(categories);
      // case SideMenuCategories.type:
      //   return SideMenuCategories(categories);
      // case SideMenuSubCategories.type:
      //   return SideMenuSubCategories(categories);
      // case HorizonMenu.type:
      //   return HorizonMenu(categories);
      // case GridCategory.type:
      //   return GridCategory(
      //     categories,
      //     icons: widget.images,
      //   );
      default:
        return HorizonMenu(categories);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
