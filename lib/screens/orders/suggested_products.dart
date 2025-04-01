import 'package:ctown/screens/orders/suggested_product_model.dart';
import 'package:ctown/screens/orders/suggested_product_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ctown/common/tools.dart';
import 'package:ctown/models/app_model.dart';
import 'package:ctown/common/constants/loading.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ctown/generated/l10n.dart';

class OutOfStockProductItem extends StatefulWidget {
  final ProductDetail? data;
  final index;
  final ondelete;
  String? productType;
  final orderId;
  String? outOfStockproductPrice;
  final parentIndex;
  final outOfStockproductId;
  final outOfStockBarcode;
  final widgetKey;
  final outOfStockQty;
  OutOfStockProductItem({
    this.data,
    this.index,
    this.parentIndex,
    this.outOfStockproductPrice,
    this.widgetKey,
    this.outOfStockQty,
    this.ondelete,
    this.productType,
    this.orderId,
    this.outOfStockBarcode,
    this.outOfStockproductId,
  });
  @override
  _OutOfStockProductItemState createState() => _OutOfStockProductItemState();
}

class _OutOfStockProductItemState extends State<OutOfStockProductItem> {
  late Size screenSize;

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(top: 12, bottom: 5),
      child: Card(
        child: Container(
          padding: EdgeInsets.only(left: 6, right: 6),
          color: Colors.grey[100],
          height: 170,
          child:
              // Text(widget.data.toString())
              Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(children: [
                    Container(
                        height: 120,
                        width: 100,
                        // color: Colors.black,
                        child: Image.network(widget.data!.productImage!
                                .contains("http")
                            ? widget.data!.productImage!
                            : "https://up.ctown.jo/pub/media/catalog/product" +
                                widget.data!.productImage!)),
                    Text(
                      Provider.of<AppModel>(context, listen: false).langCode ==
                              "ar"
                          ? "إنتهى من المخزن"
                          : "OUT OF STOCK",
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    )
                  ]),
                  SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        // height: 50,
                        // color: Colors.red,
                        width: screenSize.width * 0.50,
                        child: Text(
                          // !(widget.data.productName.length < 25)
                          //     ? widget.data.productName
                          //     : widget.data.productName + "\n",
                          widget.data!.productName!,
                          overflow: TextOverflow.visible,
                          style: TextStyle(),
                        ),
                      ),
                      Text("AED " +
                          double.parse(widget.data!.productPrice!)
                              .toStringAsFixed(1)),
                      Text(
                        "Barcode :" + widget.data!.barcode!,
                        style: TextStyle(fontSize: 12),
                      ),
                      Text(
                        "Out of Stock Qty : " + widget.outOfStockQty,
                        style: TextStyle(fontSize: 13),
                      ),
                      ElevatedButton(
                          onPressed: () async {
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                        title: Text(Provider.of<AppModel>(
                                                        context,
                                                        listen: false)
                                                    .langCode ==
                                                "ar"
                                            ? "هل أنت متأكد"
                                            : "Are You Sure"),
                                        content: Text(Provider.of<AppModel>(
                                                        context,
                                                        listen: false)
                                                    .langCode ==
                                                "ar"
                                            ? "هل تريد إزالة المنتج"
                                            : "Do you want to remove the product"),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(false),
                                            child: Text(S.of(context).no),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              showDialog(
                                                barrierDismissible: false,
                                                context: context,
                                                builder: kLoadingWidget,
                                              );
                                              var result =
                                                  await widget.ondelete(
                                                      ofsProductId: widget
                                                          .outOfStockproductId,
                                                      ofsProductBarcode: widget
                                                          .outOfStockBarcode,
                                                      orderId: widget.orderId,
                                                      ofsProductPrice: widget
                                                          .outOfStockproductPrice,
                                                      // productType: "Grocery",
                                                      productType:
                                                          widget.productType,
                                                      ofsQty:
                                                          // 1
                                                          int.parse(widget
                                                              .outOfStockQty)
                                                      //  selectedItem.selectedQtty

                                                      );
                                              if (result["success"] != null) {
                                                widget.widgetKey.currentState
                                                    .showSnackBar(SnackBar(
                                                  content:
                                                      Text(result["message"]),
                                                ));
                                                Navigator.of(context,
                                                        rootNavigator: true)
                                                    .pop();

                                                if (result["success"] == 1) {
                                                  Provider.of<SuggestedProductProvider>(
                                                          context,
                                                          listen: false)
                                                      .removeAtIndex(
                                                          widget.parentIndex);
                                                }

                                                Navigator.of(context).pop(true);
                                              }
                                            },
                                            child: Text(S.of(context).yes),
                                          )
                                        ]));

                            /*   showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: kLoadingWidget,
                            );
                            var result = await widget.ondelete(
                                ofsProductId: widget.outOfStockproductId,
                                ofsProductBarcode: widget.outOfStockBarcode,
                                orderId: widget.orderId,
                                ofsProductPrice: widget.outOfStockproductPrice,
                                // productType: "Grocery",
                                productType: widget.productType,
                                ofsQty:
                                    // 1
                                    int.parse(widget.outOfStockQty)
                                //  selectedItem.selectedQtty

                                );
                            if (result["success"] != null) {
                              Navigator.of(context, rootNavigator: true).pop();

                              if (result["success"] == 1) {
                                Provider.of<SuggestedProductProvider>(context,
                                        listen: false)
                                    .removeAtIndex(widget.parentIndex);
                              }
                              Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text(result["message"]),
                              ));
                            }*/
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(20.0)),
                          ),
                          child: Text(
                            Provider.of<AppModel>(context, listen: false)
                                        .langCode ==
                                    "ar"
                                ? "يزيل"
                                : 'Remove',
                            style: TextStyle(color: Colors.white),
                          )),
                      //
                    ],
                  ),
                  // Column(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  // Text("AED " +
                  //     double.parse(widget.data.productPrice).toStringAsFixed(1))
                  //
                  //   ],
                  // )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SuggestedReplacementProductItem extends StatefulWidget {
  final ProductDetail? data;
  String? outOfStockQty;
  String? productType;
  final int? parentIndex;
  final orderId;
  final outOfStockproductId;
  final outOfStockBarcode;
  final outOfStockPrice;
  final replacementPrice;
  final startPicking;
  final index;
  final onPressed;
  SuggestedReplacementProductItem(
      {this.data,
      this.index,
      this.outOfStockPrice,
      this.replacementPrice,
      this.startPicking,
      this.productType,
      this.orderId,
      this.outOfStockBarcode,
      this.outOfStockproductId,
      this.parentIndex,
      this.outOfStockQty,
      this.onPressed});
  @override
  _SuggestedReplacementProductItemState createState() =>
      _SuggestedReplacementProductItemState();
}

class _SuggestedReplacementProductItemState
    extends State<SuggestedReplacementProductItem> {
  late Size screenSize;

  int qty = 1;
  @override
  Widget build(BuildContext context) {
    final currency = Provider.of<AppModel>(context).currency;
    final currencyRate = Provider.of<AppModel>(context).currencyRate;
    screenSize = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(top: 5, bottom: 5),
      child: Card(
        child: Container(
          padding: EdgeInsets.only(left: 6, right: 6),
          // color: Colors.grey,
          height: 190,
          child: Row(
            children: [
              Checkbox(
                activeColor: Theme.of(context).primaryColor,
                value: Provider.of<SuggestedProductProvider>(
                  context,
                ).selectedReplacementProductsData[widget.parentIndex!]
                    ["replacement_products"][widget.index]["isSelected"],
                onChanged: (val) {
                  Provider.of<SuggestedProductProvider>(context, listen: false)
                      .selectReplacementItem(widget.parentIndex, widget.index);
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 130,
                    width: 100,
                    // color: Colors.black,
                    child: CachedNetworkImage(
                      placeholder: (context, url) =>
                          Image.asset('assets/images/placeholderr.png'),
                      imageUrl: widget.data!.productImage!.contains("http")
                          ? widget.data!.productImage!
                          : "https://up.ctown.jo/pub/media/catalog/product" +
                              widget.data!.productImage!,
                    ),
                  ),

                  // Image.network(widget.data.productImage
                  //         .contains("http")
                  //     ? widget.data.productImage
                  //     : "https://up.ctown.jo/pub/media/catalog/product" +
                  //         widget.data.productImage)),

                  SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        // height: 50,
                        // color: Colors.red,
                        width: screenSize.width * 0.40,
                        child: Text(
                          // !(widget.data.productName.length < 25)
                          //     ? widget.data.productName
                          //     : widget.data.productName + "\n",
                          widget.data!.productName!.length > 35
                              ? widget.data!.productName!.substring(0, 34)
                              : widget.data!.productName!,
                          overflow: TextOverflow.visible,
                          style: TextStyle(),
                        ),
                      ),
                      Text(Tools.getCurrencyFormatted(
                          double.parse(widget.data!.productPrice!)
                              .toStringAsFixed(1),
                          currencyRate,
                          currency: currency)!),
                      Text(
                        "Barcode :" + widget.data!.barcode!,
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      /*   Provider.of<SuggestedProductProvider>(context,
                                          listen: false)
                                      .selectedReplacementProductsData[
                                  widget.parentIndex]["replacement_products"]
                              [widget.index]["isSelected"]
                          ? Row(children: [
                              Text(
                                'Qty :',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                              Row(children: [
                                IconButton(
                                    icon: Icon(
                                      Icons.remove,
                                      size: 16,
                                    ),
                                    onPressed: () {
                                      // if (qty > 1) {
                                      //   qty--;
                                      //   Provider.of<SuggestedProductProvider>(
                                      //           context,
                                      //           listen: false)
                                      //       .selectReplacementItemQuantity(
                                      //           widget.parentIndex,
                                      //           widget.index,
                                      //           qty);
                                      //   setState(() {});
                                      // }
                                      if (Provider.of<SuggestedProductProvider>(
                                                  context,
                                                  listen: false)
                                              .selectedReplacementProductsData[
                                                  widget.parentIndex]
                                                  ["replacement_products"]
                                                  [widget.index]["item"]
                                              .selectedQtty >
                                          1) {
                                        Provider.of<SuggestedProductProvider>(
                                                context,
                                                listen: false)
                                            .reduceselectReplacementItemQuantity(
                                                widget.parentIndex,
                                                widget.index);
                                      }
                                    }),
                                Container(
                                  height: 30,
                                  width: 18,
                                  child: Center(
                                      child: Text(
                                          Provider.of<SuggestedProductProvider>(
                                    context,
                                  )
                                              .selectedReplacementProductsData[
                                                  widget.parentIndex]
                                                  ["replacement_products"]
                                                  [widget.index]["item"]
                                              .selectedQtty
                                              .toString())),
                                ),
                                IconButton(
                                    icon: Icon(
                                      Icons.add,
                                      size: 16,
                                    ),
                                    onPressed: () {
                                      if (Provider.of<SuggestedProductProvider>(
                                                  context,
                                                  listen: false)
                                              .selectedReplacementProductsData[
                                                  widget.parentIndex]
                                                  ["replacement_products"]
                                                  [widget.index]["item"]
                                              .selectedQtty <
                                          int.parse(widget.outOfStockQty)) {
                                        Provider.of<SuggestedProductProvider>(
                                                context,
                                                listen: false)
                                            .addselectReplacementItemQuantity(
                                                widget.parentIndex,
                                                widget.index);
                                        // setState(() {});
                                      }
                                    }),
                              ])
                            ])
                          : Container(),*/
                      Provider.of<SuggestedProductProvider>(context,
                                          listen: false)
                                      .selectedReplacementProductsData[
                                  widget.parentIndex!]["replacement_products"]
                              [widget.index]["isSelected"]
                          ? Center(
                              child: ElevatedButton(
                                  onPressed: () async {
                                    // print(Provider.of<SuggestedProductProvider>(
                                    //         context,
                                    //         listen: false)
                                    //     .selectedReplacementProductsData[widget
                                    //         .parentIndex]["outofstock_product"]
                                    //     .productName);
                                    // Provider.of<SuggestedProductProvider>(
                                    //         context,
                                    //         listen: false)
                                    //     .removeAtIndex(Provider.of<
                                    //                     SuggestedProductProvider>(
                                    //                 context,
                                    //                 listen: false)
                                    //             .selectedReplacementProductsData[
                                    //         widget.parentIndex]);
                                    // print(Provider.of<SuggestedProductProvider>(
                                    //         context,
                                    //         listen: false)
                                    //     .selectedReplacementProductsData[widget
                                    //         .parentIndex]["outofstock_product"]
                                    //     .productName);
                                    List oldList =
                                        Provider.of<SuggestedProductProvider>(
                                                context,
                                                listen: false)
                                            .selectedReplacementProductsData;
                                    print(oldList[widget.parentIndex!]
                                            ["outofstock_product"]
                                        .productName);
                                    ProductDetail? selectedItem;
                                    Provider.of<SuggestedProductProvider>(
                                            context,
                                            listen: false)
                                        .selectedReplacementProductsData[
                                            widget.parentIndex!]
                                            ["replacement_products"]
                                        .forEach((e) {
                                      if (e["isSelected"]) {
                                        selectedItem = e["item"];
                                      }
                                    });
                                    print(" isnt happening");
                                    showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: kLoadingWidget,
                                    );
                                    var result = await widget.onPressed(
                                        ofsProductId:
                                            widget.outOfStockproductId,
                                        ofsProductBarcode:
                                            widget.outOfStockBarcode,
                                        orderId: widget.orderId,
                                        ofsProductPrice: widget.outOfStockPrice,
                                        replacementPrice:
                                            widget.data!.productPrice,
                                        startPicking: widget.startPicking,

                                        // productType: "Grocery",
                                        productType: widget.productType,
                                        replacementId: selectedItem!.productId,
                                        replacementBarcode:
                                            selectedItem!.barcode,
                                        qty:
                                            // 1
                                            int.parse(widget.outOfStockQty!)
                                        //  selectedItem.selectedQtty

                                        );
                                    if (result["success"] != null) {
                                      Navigator.of(context, rootNavigator: true)
                                          .pop();

                                      if (result["success"] == 1) {
                                        Provider.of<SuggestedProductProvider>(
                                                context,
                                                listen: false)
                                            .removeAtIndex(widget.parentIndex);
                                      }
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text(result["message"]),
                                      ));
                                    }

                                    // setState(() {});
                                    // setState(() {});
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        new BorderRadius.circular(20.0)),
                                  ),
                                  child: Text(
                                    Provider.of<AppModel>(context,
                                                    listen: false)
                                                .langCode ==
                                            "ar"
                                        ? 'يحل محل'
                                        : 'Replace',
                                    style: TextStyle(color: Colors.white),
                                  )),
                            )
                          : Container()

                      //
                    ],
                  ),
                  // Column(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  // Text("AED " +
                  //     double.parse(widget.data.productPrice).toStringAsFixed(1))
                  //
                  //   ],
                  // )

                  //
                ],
              ),
              //
            ],
          ),
        ),
      ),
    );
  }
}
