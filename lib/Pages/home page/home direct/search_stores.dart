import 'package:chop_chop_africa/Pages/home%20page/home%20direct/vendor_detail.dart';
import 'package:chop_chop_africa/backend/store_provider.dart';
import 'package:chop_chop_africa/utility/iacolors.dart';
import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';


class SearchStores extends StatefulWidget {

  const SearchStores({super.key,});

  @override
  State<SearchStores> createState() => _SearchStoresState();
}

class _SearchStoresState extends State<SearchStores> {
  @override
  Widget build(BuildContext context) {
    return Consumer<StoreProvider>(
        builder: (context,search,child) {
          if (search.loadingSearch && search.searchStores.isEmpty) {
            // Searching: say so rather than leaving the prompt up as though
            // nothing had been typed.
            return const Center(child: CircularProgressIndicator());
          }
          if (search.searchStores.isEmpty) {
            return Center(
              child: Text(
                'Search For Stores',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            );
          }
          return Padding(
              padding:  EdgeInsets.symmetric(horizontal: 20.0,vertical: 15),
              child: ListView.builder(
                  itemCount:search.searchStores.length,
                  itemBuilder: (context,index){

                    final item = search.searchStores[index];
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
            );

        }
    );
  }

}
