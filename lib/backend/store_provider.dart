import 'dart:convert';
import 'package:chop_chop_africa/backend/models/get_active_package_model.dart';
import 'package:chop_chop_africa/backend/models/get_cart_model.dart';
import 'package:chop_chop_africa/backend/models/productCategoryModel.dart';
import 'package:chop_chop_africa/backend/models/search_product_model.dart';
import 'package:chop_chop_africa/backend/models/search_store_model.dart';
import 'package:chop_chop_africa/backend/models/send_and_receive_package.dart';
import 'package:chop_chop_africa/backend/models/store_detail_model.dart';
import 'package:chop_chop_africa/backend/models/store_information_model.dart';
import 'package:chop_chop_africa/backend/models/success_model.dart';
import 'package:chop_chop_africa/backend/models/top_stores_model.dart';
import 'package:chop_chop_africa/backend/models/user_stores_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Pages/home page/main_home.dart';
import '../env/env.dart';
import '../main.dart';
import '../utility/uiutils.dart';
import 'models/error_model.dart';
import 'models/register_error.dart';

class StoreProvider with ChangeNotifier{

  UserStoresModel? getAllStores;
  List<Record> allStoresList = [];
  bool isLoadingMoreStores = false;

  /// First-load flags. The pagination flags above only cover "load more", so
  /// the initial fetch rendered an empty screen with no sign anything was
  /// happening.
  bool loadingStores = false;
  bool loadingTopStores = false;
  bool loadingTopVendors = false;
  bool loadingCategories = false;
  bool loadingStoreDetail = false;
  bool loadingStoreInfo = false;
  bool loadingCart = false;
  bool loadingSearch = false;
  bool loadingPackages = false;
  int currentStorePage = 1;
  bool hasNextStorePage = true;
  List<TopStoresData> getTopStores =[];
  List<TopStoresData> getTopVendors =[];
  StoreDetailModel? getAllStoreDetails;
  List<StoreDetailRecord> getStoreDetailList = [];
  bool isLoadingMoreStoreDetail = false;
  int currentStoreDetailPage = 1;
  bool hasNextStoreDetailPage = true;
  ProductCategoryModel? getAllProductCategories;
  GetCartModel? getCartItems;
  List<ActivePackageList> activePackage = [];
  List<StoreModelData> searchStores = [];
  List<SearchProductData> searchProducts = [];

  // Search pagination. /user/search takes `page` and `pageSize` (it is in the
  // Swagger), but the client used to send neither, so a search only ever
  // showed its first ten results however many there were - and the models
  // have been parsing currentPage/hasNextPage the whole time with nothing
  // reading them.
  // Each type keeps its own cursor: a query can run out of stores long
  // before it runs out of products, and /user/search has to be told which of
  // the two it is looking for - there is no "both".
  int storeSearchPage = 1;
  int productSearchPage = 1;
  bool hasNextStoreSearchPage = false;
  bool hasNextProductSearchPage = false;
  bool isLoadingMoreSearch = false;
  String _searchQuery = '';

  /// Whether either half of the current search has more to give.
  bool get hasNextSearchPage =>
      hasNextStoreSearchPage || hasNextProductSearchPage;

  /// The search now on screen found nothing of either kind.
  bool get searchFoundNothing =>
      searchStores.isEmpty && searchProducts.isEmpty;

  StoreInformationModel? storeInformation;


  /// True while [loadRestOfStores] is working through the remaining pages of
  /// the nearby-vendors list.
  bool loadingWholeStoreList = false;

  /// Pulls every page of the vendor list that has not been fetched yet.
  ///
  /// Same reason as [loadRestOfStoreDetail]: searching this list is done in
  /// the app, because /user/search is not scoped by type or by location, so
  /// it would answer with supermarkets that cannot deliver to this address
  /// and with restaurants on a supermarket screen. Filtering what is already
  /// loaded keeps that scoping, but only once the whole list is here.
  Future<void> loadRestOfStores(
      String type, String latitude, String longitude) async {
    if (loadingWholeStoreList || !hasNextStorePage) return;
    loadingWholeStoreList = true;
    notifyListeners();
    try {
      while (hasNextStorePage) {
        final int before = allStoresList.length;
        await fetchStores(type, latitude, longitude, loadMore: true);
        // A page that adds nothing means there is nothing more to come,
        // whatever hasNextPage claims.
        if (allStoresList.length == before) break;
      }
    } finally {
      loadingWholeStoreList = false;
      notifyListeners();
    }
  }

  Future<void> fetchStores(String type,String latitude,String longitude, {bool loadMore = false}) async {
    if (loadMore && (isLoadingMoreStores || !hasNextStorePage)) return;
    // The flag above only covers pagination, so a first load looked
    // identical to an empty result.
    if (!loadMore) {
      loadingStores = true;
      notifyListeners();
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic jsonResponse;
    try {
      if(loadMore){
        isLoadingMoreStores = true;
        notifyListeners();
      }
      String url = "${Env.BACKEND_URL}/user/stores?page=$currentStorePage&pageSize=10&type=$type&lat=$latitude&lng=$longitude";
      final response = await apiClient.get(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': "Bearer ${prefs.getString('accessToken')}",
        },
      );


      if (response.statusCode == 200 || response.statusCode == 201) {
        jsonResponse = jsonDecode(response.body);
        final allStores = UserStoresModel.fromJson(jsonResponse);
        getAllStores = allStores;
        // Extract pagination info
        hasNextStorePage = allStores.data!.hasNextPage??false;
        currentStorePage = allStores.data!.nextPage ?? currentStorePage;
        // Add new records
        allStoresList.addAll(allStores.data!.record ?? []);
        notifyListeners();
      } else if (response.statusCode == 400) {
        jsonResponse = jsonDecode(response.body);
        print('Error: $jsonResponse');
        notifyListeners();
      } else {
        jsonResponse = jsonDecode(response.body);
        throw jsonResponse['message'];
      }
    } catch (error) {
      String errorMessage = error.toString();
      print('Caught error: $errorMessage');
      notifyListeners();
    }finally {
      // ✅ Always reset the loading flag
      if (loadMore) {
        isLoadingMoreStores = false;
      } else {
        loadingStores = false;
      }
      notifyListeners();
    }
  }
  Future<void> fetchTopStores(String lat, String long) async {
    loadingTopStores = true;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic jsonResponse;
    try {
      String url = "${Env.BACKEND_URL}/user/stores/top?lat=$lat&lng=$long&limit=10";
      final response = await apiClient.get(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': "Bearer ${prefs.getString('accessToken')}",
        },
      );


      if (response.statusCode == 200 || response.statusCode == 201) {
        jsonResponse = jsonDecode(response.body);
        final details = TopStoresModel.fromJson(jsonResponse);
        getTopStores = details.data ?? [];
        notifyListeners();
      } else if (response.statusCode == 400) {
        jsonResponse = jsonDecode(response.body);
        print('Error: $jsonResponse');
        notifyListeners();
      } else {
        jsonResponse = jsonDecode(response.body);
        throw jsonResponse['message'];
      }
    } catch (error) {
      String errorMessage = error.toString();
      print('Caught error: $errorMessage');
      notifyListeners();
      return null;
    } finally {
      loadingTopStores = false;
      notifyListeners();
    }
  }

  Future<void> fetchTopVendors(String type,String lat, String long) async {
    loadingTopVendors = true;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic jsonResponse;
    try {
      String url = "${Env.BACKEND_URL}/user/top-vendors?type=$type&lat=$lat&lng=$long";
      final response = await apiClient.get(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': "Bearer ${prefs.getString('accessToken')}",
        },
      );


      if (response.statusCode == 200 || response.statusCode == 201) {
        jsonResponse = jsonDecode(response.body);
        final details = TopStoresModel.fromJson(jsonResponse);
        getTopVendors = details.data ?? [];
        notifyListeners();
      } else if (response.statusCode == 400) {
        jsonResponse = jsonDecode(response.body);
        print('Error: $jsonResponse');
        notifyListeners();
      } else {
        jsonResponse = jsonDecode(response.body);
        throw jsonResponse['message'];
      }
    } catch (error) {
      String errorMessage = error.toString();
      print('Caught error: $errorMessage');
      notifyListeners();
    } finally {
      loadingTopVendors = false;
      notifyListeners();
    }
  }

  void clearStoreDetail() {
    getStoreDetailList.clear();
    currentStoreDetailPage = 1;
    hasNextStoreDetailPage = true;
    notifyListeners();
  }

  /// True while [loadRestOfStoreDetail] is working through the remaining
  /// pages of a vendor's menu.
  bool loadingWholeMenu = false;

  /// Pulls every page of a vendor's menu that has not been fetched yet.
  ///
  /// Searching within one vendor has to be done here in the app, because
  /// /user/search takes only `query` and `type` - there is no storeId to
  /// narrow it by. Filtering a half-loaded menu would quietly miss matches,
  /// so the rest of it is fetched before the filter is applied.
  Future<void> loadRestOfStoreDetail(String storeId, String? category) async {
    if (loadingWholeMenu || !hasNextStoreDetailPage) return;
    loadingWholeMenu = true;
    notifyListeners();
    try {
      while (hasNextStoreDetailPage) {
        final int before = getStoreDetailList.length;
        await fetchStoreDetail(storeId, category, loadMore: true);
        // A page that adds nothing means there is nothing more to come,
        // whatever hasNextPage claims. Without this a server that always
        // answers true would spin here forever.
        if (getStoreDetailList.length == before) break;
      }
    } finally {
      loadingWholeMenu = false;
      notifyListeners();
    }
  }

  Future<void> fetchStoreDetail(String storeId,String? category, {bool loadMore = false}) async {

    if (loadMore && (isLoadingMoreStoreDetail || !hasNextStoreDetailPage)) return;
    // The flag above only covers pagination, so a first load looked
    // identical to an empty result.
    if (!loadMore) {
      loadingStoreDetail = true;
      notifyListeners();
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic jsonResponse;
    try {
      if(loadMore){
        isLoadingMoreStoreDetail = true;
        notifyListeners();
      }
      String url = category == null?
          "${Env.BACKEND_URL}/user/products/store/$storeId?page=$currentStoreDetailPage&pageSize=10":
      "${Env.BACKEND_URL}/user/products/store/$storeId?page=$currentStoreDetailPage&pageSize=10&category=$category";
      final response = await apiClient.get(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': "Bearer ${prefs.getString('accessToken')}",
        },
      );


      if (response.statusCode == 200 || response.statusCode == 201) {
        jsonResponse = jsonDecode(response.body);
        final details = StoreDetailModel.fromJson(jsonResponse);
        getAllStoreDetails = details;
        // A missing page object means no more results, not a crash.
        final page = details.data;
        hasNextStoreDetailPage = page?.hasNextPage ?? false;
        currentStoreDetailPage = page?.nextPage ?? currentStoreDetailPage;
        getStoreDetailList.addAll(page?.record ?? []);
        notifyListeners();
      } else if (response.statusCode == 400) {
        jsonResponse = jsonDecode(response.body);
        print('Error: $jsonResponse');
        notifyListeners();
      } else {
        jsonResponse = jsonDecode(response.body);
        throw jsonResponse['message'];
      }
    } catch (error) {
      String errorMessage = error.toString();
      print('Caught error: $errorMessage');
      notifyListeners();
    }finally {
      // ✅ Always reset the loading flag
      if (loadMore) {
        isLoadingMoreStoreDetail = false;
      } else {
        loadingStoreDetail = false;
      }
      notifyListeners();
    }
  }

  Future<void> fetchAllProductCategories() async {
    loadingCategories = true;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic jsonResponse;
    try {
      String url = "${Env.BACKEND_URL}/user/products/categories";
      final response = await apiClient.get(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': "Bearer ${prefs.getString('accessToken')}",
        },
      );


      if (response.statusCode == 200 || response.statusCode == 201) {
        jsonResponse = jsonDecode(response.body);
        final details = ProductCategoryModel.fromJson(jsonResponse);
        getAllProductCategories = details;
        notifyListeners();
      } else if (response.statusCode == 400) {
        jsonResponse = jsonDecode(response.body);
        print('Error: $jsonResponse');
        notifyListeners();
      } else {
        jsonResponse = jsonDecode(response.body);
        throw jsonResponse['message'];
      }
    } catch (error) {
      String errorMessage = error.toString();
      print('Caught error: $errorMessage');
      notifyListeners();
    } finally {
      loadingCategories = false;
      notifyListeners();
    }
  }

  Future<dynamic> addToCart( String productId, String? variantId, int quantity, BuildContext context) async {
    dynamic jsonResponse;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    notifyListeners();
    try {
      String url = "${Env.BACKEND_URL}/user/cart/add";
      final response = await apiClient.post(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': "Bearer ${prefs.getString('accessToken')}",
        },
        body: jsonEncode(variantId == null?{
          "productId": productId,
          "quantity": quantity
        }:{
          "productId": productId,
          "variantId":variantId,
          "quantity": quantity
        }

        ),
      );
      print(response.statusCode);
      print(jsonDecode(response.body));
      if (response.statusCode == 200 || response.statusCode == 201) {
        jsonResponse = jsonDecode(response.body);
        notifyListeners();
      } else if (response.statusCode == 400) {
        jsonResponse = jsonDecode(response.body);
        final errorResponse = ErrorModel.fromJson(jsonResponse);
        print('Error: ${errorResponse.message}');
        showAlert('Error',errorResponse.message!, 'close');
        notifyListeners();
        return errorResponse;
      } else {
        jsonResponse = jsonDecode(response.body);
        throw jsonResponse['message'];
      }
    } catch (error) {
      String errorMessage = error.toString();
      print('The error is: $errorMessage');
      if (errorMessage.contains('Failed host lookup')) {
        showAlert('Error', "Connection is down currently", 'close');
      } else if (errorMessage.contains('DOCTYPE HTML') || errorMessage.contains('oken') || errorMessage.contains('Connection reset by peer')) {
        showAlert('Error', "Something went wrong", 'close');
      } else {
        showAlert('Error', errorMessage, 'close');
      }
      return null;
    }
  }
  Future<void> clearCart(String orderId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic jsonResponse;
    try {
      String url = "${Env.BACKEND_URL}/user/cart/remove/$orderId";
      final response = await apiClient.delete(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': "Bearer ${prefs.getString('accessToken')}",
        },
      );


      if (response.statusCode == 200 || response.statusCode == 201) {
        jsonResponse = jsonDecode(response.body);
        globalNavigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => MainHome()),
              (Route<dynamic> route) => false,
        );
        notifyListeners();
      } else if (response.statusCode == 400) {
        jsonResponse = jsonDecode(response.body);
        print('Error: $jsonResponse');
        notifyListeners();
      } else {
        jsonResponse = jsonDecode(response.body);
        throw jsonResponse['message'];
      }
    } catch (error) {
      String errorMessage = error.toString();
      print('Caught error: $errorMessage');
      notifyListeners();
    }
  }

  Future<void> deleteProductFromCart(String orderId, String productId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic jsonResponse;
    try {
      String url = "${Env.BACKEND_URL}/user/cart/remove/$orderId/$productId";
      final response = await apiClient.delete(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': "Bearer ${prefs.getString('accessToken')}",
        },
      );


      if (response.statusCode == 200 || response.statusCode == 201) {
        jsonResponse = jsonDecode(response.body);
        final details = SuccessModel.fromJson(jsonResponse);
        // Refresh cart items after deletion
        await fetchAllCartItems();
        notifyListeners();
      } else if (response.statusCode == 400) {
        jsonResponse = jsonDecode(response.body);
        print('Error: $jsonResponse');
        notifyListeners();
      } else {
        jsonResponse = jsonDecode(response.body);
        throw jsonResponse['message'];
      }
    } catch (error) {
      String errorMessage = error.toString();
      print('Caught error: $errorMessage');
      notifyListeners();
    }
  }

  Future<void> manipulateProductQuantity(int quantity,String productId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic jsonResponse;
    try {
      String url = "${Env.BACKEND_URL}/user/cart/$productId";
      final response = await apiClient.patch(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': "Bearer ${prefs.getString('accessToken')}",
        },
        body: jsonEncode({
         "quantity":quantity
        }),
      );


      if (response.statusCode == 200 || response.statusCode == 201) {
        jsonResponse = jsonDecode(response.body);
        final details = SuccessModel.fromJson(jsonResponse);
        if(details.message == 'Cart updated successfully'){
          fetchAllCartItems();
        }
        notifyListeners();
      } else if (response.statusCode == 400) {
        jsonResponse = jsonDecode(response.body);
        print('Error: $jsonResponse');
        notifyListeners();
      } else {
        jsonResponse = jsonDecode(response.body);
        throw jsonResponse['message'];
      }
    } catch (error) {
      String errorMessage = error.toString();
      print('Caught error: $errorMessage');
      notifyListeners();
    }
  }

  Future<void> fetchAllCartItems() async {
    loadingCart = true;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic jsonResponse;
    try {
      String url = "${Env.BACKEND_URL}/user/cart";
      final response = await apiClient.get(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': "Bearer ${prefs.getString('accessToken')}",
        },
      );


      if (response.statusCode == 200 || response.statusCode == 201) {
        jsonResponse = jsonDecode(response.body);
        final details = GetCartModel.fromJson(jsonResponse);
        getCartItems = details;
        notifyListeners();
      } else if (response.statusCode == 400) {
        jsonResponse = jsonDecode(response.body);
        print('Error: $jsonResponse');
        notifyListeners();
      } else {
        jsonResponse = jsonDecode(response.body);
        throw jsonResponse['message'];
      }
    } catch (error) {
      String errorMessage = error.toString();
      print('Caught error: $errorMessage');
      notifyListeners();
    } finally {
      loadingCart = false;
      notifyListeners();
    }
  }

  /// Empties both result lists, e.g. when the search field is cleared or the
  /// stores/products tab changes.
  void clearSearchResults() {
    searchStores = [];
    searchProducts = [];
    storeSearchPage = 1;
    productSearchPage = 1;
    hasNextStoreSearchPage = false;
    hasNextProductSearchPage = false;
    isLoadingMoreSearch = false;
    loadingSearch = false;
    _searchQuery = '';
    notifyListeners();
  }

  /// Fetches the next page of whatever is currently on screen. The query is
  /// remembered from the last search so the list does not have to hand it
  /// back.
  Future<void> loadMoreSearchResults() =>
      searchEverything(_searchQuery, loadMore: true);

  /// Searches stores and products together.
  ///
  /// /user/search takes a required `type` of either "stores" or "products",
  /// so it cannot answer for both at once - but nothing stops the app asking
  /// it twice. The two run side by side and land in their own lists, which
  /// is what lets the search screen be one field instead of two tabs.
  Future<void> searchEverything(String search, {bool loadMore = false}) async {
    final String query = search.trim();
    if (query.isEmpty) {
      clearSearchResults();
      return;
    }

    if (loadMore) {
      if (isLoadingMoreSearch || !hasNextSearchPage) return;
      isLoadingMoreSearch = true;
    } else {
      storeSearchPage = 1;
      productSearchPage = 1;
      hasNextStoreSearchPage = false;
      hasNextProductSearchPage = false;
      searchStores = [];
      searchProducts = [];
      loadingSearch = true;
    }
    _searchQuery = query;
    notifyListeners();

    try {
      // On a first search both halves go out. Loading more only asks the
      // half that still has pages left.
      await Future.wait(<Future<void>>[
        if (!loadMore || hasNextStoreSearchPage)
          searchProductsAndStores('stores', query, loadMore: loadMore),
        if (!loadMore || hasNextProductSearchPage)
          searchProductsAndStores('products', query, loadMore: loadMore),
      ]);
    } finally {
      loadingSearch = false;
      isLoadingMoreSearch = false;
      notifyListeners();
    }
  }

  Future<void> searchProductsAndStores(String type, String search,
      {bool loadMore = false}) async {
    // Clearing the field used to fire a search with an empty query, whose
    // response carries no `data` — the old `data!` then threw "Null check
    // operator used on a null value". Nothing to search for means nothing to
    // show, so clear locally and skip the request entirely.
    //
    // This check also has to come before `loadingSearch` is raised. It used
    // to sit after, and returning here skipped the try/finally that puts the
    // flag back down, so clearing the field left the spinner up for good.
    final String query = search.trim();
    if (query.isEmpty) {
      clearSearchResults();
      return;
    }

    final bool products = type == 'products';
    if (loadMore &&
        !(products ? hasNextProductSearchPage : hasNextStoreSearchPage)) {
      return;
    }
    if (!loadMore) {
      // A new query starts again at page one and keeps none of the last
      // one's results.
      if (products) {
        productSearchPage = 1;
        hasNextProductSearchPage = false;
        searchProducts = [];
      } else {
        storeSearchPage = 1;
        hasNextStoreSearchPage = false;
        searchStores = [];
      }
    }
    _searchQuery = query;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic jsonResponse;
    try {
      final String url =
          "${Env.BACKEND_URL}/user/search?query=${Uri.encodeQueryComponent(query)}&type=$type&page=${products ? productSearchPage : storeSearchPage}&pageSize=10";
      final response = await apiClient.get(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': "Bearer ${prefs.getString('accessToken')}",
        },
      );


      if (response.statusCode == 200 || response.statusCode == 201) {
        jsonResponse = jsonDecode(response.body);
        // An empty or unexpected payload yields no list; show no results
        // rather than throwing.
        if(type == 'products'){
          final details = SearchProductModel.fromJson(jsonResponse);
          searchProducts.addAll(details.data ?? []);
          hasNextProductSearchPage = details.hasNextPage ?? false;
          productSearchPage = details.nextPage ?? productSearchPage + 1;
        }else{
          final details = SearchStoreModel.fromJson(jsonResponse);
          searchStores.addAll(details.data ?? []);
          hasNextStoreSearchPage = details.hasNextPage ?? false;
          storeSearchPage = details.nextPage ?? storeSearchPage + 1;
        }

        notifyListeners();
      } else if (response.statusCode == 400) {
        jsonResponse = jsonDecode(response.body);
        print('Error: $jsonResponse');
        notifyListeners();
      } else {
        jsonResponse = jsonDecode(response.body);
        throw jsonResponse['message'];
      }
    } catch (error) {
      String errorMessage = error.toString();
      print('Caught error: $errorMessage');
      notifyListeners();
    } finally {
      if (loadMore) {
        isLoadingMoreSearch = false;
      } else {
        loadingSearch = false;
      }
      notifyListeners();
    }
  }

  /// Empties the whole cart across every store. Distinct from
  /// [clearCart], which removes one store's cart by orderId.
  Future<bool> clearEntireCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      String url = "${Env.BACKEND_URL}/user/cart/clear";
      final response = await apiClient.delete(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': "Bearer ${prefs.getString('accessToken')}",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchAllCartItems();
        return true;
      }
      print('Clear cart failed: ${response.statusCode} ${response.body}');
      return false;
    } catch (error) {
      print('Clear cart error: $error');
      return false;
    }
  }

  Future<void> getPackageStatus(String status) async {
    loadingPackages = true;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic jsonResponse;
    try {
      String url = "${Env.BACKEND_URL}/user/packages/$status";
      final response = await apiClient.get(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': "Bearer ${prefs.getString('accessToken')}",
        },
      );


      if (response.statusCode == 200 || response.statusCode == 201) {
        jsonResponse = jsonDecode(response.body);
        final details = GetActivePackageModel.fromJson(jsonResponse);
        activePackage = details.data ?? [];
        notifyListeners();
      } else if (response.statusCode == 400) {
        jsonResponse = jsonDecode(response.body);
        print('Error: $jsonResponse');
        notifyListeners();
      } else {
        jsonResponse = jsonDecode(response.body);
        throw jsonResponse['message'];
      }
    } catch (error) {
      String errorMessage = error.toString();
      print('Caught error: $errorMessage');
      notifyListeners();
    } finally {
      loadingPackages = false;
      notifyListeners();
    }
  }

  clearAllDetail(){
    allStoresList.clear();
    currentStorePage = 1;
    hasNextStorePage = true;
    isLoadingMoreStores = false;
    notifyListeners();
  }

  Future<void> fetchStoreInformation(String storeId) async {
    loadingStoreInfo = true;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic jsonResponse;
    try {
      String url = "${Env.BACKEND_URL}/user/products/stores/details/$storeId";
      final response = await apiClient.get(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': "Bearer ${prefs.getString('accessToken')}",
        },
      );


      if (response.statusCode == 200 || response.statusCode == 201) {
        jsonResponse = jsonDecode(response.body);
        final details = StoreInformationModel.fromJson(jsonResponse);
        storeInformation = details;
        notifyListeners();
      } else if (response.statusCode == 400) {
        jsonResponse = jsonDecode(response.body);
        print('Error: $jsonResponse');
        notifyListeners();
      } else {
        jsonResponse = jsonDecode(response.body);
        throw jsonResponse['message'];
      }
    } catch (error) {
      String errorMessage = error.toString();
      print('Caught error: $errorMessage');
      notifyListeners();
    } finally {
      loadingStoreInfo = false;
      notifyListeners();
    }
  }

  void clearData() {
    getAllStores = null;
    allStoresList = [];
    isLoadingMoreStores = false;
    currentStorePage = 1;
    hasNextStorePage = true;
    getTopStores = [];
    getTopVendors = [];
    getAllStoreDetails = null;
    getStoreDetailList = [];
    isLoadingMoreStoreDetail = false;
    currentStoreDetailPage = 1;
    hasNextStoreDetailPage = true;
    getAllProductCategories = null;
    getCartItems = null;
    activePackage = [];
    searchStores = [];
    searchProducts = [];
    storeSearchPage = 1;
    productSearchPage = 1;
    hasNextStoreSearchPage = false;
    hasNextProductSearchPage = false;
    isLoadingMoreSearch = false;
    _searchQuery = '';
    storeInformation = null;
    notifyListeners();
  }

  showAlert(String title,String content,String defaultAction, {Function(bool)? onDismissed = null}) {
    UiUtils.showAlertDialog(
        context: globalNavigatorKey.currentContext!,
        title: title,
        content: content,
        defaultActionText: defaultAction,
        onDismissed: (value) {
          if (onDismissed != null) onDismissed(value);
        });
  }
}