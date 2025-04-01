// import 'package:ctown/frameworks/magento/services/magento.dart';
// import 'package:ctown/models/address_model.dart';
// import 'package:ctown/models/app_model.dart';
// import 'package:ctown/models/entities/states.dart';
// import 'package:country_pickers/country.dart' as picker_country;
// import 'package:country_pickers/country_pickers.dart' as picker;
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:localstorage/localstorage.dart';
// import 'package:provider/provider.dart';

// import '../../common/config.dart';
// import '../../common/constants.dart';
// import '../../common/tools.dart';
// import '../../generated/l10n.dart';
// import '../../models/index.dart'
//     show Address, CartModel, Country, User, UserModel;
// import '../../services/index.dart';
// import '../../widgets/common/place_picker.dart';
// import 'choose_address.dart';

// import 'package:localstorage/localstorage.dart';
// import 'package:provider/provider.dart';
// import 'package:ctown/screens/cart/cartProvider.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class ShippingAddress extends StatefulWidget {
//   final Function onNext;

//   ShippingAddress({this.onNext});

//   @override
//   _ShippingAddressState createState() => _ShippingAddressState();
// }

// class _ShippingAddressState extends State<ShippingAddress> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _cityController = TextEditingController();
//   final TextEditingController _streetController = TextEditingController();
//   final TextEditingController _blockController = TextEditingController();
//   final TextEditingController _stateController = TextEditingController();
//   final TextEditingController _countryController = TextEditingController();
//   final TextEditingController _apartmentController = TextEditingController();
//   final TextEditingController _landmarkController = TextEditingController();

//   final _lastNameNode = FocusNode();
//   final _phoneNode = FocusNode();
//   final _emailNode = FocusNode();
//   final _cityNode = FocusNode();
//   final _streetNode = FocusNode();
//   final _blockNode = FocusNode();
//   final _stateNode = FocusNode();
//   final _countryNode = FocusNode();
//   final _apartmentNode = FocusNode();
//   final _landmarkNode = FocusNode();

//   var _isAddressFromMap = false;

//   Address address;
//   List<Country> countries = [];
//   List<dynamic> states = [];

//   @override
//   void dispose() {
//     _cityController.dispose();
//     _streetController.dispose();
//     _blockController.dispose();
//     _stateController.dispose();
//     _countryController.dispose();
//     _apartmentController.dispose();
//     _landmarkController.dispose();

//     _lastNameNode.dispose();
//     _phoneNode.dispose();
//     _emailNode.dispose();
//     _cityNode.dispose();
//     _streetNode.dispose();
//     _blockNode.dispose();
//     _stateNode.dispose();
//     _countryNode.dispose();
//     _apartmentNode.dispose();
//     _landmarkNode.dispose();

//     super.dispose();
//   }

// //
//   getDiscountsIfAny() async {
//     final LocalStorage storage = LocalStorage('store');
//     final userJson = storage.getItem(kLocalKey["userInfo"]);
//     final cartmodel = Provider.of<CartModel>(context, listen: false).address;
//     String url =
//         "https://up.ctown.jo/rest/V1/carts/mine/payment-information?address_id=${cartmodel.id}&nocache=${DateTime.now().microsecond}${DateTime.now().microsecond}${DateTime.now().microsecond}";

//     // print(userJson["cookie"]);
//     var response = await http.get(url, headers: {
//       'Authorization': 'Bearer ' + userJson["cookie"],
//     });
//     if (response.statusCode == 200) {
//       // print(response.body);
//       var data = jsonDecode(response.body);

//       Provider.of<CartProvider>(context, listen: false).setMagentoDiscount(
//           double.parse(data["totals"]["discount_amount"].toString()));
//       Provider.of<CartProvider>(context, listen: false).setCartGrandTotal(
//           double.parse(data["totals"]["grand_total"].toString()));
//       Provider.of<CartProvider>(context, listen: false).setBaseSubTotal(
//           double.parse(data["totals"]["base_subtotal"].toString()));
//     }
//   }

//   LocationResult latlang;

// //
//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(
//       Duration.zero,
//       () async {
//         final addressValue =
//             await Provider.of<CartModel>(context, listen: false).getAddress();
//         if (addressValue != null) {
//           setState(() {
//             address = addressValue;
//             _cityController.text = address.city;
//             _streetController.text = address.street;
//             _stateController.text = address.state;
//             _blockController.text = address.block;
//             _apartmentController.text = address.apartment;
//             _landmarkController.text = address.landmark;
//           });
//         } else {
//           User user = Provider.of<UserModel>(context, listen: false).user;
//           setState(() {
//             address = Address(country: kPaymentConfig["DefaultCountryISOCode"]);
//             if (kPaymentConfig["DefaultStateISOCode"] != null) {
//               address.state = kPaymentConfig["DefaultStateISOCode"];
//               address.state_id = kPaymentConfig["DefaultStateISOCode"];
//             }
//             _countryController.text = address.country;
//             _stateController.text = address.state;
//             if (user != null) {
//               address.firstName = user.firstName;
//               address.lastName = user.lastName;
//               address.email = user.email;
//             }
//           });
//         }
//         countries = await Services().widget.loadCountries(context);
//         var country = countries.firstWhere(
//             (element) =>
//                 element.id == address.country ||
//                 element.code == address.country,
//             orElse: () => null);
//         if (country == null) {
//           if (countries.isNotEmpty) {
//             country = countries[0];
//             address.country = countries[0].code;
//           } else {
//             country = Country.fromConfig(address.country, null, null, []);
//           }
//         }
//         //setState(() {
//         _countryController.text = country.code;
//         //});
//         states = await Services().widget.loadStatenCities();
//         setState(() {});
//       },
//     );
//   }

//   Future<void> updateState(Address address) async {
//     setState(() {
//       _cityController.text = address.city;
//       _streetController.text = address.street;
//       _stateController.text = address.state;
//       _countryController.text = address.country;
//       this.address.country = address.country;
//       _apartmentController.text = address.apartment;
//       _blockController.text = address.block;
//       _landmarkController.text = address.landmark;
//     });
//   }

//   checkToSave() {
//     final LocalStorage storage = LocalStorage("address");
//     List<Address> _list = [];
//     try {
//       var data = storage.getItem('data');
//       if (data != null) {
//         (data as List).forEach((item) {
//           final add = Address.fromLocalJson(item);
//           _list.add(add);
//         });
//       }
//       for (var local in _list) {
//         if (local.city != _cityController.text) continue;
//         if (local.street != _streetController.text) continue;
//         //if (local.zipCode != _zipController.text) continue;
//         if (local.state != _stateController.text) continue;
//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: Text(S.of(context).yourAddressExistYourLocal),
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
//           },
//         );
//         return false;
//       }
//     } catch (err) {
//       printLog(err);
//     }
//     return true;
//   }

//   // Future<void> saveDataToLocal() async {
//   //   final LocalStorage storage = LocalStorage("address");
//   //   List<Address> _list = [];
//   //   _list.add(address);
//   //   try {
//   //     final ready = await storage.ready;
//   //     if (ready) {
//   //       var data = storage.getItem('data');
//   //       if (data != null) {
//   //         (data as List).forEach((item) {
//   //           final add = Address.fromLocalJson(item);
//   //           _list.add(add);
//   //         });
//   //       }
//   //       await storage.setItem(
//   //           'data',
//   //           _list.map((item) {
//   //             return item.toJsonEncodable();
//   //           }).toList());
//   //       await showDialog(
//   //           context: context,
//   //           builder: (BuildContext context) {
//   //             return AlertDialog(
//   //               title: Text(S.of(context).youHaveBeenSaveAddressYourLocal),
//   //               actions: <Widget>[
//   //                 FlatButton(
//   //                   child: Text(
//   //                     S.of(context).ok,
//   //                     style: TextStyle(color: Theme.of(context).primaryColor),
//   //                   ),
//   //                   onPressed: () {
//   //                     Navigator.of(context).pop();
//   //                   },
//   //                 )
//   //               ],
//   //             );
//   //           });
//   //     }
//   //   } catch (err) {
//   //     printLog(err);
//   //   }
//   // }

//   Future<void> saveDataToRemote(LocationResult result) async {
//     try {
//       print("runnning");
//       UserModel userModel = Provider.of<UserModel>(context, listen: false);
//       //if (widget.isEdit) {
//       if (address.id.isNotEmpty) {
//         await Services().serviceApi.editAddress(address, userModel.user,
//             Provider.of<AppModel>(context, listen: false).langCode);
//       } else {
//         await Services().serviceApi.addAddress(
//             address,
//             userModel.user,
//             Provider.of<AppModel>(context, listen: false).langCode,
//             result.latLng.latitude.toString(),
//             result.latLng.longitude.toString());
//       }
//       await Provider.of<AddressModel>(context, listen: false)
//           .getMyAddress(userModel: userModel);
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
//     } catch (e) {
//       printLog(e);
//     }
//   }

//   Future<bool> _isAddressServiceable(LocationResult locationResult) async {
//     // if (states != null) {
//     //   Data state = states.firstWhere((element) => element.name == locationResult.city, orElse: () => null);
//     //   if (state == null) {
//     //     return false;
//     //   }
//     //   final index = state.area.indexWhere((element) => element.areaName == locationResult.locality);
//     //   if (index == -1) {
//     //     return false;
//     //   }
//     //   return true;
//     // }
//     // return false;
//     return await MagentoApi().matchDelivery(
//         locationResult.latLng.latitude,
//         locationResult.latLng.longitude,
//         Provider.of<AppModel>(context, listen: false).langCode);
//   }

//   @override
//   Widget build(BuildContext context) {
//     String countryName = S.of(context).country;
//     if (_countryController.text.isNotEmpty) {
//       try {
//         countryName = picker.CountryPickerUtils.getCountryByIsoCode(
//                 _countryController.text)
//             .name;
//       } catch (e) {
//         countryName = S.of(context).country;
//       }
//     }

//     if (address == null) {
//       return Container(height: 100, child: kLoadingWidget(context));
//     }
//     return Form(
//       key: _formKey,
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
//           Widget>[
//         TextFormField(
//           initialValue: address.firstName,
//           decoration: InputDecoration(labelText: S.of(context).firstName),
//           textCapitalization: TextCapitalization.words,
//           textInputAction: TextInputAction.next,
//           validator: (val) {
//             return val.isEmpty ? S.of(context).firstNameIsRequired : null;
//           },
//           onFieldSubmitted: (_) =>
//               FocusScope.of(context).requestFocus(_lastNameNode),
//           onSaved: (String value) {
//             address.firstName = value;
//           },
//         ),
//         TextFormField(
//             initialValue: address.lastName,
//             focusNode: _lastNameNode,
//             textCapitalization: TextCapitalization.words,
//             textInputAction: TextInputAction.next,
//             validator: (val) {
//               return val.isEmpty ? S.of(context).lastNameIsRequired : null;
//             },
//             decoration: InputDecoration(labelText: S.of(context).lastName),
//             onFieldSubmitted: (_) =>
//                 FocusScope.of(context).requestFocus(_phoneNode),
//             onSaved: (String value) {
//               address.lastName = value;
//             }),
//         TextFormField(
//             initialValue: address.phoneNumber,
//             focusNode: _phoneNode,
//             decoration: InputDecoration(labelText: S.of(context).phoneNumber),
//             textInputAction: TextInputAction.next,
//             validator: (val) {
//               return val.isEmpty ? S.of(context).phoneIsRequired : null;
//             },
//             keyboardType: TextInputType.number,
//             onFieldSubmitted: (_) =>
//                 FocusScope.of(context).requestFocus(_emailNode),
//             onSaved: (String value) {
//               address.phoneNumber = value;
//             }),
//         TextFormField(
//             initialValue: address.email,
//             focusNode: _emailNode,
//             keyboardType: TextInputType.emailAddress,
//             decoration: InputDecoration(labelText: S.of(context).email),
//             textInputAction: TextInputAction.done,
//             validator: (val) {
//               if (val.isEmpty) {
//                 return S.of(context).emailIsRequired;
//               }
//               return Validator.validateEmail(val);
//             },
//             onSaved: (String value) {
//               address.email = value;
//             }),
//         const SizedBox(height: 10.0),
//         if (kPaymentConfig['allowSearchingAddress'])
//           if (kGoogleAPIKey.isNotEmpty)
//             Row(
//               children: [
//                 Expanded(
//                   child: ButtonTheme(
//                     height: 50,
//                     child: RaisedButton(
//                       elevation: 0.0,
//                       onPressed: () async {
//                         LocationResult result =
//                             await Navigator.of(context).push(
//                           MaterialPageRoute(
//                             builder: (context) => PlacePicker(
//                               kIsWeb
//                                   ? kGoogleAPIKey['web']
//                                   : isIos
//                                       ? kGoogleAPIKey['ios']
//                                       : kGoogleAPIKey['android'],
//                             ),
//                           ),
//                         );
//                         setState(() {
//                           latlang = result;
//                         });

//                         if (result != null) {
//                           if (!await _isAddressServiceable(result)) {
//                             return showDialog(
//                               context: context,
//                               builder: (context) => AlertDialog(
//                                 content: Text(
//                                   S.of(context).selected_address,
//                                 ),
//                                 actions: [
//                                   RaisedButton(
//                                     onPressed: () =>
//                                         Navigator.of(context).pop(),
//                                     child: Text(
//                                       S.of(context).ok,
//                                     ),
//                                   )
//                                 ],
//                               ),
//                             );
//                           } else {
//                             address.country = result.country;
//                             address.street = result.street;
//                             address.state = result.city;
//                             address.state_id = states
//                                 .firstWhere(
//                                     (element) => element.name == result.city)
//                                 .id; //result.city;
//                             address.city = result.locality;
//                             //address.zipCode = result.zip;
//                             address.mapUrl =
//                                 'https://maps.google.com/maps?q=${result.latLng.latitude},${result.latLng.longitude}&output=embed';

//                             setState(() {
//                               _cityController.text = result.city;
//                               _stateController.text = result.state;
//                               _streetController.text = result.street;
//                               //_zipController.text = result.zip;
//                               _countryController.text = result.country;
//                               _isAddressFromMap = true;
//                             });
//                           }
//                           // final c =
//                           //     Country(id: result.country, name: result.country);
//                           // states = await Services().widget.loadStatenCities();
//                           // setState(() {});
//                         }
//                       },
//                       textColor: Theme.of(context).accentColor,
//                       color: Theme.of(context).primaryColorLight,
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: <Widget>[
//                           const Icon(
//                             FontAwesomeIcons.searchLocation,
//                             size: 18,
//                           ),
//                           const SizedBox(width: 10.0),
//                           Text(S.of(context).searchingAddress.toUpperCase()),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//         const SizedBox(height: 10),
//         ButtonTheme(
//           height: 50,
//           child: RaisedButton(
//             elevation: 0.0,
//             onPressed: () {
//               Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => ChooseAddress(updateState)));
//             },
//             textColor: Theme.of(context).accentColor,
//             color: Theme.of(context).primaryColorLight,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 const Icon(
//                   FontAwesomeIcons.solidAddressBook,
//                   size: 16,
//                 ),
//                 const SizedBox(width: 10.0),
//                 Text(
//                   S.of(context).selectAddress.toUpperCase(),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(height: 10),
//         Text(
//           S.of(context).country,
//           style: const TextStyle(
//               fontSize: 12, fontWeight: FontWeight.w300, color: Colors.grey),
//         ),
//         (countries.length == 1)
//             ? Container(
//                 child: Text(
//                   picker.CountryPickerUtils.getCountryByIsoCode(
//                           countries[0].code)
//                       .name,
//                   style: const TextStyle(fontSize: 18),
//                 ),
//               )
//             : GestureDetector(
//                 onTap: _openCountryPickerDialog,
//                 child: Column(children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 20),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: <Widget>[
//                         Expanded(
//                           child: Text(countryName,
//                               style: const TextStyle(fontSize: 17.0)),
//                         ),
//                         const Icon(Icons.arrow_drop_down)
//                       ],
//                     ),
//                   ),
//                   const Divider(
//                     height: 1,
//                     color: kGrey900,
//                   )
//                 ]),
//               ),
//         renderCityInput(),
//         renderStateInput(),
//         TextFormField(
//             readOnly: _isAddressFromMap,
//             controller: _streetController,
//             focusNode: _streetNode,
//             validator: (val) {
//               return val.isEmpty ? S.of(context).streetIsRequired : null;
//             },
//             decoration: InputDecoration(
//               labelText: S.of(context).streetName,
//             ),
//             textInputAction: TextInputAction.next,
//             onFieldSubmitted: (_) =>
//                 FocusScope.of(context).requestFocus(_apartmentNode),
//             onSaved: (String value) {
//               address.street = value;
//             }),
//         TextFormField(
//             controller: _apartmentController,
//             focusNode: _apartmentNode,
//             validator: (val) {
//               return null;
//             },
//             decoration:
//                 InputDecoration(labelText: S.of(context).streetNameApartment),
//             textInputAction: TextInputAction.next,
//             onFieldSubmitted: (_) =>
//                 FocusScope.of(context).requestFocus(_blockNode),
//             onSaved: (String value) {
//               address.apartment = value;
//             }),
//         TextFormField(
//             controller: _blockController,
//             focusNode: _blockNode,
//             validator: (val) {
//               return null;
//             },
//             decoration:
//                 InputDecoration(labelText: S.of(context).streetNameBlock),
//             textInputAction: TextInputAction.next,
//             onFieldSubmitted: (_) =>
//                 FocusScope.of(context).requestFocus(_landmarkNode),
//             onSaved: (String value) {
//               address.block = value;
//             }),
//         TextFormField(
//           controller: _landmarkController,
//           focusNode: _landmarkNode,
//           validator: (val) {
//             return null;
//           },
//           decoration: InputDecoration(labelText: S.of(context).landmark),
//           textInputAction: TextInputAction.done,
//           onSaved: (String value) {
//             address.landmark = value;
//           },
//         ),
//         const SizedBox(height: 20),
//         Row(children: [
//           ButtonTheme(
//             height: 45,
//             child: RaisedButton(
//               elevation: 0.0,
//               onPressed: () {
//                 if (!checkToSave()) return;
//                 if (_formKey.currentState.validate()) {
//                   _formKey.currentState.save();
//                   Provider.of<CartModel>(context, listen: false)
//                       .setAddress(address);
//                   //saveDataToLocal();
//                   saveDataToRemote(latlang);
//                 }
//               },
//               color: Theme.of(context).primaryColorLight,
//               child: Text(S.of(context).saveAddress.toUpperCase(),
//                   style: const TextStyle(fontSize: 12)),
//             ),
//           ),
//           Container(
//             width: 20,
//           ),
//           Expanded(
//             child: ButtonTheme(
//               height: 45,
//               child: RaisedButton(
//                 elevation: 0.0,
//                 onPressed: () async {
//                   if (Provider.of<CartProvider>(context, listen: false)
//                           .cartGrandTotal ==
//                       0.0) {
//                     print(Provider.of<CartProvider>(context, listen: false)
//                         .magentoPromotionsDiscount);
//                     print(Provider.of<CartProvider>(context, listen: false)
//                         .cartGrandTotal);

//                     print("getting data");
//                     await getDiscountsIfAny();
//                   }
//                   _onNext();
//                 },
//                 textColor: Colors.black,
//                 color: Colors.yellow,
//                 child: Text(
//                     kPaymentConfig['EnableShipping']
//                         ? S.of(context).continueToShipping.toUpperCase()
//                         : S.of(context).continueToReview.toUpperCase(),
//                     style: const TextStyle(fontSize: 12)),
//               ),
//             ),
//           )
//         ]),
//       ]),
//     );
//   }

//   /// Load Shipping beforehand
//   void _loadShipping({bool beforehand = true}) {
//     Services().widget.loadShippingMethods(
//         context, Provider.of<CartModel>(context, listen: false), beforehand);
//   }

//   /// on tap to Next Button
//   void _onNext() {
//     {
//       if (_formKey.currentState.validate()) {
//         _formKey.currentState.save();
//         Provider.of<CartModel>(context, listen: false).setAddress(address);
//         _loadShipping(beforehand: false);
//         widget.onNext();
//       }
//     }
//   }

//   Widget renderStateInput() {
//     if (states.isNotEmpty) {
//       List<DropdownMenuItem> items = [];
//       states.forEach((item) {
//         items.add(
//           DropdownMenuItem(
//             child: Text(item.name),
//             value: item.name,
//           ),
//         );
//       });
//       String value;
//       if (states.firstWhere(
//               (o) => o.id == address.state || o.name == address.state,
//               orElse: () => null) !=
//           null) {
//         //value = address.state;
//         value = states
//             .firstWhere((o) => o.id == address.state || o.name == address.state)
//             .name;
//       }
//       // else {
//       //   value = address.state = states.first.name;
//       // }
//       return DropdownButton(
//         items: items,
//         value: value,
//         onChanged: (val) {
//           setState(() {
//             address.state = val;
//             address.state_id =
//                 states.firstWhere((element) => element.name == val).id;
//           });
//         },
//         isExpanded: true,
//         itemHeight: 70,
//         hint: Text(S.of(context).stateProvince),
//       );
//     } else {
//       return TextFormField(
//         controller: _stateController,
//         validator: (val) {
//           return val.isEmpty ? S.of(context).streetIsRequired : null;
//         },
//         decoration: InputDecoration(labelText: S.of(context).stateProvince),
//         onSaved: (String value) {
//           address.state = value;
//           address.state_id = value;
//         },
//       );
//     }
//   }

//   Widget renderCityInput() {
//     if (states.isNotEmpty &&
//         states.firstWhere(
//                 (state) =>
//                     state.id == address.state || state.name == address.state,
//                 orElse: () => null) !=
//             null) {
//       List<Area> cities = states
//           .firstWhere((state) =>
//               state.id == address.state || state.name == address.state)
//           .area;
//       List<DropdownMenuItem<String>> items = [];
//       cities.forEach((item) {
//         items.add(
//           DropdownMenuItem<String>(
//             child: Text(item.areaName),
//             value: item.areaName,
//           ),
//         );
//       });
//       String value;
//       if (cities.firstWhere(
//               (o) => o.areaId == address.city || o.areaName == address.city,
//               orElse: () => null) !=
//           null) {
//         value = cities
//             .firstWhere(
//                 (o) => o.areaId == address.city || o.areaName == address.city)
//             .areaName;
//       }
//       // else {
//       //   value = address.city = cities.first.areaName;
//       // }
//       return DropdownButton<String>(
//         items: items,
//         value: value,
//         onChanged: (val) {
//           setState(() {
//             address.city = val;
//           });
//         },
//         isExpanded: true,
//         itemHeight: 70,
//         hint: Text(S.of(context).city),
//       );
//     } else {
//       return TextFormField(
//         controller: _cityController,
//         focusNode: _cityNode,
//         validator: (val) {
//           return val.isEmpty ? S.of(context).cityIsRequired : null;
//         },
//         decoration: InputDecoration(labelText: S.of(context).city),
//         textInputAction: TextInputAction.next,
//         onFieldSubmitted: (_) =>
//             FocusScope.of(context).requestFocus(_streetNode),
//         onSaved: (String value) {
//           address.city = value;
//         },
//       );
//     }
//   }

//   void _openCountryPickerDialog() => showDialog(
//         context: context,
//         builder: (contextBuilder) => countries.isEmpty
//             ? Theme(
//                 data: Theme.of(context).copyWith(primaryColor: Colors.pink),
//                 child: Container(
//                   height: 500,
//                   child: picker.CountryPickerDialog(
//                       titlePadding: const EdgeInsets.all(8.0),
//                       contentPadding: const EdgeInsets.all(2.0),
//                       searchCursorColor: Colors.pinkAccent,
//                       searchInputDecoration:
//                           const InputDecoration(hintText: 'Search...'),
//                       isSearchable: true,
//                       title: Text(S.of(context).country),
//                       onValuePicked: (picker_country.Country country) async {
//                         setState(
//                             () => _countryController.text = country.isoCode);
//                         setState(() => address.country = country.isoCode);
//                         final c =
//                             Country(id: country.isoCode, name: country.name);
//                         states = await Services().widget.loadStates(c);
//                         setState(() {});
//                       },
//                       itemBuilder: (country) {
//                         return Row(
//                           children: <Widget>[
//                             picker.CountryPickerUtils.getDefaultFlagImage(
//                                 country),
//                             const SizedBox(
//                               width: 8.0,
//                             ),
//                             Expanded(child: Text("${country.name}")),
//                           ],
//                         );
//                       }),
//                 ),
//               )
//             : Dialog(
//                 child: SingleChildScrollView(
//                   child: Column(
//                     children: List.generate(
//                       countries.length,
//                       (index) {
//                         return GestureDetector(
//                           onTap: () async {
//                             setState(() {
//                               _countryController.text = countries[index].code;
//                               address.country = countries[index].id;
//                             });
//                             Navigator.pop(contextBuilder);
//                             states = await Services()
//                                 .widget
//                                 .loadStates(countries[index]);
//                             setState(() {});
//                           },
//                           child: ListTile(
//                             leading: countries[index].icon != null
//                                 ? Container(
//                                     height: 40,
//                                     width: 60,
//                                     child: Image.network(
//                                       countries[index].icon,
//                                       fit: BoxFit.cover,
//                                     ),
//                                   )
//                                 : (countries[index].code != null
//                                     ? Image.asset(
//                                         picker.CountryPickerUtils
//                                             .getFlagImageAssetPath(
//                                                 countries[index].code),
//                                         height: 40,
//                                         width: 60,
//                                         fit: BoxFit.fill,
//                                         package: "country_pickers",
//                                       )
//                                     : Container(
//                                         height: 40,
//                                         width: 60,
//                                         child: const Icon(Icons.streetview),
//                                       )),
//                             title: Text(countries[index].name),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//               ),
//       );
// }
