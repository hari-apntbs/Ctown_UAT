import 'package:algolia_helper_flutter/algolia_helper_flutter.dart';
import 'package:ctown/algolia/query_suggestion.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../common/constants/general.dart';
import '../common/constants/loading.dart';
import '../common/constants/route_list.dart';
import '../models/app_model.dart';
import '../models/product_model.dart';
import '../services/index.dart';


class SuggestionRowView extends StatelessWidget {
  const SuggestionRowView({Key? key, required this.suggestion, this.onComplete})
      : super(key: key);

  final QuerySuggestion suggestion;
  final Function(String)? onComplete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: kLoadingWidget,
        );
        final _service = Services();
        var productData = await _service.searchProducts(
            name: suggestion.sku,
            categoryId: suggestion.categoryId,
            tag: "",
            attribute: "",
            attributeId: "",
            page: 1,
            lang: Provider.of<AppModel>(context, listen: false).langCode,
            isBarcode: false);
        Navigator.of(context, rootNavigator: true).pop();
        if(productData.length > 0){
          Navigator.of(context).pushNamed(
            RouteList.productDetail,
            arguments: productData[0],
          );
        }
        else {
          // FocusScope.of(context).unfocus();
          // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Something went wrong")));
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: kLoadingWidget,
          );
          final _service = Services();
          var productData = await _service.searchProducts(
              name: suggestion.productName.contains("-") ? suggestion.productName.substring(0, suggestion.productName.indexOf("-")) :
                    suggestion.productName,
              categoryId: suggestion.categoryId,
              tag: "",
              attribute: "",
              attributeId: "",
              page: 1,
              lang: Provider.of<AppModel>(context, listen: false).langCode,
              isBarcode: false);
          printLog(productData.length);
          var config = { "category": suggestion.categoryId, "screens": "Bakery"};
          // printLog(await SearchRepository().brandFacets.first);
          Navigator.of(context, rootNavigator: true).pop();
          ProductModel.showList(
            context: context,
            config: config,
            products: productData,
            showCountdown: false,
            countdownDuration: const Duration(milliseconds: 0),
          );
        }
      },
      child: Row(children: [
        const Icon(Icons.search),
        const SizedBox(
          width: 10,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: RichText(
                  text: TextSpan(
                      style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 15
                      ),
                      children: suggestion.highlighted!.toInlineSpans(
                          regularTextStyle: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold
                          ),
                          highlightedTextStyle: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold
                          )
                      ))),
            ),
            Expanded(
              child: Text(Provider.of<AppModel>(context, listen: false).langCode == "en" ? "In "+suggestion.category :" في"+suggestion.category,
                style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 10
                ),),
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          onPressed: () => onComplete?.call(suggestion.query),
          icon: const Icon(Icons.north_west),
        )
      ]),
    );
  }
}
