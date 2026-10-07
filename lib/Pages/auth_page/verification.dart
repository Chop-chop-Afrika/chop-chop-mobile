import 'dart:async';

import 'package:chop_chop_africa/Pages/Delivery/delivery_intro.dart';
import 'package:chop_chop_africa/backend/auth_provider.dart';
import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import '../../utility/iacolors.dart';
import '../../utility/paste_dialog.dart';
import '../../utility/uiutils.dart';
import 'package:loading_indicator/loading_indicator.dart';


class VerificationPage extends StatefulWidget {
  final String email;

  /// 'signup' after registering, 'login' when signing in. Decides which verify
  /// endpoint is called and which mode the resend uses.
  final String mode;
  const VerificationPage({super.key, required this.email, required this.mode});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  int _start = 300;
  Timer? _timer;
  String? _otp;
  bool _isLoading = false;
  bool _resending = false;
  TextEditingController _pinController = TextEditingController();
  void _startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
          (Timer timer) {
        if(mounted){
          if (_start == 0) {
            timer.cancel();
          }else {
            setState(() {
              _start--;
            });
          }
        }
      },
    );
  }
  /// Asks the API for a fresh code, and only restarts the countdown if one was
  /// really sent — otherwise the screen would imply a code is on its way.
  Future<void> resendOtp() async {
    if (_resending) return;
    setState(() {
      _resending = true;
    });
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bool sent = await authProvider.resendOtp(
      widget.email,
      widget.mode == 'signup'
          ? AuthProvider.registrationMode
          : AuthProvider.loginMode,
    );
    if (!mounted) return;
    setState(() {
      _resending = false;
    });
    if (!sent) return;

    UiUtils.showSnackBarFromTop(context, 'A new code is on its way to ${widget.email}');
    _timer?.cancel();
    setState(() {
      _start = 600;
    });
    _startTimer();
  }
  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    String formattedMinutes = minutes.toString().padLeft(2, '0');
    String formattedSeconds = remainingSeconds.toString().padLeft(2, '0');
    return '$formattedMinutes:$formattedSeconds';
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _startTimer();
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.white,
      appBar:  AppBar(
        leading: IconButton(
          icon: UiUtils.backButton(context),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child:  Column(
          children: [
            0.5.gap,
            Center(
              child: Text('Verify your email',
                style: TextStyle(
                    color: IAColors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.w800
                ),
              ),
            ),
            0.5.gap,
            Center(
              child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      text: 'We’ve sent a 6-digit code to ',
                      style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w300,
                          fontSize: 14
                      ),
                      children: <TextSpan>[
                        TextSpan(
                            text: widget.email,
                            style: TextStyle(
                              color: IAColors.primary,
                            ),
                        ),
                      ]
                  )
              )
            ),
            3.gap,
            PinCodeTextField(
              appContext: context,
              controller: _pinController,
              length: 6,
              textStyle: TextStyle(fontSize: 15),
              textCapitalization: TextCapitalization.characters,
              enableActiveFill: true,
              beforeTextPaste: (text) {
                // Show custom dialog synchronously - we'll handle the paste operation ourselves
                showDialog(
                    context: context,
                    builder: (context) => PasteDialog(text: text??'___',
                      onPressed: (){
                        Navigator.pop(context);
                        if (text != null) {
                          final formattedText = text.toUpperCase().
                          substring(0, text.length > 6 ? 6 : text.length);

                          final validText = formattedText.replaceAll(RegExp('[^A-Z0-9]'), '');
                          _pinController.text = validText;
                          // If you're using onCompleted callback
                          if (validText.length == 6) {
                            setState(() {
                              _otp = validText;
                            });
                          }
                        }
                      },
                    )
                );

                // Always return false to prevent default paste behavior
                // We'll handle the paste manually in the dialog's onPressed
                return false;
              },
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[A-Z0-9]')),
                //UpperCaseTextFormatter(),
              ],
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(10),
                fieldHeight: 13.pW,
                fieldWidth: 13.pW,
                borderWidth: 1,
                activeColor: IAColors.veryLightGrey,
                inactiveColor: IAColors.veryLightGrey,
                selectedColor: IAColors.veryLightGrey,
                activeFillColor:  IAColors.veryLightGrey,
                inactiveFillColor: IAColors.veryLightGrey,
                selectedFillColor: IAColors.veryLightGrey,
              ),
              keyboardType: TextInputType.text,
              onCompleted: (String verificationCode){
                setState(() {
                  _otp = verificationCode;
                });
              }, // end
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton(
                  onPressed: _start > 0 || _resending ? null : resendOtp,
                  child: _start > 0?
                  Text('Expires ${_formatDuration(_start)}',
                    style: const TextStyle(
                        color: Color(0xffE8D28B),
                        fontWeight: FontWeight.w300,
                        fontSize: 14
                    ),
                  ):Text(_resending ? 'Sending…' : 'Resend',
                    style: TextStyle(
                        color: Color(0xffE8D28B),
                        fontWeight: FontWeight.w300,
                        fontSize: 14
                    ),
                  ),
                )
              ],
            ),
            Expanded(child: Container()),
            SizedBox(
              height: 6.5.pH,
              width: 100.pW,
              child: ElevatedButton(
                onPressed: ()async{
                 await verifyOtp(_otp!, widget.email);
                },
                child: _isLoading?
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
            // Text(widget.email,style: TextStyle(color: Colors.black),),
            // Text(_otp??''),
            5.gap
          ],
        ),
      ),
    );
  }
  Future<void> verifyOtp(String otp, String email) async {
    if(_otp != null){
      setState(() {
        _isLoading = true;
      });
      UiUtils.hideKeyboard(context);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
     if(widget.mode == 'signup'){
       await authProvider.verification(email, otp, context);
     }else{
       await authProvider.loginVerification(email, otp, context);
     }
     setState(() {
       _isLoading = false;
     });
    }
  }
}
