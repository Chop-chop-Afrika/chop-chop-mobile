import 'package:chop_chop_africa/Pages/home%20page/home%20direct/vendor_grid.dart';
import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../utility/iacolors.dart';
import '../../../utility/uiutils.dart';

class VendorDetail extends StatefulWidget {
  const VendorDetail({super.key});

  @override
  State<VendorDetail> createState() => _VendorDetailState();
}

class _VendorDetailState extends State<VendorDetail> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Chicken Republic',
            style: TextStyle(
                fontSize: 16
            ),
          ),
          leading: UiUtils.backButton(context),
          actions: [
            IconButton(
              onPressed: (){},
              icon: SvgPicture.asset('assets/svg/search-normal.svg'),
            ),
            SvgPicture.asset('assets/svg/heart.svg'),
            1.gap,
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(14.pH),
            child: Column(
              children: [
                Divider(
                  color: IAColors.appBarLightGrey,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _ratingsNDelivery(false, 'Delivery Time', '5-10 mins'),
                      _ratingsNDelivery(true, 'Rating', '4.0 (200)'),
                      _ratingsNDelivery(true, 'Business Time', '9 - 7:20 pm'),
                    ],
                  ),
                ),
                Divider(color: IAColors.veryLightGrey,),
                TabBar(
                  isScrollable: true,
                  labelColor: Colors.black,
                  labelStyle: Theme.of(context).textTheme.bodySmall,
                  dividerColor: IAColors.veryLightGrey,
                  indicatorWeight: 0.01,
                  indicator: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: IAColors.primary_60,
                        width: 2,
                      ),
                    ),
                  ),
                  tabs: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('Top Sellers'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('Deals'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('Deals'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('Deals'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text('Deals'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
            children:[
              VendorGrid(),
              VendorGrid(),
              VendorGrid(),
              VendorGrid(),
              VendorGrid(),
            ]
        )
      ),
    );
  }
  Widget _ratingsNDelivery(bool withSeparator, String title, String subTitle){
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
                  fontWeight: FontWeight.w700,
                  fontSize: 15
              ),
            ),
            0.5.gap,
            Text(subTitle,
              style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 13
              ),
            ),
          ],
        ),
      ],
    );
  }
}
