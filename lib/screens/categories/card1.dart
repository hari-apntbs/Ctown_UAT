import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../common/constants.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart' show Category, ProductModel;
import '../base.dart';
import '../../widgets/common/skeleton.dart';
import '../../widgets/common/tree_view.dart';

class CardCategories1 extends StatefulWidget {
  static const String type = 'card';

  final List<Category>? categories;

  CardCategories1(this.categories);

  @override
  _StateCardCategories1 createState() => _StateCardCategories1();
}

class _StateCardCategories1 extends BaseScreen<CardCategories1> {
  ScrollController controller = ScrollController();
  late double page;

  @override
  void initState() {
    page = 0.0;
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    controller.addListener(() {
      setState(() {
        page = _getPage(controller.position, screenSize.width * 0.30 + 10);
      });
    });
  }

  bool hasChildren(id) {
    return widget.categories!.where((o) => o.parent == id).toList().isNotEmpty;
  }

  double _getPage(ScrollPosition position, double width) {
    return position.pixels / width;
  }

  List<Category> getSubCategories(id) {
    return widget.categories!.where((o) => o.parent == id).toList();
  }

  Widget getChildCategoryList(category) {
    return ChildList(
      children: [
        SubItem(
          category,
          seeAll: S.of(context).seeAll,
        ),
        for (var category in getSubCategories(category.id))
          Parent(
              parent: SubItem(category),
              childList: ChildList(
                children: [
                  for (var cate in getSubCategories(category.id))
                    Parent(
                        cate: cate,
                        parent: SubItem(cate, level: 1),
                        childList: ChildList(
                          children: [
                            for (var _cate in getSubCategories(cate.id))
                              Parent(
                                cate: _cate,
                                parent: SubItem(_cate, level: 2),
                                //                 // ),
                                childList: ChildList(children: []),
                              ),
                          ],
                        ))
                ],
              )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final _categories =
        widget.categories!.where((item) => item.parent == '0').toList();

    return SingleChildScrollView(
      controller: controller,
      child: Row(children: 
        List.generate(
          _categories.length,
          (index) {
            return CategoryCardItem(
      _categories[index],
      offset: page - index,
            );
          },
        ),
        )
      
      );
  }
}

class CategoryCardItem extends StatelessWidget {
  final Category category;
  final bool hasChildren;
  final offset;
 

  CategoryCardItem(this.category, {this.hasChildren = false, this.offset});

  /// Render category Image support caching on ios/android
  /// also fix loading on Web
  Widget renderCategoryImage(BuildContext context) {
    if (category.image!.contains('http') && kIsWeb) {
      return FadeInImage.memoryNetwork(
        image: '$kImageProxy${category.image}',
        fit: BoxFit.cover,
        width: MediaQuery.of(context).size.width*0.33,
        height: MediaQuery.of(context).size.height*0.35,
        placeholder: kTransparentImage,
      );
    }

    return category.image!.contains('http')
        ? CachedNetworkImage(
            imageUrl: category.image!,
            fit: BoxFit.cover,
            alignment: Alignment(
              0.0,
              (offset >= -1 && offset <= 1)
                  ? offset
                  : (offset > 0)
                      ? 1.0
                      : -1.0,
            ),
            // fadeInCurve: Curves.easeIn,
            imageBuilder:
                (BuildContext context, ImageProvider<dynamic> imageProvider) {
              return CircleAvatar(
                radius: 30,
                
                backgroundColor: Colors.white,
                              child: Center(
                                child: 
                               Padding(padding:EdgeInsets.all(1.5),
                              
                              child:  Image(
                    // width: MediaQuery.of(context).size.width*0.17,
                    // height: MediaQuery.of(context).size.height*0.08,
                       width: 60,
                       height:60,
                    image: imageProvider as ImageProvider<Object>,
                    fit: BoxFit.contain, 
                  ),),)
              );
            },
            placeholder: (context, url) => Skeleton(
              width:60,
              height:60
            ),
          )
        : Image.asset(
            category.image!,
            fit: BoxFit.cover,
            width: MediaQuery.of(context).size.width*0.18,
            height: MediaQuery.of(context).size.height*0.08,
            alignment: Alignment(
              0.0,
              (offset >= -1 && offset <= 1)
                  ? offset
                  : (offset > 0)
                      ? 1.0
                      : -1.0,
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Column(
      children: [
        GestureDetector(
          onTap: hasChildren
              ? null
              : () {
                  ProductModel.showList(
                    context: context,
                    cateId: category.id,
                    cateName: category.name,
                  );
                },
          child: Container(
              //  height: screenSize.height* 0.35,
               padding: const EdgeInsets.only(left: 10,),
               margin: const EdgeInsets.only(top:3,bottom: 3),
               child: Stack(
                 children: <Widget>[
                   ClipRRect(
                    //  shape: BoxShape.circle,
                    
                       borderRadius: const BorderRadius.all(Radius.circular(350.0)),
                       child: renderCategoryImage(context)),
                   Container(
                     margin: EdgeInsets.only(bottom:1),
                     width: 60,
                     height: 60,
                     decoration: BoxDecoration(
                       shape: BoxShape.circle,
                       color: const Color.fromRGBO(0, 0, 0, 0.05),
                      //  borderRadius: BorderRadius.circular(250),
                     ),
                     child:null,
                   ),
                   
                 ],
               ),
          ),
         
        ),
         Container(
            height: screenSize.height* 0.03,
           width: screenSize.width* 0.20,
           margin: EdgeInsets.only(left:3),
                       child: Center(
                         child: Text(
                           category.name!.toUpperCase(),textAlign: TextAlign.center,
                           style:  TextStyle(
                               color:  Theme.of(context)
                    .colorScheme.secondary,
                               
                               fontSize: 8,
                               fontWeight: FontWeight.w600),
                         ),
                       ),
                     ),
      ],
    );
  }
}

class SubItem extends StatelessWidget {
  final Category category;
  final String seeAll;
  final int level;

  SubItem(this.category, {this.seeAll = '', this.level = 0});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      width: screenSize.width*0.35,
      child: FittedBox(
        fit: BoxFit.cover,
        child: Container(
          width:
              screenSize.width / (2 / (screenSize.height / screenSize.width)),
          // height: 35,
          height: 45,
          decoration: BoxDecoration(
            // color: Colors.red,
            border: Border(
              top: BorderSide(
                width: 0.5,
                color: Theme.of(context)
                    .colorScheme.secondary
                    .withOpacity(level == 0 && seeAll == '' ? 0.2 : 0),
              ),
            ),
          ),
          // padding: const EdgeInsets.symmetric(vertical: 5),
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(width: 15.0),
              for (int i = 1; i <= level; i++)
                Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Container(
                    width: 20.0,
                    margin:
                        const EdgeInsets.only(top: 10.0, right: 4, bottom: 10),
                    height: 2,
                    color: Theme.of(context).primaryColor.withOpacity(0.0),
                    // decoration: BoxDecoration(
                    //   border: Border(
                    //     bottom: BorderSide(
                    //       width: 1.5,
                    //       color: Theme.of(context).primaryColor.withOpacity(0.5),
                    //     ),
                    //   ),
                    // ),
                  ),
                ),
              Expanded(
                child: Text(
                  seeAll != '' ? seeAll : category.name!,
                  style: TextStyle(
                      fontSize: level == 0 ? 12.6 : 12,
                      fontWeight: level == 0
                          ? FontWeight.w700
                          : level == 1
                              ? FontWeight.w600
                              : FontWeight.w300

                      // fontFamily: 'raleway'
                      ),
                ),
              ),
              // InkWell(
              //   onTap: () {
              //     ProductModel.showList(
              //         context: context,
              //         cateId: category.id,
              //         cateName: category.name);
              //   },
              //   child: Text(
              //     S.of(context).nItems(category.totalProduct.toString()),
              //     style: TextStyle(
              //         fontSize: 14, color: Theme.of(context).primaryColor),
              //   ),
              // ),
              IconButton(
                icon: const Icon(
                  Icons.keyboard_arrow_right,
                  // Icons.alarm,
                  size: 28,
                ),
                onPressed: () {
                  // print("Fgdfgdfg");
                  ProductModel.showList(
                      context: context,
                      cateId: category.id,
                      cateName: category.name);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
