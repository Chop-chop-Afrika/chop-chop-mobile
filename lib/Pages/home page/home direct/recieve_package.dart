import 'package:chop_chop_africa/backend/address_provider.dart';
import 'package:chop_chop_africa/backend/profile_provider.dart';
import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:chop_chop_africa/utility/uiutils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:phone_text_field/phone_text_field.dart' hide PhoneNumber;
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:chop_chop_africa/Pages/home%20page/home%20direct/package_payment_flow.dart';
import 'package:chop_chop_africa/Pages/home%20page/home%20direct/track_package.dart';
import 'package:chop_chop_africa/backend/package_provider.dart';
import 'package:provider/provider.dart';
import 'package:loading_indicator/loading_indicator.dart';
import '../../../backend/store_provider.dart';
import '../../../utility/iacolors.dart';

class ReceivePackage extends StatefulWidget {
  const ReceivePackage({super.key});

  @override
  State<ReceivePackage> createState() => _ReceivePackageState();
}

class _ReceivePackageState extends State<ReceivePackage> {
  final TextEditingController _drpOffAddress =  TextEditingController();
  double? _drpOffLat;
  double? _drpOffLng;
  double? _pckUpfLat;
  double? _pckUpLng;
  final TextEditingController _pckUpAddress =  TextEditingController();
  final TextEditingController _fullName =  TextEditingController();
  final TextEditingController _phoneController =  TextEditingController();
  String? _phoneNumber;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _receiverFullName =  TextEditingController();
  final TextEditingController _receiverPhoneController =  TextEditingController();
  final TextEditingController _receiverEmailController = TextEditingController();
  late String _initialCountryCode = "NG";
  bool enabledField = false;
  final List<Map<String, String>> _packageCategory = [
    {
      'name': 'Food',
      'write': 'food',
    },
    {
      'name': 'Clothes',
      'write': 'cloth',
    },
    {
      'name': 'Gadget',
      'write': 'gadget',
    },
    {
      'name': 'Documents',
      'write': 'documents',
    },
    {
      'name': 'Others',
      'write': 'others',
    },
    {
      'name': 'Prefer not to say',
      'write': 'prefer_not_to_say',
    },
  ];

  bool _useMyInfo = false;
  int _selectedCategoryIndex = -1;
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var mainAddress = Provider.of<AddressProvider>(context, listen: false);
    _drpOffAddress.text = mainAddress.defaultAddress!.address!;
    _drpOffAddress.addListener(() => setState(() {}));
    _drpOffLng = mainAddress.defaultAddress!.longitude;
    _drpOffLat = mainAddress.defaultAddress!.latitude;

  }
  /// Prices the delivery first. The quote is calculated from coordinates, so
  /// both addresses must have been picked from the suggestions.
  Future<void> _fetchQuote() async {
    if (_pckUpfLat == null ||
        _pckUpLng == null ||
        _drpOffLat == null ||
        _drpOffLng == null) {
      UiUtils.showSnackBarFromTop(
          context, 'Pick both addresses from the suggestions first');
      return;
    }
    await Provider.of<PackageProvider>(context, listen: false).getQuote(
      pickupLatitude: _pckUpfLat!,
      pickupLongitude: _pckUpLng!,
      dropOffLatitude: _drpOffLat!,
      dropOffLongitude: _drpOffLng!,
    );
  }

  /// Books and pays for the delivery; make-payment both creates and charges,
  /// so nothing exists server-side until this succeeds.
  Future<void> _goToPayment() async {
    if (!_globalKey.currentState!.validate()) return;
    if (_pckUpAddress.text.isEmpty || _drpOffAddress.text.isEmpty) {
      UiUtils.showSnackBarFromTop(context, 'Please select an address');
      return;
    }
    if (_pckUpfLat == null || _drpOffLat == null) {
      UiUtils.showSnackBarFromTop(
          context, 'Pick both addresses from the suggestions first');
      return;
    }
    if (_selectedCategoryIndex == -1) {
      UiUtils.showSnackBarFromTop(
          context, 'Please select what is in the package');
      return;
    }

    final packages = Provider.of<PackageProvider>(context, listen: false);
    if (packages.quote == null) {
      await _fetchQuote();
      if (!mounted || packages.quote == null) return;
    }

    final String? packageId = await runPackagePayment(
      context,
      PackageBooking(
        pickupAddress: _pckUpAddress.text,
        dropOffAddress: _drpOffAddress.text,
        senderName: _fullName.text,
        senderPhone: _phoneNumber ?? _phoneController.text,
        senderEmail: _emailController.text,
        receiverName: _receiverFullName.text,
        receiverPhone: _receiverPhoneController.text,
        receiverEmail: _receiverEmailController.text,
        type: _packageCategory[_selectedCategoryIndex]['write']!,
        mode: 'receive',
        pickupLatitude: _pckUpfLat!,
        pickupLongitude: _pckUpLng!,
        dropOffLatitude: _drpOffLat!,
        dropOffLongitude: _drpOffLng!,
      ),
    );
    if (!mounted || packageId == null) return;

    // Straight to tracking rather than back to this form. The package may
    // still be settling, which that screen reports rather than hiding.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => TrackPackage(packageId: packageId, justBooked: true),
      ),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileProvider>(context, listen: false);
    final profileInfo = profile.getAllProfileInfo!.data;
    final store = Provider.of<StoreProvider>(context, listen: false);
    final theme = Theme.of(context);
    return Form(
      key: _globalKey,
      child: Consumer<AddressProvider>(
          builder: (context, address,child) {
            return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: Text('Receive Package',
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
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      2.gap,
                      _subtitles('Delivery Details'),
                      1.5.gap,

                      Row(
                        children: [
                          Image.asset('assets/images/Frame 1171277941.png',height: 22.pH,),
                          2.gap,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _fieldName('Pickup Address'),
                              SizedBox(
                                width: 80.pW,
                                child: TypeAheadField(
                                  offset: const Offset(0, 30),
                                  builder: (context, controller, focusNode) {
                                    return TextField(
                                      controller: controller,
                                      focusNode: focusNode,
                                      onChanged: (v){
                                        address.searchForAddress(v);
                                      },
                                      autofocus: false,
                                      style: TextStyle(
                                          fontSize: 12.5
                                      ),
                                      decoration: InputDecoration(
                                        enabledBorder:  OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.transparent),
                                          borderRadius: BorderRadius.all(Radius.circular(9)),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey.shade200,
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
                                  controller: _pckUpAddress,
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
                                      // onTap: ()async{
                                      //
                                      // },
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
                                  onSelected: (suggestion) async{
                                    // Handle the selected suggestion
                                    print('object');
                                    await address.getPlaceDetailById(suggestion.placeId);
                                    setState(() {
                                      _pckUpAddress.text = suggestion.description!;
                                      _pckUpfLat = address.getPlaceDetails!.data!.latitude;
                                      _pckUpLng = address.getPlaceDetails!.data!.longitude;
                                    });
                                    FocusScope.of(context).unfocus();
                                    print('object is $_pckUpLng $_pckUpfLat');
                                    //

                                  },

                                ),
                              ),
                              1.gap,
                              _fieldName('Dropoff Address'),
                              SizedBox(
                                width: 80.pW,
                                child: Stack(
                                  children: [
                                    TypeAheadField(
                                      offset: const Offset(0, 30),
                                      builder: (context, controller, focusNode) {
                                        return TextField(
                                          controller: controller,
                                          enabled: enabledField,
                                          focusNode: focusNode,
                                          autofocus: true,
                                          style: TextStyle(
                                              fontSize: 12.5
                                          ),
                                          decoration: InputDecoration(
                                            enabledBorder:  OutlineInputBorder(
                                              borderSide: BorderSide(color: Colors.transparent),
                                              borderRadius: BorderRadius.all(Radius.circular(9)),
                                            ),
                                            filled: true,
                                            fillColor: Colors.grey.shade200,
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
                                      controller: _drpOffAddress,
                                      itemSeparatorBuilder: (context, index) => Divider(color: Colors.grey.shade200),
                                      suggestionsCallback: (pattern) {
                                        if (address.addressList.isEmpty) return [];
                                        return address.addressList
                                            .where((predictions) => predictions.address!
                                            .toLowerCase()
                                            .contains(pattern.toLowerCase()))
                                            .toList();
                                      },
                                      emptyBuilder: (context){
                                        return Container();
                                      },
                                      itemBuilder: (context, predictions) {
                                        String addressText = predictions.address?.toString() ?? "";
                                        List<String> parts = addressText.split(',').map((e) => e.trim()).toList();
                                        String lastTwo = "${parts[parts.length - 2]}, ${parts.last}";
                                        String remaining = parts.sublist(0, parts.length - 2).join(', ');
                                        return ListTile(
                                          // onTap: ()async{
                                          //
                                          // },
                                          leading: SvgPicture.asset('assets/svg/location.svg'),
                                          title: Text(remaining,
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600
                                            ),
                                          ),
                                          subtitle: Text(lastTwo,
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
                                          setState(() {
                                            _drpOffAddress.text = suggestion.address!;
                                            _drpOffLat = suggestion.latitude;
                                            _drpOffLng = suggestion.longitude;
                                          });
                                          FocusScope.of(context).unfocus();
                                          print('second object is $_drpOffLat $_drpOffLng');
                                          //
                                        });
                                      },

                                    ),

                                    Positioned(
                                      right: 6,
                                      top: 7,
                                      child: GestureDetector(
                                        onTap: (){
                                          setState(() {
                                            enabledField = true;
                                            _drpOffAddress.clear();
                                          });
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(5),
                                              color: IAColors.dialogDark
                                          ),
                                          child: Text('Change',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      2.gap,
                      _subtitles('Sender Information'),
                      1.5.gap,
                      _fieldName('Full Name'),
                      TextFormField(
                        controller: _fullName,
                        validator: (v){
                          if(v!.isEmpty){
                            return 'Field Must Not be empty';
                          }
                          return null;
                        },
                        style: theme.textTheme.bodySmall,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          contentPadding: EdgeInsets.only(top: 3,left: 10),
                          errorStyle: TextStyle(
                              fontSize: 14
                          ),
                          hintText: 'Enter your Full name',
                          hintStyle: TextStyle(
                              height: 2,
                              fontSize: 14
                          ),
                        ),
                      ),
                      1.gap,
                      _fieldName('Phone Number'),
                      Theme(
                        data: Theme.of(context).copyWith(
                          dialogTheme: DialogThemeData(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            backgroundColor: Colors.grey[50],
                          ),
                          textTheme: const TextTheme(
                            titleLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.bold), // dialog title
                            bodyMedium: TextStyle(fontSize: 13), // country list text
                            bodySmall: TextStyle(fontSize: 12),  // minor texts
                          ),
                        ),
                        child: SizedBox(
                          height: 9.5.pH,
                          child: PhoneTextField(
                            controller: _phoneController,
                            invalidNumberMessage: 'Please enter a valid phone number',
                            autovalidateMode: AutovalidateMode.onUnfocus,
                            initialCountryCode: "NG",
                            textStyle: TextStyle(
                                color: IAColors.dialogDark
                            ),
                            decoration:  InputDecoration(
                              helperText: '',
                              hintText: 'Enter Phone Number',
                              hintStyle: TextStyle(
                                  fontSize: 14
                              ),
                              filled: true,
                              labelStyle: TextStyle(
                                  color: IAColors.dialogDark
                              ),
                              fillColor: Colors.grey.shade200,
                            ),
                            searchTextStyle: TextStyle(
                                color: IAColors.dialogDark
                            ),
                            searchFieldInputDecoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.shade200,
                              suffixIcon: Icon(Icons.search),
                              hintText: 'Search country',
                            ),
                            countryViewOptions: CountryViewOptions.countryCodeWithFlag,
                            onChanged: (phoneNumber) {
                              debugPrint('Phone: ${phoneNumber.completeNumber}');
                            },
                          ),
                        ),
                      ),
                      _fieldName('Email'),
                      TextFormField(
                        controller: _emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Please enter your email';
                          if (!RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.?[a-zA-Z]+)$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                        style: theme.textTheme.bodySmall,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          contentPadding: EdgeInsets.only(top: 3,left: 10),
                          errorStyle: TextStyle(
                              fontSize: 14
                          ),
                          hintText: 'Enter your email',
                          hintStyle: TextStyle(
                              height: 2,
                              fontSize: 14
                          ),

                        ),
                      ),
                      2.gap,
                      _subtitles('Receiver Information'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _useMyInfo,
                            onChanged: (value) {
                              setState(() {
                                _useMyInfo = value!;
                                if(_useMyInfo){
                                  _receiverFullName.text = '${profileInfo!.firstName} ${profileInfo.lastName}';
                                  _receiverPhoneController.text = PhoneNumber.parse(profileInfo.phone!).nsn;
                                  _phoneNumber = profileInfo.phone;
                                  _initialCountryCode = PhoneNumber.parse(profileInfo.phone!).isoCode.name;
                                  _receiverEmailController.text = profileInfo.email!;
                                }else{
                                  _receiverFullName.clear();
                                  _receiverPhoneController.clear();
                                  _initialCountryCode = "NG";
                                  _receiverEmailController.clear();
                                }
                              });
                            },
                          ),
                          0.5.gap,
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: _fieldName('Use my account information'),
                          )
                        ],
                      ),
                      //1.gap,
                      _fieldName('Full Name'),
                      TextFormField(
                        controller: _receiverFullName,
                        validator: (v){
                          if(v!.isEmpty){
                            return 'Field Must Not be empty';
                          }
                          return null;
                        },
                        style: theme.textTheme.bodySmall,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          contentPadding: EdgeInsets.only(top: 3,left: 10),
                          errorStyle: TextStyle(
                              fontSize: 14
                          ),
                          hintText: 'Enter your Full name',
                          hintStyle: TextStyle(
                              height: 2,
                              fontSize: 14
                          ),
                        ),
                      ),
                      1.gap,
                      _fieldName('Phone Number'),
                      Theme(
                        data: Theme.of(context).copyWith(
                          dialogTheme: DialogThemeData(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            backgroundColor: Colors.grey[50],
                          ),
                          textTheme: const TextTheme(
                            titleLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.bold), // dialog title
                            bodyMedium: TextStyle(fontSize: 13), // country list text
                            bodySmall: TextStyle(fontSize: 12),  // minor texts
                          ),
                        ),
                        child: SizedBox(
                          height: 9.5.pH,
                          child: PhoneTextField(
                            controller: _receiverPhoneController,
                            invalidNumberMessage: 'Please enter a valid phone number',
                            autovalidateMode: AutovalidateMode.onUnfocus,
                            initialCountryCode: _initialCountryCode,
                            textStyle: TextStyle(
                                color: IAColors.dialogDark
                            ),
                            decoration:  InputDecoration(
                              helperText: '',
                              hintText: 'Enter Phone Number',
                              hintStyle: TextStyle(
                                  fontSize: 14
                              ),
                              filled: true,
                              labelStyle: TextStyle(
                                  color: IAColors.dialogDark
                              ),
                              fillColor: Colors.grey.shade200,
                            ),
                            searchTextStyle: TextStyle(
                                color: IAColors.dialogDark
                            ),
                            searchFieldInputDecoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.shade200,
                              suffixIcon: Icon(Icons.search),
                              hintText: 'Search country',
                            ),
                            countryViewOptions: CountryViewOptions.countryCodeWithFlag,
                            onChanged: (phoneNumber) {
                              debugPrint('Phone: ${phoneNumber.completeNumber}');
                              setState(() {
                                _phoneNumber = phoneNumber.completeNumber;
                              });
                            },
                          ),
                        ),
                      ),
                      _fieldName('Email'),
                      TextFormField(
                        controller: _receiverEmailController,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Please enter your email';
                          if (!RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.?[a-zA-Z]+)$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                        style: theme.textTheme.bodySmall,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          contentPadding: EdgeInsets.only(top: 3,left: 10),
                          errorStyle: TextStyle(
                              fontSize: 14
                          ),
                          hintText: 'Enter your email',
                          hintStyle: TextStyle(
                              height: 2,
                              fontSize: 14
                          ),

                        ),
                      ),
                      2.gap,
                      _subtitles('What’s in the package?'),
                      1.gap,
                      IntrinsicWidth(
                        child: SingleChildScrollView(
                          child: Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: _packageCategory.asMap().entries.map((entry) {
                              int index = entry.key;
                              Map<String, String> item = entry.value;

                              bool isSelected = _selectedCategoryIndex == index;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedCategoryIndex = -1; // deselect
                                    } else {
                                      _selectedCategoryIndex = index; // select
                                    }
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    color: isSelected
                                        ? IAColors.primary_20   // highlighted color
                                        : Colors.grey.shade200,   // normal color
                                    border: Border.all(
                                      color: isSelected ? IAColors.primary : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: Text(
                                    item['name']!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isSelected ? Colors.black : IAColors.dialogDark,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      2.gap,
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color(0xffFDF2DF)
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SvgPicture.asset('assets/svg/warning-2.svg'),
                            SizedBox(
                              width: 77.pW,
                              child: Text('The package size limit and weight must not exceed 80 x 60 x 40 cm and 30 kg respectively.',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    height: 1.6,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w200
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      4.gap,
                      Consumer<PackageProvider>(
                        builder: (context, packages, _) => SizedBox(
                          height: 6.5.pH,
                          width: 100.pW,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(Colors.grey.shade200),
                              elevation: WidgetStatePropertyAll(0),
                            ),
                            onPressed: packages.quoting ? null : _fetchQuote,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  packages.quote == null
                                      ? 'Get delivery price'
                                      : 'Delivery Fee',
                                  style: TextStyle(color: Colors.black),
                                ),
                                packages.quoting
                                    ? SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2, color: Colors.black54),
                                      )
                                    : Text(
                                        packages.quote == null
                                            ? 'Tap to calculate'
                                            : '£${packages.quote!.total?.toStringAsFixed(2) ?? ''}',
                                        style: TextStyle(color: Colors.black),
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      //Text(_packageCategory[_selectedCategoryIndex]['write']!),
                      1.5.gap,
                      SizedBox(
                        height: 6.5.pH,
                        width: 100.pW,
                        child: ElevatedButton(
                          style: ButtonStyle(
                              elevation: WidgetStatePropertyAll(0)
                          ),
                          onPressed: _isLoading ? null : _goToPayment,
                          child:_isLoading?
                          SizedBox(
                              height: 20,
                              width: 20,
                              child: LoadingIndicator(
                                  indicatorType: Indicator.ballPulse,
                                  colors: const [Colors.white],
                                  strokeWidth: 2,
                                  backgroundColor: Colors.transparent,
                                  pathBackgroundColor: Colors.black)): Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Go To Payment',
                                style: TextStyle(
                                    color: Colors.white
                                ),
                              ),
                              Consumer<PackageProvider>(
                                builder: (context, packages, _) => Text(
                                  packages.quote == null
                                      ? ''
                                      : '£${packages.quote!.total?.toStringAsFixed(2) ?? ''}',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      4.gap
                    ],
                  ),
                ),
              ),
            );
          }
      ),
    );
  }

  Widget _fieldName(String text){
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(text,
            style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600
            ),
          ),
        ],
      ),
    );
  }

  Widget _subtitles(String text){
    return Text(text,
      style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600
      ),
    );
  }
}
