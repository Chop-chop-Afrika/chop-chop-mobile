import 'dart:convert';

import 'package:chop_chop_africa/Pages/Delivery/delivery_intro.dart';
import 'package:chop_chop_africa/Pages/auth_page/verification.dart';
import 'package:chop_chop_africa/backend/models/error_model.dart';
import 'package:chop_chop_africa/backend/models/register_error.dart';
import 'package:chop_chop_africa/backend/models/success_model.dart';
import 'package:chop_chop_africa/backend/models/verification_model.dart';
import 'package:chop_chop_africa/backend/notification_service.dart';
import 'package:chop_chop_africa/backend/socket_service.dart';
import 'package:chop_chop_africa/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_client.dart';
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
      final response = await apiClient.post(
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
          return VerificationPage(email: email, mode: 'signup',);
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

  Future<dynamic> login( String email, BuildContext context) async {
    dynamic jsonResponse;
    notifyListeners();
    try {
      String url = "${Env.BACKEND_URL}/user/login";
      final response = await apiClient.post(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "email": email,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        jsonResponse = jsonDecode(response.body);
        final successResponse = SuccessModel.fromJson(jsonResponse);
        print('Success: ${successResponse.code}');
        Navigator.push(context, MaterialPageRoute(builder: (context){
          return VerificationPage(email: email, mode: 'login',);
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

  Future<dynamic> verification( String email, String otp, BuildContext context) async {
    dynamic jsonResponse;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    notifyListeners();
    try {
      String url = "${Env.BACKEND_URL}/user/verify-account";
      final response = await apiClient.post(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "email": email,
          "otp": otp
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        jsonResponse = jsonDecode(response.body);
        final verifyResponse = VerificationModel.fromJson(jsonResponse);
        print('Success: ${verifyResponse.message}');
        await prefs.setString('accessToken', verifyResponse.accessToken!);
        if (verifyResponse.refreshToken != null) {
          await prefs.setString('refreshToken', verifyResponse.refreshToken!);
        }
        await NotificationService.instance.registerTokenWithBackend();
        await SocketService.instance.connect();
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


  Future<dynamic> loginVerification( String email, String otp, BuildContext context) async {
    dynamic jsonResponse;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    notifyListeners();
    try {
      String url = "${Env.BACKEND_URL}/user/verify-login";
      final response = await apiClient.post(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "email": email,
          "otp": otp
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        jsonResponse = jsonDecode(response.body);
        final verifyResponse = VerificationModel.fromJson(jsonResponse);
        print('Success: ${verifyResponse.message}');
        await prefs.setString('accessToken', verifyResponse.accessToken!);
        if (verifyResponse.refreshToken != null) {
          await prefs.setString('refreshToken', verifyResponse.refreshToken!);
        }
        await NotificationService.instance.registerTokenWithBackend();
        await SocketService.instance.connect();
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

  /// Resends the OTP for whichever flow the user is in. [mode] is one of the
  /// API's enum values — REGISTRATION_VERIFICATION after signing up, or
  /// LOGIN_VERIFICATION when logging in.
  ///
  /// Returns true when a new code was sent, so the screen only restarts its
  /// countdown if one actually went out.
  Future<bool> resendOtp(String email, String mode) async {
    dynamic jsonResponse;
    try {
      String url = "${Env.BACKEND_URL}/user/resend-otp";
      final response = await apiClient.post(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "email": email,
          "mode": mode,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('OTP resent to $email');
        return true;
      }
      jsonResponse = jsonDecode(response.body);
      final dynamic message = jsonResponse['message'];
      showAlert('Error',
          message is List ? message.join("\n") : (message?.toString() ?? 'Could not resend the code'),
          'close');
      return false;
    } catch (error) {
      String errorMessage = error.toString();
      print('Resend OTP error: $errorMessage');
      if (errorMessage.contains('Failed host lookup')) {
        showAlert('Error', "Connection is down currently", 'close');
      } else {
        showAlert('Error', "Could not resend the code", 'close');
      }
      return false;
    }
  }

  /// Mode values the resend endpoint accepts for the two app flows.
  static const String registrationMode = 'REGISTRATION_VERIFICATION';
  static const String loginMode = 'LOGIN_VERIFICATION';

  Future<bool> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      // Unregister the push token first — /user/logout invalidates the access
      // token, and the device-tokens endpoint needs it to authenticate.
      await NotificationService.instance.unregisterTokenWithBackend();

      String url = "${Env.BACKEND_URL}/user/logout";
      final response = await apiClient.post(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': "Bearer ${prefs.getString('accessToken')}",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Logout successful');
        await NotificationService.instance.deleteToken();
        SocketService.instance.disconnect();
        await prefs.remove('refreshToken');
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