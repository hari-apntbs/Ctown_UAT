import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:ctown/common/config/dynamic_link.dart';
import 'package:ctown/common/constants/general.dart';
import 'package:ctown/screens/home/recipe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:instasoft/widgets/skeleton_widget/skeleton_widget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecipeDetails extends StatefulWidget {
  final config;
  final text;
  final productid;
  final title;

  const RecipeDetails({Key? key, this.config, this.text, this.productid, this.title})
      : super(key: key);

  @override
  _RecipeDetailsState createState() => _RecipeDetailsState();
}

class _RecipeDetailsState extends State<RecipeDetails> {
  getSavedStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var result = await prefs.getString('savedStore')!;

    return jsonDecode(result);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double widthHeight = size.height;
    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
                backgroundColor: Theme.of(context).colorScheme.surface,
                elevation: 1.0,
                expandedHeight: kIsWeb ? 0 : widthHeight * 0.3,
                pinned: true,
                floating: false,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.3),
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(context).primaryColor,
                      ),
                      onPressed: () {
                        // Provider.of<ProductModel>(context, listen: false)
                        //     .changeProductVariation(null);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                actions: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.3),
                      child: IconButton(
                          icon: Icon(
                            Icons.share,
                            color: Theme.of(context).primaryColor,
                            // color: Color(0xfff7e813),
                          ),
                          // icon: const Icon(Icons.share, size: 19),
                          // color: Colors.orange,
                          // onPressed: () => ProductDetailScreen.showMenu(context, widget.product),

                          onPressed: () async {
                            var store1 = await getSavedStore();
                            var storeCode = store1["store_ar"]["code"];

                            //Navigator.of(context).pop();
                            Share.share(
                              firebaseDynamicLinkConfig["link"].toString() +
                                  "index.php/$storeCode/blog/post/${widget.title}/",
                              // "index.php/qatar_barwa_branch_en/catalog/product/view/id/${product.id}",
                              // https://up.ctown.jo/index.php/qatar_barwa_branch_en/catalog/product/view/id/23344/
                              sharePositionOrigin: Rect.fromLTWH(
                                  0, 0, size.width, size.height / 2),
                            );
                            print("ffff");

                            print("ffff");

                            print("ffff");
                          }),
                    ),
                  ),
                ],
                flexibleSpace: Container(
                  child: CachedNetworkImage(
                    imageUrl: widget.config,
                    placeholder: (context, url) => Skeleton(
                      height: widthHeight * 0.3,
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    width: 100,
                    fit: BoxFit.fitWidth,
                  ),

                  // Image.network(widget.config,
                  // height:widthHeight * 0.3 ,
                  // // scale:1,
                  // ),
                )),
            SliverList(
              delegate: SliverChildListDelegate(
                <Widget>[
                  const SizedBox(
                    height: 2,
                  ),
                  Html(data: widget.text),
                  // Text('Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industrys standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMa,Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of "de Finibus Bonorum et Malorum" (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of "de Finibus Bonorum et Malorum" (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance,Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of "de Finibus Bonorum et Malorum" (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance'),

                  SizedBox(height: 20),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              Recipe(config: widget.productid)));
                      print(widget.productid);
                    },
                    child: Container(
                      height: 50,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25.0),
                          color: Colors.yellow),
                      child: Center(
                        child: Text(
                          // S.of(context).addToCart.toUpperCase(),
                          'Add Ingredient',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
