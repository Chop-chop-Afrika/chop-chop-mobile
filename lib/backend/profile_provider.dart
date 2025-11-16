import 'dart:convert';

import 'package:chop_chop_africa/backend/models/profile_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../env/env.dart';
import '../main.dart';
import '../utility/uiutils.dart';

class ProfileProvider with ChangeNotifier{

  ProfileModel? getAllProfileInfo;

  Future<ProfileModel?> getProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
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