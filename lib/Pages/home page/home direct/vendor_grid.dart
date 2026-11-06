import 'package:chop_chop_africa/Pages/home%20page/order_direct/orders.dart';
import 'package:chop_chop_africa/backend/store_provider.dart';
import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:chop_chop_africa/utility/uiutils.dart';
import 'package:chop_chop_africa/custom%20widgets/async_content.dart';
import 'package:chop_chop_africa/custom%20widgets/pressable.dart';
import 'package:chop_chop_africa/custom%20widgets/refreshable.dart';
import 'package:chop_chop_africa/utility/money.dart';
import 'package:chop_chop_africa/utility/typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';
import 'package:intl/intl.dart';
import '../../../backend/models/store_detail_model.dart';
import '../../../backend/profile_provider.dart';
import '../../../utility/iacolors.dart';

class VendorGrid extends StatefulWidget {
  final String? category;
  final String? storeId;
  /// Filters the menu down to matching items. Empty shows everything.
  final String query;
  const VendorGrid({super.key, this.category, this.storeId, this.query = '',});

  @override
  State<VendorGrid> createState() => _VendorGridState();
}

class _VendorGridState extends State<VendorGrid> {
  int _amount = 1;
  Variants? _selectedVariant;

  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_){
      Provider.of<ProfileProvider>(context,listen: false).getProfile();
      final provider = Provider.of<StoreProvider>(context, listen: false);
      provider.clearStoreDetail();
        provider.fetchStoreDetail(
          widget.storeId!,
          widget.category ?? "",
        );

      _scrollController.addListener(() {
        final stores = Provider.of<StoreProvider>(context, listen: false);

        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
          if (!stores.isLoadingMoreStoreDetail && stores.hasNextStoreDetailPage) {
              provider.fetchStoreDetail(
                widget.storeId!,
                widget.category ?? "",
                loadMore: true,
              );
          }
        }
      });
    });
  }
  /// A filter over a half-loaded menu quietly misses matches, so the first
  /// keystroke pulls the rest of this tab's pages. It has to be this widget
  /// that asks, because the category is what decides which list is being
  /// paginated.
  @override
  void didUpdateWidget(covariant VendorGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool wasSearching = oldWidget.query.trim().isNotEmpty;
    final bool nowSearching = widget.query.trim().isNotEmpty;
    if (nowSearching && !wasSearching) {
      Provider.of<StoreProvider>(context, listen: false)
          .loadRestOfStoreDetail(widget.storeId!, widget.category ?? "");
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat("#,##0.00", "en_US");
    return Consumer<StoreProvider>(
      builder: (context,store,child) {
        final itemDetails = _matching(store.getStoreDetailList);
        final bool searching = widget.query.trim().isNotEmpty;

        // This said "No items" while the first fetch was still running, which
        // read as an empty store rather than one that had not loaded.
        return Refreshable(
          onRefresh: _refresh,
          child: AsyncContent(
          // Pulling the rest of the menu for a search is a wait like any
          // other, so it gets the same placeholder a first load does.
          loading: (store.loadingStoreDetail || store.loadingWholeMenu) &&
              itemDetails.isEmpty,
          isEmpty: itemDetails.isEmpty,
          emptyTitle: searching
              ? 'Nothing matches "${widget.query.trim()}"'
              : 'Nothing on the menu yet',
          emptyMessage: searching
              ? 'Try a different word, or clear the search to see the whole menu.'
              : 'This vendor has not added any items for this category.',
          emptyIcon:
              searching ? Icons.search_off : Icons.restaurant_menu_outlined,
          loadingPlaceholder: const SkeletonList(count: 4, itemHeight: 140),
          builder: (context) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0,horizontal: 20),
          child: Stack(
            children: [
              StaggeredGridView.countBuilder(
                  physics: Refreshable.physics,
                  controller: _scrollController,
                  itemCount: itemDetails.length +
                      ((store.isLoadingMoreStoreDetail ||
                              store.loadingWholeMenu)
                          ? 1
                          : 0),
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 12,
                  itemBuilder: (context, index){
                    if (index == itemDetails.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return Pressable(
                      onTap: (){
                        showModalBottomSheet(
                            isScrollControlled: true,
                            useSafeArea: true,
                            backgroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20)),
                            ),
                            context: context,
                            builder: (context){
                              return _bottomModalWidget(itemDetails, index, formatter, store);
                            }
                        ).whenComplete((){
                          setState(() {
                            _amount = 1;
                            _selectedVariant = null;
                          });
                        });
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          NetworkThumb(
                            url: itemDetails[index].banner,
                            height: 16.pH,
                            width: double.infinity,
                          ),
                          const SizedBox(height: 10),
                          // One line only. At two, a single long name made its
                          // tile taller than the one beside it and knocked the
                          // whole grid out of step.
                          Text(
                            itemDetails[index].name ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            style: IAText.subtitle(),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            naira(itemDetails[index].price),
                            style: IAText.label(color: IAColors.darkGrey),
                          ),
                        ],
                      ),
                    );
                  },
                  staggeredTileBuilder: (context) => const StaggeredTile.fit(1)
              ),

              // getCartItems is null until the first fetch lands and again
              // after clearAllDetail, so this cannot be force-unwrapped.
              Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedSlide(
                  offset: _cartHasItems(store) ? Offset.zero : const Offset(0, 1.4),
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  child: AnimatedOpacity(
                    opacity: _cartHasItems(store) ? 1 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: SizedBox(
                      height: 10.pH,
                      width: 100.pW,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: ElevatedButton(
                            onPressed: _cartHasItems(store) ? (){
                              Navigator.push(context, MaterialPageRoute(builder: (context){
                                return Orders(index: 0,);
                              }));
                            } : null,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    _cartItemLabel(store),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: IAText.body(
                                        color: IAColors.white,
                                        weight: FontWeight.w600),
                                  ),
                                ),
                                Text(
                                  naira(store.getCartItems?.data?.grandTotal),
                                  style: IAText.body(
                                      color: IAColors.white,
                                      weight: FontWeight.w700),
                                )
                              ],
                            )
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
          ),
        ),
        );
      }
    );
  }

  /// Case-insensitive, over name and description. The description is
  /// included because that is the field /user/search itself matches products
  /// on, so searching inside a vendor behaves the same way as searching
  /// across all of them.
  List<StoreDetailRecord> _matching(List<StoreDetailRecord> all) {
    final String q = widget.query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all
        .where((item) =>
            (item.name ?? '').toLowerCase().contains(q) ||
            (item.description ?? '').toLowerCase().contains(q))
        .toList();
  }

  Future<void> _refresh() async {
    final store = Provider.of<StoreProvider>(context, listen: false);
    await Future.wait([
      store.fetchStoreDetail(widget.storeId!, widget.category ?? ''),
      store.fetchAllCartItems(),
    ]);
  }

  bool _cartHasItems(StoreProvider store) =>
      store.getCartItems?.data?.carts?.isNotEmpty ?? false;

  String _cartItemLabel(StoreProvider store) {
    final count = store.getCartItems?.data?.itemCount ?? 0;
    return 'Proceed to order $count ${count == 1 ? 'item' : 'items'}';
  }

  /// A bordered square, matching the Figma. The old version latched orange on
  /// whichever of the two you last pressed and stayed that way.
  Widget _level(IconData icon, GestureTapCallback? callBack) {
    final enabled = callBack != null;
    return Pressable(
      onTap: callBack,
      scale: 0.9,
      child: Container(
        height: 34,
        width: 34,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: IAColors.lightGrey),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? IAColors.dialogDark : IAColors.lightGrey,
        ),
      ),
    );
  }

  /// Full-width and left-aligned. The fixed 80% width meant long names broke
  /// out of the sheet rather than wrapping inside it.
  Widget bottomNavDescriptions(String name, TextStyle style) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: SizedBox(
        width: double.infinity,
        child: Text(name, style: style),
      ),
    );
  }

  Widget _bottomModalWidget(List<StoreDetailRecord> itemDetails, int index, NumberFormat formatter, StoreProvider store){
    return StatefulBuilder(
        builder: (context, setState) {
          num unitPrice = itemDetails[index].price;
          num totalPriceRaw = unitPrice * _amount;
          String totalPrice = naira(totalPriceRaw);
          final variants = itemDetails[index].variants ?? [];
          bool hasVariants = variants.isNotEmpty;
          Map<String, List<Variants>> grouped = {};
          for (var v in variants) {
            grouped.putIfAbsent(v.type!, () => []);
            grouped[v.type]!.add(v);
          }
          num effectiveUnitPrice = _selectedVariant?.price ?? unitPrice;
          num variantPriceRaw = effectiveUnitPrice * _amount;
          String variantPrice = naira(variantPriceRaw);

          // 110.pH is 759 logical pixels, taller than the viewport on a
          // smaller phone, so the sheet's own contents used to overflow.
          final maxSheet = MediaQuery.of(context).size.height * 0.88;
          return SizedBox(
                  height: (hasVariants ? 110.pH : 80.pH)
                      .clamp(0.0, maxSheet)
                      .toDouble(),
                  child: Column(
                    children: [
                      // -------------------------------
                      //    SCROLLABLE CONTENT
                      // -------------------------------
                      Expanded(
                        child: NestedScrollView(
                          headerSliverBuilder: (context, innerBoxIsScrolled) {
                            return [
                              SliverToBoxAdapter(
                                child: Column(
                                  children: [
                                    NetworkThumb(
                                      url: itemDetails[index].banner,
                                      width: double.infinity,
                                      height: 33.pH,
                                      radius: const BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ];
                          },
                          body: SingleChildScrollView(
                            child: Column(
                              children: [
                                const SizedBox(height: 18),
                                bottomNavDescriptions(
                                    itemDetails[index].name ?? '',
                                    IAText.display()),
                                const SizedBox(height: 8),
                                bottomNavDescriptions(
                                    itemDetails[index].description ?? '',
                                    IAText.body(color: IAColors.darkGrey)),
                                const SizedBox(height: 14),
                                bottomNavDescriptions(
                                  hasVariants ? 'From $variantPrice' : totalPrice,
                                  IAText.title(),
                                ),
                                const SizedBox(height: 6),
                                if (hasVariants)
                                  for (String type in grouped.keys) ...[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
                                      child: Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(7)
                                        ),
                                        child: Row(
                                          //crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Flexible(
                                              child: Text(type,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: IAText.subtitle()),
                                            ),
                                            const SizedBox(width: 6),
                                            Text("(Select 1)",
                                                style: IAText.micro())
                                          ],
                                        ),
                                      ),
                                    ),

                                    for (var v in grouped[type]!)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 10),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            /// LEFT SIDE (Size + Price)
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  v.size ?? '',
                                                  style: IAText.subtitle(
                                                    color: (_selectedVariant != null && _selectedVariant!.id != v.id)
                                                        ? IAColors.grey
                                                        : IAColors.black,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  naira(v.price),
                                                  style: IAText.caption(
                                                    color: (_selectedVariant != null && _selectedVariant!.id != v.id)
                                                        ? IAColors.grey
                                                        : IAColors.darkGrey,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            /// RIGHT SIDE (ADD / REMOVE Icon)
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  if (_selectedVariant?.id == v.id) {
                                                    _selectedVariant = null; // deselect
                                                  } else {
                                                    _selectedVariant = v; // select
                                                  }
                                                });
                                              },
                                              child: CircleAvatar(
                                                radius: 15,
                                                backgroundColor: Colors.grey.shade200,
                                                child: Icon(
                                                  (_selectedVariant?.id == v.id)
                                                      ? Icons.remove
                                                      : Icons.add,
                                                  color: Colors.black,
                                                  size: 20,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),

                                  ],

                                SizedBox(height: 20), // spacing above bottom section
                              ],
                            ),
                          ),
                        ),
                      ),

                      // -------------------------------
                      //        FIXED BOTTOM BAR
                      // -------------------------------
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          // boxShadow: [
                          //   BoxShadow(
                          //     color: Colors.black12,
                          //     blurRadius: 6,
                          //     offset: Offset(0, -2),
                          //   )
                          // ],
                        ),
                        // The Figma puts the stepper beside the button, not
                        // stacked above it.
                        child: SafeArea(
                          top: false,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _level(
                                      Icons.remove,
                                      _amount > 1
                                          ? () => setState(() => _amount--)
                                          : null,
                                    ),
                                    SizedBox(
                                      width: 40,
                                      child: AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 160),
                                        transitionBuilder: (child, animation) =>
                                            FadeTransition(
                                          opacity: animation,
                                          child: ScaleTransition(
                                              scale: animation, child: child),
                                        ),
                                        child: Text(
                                          _amount.toString(),
                                          key: ValueKey<int>(_amount),
                                          textAlign: TextAlign.center,
                                          style: IAText.subtitle(),
                                        ),
                                      ),
                                    ),
                                    _level(
                                      Icons.add,
                                      () => setState(() => _amount++),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: () async{
                                     if(hasVariants){
                                       EasyLoading.show();
                                       if(_selectedVariant != null){
                                         await store.addToCart(itemDetails[index].id!,_selectedVariant!.id!, _amount, context);
                                         await store.fetchAllCartItems();
                                         Navigator.pop(context);
                                         EasyLoading.dismiss();
                                       }else{
                                         EasyLoading.dismiss();
                                         UiUtils.showSnackBarFromTop(context, 'Please select a variant');
                                       }
                                     }else{
                                       EasyLoading.show();
                                       await store.addToCart(itemDetails[index].id!,null, _amount, context);
                                       await store.fetchAllCartItems();
                                       Navigator.pop(context);
                                       EasyLoading.dismiss();
                                     }
                                    },
                                    child: Text(
                                      'Add $_amount for ${hasVariants ? variantPrice : totalPrice}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: IAText.body(
                                          color: IAColors.white,
                                          weight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
        }
    );
  }

}
