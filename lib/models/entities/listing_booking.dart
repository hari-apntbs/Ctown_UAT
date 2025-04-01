import 'dart:convert';

class ListingBooking {
  String? title;
  String? featured_image;
  String? status;
  String? price;
  String? createdDate;
  String? orderId;
  String? orderStatus;
  Map<String, String?> adults = {};
  List<String?> services = [];
  ListingBooking(
      this.title,
      this.featured_image,
      this.status,
      this.price,
      this.createdDate,
      this.adults,
      this.services,
      this.orderId,
      this.orderStatus);

  ListingBooking.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    featured_image = json['featured_image'];
    status = json['status'];
    price = json['price'];
    createdDate = json['created'];
    orderId = json['order_id'];
    orderStatus = json['order_status'] ?? '';
    var commentJson = jsonDecode(json['comment']);
    if (commentJson['adults'] != null) {
      adults['adults'] = commentJson['adults'];
    }
    if (commentJson['tickets'] != null) {
      adults['tickets'] = commentJson['tickets'];
    }
    if (commentJson['service'] is bool) {
      return;
    }
    for (var item in commentJson['service']) {
      services.add(item['service']['name']);
    }
  }
}
