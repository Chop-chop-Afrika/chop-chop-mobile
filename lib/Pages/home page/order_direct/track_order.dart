import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:flutter/material.dart';

import '../../../utility/iacolors.dart';
import '../../../utility/uiutils.dart';

class TrackOrder extends StatefulWidget {
  const TrackOrder({super.key});

  @override
  State<TrackOrder> createState() => _TrackOrderState();
}

class _TrackOrderState extends State<TrackOrder> {
  String number = "4032";
  bool _check = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Orders Details',
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
        child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      1.gap,
                      UiUtils.subTitles('Hi {Name}', 17),
                      0.5.gap,
                      Text('Your Order arrives in 20 Mins',
                      style: TextStyle(
                        fontSize: 14
                      ),
                      ),
                      2.gap,
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(0xffFDF2DF),
                          borderRadius: BorderRadius.circular(8)
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Delivery confirmation codes',
                              style: TextStyle(
                                  fontSize: 14
                              ),
                            ),
                            UiUtils.subTitles('Show this code to your rider', 15),
                            1.5.gap,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: number.split("").map((char) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade400),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    char,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      2.gap,
                      UiUtils.subTitles('Contact Dispatch', 15),
                      2.gap,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 26,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Name',
                                    style: TextStyle(
                                      fontSize: 13
                                    ),
                                    ),
                                    UiUtils.subTitles('John Doe', 16)
                                  ],
                                ),
                              )
                            ],
                          ),
                          ElevatedButton(
                              onPressed: (){},
                              style: ButtonStyle(
                                elevation: WidgetStatePropertyAll(0)
                              ),
                              child: Text('Call Rider')
                          )
                        ],
                      ),
                      3.gap,
                        
                    ],
                  ),
                ),
              )
            ];
          },
          body:ListView.separated(
            itemCount: 6,
            itemBuilder: (context, index){
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Theme(
                        data: Theme.of(context).copyWith(
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Checkbox(
                            side: BorderSide(
                                width: 1,
                                color: Colors.grey.shade400
                            ),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                            value: _check,
                            onChanged: (v){
                              setState(() {
                                _check = v!;
                              });
                            }
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 6.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            UiUtils.subTitles('Booking Confirmation', 14),
                            Text('Order is been pushed to vendor',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500
                              ),
                            )
                          ],
                        ),
                      ),

                    ],
                  )
                ],
              );
            },
            separatorBuilder: (_, __) => Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Divider(color: Colors.grey.shade200,),
            ),
          ),
        ),
      ),
    );
  }
}
