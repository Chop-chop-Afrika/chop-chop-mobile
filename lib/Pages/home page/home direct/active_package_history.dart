import 'package:chop_chop_africa/backend/models/get_active_package_model.dart';
import 'package:chop_chop_africa/backend/store_provider.dart';
import 'package:chop_chop_africa/utility/iacolors.dart';
import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ActivePackageHistory extends StatefulWidget {
  final String status;
  const ActivePackageHistory({super.key, required this.status});

  @override
  State<ActivePackageHistory> createState() => _ActivePackageHistoryState();
}

class _ActivePackageHistoryState extends State<ActivePackageHistory> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<StoreProvider>(context, listen: false).getPackageStatus(widget.status);
  }
  String _formatNumberWithCommas(dynamic number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<StoreProvider>(
      builder: (context, stores, child) {
        final grouped = <String, List<ActivePackageList>>{};
        for (var store in stores.activePackage) {
          final dateKey = DateFormat('d MMMM, yyyy').format(store.updatedAtDateTime);

          if (!grouped.containsKey(dateKey)) {
            grouped[dateKey] = [];
          }
          grouped[dateKey]!.add(store);
        }
        return stores.activePackage.isNotEmpty?
        ListView.builder(
            itemCount: grouped.length,
            itemBuilder: (context, index){
              final keys = grouped.keys.toList();
              keys.sort((a, b) => DateFormat('d MMMM, yyyy').parse(b).compareTo(DateFormat('d MMMM, yyyy').parse(a)));
              final date = keys[index];
              final dateTransactions = grouped[date]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      date,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...dateTransactions.map((transaction) => _packageData(transaction,)
                  ),
                ],
              );

            }
        ):Center(
          child: Text(
            'No Packages available yet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        );
      }
    );
  }

  String cutUnwantedPart(String name) {
    if (name.length > 20) {
      return name.trim().replaceRange(20, null, '...');
    }
    return name;
  }


  Widget _packageData(ActivePackageList activePackage){
    return  Padding(
      padding:  EdgeInsets.only(bottom: 3.pH),
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
                _userInfo('Rectangle 6337.svg', 'Sender', activePackage.senderName!),
                Row(
                  children: [
                    SvgPicture.asset('assets/svg/arrow-right.svg'),
                    2.gap,
                    _userInfo('location(2).svg', 'Receiver', activePackage.receiverName!),
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
                _packageDetails(true, 'Package', activePackage.type!),
                _packageDetails(true, 'Delivery Address', cutUnwantedPart(activePackage.dropOffAddress!)),
              ],
            )
          ],
        ),
      ),
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
