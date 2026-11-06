import 'package:carousel_slider/carousel_slider.dart';
import 'package:chop_chop_africa/Pages/home%20page/home%20direct/easy_package_delivery.dart';
import 'package:chop_chop_africa/Pages/home%20page/home%20direct/search_page.dart';
import 'package:chop_chop_africa/Pages/home%20page/home%20direct/vendor_detail.dart';
import 'package:chop_chop_africa/Pages/home%20page/home%20direct/vendors.dart';
import 'package:chop_chop_africa/backend/address_provider.dart';
import 'package:chop_chop_africa/backend/profile_provider.dart';
import 'package:chop_chop_africa/backend/store_provider.dart';
import 'package:chop_chop_africa/utility/iacolors.dart';
import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:chop_chop_africa/custom%20widgets/async_content.dart';
import 'package:chop_chop_africa/custom%20widgets/pressable.dart';
import 'package:chop_chop_africa/custom%20widgets/refreshable.dart';
import 'package:chop_chop_africa/utility/typography.dart';
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
  String placeHolderLogo = 'https://freesvg.org/img/chef-restaurant-logo-publicdomainvectors.png';

final List<String> _carouselImages = [
  'https://images.unsplash.com/photo-1682778418768-16081e4470a1?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8cmVzdGF1cmFudCUyMGJhY2tncm91bmR8ZW58MHx8MHx8fDA%3D&fm=jpg&q=60&w=3000',
'https://images.pexels.com/photos/262978/pexels-photo-262978.jpeg?cs=srgb&dl=pexels-pixabay-262978.jpg&fm=jpg'
];

@override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileProvider>(context,listen: false);
    final profileInfo = profile.getAllProfileInfo;
    return Consumer<StoreProvider>(
      builder: (context, stores, child) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: false,
            automaticallyImplyLeading: false,
            toolbarHeight: 78,
            titleSpacing: 20,
            // The greeting, the address and Change used to share one row as a
            // title plus two actions, which left them jammed against each
            // other with nowhere for a long address to go.
            title: _greeting(profileInfo?.data?.firstName),
          ),
          body: Refreshable(
            onRefresh: _refresh,
            child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SingleChildScrollView(
              physics: Refreshable.physics,
              child: Column(
                children: [
                  1.gap,
                  TextFormField(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context){
                        return SearchPage();
                      }));
                    },
                    readOnly: true,
                    style: IAText.body(),
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SvgPicture.asset('assets/svg/search-normal.svg'),
                      ),
                      filled: true,
                      fillColor: IAColors.fieldFill,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      hintText: 'Search for food, vendors and items',
                      hintStyle: IAText.body(color: IAColors.grey),
                    ),
                  ),
                  2.gap,

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Pressable(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context){
                            return Vendors(type: "SUPER_MARKET",);
                          }));
                        },
                        child: _topContainers('hugeicons_discount-tag-02.png', Color(0xffFDF2DF), 'Supermarket'),
                      ),
                      Pressable(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context){
                            return Vendors(type: "RESTAURANT",);
                          }));
                        },
                        child: _topContainers('Quick Options.png', Color(0xffFFE3D9), 'Vendors'),
                      ),
                      Pressable(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context){
                            return EasyPackageDelivery();
                          }));
                        },
                        child: _topContainers('Quick Options (2).png', Color(0xffE9FFF5), 'Send Packages'),
                      )
                    ],
                  ),
                  2.gap,
                  _sectionTitle('Top Vendors'),
                  0.5.gap,
                  _horizontalListView(stores.getTopVendors,
                      loading: stores.loadingTopVendors),
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
                itemCount: 3,
                itemBuilder: (BuildContext context, int index, int realIndex) {
                  final vendors = stores.getTopVendors;
                  final imageUrl = (index < vendors.length && vendors[index].logo != null)
                      ? vendors[index].logo!
                      : placeHolderLogo;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0,right: 8.0,bottom: 8.0),
                    child: Pressable(
                      onTap: (){
                        if (index >= vendors.length) return;
                        Navigator.push(context, MaterialPageRoute(builder: (context){
                          return VendorDetail(
                            storeId: vendors[index].id!,
                            storeName: vendors[index].name!,
                            deliveryTime: vendors[index].deliveryTime!,
                            businessTime: '${vendors[index].openTime} - ${vendors[index].closeTime}',);
                        }));
                      },
                      child: NetworkThumb(
                        url: imageUrl,
                        width: double.infinity,
                        radius: BorderRadius.circular(15),
                      ),
                    ),
                  );
                },
              ),
                  1.gap,
                  buildIndicator(),
                 2.gap,
                  _sectionTitle('Top Stores'),
                  0.5.gap,
                  _horizontalListView(stores.getTopStores,
                      loading: stores.loadingTopStores),
                  2.gap,
                  _sectionTitle('Recommended'),
                  1.gap,
                  SizedBox(
                    height: 25.pH,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _carouselImages.length,
                        itemBuilder: (context, index){
                        return Padding(
                          padding: const EdgeInsets.only(right: 15.0),
                          child: NetworkThumb(
                            url: _carouselImages[index],
                            width: 40.pW,
                            radius: BorderRadius.circular(12),
                          ),
                        );
                        }
                    ),
                  )
                ],
              ),
            ),
          ),
          ),
        );
      }
    );
  }

  /// Everything the screen shows, re-fetched. The two store calls need
  /// coordinates, so they are skipped when there is no default address rather
  /// than taking the whole refresh down.
  Future<void> _refresh() async {
    final profile = Provider.of<ProfileProvider>(context, listen: false);
    final address = Provider.of<AddressProvider>(context, listen: false);
    final stores = Provider.of<StoreProvider>(context, listen: false);

    await Future.wait([
      profile.getProfile(),
      address.getAllAddresses(),
    ]);
    if (!mounted) return;

    final here = address.defaultAddress;
    await Future.wait([
      if (here != null)
        stores.fetchTopStores(
            here.latitude.toString(), here.longitude.toString()),
      if (here != null)
        stores.fetchTopVendors('RESTAURANT', here.latitude.toString(),
            here.longitude.toString()),
    ]);
  }
  Widget _sectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: IAText.title()),
    );
  }

  /// Two lines with room to breathe: who you are, then where you are.
  Widget _greeting(String? firstName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Hello ${firstName ?? ''} 👋'.replaceAll('  ', ' '),
          style: IAText.title(),
        ),
        const SizedBox(height: 4),
        Consumer<AddressProvider>(
          builder: (context, address, child) {
            final line = address.defaultAddress?.address;
            return Row(
              children: [
                Icon(Icons.location_on_outlined,
                    size: 15, color: IAColors.darkGrey),
                const SizedBox(width: 3),
                // Expanded plus ellipsis, so the address gives way on a narrow
                // screen instead of being cut at a fixed character count.
                Expanded(
                  child: Text(
                    line ?? 'Setting your address…',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: IAText.caption(),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return AddressSearchBar(
                          type: 'update', defaultAddress: true);
                    }));
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      'Change',
                      style: IAText.caption(color: IAColors.primary).copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: IAColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget buildIndicator(){
    return AnimatedSmoothIndicator(
      activeIndex: _activeIndex,
      count: 3,
      effect:  WormEffect(
          dotHeight: 9,
          dotWidth: 9,
          activeDotColor: IAColors.primary,
          dotColor: IAColors.primary.withValues(alpha: 0.2)
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
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: IAText.caption(color: IAColors.black),
            ),
          ],
        ),
      ),
    );
  }

  /// [loading] draws placeholder tiles instead of an empty strip, so the home
  /// screen does not look broken while the first fetch is in flight.
  Widget _horizontalListView(List allItems, {bool loading = false}){
    if (loading && allItems.isEmpty) {
      return SizedBox(
        height: 12.pH,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 4,
          itemBuilder: (context, _) => Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SkeletonBox(
              height: 12.pH,
              width: 26.pW,
              margin: EdgeInsets.zero,
              radius: 12,
            ),
          ),
        ),
      );
    }
    return SizedBox(
      height: 13.pH,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: allItems.length,
          itemBuilder: (context, index){
            final allStores = allItems[index];
            return Padding(
              padding:  EdgeInsets.only(right: 5.pW),
              child: Pressable(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context){
                    return VendorDetail(
                      storeId: allStores.id!,
                      storeName: allStores.name!,
                      deliveryTime: allStores.deliveryTime!,
                      businessTime: '${allStores.openTime} - ${allStores.closeTime}',);
                  }));
                },
                child: Column(
                  children: [
                    NetworkThumb(
                      url: allStores.logo,
                      height: 14.pW,
                      width: 14.pW,
                      radius: BorderRadius.circular(7.pW),
                    ),
                    const SizedBox(height: 8),
                    // A fixed 10-character chop cut names mid-word with no
                    // regard for how wide the tile actually is.
                    SizedBox(
                      width: 20.pW,
                      child: Text(
                        allStores.name ?? '',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: IAText.label(weight: FontWeight.w600),
                      ),
                    )
                  ],
                ),
              ),
            );
          }
      ),
    );
  }

}