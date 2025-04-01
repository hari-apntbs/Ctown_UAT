import 'dart:convert';

import 'package:ctown/common/config/payments.dart';
import 'package:ctown/common/constants/general.dart';
import 'package:ctown/common/constants/loading.dart';
import 'package:ctown/models/cart/cart_model.dart';
import 'package:ctown/models/entities/address.dart';
import 'package:ctown/models/index.dart';
import 'package:ctown/screens/settings/address_book.dart';

import 'package:ctown/services/index.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:ctown/screens/cart/cartProvider.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../common/constants/colors.dart';
import '../../generated/l10n.dart';

class AddressReviewScreen extends StatefulWidget {
  final Function? onNext;

  const AddressReviewScreen({Key? key, this.onNext}) : super(key: key);

  @override
  _AddressReviewScreenState createState() => _AddressReviewScreenState();
}

class _AddressReviewScreenState extends State<AddressReviewScreen> {
  Address? address;
  //
  List<String> addressid = [];
  getDiscountsIfAny() async {
    final LocalStorage storage = LocalStorage('store');
    final userJson = await storage.getItem(kLocalKey["userInfo"]!);
    final cartmodel = Provider.of<CartModel>(context, listen: false).address;
    String url =
        "https://up.ctown.jo/rest/V1/carts/mine/payment-information?address_id=${cartmodel?.id}&nocache=${DateTime.now().microsecond}${DateTime.now().microsecond}${DateTime.now().microsecond}";

    printLog("cvbxdfgsdfgertdf");
    printLog(url);
    // print(userJson["cookie"]);
    var response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer ' + userJson["cookie"],
    });
    if (response.statusCode == 200) {
      // print(response.body);
      var data = jsonDecode(response.body);

      Provider.of<CartProvider>(context, listen: false).setMagentoDiscount(
          double.parse(data["totals"]["discount_amount"].toString()));
      Provider.of<CartProvider>(context, listen: false).setCartGrandTotal(
          double.parse(data["totals"]["grand_total"].toString()));
      Provider.of<CartProvider>(context, listen: false).setBaseSubTotal(
          double.parse(data["totals"]["base_subtotal"].toString()));
    }
  }

  //
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      await getCustomerInfo();
      address =
          await Provider.of<CartModel>(context, listen: false).getAddress(Provider.of<AppModel>(context, listen: false).langCode ?? "en");
      if (address != null) {
        setState(() {});
      }
    });
  }

  Widget convertToCard(BuildContext context, Address address) {
    final s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 10.0),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "${s.streetName}:  ",
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            Flexible(
              child: Column(
                children: <Widget>[Text("${address.street}")],
              ),
            )
          ],
        ),
        const SizedBox(height: 4.0),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "${s.city}:  ",
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            Flexible(
              child: Column(
                children: <Widget>[Text("${address.city}")],
              ),
            )
          ],
        ),
        const SizedBox(height: 4.0),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "${s.stateProvince}:  ",
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            Flexible(
              child: Column(
                children: <Widget>[Text("${address.state}")],
              ),
            )
          ],
        ),
        const SizedBox(height: 4.0),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "${s.country}:  ",
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            Flexible(
              child: Column(
                children: <Widget>[Text("${address.country}")],
              ),
            ),
          ],
        ),
        // const SizedBox(height: 4.0),
        // Row(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: <Widget>[
        //     Text(
        //       "${s.zipCode}:  ",
        //       style: TextStyle(color: Theme.of(context).primaryColor),
        //     ),
        //     Flexible(
        //       child: Column(
        //         children: <Widget>[Text("${address.zipCode}")],
        //       ),
        //     )
        //   ],
        // ),
        const SizedBox(height: 10.0),
      ],
    );
  }

  void _onNext() {
    Provider.of<CartModel>(context, listen: false).setAddress(address);
    _loadShipping(beforehand: false);
    widget.onNext!();
  }

  void _loadShipping({bool beforehand = true}) {
    Services().widget?.loadShippingMethods(
        context, Provider.of<CartModel>(context, listen: false), beforehand);
  }

  getSavedStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var result = await prefs.getString('savedStore')!;

    return jsonDecode(result);
  }

  getCustomerInfo() async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    String? lang = Provider.of<AppModel>(context, listen: false).langCode;
    // TODO: implement getCustomerInfo
    //return super.getCustomerInfo(id);
    // var res = await http.get(MagentoHelper.buildUrl(domain, "customers/$id"),
    //     headers: {'Authorization': 'Bearer ' + accessToken});
    // return convert.jsonDecode(
    //     res.body); //User.fromMagentoJson(convert.jsonDecode(res.body), cookie);

    try {
      var store = await getSavedStore();

      String? id = lang == "en"
          ? store["store_en"]["id"]
          : store["store_ar"]["id"] ?? "";
      print("id1$id");
      final http.Response response = await http.get(
          Uri.parse("https://up.ctown.jo/index.php/rest/V1/customers/${userModel.user!.id}"),
          headers: {
            'Authorization': 'Bearer ' + 'h1oe6s65wunppubhvxq8hrnki9raobt1'
          });
      print("Sucess");
      var body = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        // print(body['addresses']);
        print("Outside Loop Success");
        var addressData = body['addresses'];
        print(body['addresses'].length);

        for (var addres in addressData) {
          print("Count Verify");
          print(addres);

          print("Count Verify");

          print("Inside LoopSuccess");
          print(addres['id']);

          if (addres['store_id'].toString() == id) {
            if (!addressid.contains(addres['id'])) {
              addressid.add(addres['id'].toString());
            }
          }
          print("addressid$addressid");
        }
        print("local");
        print(address!.id);
        print(address!.id.runtimeType);
        print('api');
        print(addressid);
        print(addressid.runtimeType);

        return body;
      } else {
        return null;
      }
    } catch (err) {
      print("error");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // String countryName = S.of(context).country;
    // if (_countryController.text.isNotEmpty) {
    //   try {
    //     countryName = picker.CountryPickerUtils.getCountryByIsoCode(
    //             _countryController.text)
    //         .name;
    //   } catch (e) {
    //     countryName = S.of(context).country;
    //   }
    // }

    if (address == null) {
      return Container(height: 100, child: kLoadingWidget(context));
    }
    return addressid.contains(address!.id) == true
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              convertToCard(context, address!),

              // InkWell(
              //   onTap: (){
              //     print(addressid.contains(address.id));
              //     print("vengades");
              //     print(addressid);
              //     print(address.id);

              //   },
              //   child: convertToCard(context, address)),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(
                  child: ButtonTheme(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0.0,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        ),
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.yellow,
                      ),
                      onPressed: () async {
                        if (Provider.of<CartProvider>(context, listen: false)
                                .cartGrandTotal ==
                            0.0) {
                          print(
                              Provider.of<CartProvider>(context, listen: false)
                                  .magentoPromotionsDiscount);
                          print(
                              Provider.of<CartProvider>(context, listen: false)
                                  .cartGrandTotal);

                          print("getting data");
                          await getDiscountsIfAny();
                        }
                        _onNext();
                      },
                      child: Text(
                        kPaymentConfig['EnableShipping'] as bool
                            ? S.of(context).continueToShipping.toUpperCase()
                            : S.of(context).continueToReview.toUpperCase(),
                      ),
                    ),
                  ),
                )
              ]),
            ],
          )
        : Container(
            child: ButtonTheme(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0.0,
                  backgroundColor: Provider.of<AppModel>(context, listen: false).darkTheme ? null : kGrey200
                ),
                onPressed: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => AddressBook()));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(
                      FontAwesomeIcons.solidAddressBook,
                      size: 16,
                    ),
                    const SizedBox(width: 10.0),
                    Text(
                      S.of(context).selectAddress.toUpperCase(),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
