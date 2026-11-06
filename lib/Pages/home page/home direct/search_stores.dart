import 'package:chop_chop_africa/Pages/home%20page/home%20direct/vendor_detail.dart';
import 'package:chop_chop_africa/backend/models/search_store_model.dart';
import 'package:chop_chop_africa/custom%20widgets/pressable.dart';
import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// The stores half of a search result, rendered inline.
///
/// This used to be a whole screen of its own behind a "Stores" tab, with its
/// own scrolling, loading and empty states. Stores and products are searched
/// together now, so [SearchPage] owns all three and this just lays out the
/// rows it is given.
class SearchStores extends StatelessWidget {
  final List<StoreModelData> items;

  const SearchStores({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Column(
          children: [
            Pressable(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return VendorDetail(
                    storeId: item.id ?? '',
                    storeName: item.name ?? '',
                    deliveryTime: item.deliveryTime ?? '',
                    businessTime: '${item.openTime} - ${item.closeTime}',
                  );
                }));
              },
              // A raw NetworkImage on item.logo! threw on any store without
              // one, and had no fallback when the image failed to load.
              child: NetworkThumb(
                url: item.logo,
                height: 22.pH,
                width: double.infinity,
                radius: BorderRadius.circular(12),
              ),
            ),
            1.gap,
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.name ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SvgPicture.asset('assets/svg/bicycle 1.svg', height: 15),
                const SizedBox(width: 6),
                Text(
                  item.deliveryTime ?? '',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w300),
                ),
                // There used to be a star here with `item.status` beside it,
                // so every result read as being rated "1" - the same bug the
                // vendors list had. /user/search returns no rating at all,
                // so there is nothing honest to show.
              ],
            ),
            3.gap,
          ],
        );
      },
    );
  }
}
