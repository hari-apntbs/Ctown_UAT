import 'package:algolia_helper_flutter/algolia_helper_flutter.dart';

class QuerySuggestion {
  QuerySuggestion(this.query, this.category, this.sku, this.categoryId, this.productName, this.highlighted);

  String query;
  HighlightedString? highlighted;
  String category;
  String sku;
  String categoryId;
  String productName;

  static QuerySuggestion fromJson(Hit hit) {
    final highlighted = hit.getProductHighlight(hit['_highlightResult']['product_name']['value'], inverted: true);
    return QuerySuggestion(hit['product_name'], hit['category_name'], hit['sku'], hit['category_id'], hit['product_name'], highlighted);
  }

  @override
  String toString() => query;
}
