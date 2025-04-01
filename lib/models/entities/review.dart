import '../../common/constants.dart';
import '../../services/index.dart';

class Review {
  int? id;
  int? productId;
  String? name;
  String? email;
  String? title;
  String? review;
  late double priceRating;
  late double valueRating;
  late double qualityRating;
  double? rating;
  late DateTime createdAt;
  String? avatar;
  String? status;

  Review.fromJson(Map<String, dynamic> parsedJson) {
    id = parsedJson["id"];
    name = parsedJson["name"];
    email = parsedJson["email"];
    review = parsedJson["review"];
    rating = double.parse(parsedJson["rating"].toString());
    createdAt = parsedJson["date_created"] != null
        ? DateTime.parse(parsedJson["date_created"])
        : DateTime.now();
  }

  Review.fromOpencartJson(Map<String, dynamic> parsedJson) {
    id = parsedJson["review_id"] != null
        ? int.parse(parsedJson["review_id"])
        : 0;
    name = parsedJson["author"];
    email = parsedJson["author"];
    review = parsedJson["text"];
    rating =
        parsedJson["rating"] != null ? double.parse(parsedJson["rating"]) : 0.0;
    createdAt = parsedJson["date_added"] != null
        ? DateTime.parse(parsedJson["date_added"])
        : DateTime.now();
  }

  Review.fromMagentoJson(Map<String, dynamic> parsedJson) {
    id = int.parse(parsedJson["review_id"]);
    name = parsedJson["nickname"];
    email = parsedJson["email"];
    review = parsedJson["detail"];
    title = parsedJson["title"];
    rating = parsedJson["Rating"].toDouble() ?? 0.0;
    qualityRating = double.parse(parsedJson["Quality"]);
    valueRating = double.parse(parsedJson["Value"]);
    priceRating = double.parse(parsedJson["Price"]);
    createdAt = parsedJson["created_at"] != null
        ? DateTime.parse(parsedJson["created_at"])
        : DateTime.now();
  }

  Review.fromWCFMJson(Map<String, dynamic> parsedJson) {
    id = int.parse(parsedJson["ID"]);
    name = parsedJson["author_name"];
    email = parsedJson["author_email"];
    review = parsedJson["review_description"];
    avatar = parsedJson["author_image"];
    rating = double.parse(parsedJson["review_rating"]);
    createdAt = parsedJson["created"] != null
        ? DateTime.parse(parsedJson["created"])
        : DateTime.now();
  }

  Review.fromDokanJson(Map<String, dynamic> parsedJson) {
    id = parsedJson["id"];
    name = parsedJson["author"]["name"];
    email = parsedJson["author"]["email"];
    avatar = parsedJson["author"]["avatar"];
    review = parsedJson["content"];
    rating = double.parse("${parsedJson["rating"]}");
    createdAt = parsedJson["date"] != null
        ? DateTime.parse(parsedJson["date"])
        : DateTime.now();
  }

  Review.fromListing(Map<String, dynamic> parsedJson) {
    try {
      id = int.parse(parsedJson["id"].toString());

      name = parsedJson["author_name"] ?? '';

      email = parsedJson["author_email"] ?? '';
      try {
        review = parsedJson["content"]["rendered"] ?? '';
      } catch (e) {
        review = parsedJson["content"] ?? '';
      }
      rating = parsedJson["rating"] != null &&
              parsedJson["rating"].toString().isNotEmpty
          ? double.parse(parsedJson["rating"].toString())
          : 0.0;

      if (Config().type == 'listpro') {
        rating = parsedJson["lp_listingpro_options"]["rating"] != null &&
                parsedJson["lp_listingpro_options"]["rating"]
                    .toString()
                    .isNotEmpty
            ? double.parse(
                parsedJson["lp_listingpro_options"]["rating"].toString())
            : 0.0;
      }

      createdAt = parsedJson["date"] != null
          ? DateTime.parse(parsedJson["date"])
          : DateTime.now();

      status = parsedJson["status"] ?? 'approved';
    } catch (err) {
      printLog(' Review $err');
    }
  }

  @override
  String toString() => 'Category { id: $id  name: $name}';
}
