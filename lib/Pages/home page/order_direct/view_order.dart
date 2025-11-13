import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../../utility/iacolors.dart';
import '../../../utility/uiutils.dart';

class ViewOrder extends StatefulWidget {
  const ViewOrder({super.key});

  @override
  State<ViewOrder> createState() => _ViewOrderState();
}

class _ViewOrderState extends State<ViewOrder> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerTheme: const DividerThemeData(
          color: Colors.transparent,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Order Details',
            style: TextStyle(
                fontSize: 16
            ),
          ),
          leading: UiUtils.backButton(context),
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
                1.5.gap,
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Color(0xffFDF2DF),
                      borderRadius: BorderRadius.circular(8)
                  ),
                  child:Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UiUtils.subTitles('You rated this Business', 17),
                      0.5.gap,
                      RatingBar.builder(
                        initialRating: 3.5,
                        minRating: 1,
                        itemSize: 7.pW,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding: EdgeInsets.symmetric(horizontal: 4),
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          print(rating);
                        },
                      )
                    ],
                  ),
                ),
                2.gap,
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Color(0xffFBFBFB),
                      borderRadius: BorderRadius.circular(8)
                  ),
                  child: Row(
                    children: [
                      Image.asset('assets/images/Frame 1171277941.png',height: 22.pH,),
                      2.gap,
                      SizedBox(
                        width: 70.pW,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('Chicken Republic - Ikoyi, chicken-republic- island.',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700
                              ),
                            ),
                            Text('Wed 14 Feb,2024 @10:29',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 12
                            ),
                            ),
                            4.gap,
                            Text('Chicken Republic - Ikoyi, chicken-republic- island.',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700
                              ),
                            ),
                            Text('Wed 14 Feb,2024 @10:29',
                              style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 12
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                2.gap,
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    height: 15.pW,
                    width: 15.pW,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      image: DecorationImage(image: NetworkImage('https://images.pexels.com/photos/262978/pexels-photo-262978.jpeg?cs=srgb&dl=pexels-pixabay-262978.jpg&fm=jpg'),
                          fit: BoxFit.cover
                      ),
                    ),
                  ),
                  title: UiUtils.subTitles('Chicken Republic', 14),
                  subtitle: Text('4 items ● \$25',
                    style: TextStyle(
                        fontSize: 13
                    ),
                  ),
                ),
                2.gap,
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xffEEEEEE),
                      borderRadius: BorderRadius.circular(8)
                  ),
                  child: Column(
                    children: [
                      _totalDetail('Sub-total (5 items)', '\$12.55',null),
                      1.gap,
                      _totalDetail('Delivery Fee', '\$12.55',null),
                      1.gap,
                      _totalDetail('Service Fees', '\$12.55',null),
                      1.gap,
                      _totalDetail('Total', '\$12.55',FontWeight.w700),
                    ],
                  ),
                ),
                5.gap,

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
                onPressed: () {

                },
                child: Text('Repeat Order',
                  style: TextStyle(
                      color: Colors.white
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _totalDetail(String detail, String value, FontWeight? fontWeight){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(detail,
        style: TextStyle(
          fontSize: 14,
          fontWeight: fontWeight
        ),
        ),
        Text(value,
          style: TextStyle(
              fontSize: 14,
            fontWeight: FontWeight.w700
          ),
        ),
      ],
    );
  }
}
