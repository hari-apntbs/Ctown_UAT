///-----store LISTING-----///
class DataMapping {
  static final DataMapping _instance = DataMapping._internal();

  factory DataMapping() => _instance;

  DataMapping._internal();

  String? kProductPath;
  String? kCategoryPath;
  late Map<String, dynamic> ProductDataMapping;
  late Map<String, dynamic> CategoryDataMapping;
  late Map<String, dynamic> kCategoryImages;
  // this taxonomies are use for display the Listing detail
  Map<String, dynamic>? kTaxonomies;
  Map<String, dynamic>? kListingReviewMapping;

  void setMapping(
      String productPath,
      String categoryPath,
      Map<String, dynamic> productDataMapping,
      Map<String, dynamic> categoryDataMapping,
      Map<String, dynamic> categoryImages,
      Map<String, dynamic> taxonomies,
      Map<String, dynamic> listingReviewMapping) {
    kProductPath = productPath;
    kCategoryPath = categoryPath;
    ProductDataMapping = Map<String, dynamic>.from(productDataMapping);
    CategoryDataMapping = Map<String, dynamic>.from(categoryDataMapping);
    kCategoryImages = Map<String, dynamic>.from(categoryImages);
    kTaxonomies = Map<String, dynamic>.from(taxonomies);
    kListingReviewMapping = Map<String, dynamic>.from(listingReviewMapping);
  }
}
