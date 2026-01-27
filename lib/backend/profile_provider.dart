import 'dart:convert';
import 'dart:io';

import 'package:chop_chop_africa/Pages/auth_page/get_started.dart';
import 'package:chop_chop_africa/backend/models/profile_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';


import '../env/env.dart';
import '../main.dart';
import '../utility/uiutils.dart';
import 'models/error_model.dart';
import 'models/success_model.dart';

class ProfileProvider with ChangeNotifier{

  ProfileModel? getAllProfileInfo;

  Future<ProfileModel?> getProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(prefs.getString('accessToken'));
    dynamic jsonResponse;
    try {
      String url = "${Env.BACKEND_URL}/user/profile";
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
        final details = ProfileModel.fromJson(jsonResponse);
        getAllProfileInfo = details;
        notifyListeners();
        return details;
      } else if (response.statusCode == 400) {
        jsonResponse = jsonDecode(response.body);
        print('Error: $jsonResponse');
        notifyListeners();
        return null;
      }else if (response.statusCode == 404) {

        UiUtils.showSnackBarFromTop(
            globalNavigatorKey.currentContext!,
            'Token has expired, Login to continue'
        );
        await prefs.clear();
        globalNavigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => GetStarted()),
              (Route<dynamic> route) => false,
        );
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

  Future<dynamic> updateProfile( String firstName,String lastName,String email, String dob, BuildContext context) async {
    dynamic jsonResponse;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    notifyListeners();
    try {
      String url = "${Env.BACKEND_URL}/user/profile/update";
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': "Bearer ${prefs.getString('accessToken')}",
        },
        body: jsonEncode({
          "firstName": firstName,
          "lastName": lastName,
          "email": email,
          "dob": dob
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        jsonResponse = jsonDecode(response.body);
        final success = SuccessModel.fromJson(jsonResponse);
        print('Success: ${success.message}');
       getProfile();
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

  Future<void> changeAvatar(File imageFile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic jsonResponse;

    try {
      String url = "${Env.BACKEND_URL}/user/change-avatar";
      String ext = path.extension(imageFile.path).toLowerCase();
      final mediaType = (ext == '.png')
          ? http.MediaType('image', 'png')
          : http.MediaType('image', 'jpeg');
      // Multipart Request
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll({
        'accept': '*/*',
        'Authorization': "Bearer ${prefs.getString('accessToken')}",
        'Content-Type': 'multipart/form-data',
      });

      // Attach file
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          contentType: mediaType,
        ),
      );

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Response body: ${response.body}');

      // Handle success
      if (response.statusCode == 200 || response.statusCode == 201) {
        jsonResponse = jsonDecode(response.body);
        //final details = SuccessModel.fromJson(jsonResponse);
        getProfile();
        notifyListeners();

      }else if (response.statusCode == 400) {
        jsonResponse = jsonDecode(response.body);
        print('Error: $jsonResponse');
        notifyListeners();

      } else {
        jsonResponse = jsonDecode(response.body);
        throw jsonResponse['message'];
      }

    } catch (error) {
      String errorMessage = error.toString();
      print("Caught error: $errorMessage");
      notifyListeners();
    }
  }
  void clearData() {
    getAllProfileInfo = null;
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