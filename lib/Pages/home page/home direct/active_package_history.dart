import 'package:chop_chop_africa/utility/iacolors.dart';
import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ActivePackageHistory extends StatefulWidget {
  const ActivePackageHistory({super.key});

  @override
  State<ActivePackageHistory> createState() => _ActivePackageHistoryState();
}

class _ActivePackageHistoryState extends State<ActivePackageHistory> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 2,
        itemBuilder: (context, index){
        return Padding(
          padding:  EdgeInsets.only(bottom: 6.pH),
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: IAColors.appBarLightGrey),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _userInfo('Rectangle 6337.svg', 'Sender', 'Alex Laye'),
                    Row(
                      children: [
                        SvgPicture.asset('assets/svg/arrow-right.svg'),
                        2.gap,
                        _userInfo('location(2).svg', 'Receiver', 'Alex Laye'),
                        7.gap
                      ],
                    )
                  ],
                ),
                Divider(color: IAColors.appBarLightGrey,),
                1.gap,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _packageDetails(false, 'Cost', '\$20'),
                    _packageDetails(true, 'Package', 'Food'),
                    _packageDetails(true, 'Delivery Address', 'Abc'),
                  ],
                )
              ],
            ),
          ),
        );
        }
    );
  }

  Widget _userInfo(String image, String role, String name){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: SvgPicture.asset('assets/svg/$image'),
        ),
        0.7.gap,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(role,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400
            ),
            ),
            Text(name,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800
            ),
            )
          ],
        )
      ],
    );
  }

  Widget _packageDetails(bool withSeparator, String title, String subTitle){
    return  Row(
      children: [
        withSeparator? Container(
            height: 5.pH,
            width: 1,
            color: IAColors.appBarLightGrey
        ):Container(),
        1.gap,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 15
              ),
            ),
            0.5.gap,
            Text(subTitle,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13
              ),
            ),
          ],
        ),
      ],
    );
  }
}
