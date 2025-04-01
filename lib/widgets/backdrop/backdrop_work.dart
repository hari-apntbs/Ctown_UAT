// Copyright 2018-present the Flutter authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../algolia/algolia_search.dart';
import '../../algolia/credentials.dart';
import '../../algolia/suggestion_repository.dart';
import '../../common/constants.dart';
import '../../models/index.dart';
import '../layout/adaptive.dart';
import 'backdrop_constants.dart';

const Cubic _kAccelerateCurve = Cubic(0.548, 0.0, 0.757, 0.464);
const Cubic _kDecelerateCurve = Cubic(0.23, 0.94, 0.41, 1.0);
const double _kPeakVelocityTime = 0.248210;
const double _kPeakVelocityProgress = 0.379146;

class _FrontLayer extends StatelessWidget {
  const _FrontLayer({Key? key, this.onTap, this.child, this.visible})
      : super(key: key);

  final VoidCallback? onTap;
  final Widget? child;
  final bool? visible;

  @override
  Widget build(BuildContext context) {
    double radius = visible! ? 0.0 : 16.0;

    return Material(
      elevation: 16.0,
      color: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(radius),
            topRight: Radius.circular(radius)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Container(
              height: visible! ? 10.0 : 40.0,
              alignment: AlignmentDirectional.centerStart,
            ),
          ),
          Expanded(
            child: child!,
          ),
        ],
      ),
    );
  }
}

class _BackdropTitle extends AnimatedWidget {
  final Function? onPress;
  final Widget frontTitle;
  final Widget backTitle;
  final bool? visible;

  const _BackdropTitle({
    Key? key,
    required Listenable listenable,
    this.onPress,
    this.visible,
    required this.frontTitle,
    required this.backTitle,
  })  : super(key: key, listenable: listenable);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = CurvedAnimation(
      parent: listenable as Animation<double>,
      curve: const Interval(0.0, 0.78),
    );

    return DefaultTextStyle(
      style:
          Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white),
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      child: Stack(
        children: <Widget>[
          Opacity(
            opacity: CurvedAnimation(
              parent: ReverseAnimation(animation),
              curve: const Interval(0.5, 1.0),
            ).value,
            child: FractionalTranslation(
              translation: Tween<Offset>(
                begin: Offset.zero,
                end: const Offset(0.5, 0.0),
              ).evaluate(animation),
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: backTitle,
              ),
            ),
          ),
          Opacity(
            opacity: CurvedAnimation(
              parent: animation,
              curve: const Interval(0.5, 1.0),
            ).value,
            child: FractionalTranslation(
              translation: Tween<Offset>(
                begin: const Offset(-0.25, 0.0),
                end: Offset.zero,
              ).evaluate(animation),
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: frontTitle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Builds a Backdrop.
///
/// A Backdrop widget has two layers, front and back. The front layer is shown
/// by default, and slides down to show the back layer, from which a user
/// can make a selection. The user can also configure the titles for when the
/// front or back layer is showing.
class CustomBackdrop extends StatefulWidget {
  final Widget frontLayer;
  final Widget backLayer;
  final Widget frontTitle;
  final Widget backTitle;
  final Widget? appbarCategory;
  final AnimationController controller;
  final Function? onSort;
  final Widget? listViewWidget;


  const CustomBackdrop({
    required this.frontLayer,
    required this.backLayer,
    required this.frontTitle,
    required this.backTitle,
    required this.controller,
    this.appbarCategory,
    this.onSort,
    this.listViewWidget
  });

  @override
  _CustomBackdropState createState() => _CustomBackdropState();
}

class _CustomBackdropState extends State<CustomBackdrop>
    with SingleTickerProviderStateMixin {
  String _mySelection = '';
  List data = ['weekly', 'monthly'];
  final GlobalKey _backdropKey = GlobalKey(debugLabel: 'Backdrop');
  late AnimationController _controller;
  late Animation<RelativeRect> _layerAnimation;
  String _selectSort = "date";
  bool userDarkColor = false;
  String currentStore = '';
  String searchIndex = '';
  bool showListView = true;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    userDarkColor = false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _frontLayerVisible {
    final AnimationStatus status = _controller.status;
    return status == AnimationStatus.completed ||
        status == AnimationStatus.forward;
  }

  bool shouldShowCategory = true;

  void _toggleBackdropLayerVisibility() {
    // Call setState here to update layerAnimation if that's necessary
    setState(() {
      _frontLayerVisible ? _controller.reverse() : _controller.forward();
      if (!_frontLayerVisible) {
        userDarkColor = true;
      }
    });
    Future.delayed(Duration(milliseconds: _frontLayerVisible ? 0 : 75), () {
      setState(() {
        shouldShowCategory = _frontLayerVisible;
      });
    });
  }

  // _layerAnimation animates the front layer between open and close.
  // _getLayerAnimation adjusts the values in the TweenSequence so the
  // curve and timing are correct in both directions.
  Animation<RelativeRect> _getLayerAnimation(Size layerSize, double layerTop) {
    Curve firstCurve; // Curve for first TweenSequenceItem
    Curve secondCurve; // Curve for second TweenSequenceItem
    double firstWeight; // Weight of first TweenSequenceItem
    double secondWeight; // Weight of second TweenSequenceItem
    Animation animation; // Animation on which TweenSequence runs

    if (_frontLayerVisible) {
      firstCurve = _kAccelerateCurve;
      secondCurve = _kDecelerateCurve;
      firstWeight = _kPeakVelocityTime;
      secondWeight = 1.0 - _kPeakVelocityTime;
      animation = CurvedAnimation(
        parent: _controller.view,
        curve: const Interval(0.0, 0.78),
      );
    } else {
      // These values are only used when the controller runs from t=1.0 to t=0.0
      firstCurve = _kDecelerateCurve.flipped;
      secondCurve = _kAccelerateCurve.flipped;
      firstWeight = 1.0 - _kPeakVelocityTime;
      secondWeight = _kPeakVelocityTime;
      animation = _controller.view;
    }

    return TweenSequence(
      <TweenSequenceItem<RelativeRect>>[
        TweenSequenceItem<RelativeRect>(
          tween: RelativeRectTween(
            begin: RelativeRect.fromLTRB(
              0.0,
              layerTop,
              0.0,
              layerTop - layerSize.height,
            ),
            end: RelativeRect.fromLTRB(
              0.0,
              layerTop * _kPeakVelocityProgress,
              0.0,
              (layerTop - layerSize.height) * _kPeakVelocityProgress,
            ),
          ).chain(CurveTween(curve: firstCurve)),
          weight: firstWeight,
        ),
        TweenSequenceItem<RelativeRect>(
          tween: RelativeRectTween(
            begin: RelativeRect.fromLTRB(
              0.0,
              layerTop * _kPeakVelocityProgress,
              0.0,
              (layerTop - layerSize.height) * _kPeakVelocityProgress,
            ),
            end: RelativeRect.fill,
          ).chain(CurveTween(curve: secondCurve)),
          weight: secondWeight,
        ),
      ],
    ).animate(animation as Animation<double>);
  }

  Widget _buildStack(BuildContext context, BoxConstraints constraints) {
    const double layerTitleHeight = 20;
    final Size layerSize = constraints.biggest;
    final double layerTop = layerSize.height - layerTitleHeight;
    _layerAnimation = _getLayerAnimation(layerSize, layerTop);
    _layerAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          if (_frontLayerVisible) {
            userDarkColor = false;
          }
        });
      }
    });
    return Stack(
      key: _backdropKey,
      fit: StackFit.expand,
      children: <Widget>[
        Container(
          color: Colors.white, //Theme.of(context).primaryColor,
          child: DefaultTextStyle.merge(
            style: const TextStyle(color: Colors.black),
            child: widget.backLayer,
          ),
        ),
        PositionedTransition(
          rect: _layerAnimation,
          child: _FrontLayer(
            onTap: _toggleBackdropLayerVisibility,
            child: showListView ? widget.frontLayer :widget.listViewWidget,
            visible: _frontLayerVisible,
          ),
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildMenuItem(
      IconData icon, String label, String value,
      [bool isSelect = false]) {
    final TextStyle menuItemStyle = TextStyle(
      fontSize: 13.0,
      color: isSelect
          ? Theme.of(context).primaryColor
          : Theme.of(context).colorScheme.secondary,
      height: 24.0 / 15.0,
    );
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: Icon(icon,
                color: isSelect
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).colorScheme.secondary,
                size: 17),
          ),
          Text(label, style: menuItemStyle),
        ],
      ),
    );
  }

  getSavedStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var result = await prefs.getString('savedStore') ?? "";
    var jsonData = jsonDecode(result);
    if(jsonData.length > 0){
      if(Provider.of<AppModel>(context, listen: false).langCode == "en") {
        currentStore = jsonData['store_en']['code'] ?? "";
      }
      else {
        currentStore = jsonData['store_ar']['code'] ?? "";
      }
      if(currentStore != "") {
        searchIndex = await Credentials.getSearchIndex(currentStore);
        printLog("==========search index $searchIndex");
      }
    }
    printLog(jsonData);
  }


  void _presentAutoComplete(BuildContext context) =>
      Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (_, __, ___) => Provider<SuggestionRepository>(
            create: (_) => SuggestionRepository(initialIndexName: searchIndex),
            dispose: (_, value) => value.dispose(),
            child: AlgoliaSearch(indexName: searchIndex)),
        fullscreenDialog: true,
      ));


  @override
  Widget build(BuildContext context) {
    const double _appBarCategoryHeight = 50.0;
    var appBar = AppBar(
      // brightness: Brightness.light,
      elevation: 0.0,
      titleSpacing: 0.0,
      bottom: widget.appbarCategory != null
          ? PreferredSize(
              preferredSize: Size(
                MediaQuery.of(context).size.width,
                shouldShowCategory ? _appBarCategoryHeight : 0,
              ),
              child: Container(
                height: shouldShowCategory ? _appBarCategoryHeight : 0,
                child: AnimatedOpacity(
                  opacity: _frontLayerVisible ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: BottomAppBar(
                    color: Theme.of(context).primaryColor,
                      elevation: 0.0, child: widget.appbarCategory),
                ),
              ),
            )
          : null,
      title: _BackdropTitle(
          listenable: _controller.view,
          onPress: _toggleBackdropLayerVisibility,
          frontTitle: widget.frontTitle,
          backTitle: widget.backTitle,
          visible: _frontLayerVisible),
      leading: !_frontLayerVisible
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios,
                  size: 20, color: Colors.white),
              color: Theme.of(context).colorScheme.secondary,
              onPressed: () {
                if (kIsWeb) {
                  eventBus.fire(const EventOpenCustomDrawer());
                  // LayoutWebCustom.changeStateMenu(true);
                }
                if (!_frontLayerVisible) {
                  _toggleBackdropLayerVisibility();
                  return;
                }
                Navigator.pop(context);
              },
            )
          : null,
      actions: <Widget>[
        IconButton(
          icon: const Icon(
            FontAwesomeIcons.search,
            color: Colors.white,
            size: 18,
          ),
          onPressed: () async {
            await getSavedStore();
            _presentAutoComplete(context);
            // Navigator.of(context)
            //     .pushNamed(RouteList.homeSearch, arguments: '');
          },
        ),
        // PopupMenuButton(
        //           icon:Icon(FontAwesomeIcons.filter, color: Colors.white, size: 18) ,
        //               // color: Colors.yellowAccent,
        //               elevation: 20,
        //               enabled: true,
        //               onSelected: (value) {
        //                 setState(() {
        //                    _mySelection = value;
        //                 });
        //                 // Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Brandfilter(categoryid: widget.product,optionid: _mySelection,)));
        //               },
        //               itemBuilder:(context) {
        //                 return data.map(( choice) {
        //                   return PopupMenuItem(
        //                     value: choice,
        //                     child: Text("$choice"),
        //                   );
        //                 }).toList();
        //               }
        //           ),
        IconButton(
          icon: Icon(
            // Provider.of<AppModel>(context, listen: false).productListLayout ==
            //         "list"
            //     ? FontAwesomeIcons.list
            //     : Icons.grid_view,
            showListView
                ? FontAwesomeIcons.list
                : Icons.grid_view,
            color: Colors.white,
            size: 18,
          ),
          onPressed: () {
            setState(() {
              showListView = !showListView;
            });
            // if (Provider.of<AppModel>(context, listen: false)
            //         .productListLayout ==
            //     "list") {
            //   return Provider.of<AppModel>(context, listen: false)
            //       .updateProductListLayout('listTile');
            // } else {
            //   return Provider.of<AppModel>(context, listen: false)
            //       .updateProductListLayout('list');
            // }
          },
        ),

        // if (!Config().isListingType())
        //   PopupMenuButton<String>(
        //     icon: const Icon(FontAwesomeIcons.sort,
        //         color: Colors.white, size: 18),
        //     onSelected: (String item) {
        //       _selectSort = item;
        //       widget.onSort(item);
        //     },
        //     itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
        //       _buildMenuItem(FontAwesomeIcons.calendarAlt, S.of(context).date,
        //           "date", _selectSort == "date"),
        //       _buildMenuItem(FontAwesomeIcons.star, S.of(context).featured,
        //           "featured", _selectSort == "featured"),
        //       _buildMenuItem(FontAwesomeIcons.percentage, S.of(context).onSale,
        //           "on_sale", _selectSort == "on_sale"),
        //     ],
        //   ),
        // IconButton(
        //     icon: AnimatedIcon(
        //       icon: AnimatedIcons.close_menu,
        //       progress: _controller,
        //     ),
        //     color: Colors.white,
        //     onPressed: _toggleBackdropLayerVisibility),

        IconButton(
            icon: Image.asset(
              "assets/images/filter.png",
            ),
            onPressed: _toggleBackdropLayerVisibility),
        //        Container(
        //         width: 20,
        //         height: 20,
        //         margin: const EdgeInsets.only(top: 3,right:15),
        //         child: Image.asset(
        //           "assets/images/filter.png",
        //           //fit: BoxFit.none,
        //
        //         ),
        //
        // ),
      ],
    );
    return Theme(
      data: Theme.of(
          context), //userDarkColor ? Theme.of(context).copyWith(primaryColor: kLightAccent1) : Theme.of(context),
      child: Scaffold(
        appBar: !isDisplayDesktop(context) ? appBar : null,
        body: Row(
          children: <Widget>[
            isDisplayDesktop(context)
                ? Container(
                    width: BackdropConstants.drawerWidth,
                    alignment: Alignment.topCenter,
                    padding: const EdgeInsets.only(bottom: 32),
                    color: Theme.of(context).primaryColor,
                    child: widget.backLayer,
                  )
                : const SizedBox(),
            Expanded(
              child: LayoutBuilder(
                builder: _buildStack,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomBackdrop2 extends StatefulWidget {
  final Widget frontLayer;
  final Widget backLayer;
  final Widget frontTitle;
  final Widget backTitle;
  final Widget? appbarCategory;
  final AnimationController controller;
  final Function? onSort;
  final Widget? filter;
  final Widget? listViewWidget;
  final Map<String, dynamic>? menuSetup;

  const CustomBackdrop2({
    required this.frontLayer,
    required this.backLayer,
    required this.frontTitle,
    required this.backTitle,
    required this.controller,
    this.appbarCategory,
    this.onSort,
    this.filter,
    this.listViewWidget,
    this.menuSetup
  })  : assert(frontLayer != null),
        assert(backLayer != null),
        assert(frontTitle != null),
        assert(backTitle != null),
        assert(controller != null);

  @override
  _CustomBackdrop2State createState() => _CustomBackdrop2State();
}

class _CustomBackdrop2State extends State<CustomBackdrop2>
    with SingleTickerProviderStateMixin {
  String _mySelection = '';
  List data = ['weekly', 'monthly'];
  final GlobalKey _backdropKey = GlobalKey(debugLabel: 'Backdrop');
  late AnimationController _controller;
  late Animation<RelativeRect> _layerAnimation;
  String _selectSort = "date";
  bool userDarkColor = false;

  String currentStore = '';
  String searchIndex = '';
  bool showListView = true;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    userDarkColor = false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _frontLayerVisible {
    final AnimationStatus status = _controller.status;
    return status == AnimationStatus.completed ||
        status == AnimationStatus.forward;
  }

  bool shouldShowCategory = true;

  void _toggleBackdropLayerVisibility() {
    // Call setState here to update layerAnimation if that's necessary
    setState(() {
      _frontLayerVisible ? _controller.reverse() : _controller.forward();
      if (!_frontLayerVisible) {
        userDarkColor = true;
      }
    });
    Future.delayed(Duration(milliseconds: _frontLayerVisible ? 0 : 75), () {
      setState(() {
        shouldShowCategory = _frontLayerVisible;
      });
    });
  }

  // _layerAnimation animates the front layer between open and close.
  // _getLayerAnimation adjusts the values in the TweenSequence so the
  // curve and timing are correct in both directions.
  Animation<RelativeRect> _getLayerAnimation(Size layerSize, double layerTop) {
    Curve firstCurve; // Curve for first TweenSequenceItem
    Curve secondCurve; // Curve for second TweenSequenceItem
    double firstWeight; // Weight of first TweenSequenceItem
    double secondWeight; // Weight of second TweenSequenceItem
    Animation animation; // Animation on which TweenSequence runs

    if (_frontLayerVisible) {
      firstCurve = _kAccelerateCurve;
      secondCurve = _kDecelerateCurve;
      firstWeight = _kPeakVelocityTime;
      secondWeight = 1.0 - _kPeakVelocityTime;
      animation = CurvedAnimation(
        parent: _controller.view,
        curve: const Interval(0.0, 0.78),
      );
    } else {
      // These values are only used when the controller runs from t=1.0 to t=0.0
      firstCurve = _kDecelerateCurve.flipped;
      secondCurve = _kAccelerateCurve.flipped;
      firstWeight = 1.0 - _kPeakVelocityTime;
      secondWeight = _kPeakVelocityTime;
      animation = _controller.view;
    }

    return TweenSequence(
      <TweenSequenceItem<RelativeRect>>[
        TweenSequenceItem<RelativeRect>(
          tween: RelativeRectTween(
            begin: RelativeRect.fromLTRB(
              0.0,
              layerTop,
              0.0,
              layerTop - layerSize.height,
            ),
            end: RelativeRect.fromLTRB(
              0.0,
              layerTop * _kPeakVelocityProgress,
              0.0,
              (layerTop - layerSize.height) * _kPeakVelocityProgress,
            ),
          ).chain(CurveTween(curve: firstCurve)),
          weight: firstWeight,
        ),
        TweenSequenceItem<RelativeRect>(
          tween: RelativeRectTween(
            begin: RelativeRect.fromLTRB(
              0.0,
              layerTop * _kPeakVelocityProgress,
              0.0,
              (layerTop - layerSize.height) * _kPeakVelocityProgress,
            ),
            end: RelativeRect.fill,
          ).chain(CurveTween(curve: secondCurve)),
          weight: secondWeight,
        ),
      ],
    ).animate(animation as Animation<double>);
  }

  Widget _buildStack(BuildContext context, BoxConstraints constraints) {
    const double layerTitleHeight = 20;
    final Size layerSize = constraints.biggest;
    final double layerTop = layerSize.height - layerTitleHeight;
    _layerAnimation = _getLayerAnimation(layerSize, layerTop);
    _layerAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          if (_frontLayerVisible) {
            userDarkColor = false;
          }
        });
      }
    });
    return Stack(
      key: _backdropKey,
      fit: StackFit.expand,
      children: <Widget>[
        Container(//Theme.of(context).primaryColor,
          child: DefaultTextStyle.merge(
            style: const TextStyle(color: Colors.black),
            child: widget.backLayer,
          ),
        ),
        PositionedTransition(
          rect: _layerAnimation,
          child: _FrontLayer(
            onTap: _toggleBackdropLayerVisibility,
            child: showListView ? widget.frontLayer :widget.listViewWidget,
            visible: _frontLayerVisible,
          ),
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildMenuItem(
      IconData icon, String label, String value,
      [bool isSelect = false]) {
    final TextStyle menuItemStyle = TextStyle(
      fontSize: 13.0,
      color: isSelect
          ? Theme.of(context).primaryColor
          : Theme.of(context).colorScheme.secondary,
      height: 24.0 / 15.0,
    );
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: Icon(icon,
                color: isSelect
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).colorScheme.secondary,
                size: 17),
          ),
          Text(label, style: menuItemStyle),
        ],
      ),
    );
  }

  getSavedStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var result = await prefs.getString('savedStore') ?? "";
    var jsonData = jsonDecode(result);
    if(jsonData.length > 0){
      if(Provider.of<AppModel>(context, listen: false).langCode == "en") {
        currentStore = jsonData['store_en']['code'] ?? "";
      }
      else {
        currentStore = jsonData['store_ar']['code'] ?? "";
      }
      if(currentStore != "") {
        searchIndex = await Credentials.getSearchIndex(currentStore);
        printLog("==========search index $searchIndex");
      }
    }
    printLog(jsonData);
  }

  void _presentAutoComplete(BuildContext context) =>
      Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (_, __, ___) => Provider<SuggestionRepository>(
            create: (_) => SuggestionRepository(initialIndexName: searchIndex),
            dispose: (_, value) => value.dispose(),
            child: AlgoliaSearch(indexName: searchIndex)),
        fullscreenDialog: true,
      ));

  @override
  Widget build(BuildContext context) {
    const double _appBarCategoryHeight = 50.0;
    var appBar = AppBar(
      // brightness: Brightness.light,
      elevation: 0.0,
      titleSpacing: 0.0,
      bottom: widget.appbarCategory != null
          ? PreferredSize(
              preferredSize: Size(
                MediaQuery.of(context).size.width,
                shouldShowCategory ? _appBarCategoryHeight : 0,
              ),
              child: Container(
                height: shouldShowCategory ? _appBarCategoryHeight : 0,
                child: AnimatedOpacity(
                  opacity: _frontLayerVisible ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: BottomAppBar(
                    color: Theme.of(context).primaryColor,
                      elevation: 0.0, child: widget.appbarCategory),
                ),
              ),
            )
          : null,
      title: _BackdropTitle(
          listenable: _controller.view,
          onPress: _toggleBackdropLayerVisibility,
          frontTitle: widget.frontTitle,
          backTitle: widget.backTitle,
          visible: _frontLayerVisible),
      leading: !_frontLayerVisible
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios,
                  size: 20, color: Colors.white),
              color: Theme.of(context).colorScheme.secondary,
              onPressed: () {
                if (kIsWeb) {
                  eventBus.fire(const EventOpenCustomDrawer());
                  // LayoutWebCustom.changeStateMenu(true);
                }
                if (!_frontLayerVisible) {
                  _toggleBackdropLayerVisibility();
                  return;
                }
                Navigator.pop(context);
              },
            )
          : null,
      actions: <Widget>[
        IconButton(
          icon: const Icon(
            FontAwesomeIcons.search,
            color: Colors.white,
            size: 18,
          ),
          onPressed: () async {
            await getSavedStore();
            _presentAutoComplete(context);
            // Navigator.of(context)
            //     .pushNamed(RouteList.homeSearch, arguments: '');
          },
        ),
        // PopupMenuButton(
        //           icon:Icon(FontAwesomeIcons.filter, color: Colors.white, size: 18) ,
        //               // color: Colors.yellowAccent,
        //               elevation: 20,
        //               enabled: true,
        //               onSelected: (value) {
        //                 setState(() {
        //                    _mySelection = value;
        //                 });
        //                 // Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Brandfilter(categoryid: widget.product,optionid: _mySelection,)));
        //               },
        //               itemBuilder:(context) {
        //                 return data.map(( choice) {
        //                   return PopupMenuItem(
        //                     value: choice,
        //                     child: Text("$choice"),
        //                   );
        //                 }).toList();
        //               }
        //           ),
        if (widget.filter != null) widget.filter!,
        IconButton(
          icon: Icon(
            // Provider.of<AppModel>(context, listen: false).productListLayout ==
            //         "list"
            //     ? FontAwesomeIcons.list
            //     : Icons.grid_view,
            showListView
                ? FontAwesomeIcons.list
                : Icons.grid_view,
            color: Colors.white,
            size: 18,
          ),
          onPressed: () {
            setState(() {
              showListView = !showListView;
            });
            // if (Provider.of<AppModel>(context, listen: false)
            //         .productListLayout ==
            //     "list") {
            //   return Provider.of<AppModel>(context, listen: false)
            //       .updateProductListLayout('listTile');
            // } else {
            //   return Provider.of<AppModel>(context, listen: false)
            //       .updateProductListLayout('list');
            // }
          },
        ),
        IconButton(
            icon: Image.asset(
              "assets/images/filter.png",
            ),
            onPressed: _toggleBackdropLayerVisibility),
        //        Container(
        //         width: 20,
        //         height: 20,
        //         margin: const EdgeInsets.only(top: 3,right:15),
        //         child: Image.asset(
        //           "assets/images/filter.png",
        //           //fit: BoxFit.none,
        //
        //         ),
        //
        // ),
      ],
    );
    return Theme(
      data: Theme.of(
          context), //userDarkColor ? Theme.of(context).copyWith(primaryColor: kLightAccent1) : Theme.of(context),
      child: Scaffold(
        appBar: !isDisplayDesktop(context) ? appBar : null,
        body: Row(
          children: <Widget>[
            isDisplayDesktop(context)
                ? Container(
                    width: BackdropConstants.drawerWidth,
                    alignment: Alignment.topCenter,
                    padding: const EdgeInsets.only(bottom: 32),
                    color: Theme.of(context).primaryColor,
                    child: widget.backLayer,
                  )
                : const SizedBox(),
            Expanded(
              child: LayoutBuilder(
                builder: _buildStack,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
