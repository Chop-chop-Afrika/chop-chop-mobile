import 'package:chop_chop_africa/Pages/home%20page/home%20direct/vendor_detail.dart';
import 'package:chop_chop_africa/backend/address_provider.dart';
// `Record` is also a dart:core type; the explicit import is what makes the
// name here mean a store from /user/stores.
import 'package:chop_chop_africa/backend/models/user_stores_model.dart';
import 'package:chop_chop_africa/backend/store_provider.dart';
import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:chop_chop_africa/custom%20widgets/async_content.dart';
import 'package:chop_chop_africa/custom%20widgets/pressable.dart';
import 'package:chop_chop_africa/custom%20widgets/refreshable.dart';
import 'package:chop_chop_africa/utility/typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../backend/profile_provider.dart';
import '../../../utility/iacolors.dart';
import '../../../utility/uiutils.dart';

class Vendors extends StatefulWidget {
  final String type;
  const Vendors({super.key, required this.type});

  @override
  State<Vendors> createState() => _VendorsState();
}

class _VendorsState extends State<Vendors> {
  final ScrollController _scrollController = ScrollController();

  /// /user/search is neither scoped by store type nor by location, so it
  /// would answer a search on this screen with restaurants and with places
  /// that cannot deliver here. The list this screen already has is scoped
  /// both ways, so searching filters that instead - after fetching whatever
  /// pages of it are still outstanding.
  bool _searching = false;
  String _query = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _openSearch() {
    setState(() => _searching = true);
    final address = Provider.of<AddressProvider>(context, listen: false);
    final here = address.defaultAddress ??
        (address.addressList.isEmpty ? null : address.addressList.first);
    if (here == null) return;
    Provider.of<StoreProvider>(context, listen: false).loadRestOfStores(
      widget.type,
      here.latitude.toString(),
      here.longitude.toString(),
    );
  }

  void _closeSearch() {
    setState(() {
      _searching = false;
      _query = '';
      _searchController.clear();
    });
  }

  /// Case-insensitive, over the name. That is the field /user/search matches
  /// stores on, so searching here behaves the same way.
  List<Record> _matching(List<Record> all) {
    final String q = _query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all
        .where((item) => (item.name ?? '').toLowerCase().contains(q))
        .toList();
  }

  /// `status` was being printed here, so every vendor showed an integer
  /// beside a star. These are the fields the API actually sends.
  String _rating(double? average, int? count) {
    if (average == null || average == 0) return 'New';
    final total = count ?? 0;
    return total > 0
        ? '${average.toStringAsFixed(1)} ($total)'
        : average.toStringAsFixed(1);
  }

  bool get _isSupermarket => widget.type.toUpperCase().contains('MARKET');
  String get _screenTitle => _isSupermarket ? 'Supermarkets' : 'Vendors';
  String get _screenNoun => _isSupermarket ? 'supermarket' : 'vendor';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileProvider>(context,listen: false).getProfile();
      final address = Provider.of<AddressProvider>(context, listen: false);
      final addressList = address.addressList;

      final defaultAddress = addressList.firstWhere(
            (item) => item.defaut == true,
        orElse: () => addressList.first,
      );

      final storeProvider = Provider.of<StoreProvider>(context, listen: false);

      // Clear AFTER the first frame
      storeProvider.clearAllDetail();

      // Fetch data AFTER the first frame
      storeProvider.fetchStores(
        widget.type,
        defaultAddress.latitude.toString(),
        defaultAddress.longitude!.toString(),
      );

      // Attach scroll listener AFTER UI builds
      _scrollController.addListener(() {
        final stores = Provider.of<StoreProvider>(context, listen: false);

        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
          if (!stores.isLoadingMoreStores && stores.hasNextStorePage) {
            stores.fetchStores(
              widget.type,
              defaultAddress.latitude.toString(),
              defaultAddress.longitude!.toString(),
              loadMore: true,
            );
          }
        }
      });
    });
  }



  @override
  Widget build(BuildContext context) {
    return Consumer<StoreProvider>(
      builder: (context,store,child) {
        // This used to spin forever when there genuinely were no vendors,
        // and it replaced the whole Scaffold, so there was no way back.
        final bool firstLoad = store.loadingStores && store.allStoresList.isEmpty;
        final List<Record> visible = _matching(store.allStoresList);
        final bool searching = _query.trim().isNotEmpty;
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: _searching
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: IAText.body(),
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      isDense: true,
                      filled: false,
                      border: InputBorder.none,
                      hintText: 'Search ${_screenTitle.toLowerCase()}',
                      hintStyle: IAText.body(color: IAColors.grey),
                    ),
                  )
                : Text(_screenTitle, style: IAText.subtitle()),
            leading: UiUtils.backButton(context),
            actions: [
              IconButton(
                  onPressed: _searching ? _closeSearch : _openSearch,
                  icon: _searching
                      ? const Icon(Icons.close)
                      : SvgPicture.asset('assets/svg/search-normal.svg'),
              ),
              1.gap,
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(7),
              child: Divider(
                color: IAColors.appBarLightGrey,
              ),
            ),
          ),
          // The empty state here literally tells the user to pull down, and
          // until now there was nothing to pull.
          body: Refreshable(
            onRefresh: _refresh,
            child: AsyncContent(
            // Fetching the rest of the list for a search is a wait like any
            // other, so it gets the same placeholder a first load does.
            loading: firstLoad || (store.loadingWholeStoreList && visible.isEmpty),
            isEmpty: visible.isEmpty,
            emptyTitle: searching
                ? 'Nothing matches "${_query.trim()}"'
                : 'No ${_screenNoun}s nearby',
            emptyMessage: searching
                ? 'No $_screenNoun around you goes by that name. Try a '
                    'different word, or clear the search to see them all.'
                : 'We could not find any ${_screenNoun}s around you right now. '
                    'Pull down to try again.',
            emptyIcon:
                searching ? Icons.search_off : Icons.storefront_outlined,
            loadingPlaceholder: const SkeletonList(count: 6, itemHeight: 90),
            builder: (context) => Padding(
            padding:  EdgeInsets.symmetric(horizontal: 20.0),
            child: ListView.builder(
                physics: Refreshable.physics,
                controller: _scrollController,
              itemCount: visible.length +
                  ((store.isLoadingMoreStores || store.loadingWholeStoreList)
                      ? 1
                      : 0),
                itemBuilder: (context,index){
                  // LOADING MORE indicator at bottom
                  if (index == visible.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final item = visible[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 26),
                  child: Pressable(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context){
                        return VendorDetail(
                          storeId: item.id!,
                          storeName: item.name!,
                          deliveryTime: item.deliveryTime!,
                          businessTime: '${item.openTime} - ${item.closeTime}',
                          rating: _rating(item.averageRating, item.totalRatings),);
                      }));
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        NetworkThumb(
                          url: item.logo,
                          height: 22.pH,
                          width: double.infinity,
                          radius: BorderRadius.circular(12),
                        ),
                        const SizedBox(height: 12),
                        // Name and meta were the same weight on adjacent lines
                        // with no gap, so the two read as one block of text.
                        Text(
                          item.name ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: IAText.title(),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SvgPicture.asset('assets/svg/bicycle 1.svg',
                                    height: 15),
                                const SizedBox(width: 6),
                                Text(item.deliveryTime ?? '',
                                    style: IAText.caption()),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.star_rounded,
                                    color: const Color(0xffF7B100), size: 17),
                                const SizedBox(width: 4),
                                Text(_rating(item.averageRating, item.totalRatings),
                                    style: IAText.caption()),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                );
                }
            ),
          ),
          ),
          ),
        );
      }
    );
  }

  Future<void> _refresh() async {
    final address = Provider.of<AddressProvider>(context, listen: false);
    final here = address.defaultAddress ??
        (address.addressList.isEmpty ? null : address.addressList.first);
    if (here == null) {
      await address.getAllAddresses();
      if (!mounted) return;
    }
    final from = Provider.of<AddressProvider>(context, listen: false)
            .defaultAddress ??
        here;
    if (from == null) return;
    await Provider.of<StoreProvider>(context, listen: false).fetchStores(
      widget.type,
      from.latitude.toString(),
      from.longitude.toString(),
    );
  }

}
