import 'dart:io';

import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  final _emailController = TextEditingController();
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
                child: Text('You can log back into your account using your email address',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade800
                  ),
                ),
              ),
              2.gap,
              title('Email'),
              SizedBox(
                height: 11.pH,
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  autovalidateMode: AutovalidateMode.onUnfocus,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.?[a-zA-Z]+)$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  style: Theme.of(context).textTheme.bodySmall,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    contentPadding: EdgeInsets.only(top: 3, left: 10),
                    errorStyle: TextStyle(fontSize: 14),
                    hintText: 'Enter your email',
                    hintStyle: TextStyle(height: 2, fontSize: 14),
                    helperText: '',
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
  login(AuthProvider authData) async {
    final String email = _emailController.text.trim();
    if (email.isEmpty) {
      UiUtils.showSnackBarFromTop(context, 'Enter your email to continue');
      return;
    }
    setState(() {
      _isLoading = true;
    });
    await authData.login(email, context);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
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
