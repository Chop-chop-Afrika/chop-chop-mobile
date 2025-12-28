import 'package:chop_chop_africa/Pages/home%20page/profile%20direct/addresses.dart';
import 'package:chop_chop_africa/Pages/home%20page/profile%20direct/profile_details.dart';
import 'package:chop_chop_africa/backend/profile_provider.dart';
import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../utility/iacolors.dart';
import '../../../utility/image_services.dart';
import '../../../utility/uiutils.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String placeHolderLogo = 'https://freesvg.org/img/chef-restaurant-logo-publicdomainvectors.png';
  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context,profile,child) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text('My Profile',
              style: TextStyle(
                  fontSize: 16
              ),
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(7),
              child: Divider(
                color: IAColors.veryLightGrey,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  1.gap,
                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap:()async{
                            await ImageServices().pickImages(ImageSource.gallery,'changeAvatar', context);
                          },
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(profile.getAllProfileInfo?.data?.avatar??placeHolderLogo),
                            radius: 30,
                          ),
                        ),
                        0.5.gap,
                        Text('${profile.getAllProfileInfo?.data?.firstName} ${profile.getAllProfileInfo?.data?.lastName}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700
                        ),
                        ),
                        0.5.gap,
                        Container(
                          width: 17.pW,
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: IAColors.dialogDark,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/images/fluent-color_coin-multiple-24.png',height: 3.pH,),
                              Text('20',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xffF7B100),
                                fontWeight: FontWeight.w600
                              ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  2.gap,
                  UiUtils.subTitles('Account', 17),
                  2.gap,
                  _accountInfo((){
                    Navigator.push(context, MaterialPageRoute(builder: (context){
                      return ProfileDetails();
                    }));
                  },'Frame 1171277849.svg', 'Profile details', Icon(Icons.arrow_forward_ios,size: 22,color: IAColors.lightGrey,)),
                  _accountInfo((){
                    Navigator.push(context, MaterialPageRoute(builder: (context){
                      return Addresses();
                    }));
                  },'location (1).svg', 'Addresses', Icon(Icons.arrow_forward_ios,size: 22,color: IAColors.lightGrey,)),
                  _accountInfo((){},'Frame 1171277849 (1).svg', 'Share and Earn', Icon(Icons.arrow_forward_ios,size: 22,color: IAColors.lightGrey,)),
                  3.gap,
                  UiUtils.subTitles('General', 17),
                  2.gap,
                  _accountInfo((){},'Frame 1171277849 (2).svg', 'Privacy and Policy', null),
                  _accountInfo((){},'Frame 1171277849 (2).svg', 'Terms of Service', null),
                  _accountInfo((){},'Frame 1171277849 (3).svg', 'Rate the app', null),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: SvgPicture.asset('assets/svg/Frame 1171277849 (4).svg'),
                    title: Text('Log Out',
                    ),
                    titleTextStyle: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                        color: Colors.red
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
  Widget _accountInfo(void Function() onTap,String icon, String title, Icon? iconMove){
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          MediaQuery.removePadding(
            context: context,
            removeTop: true,
            removeBottom: true,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: SvgPicture.asset('assets/svg/$icon'),
              title: Text(title),
              titleTextStyle: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w400,
                color: Colors.black
              ),
              trailing: iconMove,
            ),
          ),
          Divider(color: IAColors.lightGrey,height: 0,)
        ],
      ),
    );
  }
}
