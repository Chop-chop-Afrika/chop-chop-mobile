import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:chop_chop_africa/utility/uiutils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:phone_text_field/phone_text_field.dart';

import '../../../utility/iacolors.dart';

class SendPackage extends StatefulWidget {
  const SendPackage({super.key});

  @override
  State<SendPackage> createState() => _SendPackageState();
}

class _SendPackageState extends State<SendPackage> {
  final TextEditingController _pickUpAddress =  TextEditingController();
  final TextEditingController _dropOffAddress =  TextEditingController();
  final TextEditingController _fullName =  TextEditingController();
  final TextEditingController _phoneController =  TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _receiverFullName =  TextEditingController();
  final TextEditingController _receiverPhoneController =  TextEditingController();
  final TextEditingController _receiverEmailController = TextEditingController();
  final List<String> _packageCategory = ['Food','Clothes','Gadget','Documents','Others','Prefer not to say'];
  bool _useMyInfo = false;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Send Package',
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
              _fieldName('Pickup Address'),
              Stack(
                children: [
                  TextFormField(
                    controller: _pickUpAddress,
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
                        hintText: 'PickUp Address',
                        hintStyle: TextStyle(
                            height: 2,
                            fontSize: 14
                        ),
                       // helperText: ''
                    ),
                  ),
                  Positioned(
                      right: 6,
                      top: 7,
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
                  )
                ],
              ),
              1.gap,
              _fieldName('Dropoff Address'),
              TextFormField(
                controller: _dropOffAddress,
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
                    hintText: 'Enter Dropoff',
                    hintStyle: TextStyle(
                        height: 2,
                        fontSize: 14
                    ),

                ),
              ),
              2.gap,
              _subtitles('Sender Information'),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _useMyInfo,
                    onChanged: (value) {
                      setState(() {
                        _useMyInfo = value!;
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
              1.gap,
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
                    initialCountryCode: 'NG',
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
              1.gap,
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
                    initialCountryCode: 'NG',
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
                      String item = entry.value;
                      return Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: Colors.grey.shade200
                        ),
                        child: Text(item,
                          style:  TextStyle(
                             // fontWeight: FontWeight.w600,
                              color: IAColors.dialogDark,
                            fontSize: 13
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
              SizedBox(
                height: 6.5.pH,
                width: 100.pW,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.grey.shade200),
                    elevation: WidgetStatePropertyAll(0)
                  ),
                  onPressed: () {
                   
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Delivery Fee',
                        style: TextStyle(
                            color: Colors.black
                        ),
                      ),
                      Text('\$120',
                        style: TextStyle(
                            color: Colors.black
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              1.5.gap,
              SizedBox(
                height: 6.5.pH,
                width: 100.pW,
                child: ElevatedButton(
                  style: ButtonStyle(
                      elevation: WidgetStatePropertyAll(0)
                  ),
                  onPressed: () {

                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Go To Payment',
                        style: TextStyle(
                            color: Colors.white
                        ),
                      ),
                      Text('\$120',
                        style: TextStyle(
                            color: Colors.white
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
