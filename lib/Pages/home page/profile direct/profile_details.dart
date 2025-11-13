import 'package:chop_chop_africa/Pages/home%20page/profile%20direct/delete_account.dart';
import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:chop_chop_africa/utility/uiutils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:phone_text_field/phone_text_field.dart';

import '../../../utility/iacolors.dart';

class ProfileDetails extends StatefulWidget {
  const ProfileDetails({super.key});

  @override
  State<ProfileDetails> createState() => _ProfileDetailsState();
}

class _ProfileDetailsState extends State<ProfileDetails> {
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dateController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dateController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: Theme.of(context).copyWith(
        dividerTheme: const DividerThemeData(
          color: Colors.transparent,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Profile Details',
            style: TextStyle(
                fontSize: 16
            ),
          ),
          leading: UiUtils.backButton(context),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(7),
            child: Divider(
              color: IAColors.veryLightGrey,
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
                _titleText('First Name'),
                1.gap,
                TextFormField(
                  controller: _firstNameController,
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
                      hintText: 'Enter your First Name',
                      hintStyle: TextStyle(
                          height: 2,
                          fontSize: 14
                      ),
                  ),
                ),
                2.gap,
                _titleText('Last Name'),
                1.gap,
                TextFormField(
                  controller: _lastNameController,
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
                    hintText: 'Enter your Last Name',
                    hintStyle: TextStyle(
                        height: 2,
                        fontSize: 14
                    ),
                  ),
                ),
                2.gap,
                _titleText('Email'),
                1.gap,
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
                _titleText('Phone Number'),
                1.gap,
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
                      //showCountryCodeAsIcon: true,
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
                _titleText('D.O.B'),
                SizedBox(
                  height:11.pH,
                  child: TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    validator: (v){
                      if(v!.isEmpty){
                        return 'Field Must Not be empty';
                      }
                      return null;
                    },
                    style: theme.textTheme.bodySmall,
                    decoration: InputDecoration(
                        suffixIcon: const Icon(Icons.calendar_today_rounded),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        contentPadding: EdgeInsets.only(top: 3,left: 10),
                        errorStyle: TextStyle(
                            fontSize: 14
                        ),
                        hintText: 'Enter your Date Of Birth',
                        hintStyle: TextStyle(
                            height: 2,
                            fontSize: 14
                        ),
                        helperText: ''
                    ),
                  ),
                ),
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
                  backgroundColor: WidgetStatePropertyAll(Colors.red)
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context){
                    return DeleteAccount();
                  }));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset('assets/svg/trash.svg'),
                    0.5.gap,
                    Text('Delete Account',)
                  ],
                )
              ),
            ),
          ),

        ],
      ),
    );
  }
  Widget _titleText(String text){
    return Text(text,
    style: TextStyle(
      fontSize: 14
    ),
    );
  }
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(

      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: IAColors.primary,
              onPrimary: Colors.white,
              surface: Theme.of(context).scaffoldBackgroundColor, // main background
              onSurface: IAColors.dialogDark, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: IAColors.primary, // button text color
              ),
            ),
            textTheme: Theme.of(context).textTheme.copyWith(
              bodyLarge: TextStyle(
                  fontSize: 13, // reduces the large calendar numbers
                  color: IAColors.dialogDark
              ),
              bodyMedium: TextStyle(
                  fontSize: 12,
                  color: IAColors.dialogDark
              ),
              titleMedium: TextStyle(
                  fontSize: 14, // month/year size
                  fontWeight: FontWeight.w600,
                  color: IAColors.dialogDark
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        // You can format it however you like
        _dateController.text =
        "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
  }
}
