/// This widget is customize from the place_picker - https://pub.dev/packages/place_picker
import 'dart:async';
import 'dart:convert';
import 'dart:math' show Random;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../../generated/l10n.dart';

/// A UUID generator.
///
/// This will generate unique IDs in the format:
///
///     f47ac10b-58cc-4372-a567-0e02b2c3d479
///
/// The generated uuids are 128 bit numbers encoded in a specific string format.
/// For more information, see
/// [en.wikipedia.org/wiki/Universally_unique_identifier](http://en.wikipedia.org/wiki/Universally_unique_identifier).
class Uuid {
  final Random _random = Random();

  /// Generate a version 4 (random) uuid. This is a uuid scheme that only uses
  /// random numbers as the source of the generated uuid.
  String generateV4() {
    // Generate xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx / 8-4-4-4-12.
    int special = 8 + _random.nextInt(4);

    return '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}-'
        '${_bitsDigits(16, 4)}-'
        '4${_bitsDigits(12, 3)}-'
        '${_printDigits(special, 1)}${_bitsDigits(12, 3)}-'
        '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}';
  }

  String _bitsDigits(int bitCount, int digitCount) =>
      _printDigits(_generateBits(bitCount), digitCount);

  int _generateBits(int bitCount) => _random.nextInt(1 << bitCount);

  String _printDigits(int value, int count) =>
      value.toRadixString(16).padLeft(count, '0');
}

/// The result returned after completing location selection.
class LocationResult {
  /// The human readable name of the location. This is primarily the
  /// name of the road. But in cases where the place was selected from Nearby
  /// places list, we use the <b>name</b> provided on the list item.
  String? name; // or road

  /// The human readable locality of the location.
  String? locality;

  /// Latitude/Longitude of the selected location.
  LatLng? latLng;

  String? street;

  String? streetNo;

  String? country;

  String? state;

  String? city;

  String? zip;
}

/// Nearby place data will be deserialized into this model.
class NearbyPlace {
  /// The human-readable name of the location provided. This value is provided
  /// for [LocationResult.name] when the user selects this nearby place.
  String? name;

  /// The icon identifying the kind of place provided. Eg. lodging, chapel,
  /// hospital, etc.
  String? icon;

  // Latitude/Longitude of the provided location.
  LatLng? latLng;
}

/// Autocomplete results item returned from Google will be deserialized
/// into this model.
class AutoCompleteItem {
  /// The id of the place. This helps to fetch the lat,lng of the place.
  String? id;

  /// The text (name of place) displayed in the autocomplete suggestions list.
  String? text;

  /// Assistive index to begin highlight of matched part of the [text] with
  /// the original query
  int? offset;

  /// Length of matched part of the [text]
  int? length;
}

/// Place picker widget made with map widget from
/// [google_maps_flutter](https://github.com/flutter/plugins/tree/master/packages/google_maps_flutter)
/// and other API calls to [Google Places API](https://developers.google.com/places/web-service/intro)
///
/// API key provided should have `Maps SDK for Android`, `Maps SDK for iOS`
/// and `Places API`  enabled for it
class PlacePicker extends StatefulWidget {
  /// API key generated from Google Cloud Console. You can get an API key
  /// [here](https://cloud.google.com/maps-platform/)
  final String? apiKey;

  PlacePicker(this.apiKey);

  @override
  State<StatefulWidget> createState() {
    return PlacePickerState();
  }
}

/// Place picker state
class PlacePickerState extends State<PlacePicker> {
  /// Initial waiting location for the map before the current user location
  /// is fetched.
  static const LatLng initialTarget = LatLng(25.286106, -0.3198162);

  final Completer<GoogleMapController> mapController = Completer();

  /// Indicator for the selected location
  final Set<Marker> markers = Set()
    ..add(
      Marker(
        position: initialTarget,
        markerId: MarkerId("selected-location"),
      ),
    );

  /// Result returned after user completes selection
  LocationResult? locationResult;

  /// Overlay to display autocomplete suggestions
  OverlayEntry? overlayEntry;

  List<NearbyPlace> nearbyPlaces = [];

  /// Session token required for autocomplete API call
  String sessionToken = Uuid().generateV4();

  GlobalKey appBarKey = GlobalKey();

  bool hasSearchTerm = false;

  String previousSearchTerm = '';

  // constructor
  PlacePickerState();

  void onMapCreated(GoogleMapController controller) {
    mapController.complete(controller);
    moveToCurrentUserLocation();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        key: appBarKey,
        title: SearchInput(searchPlace),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
          color: Theme.of(context).colorScheme.secondary,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        automaticallyImplyLeading: false,
      ),
      // Colors.white,
      body: Column(
        children: <Widget>[
          Expanded(
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: initialTarget,
                zoom: 15,
              ),
              myLocationButtonEnabled: false,
              myLocationEnabled: false,
              onMapCreated: onMapCreated,
              onTap: (latLng) {
                clearOverlay();
                moveToLocation(latLng);
              },
              markers: markers,
            ),
          ),
          hasSearchTerm
              ? const SizedBox()
              : Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SelectPlaceAction(getLocationName(), () {
                       
                        print(locationResult!.city);
                        print(locationResult!.country);
                        print(locationResult!.street);
                        print(locationResult!.state);

                        Navigator.of(context).pop(locationResult);
                      }),
                      const Divider(
                        height: 8,
                      ),
                      Padding(
                        child: Text(
                          S.of(context).nearbyPlaces,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 6,
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: nearbyPlaces
                                .map((it) => NearbyPlaceItem(it, () {
                                      moveToLocation(it.latLng!);
                                    }))
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  /// Hides the autocomplete overlay
  void clearOverlay() {
    if (overlayEntry != null) {
      overlayEntry!.remove();
      overlayEntry = null;
    }
  }

  /// Begins the search process by displaying a "wait" overlay then
  /// proceeds to fetch the autocomplete list. The bottom "dialog"
  /// is hidden so as to give more room and better experience for the
  /// autocomplete list overlay.
  void searchPlace(String place) {
    // on keyboard dismissal, the search was being triggered again
    // this is to cap that.
    if (place == previousSearchTerm) {
      return;
    } else {
      previousSearchTerm = place;
    }

    if (context == null) {
      return;
    }

    clearOverlay();

    setState(() {
      hasSearchTerm = place.isNotEmpty;
    });

    if (place.isEmpty) {
      return;
    }

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    Size size = renderBox.size;

    final RenderBox? appBarBox = appBarKey.currentContext!.findRenderObject() as RenderBox?;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: appBarBox!.size.height,
        width: size.width,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 24,
          ),
          color: Colors.white,
          child: Row(
            children: const <Widget>[
              SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  backgroundColor: Colors.black,
                ),
              ),
              SizedBox(
                width: 24,
              ),
            ],
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry!);

    autoCompleteSearch(context, place);
  }

  /// Fetches the place autocomplete list with the query [place].
  void autoCompleteSearch(context, String place) {
    place = place.replaceAll(" ", "+");
    var endpoint =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?"
        "key=${widget.apiKey}&"
        "input={$place}&sessiontoken=$sessionToken";

    if (locationResult != null) {
      endpoint += "&location=${locationResult!.latLng!.latitude},"
          "${locationResult!.latLng!.longitude}";
    }
    http.get(Uri.parse(endpoint)).then((response) {
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        List<RichSuggestion> suggestions = [];

        if (data["error_message"] == null) {
          List<dynamic> predictions = data['predictions'];
          print("#######################");
          print(data);

          if (predictions.isEmpty) {
            AutoCompleteItem aci = AutoCompleteItem();
            aci.text = S.of(context).noResultFound;
            aci.offset = 0;
            aci.length = 0;

            suggestions.add(RichSuggestion(aci, () {}));
          } else {
            for (dynamic t in predictions) {
              AutoCompleteItem aci = AutoCompleteItem();

              aci.id = t['place_id'];
              aci.text = t['description'];
              aci.offset = t['matched_substrings'][0]['offset'];
              aci.length = t['matched_substrings'][0]['length'];

              suggestions.add(RichSuggestion(aci, () {
                FocusScope.of(context).requestFocus(FocusNode());
                decodeAndSelectPlace(aci.id);
              }));
            }
          }
        } else {
          AutoCompleteItem aci = AutoCompleteItem();
          aci.text = data["error_message"];
          aci.offset = 0;
          aci.length = 0;
          suggestions.add(RichSuggestion(aci, () {}));
        }
        displayAutoCompleteSuggestions(suggestions);
      }
    }).catchError((print) {});
  }

  /// To navigate to the selected place from the autocomplete list to the map,
  /// the lat,lng is required. This method fetches the lat,lng of the place and
  /// proceeds to moving the map to that location.
  void decodeAndSelectPlace(String? placeId) {
    clearOverlay();

    String endpoint =
        "https://maps.googleapis.com/maps/api/place/details/json?key=${widget.apiKey}"
        "&placeid=$placeId";

    http.get(Uri.parse(endpoint)).then((response) {
      if (response.statusCode == 200) {
        Map<String, dynamic> location =
            jsonDecode(response.body)['result']['geometry']['location'];

        LatLng latLng = LatLng(location['lat'], location['lng']);
        print("latLong");
        print(location['lat']);
        print(location['lng']);
        print(latLng);


        moveToLocation(latLng);
      }
    });
  }

  /// Display autocomplete suggestions with the overlay.
  void displayAutoCompleteSuggestions(List<RichSuggestion> suggestions) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    Size size = renderBox.size;

    final RenderBox? appBarBox = appBarKey.currentContext!.findRenderObject() as RenderBox?;

    clearOverlay();

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        top: appBarBox!.size.height,
        child: Container(
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: suggestions,
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry!);
  }

  /// Utility function to get clean readable name of a location. First checks
  /// for a human-readable name from the nearby list. This helps in the cases
  /// that the user selects from the nearby list (and expects to see that as a
  /// result, instead of road name). If no name is found from the nearby list,
  /// then the road name returned is used instead.
  String? getLocationName() {
    if (locationResult == null) {
      return "Unnamed location";
    }

    for (NearbyPlace np in nearbyPlaces) {
      if (np.latLng == locationResult!.latLng) {
        locationResult!.name = np.name;
        return np.name;
      }
    }

    return "${locationResult!.name}, ${locationResult!.locality}";
  }

  /// Moves the marker to the indicated lat,lng
  void setMarker(LatLng latLng) {
    // markers.clear();
    setState(() {
      markers.clear();
      markers.add(
        Marker(
          markerId: MarkerId("selected-location"),
          position: latLng,
        ),
      );
    });
  }

  /// Fetches and updates the nearby places to the provided lat,lng
  void getNearbyPlaces(LatLng latLng) {
    http
        .get(Uri.parse("https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
        "key=${widget.apiKey}&"
        "location=${latLng.latitude},${latLng.longitude}&radius=150"))
        .then((response) {
      if (response.statusCode == 200) {
        nearbyPlaces.clear();
        for (Map<String, dynamic> item
            in jsonDecode(response.body)['results']) {
          NearbyPlace nearbyPlace = NearbyPlace();

          nearbyPlace.name = item['name'];
          nearbyPlace.icon = item['icon'];
          double latitude = item['geometry']['location']['lat'];
          double longitude = item['geometry']['location']['lng'];

          LatLng _latLng = LatLng(latitude, longitude);

          nearbyPlace.latLng = _latLng;

          nearbyPlaces.add(nearbyPlace);
        }
      }

      // to update the nearby places
      setState(() {
        // this is to require the result to show
        hasSearchTerm = false;
      });
    }).catchError((error) {});
  }

  /// This method gets the human readable name of the location. Mostly appears
  /// to be the road name and the locality.
  void reverseGeocodeLatLng(LatLng latLng) {
    http
        .get(Uri.parse("https://maps.googleapis.com/maps/api/geocode/json?latlng=${latLng.latitude},${latLng.longitude}&key=${widget.apiKey}"))
        .then((response) {
      if (response.statusCode == 200) {
        print("hhgff");
        print("https://maps.googleapis.com/maps/api/geocode/json?latlng=${latLng.latitude},${latLng.longitude}&key=${widget.apiKey}");
        Map<String, dynamic> responseJson = jsonDecode(response.body);

        String? road =
            responseJson['results'][0]['address_components'][0]['short_name'];

        String? locality = "";
        String number = "";
        String? street = "";
        String? state = "";

        String? city = "";
        String? country = "";
        String? zip = '';
        List st=[];

        List components = responseJson['results'][0]['address_components'];
        

        for (var i = 0; i < components.length; i++) {
          final item = components[i];
          List types = item["types"];

          // ignore: prefer_contains
          if (types.indexOf("street_number") > -1) {
            street = item["long_name"];
          }else{
            st.add(item["long_name"]);
          }
          // ignore: prefer_contains
          // if (types.indexOf("street_number") > -1) {
          //   // print(state);
          //   // print(i);
          //   // print(item["long_name"]);
          //   street = item["long_name"];
          //   // print(street);
          // }
          // ignore: prefer_contains
          if (types.indexOf("neighbourhood") > -1 ||
              types.indexOf("neighborhood") > -1) {
            locality = item["long_name"];
          } else if (types.contains("locality")) {
            locality = item["long_name"];
          }
          // ignore: prefer_contains
          if (types.indexOf("locality") > -1) {
            city = item["long_name"];
          }
          // ignore: prefer_contains
          if (types.indexOf("neighborhood") > -1||types.indexOf("sublocality_level_1") > -1) {
            state = item["long_name"];
          }
          // ignore: prefer_contains
          if (types.indexOf("country") > -1) {
            country = item["short_name"];
          }
          // ignore: prefer_contains
          if (types.indexOf("administrative_area_level_4") > -1 ||
              // ignore: prefer_contains
              types.indexOf("postal_code") > -1) {
            zip = item["long_name"];
          }
        }
        print("jhjkdhshjask");
        print(st);
        print("https://maps.googleapis.com/maps/api/geocode/json?latlng=${latLng.latitude},${latLng.longitude}&key=${widget.apiKey}");
        street =
            responseJson['results'][0]['address_components'][1]['long_name'];
        state =
            responseJson['results'][0]['address_components'][1]['long_name'];
        setState(() {
          locationResult = LocationResult();
          locationResult!.name = road;
          locationResult!.locality = locality;
          locationResult!.latLng = latLng;
          locationResult!.street = "$street;";

          locationResult!.state = state;
          locationResult!.city = city;
          locationResult!.country = country;
          locationResult!.zip = zip;
        });
      }
    });
  }

  /// Moves the camera to the provided location and updates other UI features to
  /// match the location.
  void moveToLocation(LatLng latLng) {
    mapController.future.then((controller) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: latLng,
            zoom: 15.0,
          ),
        ),
      );
    });

    setMarker(latLng);

    reverseGeocodeLatLng(latLng);

    getNearbyPlaces(latLng);
  }

   Future<void> moveToCurrentUserLocation() async {
     bool serviceEnabled;
     LocationPermission? permission;
     serviceEnabled = await Geolocator.isLocationServiceEnabled();
     if (!serviceEnabled) {
       return Future.error('Location services are disabled.');
     }

     permission = await Geolocator.checkPermission();
     if (permission == LocationPermission.denied) {
       permission = await Geolocator.requestPermission();
     }
     var locTarget = await Geolocator.getCurrentPosition();
     moveToLocation(LatLng(locTarget.latitude, locTarget.longitude));

  }
}

/// Custom Search input field, showing the search and clear icons.
class SearchInput extends StatefulWidget {
  final ValueChanged<String> onSearchInput;

  SearchInput(this.onSearchInput);

  @override
  State<StatefulWidget> createState() {
    return SearchInputState();
  }
}

class SearchInputState extends State<SearchInput> {
  TextEditingController editController = TextEditingController();

  Timer? debouncer;

  bool hasSearchEntry = false;

  SearchInputState();

  @override
  void initState() {
    super.initState();
    editController.addListener(onSearchInputChange);
  }

  @override
  void dispose() {
    editController.removeListener(onSearchInputChange);
    editController.dispose();

    super.dispose();
  }

  void onSearchInputChange() {
    if (editController.text.isEmpty) {
      debouncer?.cancel();
      widget.onSearchInput(editController.text);
      return;
    }

    if (debouncer?.isActive ?? false) {
      debouncer!.cancel();
    }

    debouncer = Timer(const Duration(milliseconds: 500), () {
      widget.onSearchInput(editController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
      ),
      child: Row(
        children: <Widget>[
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: S.of(context).searchPlace,
                border: InputBorder.none,
              ),
              controller: editController,
              onChanged: (value) {
                setState(() {
                  hasSearchEntry = value.isNotEmpty;
                });
              },
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          hasSearchEntry
              ? GestureDetector(
                  child: const Icon(
                    Icons.clear,
                  ),
                  onTap: () {
                    editController.clear();
                    setState(() {
                      hasSearchEntry = false;
                    });
                  },
                )
              : const SizedBox(),
        ],
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colors.grey[100],
      ),
    );
  }
}

class SelectPlaceAction extends StatelessWidget {
  final String? locationName;
  final VoidCallback onTap;

  SelectPlaceAction(this.locationName, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 8,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    locationName!,
                    style: TextStyle(
                        fontSize: 16, color: Theme.of(context).colorScheme.secondary
                        // color: Colors.black
                        ),
                  ),
                  Text(
                    S.of(context).tapSelectLocation,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward,
            )
          ],
        ),
      ),
    );
  }
}

class NearbyPlaceItem extends StatelessWidget {
  final NearbyPlace nearbyPlace;
  final VoidCallback onTap;

  NearbyPlaceItem(this.nearbyPlace, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        child: Row(
          children: <Widget>[
            Image.network(
              nearbyPlace.icon!,
              width: 16,
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Text(
                "${nearbyPlace.name}",
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class RichSuggestion extends StatelessWidget {
  final VoidCallback onTap;
  final AutoCompleteItem autoCompleteItem;

  RichSuggestion(this.autoCompleteItem, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: RichText(
                  text: TextSpan(children: getStyledTexts(context)),
                ),
              )
            ],
          )),
      onTap: onTap,
    );
  }

  List<TextSpan> getStyledTexts(BuildContext context) {
    final List<TextSpan> result = [];

    final String startText =
        autoCompleteItem.text!.substring(0, autoCompleteItem.offset);
    if (startText.isNotEmpty) {
      result.add(
        TextSpan(
          text: startText,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 15,
          ),
        ),
      );
    }

    final String boldText = autoCompleteItem.text!.substring(
        autoCompleteItem.offset!,
        autoCompleteItem.offset! + autoCompleteItem.length!);

    result.add(TextSpan(
      text: boldText,
      style: TextStyle(
        color: Theme.of(context).colorScheme.secondary,
        //  Colors.black,
        fontSize: 15,
      ),
    ));

    String remainingText = autoCompleteItem.text!
        .substring(autoCompleteItem.offset! + autoCompleteItem.length!);
    result.add(
      TextSpan(
        text: remainingText,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 15,
        ),
      ),
    );

    return result;
  }
}
