// ignore: prefer_relative_imports
import 'dart:io';

import 'package:ctown/models/address_model.dart';
import 'package:ctown/models/app_model.dart';
// ignore: prefer_relative_imports
import 'package:ctown/models/user_model.dart';
// ignore: prefer_relative_imports
import 'package:ctown/screens/base.dart';
// ignore: prefer_relative_imports
import 'package:ctown/widgets/home/add_address_screen.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:scrolls_to_top/scrolls_to_top.dart';

import '../../common/constants.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart' show Address, CartModel, User;
import '../../services/index.dart';

class AddressBook extends StatefulWidget {
  // final void Function(Address) callback;

  // AddressBook(this.callback);
  final bool? showAdd;
  AddressBook({
    this.showAdd,
  });
  @override
  _StateAddressBook createState() => _StateAddressBook();
}

class _StateAddressBook extends BaseScreen<AddressBook> {
  List<Address> listAddress = [];
  //User user;
  Address? selectedAddress;

  final ScrollController _scrollController = ScrollController();

  // @override
  // void initState() {
  //   super.initState();
  //   getDatafromLocal();
  //   getUserInfo().then((_) {
  //     getDataFromNetwork();
  //   });
  // }

  @override
  void afterFirstLayout(BuildContext context) {
    listAddress = Provider.of<AddressModel>(context, listen: false).listAddress;
    refreshMyAddresses();
  }

  void refreshMyAddresses() {
    Provider.of<AddressModel>(context, listen: false)
        .getMyAddress(userModel: Provider.of<UserModel>(context, listen: false), lang: Provider.of<AppModel>(context, listen: false).langCode);
  }


  Future<void> removeData(int index) async {
    final LocalStorage storage = LocalStorage("address");
    print("LocalStorage Delete ${LocalStorage("address")}");
    try {
      var data = await storage.getItem('data');
      if (data != null) {
        (data as List).removeAt(index);
      }
      storage.setItem('data', data);
    } catch (_) {}
    //getDatafromLocal();
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
            Flexible(
              child: Column(
                children: <Widget>[
                  Text(
                    "${address.buildingNo == null ? '' : address.buildingNo} ,${address.apartment == null ? '' : address.apartment}",
                    style: TextStyle(color: Provider.of<AppModel>(context, listen: false).darkTheme ? Colors.white : Colors.black),
                  )
                ],
              ),
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Text(
            //   "${s.streetName}:  ",
            //   style: TextStyle(color: Theme.of(context).primaryColor),
            // ),
            Flexible(
              child: Column(
                children: <Widget>[
                  Text(
                    "${address.street == null ? '' : address.street} ${address.streetNo == null ? '' : address.streetNo}",
                    style: TextStyle(color: Provider.of<AppModel>(context, listen: false).darkTheme ? Colors.white : Colors.black),
                  )
                ],
              ),
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Text(
            //   "${s.city}:  ",
            //   style: TextStyle(color: Theme.of(context).primaryColor),
            // ),
            Flexible(
              child: Column(
                children: <Widget>[
                  Text(
                    "${address.city == null ? '' : address.city}, ${address.state == null ? '' : address.state}",
                    style: TextStyle(color: Provider.of<AppModel>(context, listen: false).darkTheme ? Colors.white : Colors.black),
                  )
                ],
              ),
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Text(
            //   "${s.country}:  ",
            //   style: TextStyle(color: Theme.of(context).primaryColor),
            // ),
            Flexible(
              child: Column(
                children: <Widget>[
                  Text(
                    "${address.country}",
                    style: TextStyle(color: Provider.of<AppModel>(context, listen: false).darkTheme ? Colors.white : Colors.black),
                  )
                ],
              ),
            )
          ],
        ),
        // const SizedBox(height: 4.0),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "${s.phone}:  ",
              style: TextStyle(color: Provider.of<AppModel>(context, listen: false).darkTheme ? Colors.white : Colors.black),
              // style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            Flexible(
              child: Column(
                children: <Widget>[
                  Text(
                    "${address.phoneNumber}",
                    style: TextStyle(color: Provider.of<AppModel>(context, listen: false).darkTheme ? Colors.white : Colors.black),
                  )
                ],
              ),
            )
          ],
        ),
        const SizedBox(height: 10.0),
      ],
    );
  }


  Future<void> _showMyDialog(BuildContext context, bool isEdit) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) => AddAddressScreen(
        isEdit: isEdit,
        savedAddresses: Provider.of<AddressModel>(context, listen: false).listAddress,
      ),
    );
  }

  Future<void> removeDataFromRemote(Address address) async {
    try {
      UserModel userModel = Provider.of<UserModel>(context, listen: false);
      await Services().serviceApi?.deleteAddress(address);
      await Provider.of<AddressModel>(context, listen: false)
          .getMyAddress(userModel: userModel, lang: Provider.of<AppModel>(context, listen: false).langCode);
    } catch (e) {
      printLog(e);
    }
  }

  Future<void> _onScrollsToTop(ScrollsToTopEvent event) async {
    _scrollController.animateTo(0, duration: const Duration(milliseconds: 1000), curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    // final bool showAdd = widget.showAdd ?? false;
    return Platform.isIOS
        ? ScrollsToTop(
            onScrollsToTop: _onScrollsToTop,
            child: Scaffold(
              appBar: AppBar(
                title: Text(
                  S.of(context).addressBook,
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
                  onTap: () => Navigator.pop(context, true),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () => _showMyDialog(context, false),
                      child: SizedBox(
                        width: 40,
                        child: Icon(
                          Icons.add,
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              body: ListenableProvider.value(
                value: Provider.of<AddressModel>(context),
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        children: <Widget>[
                          Consumer<AddressModel>(
                            builder: (context, model, child) {
                              // final cartAddress = await Provider.of<CartModel>(context, listen: false).getAddress();
                              return Container(
                                color: Colors.transparent,
                                margin: model.listAddress.isEmpty
                                    ? EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.36)
                                    : const EdgeInsets.all(10.0),
                                padding: const EdgeInsets.only(top: 10.0),
                                child: model.listAddress.isEmpty
                                    ? /*Image.asset(kEmptySearch, width: 120, height: 120)*/ const Center(child: Text("Address list is empty"))
                                    : FutureBuilder<Address?>(
                                        future: Provider.of<CartModel>(context, listen: false)
                                            .getAddress(Provider.of<AppModel>(context, listen: false).langCode ?? "en"),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState != ConnectionState.done) {
                                            return const Center(
                                              child: CircularProgressIndicator(),
                                            );
                                          }
                                          if (snapshot.hasData && model.listAddress.isNotEmpty) {
                                            if (model.listAddress.contains(snapshot.data)) {
                                              selectedAddress = snapshot.data;
                                              print("My test");
                                              print("Total Length: ${model.listAddress.length}");
                                            } else {
                                              selectedAddress = model.listAddress[0];
                                            }
                                          }
                                          return StatefulBuilder(builder: (BuildContext context, setState) {
                                            return Stack(
                                              children: [
                                                Column(
                                                  children: [
                                                    ...List.generate(
                                                      model.listAddress.length,
                                                      (index) {
                                                        var add = model.listAddress[index];

                                                        return Column(
                                                          children: [
                                                            RadioListTile<Address>(
                                                              activeColor: Theme.of(context).primaryColor,
                                                              value: model.listAddress[index],
                                                              groupValue: selectedAddress,
                                                              onChanged: (value) {
                                                                setState(() {
                                                                  selectedAddress = value;
                                                                });
                                                              },
                                                              title: Text(
                                                                '${add.firstName} ${add.lastName}',
                                                                style: TextStyle(
                                                                    fontSize: 14,
                                                                    fontWeight: FontWeight.bold,
                                                                    color: Provider.of<AppModel>(context, listen: false).darkTheme
                                                                        ? Colors.white
                                                                        : Colors.black),
                                                              ),
                                                              subtitle: convertToCard(context, add),
                                                            ),
                                                            if (selectedAddress == add)
                                                              Column(
                                                                children: [
                                                                  SizedBox(
                                                                    height: 40,
                                                                    width: MediaQuery.of(context).size.width * 0.85,
                                                                    child: ElevatedButton(
                                                                      onPressed: () async {
                                                                        await Provider.of<CartModel>(context, listen: false)
                                                                            .setAddress(model.listAddress[index]);
                                                                        Navigator.of(context).pop();
                                                                        // Navigator.of(context, rootNavigator: true)
                                                                        //     .pushReplacementNamed(RouteList.dashboard);
                                                                      },
                                                                      style: ElevatedButton.styleFrom(
                                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
                                                                        padding: const EdgeInsets.all(0.0),
                                                                      ),
                                                                      child: Ink(
                                                                        decoration: BoxDecoration(
                                                                          gradient: LinearGradient(
                                                                              begin: Alignment.topCenter,
                                                                              end: Alignment.bottomCenter,
                                                                              colors: [
                                                                                Theme.of(context).primaryColor,
                                                                                Theme.of(context).primaryColor,
                                                                              ]),
                                                                          borderRadius: const BorderRadius.all(Radius.circular(40.0)),
                                                                          // border: Border.all(color: Colors.black45),
                                                                        ),
                                                                        child: Container(
                                                                          constraints: const BoxConstraints(
                                                                              minWidth: 88.0, minHeight: 36.0), // min sizes for Material buttons
                                                                          alignment: Alignment.center,
                                                                          child: Text(
                                                                            S.of(context).delivertothisaddress,
                                                                            style: const TextStyle(
                                                                                color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                                                                            textAlign: TextAlign.center,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                  SizedBox(
                                                                    height: 40,
                                                                    width: MediaQuery.of(context).size.width * 0.85,
                                                                    child: ElevatedButton(
                                                                      onPressed: () async {
                                                                        await Provider.of<CartModel>(context, listen: false)
                                                                            .setAddress(model.listAddress[index]);
                                                                        print("My test");
                                                                        print(
                                                                            "Length: ${Provider.of<AddressModel>(context, listen: false).listAddress.length}");
                                                                        _showMyDialog(context, true);
                                                                      },
                                                                      style: ElevatedButton.styleFrom(
                                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
                                                                        padding: const EdgeInsets.all(0.0),
                                                                      ),
                                                                      child: Ink(
                                                                        decoration: const BoxDecoration(
                                                                          gradient: LinearGradient(
                                                                            begin: Alignment.topCenter,
                                                                            end: Alignment.bottomCenter,
                                                                            colors: [Colors.white, Color(0xeaffffff)],
                                                                          ),
                                                                          borderRadius: BorderRadius.all(Radius.circular(40.0)),
                                                                          // border: Border.all(color: Colors.black45),
                                                                        ),
                                                                        child: Container(
                                                                          constraints: const BoxConstraints(
                                                                              minWidth: 88.0, minHeight: 36.0), // min sizes for Material buttons
                                                                          alignment: Alignment.center,
                                                                          child: Text(
                                                                            S.of(context).editaddress,
                                                                            textAlign: TextAlign.center,
                                                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                  SizedBox(
                                                                    height: 40,
                                                                    width: MediaQuery.of(context).size.width * 0.85,
                                                                    child: ElevatedButton(
                                                                      onPressed: () async {
                                                                        await removeDataFromRemote(model.listAddress[index]);
                                                                        printLog("My test 2");
                                                                        printLog(
                                                                            "Length: ${Provider.of<AddressModel>(context, listen: false).listAddress.length}");
                                                                        listAddress.removeAt(index);
                                                                        await Provider.of<CartModel>(context, listen: false).setAddress(listAddress);
                                                                        printLog("My test 2");
                                                                        printLog(
                                                                            "Length: ${Provider.of<AddressModel>(context, listen: false).listAddress.length}");
                                                                        printLog(Provider.of<CartModel>(context, listen: false).address);
                                                                      },
                                                                      style: ElevatedButton.styleFrom(
                                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
                                                                        padding: const EdgeInsets.all(0.0),
                                                                      ),
                                                                      child: Ink(
                                                                        decoration: const BoxDecoration(
                                                                          gradient:  LinearGradient(
                                                                              begin: Alignment.topCenter,
                                                                              end: Alignment.bottomCenter,
                                                                              colors: [Colors.white, Color(0xeaffffff)]),
                                                                          borderRadius:  BorderRadius.all(Radius.circular(40.0)),
                                                                          // border: Border.all(color: Colors.black45),
                                                                        ),
                                                                        child: Container(
                                                                          constraints: const BoxConstraints(
                                                                              minWidth: 88.0, minHeight: 36.0), // min sizes for Material buttons
                                                                          alignment: Alignment.center,
                                                                          child: Text(
                                                                            S.of(context).deleteaddress,
                                                                            textAlign: TextAlign.center,
                                                                            style: const TextStyle(
                                                                                color: Colors.red, fontSize: 14, fontWeight: FontWeight.w600),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                ],
                                                              ),
                                                            if (index != model.listAddress.length - 1)
                                                              const Divider(
                                                                thickness: 1.5,
                                                              ),
                                                          ],
                                                        );
                                                      },
                                                    )
                                                  ],
                                                ),
                                                model.isLoading
                                                    ? Container(
                                                        width: MediaQuery.of(context).size.width,
                                                        height: MediaQuery.of(context).size.height,
                                                        color: Colors.black.withOpacity(0.2),
                                                        child: Center(
                                                          child: kLoadingWidget(context),
                                                        ),
                                                      )
                                                    : Container()
                                              ],
                                            );
                                          });
                                        }),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text(
                S.of(context).addressBook,
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
                onTap: () => Navigator.pop(context, true),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () => _showMyDialog(context, false),
                    child: Container(
                      // decoration: BoxDecoration(
                      //   color: Colors.white,
                      //   borderRadius: BorderRadius.circular(40.0),
                      // ),
                      width: 40,
                      child: Icon(
                        Icons.add,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: ListenableProvider.value(
              value: Provider.of<AddressModel>(context),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Consumer<AddressModel>(
                          builder: (context, model, child) {
                            // final cartAddress = await Provider.of<CartModel>(context, listen: false).getAddress();
                            return Container(
                              margin: model.listAddress.isEmpty
                                  ? EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.36)
                                  : const EdgeInsets.all(10.0),
                              padding: const EdgeInsets.only(top: 10.0),
                              child: model.listAddress.isEmpty
                                  ? /*Image.asset(kEmptySearch, width: 120, height: 120)*/ const Center(child: Text("Address list is empty"))
                                  : FutureBuilder<Address?>(
                                      future: Provider.of<CartModel>(context, listen: false)
                                          .getAddress(Provider.of<AppModel>(context, listen: false).langCode ?? "en"),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState != ConnectionState.done) {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }
                                        if (snapshot.hasData && model.listAddress.isNotEmpty) {
                                          if (model.listAddress.contains(snapshot.data)) {
                                            selectedAddress = snapshot.data;
                                            print("My test");
                                            print("Total Length: ${model.listAddress.length}");
                                          } else {
                                            selectedAddress = model.listAddress[0];
                                          }
                                        }
                                        return StatefulBuilder(builder: (BuildContext context, setState) {
                                          return Stack(
                                            children: [
                                              Column(
                                                children: [
                                                  ...List.generate(
                                                    model.listAddress.length,
                                                    (index) {
                                                      var add = model.listAddress[index];

                                                      return Column(
                                                        children: [
                                                          RadioListTile<Address>(
                                                            activeColor: Theme.of(context).primaryColor,
                                                            value: model.listAddress[index],
                                                            groupValue: selectedAddress,
                                                            onChanged: (value) {
                                                              setState(() {
                                                                selectedAddress = value;
                                                              });
                                                            },
                                                            title: Text(
                                                              '${add.firstName} ${add.lastName}',
                                                              style: TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Provider.of<AppModel>(context, listen: false).darkTheme
                                                                      ? Colors.white
                                                                      : Colors.black),
                                                            ),
                                                            subtitle: convertToCard(context, add),
                                                          ),
                                                          if (selectedAddress == add)
                                                            Column(
                                                              children: [
                                                                SizedBox(
                                                                  height: 40,
                                                                  width: MediaQuery.of(context).size.width * 0.85,
                                                                  child: ElevatedButton(
                                                                    onPressed: () async {
                                                                      await Provider.of<CartModel>(context, listen: false)
                                                                          .setAddress(model.listAddress[index]);
                                                                      Navigator.of(context).pop();
                                                                      // Navigator.of(context, rootNavigator: true)
                                                                      //     .pushReplacementNamed(RouteList.dashboard);
                                                                    },
                                                                    style: ElevatedButton.styleFrom(
                                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
                                                                      padding: const EdgeInsets.all(0.0),
                                                                    ),
                                                                    child: Ink(
                                                                      decoration: BoxDecoration(
                                                                        gradient: LinearGradient(
                                                                            begin: Alignment.topCenter,
                                                                            end: Alignment.bottomCenter,
                                                                            colors: [
                                                                              Theme.of(context).primaryColor,
                                                                              Theme.of(context).primaryColor,
                                                                            ]),
                                                                        borderRadius: const BorderRadius.all(Radius.circular(40.0)),
                                                                        // border: Border.all(color: Colors.black45),
                                                                      ),
                                                                      child: Container(
                                                                        constraints: const BoxConstraints(
                                                                            minWidth: 88.0, minHeight: 36.0), // min sizes for Material buttons
                                                                        alignment: Alignment.center,
                                                                        child: Text(
                                                                          S.of(context).delivertothisaddress,
                                                                          style: const TextStyle(
                                                                              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                                                                          textAlign: TextAlign.center,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                                SizedBox(
                                                                  height: 40,
                                                                  width: MediaQuery.of(context).size.width * 0.85,
                                                                  child: ElevatedButton(
                                                                    onPressed: () async {
                                                                      await Provider.of<CartModel>(context, listen: false)
                                                                          .setAddress(model.listAddress[index]);
                                                                      print("My test");
                                                                      print(
                                                                          "Length: ${Provider.of<AddressModel>(context, listen: false).listAddress.length}");
                                                                      _showMyDialog(context, true);
                                                                    },
                                                                    style: ElevatedButton.styleFrom(
                                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
                                                                      padding: const EdgeInsets.all(0.0),
                                                                    ),
                                                                    child: Ink(
                                                                      decoration: const BoxDecoration(
                                                                        gradient: LinearGradient(
                                                                          begin: Alignment.topCenter,
                                                                          end: Alignment.bottomCenter,
                                                                          colors: [Colors.white, Color(0xeaffffff)],
                                                                        ),
                                                                        borderRadius:  BorderRadius.all(Radius.circular(40.0)),
                                                                        // border: Border.all(color: Colors.black45),
                                                                      ),
                                                                      child: Container(
                                                                        constraints: const BoxConstraints(
                                                                            minWidth: 88.0, minHeight: 36.0), // min sizes for Material buttons
                                                                        alignment: Alignment.center,
                                                                        child: Text(
                                                                          S.of(context).editaddress,
                                                                          textAlign: TextAlign.center,
                                                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                                SizedBox(
                                                                  height: 40,
                                                                  width: MediaQuery.of(context).size.width * 0.85,
                                                                  child: ElevatedButton(
                                                                    onPressed: () async {
                                                                      await removeDataFromRemote(model.listAddress[index]);
                                                                      printLog("My test 2");
                                                                      printLog(
                                                                          "Length: ${Provider.of<AddressModel>(context, listen: false).listAddress.length}");
                                                                      listAddress.removeAt(index);
                                                                      await Provider.of<CartModel>(context, listen: false).setAddress(listAddress);
                                                                      printLog("My test 2");
                                                                      printLog(
                                                                          "Length: ${Provider.of<AddressModel>(context, listen: false).listAddress.length}");
                                                                      printLog(Provider.of<CartModel>(context, listen: false).address);
                                                                    },
                                                                    style: ElevatedButton.styleFrom(
                                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
                                                                      padding: const EdgeInsets.all(0.0),
                                                                    ),
                                                                    child: Ink(
                                                                      decoration: const BoxDecoration(
                                                                        gradient: LinearGradient(
                                                                            begin: Alignment.topCenter,
                                                                            end: Alignment.bottomCenter,
                                                                            colors: [Colors.white, Color(0xeaffffff)]),
                                                                        borderRadius: BorderRadius.all(Radius.circular(40.0)),
                                                                        // border: Border.all(color: Colors.black45),
                                                                      ),
                                                                      child: Container(
                                                                        constraints: const BoxConstraints(
                                                                            minWidth: 88.0, minHeight: 36.0), // min sizes for Material buttons
                                                                        alignment: Alignment.center,
                                                                        child: Text(
                                                                          S.of(context).deleteaddress,
                                                                          textAlign: TextAlign.center,
                                                                          style: const TextStyle(
                                                                              color: Colors.red, fontSize: 14, fontWeight: FontWeight.w600),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                              ],
                                                            ),
                                                          if (index != model.listAddress.length - 1)
                                                            const Divider(
                                                              thickness: 1.5,
                                                            ),
                                                        ],
                                                      );
                                                    },
                                                  )
                                                ],
                                              ),
                                              model.isLoading
                                                  ? Container(
                                                      width: MediaQuery.of(context).size.width,
                                                      height: MediaQuery.of(context).size.height,
                                                      color: Colors.black.withOpacity(0.2),
                                                      child: Center(
                                                        child: kLoadingWidget(context),
                                                      ),
                                                    )
                                                  : Container()
                                            ],
                                          );
                                        });
                                      }),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
