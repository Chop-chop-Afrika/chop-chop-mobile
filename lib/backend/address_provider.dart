import 'dart:convert';

import 'package:chop_chop_africa/Pages/home%20page/main_home.dart';
import 'package:chop_chop_africa/backend/models/address_search_model.dart';
import 'package:chop_chop_africa/backend/models/all_address_model.dart';
import 'package:chop_chop_africa/backend/models/current_address_model.dart';
import 'package:chop_chop_africa/backend/models/place_detail_by_id_model.dart';
import 'package:chop_chop_africa/backend/models/register_error.dart';
import 'package:chop_chop_africa/backend/models/success_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../env/env.dart';
import '../main.dart';
import '../utility/uiutils.dart';
import 'models/error_model.dart';

class AddressProvider with ChangeNotifier{

  List<SearchedAddress>? searchedAddress;
  CurrentAddressModel? currentAddress;
  List<AddressList> addressList = [];
  AddressList? defaultAddress;
  PlaceDetailsByIdModel? getPlaceDetails;


  Future<AddressSearchModel?> searchForAddress(String search) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic jsonResponse;
    try {
      String url = "${Env.BACKEND_URL}/user/address/search?q=$search";
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
        final addressSearch = AddressSearchModel.fromJson(jsonResponse);
        searchedAddress = addressSearch.data!;
        notifyListeners();
        return addressSearch;
      } else if (response.statusCode == 400) {
        jsonResponse = jsonDecode(response.body);
        print('Error: $jsonResponse');
        notifyListeners();
        return null;
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

  Future<CurrentAddressModel?> getCurrentAddress(String lat,String lng) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic jsonResponse;
    try {
      String url = "${Env.BACKEND_URL}/user/address/current-location?lat=$lat&lng=$lng";
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
        final currentAddressSeem = CurrentAddressModel.fromJson(jsonResponse);
        currentAddress = currentAddressSeem;
        notifyListeners();
        return currentAddressSeem;
      } else if (response.statusCode == 400) {
        jsonResponse = jsonDecode(response.body);
        print('Error: $jsonResponse');
        notifyListeners();
        return null;
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

  Future<dynamic> getLocationFromPlaceId( String placeId, bool defaultAddress, BuildContext context) async {
    dynamic jsonResponse;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    notifyListeners();
    print('this is $placeId');
    try {
      String url = "${Env.BACKEND_URL}/user/address/create-from-place";
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': "Bearer ${prefs.getString('accessToken')}",
        },
        body: jsonEncode({
          "placeId": placeId,
          "isDefault": defaultAddress
        }),
      );
      print('done');
      if (response.statusCode == 200 || response.statusCode == 201) {
        jsonResponse = jsonDecode(response.body);
        final success = SuccessModel.fromJson(jsonResponse);
        print('Success: ${success.message}');
        globalNavigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(builder: (_) => MainHome()),
        );
        notifyListeners();
        return success;
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

  Future<dynamic> getLocationManually( String address,double longitude,double latitude, bool defaultAddress, BuildContext context) async {
    dynamic jsonResponse;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    notifyListeners();
    try {
      String url = "${Env.BACKEND_URL}/user/address/create";
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': "Bearer ${prefs.getString('accessToken')}",
        },
        body: jsonEncode({
          "address": address,
          "longitude": longitude,
          "latitude": latitude,
          "isDefault": defaultAddress
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        jsonResponse = jsonDecode(response.body);
        final success = SuccessModel.fromJson(jsonResponse);
        print('Success: ${success.message}');
        globalNavigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(builder: (_) => MainHome()),
        );
        notifyListeners();
        return success;
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

  Future<AllAddressesModel?> getAllAddresses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic jsonResponse;
    try {
      String url = "${Env.BACKEND_URL}/user/address/all";
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
        final allAddress = AllAddressesModel.fromJson(jsonResponse);
        addressList = allAddress.data!;
        final mainAddress = addressList.isEmpty
            ? null
            : addressList.firstWhere(
              (item) => item.defaut == true,
          orElse: () => addressList.first,
        );
        defaultAddress = mainAddress;
        notifyListeners();
        return allAddress;
      } else if (response.statusCode == 400) {
        jsonResponse = jsonDecode(response.body);
        print('Error: $jsonResponse');
        notifyListeners();
        return null;
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


  Future<dynamic> changeAddress( String id,String address,double longitude,double latitude, BuildContext context) async {
    dynamic jsonResponse;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    notifyListeners();
    try {
      String url = "${Env.BACKEND_URL}/user/address/update/$id";
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': "Bearer ${prefs.getString('accessToken')}",
        },
        body: jsonEncode({
          "address": address,
          "longitude": longitude,
          "latitude": latitude,
          "isDefault": true
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        jsonResponse = jsonDecode(response.body);
        final success = SuccessModel.fromJson(jsonResponse);
        print('Success: ${success.message}');
        globalNavigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(builder: (_) => MainHome()),
        );
        notifyListeners();
        return success;
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

  Future<PlaceDetailsByIdModel?> getPlaceDetailById(String placeId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic jsonResponse;
    try {
      String url = "${Env.BACKEND_URL}/user/address/place/$placeId";
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
        final details = PlaceDetailsByIdModel.fromJson(jsonResponse);
        getPlaceDetails = details;
        notifyListeners();
        return details;
      } else if (response.statusCode == 400) {
        jsonResponse = jsonDecode(response.body);
        print('Error: $jsonResponse');
        notifyListeners();
        return null;
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

  Future<void> deleteAddress(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic jsonResponse;
    try {
      String url = "${Env.BACKEND_URL}/user/address/delete/$id";
      final response = await http.delete(
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
        //final details = SuccessModel.fromJson(jsonResponse);
        getAllAddresses();
        notifyListeners();
      } else if (response.statusCode == 400) {
        jsonResponse = jsonDecode(response.body);
        print('Error: $jsonResponse');
        notifyListeners();
        return null;
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



  void clearData() {
    searchedAddress = null;
    currentAddress = null;
    addressList = [];
    defaultAddress = null;
    getPlaceDetails = null;
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