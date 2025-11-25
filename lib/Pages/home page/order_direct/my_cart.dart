import 'package:chop_chop_africa/Pages/home%20page/order_direct/cart_details.dart';
import 'package:chop_chop_africa/backend/store_provider.dart';
import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:chop_chop_africa/utility/uiutils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';


class MyCart extends StatefulWidget {
  const MyCart({super.key});

  @override
  State<MyCart> createState() => _MyCartState();
}

class _MyCartState extends State<MyCart> {
  final formatter = NumberFormat("#,##0.00", "en_US");
  String cutUnwantedPart(String name) {
    if (name.length > 16) {
      return name.trim().replaceRange(16, null, '...');
    }
    return name;
  }
  String placeHolderLogo = 'https://freesvg.org/img/chef-restaurant-logo-publicdomainvectors.png';
  @override
  Widget build(BuildContext context) {
    return Consumer<StoreProvider>(
      builder: (context,store,child) {
        var cartStores = store.getCartItems?.data?.carts;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: cartStores != null? ListView.builder(
            itemCount: cartStores.length,
              itemBuilder: (context, index){
              return GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context){
                    return CartDetails(orderId: cartStores[index].orderId!,);
                  }));
                },
                child: ListTile(
                  leading: Container(
                    height: 15.pW,
                    width: 15.pW,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      image: DecorationImage(image: NetworkImage(cartStores[index].store?.logo??placeHolderLogo),
                      fit: BoxFit.cover
                      )
                    ),
                  ),
                  title: UiUtils.subTitles(cutUnwantedPart(cartStores[index].store?.name??''), 14),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset('assets/svg/bicycle 1.svg'),
                          1.gap,
                          Text(cartStores[index].store?.deliveryTime??'',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                          )
                        ],
                      ),
                      Text('${cartStores[index].items?.length} items',
                      style: TextStyle(
                      fontSize: 13,
                  ),
                      )
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('\$${formatter.format(cartStores[index].subtotal)}',
                      style: TextStyle(
                        fontSize: 15
                      ),
                      ),
                    ],
                  ),
                ),
              );
              }
          ):Center(
            child: Text('No Items',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 23
            ),
            ),
          ),
        );
      }
    );
  }
}
