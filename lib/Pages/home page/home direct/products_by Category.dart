// import 'package:chop_chop_africa/Pages/home%20page/home%20direct/vendor_grid.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../../backend/store_provider.dart';
//
//
// class ProductsByCategory extends StatefulWidget {
//   final String? category;
//   final String? storeId;
//
//
//   const ProductsByCategory({this.category, this.storeId});
//
//   @override
//   State<ProductsByCategory> createState() => _ProductsByCategoryState();
// }
//
// class _ProductsByCategoryState extends State<ProductsByCategory> {
//   final ScrollController _scrollController = ScrollController();
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_){
//       final provider = Provider.of<StoreProvider>(context, listen: false);
//       Future.microtask(() {
//
//         provider.fetchStoreDetail(
//           widget.storeId!,
//           "1",
//           widget.category ?? "",
//         );
//       });
//       _scrollController.addListener(() {
//         final stores = Provider.of<StoreProvider>(context, listen: false);
//
//         if (_scrollController.position.pixels >=
//             _scrollController.position.maxScrollExtent - 200) {
//           if (!stores.isLoadingMoreStoreDetail && stores.hasNextStoreDetailPage) {
//             Future.microtask(() {
//               provider.fetchStoreDetail(
//                 widget.storeId!,
//                 "1",
//                 widget.category ?? "",
//               );
//             });
//           }
//         }
//       });
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<StoreProvider>(
//       builder: (context, provider, _) {
//         final products = provider.getAllStoreDetails?.data?.record ?? [];
//
//         if (products.isEmpty) {
//           return Center(child: Text("No items"));
//         }
//
//         return VendorGrid(controller: _scrollController, products: provider.getStoreDetailList,);
//       },
//     );
//   }
// }
