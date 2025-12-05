import 'package:chop_chop_africa/Pages/auth_page/login.dart';
import 'package:chop_chop_africa/Pages/auth_page/sign_up.dart';
import 'package:chop_chop_africa/utility/iacolors.dart';
import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class GetStarted extends StatefulWidget {
  const GetStarted({super.key});

  @override
  State<GetStarted> createState() => _GetStartedState();
}

class _GetStartedState extends State<GetStarted> {
  bool _showMeals = true;

  @override
  void initState() {
    super.initState();
    // Switch every 1 second
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return false;
      setState(() {
        _showMeals = !_showMeals;
      });
      return true; // continue the loop
    });
  }
  @override
  Widget build(BuildContext context) {
    return  Theme(
      data: Theme.of(context).copyWith(
        dividerTheme: const DividerThemeData(
          color: Colors.transparent,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            // TextButton(
            //     onPressed: (){},
            //     child: Text('Continue as guest',
            //       style: TextStyle(
            //         color: IAColors.primary
            //       ),
            //     )
            // )
          ],
        ),
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Center(
                child: Column(
                  children: [
                    3.gap,
                    Text('African',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 30
                    ),
                    ),
                    0.5.gap,
                  AnimatedSwitcher(
                    duration: const Duration(seconds: 1),
                    transitionBuilder: (child, animation) {
                      // You can mix animations (fade + slide)
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(scale: animation, child: child),
                      );
                    },
                    child: Container(
                      key: ValueKey(_showMeals), // triggers animation when text changes
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color:  _showMeals ? Color(0xffF7B100):IAColors.dialogDark,
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(
                          color: _showMeals ?Colors.black:IAColors.primary,
                          width: 2.5,
                        ),
                      ),
                      child: Text(
                        _showMeals ? 'Meals' : 'Ingredients',
                        style:  TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 25,
                          color: _showMeals?IAColors.primary:Color(0xffF7B100),
                        ),
                      ),
                    ),
                  ),
                    0.5.gap,
                    Text('Near You.',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 30
                      ),
                    ),

                  ],
                ),
              ),
              Column(
                children: [
                  18.gap,
                  Image.asset('assets/images/OBJECTS.png'),
                ],
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
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context){
                    return SignUp();
                  }));
                },
                child: Text('Get Started',
                  style: TextStyle(
                      color: Colors.white
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: TextStyle(
                        color: IAColors.dialogDark
                      ),
                      children: [
                        TextSpan(
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(context, MaterialPageRoute(builder: (context){
                                  return Login();
                                }));
                              },
                          text: 'Log in',
                          style: TextStyle(
                            color: IAColors.primary
                          )
                        )
                      ]
                    ),
                )
              ],
            ),
          ),
          3.gap,
        ],
      ),
    );
  }
}
