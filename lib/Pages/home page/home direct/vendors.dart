import 'package:chop_chop_africa/Pages/home%20page/home%20direct/vendor_detail.dart';
import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../utility/iacolors.dart';
import '../../../utility/uiutils.dart';

class Vendors extends StatefulWidget {
  const Vendors({super.key});

  @override
  State<Vendors> createState() => _VendorsState();
}

class _VendorsState extends State<Vendors> {
  List<String> _carouselImages = [
    'https://images.unsplash.com/photo-1682778418768-16081e4470a1?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8cmVzdGF1cmFudCUyMGJhY2tncm91bmR8ZW58MHx8MHx8fDA%3D&fm=jpg&q=60&w=3000',
    'https://images.pexels.com/photos/262978/pexels-photo-262978.jpeg?cs=srgb&dl=pexels-pixabay-262978.jpg&fm=jpg'
  ];
  @override
  Widget build(BuildContext context) {
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
          itemCount: _carouselImages.length,
            itemBuilder: (context,index){
            return Column(
              children: [
                GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context){
                      return VendorDetail();
                    }));
                  },
                  child: Container(
                    height: 25.pH,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                          image: NetworkImage(_carouselImages[index]),
                        fit: BoxFit.cover
                      )
                    ),
                  ),
                ),
                1.gap,
                UiUtils.subTitles('Chicken Republic', 17),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset('assets/svg/bicycle 1.svg'),
                        0.5.gap,
                        Text('5-10 Mins',
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
                        Text('3.7(20)s',
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

}
