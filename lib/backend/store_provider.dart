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
  StoreInformationModel? storeInformation;


  Future<void> fetchStores(String type,String latitude,String longitude, {bool loadMore = false}) async {
    if (loadMore && (isLoadingMoreStores || !hasNextStorePage)) return;
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
      }
      notifyListeners();
    }
  }
  Future<void> fetchTopStores(String lat, String long) async {
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
        getTopStores = details.data!;
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
    }
  }

  Future<void> fetchTopVendors(String type,String lat, String long) async {
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
        getTopVendors = details.data!;
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

  void clearStoreDetail() {
    getStoreDetailList.clear();
    currentStoreDetailPage = 1;
    hasNextStoreDetailPage = true;
    notifyListeners();
  }

  Future<void> fetchStoreDetail(String storeId,String? category, {bool loadMore = false}) async {

    if (loadMore && (isLoadingMoreStoreDetail || !hasNextStoreDetailPage)) return;
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
        hasNextStoreDetailPage = details.data!.hasNextPage??false;
        currentStoreDetailPage = details.data!.nextPage ?? currentStoreDetailPage;
        getStoreDetailList.addAll(details.data!.record ?? []);
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
      }
      notifyListeners();
    }
  }

  Future<void> fetchAllProductCategories() async {
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
    }
  }

  Future<void> searchProductsAndStores(String type, String search) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic jsonResponse;
    try {
      String url = "${Env.BACKEND_URL}/user/search?query=$search&type=$type";
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
        if(type == 'products'){
          final details = SearchProductModel.fromJson(jsonResponse);
          searchProducts = details.data!;
        }else{
          final details = SearchStoreModel.fromJson(jsonResponse);
          searchStores = details.data!;
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
        activePackage = details.data!;
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

  clearAllDetail(){
    allStoresList.clear();
    currentStorePage = 1;
    hasNextStorePage = true;
    isLoadingMoreStores = false;
    notifyListeners();
  }

  Future<void> fetchStoreInformation(String storeId) async {
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