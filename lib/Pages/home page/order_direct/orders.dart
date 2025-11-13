import 'package:chop_chop_africa/Pages/home%20page/order_direct/completed.dart';
import 'package:chop_chop_africa/Pages/home%20page/order_direct/my_cart.dart';
import 'package:chop_chop_africa/Pages/home%20page/order_direct/on_going.dart';
import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:flutter/material.dart';

import '../../../utility/iacolors.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Orders',
            style: TextStyle(
                fontSize: 16
            ),
          ),
          automaticallyImplyLeading: false,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(4.pH),
            child: Column(
              children: [
                Divider(
                  color:  IAColors.veryLightGrey,
                ),
                TabBar(
                  labelColor: Colors.black,
                  labelStyle: Theme.of(context).textTheme.bodySmall,
                  indicatorWeight: 0.01,
                  dividerColor: IAColors.veryLightGrey,
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
                      child: Text('My Cart',
                      style: TextStyle(
                        fontSize: 17
                      ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('Ongoing',
                        style: TextStyle(
                            fontSize: 17
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('Completed',
                        style: TextStyle(
                            fontSize: 17
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: TabBarView(
              children: [
                MyCart(),
                OnGoing(),
                Completed(),
              ]
          ),
        ),
      ),
    );
  }
}