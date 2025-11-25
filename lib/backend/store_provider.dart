import 'dart:convert';

import 'package:chop_chop_africa/backend/models/add_to_cart_model.dart';
import 'package:chop_chop_africa/backend/models/get_cart_model.dart';
import 'package:chop_chop_africa/backend/models/productCategoryModel.dart';
import 'package:chop_chop_africa/backend/models/send_and_receive_package.dart';
import 'package:chop_chop_africa/backend/models/store_detail_model.dart';
import 'package:chop_chop_africa/backend/models/success_model.dart';
import 'package:chop_chop_africa/backend/models/top_stores_model.dart';
import 'package:chop_chop_africa/backend/models/user_stores_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../env/env.dart';
import '../main.dart';
import '../utility/uiutils.dart';
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
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': "Bearer ${prefs.getString('accessToken')}",
        },
      );

      print('Response body: ${response.body}');

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
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': "Bearer ${prefs.getString('accessToken')}",
        },
      );

      print('Response body: ${response.body}');

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
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': "Bearer ${prefs.getString('accessToken')}",
        },
      );

      print('Response body: ${response.body}');

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
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': "Bearer ${prefs.getString('accessToken')}",
        },
      );

      print('Response body: ${response.body}');

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
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': "Bearer ${prefs.getString('accessToken')}",
        },
      );

      print('Response body: ${response.body}');

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
      final response = await http.post(
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
      print('done');
      if (response.statusCode == 200 || response.statusCode == 201) {
        jsonResponse = jsonDecode(response.body);
        notifyListeners();
      } else if (response.statusCode == 400) {
        jsonResponse = jsonDecode(response.body);
        final errorResponse = RegisterErrorModel.fromJson(jsonResponse);
        print('Error: ${errorResponse.message}');
        showAlert('Error',errorResponse.message!.join("\n"), 'close');
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

  Future<void> manipulateProductQuantity(int quantity,String productId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic jsonResponse;
    try {
      String url = "${Env.BACKEND_URL}/user/cart/$productId";
      final response = await http.patch(
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

      print('Response body: ${response.body}');

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
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': "Bearer ${prefs.getString('accessToken')}",
        },
      );

      print('Response body: ${response.body}');

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

  Future<void> packageAction(String pickUpAddress,
      String dropOffAddress,
      String senderName,
      String senderPhone,
      String senderEmail,
      String receiverName,
      String receiverPhone,
      String receiverEmail,
      String type,
      String mode,
      double? pickUpLongitude,
      double? pickUpLatitude,
      double? dropOffLongitude,
      double? dropOffLatitude
      ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic jsonResponse;
    try {
      String url = "${Env.BACKEND_URL}/user/packages/create";
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': "Bearer ${prefs.getString('accessToken')}",
        },
        body: jsonEncode({
          "pickupAddress": pickUpAddress,
          "dropOffAddress": dropOffAddress,
          "senderName": senderName,
          "senderPhone": senderPhone,
          "senderEmail": senderEmail,
          "receiverName": receiverName,
          "receiverPhone": receiverPhone,
          "receiverEmail": receiverEmail,
          "type": type,
          "mode": mode,
          "pickupLongitude": pickUpLongitude,
          "pickupLatitude": pickUpLatitude,
          "dropOffLongitude": dropOffLongitude,
          "dropOffLatitude": dropOffLatitude
        }),
      );

      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        jsonResponse = jsonDecode(response.body);
        final details = SendAndReceivePackageModel.fromJson(jsonResponse);
        showAlert('Success!', details.message!, 'close');
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