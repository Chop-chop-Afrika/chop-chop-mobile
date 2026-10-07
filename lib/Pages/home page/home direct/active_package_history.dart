import 'package:chop_chop_africa/backend/models/get_active_package_model.dart';
import 'package:chop_chop_africa/backend/store_provider.dart';
import 'package:chop_chop_africa/utility/iacolors.dart';
import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:chop_chop_africa/Pages/home%20page/home%20direct/track_package.dart';
import 'package:chop_chop_africa/backend/package_provider.dart';
import 'package:chop_chop_africa/backend/models/package_model.dart';
import 'package:chop_chop_africa/utility/uiutils.dart';

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
    // A package still awaiting its payment webhook is not in this list, so
    // surface it separately rather than losing it.
    if (widget.status == 'active') {
      Provider.of<PackageProvider>(context, listen: false).loadPendingPackage();
    }
  }

  /// Banner for a booking whose payment has not been confirmed yet.
  Widget _pendingBanner() {
    return Consumer<PackageProvider>(
      builder: (context, packages, _) {
        final String? id = packages.pendingPackageId;
        if (id == null || widget.status != 'active') {
          return const SizedBox.shrink();
        }
        final PackageData? pkg = packages.packageDetail;
        return Padding(
          padding: EdgeInsets.only(bottom: 2.pH),
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TrackPackage(packageId: id)),
            ).then((_) {
              if (mounted) packages.loadPendingPackage();
            }),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xffFDF2DF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        UiUtils.subTitles('Confirming a payment', 14),
                        Text(
                          pkg?.dropOffAddress == null
                              ? 'Tap to see your latest booking'
                              : 'To ${pkg!.dropOffAddress}',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey.shade500),
                ],
              ),
            ),
          ),
        );
      },
    );
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
            itemCount: grouped.length + 1,
            itemBuilder: (context, rawIndex){
              // The pending-payment banner sits above the dated groups.
              if (rawIndex == 0) return _pendingBanner();
              final index = rawIndex - 1;
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
        ):ListView(
          children: [
            _pendingBanner(),
            SizedBox(height: 20.pH),
            Center(
              child: Text(
                'No Packages available yet',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
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
      child: GestureDetector(
        onTap: activePackage.id == null
            ? null
            : () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TrackPackage(packageId: activePackage.id!),
                  ),
                ).then((_) {
                  // Status may have moved on while the tracking page was open.
                  if (mounted) {
                    Provider.of<StoreProvider>(context, listen: false)
                        .getPackageStatus(widget.status);
                  }
                }),
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
