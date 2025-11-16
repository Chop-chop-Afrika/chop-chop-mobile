import 'package:chop_chop_africa/Pages/home%20page/home%20direct/home.dart';
import 'package:chop_chop_africa/Pages/home%20page/order_direct/orders.dart';
import 'package:chop_chop_africa/Pages/home%20page/profile%20direct/profile.dart';
import 'package:chop_chop_africa/Pages/home%20page/support_direct/support.dart';
import 'package:chop_chop_africa/backend/address_provider.dart';
import 'package:chop_chop_africa/backend/profile_provider.dart';
import 'package:chop_chop_africa/utility/iacolors.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';


class MainHome extends StatefulWidget {
  const MainHome({super.key,});

  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  int _currentIndex = 0;
  final List<Widget> _body = [
    Home(),
    Orders(),
    Support(),
    Profile()
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getAllNecessaryBackendData();
    _connection();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: AppColors.scaffoldBackground,
      body: _body[_currentIndex],
      bottomNavigationBar:
      BottomNavigationBar(
         backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          type: BottomNavigationBarType.fixed,
          elevation: 1,
          currentIndex: _currentIndex,
          selectedItemColor: IAColors.primary,
          showUnselectedLabels: true,
          unselectedItemColor: Colors.grey,
          onTap: (newIndex){
            setState(() {
              _currentIndex = newIndex;
            });
          },
          items: [
            BottomNavigationBarItem(
                label: "Home",
                icon: SvgPicture.asset('assets/svg/Home 1.svg',colorFilter: ColorFilter.mode(
                  IAColors.grey,
                  BlendMode.srcIn,
                )),
                activeIcon: SvgPicture.asset('assets/svg/Home 1.svg',)

            ),
            BottomNavigationBarItem(
                label: "Order",
                icon: SvgPicture.asset('assets/svg/bag-2.svg'),
                activeIcon: SvgPicture.asset('assets/svg/bag-2.svg',colorFilter: ColorFilter.mode(
                  IAColors.primary,
                  BlendMode.srcIn,
                ),)
            ),
            BottomNavigationBarItem(
                label: "Support",
                icon: SvgPicture.asset('assets/svg/message.svg'),
                activeIcon: SvgPicture.asset('assets/svg/message.svg',colorFilter: ColorFilter.mode(
                  IAColors.primary,
                  BlendMode.srcIn,
                ))
            ),
            BottomNavigationBarItem(
              label: "Profile",
              icon: SvgPicture.asset('assets/svg/Ellipse 8.svg'),
              activeIcon: SvgPicture.asset('assets/svg/Ellipse 8.svg',colorFilter: ColorFilter.mode(
                IAColors.primary,
                BlendMode.srcIn,
              )),
            ),
          ]
      ),
    );
  }
  _connection() {
    final Connectivity connectivity = Connectivity();
    connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
      if (result == ConnectivityResult.mobile || result == ConnectivityResult.wifi) {
        print('gfoghfugosughdafhufhuh');
        _getAllNecessaryBackendData();
      }
    });
  }
  _getAllNecessaryBackendData(){
    Provider.of<AddressProvider>(context,listen: false).getAllAddresses();
    Provider.of<ProfileProvider>(context,listen: false).getProfile();
  }
}
