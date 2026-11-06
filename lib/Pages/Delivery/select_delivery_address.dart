import 'package:chop_chop_africa/backend/address_provider.dart';
import 'package:chop_chop_africa/backend/models/address_search_model.dart';
import 'package:chop_chop_africa/backend/models/all_address_model.dart';
import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:chop_chop_africa/utility/uiutils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import '../../utility/iacolors.dart';

/// Picking a delivery address is deliberately two steps: choosing from the
/// Google-backed list only fills the field, and a separate Confirm commits it.
/// That keeps every saved address one Google knows about, while still giving
/// the user something to read back before they are moved on.
class AddressSearchBar extends StatefulWidget {
  final String type;
  final bool defaultAddress;

  const AddressSearchBar(
      {super.key, required this.type, required this.defaultAddress});

  @override
  State<AddressSearchBar> createState() => _AddressSearchBarState();
}

class _AddressSearchBarState extends State<AddressSearchBar> {
  final TextEditingController _typeAheadController = TextEditingController();

  /// What the user has actually settled on. Null until they pick from the list
  /// or use their current location; typing alone never fills these.
  String? _selectedLabel;
  String? _selectedPlaceId;
  double? _selectedLatitude;
  double? _selectedLongitude;

  bool _isSubmitting = false;
  bool _isLocating = false;

  bool get _hasSelection => _selectedLabel != null;

  @override
  void initState() {
    super.initState();
    // Updating the default address needs the address list in hand. Nothing
    // else on this screen loads it, so make sure it is there before the user
    // can press Confirm.
    if (widget.type != 'create') {
      Future.microtask(() {
        final address = Provider.of<AddressProvider>(context, listen: false);
        if (address.addressList.isEmpty) address.getAllAddresses();
      });
    }
  }

  @override
  void dispose() {
    _typeAheadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AddressProvider>(builder: (context, address, child) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Delivery Address',
            style: TextStyle(fontSize: 16),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(7),
            child: Divider(
              color: IAColors.appBarLightGrey,
            ),
          ),
        ),
        body: IgnorePointer(
          ignoring: _isSubmitting,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                3.gap,
                _searchField(address),
                0.3.gap,
                _currentLocationRow(address),
                1.gap,
                if (_hasSelection) _selectedCard() else _pickFromListHint(),
              ],
            ),
          ),
        ),
        persistentFooterButtons: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: SizedBox(
              height: 6.5.pH,
              width: 100.pW,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                      _hasSelection ? IAColors.primary : IAColors.lightGrey),
                  foregroundColor: WidgetStatePropertyAll(
                      _hasSelection ? IAColors.white : IAColors.darkGrey),
                ),
                onPressed: _isSubmitting ? null : () => _confirm(address),
                child: _isSubmitting
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: LoadingIndicator(
                            indicatorType: Indicator.ballPulse,
                            colors: const [Colors.white],
                            strokeWidth: 2,
                            backgroundColor: Colors.transparent,
                            pathBackgroundColor: Colors.black),
                      )
                    : Text('Confirm Address'),
              ),
            ),
          )
        ],
      );
    });
  }

  Widget _searchField(AddressProvider address) {
    return TypeAheadField<SearchedAddress>(
      offset: const Offset(0, 30),
      controller: _typeAheadController,
      // The package debounces the callback for us, so the search runs once the
      // user pauses rather than once per keystroke.
      debounceDuration: const Duration(milliseconds: 350),
      hideOnSelect: true,
      retainOnLoading: false,
      builder: (context, controller, focusNode) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: true,
          style: TextStyle(fontSize: 12.5),
          onChanged: (_) {
            // Editing the text invalidates whatever was picked before, so the
            // user cannot confirm an address they have since typed over.
            if (_hasSelection) setState(_clearSelection);
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: IAColors.fieldFill,
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SvgPicture.asset('assets/svg/search-normal.svg'),
            ),
            errorStyle: TextStyle(fontSize: 12.5),
            hintText: 'Start typing your address',
            hintStyle: TextStyle(
                fontSize: 12, height: 1.5, fontWeight: FontWeight.normal),
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
      itemSeparatorBuilder: (context, index) =>
          Divider(color: IAColors.veryLightGrey),
      suggestionsCallback: (pattern) async {
        final query = pattern.trim();
        if (query.length < 3) return <SearchedAddress>[];
        final result = await address.searchForAddress(query);
        // Google has already matched the query; filtering its answers again by
        // raw substring would throw away corrected spellings and expansions.
        return result?.data ?? <SearchedAddress>[];
      },
      loadingBuilder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Center(
          child: SizedBox(
            height: 22,
            width: 22,
            child: LoadingIndicator(
                indicatorType: Indicator.ballPulse,
                colors: [IAColors.primary],
                strokeWidth: 2,
                backgroundColor: Colors.transparent,
                pathBackgroundColor: Colors.transparent),
          ),
        ),
      ),
      emptyBuilder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12),
        child: Text(
          'No matches. Try a street name or a nearby landmark.',
          style: TextStyle(fontSize: 13, color: IAColors.darkGrey),
        ),
      ),
      errorBuilder: (context, error) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12),
        child: Text(
          'Could not search right now. Check your connection and try again.',
          style: TextStyle(fontSize: 13, color: IAColors.darkGrey),
        ),
      ),
      itemBuilder: (context, prediction) {
        return ListTile(
          leading: SvgPicture.asset('assets/svg/location.svg'),
          title: Text(
            prediction.mainText ?? '',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            prediction.secondaryText ?? '',
            style: TextStyle(fontSize: 13),
          ),
        );
      },
      onSelected: (prediction) {
        // Selecting only fills the field. Confirm does the work.
        setState(() {
          _clearSelection();
          _selectedLabel = prediction.description ?? prediction.mainText;
          _selectedPlaceId = prediction.placeId;
          _typeAheadController.text = _selectedLabel ?? '';
        });
        FocusScope.of(context).unfocus();
      },
    );
  }

  Widget _currentLocationRow(AddressProvider address) {
    if (_isLocating) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 16,
            width: 16,
            child: LoadingIndicator(
                indicatorType: Indicator.ballPulse,
                colors: [IAColors.primary],
                strokeWidth: 2,
                backgroundColor: Colors.transparent,
                pathBackgroundColor: Colors.transparent),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Finding you…',
              style: TextStyle(color: IAColors.primary, fontSize: 13),
            ),
          ),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset('assets/svg/send-2.svg'),
        Flexible(
          child: GestureDetector(
            onTap: () => _useCurrentLocation(address),
            child: Text(
              'Use your current location',
              style: TextStyle(color: IAColors.primary, fontSize: 13),
            ),
          ),
        )
      ],
    );
  }

  Widget _pickFromListHint() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline, size: 15, color: IAColors.darkGrey),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'Pick your address from the list so we can find you exactly.',
            style: TextStyle(fontSize: 12, color: IAColors.darkGrey),
          ),
        ),
      ],
    );
  }

  Widget _selectedCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: IAColors.primary_10,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset('assets/svg/location.svg'),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivering to',
                  style: TextStyle(fontSize: 11, color: IAColors.darkGrey),
                ),
                const SizedBox(height: 2),
                Text(
                  _selectedLabel ?? '',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _clearSelection() {
    _selectedLabel = null;
    _selectedPlaceId = null;
    _selectedLatitude = null;
    _selectedLongitude = null;
  }

  /// The address flagged default, or null when the user has none yet.
  AddressList? _defaultAddress(AddressProvider address) {
    for (final item in address.addressList) {
      if (item.defaut == true) return item;
    }
    return null;
  }

  Future<void> _confirm(AddressProvider address) async {
    if (!_hasSelection) {
      UiUtils.showSnackBarFromTop(
          context, 'Pick your address from the list so we can find you.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final existingDefault = _defaultAddress(address);
      // Updating only makes sense when there is something to update. With no
      // default on file, save this one as the default instead of failing.
      final isUpdate = widget.type != 'create' && existingDefault != null;

      if (_selectedPlaceId != null) {
        if (isUpdate) {
          final details = await address.getPlaceDetailById(_selectedPlaceId!);
          final place = details?.data;
          if (place?.address == null ||
              place?.longitude == null ||
              place?.latitude == null) {
            if (mounted) {
              UiUtils.showSnackBarFromTop(context,
                  'Could not read that address. Pick it from the list again.');
            }
            return;
          }
          await address.changeAddress(existingDefault.id!, place!.address!,
              place.longitude!, place.latitude!, context);
        } else {
          await address.getLocationFromPlaceId(
              _selectedPlaceId!, widget.defaultAddress, context);
        }
      } else {
        if (isUpdate) {
          await address.changeAddress(existingDefault.id!, _selectedLabel!,
              _selectedLongitude!, _selectedLatitude!, context);
        } else {
          await address.getLocationManually(_selectedLabel!,
              _selectedLongitude!, _selectedLatitude!, widget.defaultAddress, context);
        }
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _useCurrentLocation(AddressProvider address) async {
    if (_isLocating || _isSubmitting) return;

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        UiUtils.showSnackBarFromTop(context, 'Please enable location services');
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          UiUtils.showSnackBarFromTop(context, 'Location permission denied');
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        UiUtils.showSnackBarFromTop(
            context, 'Location permission permanently denied');
      }
      return;
    }

    setState(() => _isLocating = true);
    try {
      final position = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(accuracy: LocationAccuracy.best));

      final resolved = await address.getCurrentAddress(
          position.latitude.toString(), position.longitude.toString());
      final data = resolved?.data;
      if (!mounted) return;

      final label = data?.address;
      final latitude = data?.latitude;
      final longitude = data?.longitude;
      if (label == null || latitude == null || longitude == null) {
        UiUtils.showSnackBarFromTop(context,
            'Could not work out your address. Try typing it instead.');
        return;
      }

      // Treated exactly like a list pick: fill the field, wait for Confirm.
      setState(() {
        _clearSelection();
        _selectedLabel = label;
        _selectedLatitude = latitude;
        _selectedLongitude = longitude;
        _typeAheadController.text = label;
      });
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }
}
