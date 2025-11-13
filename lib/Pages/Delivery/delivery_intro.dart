import 'package:chop_chop_africa/Pages/Delivery/select_delivery_address.dart';
import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../utility/iacolors.dart';

class DeliveryIntro extends StatelessWidget {
  const DeliveryIntro({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/svg/location (1).svg'),
            Text('Select Address',
              style: TextStyle(
                  fontSize: 16
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded)
          ],
        ),
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(7),
          child: Divider(
            color: IAColors.appBarLightGrey,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/svg/big-location.svg'),
              1.gap,
              Text('Add your address to discover what’s available near you',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600
              ),
              ),
              1.gap,
              GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context){
                    return AddressSearchBar();
                  }));
                },
                child: Container(
                  padding: EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Choose delivery address',
                  style: TextStyle(
                    fontSize: 13
                  ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
