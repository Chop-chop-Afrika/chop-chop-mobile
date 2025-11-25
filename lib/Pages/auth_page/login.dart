import 'dart:io';

import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:phone_text_field/phone_text_field.dart';
import 'package:provider/provider.dart';

import '../../backend/auth_provider.dart';
import '../../utility/iacolors.dart';
import '../../utility/uiutils.dart';
import 'package:loading_indicator/loading_indicator.dart';


class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    final authData = Provider.of<AuthProvider>(context,listen: false);
    return Theme(
      data: Theme.of(context).copyWith(
        dividerTheme: const DividerThemeData(
          color: Colors.transparent,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          leading: UiUtils.backButton(context),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(7),
            child: Divider(
              color: IAColors.appBarLightGrey,
            ),
          ),
          actions: [
            // TextButton(
            //     onPressed: (){},
            //     child: Text('Continue as guest',
            //       style: TextStyle(
            //           color: IAColors.primary
            //       ),
            //     )
            // )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              0.5.gap,
              Center(
                child: Text('Welcome Back',
                  style: TextStyle(
                      color: IAColors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.w800
                  ),
                ),
              ),
              0.5.gap,
              Center(
                child: Text('You can log back into your account using your phone number',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade800
                  ),
                ),
              ),
              2.gap,
              title('Phone Number'),
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
                      setState(() {
                        _phoneController.text = phoneNumber.completeNumber;
                      });
                    },
                  ),
                ),
              ),
              1.gap,
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.grey.shade300,
                    )
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Or',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.grey.shade300,
                    )
                  ),
                ],
              ),
              2.gap,
              Platform.isIOS?
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),
                  color: Colors.grey.shade200
                ),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset('assets/svg/Apple.svg',height: 21,),
                    0.3.gap,
                    Text('Continue with Apple',
                    style: TextStyle(
                      fontSize: 14
                    ),
                    )
                  ],
                ),
              ):Container(),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9),
                      color: Colors.grey.shade200
                  ),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset('assets/svg/fe_google.svg',height: 21,),
                      0.3.gap,
                      Text('Continue with Google',
                        style: TextStyle(
                            fontSize: 14
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        persistentFooterButtons: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: SizedBox(
              height: 6.5.pH,
              width: 100.pW,
              child: ElevatedButton(
                onPressed: () async{
                  await login(authData);
                },
                child:  _isLoading?
                SizedBox(
                    height: 20,
                    width: 20,
                    child: LoadingIndicator(
                        indicatorType: Indicator.ballPulse,
                        colors: const [Colors.white],
                        strokeWidth: 2,
                        backgroundColor: Colors.transparent,
                        pathBackgroundColor: Colors.black)):
                Text('Continue',
              ),
            ),
          ),
          )
        ],
      ),
    );
  }
  login(AuthProvider authData)async{
   if(_phoneController.text.isNotEmpty){
     setState(() {
       _isLoading= true;
     });
     await authData.login(_phoneController.text, context);
     setState(() {
       _isLoading= false;
     });
   }
  }
  Widget title(String text){
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
}
