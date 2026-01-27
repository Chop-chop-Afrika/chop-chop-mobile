import 'dart:convert';

import 'package:chop_chop_africa/Pages/Delivery/delivery_intro.dart';
import 'package:chop_chop_africa/Pages/auth_page/verification.dart';
import 'package:chop_chop_africa/backend/models/error_model.dart';
import 'package:chop_chop_africa/backend/models/register_error.dart';
import 'package:chop_chop_africa/backend/models/success_model.dart';
import 'package:chop_chop_africa/backend/models/verification_model.dart';
import 'package:chop_chop_africa/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Pages/home page/main_home.dart';
import '../env/env.dart';
import '../utility/uiutils.dart';

class AuthProvider with ChangeNotifier{

  Future<dynamic> signUp(String firstName, String lastName, String email, String phoneNo,String dob, String referral, BuildContext context) async {
    dynamic jsonResponse;
    notifyListeners();
    try {
      String url = "${Env.BACKEND_URL}/user/register";
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "first_name": firstName,
          "last_name": lastName,
          "email": email,
          "phone": phoneNo,
          "dob": dob,
          "referral_code": referral
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        jsonResponse = jsonDecode(response.body);
        final successResponse = SuccessModel.fromJson(jsonResponse);
        print('Success: ${successResponse.code}');
        Navigator.push(context, MaterialPageRoute(builder: (context){
          return VerificationPage(phoneNo: phoneNo,mode: 'signup',);
        }));
        notifyListeners();
        return successResponse;
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

  Future<dynamic> login( String phoneNo, BuildContext context) async {
    dynamic jsonResponse;
    notifyListeners();
    try {
      String url = "${Env.BACKEND_URL}/user/login";
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "phone": phoneNo,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        jsonResponse = jsonDecode(response.body);
        final successResponse = SuccessModel.fromJson(jsonResponse);
        print('Success: ${successResponse.code}');
        Navigator.push(context, MaterialPageRoute(builder: (context){
          return VerificationPage(phoneNo: phoneNo,mode: 'login',);
        }));
        notifyListeners();
        return successResponse;
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

  Future<dynamic> verification( String phoneNo, String otp, BuildContext context) async {
    dynamic jsonResponse;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    notifyListeners();
    try {
      String url = "${Env.BACKEND_URL}/user/verify-account";
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "phone": phoneNo,
          "otp": otp
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        jsonResponse = jsonDecode(response.body);
        final verifyResponse = VerificationModel.fromJson(jsonResponse);
        print('Success: ${verifyResponse.message}');
        await prefs.setString('accessToken', verifyResponse.accessToken!);
        globalNavigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(builder: (_) => DeliveryIntro()),
        );
        notifyListeners();
        return verifyResponse;
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


  Future<dynamic> loginVerification( String phoneNo, String otp, BuildContext context) async {
    dynamic jsonResponse;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    notifyListeners();
    try {
      String url = "${Env.BACKEND_URL}/user/verify-login";
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "phone": phoneNo,
          "otp": otp
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        jsonResponse = jsonDecode(response.body);
        final verifyResponse = VerificationModel.fromJson(jsonResponse);
        print('Success: ${verifyResponse.message}');
        await prefs.setString('accessToken', verifyResponse.accessToken!);
        globalNavigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => MainHome()),
              (Route<dynamic> route) => false,
        );
        notifyListeners();
        return verifyResponse;
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

  Future<bool> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      String url = "${Env.BACKEND_URL}/user/logout";
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': "Bearer ${prefs.getString('accessToken')}",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Logout successful');
        return true;
      } else {
        print('Logout failed with status: ${response.statusCode}');
        return false;
      }
    } catch (error) {
      print('Logout error: $error');
      return false;
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