import 'package:chop_chop_africa/Pages/home%20page/home%20direct/vendor_grid.dart';
import 'package:chop_chop_africa/backend/store_provider.dart';
import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:chop_chop_africa/custom%20widgets/async_content.dart';
import 'package:chop_chop_africa/utility/typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../../utility/iacolors.dart';
import '../../../utility/uiutils.dart';

class VendorDetail extends StatefulWidget {
  final String storeId;
  final String storeName;
  final String deliveryTime;
  final String businessTime;
  /// Already formatted by the caller, e.g. "4.5 (128)" or "New". Optional so
  /// the screens that do not yet have it keep working.
  final String? rating;
  const VendorDetail({super.key,required this.storeId, required this.storeName, required this.deliveryTime, required this.businessTime, this.rating,});

  @override
  State<VendorDetail> createState() => _VendorDetailState();
}

class _VendorDetailState extends State<VendorDetail> {
  /// /user/search has no storeId parameter, so searching a single vendor is
  /// done against the menu this screen has already loaded. The query is
  /// handed to each [VendorGrid], which knows its own category and so can
  /// fetch the rest of the right list before filtering it.
  bool _searching = false;
  String _query = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<StoreProvider>(context,listen: false).fetchStoreDetail(widget.storeId, null);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openSearch() => setState(() => _searching = true);

  void _closeSearch() {
    setState(() {
      _searching = false;
      _query = '';
      _searchController.clear();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<StoreProvider>(
      builder: (context,store,child) {
        final categories = store.getAllProductCategories?.data ?? [];
        // categories! crashed this screen whenever the category request had
        // not finished, which is the normal case on first open.
        if (categories.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.storeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: IAText.subtitle()),
              leading: UiUtils.backButton(context),
            ),
            body: AsyncContent(
              loading: store.loadingCategories,
              isEmpty: true,
              emptyTitle: 'Nothing on the menu yet',
              emptyMessage: 'This vendor has not added any items.',
              emptyIcon: Icons.restaurant_menu_outlined,
              loadingPlaceholder: const SkeletonList(count: 4, itemHeight: 120),
              builder: (_) => const SizedBox.shrink(),
            ),
          );
        }
        return DefaultTabController(
          length: categories.length + 1,
          child: Scaffold(
            appBar: AppBar(
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
                        hintText: 'Search ${widget.storeName}',
                        hintStyle: IAText.body(color: IAColors.grey),
                      ),
                    )
                  : Text(widget.storeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: IAText.subtitle()),
              leading: UiUtils.backButton(context),
              actions: [
                if (_searching)
                  IconButton(
                    onPressed: _closeSearch,
                    icon: const Icon(Icons.close),
                  )
                else ...[
                  IconButton(
                    onPressed: _openSearch,
                    icon: SvgPicture.asset('assets/svg/search-normal.svg'),
                  ),
                  SvgPicture.asset('assets/svg/heart.svg'),
                ],
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
                        children: [
                          _ratingsNDelivery(false, 'Delivery time', widget.deliveryTime, flex: 5),
                          _ratingsNDelivery(true, 'Rating', widget.rating ?? 'New', flex: 4),
                          _ratingsNDelivery(true, 'Business time', widget.businessTime, flex: 6),
                        ],
                      ),
                    ),
                    Divider(color: IAColors.veryLightGrey,),
                    TabBar(
                      isScrollable: true,
                      labelColor: Colors.black,
                      labelStyle: IAText.label(weight: FontWeight.w600),
                      unselectedLabelStyle: IAText.label(),
                      unselectedLabelColor: IAColors.darkGrey,
                      tabAlignment: TabAlignment.start,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 14),
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
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: Text('All Products'),
                        ),
                        ...categories.map((c) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10.0),
                              child: Text(c.name ?? ''),
                            )),

                      ],
                    ),
                  ],
                ),
              ),
            ),
            body: TabBarView(
                children:[
                  VendorGrid(category: null,storeId: widget.storeId, query: _query,), // All Items
                  ...categories.map((c) => VendorGrid(category: c.id,storeId: widget.storeId, query: _query,)),
                ]
            )
          ),
        );
      }
    );
  }
  /// The label sits quietly above the value it describes. It used to be the
  /// larger and bolder of the two, which made every stat read as a heading.
  ///
  /// [flex] lets business hours, which are the longest of the three, claim
  /// more of the row than the rating does. Opening times are the one thing
  /// here a user must be able to read in full, so the value shrinks to fit
  /// rather than being cut off with an ellipsis.
  Widget _ratingsNDelivery(bool withSeparator, String title, String subTitle,
      {int flex = 3}){
    return Expanded(
      flex: flex,
      child: Row(
        children: [
          if (withSeparator)
            Container(
              height: 32,
              width: 1,
              color: IAColors.appBarLightGrey,
            ),
          SizedBox(width: withSeparator ? 10 : 0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: IAText.micro()),
                const SizedBox(height: 3),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(subTitle,
                        maxLines: 1,
                        softWrap: false,
                        style: IAText.label(weight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
