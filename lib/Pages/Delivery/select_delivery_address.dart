import 'package:chop_chop_africa/Pages/home%20page/main_home.dart';
import 'package:chop_chop_africa/backend/address_provider.dart';
import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import '../../utility/iacolors.dart';

class AddressSearchBar extends StatefulWidget {
final String type;
  AddressSearchBar({super.key, required this.type});

  @override
  State<AddressSearchBar> createState() => _AddressSearchBarState();
}

class _AddressSearchBarState extends State<AddressSearchBar> {
  final TextEditingController _typeAheadController = TextEditingController();
  //  List<AutocompletePrediction>? _addressPredictions;
  // final _places = FlutterGooglePlacesSdk(Env.GOOGLE_API_KEY);
  // Future<void> searchPlaces(String query) async {
  //   if (query.trim().isEmpty) {
  //     setState(() {
  //       _addressPredictions = [];
  //     });
  //     return;
  //   }
  //   final result = await _places.findAutocompletePredictions(query);
  //   setState(() {
  //     _addressPredictions = result.predictions;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Consumer<AddressProvider>(
      builder: (context,address,child) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text('Delivery Address',
            style: TextStyle(
              fontSize: 16
            ),
            ),
            leading: IconButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context){
                    return MainHome();
                  }));
                },
                icon: Icon(Icons.close,color: Colors.black,)
            ),
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
                3.gap,
                TypeAheadField(
                  offset: const Offset(0, 30),
                  builder: (context, controller, focusNode) {
                    return TextField(
                      controller: controller,

                      onChanged: (v){
                        address.searchForAddress(v);
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
                  itemSeparatorBuilder: (context, index) => Divider(color: Colors.grey.shade200),
                  suggestionsCallback: (pattern) {
                    if (address.searchedAddress == null) return [];
                    return address.searchedAddress!
                        .where((predictions) => predictions.description!
                        .toLowerCase()
                        .contains(pattern.toLowerCase()))
                        .toList();
                  },
                  emptyBuilder: (context){
                    return Container();
                  },
                  itemBuilder: (context, predictions) {
                    return ListTile(
                      onTap: ()async{
                        print('object');
                        _typeAheadController.text = predictions.description!;
                        if(widget.type == "create"){
                          await address.getLocationFromPlaceId(predictions.placeId, context);
                        }else{
                          final defaultAddress = address.addressList.firstWhere(
                                (item) => item.defaut == true,
                          );
                          await address.getPlaceDetailById(predictions.placeId);
                          await address.changeAddress(
                              defaultAddress.id!,
                              address.getPlaceDetails!.data!.address!,
                              address.getPlaceDetails!.data!.longitude!,
                              address.getPlaceDetails!.data!.latitude!,
                              context);
                        }
                      },
                      leading: SvgPicture.asset('assets/svg/location.svg'),
                      title: Text(predictions.mainText,
                        style: TextStyle(
                            fontSize: 13,
                          fontWeight: FontWeight.w600
                        ),
                      ),
                      subtitle: Text(predictions.secondaryText??'',
                        style: TextStyle(
                            fontSize: 13,
                        ),
                      ),
                    );
                  },
                  onSelected: (suggestion) {
                    // Handle the selected suggestion
                    setState(() {
                      print('object');
                      //
                      print('object');
                      //
                    });
                  },

                ),
                0.3.gap,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset('assets/svg/send-2.svg'),
                    GestureDetector(
                      onTap: (){
                        _useCurrentLocation(address);
                      },
                      child: Text('Use your current location',
                      style: TextStyle(
                        color: IAColors.primary,
                        fontSize: 13
                      ),
                      ),
                    )
                  ],
                ),

              ],
            ),
          ),
        );
      }
    );
  }

  Future<void> _useCurrentLocation(AddressProvider address) async {
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
    // final placemarks = await placemarkFromCoordinates(
    //   position.latitude,
    //   position.longitude,
    // );
    //
    // if (placemarks.isNotEmpty) {
    //   final place = placemarks.first;
    //   final address =
    //       "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
    
    await address.getCurrentAddress(position.latitude.toString(), position.longitude.toString());
      setState(() {
        _typeAheadController.text = address.currentAddress!.data!.address!;
      });

      if(widget.type == 'create'){
        await address.getLocationManually(
            address.currentAddress!.data!.address!,
            address.currentAddress!.data!.longitude!,
            address.currentAddress!.data!.latitude!,
            context);
      }else{
        final defaultAddress = address.addressList.firstWhere(
              (item) => item.defaut == true,
        );
        await address.changeAddress(
            defaultAddress.id!,
            address.currentAddress!.data!.address!,
            address.currentAddress!.data!.longitude!,
            address.currentAddress!.data!.latitude!,
            context);
      }
    }
}
