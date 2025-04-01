import 'package:ctown/models/address_model.dart';
import 'package:ctown/screens/settings/check_deliverable.dart';
import 'package:ctown/screens/settings/selected_store_model.dart';
import 'package:ctown/widgets/home/add_address_screen.dart';
import 'package:ctown/widgets/home/clickandcollect_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/constants.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart';
import '../base.dart';

class AddressSelectorWidget extends StatefulWidget {
  final showPickOption;

  const AddressSelectorWidget(this.showPickOption, {Key? key}) : super(key: key);
  @override
  _AddressSelectorWidgetState createState() => _AddressSelectorWidgetState();
}

class _AddressSelectorWidgetState extends BaseScreen<AddressSelectorWidget> {
  late String whatsapp, url;
  Future<void> _showMyDialog(BuildContext context, List<Address> savedAdresses) async {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AddAddressScreen(
        isEdit: false,
        savedAddresses: savedAdresses,
      ),
    ));
  }

//
  showAlertDialog(BuildContext context) async {
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text("Let's"),
      onPressed: () {},
    );

    AlertDialog alert = AlertDialog(
      title: Text("Add an address"),
      content: Text("Please have atleast one address before selecting click and collect"),
      actions: [
        cancelButton,
        // continueButton,
      ],
    );

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _launchWhatsapp() async {
    const url = "https://api.whatsapp.com/send/?phone=96265514480&text=Your+Message+here&app_absent=0";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void afterFirstLayout(BuildContext context) {
    final userModel = Provider.of<UserModel>(context, listen: false);
    if (userModel.loggedIn) {
      Provider.of<AddressModel>(context, listen: false)
          .getMyAddress(userModel: userModel, lang: Provider.of<AppModel>(context, listen: false).langCode);
    }
  }

  SelectedStoreModel? storemodel;

  String? name;

  void loadStoreName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var store1 = prefs.getString('savedStore1');
    printLog("vengadzh");
    setState(() {
      name = store1;
    });
  }


  @override
  void initState() {
    super.initState();
    loadStoreName();
    whatsapp = "96265514480";
    url = "https://api.whatsapp.com/send/?phone=$whatsapp&text=Your+Message+here&type=phone_number&app_absent=0";
  }

//
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Positioned(
            left: 0,
            top: 5,
            right: 0,
            bottom: 0,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: !Provider.of<AppModel>(context, listen: false).darkTheme
                    ? Colors.grey[300]
                    : Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.all(Radius.circular(0)),
              ),
              child: Container(),
            ),
          ),
          Positioned(
            top: 6,
            right: 5,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 8,
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    width: 33,
                    height: 33,
                    margin: const EdgeInsets.only(
                      top: 5,
                    ),
                    child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: const Color.fromARGB(0, 0, 0, 0),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(0)),
                          ),
                          foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                          padding: const EdgeInsets.all(0),
                        ),
                        onPressed: () async {
                          var loggedIn = Provider.of<UserModel>(context, listen: false).loggedIn;
//
                          Address address = Address();
                          print(Provider.of<AddressModel>(context, listen: false).listAddress);
                          print("*********");
                          if (!loggedIn) {
                            await Navigator.of(
                              context,
                              rootNavigator: true,
                            ).pushNamed(RouteList.login);
                          } else {
                            // Navigator.of(context).pop();
                            return showModalBottomSheet(
                              useRootNavigator: true,
                              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                              // isScrollControlled: true,
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
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  S.of(context).chooseyouraddress,
                                                  // "this place",
                                                  style: TextStyle(fontSize: FontSize.xLarge.value, fontWeight: FontWeight.w900),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Container(
                                                  height: 142,
                                                  child: ListView.builder(
                                                    scrollDirection: Axis.horizontal,
                                                    itemCount: value.listAddress.length + 1,
                                                    itemBuilder: (context, index) {
                                                      if (index + 1 == value.listAddress.length + 1) {
                                                        return Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: GestureDetector(
                                                            onTap: () => _showMyDialog(context, value.listAddress),
                                                            child: Container(
                                                              width: 130,
                                                              decoration: BoxDecoration(
                                                                  border: Border.all(width: 0.5, color: const Color(0xff306fb4)),
                                                                  borderRadius: BorderRadius.circular(2.0)),
                                                              child: Center(
                                                                child: Text(
                                                                  S.of(context).add_new_address,
                                                                  style: const TextStyle(color: Color(0xff306fb4), fontWeight: FontWeight.w900),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      } else {
                                                        return Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: GestureDetector(
                                                            onTap: () {
                                                              address = value.listAddress[index];
                                                              Provider.of<CartModel>(context, listen: false).setAddress(address);
                                                              Provider.of<ClickNCollectProvider>(context, listen: false)
                                                                  .setDeliveryTypeAndStoreId("", "homedelivery");
                                                              Navigator.of(context).pop();
                                                            },
                                                            child: Container(
                                                              padding: const EdgeInsets.all(5.0),
                                                              width: 130,
                                                              decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.circular(2.0),
                                                                border: Border.all(
                                                                    width: 0.5,
                                                                    color: value.listAddress[index] ==
                                                                            Provider.of<CartModel>(context, listen: false).address
                                                                        ? const Color(0xffe59535)
                                                                        : const Color(0xff306fb4)),
                                                              ),
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Text(
                                                                    '${value.listAddress[index].firstName} ${value.listAddress[index].lastName}',
                                                                    style: TextStyle(fontSize: FontSize.medium.value, fontWeight: FontWeight.w900),
                                                                    overflow: TextOverflow.ellipsis,
                                                                    maxLines: 1,
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 7.0,
                                                                  ),
                                                                  Text(
                                                                    '${value.listAddress[index].street},',
                                                                    overflow: TextOverflow.ellipsis,
                                                                    maxLines: 1,
                                                                  ),
                                                                  Text(
                                                                    '${value.listAddress[index].city},',
                                                                    overflow: TextOverflow.ellipsis,
                                                                    maxLines: 1,
                                                                  ),
                                                                  Text(
                                                                    '${value.listAddress[index].state},',
                                                                    overflow: TextOverflow.ellipsis,
                                                                    maxLines: 1,
                                                                  ),
                                                                  Text(
                                                                    value.listAddress[index].country!,
                                                                    overflow: TextOverflow.ellipsis,
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
                          // return _showMyDialog(context, loggedIn);
                        },
                        child: Image.asset(
                            Provider.of<ClickNCollectProvider>(
                                      context,
                                    ).deliveryType ==
                                    "homedelivery"
                                ? "assets/images/Bike Red.png"
                                : "assets/images/Bike Green.png",
                            height: 30)),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                const SizedBox(width: 10),
                const Align(
                  alignment: Alignment.topRight,
                ),
              ],
            ),
          ),
          Positioned(
              left: 5,
              bottom: 3,
              height: 40,
              child: InkWell(
                onTap: () async {
                  printLog("clicked");
                  if (!await launch(url)) {
                    throw 'Could not launch $url';
                  }
                  await launch(url);
                },
                child: Container(
                  child: Image.asset(
                    "assets/images/whatsapp.png",
                  ),
                ),
              )),
          Positioned(
              top: 18,
              left: 60,
              child: InkWell(
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (context) => const UserManualStoreSelectionScreen(fromHome: true,)));
                  },
                  child: name != null && name != ""?
                  Center(child: Text(name != null ? "${name!.substring(1, name!.length - 1)} ▼" : ''))
              : Container())),
        ],
      ),
    );
  }
}
