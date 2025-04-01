class CardDetails {
  String? id;
  String? customerId;
  String? pan;
  String? expiry;
  String? cardholdername;
  String? scheme;
  String? cardtoken;
  String? created;

  CardDetails(
      {this.id,
      this.customerId,
      this.pan,
      this.expiry,
      this.cardholdername,
      this.scheme,
      this.cardtoken,
      this.created});

  CardDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    customerId = json['customer_id'];
    pan = json['pan'];
    expiry = json['expiry'];
    cardholdername = json['cardholdername'];
    scheme = json['scheme'];
    cardtoken = json['cardtoken'];
    created = json['created'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['customer_id'] = customerId;
    data['pan'] = pan;
    data['expiry'] = expiry;
    data['cardholdername'] = cardholdername;
    data['scheme'] = scheme;
    data['cardtoken'] = cardtoken;
    data['created'] = created;
    return data;
  }
}
