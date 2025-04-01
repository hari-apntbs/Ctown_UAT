import 'package:ctown/models/app_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/constants.dart';
import '../../generated/l10n.dart';
import '../../models/address_model.dart';
import '../../models/index.dart' show Address, CartModel, User, UserModel;
import '../../services/index.dart';
import '../base.dart';

class ChooseAddress extends StatefulWidget {
  final void Function(Address) callback;

  ChooseAddress(this.callback);

  @override
  _StateChooseAddress createState() => _StateChooseAddress();
}

class _StateChooseAddress extends BaseScreen<ChooseAddress> {
  //List<Address> listAddress = [];
  User? user;

  // @override
  // void initState() {
  //   super.initState();
  //   getDatafromLocal();
  //   getUserInfo().then((_) {A
  //     getDataFromNetwork();
  //   });
  // }
  @override
  void afterFirstLayout(BuildContext context) {
    refreshMyAddresses();
  }

  void refreshMyAddresses() {
    final addressModel = Provider.of<AddressModel>(context, listen: false);
    final userModel = Provider.of<UserModel>(context, listen: false);
    if (userModel.loggedIn) {
      addressModel.getMyAddress(userModel: userModel,lang: Provider.of<AppModel>(context, listen: false).langCode);
    }

    //listAddress = addressModel.listAddress;
  }

  // Future<void> getUserInfo() async {
  //   final LocalStorage storage = LocalStorage("store");
  //   final userJson = storage.getItem(kLocalKey["userInfo"]);
  //   if (userJson != null) {
  //     final User user = await Services().getUserInfo(userJson['cookie']);
  //     user.isSocial = userJson['isSocial'] ?? false;
  //     user.id = userJson["id"];
  //     setState(() {
  //       this.user = user;
  //     });
  //   }
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
  //     setState(() {
  //       listAddress = _list;
  //     });
  //   } catch (_) {}
  // }

  // Future<void> getDataFromNetwork() async {
  //   try {
  //     var result = await Services().getCustomerInfo(user.id, user.cookie);

  //     if (result != null && result['addresses'] != null) {
  //       for (var address in result['addresses']) {
  //         final add = Address.fromMagentoJson(Map.from(address));
  //         listAddress.add(add);
  //       }
  //       setState(() {});
  //     }
  //   } catch (err) {
  //     printLog(err);
  //   }
  // }

  // void removeData(int index) {
  //   final LocalStorage storage = LocalStorage("address");
  //   try {
  //     var data = storage.getItem('data');
  //     if (data != null) {
  //       (data as List).removeAt(index);
  //     }
  //     storage.setItem('data', data);
  //   } catch (_) {}
  //   getDatafromLocal();
  // }

  Future<void> removeDataFromRemote(Address address) async {
    try {
      //UserModel userModel = Provider.of<UserModel>(context, listen: false);
      await Services().serviceApi?.deleteAddress(address);
      refreshMyAddresses();
      // await Provider.of<AddressModel>(context, listen: false)
      //     .getMyAddress(userModel: userModel);
      // await showDialog(
      //     context: context,
      //     builder: (BuildContext context) {
      //       return AlertDialog(
      //         title: Text(S.of(context).youHaveBeenSaveAddressYourLocal),
      //         actions: <Widget>[
      //           FlatButton(
      //             child: Text(
      //               S.of(context).ok,
      //               style: TextStyle(color: Theme.of(context).primaryColor),
      //             ),
      //             onPressed: () {
      //               Navigator.of(context).pop();
      //             },
      //           )
      //         ],
      //       );
      //     });
    } catch (e) {
      printLog(e);
    }
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
            )
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

  Widget _renderBillingAddress() {
    if (user == null || user!.billing == null) {
      return Container();
    }
    return GestureDetector(
      onTap: () {
        final add = Address(
            firstName: user!.billing!.firstName!.isNotEmpty
                ? user!.billing!.firstName
                : user!.firstName,
            lastName: user!.billing!.lastName!.isNotEmpty
                ? user!.billing!.lastName
                : user!.lastName,
            email:
                user!.billing!.email!.isNotEmpty ? user!.billing!.email : user!.email,
            street: user!.billing!.street,
            country: user!.billing!.country,
            state: user!.billing!.state,
            phoneNumber: user!.billing!.phoneNumber,
            city: user!.billing!.city,
            zipCode: user!.billing!.zipCode);
        Provider.of<CartModel>(context, listen: false).setAddress(add);
        Navigator.of(context).pop();
        widget.callback(add);
      },
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).primaryColorLight,
            borderRadius: BorderRadius.circular(10)),
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              S.of(context).billingAddress,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text(user!.billing!.firstName! + ' ' + user!.billing!.lastName!),
            Text(user!.billing!.phoneNumber!),
            Text(user!.billing!.email!),
            Text(user!.billing!.street!),
            Text(user!.billing!.city!),
            Text(user!.billing!.zipCode!)
          ],
        ),
      ),
    );
  }

  Widget _renderShippingAddress() {
    if (user == null || user!.shipping == null) return Container();
    return GestureDetector(
      onTap: () {
        final add = Address(
            firstName: user!.shipping!.firstName!.isNotEmpty
                ? user!.shipping!.firstName
                : user!.firstName,
            lastName: user!.shipping!.lastName!.isNotEmpty
                ? user!.shipping!.lastName
                : user!.lastName,
            email: user!.email,
            street: user!.shipping!.street,
            country: user!.shipping!.country,
            state: user!.shipping!.state,
            city: user!.shipping!.city,
            zipCode: user!.shipping!.zipCode);
        Provider.of<CartModel>(context, listen: false).setAddress(add);
        Navigator.of(context).pop();
        widget.callback(add);
      },
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).primaryColorLight,
            borderRadius: BorderRadius.circular(10)),
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              S.of(context).shippingAddress,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text(user!.shipping!.firstName! + ' ' + user!.shipping!.lastName!),
            Text(user!.shipping!.street!),
            Text(user!.shipping!.city!),
            Text(user!.shipping!.zipCode!)
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          S.of(context).selectAddress,
          style: const TextStyle(
            fontSize: 16.0,
            color: Colors.white,
          ),
        ),
        leading: GestureDetector(
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onTap: () => Navigator.pop(context),
        ),
      ),
      body: ListenableProvider.value(
        value: Provider.of<AddressModel>(context),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              _renderBillingAddress(),
              _renderShippingAddress(),
              Consumer<AddressModel>(
                builder: (context, addressModel, child) {
                  if (addressModel.isLoading) {
                    return kLoadingWidget(context);
                  }
                  if (addressModel.errMsg != null) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(addressModel.errMsg!),
                    );
                  }
                  return Column(
                    children: [
                      if (addressModel.listAddress.isEmpty)
                        Image.asset(
                          kEmptySearch,
                          width: 120,
                          height: 120,
                        ),
                      ...List.generate(addressModel.listAddress.length,
                          (index) {
                        return Padding(
                          padding: const EdgeInsets.all(10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: GestureDetector(
                              onTap: () {
                                Provider.of<CartModel>(context, listen: false)
                                    .setAddress(
                                        addressModel.listAddress[index]);
                                Navigator.of(context).pop();
                                widget
                                    .callback(addressModel.listAddress[index]);
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColorLight),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    children: <Widget>[
                                      Padding(
                                        child: Icon(
                                          Icons.home,
                                          color: Theme.of(context).primaryColor,
                                          size: 18,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: convertToCard(context,
                                            addressModel.listAddress[index]),
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          //removeData(index);
                                          var add =
                                              await Provider.of<CartModel>(
                                                      context,
                                                      listen: false)
                                                  .getAddress(Provider.of<AppModel>(context, listen: false).langCode ?? "en");
                                          if (add ==
                                              addressModel.listAddress[index]) {
                                            Provider.of<CartModel>(context,
                                                    listen: false)
                                                .setAddress(Address());
                                          }
                                          await removeDataFromRemote(
                                              addressModel.listAddress[index]);
                                        },
                                        child: Icon(
                                          Icons.delete,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      })
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
