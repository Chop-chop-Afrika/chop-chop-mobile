import 'package:chop_chop_africa/backend/auth_provider.dart';
import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:chop_chop_africa/utility/uiutils.dart';
import 'package:flutter/material.dart';
import 'package:phone_text_field/phone_text_field.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '../../utility/iacolors.dart';
import 'package:loading_indicator/loading_indicator.dart';


class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dateController = TextEditingController();
  bool _isLoading = false;
  String _referralCode = "";
  GlobalKey<FormState> _globalKey = GlobalKey<FormState>();

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
    final authData = Provider.of<AuthProvider>(context,listen: false);
    return Form(
      key: _globalKey,
      child: Theme(
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
            child: SingleChildScrollView(
              child: Column(
                children: [
                  0.5.gap,
                  Center(
                    child: Text('Let’s get started',
                    style: TextStyle(
                      color: IAColors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.w800
                    ),
                    ),
                  ),
                  0.5.gap,
                  Center(
                    child: Text('We just need a bit more information. Please enter your details to get started.',
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
                  title('Email'),
                  SizedBox(
                    height:11.pH,
                    child: TextFormField(
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
                          helperText: ''
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          title('First Name'),
                          SizedBox(
                            height:11.pH, width: 43.pW,
                            child: TextFormField(
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
                                  helperText: ''
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          title('Last Name'),
                          SizedBox(
                            height:11.pH, width: 43.pW,
                            child: TextFormField(
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
                                  helperText: ''
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  title('D.O.B'),
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
                  title('Referral Code (optional)'),
                  SizedBox(
                    height:11.pH,
                    child: TextFormField(
                      onChanged: (v){
                        _referralCode = v;
                      },
                      style: theme.textTheme.bodySmall,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          contentPadding: EdgeInsets.only(top: 3,left: 10),
                          errorStyle: TextStyle(
                              fontSize: 14
                          ),
                          hintText: 'Enter Referral Code',
                          hintStyle: TextStyle(
                              height: 2,
                              fontSize: 14
                          ),
                          helperText: ''
                      ),
                    ),
                  ),
                  3.gap
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
                  onPressed: () async{
                    await _signIn(authData);
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
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: RichText(
                      textAlign:TextAlign.center,
                      text: TextSpan(
                          text: 'By signing up, you agree to ChopChop Afrika’s ',
                          style: TextStyle(
                              color: IAColors.dialogDark,
                            fontSize: 15
                          ),
                          children: [
                            TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {

                                  },
                                text: 'Terms of use ',
                                style: TextStyle(
                                    color: IAColors.primary
                                )
                            ),
                            TextSpan(
                                text: 'and ',
                            ),
                            TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {

                                  },
                                text: 'Privacy Policy',
                                style: TextStyle(
                                    color: IAColors.primary
                                )
                            )
                          ]
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  _signIn(AuthProvider authData)async{
    if(_globalKey.currentState!.validate()){
      setState(() {
        _isLoading = true;
      });
      await authData.signUp(
          _firstNameController.text,
          _lastNameController.text,
          _emailController.text,
          _phoneController.text,
          _dateController.text,
          _referralCode,
          context);
      setState(() {
        _isLoading = false;
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
        "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
      });
    }
  }
}
