import 'dart:convert';

import 'package:chop_chop_africa/backend/models/user_stores_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../env/env.dart';
import '../main.dart';
import '../utility/uiutils.dart';

class StoreProvider with ChangeNotifier{

  UserStoresModel? getAllStores;
  List<Record> allStoresList = [];
  bool isLoadingMoreStores = false;
  int currentStorePage = 1;
  bool hasNextStorePage = true;

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