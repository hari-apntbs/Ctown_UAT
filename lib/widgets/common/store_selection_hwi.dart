import 'package:ctown/common/constants.dart';
import 'package:ctown/models/entities/address.dart';
import 'package:ctown/models/entities/states.dart';
import 'package:ctown/services/index.dart';
import 'package:ctown/widgets/dropdown_widget.dart';
import 'package:flutter/material.dart';

import '../../generated/l10n.dart';

class StoreSelectionHwi extends StatefulWidget {
  const StoreSelectionHwi({Key? key}) : super(key: key);

  @override
  State<StoreSelectionHwi> createState() => _StoreSelectionHwiState();
}

class _StoreSelectionHwiState extends State<StoreSelectionHwi> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final _cityNode = FocusNode();
  Future? myFuture;
  List<dynamic> states = [];
  List<Area>? cities = [];
  List<String?> location = [];
  Address address = Address();
  bool isLoading = true;

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

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).primaryColor),
            borderRadius: const BorderRadius.all(Radius.circular(10.0))),
        child: DropdownButtonHideUnderline(
          child: DropdownButtonFormField<DropDownWidgetItem>(
            items: items,
            value: address?.state != null
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
                _stateController.text = item.value!;
                location.add(item.value);
              });
            },
            decoration: InputDecoration(
              labelText: S.of(context).stateProvince,
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
        controller: _stateController,
        style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 14),
        validator: (val) {
          return val!.isEmpty ? S.of(context).stateIsRequired : null;
        },
        decoration: InputDecoration(labelText: S.of(context).stateProvince),
        onSaved: (String? value) {
          address.state = value;
          address.state_id = value;
          _stateController.text = value!;
          location.add(value);
        },
      );
    }
  }

  Widget renderCityInput() {
    if (states.isNotEmpty &&
        states.firstWhere((state) => state.name == address.state,
                orElse: () => null) !=
            null) {
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
            value: item.areaName,
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
                _cityController.text = item.value!;
                location.add(item.value);
              });
            },
            decoration: InputDecoration(
              labelText: "City",
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
            labelText: "City",
            labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
                borderRadius: const BorderRadius.all(Radius.circular(10.0)))),
        textInputAction: TextInputAction.next,
        onSaved: (String? value) {
          address.city = value;
          _cityController.text = value!;
          location.add(value);
        },
      );
    }
  }

  Future<void> getStates() async {
    states = await Services().widget?.loadStatenCities() ?? [];
    isLoading = false;
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getStates();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _stateController.dispose();
    _cityController.dispose();
    _cityNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 22.0,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Store Selection",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: isLoading == true
          ? Container(child: Center(child: kLoadingWidget(context)))
          : Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.20),
                        renderStateInput(),
                        const SizedBox(height: 15.0),
                        renderCityInput(),
                        const SizedBox(height: 25.0),
                        Center(
                          child: ButtonTheme(
                            height: 50.0,
                            minWidth: MediaQuery.of(context).size.width * 0.60,
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
                                printLog(location);
                                Navigator.of(context).pop(location);
                              },
                              child: Text(
                                S.of(context).submit.toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
