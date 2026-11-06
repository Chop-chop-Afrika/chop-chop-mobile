import 'dart:async';

import 'package:chop_chop_africa/Pages/home%20page/home%20direct/search_products.dart';
import 'package:chop_chop_africa/Pages/home%20page/home%20direct/search_stores.dart';
import 'package:chop_chop_africa/Pages/home%20page/order_direct/orders.dart';
import 'package:chop_chop_africa/backend/store_provider.dart';
import 'package:chop_chop_africa/custom%20widgets/async_content.dart';
import 'package:chop_chop_africa/utility/money.dart';
import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:chop_chop_africa/utility/typography.dart';
import 'package:chop_chop_africa/utility/uiutils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../utility/iacolors.dart';

/// One field for the whole catalogue.
///
/// This screen used to make you pick a tab first — Stores or Products — and
/// searched only the one you were on. /user/search does insist on a `type`,
/// but that is a limit on one request, not on the screen: [searchEverything]
/// asks it for both at once and the two answers are laid out here under
/// their own headings, so whichever kind of thing you were looking for is
/// simply there.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  /// onChanged fires on every keystroke, which sent one request per letter.
  /// Besides the wasted calls, the responses could arrive out of order and
  /// leave results that did not match what was typed.
  Timer? _debounce;
  static const Duration _debounceDelay = Duration(milliseconds: 350);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      Provider.of<StoreProvider>(context, listen: false)
          .loadMoreSearchResults();
    }
  }

  void _onQueryChanged(StoreProvider search, String value) {
    // The clear button and the empty state both read the field, and nothing
    // else rebuilds until the debounced request comes back - without this
    // they lag a third of a second behind what has been typed.
    setState(() {});
    _debounce?.cancel();
    // Clearing the field should empty the list straight away rather than
    // after the debounce.
    if (value.trim().isEmpty) {
      search.clearSearchResults();
      return;
    }
    _debounce = Timer(_debounceDelay, () => search.searchEverything(value));
  }

  Widget _sectionHeading(String text, int count) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Row(
        children: [
          Text(text, style: IAText.title()),
          const SizedBox(width: 8),
          Text('$count', style: IAText.caption(color: IAColors.grey)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StoreProvider>(
      builder: (context, search, child) {
        final bool typing = _searchController.text.trim().isNotEmpty;
        final stores = search.searchStores;
        final products = search.searchProducts;

        return Scaffold(
          appBar: AppBar(
            // There was no way off this screen: automaticallyImplyLeading
            // was false and nothing was given in its place.
            leading: UiUtils.backButton(context),
            titleSpacing: 0,
            // The field is 46 high and the default toolbar is 56, so with
            // any padding at all it was being clipped top and bottom.
            toolbarHeight: 68,
            title: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: SizedBox(
                height: 46,
                child: TextFormField(
                  controller: _searchController,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  onChanged: (v) => _onQueryChanged(search, v),
                  style: IAText.body(),
                  decoration: InputDecoration(
                    // Without constraints the prefix stretched the svg to
                    // the icon theme's size and squashed the hint beside it.
                    prefixIconConstraints:
                        const BoxConstraints(minWidth: 42, minHeight: 20),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 14, right: 8),
                      child: SvgPicture.asset('assets/svg/search-normal.svg',
                          height: 18, width: 18),
                    ),
                    suffixIcon: typing
                        ? IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: Icon(Icons.close,
                                size: 18, color: IAColors.darkGrey),
                            onPressed: () {
                              _searchController.clear();
                              _debounce?.cancel();
                              search.clearSearchResults();
                              setState(() {});
                            },
                          )
                        : null,
                    suffixIconConstraints:
                        const BoxConstraints(minWidth: 40, minHeight: 20),
                    filled: true,
                    fillColor: IAColors.fieldFill,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 13),
                    hintText: 'Search food, vendors and items',
                    hintStyle: IAText.body(color: IAColors.grey),
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(7),
              child: Divider(color: IAColors.veryLightGrey),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: AsyncContent(
              loading: search.loadingSearch && search.searchFoundNothing,
              isEmpty: search.searchFoundNothing,
              emptyTitle: typing
                  ? 'Nothing found for "${_searchController.text.trim()}"'
                  : 'What are you looking for?',
              emptyMessage: typing
                  ? 'Try a different word.'
                  : 'Vendors and their menus, searched together.',
              emptyIcon: typing ? Icons.search_off : Icons.search,
              // Nothing else is on this screen, so centred left the message
              // stranded halfway down an empty page.
              emptyAlignment: const Alignment(0, -0.45),
              // The generic list of four identical bars said nothing about
              // what was coming. This is the shape of a result: a vendor
              // card, then a row of items.
              loadingPlaceholder: _resultsSkeleton(),
              builder: (context) => ListView(
                controller: _scrollController,
                children: [
                  // Whichever kinds matched show up; a kind that matched
                  // nothing simply is not here.
                  if (stores.isNotEmpty) ...[
                    _sectionHeading('Vendors', stores.length),
                    SearchStores(items: stores),
                  ],
                  if (products.isNotEmpty) ...[
                    _sectionHeading('Items', products.length),
                    SearchProducts(items: products),
                  ],
                  if (search.isLoadingMoreSearch)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  SizedBox(height: 3.pH),
                ],
              ),
            ),
          ),
          bottomNavigationBar: _cartBar(search),
        );
      },
    );
  }

  Widget _resultsSkeleton() => Shimmer(
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 18),
          children: [
            _bar(80),
            const SizedBox(height: 14),
            SkeletonBox(height: 22.pH, radius: 12),
            const SizedBox(height: 6),
            _bar(180),
            const SizedBox(height: 24),
            _bar(60),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _tileSkeleton()),
                const SizedBox(width: 8),
                Expanded(child: _tileSkeleton()),
              ],
            ),
          ],
        ),
      );

  /// A ListView stretches its children to full width, so a bar has to be
  /// aligned inside that width rather than just given one.
  Widget _bar(double width) => Align(
        alignment: Alignment.centerLeft,
        child: SkeletonBox(height: 14, width: width, radius: 4),
      );

  Widget _tileSkeleton() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(height: 16.pH, radius: 8),
          const SizedBox(height: 4),
          const SkeletonBox(height: 12, width: 110, radius: 4),
          const SizedBox(height: 2),
          const SkeletonBox(height: 12, width: 60, radius: 4),
        ],
      );

  /// Only when there is actually something in the cart. The old condition
  /// was `carts?.isNotEmpty != null`, which is true of any cart that has
  /// been loaded at all, empty ones included.
  Widget? _cartBar(StoreProvider store) {
    final carts = store.getCartItems?.data?.carts ?? [];
    if (carts.isEmpty) return null;
    final count = store.getCartItems?.data?.itemCount ?? 0;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const Orders(index: 0);
              }));
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Proceed to order $count ${count == 1 ? 'item' : 'items'}',
                    style: IAText.body(
                        color: IAColors.white, weight: FontWeight.w600)),
                Text(naira(store.getCartItems?.data?.grandTotal),
                    style: IAText.body(
                        color: IAColors.white, weight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
