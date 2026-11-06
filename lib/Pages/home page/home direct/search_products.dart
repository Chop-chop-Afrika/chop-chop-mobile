import 'package:chop_chop_africa/Pages/home%20page/home%20direct/vendor_detail.dart';
import 'package:chop_chop_africa/backend/store_provider.dart';
import 'package:chop_chop_africa/custom%20widgets/pressable.dart';
import 'package:chop_chop_africa/utility/money.dart';
import 'package:chop_chop_africa/utility/typography.dart';
import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:chop_chop_africa/utility/uiutils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';
import 'package:intl/intl.dart';
import '../../../backend/models/search_product_model.dart';
import '../../../utility/iacolors.dart';

/// The products half of a search result, rendered inline.
///
/// This used to be a whole screen of its own behind a "Products" tab.
/// Stores and products are searched together now, so [SearchPage] owns the
/// scrolling, the loading and empty states and the cart bar, and this lays
/// out the tiles it is given.
class SearchProducts extends StatefulWidget {
  final List<SearchProductData> items;

  const SearchProducts({super.key, required this.items});

  @override
  State<SearchProducts> createState() => _SearchProductsState();
}

class _SearchProductsState extends State<SearchProducts> {
  String placeHolderLogo = 'https://freesvg.org/img/chef-restaurant-logo-publicdomainvectors.png';
  int _amount = 1;
  int _selected = 0;
  Variants? _selectedVariant;

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<StoreProvider>(context, listen: false);
    final itemDetails = widget.items;
    final formatter = NumberFormat("#,##0.00", "en_US");
    return StaggeredGridView.countBuilder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: itemDetails.length,
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 12,
        itemBuilder: (context, index) {
          final item = itemDetails[index];
          return Pressable(
            onTap: () {
              showModalBottomSheet(
                  isScrollControlled: true,
                  backgroundColor: Colors.white,
                  context: context,
                  builder: (context) {
                    return _bottomModalWidget(itemDetails, index, formatter, store);
                  }).whenComplete(() {
                setState(() {
                  _amount = 1;
                  _selected = 0;
                  _selectedVariant = null;
                });
              });
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Was a raw NetworkImage falling back to a stock chef logo
                // from freesvg.org, with no handling for a failed load.
                NetworkThumb(
                  url: item.banner,
                  height: 16.pH,
                  width: double.infinity,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // One line only, so a long name cannot make its
                          // tile taller than the one beside it.
                          Text(
                            item.name ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            style: IAText.subtitle(),
                          ),
                          const SizedBox(height: 4),
                          // Was '₦${item.price}', so five-figure prices came
                          // out as 12550 with no separator.
                          Text(naira(item.price),
                              style: IAText.label(color: IAColors.darkGrey)),
                        ],
                      ),
                    ),
                    if (item.stores?.id != null)
                      IconButton(
                          tooltip: 'Open ${item.stores?.name ?? 'store'}',
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return VendorDetail(
                                storeId: item.stores!.id!,
                                storeName: item.stores!.name ?? '',
                                deliveryTime: item.stores!.deliveryTime ?? '',
                                businessTime:
                                    '${item.stores!.openTime} - ${item.stores!.closeTime}',
                              );
                            }));
                          },
                          icon: SvgPicture.asset('assets/svg/Home 1.svg',
                              height: 21))
                  ],
                )
              ],
            ),
          );
        },
        staggeredTileBuilder: (context) => const StaggeredTile.fit(1));
  }

  Widget _level(IconData icon, GestureTapCallback callBack, {required bool isSelected}) {
    return GestureDetector(
      onTap: callBack,
      child: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected ? IAColors.primary : Colors.transparent, // highlight
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: IAColors.lightGrey,
          ),
        ),
        child: Icon(icon,size: 30,color: isSelected?IAColors.white:IAColors.dialogDark,),
      ),
    );
  }

  Widget bottomNavDescriptions(String name, double? fontSize, FontWeight? fontWeight){
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SizedBox(
            width: 80.pW,
            child: Text(name,
              style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: fontWeight
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _bottomModalWidget(List<SearchProductData> itemDetails, int index, NumberFormat formatter, StoreProvider store){
    return StatefulBuilder(
        builder: (context, setState) {
          num? unitPrice = itemDetails[index].price!;
          num? totalPriceRaw = unitPrice * _amount;
          String totalPrice = formatter.format(totalPriceRaw);
          final variants = itemDetails[index].variants ?? [];
          bool hasVariants = variants.isNotEmpty;
          Map<String, List<Variants>> grouped = {};
          for (var v in variants) {
            grouped.putIfAbsent(v.type!, () => []);
            grouped[v.type]!.add(v);
          }
          num? effectiveUnitPrice = _selectedVariant?.price ?? unitPrice;
          num? variantPriceRaw = effectiveUnitPrice * _amount;
          String variantPrice = formatter.format(variantPriceRaw);

          return SizedBox(
            height:hasVariants?110.pH:80.pH,
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
                              Container(
                                width: double.infinity,
                                height: 33.pH,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                        itemDetails[index].banner ?? placeHolderLogo
                                    ),
                                    fit: BoxFit.cover,
                                  ),
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
                          1.gap,
                          bottomNavDescriptions(
                              itemDetails[index].name!,
                              21,
                              FontWeight.w800),
                          bottomNavDescriptions(
                              itemDetails[index].description!,
                              14,
                              FontWeight.w400),
                          2.gap,
                          bottomNavDescriptions(
                            hasVariants ? "₦$variantPrice" : "₦$totalPrice",
                            24,
                            FontWeight.w800,
                          ),
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
                                      Text(type,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          )),
                                      SizedBox(width: 6),
                                      Text("(Select 1)",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 13,
                                          ))
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
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: (_selectedVariant != null && _selectedVariant!.id != v.id)
                                                  ? Colors.grey // grey out
                                                  : Colors.black,
                                            ),
                                          ),
                                          SizedBox(height: 6),
                                          Text(
                                            "₦${formatter.format(v.price)}",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: (_selectedVariant != null && _selectedVariant!.id != v.id)
                                                  ? Colors.grey // grey out
                                                  : Colors.grey.shade700,
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
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _level(
                            Icons.remove,
                                () {
                              setState(() {
                                if (_amount > 1) {
                                  _amount--;
                                  _selected = 1;
                                }
                              });
                            },
                            isSelected: _selected == 1,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text(
                              _amount.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          _level(
                            Icons.add,
                                () {
                              setState(() {
                                _amount++;
                                _selected = 2;
                              });
                            },
                            isSelected: _selected == 2,
                          ),
                        ],
                      ),
                      3.gap,
                      SizedBox(
                        height: 6.5.pH,
                        width: 100.pW,
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
                              await store.addToCart(itemDetails[index].id!,null, _amount, context);
                              await store.fetchAllCartItems();
                              Navigator.pop(context);
                              EasyLoading.dismiss();
                            }
                          },
                          child: Text(
                            'Add $_amount for ₦${hasVariants ? variantPrice : totalPrice}',
                          ),
                        ),
                      ),
                      4.gap,
                    ],
                  ),
                ),
              ],
            ),
          );
        }
    );
  }

}
