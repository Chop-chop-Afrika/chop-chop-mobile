import 'package:chop_chop_africa/Pages/home%20page/main_home.dart';
import 'package:chop_chop_africa/env/env.dart';
import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:chop_chop_africa/utility/uiutils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../../../utility/iacolors.dart';

class NewAddress extends StatefulWidget {

  NewAddress({super.key});

  @override
  State<NewAddress> createState() => _NewAddressState();
}

class _NewAddressState extends State<NewAddress> {
  final TextEditingController _typeAheadController = TextEditingController();
  List<AutocompletePrediction>? _addressPredictions;
  final _places = FlutterGooglePlacesSdk(Env.GOOGLE_API_KEY);
  Future<void> searchPlaces(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _addressPredictions = [];
      });
      return;
    }
    final result = await _places.findAutocompletePredictions(query);
    setState(() {
      _addressPredictions = result.predictions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('New Address',
          style: TextStyle(
              fontSize: 16
          ),
        ),
        leading: UiUtils.backButton(context),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(7),
          child: Divider(
            color: IAColors.appBarLightGrey,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            2.gap,
            TypeAheadField(
              offset: const Offset(0, 30),
              builder: (context, controller, focusNode) {
                return TextField(
                  controller: controller,

                  onChanged: (v){
                    searchPlaces(v);
                  },
                  focusNode: focusNode,
                  autofocus: true,
                  style: TextStyle(
                      fontSize: 12.5
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SvgPicture.asset('assets/svg/search-normal.svg',),
                    ),
                    errorStyle: TextStyle(
                        fontSize: 12.5
                    ),

                    hintText: 'Select Address',
                    hintStyle: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        fontWeight: FontWeight.normal
                    ),
                  ),
                );
              },
              decorationBuilder: (context, child) {
                return Material(
                  type: MaterialType.card,
                  color: Theme.of(context).scaffoldBackgroundColor,
                  elevation: 0,
                  borderRadius: BorderRadius.circular(8),
                  child: child,
                );
              },
              controller: _typeAheadController,
              suggestionsCallback: (pattern) {
                if (_addressPredictions == null) return [];
                return _addressPredictions!
                    .where((predictions) => predictions.fullText
                    .toLowerCase()
                    .contains(pattern.toLowerCase()))
                    .toList();
              },
              emptyBuilder: (context){
                return Container();
              },
              itemBuilder: (context, predictions) {
                return Column(
                  children: [
                    ListTile(
                      leading: SvgPicture.asset('assets/svg/location.svg'),
                      title: Text(predictions.primaryText,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      subtitle: Text(predictions.secondaryText,
                        style: TextStyle(
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Divider(color: Colors.grey.shade200,)
                  ],
                );
              },
              onSelected: (suggestion) {
                _typeAheadController.text = suggestion.fullText;
                // Handle the selected suggestion
              },

            ),
            0.3.gap,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset('assets/svg/send-2.svg'),
                GestureDetector(
                  onTap: _useCurrentLocation,
                  child: Text('Use your current location',
                    style: TextStyle(
                        color: IAColors.primary,
                        fontSize: 13
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> _useCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enable location services')),
      );
      return;
    }

    // Check for permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission permanently denied')),
      );
      return;
    }

    // Get current position
    final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
            accuracy: LocationAccuracy.best
        )
    );

    // Reverse geocode to get address
    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      final place = placemarks.first;
      final address =
          "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";

      setState(() {
        _typeAheadController.text = address;
      });
    }
  }
}
