
import 'package:localstorage/localstorage.dart';
import '../../common/constants.dart';

class Address {
  String? firstName;
  String? lastName;
  String? email;
  String? street;
  String? apartment;
  String? block;
  String? city;
  String? state;
  String? country;
  String? phoneNumber;
  String? zipCode;
  String? mapUrl;
  String? id;
  String? state_id;
  String? landmark;
//
  String? buildingNo;
  String? zoneNo;
  String? streetNo;
  String? unitNo;

//
  Address(
      {this.firstName,
      this.lastName,
      this.email,
      this.street,
      this.apartment,
      this.block,
      this.city,
      this.state,
      this.country,
      this.phoneNumber,
      this.zipCode,
      this.mapUrl,
      this.id,
      this.state_id,
      this.landmark,

      //

      this.streetNo,
      this.zoneNo,
      this.buildingNo,
      this.unitNo
      //
      });

  Address.fromJson(Map<String, dynamic> parsedJson) {
    firstName = parsedJson["first_name"];
    lastName = parsedJson["last_name"];
    apartment = parsedJson["company"];
    street = parsedJson["street"];
    block = parsedJson["address_2"];
    city = parsedJson["city"];
    state = parsedJson["state"];
    country = parsedJson["country"];
    email = parsedJson["email"];
    id = parsedJson["id"];
    zoneNo = parsedJson["zone_no"];
    final alphanumeric = RegExp(r'^[a-zA-Z0-9]+$');
    if (alphanumeric.hasMatch(firstName!)) {
      phoneNumber = firstName;
    }
    //phoneNumber = parsedJson["phone"];
    zipCode = parsedJson["postcode"];
  }

  Address.fromMagentoJson(Map<String, dynamic> parsedJson) {
    firstName = parsedJson["firstname"];
    lastName = parsedJson["lastname"];
    street = parsedJson["street"][0];
    streetNo = parsedJson["street_no"];
    block = parsedJson["flat_no"];
    city = parsedJson["city"];
    state = parsedJson["region"] is String
        ? parsedJson["region"]
        : parsedJson["region"]["region"];
    country = parsedJson["country_id"];
    email = parsedJson["email"];
    phoneNumber = parsedJson["telephone"];
    zipCode = parsedJson["postcode"];
    id = parsedJson["id"].toString();
    zoneNo = parsedJson["zone_no"];
    apartment = parsedJson["building_name"];
    landmark = parsedJson["landmark"];
    buildingNo = parsedJson["building_no"];
    unitNo = parsedJson["unit_no"];
    landmark = parsedJson["landmark"];
  }

  Map<String, dynamic> toJson() {
    return {
      "first_name": firstName,
      "last_name": lastName,
      "street": street ?? '',
      "address_2": block ?? '',
      "company": apartment ?? '',
      "city": city,
      "state": state,
      "country": country,
      "email": email,
      "id": id,
      "phone": phoneNumber,
      "postcode": zipCode,
      "mapUrl": mapUrl,
    };
  }

  Address.fromLocalJson(Map<String, dynamic> json) {
    try {
      firstName = json['first_name'];
      lastName = json['last_name'];
      street = json['street'];
      block = json['address_2'];
      apartment = json['company'];
      city = json['city'];
      state = json['state'];
      country = json['country'];
      email = json['email'];
      id = json['id'];
      phoneNumber = json['phone'];
      zipCode = json['postcode'];
      mapUrl = json['mapUrl'];
      landmark = json['landmark'];
    } catch (e) {
      printLog(e.toString());
    }
  }

  Map<String, dynamic> toMagentoJson() {
    return {
      "address": {
        "region": state,
        "country_id": country,
        // "region_id": state_id,
        "street": [
          street,
          //'$apartment${(block?.isEmpty ?? true) ? '' : ' - $block'}',
        ],
        "postcode": zipCode,
        "city": city,
        "firstname": firstName,
        "lastname": lastName,
        "email": email,
        // "id": id,
        "telephone": phoneNumber,
        "same_as_billing": 1,
        // "landmark": landmark,
        // "building_name": apartment,
        // "flat_no": block
      }
    };
  }

  Map<String, dynamic> toOpencartJson() {
    return {
      "zone_id": state,
      "country_id": country,
      "street": street ?? '',
      "address_2": block ?? '',
      "company": apartment ?? '',
      "postcode": zipCode,
      "city": city,
      "id": id,
      "firstname": firstName,
      "lastname": lastName,
      "email": email,
      "telephone": phoneNumber
    };
  }

  bool isValid() {
    return (firstName?.isNotEmpty ?? false) &&
        (lastName?.isNotEmpty ?? false) &&
        (email?.isNotEmpty ?? false) &&
        (street?.isNotEmpty ?? false) &&
        (city?.isNotEmpty ?? false) &&
        (state?.isNotEmpty ?? false) &&
        (country?.isNotEmpty ?? false) &&
        (phoneNumber?.isNotEmpty ?? false);
  }

  Map<String, String?> toJsonEncodable() {
    return {
      "first_name": firstName,
      "last_name": lastName,
      "street": street ?? '',
      "address_2": block ?? '',
      "company": apartment ?? '',
      "city": city,
      "state": state,
      "country": country,
      "id": id,
      "email": email,
      "phone": phoneNumber,
      "postcode": zipCode
    };
  }

  Future<void> saveToLocal() async {
    final LocalStorage storage = LocalStorage("address");
    try {
      final ready = await storage.ready;
      if (ready) {
        await storage.setItem('', toJson());
      }
    } catch (err) {
      printLog(err);
    }
  }

  Address.fromShopifyJson(Map<String, dynamic> json) {
    try {
      firstName = json['firstName'];
      lastName = json['lastName'];
      street = json['street'];
      block = json['address2'];
      apartment = json['company'];
      city = json['city'];
      state = json['pronvice'];
      country = json['country'];
      email = json['email'];
      id = json['id'];
      phoneNumber = json['phone'];
      zipCode = json['zip'];
      mapUrl = json['mapUrl'];
    } catch (e) {
      printLog(e.toString());
    }
  }

  Map<String, dynamic> toShopifyJson() {
    return {
      "address": {
        "province": state,
        "country": country,
        "street": street,
        "address2": block,
        "company": apartment,
        "zip": zipCode,
        "city": city,
        "id": id,
        "firstName": firstName,
        "lastName": lastName,
        "phone": phoneNumber,
      }
    };
  }

  Address.fromOpencartOrderJson(Map<String, dynamic> json) {
    try {
      firstName = json['shipping_firstname'];
      lastName = json['shipping_lastname'];
      street = json['street'];
      block = json['shipping_address_2'];
      apartment = json['shipping_company'];
      city = json['shipping_city'];
      state = json['shipping_zone'];
      country = json['shipping_country'];
      email = json['email'];
      id = json['id'];
      phoneNumber = json['telephone'];
      zipCode = json['shipping_postcode'];
    } catch (e) {
      printLog(e.toString());
    }
  }

  @override
  String toString() {
    return street! + country! + city!;
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Address &&
        o.block == block &&
        o.apartment == apartment &&
        o.street == street &&
        o.city == city &&
        o.state == state &&
        o.country == country;
  }

  @override
  int get hashCode {
    return firstName.hashCode ^
        lastName.hashCode ^
        email.hashCode ^
        street.hashCode ^
        apartment.hashCode ^
        block.hashCode ^
        city.hashCode ^
        state.hashCode ^
        country.hashCode ^
        phoneNumber.hashCode ^
        zipCode.hashCode ^
        mapUrl.hashCode ^
        id.hashCode ^
        state_id.hashCode ^
        landmark.hashCode;
  }
}

class ListAddress {
  List<Address> list = [];

  toJsonEncodable() {
    return list.map((item) {
      return item.toJsonEncodable();
    }).toList();
  }
}
