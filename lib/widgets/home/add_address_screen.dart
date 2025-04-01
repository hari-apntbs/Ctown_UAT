import 'dart:convert';
import 'dart:convert' as convert;
import 'dart:developer';
import 'dart:io';

import 'package:country_pickers/country_pickers.dart' as picker;
import 'package:ctown/models/app_model.dart';
import 'package:flutter/material.dart';
/*import 'package:flutter_hms_gms_availability/flutter_hms_gms_availability.dart';*/
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:instasoft/widgets/dropdown/dropdown_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../frameworks/magento/services/magento.dart';
import '../../generated/l10n.dart';
import '../../models/address_model.dart';
import '../../models/entities/address.dart';
import '../../models/entities/country.dart';
import '../../models/entities/states.dart';
import '../../models/index.dart'
    show Address, CartModel, Country, User, UserModel;
import '../../services/index.dart';
import '../common/place_picker.dart';

class AddAddressScreen extends StatefulWidget {
  final bool? isEdit;
  final List<Address>? savedAddresses;

  const AddAddressScreen({Key? key, this.isEdit, this.savedAddresses})
      : super(key: key);
  @override
  _AddAddressScreenState createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late bool _firstTimePress;
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _blockController = TextEditingController();
  final TextEditingController _phoneNoController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _apartmentController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();

  // lat
  final TextEditingController _buildingNo = TextEditingController();
  final TextEditingController _streetNo = TextEditingController();
  final TextEditingController _zoneNo = TextEditingController();
  final TextEditingController _unitNo = TextEditingController();

  //
  bool isSavePressed = false;
  final _streetNode = FocusNode();
  final _blockNode = FocusNode();
  final _phoneNoNode = FocusNode();
  final _stateNode = FocusNode();
  final _countryNode = FocusNode();
  final _apartmentNode = FocusNode();
  final _cityNode = FocusNode();
  final _landmarkNode = FocusNode();
  final _lastNameNode = FocusNode();

  //
  final _streetNoNode = FocusNode();
  final _zoneNode = FocusNode();
  final _unitNode = FocusNode();
  final _buildingNoNode = FocusNode();

  //

  // bool _isAddressFromMap = false;
  bool deliverableArea = true;
  Address address = Address();
  List<Country>? countries = [];
  List<dynamic> states = [];
  List<Area>? cities = [];
  Future? myFuture;
  LocationResult? latlan;
  String? lat1, long1;
  String? messageContent = "";
  //   void _onNext() {
  //   {
  //     if (_formKey.currentState.validate()) {
  //       _formKey.currentState.save();
  //       Provider.of<CartModel>(context, listen: false).setAddress(address);
  //       //widget.onNext();
  //     }
  //   }
  // }

  getFlatDetails(addressId) async {
    // print(addressId);
    Map body = {"address_id": "$addressId"};
    var response = await http.post(Uri.parse("https://up.ctown.jo/api/viewaddress.php"),
        body: jsonEncode(body));
    print("view address url");
    print("body ${{"address_id": "$addressId"}}");
    print(response.statusCode);
    print(response.body);
    print("%%%%%%%%%%%%%%");
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body)["addresses"][0];
      print("==============");
      print(responseBody["building_name"]);
      _apartmentController.text = responseBody["building_name"];

      _blockController.text = responseBody["flat_no"];
      _landmarkController.text = responseBody["landmark"];
      //
      _buildingNo.text = responseBody["building_no"];
      _streetNo.text = responseBody["street_no"];
      _unitNo.text = responseBody["unit_no"];
      _zoneNo.text = responseBody["zone_no"];
      //
    }
    // print(addressId);

    // var response = await Dio().post("https://up.ctown.jo/api/viewaddress.php",
    //     queryParameters: {"address_id": "$addressId"});
    // print("view address url");
    // print("body ${{"address_id": "$addressId"}}");
    // print(response.statusCode);
    // print(response.data);
    // print("%%%%%%%%%%%%%%");
    // if (response.statusCode == 200) {
    //   var responseBody = json.decode(response.data)["addresses"][0];
    //   print("==============");
    //   print(responseBody["building_name"]);
    //   _apartmentController.text = responseBody["building_name"];

    //   _blockController.text = responseBody["flat_no"];
    //   _landmarkController.text = responseBody["landmark"];
    // }
  }

  @override
  void dispose() {
    _cityController.dispose();
    _streetController.dispose();
    _blockController.dispose();
    _phoneNoController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _apartmentController.dispose();
    _landmarkController.dispose();

    _lastNameNode.dispose();
    // _phoneNode.dispose();
    // _emailNode.dispose();
    _cityNode.dispose();
    _streetNode.dispose();
    _blockNode.dispose();
    _phoneNoNode.dispose();
    _stateNode.dispose();
    _countryNode.dispose();
    _apartmentNode.dispose();
    _landmarkNode.dispose();

    super.dispose();
  }

  /*bool gms, hms;*/
  @override
  void initState() {
    super.initState();

    /*FlutterHmsGmsAvailability.isGmsAvailable.then((value) {
      setState(() {
        gms = value;
      });
    });

    FlutterHmsGmsAvailability.isHmsAvailable.then((value) {
      setState(() {
        hms = value;
      });
    });*/

    myFuture = Future.delayed(
      Duration.zero,
          () async {
        final addressValue = await Provider.of<CartModel>(context,
            listen: false)
            .getAddress(Provider.of<AppModel>(context, listen: false).langCode);
        if (addressValue != null) {
          setState(() {
            if (widget.isEdit!) {
              print("if");
              address = addressValue;
              getFlatDetails(address.id);
              print(_apartmentController.text);
              print(_landmarkController.text);
            } else {
              print("else");
              address.firstName = addressValue.firstName;
              address.lastName = addressValue.lastName;
              address.apartment = addressValue.apartment;
              address.landmark = addressValue.landmark;
              address.phoneNumber = addressValue.phoneNumber;
              address.email = addressValue.email;
              address.country = addressValue.country;
            }
            _cityController.text = address.city!;
            _streetController.text = address.street!;
            _phoneNoController.text = address.phoneNumber!;
            _stateController.text = address.state!;
            _blockController.text = address.block!;
            _apartmentController.text = address.apartment!;
            _landmarkController.text = address.landmark!;
          });
        } else {
          User? user = Provider.of<UserModel>(context, listen: false).user;
          setState(() {
            address = Address(country: kPaymentConfig["DefaultCountryISOCode"] as String?);
            if (kPaymentConfig["DefaultStateISOCode"] != null) {
              address.state = kPaymentConfig["DefaultStateISOCode"] as String?;
              address.state_id = kPaymentConfig["DefaultStateISOCode"] as String?;
            }
            _countryController.text = address.country!;
            _stateController.text = address.state!;
            if (user != null) {
              address.firstName = user.firstName;
              address.lastName = user.lastName;
              address.email = user.email;
            }
          });
        }
        countries = await Services().widget?.loadCountries(context);
        var country = countries!.firstWhere(
                (element) =>
            element.id == address.country ||
                element.code == address.country,
            orElse: () => countries!.first);
        if (country == null) {
          if (countries!.isNotEmpty) {
            country = countries![0];
            address.country = countries![0].code;
          } else {
            country = Country.fromConfig(address.country, null, null, []);
          }
        }
        //setState(() {
        _countryController.text = country.code!;
        //});
        states = await Services().widget?.loadStatenCities() ?? [];
        setState(() {});
      },
    );
    // widget.isEdit?getFlatDetails():"";
  }

  checkToSave() {
    //final LocalStorage storage = LocalStorage("address");
    List<Address> _list =
        Provider.of<AddressModel>(context, listen: false).listAddress; //[];
    try {
      for (var local in _list) {
        if (local != address) continue;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: Text(S.of(context).yourAddressExistYourLocal),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    S.of(context).ok,
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          },
        );
        return false;
      }
    } catch (err) {
      printLog(err);
    }
    return true;
  }

  Widget renderStateInput() {
    if (states.isNotEmpty) {
      List<DropdownMenuItem<DropDownWidgetItem>> items = [];
      states.forEach((item) {
        items.add(
          DropdownMenuItem<DropDownWidgetItem>(
            value: DropDownWidgetItem(value: item.name, id: item.id),
            child: Text(
              item.name,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        );
      });
      // String value;
      // if (states.firstWhere((o) => o.id == address.state, orElse: () => null) !=
      //     null) {
      //   value = address.state;
      // }
      // if (address.state == null ||
      //     states.firstWhere((o) => o.id == address.state || o.name == address.state, orElse: () => null) == null) {
      //   address.state = items[0].value;
      //   address.state_id = items[0].id;
      // }
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).primaryColor),
            borderRadius: const BorderRadius.all(Radius.circular(10.0))),
        child: DropdownButtonHideUnderline(
          child: DropdownButtonFormField<DropDownWidgetItem>(
            items: items,
            value: address.state != null
                ? items
                .firstWhere(
                  (element) =>
              element.value!.value == address.state ||
                  element.value!.id == address.state,
              orElse: () => items.first,
            )
                .value
                : null,
            onChanged: (item) {
              setState(() {
                address.state = item!.value;
                address.state_id = item.id;
                _stateController.text = item.value;
              });
            },
            decoration: InputDecoration(
              labelText: S.of(context).stateProvince,
              labelStyle: Theme.of(context).textTheme.bodyMedium,
              isDense: true,
              filled: true,
              fillColor: Colors.transparent,
            ),
            icon: const Icon(Icons.keyboard_arrow_down_sharp),
            isExpanded: true,
          ),
        ),
      );
    } else {
      return TextFormField(
        controller: _stateController,
        style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 14),
        validator: (val) {
          return val!.isEmpty ? S.of(context).stateIsRequired : null;
        },
        decoration: InputDecoration(labelText: S.of(context).stateProvince,
        labelStyle: Theme.of(context).textTheme.bodyMedium,),
        onSaved: (String? value) {
          address.state = value;
          address.state_id = value;
          _stateController.text = value!;
        },
      );
    }
  }

  Widget renderCityInput() {
    final langCode = Provider.of<AppModel>(context, listen: false).langCode ?? "en";
    if (states.isNotEmpty) {
      cities = states.firstWhere((state) => state.name == address.state).area;

      if (cities!.isEmpty) {
        return Container(
            height: 55,
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).primaryColor),
                borderRadius: const BorderRadius.all(Radius.circular(10.0))),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 12.0),
                  child: Text('No City to show'),
                ),
              ],
            ));
      }

      List<DropdownMenuItem<DropDownWidgetItem>> items = [];
      cities!.forEach((item) {
        items.add(DropdownMenuItem<DropDownWidgetItem>(
          value: DropDownWidgetItem(
            value: item.areaName!,
          ),
          child: Text(
            item.areaName!,
            style:
            TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.secondary),
          ),
        ));
      });

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).primaryColor),
            borderRadius: const BorderRadius.all(Radius.circular(10.0))),
        child: DropdownButtonHideUnderline(
          child: DropdownButtonFormField<DropDownWidgetItem>(
            items: items,
            value: address.city != null
                ? items
                .firstWhere(
                  (element) =>
              element.value!.value == address.city ||
                  element.value!.id == address.city,
              orElse: () => items.first,
            )
                .value
                : null,
            onChanged: (item) async {
              setState(() {
                address.city = item!.value;
                _cityController.text = item.value;
              });
              /*if (hms == true) {
                printLog("State: ${address.state}");
                printLog("City: ${address.city}");

                if (address.state != null && address.city != null) {
                  deliverableArea = true;
                  await matchDeliveryHwi1(address.state, address.city);
                  setState(() {
                    _stateController.text = statename.toString().trim();
                    _cityController.text = cityname.toString().trim();
                  });
                  if (!await _isAddressServiceableHwi(
                      address.state, address.city)) {
                    deliverableArea = false;
                    setState(() {});
                    printLog("1 $deliverableArea");
                    return showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        content: Text(messageContent),
                        actions: [
                          RaisedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              S.of(context).ok,
                            ),
                          )
                        ],
                      ),
                    );
                  }
                }
              }*/
            },
            decoration: InputDecoration(
              labelText: langCode == "en"? "City" :"المدينة",
              labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
              isDense: true,
              filled: true,
              fillColor: Colors.transparent,
            ),
            icon: const Icon(Icons.keyboard_arrow_down_sharp),
            isExpanded: true,
          ),
        ),
      );
    } else {
      return TextFormField(
        style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 14),
        controller: _cityController,
        focusNode: _cityNode,
        validator: (val) {
          return val!.isEmpty ? S.of(context).cityIsRequired : null;
        },
        decoration: InputDecoration(
            labelText: langCode == "en"? "City" :"المدينة",
            labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
                borderRadius: const BorderRadius.all(Radius.circular(10.0)))),
        textInputAction: TextInputAction.next,
        onSaved: (String? value) {
          address.city = value;
          _cityController.text = value!;
        },
      );
    }
  }

  // Future<void> saveDataToLocal() async {
  //   final LocalStorage storage = LocalStorage("address");
  //   List<Address> _list = [];
  //   _list.add(address);
  //   try {
  //     final ready = await storage.ready;
  //     if (ready) {
  //       var data = storage.getItem('data');
  //       if (data != null) {
  //         (data as List).forEach((item) {
  //           final add = Address.fromLocalJson(item);
  //           _list.add(add);
  //         });
  //       }
  //       await storage.setItem(
  //           'data',
  //           _list.map((item) {
  //             return item.toJsonEncodable();
  //           }).toList());
  //       await showDialog(
  //           context: context,
  //           builder: (BuildContext context) {
  //             return AlertDialog(
  //               title: Text(S.of(context).youHaveBeenSaveAddressYourLocal),
  //               actions: <Widget>[
  //                 FlatButton(
  //                   child: Text(
  //                     S.of(context).ok,
  //                     style: TextStyle(color: Theme.of(context).primaryColor),
  //                   ),
  //                   onPressed: () {
  //                     Navigator.of(context).pop();
  //                   },
  //                 )
  //               ],
  //             );
  //           });
  //     }
  //   } catch (err) {
  //     printLog(err);
  //   }
  // }

  Future<void> saveDataToRemote(String? latitude, String? longitude) async {
    try {
      printLog(latitude);
      printLog(longitude);
      UserModel userModel = Provider.of<UserModel>(context, listen: false);
      if (widget.isEdit!) {
        await Services().serviceApi?.editAddress(
            address,
            userModel.user,
            Provider.of<AppModel>(context, listen: false).langCode,
            latitude,
            longitude);
      } else {
        await Services().serviceApi?.addAddress(
            address,
            userModel.user,
            Provider.of<AppModel>(context, listen: false).langCode,
            latitude,
            longitude);
      }
      await Provider.of<AddressModel>(context, listen: false).getMyAddress(
          userModel: userModel,
          lang: Provider.of<AppModel>(context, listen: false).langCode);
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: Text(S.of(context).youHaveBeenSaveAddressYourLocal),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    S.of(context).ok,
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    } catch (e) {
      printLog(e);
    }
  }

  getSavedStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var result = await prefs.getString('savedStore')!;

    return jsonDecode(result);
  }

  getSavedStoregroupid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var result = await prefs.getString('setSavedStoregroupid')!;

    return jsonDecode(result);
  }

  Future<bool> _isAddressServiceable(LocationResult locationResult) async {
    // if (states != null) {
    //   Data state = states.firstWhere((element) => element.name == locationResult.city, orElse: () => null);
    //   if (state == null) {
    //     return false;
    //   }
    //   final index = state.area.indexWhere((element) => element.areaName == locationResult.locality);
    //   if (index == -1) {
    //     return false;
    //   }
    //   return true;
    // }
    // return false;
    inspect(locationResult);
    print("match");
    bool isServiceable = await MagentoApi().matchDelivery(
        locationResult.latLng!.latitude,
        locationResult.latLng!.longitude,
        Provider.of<AppModel>(context, listen: false).langCode);
    return isServiceable;
  }

  String? cityname;
  String? statename;

  Future<bool> matchDelivery1(LocationResult latLng) async {
    try {
      print("runing");
      var store = await getSavedStore();
      String? lang = Provider.of<AppModel>(context, listen: false).langCode;

      String? id = lang == "en"
          ? store["store_en"]["id"]
          : store["store_ar"]["id"] ?? "";
      var store1 = await getSavedStoregroupid();
      print(
        convert.jsonEncode({
          "lat": latLng.latLng!.latitude.toString(),
          "long": latLng.latLng!.longitude.toString(),
          "store_id": id,
          "store_group_id": store1
        }),
      );

      print(convert.jsonEncode({
        "lat": latLng.latLng!.latitude.toString(),
        "long": latLng.latLng!.longitude.toString()
      }));
      var res = await http.post(
        Uri.parse('https://up.ctown.jo/api/matchdelivery.php'),
        headers: {
          'Authorization': 'Bearer ' + 'h1oe6s65wunppubhvxq8hrnki9raobt1',
          "content-type": "application/json"
        },
        body: convert.jsonEncode({
          "lat": latLng.latLng!.latitude.toString(),
          "long": latLng.latLng!.longitude.toString(),
          "store_id": id,
          "store_group_id": store1
        }),
      );

      print(res.body);
      print(res.statusCode);
      print(Provider.of<AppModel>(context, listen: false).langCode);
      print("suceatda");
      if (res.statusCode == 200) {
        var body = convert.jsonDecode(res.body);
        print(body);
        print(body["db_city"]);
        setState(() {
          statename = body["db_state"];
          cityname = body["db_city"];
          messageContent =
          Provider.of<AppModel>(context, listen: false).langCode == "en"
              ? body["message_content_en"]
              : body["message_content_ar"];
        });
        print(cityname);

        return body["success"] == 1 ? true : false;
      }

      throw Exception(res.reasonPhrase);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> _isAddressServiceableHwi(String state, String city) async {
    printLog("Match Hwi My Test");
    return await MagentoApi().matchDeliveryHwi(
        state, city, Provider.of<AppModel>(context, listen: false).langCode);
  }

  Future<bool> matchDeliveryHwi1(String state, String city) async {
    try {
      var store = await getSavedStore();
      String? lang = Provider.of<AppModel>(context, listen: false).langCode;

      String? storeId = lang == "en"
          ? store["store_en"]["id"]
          : store["store_ar"]["id"] ?? "";
      var storeGroupId = await getSavedStoregroupid();

      printLog("My Test Huawei");
      printLog("State & City: $state $city");
      printLog("Store Id & Store Group Id: $storeId $storeGroupId");
      var res = await http.post(
        Uri.parse("https://up.ctown.jo/api/matchdeliveryhuawei.php"),
        body: json.encode({
          "state_area": state,
          "city": city,
          "store_id": storeId,
          "store_group_id": storeGroupId
        }),
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          "Authorization": "Bearer " + "h1oe6s65wunppubhvxq8hrnki9raobt1"
        },
      );

      printLog(res.body);
      printLog(res.statusCode);
      printLog(Provider.of<AppModel>(context, listen: false).langCode);
      if (res.statusCode == 200) {
        printLog("Success...");
        var body = json.decode(res.body);
        printLog(body);
        printLog(body["db_state"]);
        printLog(body["db_city"]);
        setState(() {
          statename = body["db_state"];
          cityname = body["db_city"];
          lat1 = body["latitude"];
          long1 = body["longitude"];
          messageContent =
          Provider.of<AppModel>(context, listen: false).langCode == "en"
              ? body["message_content_en"]
              : body["message_content_ar"];
        });
        return body["success"] == 1 ? true : false;
      }
      throw Exception(res.reasonPhrase);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final langCode = Provider.of<AppModel>(context, listen: false).langCode ?? "en";
    _firstTimePress = true;
    //String countryName = S.of(context).country;
    // if (_countryController.text.isNotEmpty) {
    //   try {
    //     countryName = picker.CountryPickerUtils.getCountryByIsoCode(
    //             _countryController.text)
    //         .name;
    //   } catch (e) {
    //     countryName = S.of(context).country;
    //   }
    // }

    // if (address == null) {
    //   return Container(height: 100, child: kLoadingWidget(context));
    // }
    return SafeArea(
      child: Scaffold(
        // backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 22,
            ),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop();
              } else {
                Navigator.pushNamed(context, '/home');
              }
            },
          ),
          title: Text(
            widget.isEdit!
                ? S.of(context).editaddress
                : S.of(context).add_address,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        body: FutureBuilder(
          future: myFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Center(
                child: kLoadingWidget(context), //CircularProgressIndicator(),
              );
            }
            return SingleChildScrollView(
              child: Form(
                key: _formKey,
                child:
                //  isSavePressed
                //     ? Center(
                //         child: CircularProgressIndicator(),
                //       )
                // :
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 10),
                      TextFormField(
                        initialValue: address.firstName,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary, fontSize: 14),
                        //decoration: InputDecoration(labelText: S.of(context).firstName),
                        decoration: InputDecoration(
                          isDense: true,
                          labelStyle:
                          TextStyle(color: Theme.of(context).colorScheme.secondary),
                          labelText: S.of(context).firstName,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                          ),
                        ),
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        validator: (val) {
                          return val!.isEmpty
                              ? S.of(context).firstNameIsRequired
                              : null;
                        },
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_lastNameNode),
                        onSaved: (String? value) {
                          address.firstName = value;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                          initialValue: address.lastName,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 14),
                          focusNode: _lastNameNode,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.done,
                          validator: (val) {
                            return val!.isEmpty
                                ? S.of(context).lastNameIsRequired
                                : null;
                          },
                          // decoration: InputDecoration(labelText: S.of(context).lastName),
                          decoration: InputDecoration(
                            isDense: true,
                            labelText: S.of(context).lastName,
                            labelStyle:
                            TextStyle(color: Theme.of(context).colorScheme.secondary),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                          ),
                          //onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_phoneNode),
                          onSaved: (String? value) {
                            address.lastName = value;
                          }),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18.0, vertical: 6.0),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context).primaryColor),
                            borderRadius:
                            const BorderRadius.all(Radius.circular(10.0))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    S.of(context).country,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w300,
                                        // color: Colors.black54,
                                        color: Theme.of(context).colorScheme.secondary),
                                  ),
                                ),
                              ],
                            ),
                            (countries!.length == 1)
                                ? Text(
                              picker.CountryPickerUtils
                                  .getCountryByIsoCode(
                                  countries![0].code!)
                                  .name,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black),
                            )
                                : Text(_countryController.text == "JO" ? "Jordan" :_countryController.text,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black
                              ),) ,
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      renderStateInput(),
                      const SizedBox(height: 10),
                      renderCityInput(),
                      const SizedBox(height: 10),
                      TextFormField(
                          onTap: () async {
                            LocationResult result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => PlacePicker(
                                  kIsWeb
                                      ? kGoogleAPIKey['web']
                                      : isIos
                                      ? kGoogleAPIKey['ios']
                                      : kGoogleAPIKey['android'],
                                ),
                              ),
                            ) ?? LocationResult();
                            if (result.latLng != null) {
                              bool isServiceable = true;
                              setState(() {
                                latlan = result;
                                lat1 = result.latLng!.latitude.toString();
                                long1 = result.latLng!.longitude.toString();
                              });
                              try {
                                showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: kLoadingWidget,
                                );
                                print(
                                    "printer ${result.street} ${result.city} ${result.locality}${result.state}${result.country}");
                                deliverableArea = true;
                                print(result.city);
                                await matchDelivery1(result);
                                setState(() {
                                  _cityController.text =
                                      cityname.toString().trim();
                                  _stateController.text =
                                      statename.toString().trim();
                                  _streetController.text =
                                      result.street.toString().trim();
                                  _countryController.text = result.country!;
                                });
                                isServiceable = await _isAddressServiceable(result);
                              }
                              catch(e) {
                                printLog(e.toString());
                              }
                              finally {
                                Navigator.of(context, rootNavigator: true).pop();
                              }
                              if (!isServiceable) {
                                deliverableArea = false;
                                print("1 $deliverableArea");
                                return showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                    content: Text(messageContent!),
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: Text(
                                          S.of(context).ok,
                                          style: TextStyle(
                                            color: Colors.white
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              }
                              else {
                                address.country = result.country;
                                address.street = result.street;
                                address.state = statename;

                                address.state_id = result.city;
                                address.city = cityname;
                                //address.zipCode = result.zip;
                                address.mapUrl =
                                'https://maps.google.com/maps?q=${result.latLng!.latitude},${result.latLng!.longitude}&output=embed';

                                print(address.city);
                                print(address.street);
                                print("vengadesh");
                                print(result.country);
                                setState(() {
                                  _cityController.text = cityname!;
                                  _stateController.text = statename!;
                                  _streetController.text =
                                      result.street.toString().trim();
                                  //_zipController.text = result.zip;
                                  _countryController.text = result.country!;
                                  // _isAddressFromMap = true;
                                });
                              }
                            }
                          },
                          readOnly: /*hms == true ? false : */ true,
                          controller: _streetController,
                          focusNode: _streetNode,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 14),
                          validator: (val) {
                            return val!.isEmpty
                                ? S.of(context).streetIsRequired
                                : null;
                          },
                          decoration: InputDecoration(
                            isDense: true,
                            labelText: S.of(context).searchingAddress,
                            labelStyle:
                            TextStyle(color: Theme.of(context).colorScheme.secondary),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                          ),
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) => FocusScope.of(context)
                              .requestFocus(_apartmentNode),
                          onSaved: (String? value) {
                            address.street = value;
                            _streetController.text = value!;
                          }),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _stateController,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary, fontSize: 14),
                        validator: (val) {
                          return val!.isEmpty ? "Area is Required" : null;
                        },
                        textInputAction: TextInputAction.done,
                        readOnly: /*hms == true ? true : */ false,
                        decoration: InputDecoration(
                          isDense: true,
                          labelText: langCode == "en" ? "Area" :"المنطقة",
                          labelStyle:
                          TextStyle(color: Theme.of(context).colorScheme.secondary),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor),
                            borderRadius:
                            const BorderRadius.all(Radius.circular(10.0)),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor),
                            borderRadius:
                            const BorderRadius.all(Radius.circular(10.0)),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor),
                            borderRadius:
                            const BorderRadius.all(Radius.circular(10.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor),
                            borderRadius:
                            const BorderRadius.all(Radius.circular(10.0)),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor),
                            borderRadius:
                            const BorderRadius.all(Radius.circular(10.0)),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor),
                            borderRadius:
                            const BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                        onSaved: (String? value) {
                          address.streetNo = value;
                        },
                        onChanged: (e) {
                          address.streetNo = e;
                        },
                      ),
                      //
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _streetNo,
                        focusNode: _streetNoNode,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary, fontSize: 14),
                        // validator: (val) {
                        //   return val.isEmpty ? "Street No is Required" : null;
                        // },
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          isDense: true,
                          labelText: langCode == "en" ? "Street No" :"رقم الشارع",
                          labelStyle:
                          TextStyle(color: Theme.of(context).colorScheme.secondary),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor),
                            borderRadius:
                            const BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                        onSaved: (String? value) {
                          address.streetNo = value;
                        },
                        onChanged: (e) {
                          address.streetNo = e;
                        },
                      ),

                      //
                      const SizedBox(height: 10),
                      TextFormField(
                          controller: _apartmentController,
                          focusNode: _apartmentNode,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 14),
                          // validator: (val) {
                          //   return val.isEmpty
                          //       ? "Building Name is Required"
                          //       : null;
                          // },
                          decoration: InputDecoration(
                            isDense: true,
                            labelText: S.of(context).streetNameApartment,
                            labelStyle:
                            TextStyle(color: Theme.of(context).colorScheme.secondary),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                          ),
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) =>
                              FocusScope.of(context).requestFocus(_blockNode),
                          onChanged: (e) {
                            address.apartment = e;
                          },
                          onSaved: (String? value) {
                            address.apartment = value;
                          }),
                      //

                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _buildingNo,
                        focusNode: _buildingNoNode,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary, fontSize: 14),
                        // validator: (val) {
                        //   return val.isEmpty ? "Building No is Required" : null;
                        // },
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          isDense: true,
                          labelText: langCode == "en" ? "Building No" : "رقم البناية",
                          labelStyle:
                          TextStyle(color: Theme.of(context).colorScheme.secondary),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor),
                            borderRadius:
                            const BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                        onSaved: (String? value) {
                          // address.phoneNumber = value;
                        },
                        onChanged: (e) {
                          address.buildingNo = e;
                        },
                      ),
                      //
                      const SizedBox(height: 10),
                      TextFormField(
                          controller: _blockController,
                          focusNode: _blockNode,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 14),
                          // validator: (val) {
                          //   return val.isEmpty ? "Flat No is Required" : null;
                          // },
                          decoration: InputDecoration(
                            isDense: true,
                            labelText: S.of(context).streetNameBlock,
                            labelStyle:
                            TextStyle(color: Theme.of(context).colorScheme.secondary),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                          ),
                          textInputAction: TextInputAction.next,
                          onChanged: (e) {
                            address.block = e;
                          },
                          onFieldSubmitted: (_) => FocusScope.of(context)
                              .requestFocus(_landmarkNode),
                          onSaved: (String? value) {
                            address.block = value;
                          }),
                      //
                      const SizedBox(height: 10),
                      // TextFormField(
                      //     controller: _zoneNo,
                      //     focusNode: _zoneNode,
                      //     style: TextStyle(
                      //         color: Theme.of(context).accentColor,
                      //         fontSize: 14),
                      //     validator: (val) {
                      //       return val.isEmpty ? "Zone No is Required" : null;
                      //     },
                      //     keyboardType: TextInputType.number,
                      //     textInputAction: TextInputAction.done,
                      //     decoration: InputDecoration(
                      //       isDense: true,
                      //       labelText: "Zone No",
                      //       labelStyle:
                      //           TextStyle(color: Theme.of(context).accentColor),
                      //       enabledBorder: OutlineInputBorder(
                      //         borderSide: BorderSide(
                      //             color: Theme.of(context).primaryColor),
                      //         borderRadius:
                      //             const BorderRadius.all(Radius.circular(10.0)),
                      //       ),
                      //     ),
                      //     onSaved: (String value) {
                      //       // address.phoneNumber = value;
                      //     },
                      //     onChanged: (e) {
                      //       address.zoneNo = e;
                      //     }),
                      // const SizedBox(height: 10),
                      // TextFormField(
                      //   controller: _unitNo,
                      //   focusNode: _unitNode,
                      //   style: TextStyle(
                      //       color: Theme.of(context).accentColor, fontSize: 14),
                      //   validator: (val) {
                      //     return null;
                      //     // val.isEmpty ? "Unit No is Required" : null;
                      //   },
                      //   keyboardType: TextInputType.number,
                      //   textInputAction: TextInputAction.done,
                      //   decoration: InputDecoration(
                      //     isDense: true,
                      //     labelText: "Unit No",
                      //     labelStyle:
                      //         TextStyle(color: Theme.of(context).accentColor),
                      //     enabledBorder: OutlineInputBorder(
                      //       borderSide: BorderSide(
                      //           color: Theme.of(context).primaryColor),
                      //       borderRadius:
                      //           const BorderRadius.all(Radius.circular(10.0)),
                      //     ),
                      //   ),
                      //   onSaved: (String value) {
                      //     address.unitNo = value;
                      //   },
                      //   // onEditingComplete: () {
                      //   //   address.unitNo = _unitNo.text.trim();
                      //   //   _unitNode.unfocus();
                      //   // },
                      //   onChanged: (e) {
                      //     address.unitNo = e;
                      //   },
                      // ),
                      //
                      const SizedBox(height: 10),
                      TextFormField(
                          controller: _landmarkController,
                          focusNode: _landmarkNode,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 14),
                          // validator: (val) {
                          //   return val.isEmpty ? "Landmark is Required" : null;
                          // },
                          decoration: InputDecoration(
                            isDense: true,
                            labelText: S.of(context).landmark,
                            labelStyle:
                            TextStyle(color: Theme.of(context).colorScheme.secondary),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                          ),
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) =>
                              FocusScope.of(context).requestFocus(_phoneNoNode),
                          onChanged: (e) {
                            address.landmark = e;
                          },
                          onSaved: (String? value) {
                            address.landmark = value;
                          }),
                      const SizedBox(height: 10),
                      TextFormField(
                          controller: _phoneNoController,
                          focusNode: _phoneNoNode,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 14),
                          validator: (val) {
                            return val!.isEmpty
                                ? S.of(context).phoneIsRequired
                                : null;
                          },
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            isDense: true,
                            labelText: S.of(context).phoneNumber,
                            labelStyle:
                            TextStyle(color: Theme.of(context).colorScheme.secondary),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor),
                              borderRadius:
                              const BorderRadius.all(Radius.circular(10.0)),
                            ),
                          ),
                          onSaved: (String? value) {
                            address.phoneNumber = value;
                          }),
                      const SizedBox(height: 20),
                      /* hms == true
                          ? Container()
                          : */
                      ButtonTheme(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                side: BorderSide(
                                    color: Theme.of(context).primaryColor)),
                            elevation: 0.0,
                            foregroundColor: Theme.of(context).colorScheme.surface,
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                          onPressed: () async {
                            LocationResult result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => PlacePicker(
                                  kIsWeb
                                      ? kGoogleAPIKey['web']
                                      : isIos
                                      ? kGoogleAPIKey['ios']
                                      : kGoogleAPIKey['android'],
                                ),
                              ),
                            ) ?? LocationResult();
                            setState(() {
                              latlan = result;
                              lat1 = result.latLng!.latitude.toString();
                              long1 = result.latLng!.longitude.toString();
                            });
                            if (result.latLng != null) {
                              bool isServiceable = true;
                              try {
                                showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: kLoadingWidget,
                                );
                                print(
                                    "printer ${result.street} ${result.city} ${result.locality}${result.state}${result.country}");
                                deliverableArea = true;
                                print(result.city);
                                await matchDelivery1(result);
                                isServiceable = await _isAddressServiceable(result);
                              }
                              catch(e) {
                                printLog(e.toString());
                              }
                              finally {
                                Navigator.of(context, rootNavigator: true).pop();
                              }
                              if (!isServiceable) {
                                deliverableArea = false;
                                print("1 $deliverableArea");
                                return showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                    content: Text(messageContent!),
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: Text(
                                          S.of(context).ok,
                                          style: TextStyle(
                                              color: Colors.white
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              }
                              else {
                                address.country = result.country;
                                address.street = result.street;
                                address.state = statename;

                                address.state_id = result.city;
                                address.city = cityname;
                                //address.zipCode = result.zip;
                                address.mapUrl =
                                'https://maps.google.com/maps?q=${result.latLng!.latitude},${result.latLng!.longitude}&output=embed';

                                print(address.city);
                                print(address.street);
                                print("vengadesh");
                                print(result.country);
                                setState(() {
                                  _cityController.text =
                                      cityname.toString().trim();
                                  _stateController.text =
                                      statename.toString().trim();
                                  _streetController.text =
                                      result.street.toString().trim();
                                  _countryController.text = result.country!;
                                });
                                // setState(() {
                                //   _cityController.text = cityname!;
                                //   _stateController.text = statename!;
                                //   _streetController.text =
                                //       result.street.toString().trim();
                                //   //_zipController.text = result.zip;
                                //   _countryController.text = result.country!;
                                //   // _isAddressFromMap = true;
                                // });
                              }
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const Icon(
                                FontAwesomeIcons.searchLocation,
                                size: 18,
                              ),
                              const SizedBox(width: 10.0),
                              Text(
                                S.of(context).searchingAddress.toUpperCase(),
                                // "sdsdsd",
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                      /*hms == true ? Container() : */ Container(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ButtonTheme(
                            height: 50,
                            minWidth: 150,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                side: BorderSide(
                                    color: Theme.of(context).primaryColor)),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0.0,
                                foregroundColor: Theme.of(context).colorScheme.surface,
                                backgroundColor: Theme.of(context).primaryColor,
                              ),
                              onPressed: () async {
                                // if (!checkToSave()) return;
                                // if (_formKey.currentState.validate()) {
                                //   _formKey.currentState.save();
                                //   Provider.of<CartModel>(context, listen: false).setAddress(address);
                                //   //saveDataToLocal();
                                //   await saveDataToRemote();
                                Navigator.of(context).pop();
                                //}
                              },
                              child: Text(
                                S.of(context).cancel.toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          // Container(
                          //   width: 10,
                          // ),
                          ButtonTheme(
                            height: 50,
                            minWidth: 150,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                side: BorderSide(
                                    color: Theme.of(context).primaryColor)),
                            child: address.city == null ||
                                deliverableArea == false
                                ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xffeeeeee),
                              ),
                              onPressed: () {},
                              child: Text(
                                S.of(context).saveAddress.toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                              ),
                            )
                                : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0.0,
                                foregroundColor: Theme.of(context).colorScheme.surface,
                                backgroundColor: Theme.of(context).primaryColor,
                              ),
                              onPressed: () async {
                                // if (!checkToSave()) return;
                                print(
                                    "=====dfgkddddddddddddddddddddddddddddddddddd");
                                print(address.city);
                                print(_cityController.text);
                                print(address.street);
                                print(address.state);
                                print(address.country);
                                print(address.landmark);
                                print(address.apartment);
                                print(address.block);
                                print("unti this");

                                print(address.streetNo);
                                print(address.unitNo);
                                print(address.zoneNo);
                                print(address.buildingNo);

                                if (_formKey.currentState!.validate()) {
                                  if (address.city != null) {
                                    if (deliverableArea) {
                                      if (_firstTimePress) {
                                        bool addressExists = false;

                                        _formKey.currentState!.save();

                                        if (widget.isEdit == false) {
                                          print(address.country =
                                              _countryController.text);

                                          if (!checkToSave()) return;
                                          for (int i = 0;
                                          i <
                                              widget.savedAddresses!
                                                  .length;
                                          i++) {
                                            print(widget
                                                .savedAddresses![i].city);
                                            print(widget.savedAddresses![i]
                                                .street);
                                            if ((widget.savedAddresses![i]
                                                .state ==
                                                address.state &&
                                                widget.savedAddresses![i]
                                                    .city ==
                                                    address.city &&
                                                widget.savedAddresses![i]
                                                    .street ==
                                                    address.street)) {
                                              addressExists = true;
                                              break;
                                            }
                                          }
                                          print(addressExists);
                                          if (addressExists) {
                                            SnackBar snackBar = SnackBar(
                                              content: Text(
                                                  'This address is already saved'),
                                              duration:
                                              Duration(seconds: 1),
                                            );
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(snackBar);
                                          } else {
                                            showDialog(
                                                context: context,
                                                builder: kLoadingWidget,
                                                barrierDismissible:
                                                false);

                                            await saveDataToRemote(
                                                lat1, long1);

                                            _firstTimePress = false;
                                            // Provider.of<CartModel>(
                                            //         context,
                                            //         listen: false)
                                            //     .setAddress(address);
                                            //  // saveDataToLocal();
                                            Navigator.of(context,
                                                rootNavigator: true)
                                                .pop();
                                            Navigator.of(context).pop();
                                          }
                                        } else {
                                          int addressCounter = 0;
                                          for (int i = 0;
                                          i <
                                              widget.savedAddresses!
                                                  .length;
                                          i++) {
                                            if ((widget.savedAddresses![i]
                                                .country ==
                                                address.country &&
                                                widget.savedAddresses![i]
                                                    .state ==
                                                    address.state &&
                                                widget.savedAddresses![i]
                                                    .city ==
                                                    address.city &&
                                                widget.savedAddresses![i]
                                                    .street ==
                                                    address.street &&
                                                widget.savedAddresses![i]
                                                    .phoneNumber ==
                                                    address
                                                        .phoneNumber)) {
                                              addressCounter++;
                                            }
                                          }

                                          print(addressCounter);
                                          if (addressCounter <= 1) {
                                            showDialog(
                                                context: context,
                                                builder: kLoadingWidget,
                                                barrierDismissible:
                                                false);

                                            await saveDataToRemote(
                                                lat1, long1);

                                            // Provider.of<CartModel>(
                                            //         context,
                                            //         listen: false)
                                            //     .setAddress(address);
                                            Navigator.of(context,
                                                rootNavigator: true)
                                                .pop();

                                            Navigator.of(context).pop();
                                          }
                                        }
                                      }
                                    } else {
                                      SnackBar snackBar = SnackBar(
                                          content: Text(
                                              'This address does not fall within the service area'));
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                    }
                                  } else {
                                    SnackBar snackBar = SnackBar(
                                        content: Text(
                                            'please select city and street'));
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  }
                                }
                              },
                              child: Text(
                                S.of(context).saveAddress.toUpperCase(),
                                // "dfgfd",
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
