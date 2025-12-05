import 'package:chop_chop_africa/Pages/home%20page/home%20direct/active_package_history.dart';
import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:flutter/material.dart';

import '../../../utility/iacolors.dart';
import '../../../utility/uiutils.dart';

class PackageHistoryTab extends StatefulWidget {

  const PackageHistoryTab({super.key});

  @override
  State<PackageHistoryTab> createState() => _PackageHistoryTabState();
}

class _PackageHistoryTabState extends State<PackageHistoryTab> {



  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex:0,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          foregroundColor: Colors.transparent,
          automaticallyImplyLeading: true,
          title: Text('History',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600
            ),
          ),
          leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            },
            icon: UiUtils.backButton(context),
          ),

          bottom: PreferredSize(
            preferredSize: Size.fromHeight(8.pH),
            child: Column(
              children: [
                Divider(
                  color: IAColors.appBarLightGrey,
                ),
                TabBar(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Active',
                            style: TextStyle(
                                fontSize: 17
                            )
                        ),
                        SizedBox(
                          height: 7.pH,
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Completed',
                            style: TextStyle(
                                fontSize: 17
                            )
                        ),
                        SizedBox(
                          height: 7.pH,
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: TabBarView(
            children: [
              ActivePackageHistory(status: 'active',),
              ActivePackageHistory(status: 'completed',)
            ],
          ),
        ),
      ),
    );
  }
}
