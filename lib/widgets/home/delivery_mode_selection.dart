import 'package:ctown/models/app_model.dart';
import 'package:ctown/widgets/home/clickandcollect_provider.dart';
import 'package:ctown/widgets/home/vertical/clickandcollect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';

import '../../common/constants/route_list.dart';
import '../../generated/l10n.dart';
import '../../models/address_model.dart';
import '../../models/cart/cart_base.dart';
import '../../models/entities/address.dart';
import '../../models/entities/states.dart';
import '../../models/user_model.dart';
import '../../screens/base.dart';
import 'add_address_screen.dart';

class DeliveryModeSelectionDialog extends StatefulWidget {
  final loggedIn;
  final showPickOption;
  
  const DeliveryModeSelectionDialog(
      {Key? key, this.loggedIn, this.showPickOption}) 
      : super(key: key);

  @override
  _DeliveryModeSelectionDialogState createState() =>
      _DeliveryModeSelectionDialogState();
}

class _DeliveryModeSelectionDialogState
    extends BaseScreen<DeliveryModeSelectionDialog> {
  List<Data>? states;
  List<Address> listAddress = [];
  Address address = Address();
  var userJson;
  Future<void>? myFuture;
  int selectedDeliveryMode = 0;
  showAlertDialog(BuildContext context) async {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        // Navigator.of(context, rootNavigator: true).pop();
        // Navigator.of(context, rootNavigator: true).pop();
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text("Let's"),
      onPressed: () {},
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Add an address"),
      content: Text(
          "Please have atleast one address before selecting click and collect"),
      actions: [
        cancelButton,
        // continueButton,
      ],
    );

    // show the dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  //String result = 'Rumalia';

  // final _cityController = TextEditingController();
  // final _stateController = TextEditingController();

  // final _cityNode = FocusNode();

  // final _formKey = GlobalKey<FormState>();

  // @override
  // void initState() {
  //   super.initState();
  //   //_fetchData();
  // }

  @override
  void afterFirstLayout(BuildContext context) {
    final userModel = Provider.of<UserModel>(context, listen: false);
    if (userModel.loggedIn) {
      Provider.of<AddressModel>(context, listen: false)
          .getMyAddress(userModel: userModel,lang: Provider.of<AppModel>(context, listen: false).langCode);
    }
  }

  // Future _fetchData() async {
  //   states = await Services().widget.loadStatenCities();
  //   // await getDatafromLocal();
  //   // await getUserInfo();
  //   // await getDataFromNetwork();
  //   // myFuture = Future.delayed(
  //   //   Duration.zero,
  //   //   () => getDataFromNetwork,
  //   // );
  //   return true;
  // }

  // Future<void> getUserInfo() async {
  //   final LocalStorage storage = LocalStorage("store");
  //   userJson = storage.getItem(kLocalKey["userInfo"]);
  // }

  // Future<void> getDatafromLocal() async {
  //   final LocalStorage storage = LocalStorage("address");
  //   List<Address> _list = [];
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
  //     }
  //     //setState(() {
  //     listAddress = _list;
  //     //});
  //   } catch (_) {}
  // }

  // Future<void> getDataFromNetwork() async {
  //   try {
  //     var result = await Services().getCustomerInfo(userJson["id"]);

  //     if (result != null && result['addresses'] != null) {
  //       for (var address in result['addresses']) {
  //         final add = Address.fromMagentoJson(Map.from(address));
  //         listAddress.add(add);
  //       }
  //       //setState(() {});
  //     }
  //   } catch (err) {
  //     printLog(err);
  //   }
  // }

  // Widget renderStateInput(List<Data> states) {
  //   if (states != null && states.isNotEmpty) {
  //     List<DropDownWidgetItem> items = [];
  //     states.forEach((item) {
  //       items.add(
  //         DropDownWidgetItem(
  //           id: item.id,
  //           value: item.name,
  //         ),
  //       );
  //     });
  //     // String value;
  //     // if (states.firstWhere((o) => o.id == address.state, orElse: () => null) !=
  //     //     null) {
  //     //   value = address.state;
  //     // }
  //     if (address.state == null) {
  //       address.state = items[0].value;
  //       address.state_id = items[0].id;
  //     }

  //     return Container(
  //       padding: const EdgeInsets.symmetric(horizontal: 4.0),
  //       decoration: BoxDecoration(
  //           border: Border.all(color: Colors.blue), borderRadius: const BorderRadius.all(Radius.circular(10.0))),
  //       child: DropDownWidget(
  //         data: items,
  //         indexSelected: address?.state != null
  //             ? items.indexWhere((element) => element.value == address.state || element.id == address.state)
  //             : 0,
  //         //value: value,
  //         onChanged: (item, index) {
  //           setState(() {
  //             address.state = item.value;
  //             address.state_id = item.id;
  //           });
  //         },
  //         //isExpanded: true,
  //         //itemHeight: 70,
  //         label: S.of(context).stateProvince,
  //       ),
  //     );
  //   } else {
  //     return TextFormField(
  //       controller: _stateController,
  //       validator: (val) {
  //         return val.isEmpty ? S.of(context).streetIsRequired : null;
  //       },
  //       decoration: InputDecoration(labelText: S.of(context).stateProvince),
  //       onSaved: (String value) {
  //         address.state = value;
  //         address.state_id = value;
  //       },
  //     );
  //   }
  // }

  // Widget renderCityInput(List<Data> states) {
  //   if (states.isNotEmpty && states.firstWhere((state) => state.name == address.state, orElse: () => null) != null) {
  //     List<Area> cities = states.firstWhere((state) => state.name == address.state).area;
  //     List<DropDownWidgetItem> items = [];
  //     cities.forEach((item) {
  //       items.add(
  //         DropDownWidgetItem(
  //           id: item.areaId,
  //           value: item.areaName,
  //         ),
  //       );
  //     });
  //     // String value;
  //     // if (cities.firstWhere((o) => o.areaName == address.city,
  //     //         orElse: () => null) !=
  //     //     null) {
  //     //   value = address.city;
  //     // }
  //     if (address.city == null) {
  //       address.city = items[0].value;
  //     }

  //     return Container(
  //       padding: const EdgeInsets.symmetric(horizontal: 4.0),
  //       decoration: BoxDecoration(
  //           border: Border.all(color: Colors.blue), borderRadius: const BorderRadius.all(Radius.circular(10.0))),
  //       child: DropDownWidget(
  //         data: items,
  //         indexSelected: address?.city != null
  //             ? items.indexWhere((element) => element.value == address.city || element.id == address.city)
  //             : 0,
  //         //value: value,
  //         onChanged: (item, index) {
  //           setState(() {
  //             address.city = item.value;
  //           });
  //         },
  //         //isExpanded: true,
  //         //itemHeight: 70,
  //         label: S.of(context).city,
  //       ),
  //     );
  //   } else {
  //     return TextFormField(
  //       controller: _cityController,
  //       focusNode: _cityNode,
  //       validator: (val) {
  //         return val.isEmpty ? S.of(context).cityIsRequired : null;
  //       },
  //       decoration: InputDecoration(labelText: S.of(context).city),
  //       textInputAction: TextInputAction.done,
  //       // onFieldSubmitted: (_) =>
  //       //     FocusScope.of(context).requestFocus(_apartmentNode),
  //       onSaved: (String value) {
  //         address.city = value;
  //       },
  //     );
  //   }
  // }

  // Widget userNotLoggedInFields() {
  //   return FutureBuilder(
  //     future: _fetchData(),
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState != ConnectionState.done) {
  //         return Center(
  //           child: kLoadingWidget(context), //CircularProgressIndicator(),
  //         );
  //       }
  //       return Column(
  //         children: [
  //           renderStateInput(states),
  //           const SizedBox(height: 17.0),
  //           renderCityInput(states),
  //         ],
  //       );
  //     },
  //   );
  // }

  Future<void> _showMyDialog(
      BuildContext context, List<Address> savedAdresses) async {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AddAddressScreen(
        isEdit: false,
        savedAddresses: savedAdresses,
      ),
    ));

    // return showDialog<void>(
    //   context: context,
    //   barrierDismissible: false, // user must tap button!
    //   builder: (BuildContext context) => const AddAddressScreen(
    //     isEdit: false,
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        SafeArea(
          child: Container(
              //height: 150,
              child: Column(
            children: [
              const SizedBox(
                height: 12,
              ),
              ListTile(
                leading: const Icon(Icons.delivery_dining),
                title: Text(S.of(context).home_delivery),
                onTap: () async {
                  if (!widget.loggedIn) {
                    await Navigator.of(
                      context,
                      rootNavigator: true,
                    ).pushNamed(RouteList.login);
                  } else {
                    Navigator.of(context).pop();
                    return showModalBottomSheet(
                      useRootNavigator: true,
                      isScrollControlled: true,
                      context: context,
                      builder: (context) => ListenableProvider.value(
                        value: Provider.of<AddressModel>(context),
                        child: Consumer<AddressModel>(
                          builder: (context, value, child) {
                            print("list of addresses");
                            print(value.listAddress.length); 
                            print("==========");
                            if (value.isLoading) {
                              return Container(
                                height: 170,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            return Wrap(
                              children: [
                                SafeArea(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          S.of(context).chooseyouraddress,
                                          // "this place",
                                          style: TextStyle(
                                              fontSize: FontSize.xLarge.value,
                                              fontWeight: FontWeight.w900),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Container(
                                          height: 142,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount:
                                                value.listAddress.length + 1,
                                            itemBuilder: (context, index) {
                                              if (index + 1 ==
                                                  value.listAddress.length +
                                                      1) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: GestureDetector(
                                                    onTap: () => _showMyDialog(
                                                        context,
                                                        value.listAddress),
                                                    child: Container(
                                                      width: 130,
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              width: 0.5,
                                                              color: const Color(
                                                                  0xff306fb4)),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      2.0)),
                                                      child: Center(
                                                        child: Text(
                                                          S
                                                              .of(context)
                                                              .add_new_address,
                                                          style: const TextStyle(
                                                              color: Color(
                                                                  0xff306fb4),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w900),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      address = value
                                                          .listAddress[index];
                                                      Provider.of<CartModel>(
                                                              context,
                                                              listen: false)
                                                          .setAddress(address);
                                                      Provider.of<ClickNCollectProvider>(
                                                              context,
                                                              listen: false)
                                                          .setDeliveryTypeAndStoreId(
                                                              "",
                                                              "homedelivery");
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              5.0),
                                                      width: 130,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(2.0),
                                                        border: Border.all(
                                                            width: 0.5,
                                                            color: value.listAddress[
                                                                        index] ==
                                                                    Provider.of<CartModel>(
                                                                            context,
                                                                            listen:
                                                                                false)
                                                                        .address
                                                                ? const Color(
                                                                    0xffe59535)
                                                                : const Color(
                                                                    0xff306fb4)),
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            '${value.listAddress[index].firstName} ${value.listAddress[index].lastName}',
                                                            style: TextStyle(
                                                                fontSize:
                                                                    FontSize.medium.value,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w900),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                          const SizedBox(
                                                            height: 7.0,
                                                          ),
                                                          Text(
                                                            '${value.listAddress[index].street},',
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                          Text(
                                                            '${value.listAddress[index].city},',
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                          Text(
                                                            '${value.listAddress[index].state},',
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                          Text(
                                                            value
                                                                .listAddress[
                                                                    index]
                                                                .country!,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    );
                  }
                },
              ),
              if (widget.showPickOption)
                ListTile(
                  leading: const Icon(Icons.shopping_bag),
                  title: Text(S.of(context).click_and_collect),
                  onTap: () async {
                    // Navigator.of(context).pop();
                    if (widget.showPickOption) {
                      if (!widget.loggedIn) {
                        Navigator.of(context).pop();
                        await Navigator.of(
                          context,
                          rootNavigator: true,
                        ).pushNamed(RouteList.login);
                      } else if (Provider.of<CartModel>(context, listen: false)
                              .address?.street == "") {
                        // Navigator.of(context).pop();
                        await showAlertDialog(context);
                      } else {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ClickAndCollect()));
                      }
                    }  
                    //  else {

                    // _scaffoldKey.currentState.showSnackBar(snackBar);
                    // }
                  },
                )

              /* 
                ListTile(
                  leading: const Icon(Icons.shopping_bag),
                  title: Text(S.of(context).click_and_collect),
                  onTap: () {
                    Navigator.of(context).pop();
                    return showModalBottomSheet(
                      useRootNavigator: true,
                      isScrollControlled: true,
                      context: context,
                      builder: (context) => Wrap(
                        children: [
                          SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Choose your store',
                                    style: TextStyle(
                                        fontSize: FontSize.xLarge.size,
                                        fontWeight: FontWeight.w900),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          address = Address(
                                              state: S.of(context).rumaila);
                                          Provider.of<CartModel>(context,
                                                  listen: false)
                                              .setAddress(address);
                                          Navigator.of(context).pop();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5.0),
                                          width: 120,
                                          height: 120,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: const Color(0xff306fb4)),
                                          ),
                                          child: Center(
                                              child: Text(
                                            S.of(context).rumaila,
                                            style: const TextStyle(
                                                color: Color(0xff306fb4),
                                                fontWeight: FontWeight.w900),
                                          )),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                )*/
              // : Container(),
            ],
          )),
        ),
      ],
    );

    // bool loggedInn = Provider.of<UserModel>(context).loggedIn;

    // return AlertDialog(
    //   content: Container(
    //     // width: double.maxFinite,
    //     height: 380.0,
    //     width: 360.0,
    //     child: Form(
    //       key: _formKey,
    //       child: Column(
    //         mainAxisSize: MainAxisSize.min,
    //         children: <Widget>[
    //           Expanded(
    //             child: ListView(
    //               shrinkWrap: true,
    //               children: <Widget>[
    //                 Padding(
    //                   padding: const EdgeInsets.all(8.0),
    //                   child: Text(
    //                     S.of(context).delivery_mode,
    //                     textAlign: TextAlign.center,
    //                     style: const TextStyle(
    //                       fontStyle: FontStyle.normal,
    //                       fontSize: 18,
    //                       color: Colors.orange,
    //                       fontWeight: FontWeight.w400,
    //                     ),
    //                   ),
    //                 ),
    //                 const SizedBox(height: 17.0),
    //                 // dropdown for delivery mode
    //                 Container(
    //                   padding: const EdgeInsets.symmetric(horizontal: 4.0),
    //                   decoration: BoxDecoration(
    //                       border: Border.all(color: Colors.blue),
    //                       borderRadius: const BorderRadius.all(Radius.circular(10.0))),
    //                   child: DropDownWidget(
    //                     data: [
    //                       // DropDownWidgetItem(value: 'Click & Collect'),
    //                       DropDownWidgetItem(
    //                         value: S.of(context).home_delivery,
    //                       ),
    //                       DropDownWidgetItem(
    //                         value: S.of(context).click_and_collect,
    //                       ),
    //                     ],
    //                     indexSelected: selectedDeliveryMode,
    //                     onChanged: (item, indexSelected) {
    //                       setState(() {
    //                         selectedDeliveryMode = indexSelected;
    //                       });
    //                     },
    //                   ),
    //                 ),
    //                 const SizedBox(height: 17.0),
    //                 TextFormField(
    //                   readOnly: true,
    //                   decoration: InputDecoration(
    //                     contentPadding: const EdgeInsets.symmetric(
    //                       vertical: 10.0,
    //                       horizontal: 22.0,
    //                     ),
    //                     border: const OutlineInputBorder(
    //                       borderRadius: BorderRadius.all(Radius.circular(10.0)),
    //                     ),
    //                     enabledBorder: const OutlineInputBorder(
    //                       borderSide: BorderSide(color: Colors.blue, width: 1.0),
    //                       borderRadius: BorderRadius.all(Radius.circular(10.0)),
    //                     ),
    //                     hintText: S.of(context).Choose_your_country,
    //                     hintStyle: const TextStyle(fontSize: 12.0, color: Colors.blue),
    //                   ),
    //                   initialValue: "UAE",
    //                   validator: (value) {
    //                     if (value.isEmpty) {
    //                       return S.of(context).Please_select_your_country;
    //                     }
    //                     return null;
    //                   },
    //                 ),
    //                 const SizedBox(height: 17.0),
    //                 (selectedDeliveryMode == 0)
    //                     ? (!loggedInn)
    //                         ? userNotLoggedInFields()
    //                         : ListenableProvider.value(
    //                             value: Provider.of<AddressModel>(context),
    //                             child: Consumer<AddressModel>(
    //                               builder: (context, value, child) {
    //                                 if (value.isLoading) {
    //                                   return const Center(
    //                                     child: CircularProgressIndicator(),
    //                                   );
    //                                 }
    //                                 return Column(
    //                                   children: [
    //                                     Container(
    //                                       padding: const EdgeInsets.symmetric(horizontal: 4.0),
    //                                       decoration: BoxDecoration(
    //                                           border: Border.all(color: Colors.blue),
    //                                           borderRadius: const BorderRadius.all(Radius.circular(10.0))),
    //                                       child: value.errMsg != null
    //                                           ? Text(value.errMsg)
    //                                           : value.listAddress != null && value.listAddress.isNotEmpty
    //                                               ? DropDownWidget(
    //                                                   data: value.listAddress
    //                                                       .map((e) => DropDownWidgetItem(
    //                                                           value:
    //                                                               '${e.street}, ${e.city}, ${e.state}, ${e.country}'))
    //                                                       .toList(),
    //                                                   label: S.of(context).Choose_an_Address,
    //                                                   onChanged: (item, indexSelected) =>
    //                                                       address = value.listAddress[indexSelected],
    //                                                 )
    //                                               : Text(S.of(context).No_Addresses_found),
    //                                     ),
    //                                     const SizedBox(
    //                                       height: 10,
    //                                     ),
    //                                     StyleButton(
    //                                       color: Colors.blue,
    //                                       onPressed: () => _showMyDialog(context),
    //                                       //.then((_) {
    //                                       //setState(() {});
    //                                       //}),
    //                                       child: Text(
    //                                         S.of(context).add_new_address,
    //                                         style: const TextStyle(color: Colors.white),
    //                                       ),
    //                                     ),
    //                                   ],
    //                                 );
    //                               },
    //                             ),
    //                           )

    //                     // FutureBuilder(
    //                     //     future: _fetchData(),
    //                     //     builder: (context, snapshot) {
    //                     //       if (snapshot.connectionState !=
    //                     //           ConnectionState.done) {
    //                     //         return const Center(
    //                     //           child: CircularProgressIndicator(),
    //                     //         );
    //                     //       }
    //                     //       return Column(
    //                     //         children: [
    //                     //           Container(
    //                     //             padding: const EdgeInsets.symmetric(
    //                     //                 horizontal: 4.0),
    //                     //             decoration: BoxDecoration(
    //                     //                 border: Border.all(
    //                     //                     color: Colors.blue),
    //                     //                 borderRadius: const BorderRadius.all(
    //                     //                     Radius.circular(10.0))),
    //                     //             child: listAddress != null
    //                     //                 ? DropDownWidget(
    //                     //                     data: listAddress
    //                     //                         .map((e) => DropDownWidgetItem(
    //                     //                             value:
    //                     //                                 '${e.apartment}, ${e.street}, ${e.city}, ${e.state}, ${e.country}-${e.zipCode}'))
    //                     //                         .toList(),
    //                     //                     label: 'Choose an Address',
    //                     //                     onChanged:
    //                     //                         (item, indexSelected) =>
    //                     //                             address = listAddress[
    //                     //                                 indexSelected],
    //                     //                   )
    //                     //                 : const Text('No Addresses found'),
    //                     //           ),
    //                     //           const SizedBox(
    //                     //             height: 10,
    //                     //           ),
    //                     //           StyleButton(
    //                     //             color: Colors.blue,
    //                     //             onPressed: () =>
    //                     //                 _showMyDialog(context).then((_) {
    //                     //               setState(() {});
    //                     //             }),
    //                     //             child: const Text('Add an address'),
    //                     //           ),
    //                     //         ],
    //                     //       );
    //                     //     },
    //                     //   )
    //                     : Container(
    //                         padding: const EdgeInsets.symmetric(horizontal: 4.0),
    //                         decoration: BoxDecoration(
    //                             border: Border.all(color: Colors.blue),
    //                             borderRadius: const BorderRadius.all(Radius.circular(10.0))),
    //                         child: DropDownWidget(
    //                           data: [
    //                             DropDownWidgetItem(
    //                               value: S.of(context).rumaila,
    //                             )
    //                           ],
    //                           onChanged: (item, indexSelected) => address.state = item.value,
    //                         ),
    //                       ),
    //               ],
    //             ),
    //           )
    //         ],
    //       ),
    //     ),
    //   ),
    //   actions: <Widget>[
    //     FlatButton(
    //       child: Text(
    //         S.of(context).cancel,
    //         textAlign: TextAlign.center,
    //         style: const TextStyle(
    //           color: Colors.black,
    //           fontFamily: "Poppins",
    //           fontWeight: FontWeight.w400,
    //           fontSize: 12,
    //         ),
    //       ),
    //       color: Theme.of(context).primaryColorLight,
    //       shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadius.circular(10.0),
    //           side: const BorderSide(
    //             color: Colors.black12,
    //           )),
    //       height: 40,
    //       // shape: new RoundedRectangleBorder(
    //       //     borderRadius: new BorderRadius.circular(25.0),
    //       // ),
    //       onPressed: () {
    //         //Provider.of<CartModel>(context, listen: false).setAddress(address);
    //         Navigator.of(context).pop();
    //       },
    //     ),
    //     FlatButton(
    //       child: Text(
    //         S.of(context).save,
    //         textAlign: TextAlign.center,
    //         style: const TextStyle(
    //           color: Colors.white,
    //           fontFamily: "Poppins",
    //           fontWeight: FontWeight.w400,
    //           fontSize: 12,
    //         ),
    //       ),
    //       color: Colors.blue,
    //       height: 40,
    //       shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadius.circular(10.0),
    //           side: const BorderSide(
    //             color: Colors.blue,
    //           )),
    //       onPressed: () {
    //         Provider.of<CartModel>(context, listen: false).setAddress(address);
    //         // if (selectedDeliveryMode == 0) {
    //         //   result = address.city + ", " + address.state;
    //         // }
    //         Navigator.of(context).pop();
    //       },
    //     ),
    //   ],
    // );
  }
}
