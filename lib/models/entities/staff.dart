class StaffBooking {
  int? id;
  String? displayName;
  String? email;
  String? username;

  StaffBooking({
    this.id,
    this.displayName,
    this.email,
    this.username,
  });

  StaffBooking.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '' as int?;
    displayName = json['displayname'] ?? '';
    email = json['email'] ?? '';
    username = json['username'] ?? '';
  }
}

class ProductBooking {
  int? id;
  String? name;
  String? staffCost;
  String? staffQty;
  String? price;

  ProductBooking.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    staffCost = json['staff_cost'];
    staffQty = json['staff_qty'];
    price = json['price'];
  }
}
