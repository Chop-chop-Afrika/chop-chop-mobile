// Apple and Google sign-in are commented out for now, so the imports they
// needed (dart:io for Platform, flutter_svg for the two marks) are commented
// out with them rather than deleted. Uncomment both ends together.
// import 'dart:io';
// import 'package:flutter_svg/flutter_svg.dart';

import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:flutter/material.dart';
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
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authData = Provider.of<AuthProvider>(context, listen: false);
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              0.5.gap,
              Center(
                child: Text('Welcome Back',
                  style: TextStyle(
                      color: IAColors.ink,
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
                      fontSize: 14,
                      height: 1.45,
                      color: IAColors.ink
                  ),
                ),
              ),
              4.5.gap,
              title('Email'),
              // No SizedBox around this any more. It used to be wrapped in
              // one 9.5.pH tall, and `helperText` claims a line of that for
              // the error message, which left the field itself less room than
              // it wanted and squashed it. The field now sizes itself from
              // its own padding instead. That lands on 48, which is both
              // Material's minimum tap target and within a couple of points
              // of the 46 the Figma draws.
              TextFormField(
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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 15,
                      color: IAColors.ink,
                    ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: IAColors.fieldFill,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  errorStyle: TextStyle(fontSize: 12),
                  hintText: 'Enter your email',
                  hintStyle: TextStyle(fontSize: 15),
                  // Keeps the error's line reserved so nothing below jumps
                  // when validation fails.
                  helperText: '',
                ),
              ),
              // The "Or" divider separated the field from Apple and Google.
              // With those two commented out it would be dividing the field
              // from nothing, so it waits here with them.
              // 1.gap,
              // Row(
              //   children: [
              //     Expanded(
              //       child: Divider(
              //         color: Colors.grey.shade300,
              //       )
              //     ),
              //     Padding(
              //       padding: const EdgeInsets.symmetric(horizontal: 8.0),
              //       child: Text(
              //         'Or',
              //         style: TextStyle(
              //           fontSize: 15,
              //           fontWeight: FontWeight.w500,
              //           color: Colors.grey.shade800,
              //         ),
              //       ),
              //     ),
              //     Expanded(
              //       child: Divider(
              //         color: Colors.grey.shade300,
              //       )
              //     ),
              //   ],
              // ),
              // 2.gap,
              // Platform.isIOS?
              // Container(
              //   width: double.infinity,
              //   padding: EdgeInsets.symmetric(vertical: 11),
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(9),
              //     color: IAColors.fieldFill
              //   ),
              //
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       SvgPicture.asset('assets/svg/Apple.svg',height: 21,),
              //       0.3.gap,
              //       Text('Continue with Apple',
              //       style: TextStyle(
              //         fontSize: 14
              //       ),
              //       )
              //     ],
              //   ),
              // ):Container(),
              // Padding(
              //   padding: const EdgeInsets.only(top: 4.0),
              //   child: Container(
              //     width: double.infinity,
              //     padding: EdgeInsets.symmetric(vertical: 11),
              //     decoration: BoxDecoration(
              //         borderRadius: BorderRadius.circular(9),
              //         color: IAColors.fieldFill
              //     ),
              //
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         SvgPicture.asset('assets/svg/fe_google.svg',height: 21,),
              //         0.3.gap,
              //         Text('Continue with Google',
              //           style: TextStyle(
              //               fontSize: 14
              //           ),
              //         )
              //       ],
              //     ),
              //   ),
              // )
            ],
          ),
        ),
        // Was persistentFooterButtons, which wraps its children in padding of
        // its own and was handed `width: 100.pW` - the full screen width
        // inside something already inset, so the button had no room for the
        // width it asked for. This sits where the Figma puts it and is the
        // 46 high the design draws.
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              height: 46,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () async {
                  await login(authData);
                },
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: LoadingIndicator(
                            indicatorType: Indicator.ballPulse,
                            colors: const [Colors.white],
                            strokeWidth: 2,
                            backgroundColor: Colors.transparent,
                            pathBackgroundColor: Colors.black))
                    : Text('Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        )),
              ),
            ),
          ),
        ),
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
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(text,
            style: TextStyle(
                fontSize: 13,
                color: IAColors.ink
            ),
          ),
        ],
      ),
    );
  }
}
