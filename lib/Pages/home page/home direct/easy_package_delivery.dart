import 'package:chop_chop_africa/Pages/home%20page/home%20direct/active_package_history.dart';
import 'package:chop_chop_africa/Pages/home%20page/home%20direct/recieve_package.dart';
import 'package:chop_chop_africa/Pages/home%20page/home%20direct/send_package.dart';
import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:chop_chop_africa/utility/uiutils.dart';
import 'package:flutter/material.dart';


class EasyPackageDelivery extends StatelessWidget {
  const EasyPackageDelivery({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        leading: IconButton(
          icon: UiUtils.backButton(context),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              1.5.gap,
              Text('Easy package delivery',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700
                ),
              ),
              Text('Send package to friends, businesses or family',
              style: TextStyle(
                fontSize: 13
              ),
              ),
              4.gap,
              GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context){
                    return SendPackage();
                  }));
                },
                  child: _topContainers('Box.png', Color(0xffFDF2DF), 'Send Package')),
              2.gap,
              GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context){
                      return ReceivePackage();
                    }));
                  },
                  child: _topContainers('Group.png', Color(0xffFFE3D9), 'Receive package'))
              ,
              2.gap,
              GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context){
                      return ActivePackageHistory();
                    }));
                  },child: _topContainers('Group (1).png', Color(0xffE9FFF5), 'History'))
            ],
          ),
        ),
      ),
    );
  }
  Widget _topContainers(String image, Color color, String title) {
    return Stack(
      children: [
        Container(
          height: 26.pH,
          width: double.infinity,
          decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12)
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top:12.0),
            child: Text(title,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset('assets/images/$image', height: 29.pW,)),

      ],
    );
  }
}
