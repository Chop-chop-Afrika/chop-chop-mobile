import 'dart:convert';

import 'package:flutter/material.dart';
import 'api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../env/env.dart';
import '../main.dart';
import '../utility/uiutils.dart';
import 'models/charges_model.dart';
import 'models/make_payment_model.dart';
import 'models/order_detail_model.dart';
import 'models/wallet_transaction_model.dart';

class OrderProvider with ChangeNotifier {
  ChargesData? charges;
  num? walletBalance;
  final List<WalletTransaction> walletTransactions = [];
  int _txPage = 1;
  bool txHasMore = false;
  bool loadingTransactions = false;
  bool txLoadedOnce = false;
  OrderDetailData? orderDetail;

  /// One bucket per tab, keyed by the API's `status` values.
  final Map<String, List<OrderDetailData>> orders = {
    'ongoing': <OrderDetailData>[],
    'completed': <OrderDetailData>[],
  };
  final Map<String, int> _page = {'ongoing': 1, 'completed': 1};
  final Map<String, bool> hasMore = {'ongoing': false, 'completed': false};
  final Map<String, bool> loadingOrders = {'ongoing': false, 'completed': false};

  /// True once a tab has loaded at least once, so the UI can tell "still
  /// loading" apart from "genuinely no orders".
  final Map<String, bool> loadedOnce = {'ongoing': false, 'completed': false};

  bool paying = false;
  bool loadingDetail = false;

  /// Platform fees. Passing [subtotal] makes the API return a `breakdown`
  /// with the exact serviceFee, deliveryFee and total for that basket, so the
  /// checkout summary never has to compute the fees itself.
  Future<ChargesData?> getCharges({num? subtotal}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final String query = subtotal != null ? '?subtotal=$subtotal' : '';
      final String url = "${Env.BACKEND_URL}/user/charges$query";
      final response = await apiClient.get(
        Uri.parse(url),
        headers: _headers(prefs),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = ChargesModel.fromJson(jsonDecode(response.body)).data;
        charges = data;
        notifyListeners();
        return data;
      }
      if (_handleExpiredToken(response.statusCode, prefs)) return null;
      print('Charges failed: ${response.statusCode} ${response.body}');
      return null;
    } catch (error) {
      print('Charges error: $error');
      return null;
    }
  }

  Future<num?> getWalletBalance() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final String url = "${Env.BACKEND_URL}/user/profile/wallet";
      final response = await apiClient.get(
        Uri.parse(url),
        headers: _headers(prefs),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic body = jsonDecode(response.body);
        walletBalance = body['data']?['balance'];
        notifyListeners();
        return walletBalance;
      }
      if (_handleExpiredToken(response.statusCode, prefs)) return null;
      print('Wallet failed: ${response.statusCode} ${response.body}');
      return null;
    } catch (error) {
      print('Wallet error: $error');
      return null;
    }
  }

  /// Pays for the cart (the pending order). [paymentMethod] is `wallet`, which
  /// settles immediately, or `card`, which returns a Stripe Checkout URL to
  /// open in a webview. Returns null on failure, having shown the error.
  Future<MakePaymentData?> makePayment({
    required String orderId,
    required String addressId,
    required String paymentMethod,
    String? deliveryTime,
    String? note,
    String? scheduledDate,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    paying = true;
    notifyListeners();
    try {
      final String url = "${Env.BACKEND_URL}/user/orders/make-payment";
      final response = await apiClient.post(
        Uri.parse(url),
        headers: _headers(prefs),
        body: jsonEncode({
          "orderId": orderId,
          "addressId": addressId,
          "paymentMethod": paymentMethod,
          if (deliveryTime != null && deliveryTime.isNotEmpty)
            "deliveryTime": deliveryTime,
          if (note != null && note.isNotEmpty) "note": note,
          if (scheduledDate != null && scheduledDate.isNotEmpty)
            "scheduledDate": scheduledDate,
        }),
      );


      if (response.statusCode == 200 || response.statusCode == 201) {
        return MakePaymentModel.fromJson(jsonDecode(response.body)).data;
      }
      if (_handleExpiredToken(response.statusCode, prefs)) return null;
      _showError(jsonDecode(response.body));
      return null;
    } catch (error) {
      print('Make payment error: $error');
      _showNetworkError(error.toString());
      return null;
    } finally {
      paying = false;
      notifyListeners();
    }
  }

  /// Whether a card payment actually went through. Called when the Stripe
  /// webview closes, since the browser redirect alone does not prove payment.
  Future<PaymentStatusData?> getPaymentStatus(String orderId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final String url = "${Env.BACKEND_URL}/user/orders/$orderId/payment-status";
      final response = await apiClient.get(
        Uri.parse(url),
        headers: _headers(prefs),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return PaymentStatusModel.fromJson(jsonDecode(response.body)).data;
      }
      if (_handleExpiredToken(response.statusCode, prefs)) return null;
      print('Payment status failed: ${response.statusCode} ${response.body}');
      return null;
    } catch (error) {
      print('Payment status error: $error');
      return null;
    }
  }

  /// Stripe confirms payment to the backend by webhook, which can land a
  /// moment after the webview closes. Polls briefly rather than deciding the
  /// payment failed on the first `pending`.
  Future<PaymentStatusData?> waitForPayment(
    String orderId, {
    int attempts = 6,
    Duration interval = const Duration(seconds: 2),
  }) async {
    PaymentStatusData? last;
    for (int i = 0; i < attempts; i++) {
      last = await getPaymentStatus(orderId);
      if (last?.isPaid == true) return last;
      if (i < attempts - 1) await Future.delayed(interval);
    }
    return last;
  }

  Future<OrderDetailData?> getOrderDetails(String orderId,
      {bool silent = false}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!silent) {
      loadingDetail = true;
      notifyListeners();
    }
    try {
      final String url = "${Env.BACKEND_URL}/user/orders/$orderId";
      final response = await apiClient.get(
        Uri.parse(url),
        headers: _headers(prefs),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = OrderDetailModel.fromJson(jsonDecode(response.body)).data;
        orderDetail = data;
        notifyListeners();
        return data;
      }
      if (_handleExpiredToken(response.statusCode, prefs)) return null;
      print('Order details failed: ${response.statusCode} ${response.body}');
      return null;
    } catch (error) {
      print('Order details error: $error');
      return null;
    } finally {
      if (!silent) {
        loadingDetail = false;
        notifyListeners();
      }
    }
  }

  /// Fetches a page of orders for a tab. [status] is 'ongoing' or 'completed'.
  /// Pass refresh: true to start again at page 1, otherwise the next page is
  /// appended for infinite scroll.
  Future<void> getOrders(String status, {bool refresh = false}) async {
    if (loadingOrders[status] == true) return;
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (refresh) _page[status] = 1;
    final int page = _page[status]!;

    loadingOrders[status] = true;
    notifyListeners();
    try {
      final String url =
          "${Env.BACKEND_URL}/user/orders?status=$status&page=$page&pageSize=10";
      final response = await apiClient.get(
        Uri.parse(url),
        headers: _headers(prefs),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = OrderListModel.fromJson(jsonDecode(response.body)).data;
        final List<OrderDetailData> fetched = data?.record ?? [];
        if (refresh || page == 1) {
          orders[status] = fetched;
        } else {
          orders[status]!.addAll(fetched);
        }
        hasMore[status] = data?.hasNextPage ?? false;
        if (hasMore[status] == true) _page[status] = page + 1;
        loadedOnce[status] = true;
        return;
      }
      if (_handleExpiredToken(response.statusCode, prefs)) return;
      print('Orders failed: ${response.statusCode} ${response.body}');
      loadedOnce[status] = true;
    } catch (error) {
      print('Orders error: $error');
      loadedOnce[status] = true;
    } finally {
      loadingOrders[status] = false;
      notifyListeners();
    }
  }

  /// Cancels an order; the backend refunds to the wallet. Returns the message
  /// to show, or null if it failed.
  Future<String?> cancelOrder(String orderId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final String url = "${Env.BACKEND_URL}/user/orders/$orderId/cancel";
      final response = await apiClient.post(
        Uri.parse(url),
        headers: _headers(prefs),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        // Drop it from the ongoing tab straight away rather than refetching.
        orders['ongoing']!.removeWhere((o) => o.id == orderId);
        notifyListeners();
        return body['message'] ?? 'Order canceled';
      }
      if (_handleExpiredToken(response.statusCode, prefs)) return null;
      _showError(jsonDecode(response.body));
      return null;
    } catch (error) {
      print('Cancel order error: $error');
      _showNetworkError(error.toString());
      return null;
    }
  }

  /// Rates the store an order came from. [rating] is 1–5.
  Future<bool> rateOrder(String orderId, num rating) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final String url = "${Env.BACKEND_URL}/user/orders/$orderId/rate";
      final response = await apiClient.post(
        Uri.parse(url),
        headers: _headers(prefs),
        body: jsonEncode({"rating": rating}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        orderDetail?.storeRating = rating;
        notifyListeners();
        return true;
      }
      if (_handleExpiredToken(response.statusCode, prefs)) return false;
      _showError(jsonDecode(response.body));
      return false;
    } catch (error) {
      print('Rate order error: $error');
      _showNetworkError(error.toString());
      return false;
    }
  }

  /// Wallet ledger, newest first. Pass refresh: true to start from page 1.
  Future<void> getWalletTransactions({bool refresh = false}) async {
    if (loadingTransactions) return;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (refresh) _txPage = 1;
    final int page = _txPage;

    loadingTransactions = true;
    notifyListeners();
    try {
      final String url =
          "${Env.BACKEND_URL}/user/wallet/transactions?page=$page&pageSize=20";
      final response = await apiClient.get(
        Uri.parse(url),
        headers: _headers(prefs),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data =
            WalletTransactionModel.fromJson(jsonDecode(response.body)).data;
        final fetched = data?.record ?? [];
        if (refresh || page == 1) {
          walletTransactions
            ..clear()
            ..addAll(fetched);
        } else {
          walletTransactions.addAll(fetched);
        }
        txHasMore = data?.hasNextPage ?? false;
        if (txHasMore) _txPage = page + 1;
      } else if (response.statusCode != 401) {
        print('Wallet transactions failed: ${response.statusCode} ${response.body}');
      }
    } catch (error) {
      print('Wallet transactions error: $error');
    } finally {
      txLoadedOnce = true;
      loadingTransactions = false;
      notifyListeners();
    }
  }

  /// Permanently deletes the account. Returns the server message on success.
  Future<String?> deleteAccount() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final String url = "${Env.BACKEND_URL}/user/profile/delete-account";
      final response = await apiClient.delete(
        Uri.parse(url),
        headers: _headers(prefs),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body)['message'] ?? 'Account deleted';
      }
      if (response.statusCode == 401) return null;
      _showError(jsonDecode(response.body));
      return null;
    } catch (error) {
      print('Delete account error: $error');
      _showNetworkError(error.toString());
      return null;
    }
  }

  Map<String, String> _headers(SharedPreferences prefs) => {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': "Bearer ${prefs.getString('accessToken')}",
      };

  /// True when the call failed because the session expired. The redirect is
  /// handled centrally by apiClient.onUnauthorized; this only tells the caller
  /// to stop and not show its own error on top.
  bool _handleExpiredToken(int statusCode, SharedPreferences prefs) =>
      statusCode == 401;

  /// Validation failures come back as a list of messages, plain errors as a
  /// string, so handle both rather than assuming one shape.
  void _showError(dynamic jsonResponse) {
    final dynamic message = jsonResponse is Map ? jsonResponse['message'] : null;
    _alert(
      'Error',
      message is List
          ? message.join('\n')
          : (message?.toString() ?? 'Payment could not be completed'),
    );
  }

  void _showNetworkError(String errorMessage) {
    if (errorMessage.contains('Failed host lookup')) {
      _alert('Error', 'Connection is down currently');
    } else if (errorMessage.contains('DOCTYPE HTML') ||
        errorMessage.contains('Connection reset by peer')) {
      _alert('Error', 'Something went wrong');
    } else {
      _alert('Error', errorMessage);
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
