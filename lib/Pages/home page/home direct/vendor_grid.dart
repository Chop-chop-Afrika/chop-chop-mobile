import 'package:chop_chop_africa/Pages/home%20page/order_direct/orders.dart';
import 'package:chop_chop_africa/backend/store_provider.dart';
import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:chop_chop_africa/utility/uiutils.dart';
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
  const VendorGrid({super.key, this.category, this.storeId,});

  @override
  State<VendorGrid> createState() => _VendorGridState();
}

class _VendorGridState extends State<VendorGrid> {
  String placeHolderLogo = 'https://freesvg.org/img/chef-restaurant-logo-publicdomainvectors.png';
  int _amount = 1;
  int _selected = 0;
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
  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat("#,##0.00", "en_US");
    return Consumer<StoreProvider>(
      builder: (context,store,child) {
        final itemDetails = store.getStoreDetailList;

        if (itemDetails.isEmpty) {
          return Center(child: Text("No items"));
        }
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0,horizontal: 20),
          child: Stack(
            children: [
              StaggeredGridView.countBuilder(
                  controller: _scrollController,
                  itemCount:itemDetails.length +
                      (store.isLoadingMoreStoreDetail ? 1 : 0),
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
                    return GestureDetector(
                      onTap: (){
                        showModalBottomSheet(
                            isScrollControlled: true,
                            backgroundColor: Colors.white,

                            context: context,
                            builder: (context){
                              return _bottomModalWidget(itemDetails, index, formatter, store);
                            }
                        ).whenComplete((){
                          setState(() {
                            _amount = 1;
                            _selected = 0;
                            _selectedVariant = null;
                          });
                        });
                      },
                      child: Column(
                        children: [
                          Container(
                            height: 16.pH,
                            width: 50.pW,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                    image: NetworkImage(itemDetails[index].banner??placeHolderLogo),
                                    fit: BoxFit.cover
                                )
                            ),
                          ),
                          1.gap,
                          UiUtils.subTitles(itemDetails[index].name??'', 15),
                          UiUtils.subTitles('\$${itemDetails[index].price}', 13),
                        ],
                      ),
                    );
                  },
                  staggeredTileBuilder: (context) => const StaggeredTile.fit(1)
              ),

              store.getCartItems!.data!.carts!.isNotEmpty?
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: 10.pH,
                  width: 100.pW,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: ElevatedButton(
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context){
                            return Orders(index: 0,);
                          }));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Proceed to order ${store.getCartItems?.data?.itemCount ?? 0} item'),
                            Text('\$${formatter.format(store.getCartItems?.data?.grandTotal)}')
                          ],
                        )
                    ),
                  ),
                ),
              ):Container()
            ],
          ),
        );
      }
    );
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

  Widget _bottomModalWidget(List<StoreDetailRecord> itemDetails, int index, NumberFormat formatter, StoreProvider store){
    return StatefulBuilder(
        builder: (context, setState) {
          num unitPrice = itemDetails[index].price;
          num totalPriceRaw = unitPrice * _amount;
          String totalPrice = formatter.format(totalPriceRaw);
          final variants = itemDetails[index].variants ?? [];
          bool hasVariants = variants.isNotEmpty;
          Map<String, List<Variants>> grouped = {};
          for (var v in variants) {
            grouped.putIfAbsent(v.type!, () => []);
            grouped[v.type]!.add(v);
          }
          num effectiveUnitPrice = _selectedVariant?.price ?? unitPrice;
          num variantPriceRaw = effectiveUnitPrice * _amount;
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
                                  hasVariants ? "\$$variantPrice" : "\$$totalPrice",
                                  20,
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
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                )),
                                            SizedBox(width: 6),
                                            Text("(Select 1)",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 11,
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
                                  'Add $_amount for \$${hasVariants ? variantPrice : totalPrice}',
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
