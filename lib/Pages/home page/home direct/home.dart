import 'package:carousel_slider/carousel_slider.dart';
import 'package:chop_chop_africa/Pages/home%20page/home%20direct/easy_package_delivery.dart';
import 'package:chop_chop_africa/Pages/home%20page/home%20direct/vendors.dart';
import 'package:chop_chop_africa/backend/address_provider.dart';
import 'package:chop_chop_africa/backend/profile_provider.dart';
import 'package:chop_chop_africa/utility/iacolors.dart';
import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:chop_chop_africa/utility/uiutils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../Delivery/select_delivery_address.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _activeIndex = 0;
List<String> _carouselImages = [
  'https://images.unsplash.com/photo-1682778418768-16081e4470a1?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8cmVzdGF1cmFudCUyMGJhY2tncm91bmR8ZW58MHx8MHx8fDA%3D&fm=jpg&q=60&w=3000',
'https://images.pexels.com/photos/262978/pexels-photo-262978.jpeg?cs=srgb&dl=pexels-pixabay-262978.jpg&fm=jpg'
];
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = Provider.of<ProfileProvider>(context,listen: false);
    final profileInfo = profile.getAllProfileInfo;
    String cutUnwantedPart(String name) {
      if (name.length > 25) {
        return name.trim().replaceRange(25, null, '...');
      }
      return name;
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Text('Hello ${profileInfo?.data?.firstName} 👋',
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 14
          ),
        ),
        actions: [
          Consumer<AddressProvider>(
            builder: (context,address,child) {
              final addressList = address.addressList;
              final defaultAddress = addressList.firstWhere(
                    (item) => item.defaut == true,
                orElse: () => addressList.first,
              );
              return Text( addressList.isEmpty?
                  'Loading...':
                cutUnwantedPart(defaultAddress.address??''),
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 14
                ),
              );
            }
          ),
          TextButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context){
                  return AddressSearchBar(type: 'update',);
                }));
              },
              child: Text('Change',
              style: TextStyle(
                fontWeight: FontWeight.w300,
                decoration: TextDecoration.underline,
                  decorationColor: IAColors.primary,
                color: IAColors.primary
              ),
              )
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height:11.pH,
                child: TextFormField(
                  validator: (v){
                    if(v!.isEmpty){
                      return 'Field Must Not be empty';
                    }
                    return null;
                  },
                  onChanged: (v){
                  },
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

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _topContainers('hugeicons_discount-tag-02.png', Color(0xffFDF2DF), 'Supermarket'),
                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context){
                        return Vendors();
                      }));
                    },
                      child: _topContainers('Quick Options.png', Color(0xffFFE3D9), 'Vendors')
                  ),
                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context){
                        return EasyPackageDelivery();
                      }));
                    },
                      child: _topContainers('Quick Options (2).png', Color(0xffE9FFF5), 'Send Packages'))
                ],
              ),
              2.gap,
              UiUtils.subTitles('Top Vendors', 17),
              0.5.gap,
              _horizontalListView('assets/images/image 4.png', 'WYPL'),
          CarouselSlider.builder(
            options: CarouselOptions(
                viewportFraction: 1,
                aspectRatio: 16/9,
                height: 20.pH,
                autoPlay: true,
                initialPage: 0,
                enableInfiniteScroll: false,
                enlargeCenterPage: false,
                onPageChanged: (index, reason){
                  setState(() {
                    _activeIndex = index;
                  });
                }
            ),
            itemCount: _carouselImages.length,
            itemBuilder: (BuildContext context, int index, int realIndex) {
              return Padding(
                padding: const EdgeInsets.only(top: 8.0,right: 8.0,bottom: 8.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                        image: NetworkImage(_carouselImages[index],),
                      fit: BoxFit.cover
                    )
                  ),
                ),
              );
            },
          ), 
              1.gap,
              buildIndicator(),
             2.gap,
              UiUtils.subTitles('Top Stores', 17),
              0.5.gap,
              _horizontalListView('assets/images/image 4.png', 'WYPL'),
              2.gap,
              UiUtils.subTitles('Recommended', 17),
              1.gap,
              SizedBox(
                height: 25.pH,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _carouselImages.length,
                    itemBuilder: (context, index){
                    return Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: Container(
                        width: 40.pW,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                                image: NetworkImage(_carouselImages[index],),
                                fit: BoxFit.cover
                            )
                        ),
                      ),
                    );
                    }
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  Widget buildIndicator(){
    return AnimatedSmoothIndicator(
      activeIndex: _activeIndex,
      count: _carouselImages.length,
      effect:  WormEffect(
          dotHeight: 9,
          dotWidth: 9,
          activeDotColor: IAColors.primary,
          dotColor: IAColors.primary.withOpacity(0.2)
      ),
    );
  }

  Widget _topContainers(String image, Color color, String title){
    return Container(
      height: 25.5.pW,
      width: 28.5.pW,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12)
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/$image',height: 13.pW,),
            0.5.gap,
            Text(title,
            style: TextStyle(
              fontSize: 12
            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _horizontalListView(String image, String text){
    return SizedBox(
      height: 12.pH,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 10,
          itemBuilder: (context, index){
            return Padding(
              padding:  EdgeInsets.only(right: 7.pW),
              child: Column(
                children: [
                  Image.asset(image,height: 6.pH,),
                  1.gap,
                  Text(text,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13
                    ),
                  )
                ],
              ),
            );
          }
      ),
    );
  }

}