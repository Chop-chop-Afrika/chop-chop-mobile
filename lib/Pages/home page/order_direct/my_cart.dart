import 'package:chop_chop_africa/Pages/home%20page/order_direct/cart_details.dart';
import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:chop_chop_africa/utility/uiutils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class MyCart extends StatefulWidget {
  const MyCart({super.key});

  @override
  State<MyCart> createState() => _MyCartState();
}

class _MyCartState extends State<MyCart> {
  List<String> _carouselImages = [
    'https://images.unsplash.com/photo-1682778418768-16081e4470a1?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8cmVzdGF1cmFudCUyMGJhY2tncm91bmR8ZW58MHx8MHx8fDA%3D&fm=jpg&q=60&w=3000',
    'https://images.pexels.com/photos/262978/pexels-photo-262978.jpeg?cs=srgb&dl=pexels-pixabay-262978.jpg&fm=jpg'
  ];
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: ListView.builder(
        itemCount: _carouselImages.length,
          itemBuilder: (context, index){
          return GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context){
                return CartDetails();
              }));
            },
            child: ListTile(
              leading: Container(
                height: 15.pW,
                width: 15.pW,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  image: DecorationImage(image: NetworkImage(_carouselImages[index]),
                  fit: BoxFit.cover
                  )
                ),
              ),
              title: UiUtils.subTitles('Chicken Republic', 14),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset('assets/svg/bicycle 1.svg'),
                      1.gap,
                      Text('5-10 Mins',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                      )
                    ],
                  ),
                  Text('4 items',
                  style: TextStyle(
                  fontSize: 13,
              ),
                  )
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('\$20.33',
                  style: TextStyle(
                    fontSize: 15
                  ),
                  ),
                ],
              ),
            ),
          );
          }
      ),
    );
  }
}
