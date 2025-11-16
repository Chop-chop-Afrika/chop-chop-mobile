import 'package:chop_chop_africa/Pages/home%20page/main_home.dart';
import 'package:chop_chop_africa/backend/auth_provider.dart';
import 'package:chop_chop_africa/backend/address_provider.dart';
import 'package:chop_chop_africa/backend/profile_provider.dart';
import 'package:chop_chop_africa/backend/store_provider.dart';
import 'package:chop_chop_africa/utility/iacolors.dart';
import 'package:chop_chop_africa/utility/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart' as provider;
import 'package:shared_preferences/shared_preferences.dart';

import 'Pages/auth_page/get_started.dart';


final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>();

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(provider.MultiProvider(
      providers: [
        provider.ChangeNotifierProvider<AuthProvider>(create:(_) => AuthProvider()),
        provider.ChangeNotifierProvider<AddressProvider>(create:(_) => AddressProvider()),
        provider.ChangeNotifierProvider<ProfileProvider>(create:(_) => ProfileProvider()),
        provider.ChangeNotifierProvider<StoreProvider>(create:(_) => StoreProvider())
      ],
      child: MyApp(prefs: prefs,))
  );
  _easyLoading();
}
_easyLoading(){
  EasyLoading.instance
    ..indicatorType = EasyLoadingIndicatorType.circle
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 30.0
    ..radius = 50.0
    ..progressColor = IAColors.darkGrey
    ..backgroundColor = Colors.transparent
    ..textColor = Colors.cyan
    ..indicatorColor =  IAColors.darkGrey
    ..userInteractions = true
    ..boxShadow = <BoxShadow>[]
    ..dismissOnTap = false;

}
class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  const MyApp({super.key, required this.prefs});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent
      )
    );
    return ScreenUtilInit(
        minTextAdapt: true,
        ensureScreenSize: true,
      builder: (context,child) {
        return MaterialApp(
          navigatorKey: globalNavigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: IATheme.getLightTheme(),
          home: prefs.getString('accessToken')!.isEmpty?
          GetStarted():MainHome(),
          builder: EasyLoading.init(),
        );
      }
    );
  }
}

