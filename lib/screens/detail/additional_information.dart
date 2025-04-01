import 'package:flutter/material.dart';

import '../../common/constants/loading.dart';
import '../../services/index.dart';

class AdditionalInformation extends StatefulWidget {
  //final List<ProductAttribute> listInfo;
  final String? productId;
  AdditionalInformation({required this.productId});

  @override
  _AdditionalInformationState createState() => _AdditionalInformationState();
}

class _AdditionalInformationState extends State<AdditionalInformation> {
  List<String>? listInfo;
  final services = Services();

  @override
  void initState() {
    super.initState();
    getListAdditionInfo();
  }

  void getListAdditionInfo() {
    //
    //
    services.getProductAddtionalInfo(widget.productId)?.then((onValue) {
      setState(() {
        listInfo = onValue;
      });
    });
    //
    //  MagentoApi().getProductAddtionalInfo(widget.productId).then((onValue) {
    //   setState(() {
    //     listInfo = onValue;
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    //final lengthInfo = listInfo.length;
    return Column(
      children: listInfo == null
          ? [Container(height: 80, child: kLoadingWidget(context))]
          : listInfo!.isEmpty
              ? [
                  Container(
                      // height: 80,
                      // child: Center(
                      //   child: Text(S.of(context).noReviews),
                      // ),
                      )
                ]
              : List.generate(
                  listInfo!.length,
                  (index) {
                    Color? color;
                    if (index.isEven && listInfo!.length > 2) {
                      color = Theme.of(context).scaffoldBackgroundColor;
                    }
                    return renderItem(
                      attribute: listInfo![index],
                      color: color,
                    );
                  },
                ),
    );
  }

  Widget renderItem({
    String? attribute,
    Color? color,
  }) {
    print("Attr $attribute");
    if (attribute == null) return const SizedBox();

    return Container(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    //attribute.name.toUpperCase(),
                    attribute,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            // const SizedBox(width: 8),
            // Expanded(
            //   flex: 6,
            //   child: attribute.name != "color"
            //       ? Align(
            //           alignment: Alignment.centerLeft,
            //           child: Text(attribute.options.join(", "),
            //               style: const TextStyle(
            //                 color: kGrey600,
            //                 fontSize: 14,
            //               )),
            //         )
            //       : Wrap(
            //           runSpacing: 8.0,
            //           spacing: 8.0,
            //           children: <Widget>[
            //             for (var i = 0; i < attribute.options.length; i++)
            //               tool_tip.Tooltip(
            //                 child: Container(
            //                   width: 25,
            //                   height: 25,
            //                   decoration: BoxDecoration(
            //                     borderRadius: BorderRadius.circular(40),
            //                     color: HexColor(
            //                       kNameToHex[attribute.options[i].toString().replaceAll(' ', "_").toLowerCase()],
            //                     ),
            //                   ),
            //                 ),
            //                 message: attribute.options[i] != null ? attribute.options[i] : '',
            //               )
            //           ],
            //         ),
            // ),
          ],
        ),
      ),
    );
  }
}
