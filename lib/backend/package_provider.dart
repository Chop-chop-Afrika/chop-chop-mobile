import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../env/env.dart';
import '../main.dart';
import '../utility/uiutils.dart';
import 'api_client.dart';
import 'models/package_model.dart';

class PackageProvider with ChangeNotifier {
  PackageQuote? quote;
  PackageData? packageDetail;

  /// One bucket per history tab.
  final Map<String, List<PackageData>> packages = {
    'active': <PackageData>[],
    'completed': <PackageData>[],
  };
  final Map<String, bool> loadingPackages = {'active': false, 'completed': false};
  final Map<String, bool> loadedOnce = {'active': false, 'completed': false};

  /// Id of a package booked but not yet confirmed paid. An unpaid package is
  /// absent from /user/packages/active, so without remembering it here the
  /// customer would have no way back to it after leaving the tracking screen.
  String? pendingPackageId;

  bool quoting = false;
  bool paying = false;
  bool loadingDetail = false;

  /// Price for a delivery between two points, before committing to it.
  /// Returns null on failure, having shown the error.
  Future<PackageQuote?> getQuote({
    required num pickupLatitude,
    required num pickupLongitude,
    required num dropOffLatitude,
    required num dropOffLongitude,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    quoting = true;
    notifyListeners();
    try {
      final String url = "${Env.BACKEND_URL}/user/packages/quote";
      final response = await apiClient.post(
        Uri.parse(url),
        headers: _headers(prefs),
        body: jsonEncode({
          "pickupLatitude": pickupLatitude,
          "pickupLongitude": pickupLongitude,
          "dropOffLatitude": dropOffLatitude,
          "dropOffLongitude": dropOffLongitude,
        }),
      );

      if (_ok(response.statusCode)) {
        quote = PackageQuoteModel.fromJson(jsonDecode(response.body)).data;
        return quote;
      }
      if (response.statusCode == 401) return null;
      _showError(jsonDecode(response.body));
      return null;
    } catch (error) {
      print('Package quote error: $error');
      _showNetworkError(error.toString());
      return null;
    } finally {
      quoting = false;
      notifyListeners();
    }
  }

  /// Creates the package and pays for it in one call — there is no separate
  /// create endpoint. `wallet` settles immediately; `card` comes back with a
  /// Stripe Checkout URL to open in a webview.
  Future<PackagePaymentData?> makePackagePayment({
    required String pickupAddress,
    required String dropOffAddress,
    required String senderName,
    required String senderPhone,
    required String senderEmail,
    required String receiverName,
    required String receiverPhone,
    required String receiverEmail,
    required String type,
    required String mode,
    required num pickupLatitude,
    required num pickupLongitude,
    required num dropOffLatitude,
    required num dropOffLongitude,
    required String paymentMethod,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    paying = true;
    notifyListeners();
    try {
      final String url = "${Env.BACKEND_URL}/user/packages/make-payment";
      final response = await apiClient.post(
        Uri.parse(url),
        headers: _headers(prefs),
        body: jsonEncode({
          "pickupAddress": pickupAddress,
          "dropOffAddress": dropOffAddress,
          "senderName": senderName,
          "senderPhone": senderPhone,
          "senderEmail": senderEmail,
          "receiverName": receiverName,
          "receiverPhone": receiverPhone,
          "receiverEmail": receiverEmail,
          "type": type,
          "mode": mode,
          "pickupLatitude": pickupLatitude,
          "pickupLongitude": pickupLongitude,
          "dropOffLatitude": dropOffLatitude,
          "dropOffLongitude": dropOffLongitude,
          "paymentMethod": paymentMethod,
        }),
      );

      if (_ok(response.statusCode)) {
        return PackagePaymentModel.fromJson(jsonDecode(response.body)).data;
      }
      if (response.statusCode == 401) return null;
      _showError(jsonDecode(response.body));
      return null;
    } catch (error) {
      print('Package payment error: $error');
      _showNetworkError(error.toString());
      return null;
    } finally {
      paying = false;
      notifyListeners();
    }
  }

  /// Packages have no payment-status endpoint, unlike orders, so confirmation
  /// is read off the package itself: status 1 means paid and waiting for a
  /// rider. Stripe confirms by webhook, so this polls briefly.
  Future<PackageData?> waitForPackagePayment(
    String packageId, {
    int attempts = 6,
    Duration interval = const Duration(seconds: 2),
  }) async {
    PackageData? last;
    for (int i = 0; i < attempts; i++) {
      last = await getPackageDetails(packageId, silent: true);
      if ((last?.status ?? 0) >= 1) return last;
      if (i < attempts - 1) await Future.delayed(interval);
    }
    return last;
  }

  /// [bucket] is 'active' or 'completed', matching the two history tabs.
  Future<void> getPackages(String bucket) async {
    if (loadingPackages[bucket] == true) return;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    loadingPackages[bucket] = true;
    notifyListeners();
    try {
      final String url = "${Env.BACKEND_URL}/user/packages/$bucket";
      final response = await apiClient.get(
        Uri.parse(url),
        headers: _headers(prefs),
      );

      if (_ok(response.statusCode)) {
        packages[bucket] =
            PackageListModel.fromJson(jsonDecode(response.body)).record ?? [];
      } else if (response.statusCode != 401) {
        print('Packages failed: ${response.statusCode} ${response.body}');
      }
    } catch (error) {
      print('Packages error: $error');
    } finally {
      loadedOnce[bucket] = true;
      loadingPackages[bucket] = false;
      notifyListeners();
    }
  }

  Future<PackageData?> getPackageDetails(String packageId,
      {bool silent = false}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!silent) {
      loadingDetail = true;
      notifyListeners();
    }
    try {
      final String url = "${Env.BACKEND_URL}/user/packages/$packageId";
      final response = await apiClient.get(
        Uri.parse(url),
        headers: _headers(prefs),
      );

      if (_ok(response.statusCode)) {
        final data = PackageDetailModel.fromJson(jsonDecode(response.body)).data;
        packageDetail = data;
        notifyListeners();
        return data;
      }
      if (response.statusCode != 401) {
        print('Package details failed: ${response.statusCode} ${response.body}');
      }
      return null;
    } catch (error) {
      print('Package details error: $error');
      return null;
    } finally {
      if (!silent) {
        loadingDetail = false;
        notifyListeners();
      }
    }
  }

  /// Note this is a PATCH, unlike the order cancel which is a POST.
  Future<String?> cancelPackage(String packageId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final String url = "${Env.BACKEND_URL}/user/packages/cancel/$packageId";
      final response = await apiClient.patch(
        Uri.parse(url),
        headers: _headers(prefs),
      );

      if (_ok(response.statusCode)) {
        packages['active']!.removeWhere((p) => p.id == packageId);
        notifyListeners();
        return jsonDecode(response.body)['message'] ?? 'Package canceled';
      }
      if (response.statusCode == 401) return null;
      _showError(jsonDecode(response.body));
      return null;
    } catch (error) {
      print('Cancel package error: $error');
      _showNetworkError(error.toString());
      return null;
    }
  }

  static const String _pendingKey = 'pendingPackageId';

  Future<void> rememberPendingPackage(String packageId) async {
    pendingPackageId = packageId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pendingKey, packageId);
    notifyListeners();
  }

  /// Reloads the pending package and drops it once it is paid (or gone).
  Future<PackageData?> loadPendingPackage() async {
    final prefs = await SharedPreferences.getInstance();
    pendingPackageId ??= prefs.getString(_pendingKey);
    final String? id = pendingPackageId;
    if (id == null) return null;

    final PackageData? data = await getPackageDetails(id, silent: true);
    if (data == null || (data.status ?? 0) >= 1) {
      await clearPendingPackage();
      return null;
    }
    notifyListeners();
    return data;
  }

  Future<void> clearPendingPackage() async {
    pendingPackageId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingKey);
    notifyListeners();
  }

  bool _ok(int code) => code == 200 || code == 201;

  Map<String, String> _headers(SharedPreferences prefs) => {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': "Bearer ${prefs.getString('accessToken')}",
      };

  void _showError(dynamic jsonResponse) {
    final dynamic message = jsonResponse is Map ? jsonResponse['message'] : null;
    _alert(
      'Error',
      message is List
          ? message.join('\n')
          : (message?.toString() ?? 'Something went wrong'),
    );
  }

  void _showNetworkError(String errorMessage) {
    if (errorMessage.contains('Failed host lookup')) {
      _alert('Error', 'Connection is down currently');
    } else {
      _alert('Error', 'Something went wrong');
    }
  }

  void _alert(String title, String content) {
    UiUtils.showAlertDialog(
      context: globalNavigatorKey.currentContext!,
      title: title,
      content: content,
      defaultActionText: 'close',
      onDismissed: (_) {},
    );
  }
}
