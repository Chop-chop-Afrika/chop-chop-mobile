import 'package:chop_chop_africa/Pages/home%20page/home%20direct/vendor_detail.dart';
import 'package:chop_chop_africa/backend/address_provider.dart';
import 'package:chop_chop_africa/backend/store_provider.dart';
import 'package:chop_chop_africa/utility/sizes.dart';
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
        if (store.allStoresList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text('Vendors',
              style: TextStyle(
                  fontSize: 16
              ),
            ),
            leading: UiUtils.backButton(context),
            actions: [
              IconButton(
                  onPressed: (){},
                  icon: SvgPicture.asset('assets/svg/search-normal.svg'),
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
          body: Padding(
            padding:  EdgeInsets.symmetric(horizontal: 20.0),
            child: ListView.builder(
                controller: _scrollController,
              itemCount:store.allStoresList.length +
                  (store.isLoadingMoreStores ? 1 : 0),
                itemBuilder: (context,index){
                  // LOADING MORE indicator at bottom
                  if (index == store.allStoresList.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final item = store.allStoresList[index];
                return Column(
                  children: [
                    GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context){
                          return VendorDetail(
                            storeId: item.id!,
                            storeName: item.name!,
                            deliveryTime: item.deliveryTime!,
                            businessTime: '${item.openTime} - ${item.closeTime}',);
                        }));

                      },
                      child: Container(
                        height: 25.pH,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                              image: NetworkImage(item.logo!),
                            fit: BoxFit.cover
                          )
                        ),
                      ),
                    ),
                    1.gap,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(

                          width: 80.pW,
                          child: Text(item.name!,
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset('assets/svg/bicycle 1.svg'),
                            0.5.gap,
                            Text(item.deliveryTime!,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w300
                            ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.star_border,color: Color(0xffF7B100), size: 6.5.pW,),
                            0.8.gap,
                            Text(item.status.toString(),
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w300
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    3.gap,
                  ],
                );
                }
            ),
          ),
        );
      }
    );
  }

}
