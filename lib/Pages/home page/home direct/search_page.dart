import 'dart:async';

import 'package:chop_chop_africa/Pages/home%20page/home%20direct/search_products.dart';
import 'package:chop_chop_africa/Pages/home%20page/home%20direct/search_stores.dart';
import 'package:chop_chop_africa/backend/store_provider.dart';
import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../utility/iacolors.dart';

class SearchPage extends StatefulWidget {

  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _type = 'stores';
  final TextEditingController _searchController = TextEditingController();

  /// onChanged fires on every keystroke, which sent one request per letter.
  /// Besides the wasted calls, the responses could arrive out of order and
  /// leave results that did not match what was typed.
  Timer? _debounce;
  static const Duration _debounceDelay = Duration(milliseconds: 350);

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged(StoreProvider search, String value) {
    _debounce?.cancel();
    // Clearing the field should empty the list straight away rather than
    // after the debounce.
    if (value.trim().isEmpty) {
      search.clearSearchResults();
      return;
    }
    _debounce = Timer(_debounceDelay, () {
      search.searchProductsAndStores(_type, value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final search = Provider.of<StoreProvider>(context,listen:false);
    final theme = Theme.of(context);
    return DefaultTabController(
      //initialIndex: widget.index,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Padding(
            padding:  EdgeInsets.only(top: 4.pH),
            child: TextFormField(
              controller: _searchController,
              validator: (v){
                if(v!.isEmpty){
                  return 'Field Must Not be empty';
                }
                return null;
              },
              onChanged: (v) => _onQueryChanged(search, v),
              style: theme.textTheme.bodySmall,
              decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SvgPicture.asset('assets/svg/search-normal.svg',),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  contentPadding: EdgeInsets.only(top: 3,left: 10),
                  errorStyle: TextStyle(
                      fontSize: 14
                  ),
                  hintText: 'Search',
                  hintStyle: TextStyle(
                      height: 2,
                      fontSize: 14,
                      fontWeight: FontWeight.w800
                  ),
                  helperText: ''
              ),
            ),
          ),
          automaticallyImplyLeading: false,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(7.pH),
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
                  onTap: (index) {
                    setState(() {
                      _type = index == 0 ? 'stores' : 'products';
                      _searchController.clear();
                      _debounce?.cancel();
                      // Switching tab resets the field, so clear both result
                      // lists instead of searching for an empty string.
                      search.clearSearchResults();
                    });
                  },
                  tabs: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('Stores',
                        style: TextStyle(
                            fontSize: 15
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('Products',
                        style: TextStyle(
                            fontSize: 15
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
                SearchStores(),
                SearchProducts(),
              ]
          ),
        ),
      ),
    );
  }
}