import 'package:chop_chop_africa/Pages/home%20page/order_direct/track_order.dart';
import 'package:chop_chop_africa/utility/iacolors.dart';
import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:flutter/material.dart';

import '../../../utility/uiutils.dart';

class OnGoing extends StatefulWidget {
  const OnGoing({super.key});

  @override
  State<OnGoing> createState() => _OnGoingState();
}

class _OnGoingState extends State<OnGoing> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        1.gap,
        Card(
          elevation: 1,
          color: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0,top: 8,bottom: 8),
            child: ListTile(
                leading: Container(
                  height: 15.pW,
                  width: 15.pW,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    image: DecorationImage(image: NetworkImage('https://images.pexels.com/photos/262978/pexels-photo-262978.jpeg?cs=srgb&dl=pexels-pixabay-262978.jpg&fm=jpg'),
                        fit: BoxFit.cover
                    ),
                  ),
                ),
                title: UiUtils.subTitles('Chicken Republic', 14),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order#1234',
                      style: TextStyle(
                          fontSize: 13
                      ),
                    ),
                    Text('Order#1234',
                      style: TextStyle(
                          fontSize: 13
                      ),
                    ),
                  ],
                ),
            ),
          ),
        ),
        TextButton(
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context){
                return TrackOrder();
              }));
            },
            child: Text('Track Order',
            style: TextStyle(
              color: IAColors.primary,
              decoration: TextDecoration.underline,
              decorationColor: IAColors.primary,
            ),
            )
        )
      ],
    );
  }
}
