import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClickNCollectProvider with ChangeNotifier {
  String? deliveryType = "homedelivery";
  // String deliveryType = "clickandcollect";
  String? storeId = "";
  // setDeliveryType(type) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setString("selectedDeliveryType", type);

  //   notifyListeners();
  // }

  // getDeliveryTypeAndStoreId() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   deliveryType = await prefs.getString("selectedDeliveryType");
  //   storeId = await prefs.getString("selectedStoreId");
  //   notifyListeners();
  // }

  // setStoreId(id) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setString("selectedDeliveryType", "clickandcollect");
  //   await prefs.setString("selectedStoreId", id);
  //   // storeId = id;
  //   notifyListeners();
  // }
  initializeTypeAndStoreId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    deliveryType = prefs.getString("selectedDeliveryType");
    storeId = prefs.getString("selectedStoreId");
  }

  setDeliveryTypeAndStoreId(id, type) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("selectedDeliveryType", type);
    await prefs.setString("selectedStoreId", id);
    deliveryType = prefs.getString("selectedDeliveryType");
    storeId = prefs.getString("selectedStoreId");
    // storeId = id;
    notifyListeners();
  }

  late LatLng initialcameraposition;

  setInitialCameraPosition(lat, lng) {
    initialcameraposition = LatLng(lat, lng);
    notifyListeners();
  }
}
