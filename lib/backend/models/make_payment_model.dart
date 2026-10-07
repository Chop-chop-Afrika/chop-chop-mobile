class MakePaymentModel {
  bool? status;
  String? message;
  MakePaymentData? data;

  MakePaymentModel({this.status, this.message, this.data});

  MakePaymentModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data =
        json['data'] != null ? MakePaymentData.fromJson(json['data']) : null;
  }
}

class MakePaymentData {
  String? orderId;
  num? total;
  String? paymentMethod;
  String? paymentStatus;

  /// Stripe Checkout URL. Only present for `card` payments — a `wallet`
  /// payment is already settled when the response comes back.
  String? checkoutUrl;
  String? sessionId;
  String? expiresAt;

  MakePaymentData({
    this.orderId,
    this.total,
    this.paymentMethod,
    this.paymentStatus,
    this.checkoutUrl,
    this.sessionId,
    this.expiresAt,
  });

  MakePaymentData.fromJson(Map<String, dynamic> json) {
    orderId = json['orderId'];
    total = json['total'];
    paymentMethod = json['paymentMethod'];
    paymentStatus = json['paymentStatus'];
    checkoutUrl = json['checkoutUrl'];
    sessionId = json['sessionId'];
    expiresAt = json['expiresAt'];
  }

  bool get needsCardCheckout =>
      checkoutUrl != null && checkoutUrl!.isNotEmpty;
}

class PaymentStatusModel {
  bool? status;
  String? message;
  PaymentStatusData? data;

  PaymentStatusModel({this.status, this.message, this.data});

  PaymentStatusModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data =
        json['data'] != null ? PaymentStatusData.fromJson(json['data']) : null;
  }
}

class PaymentStatusData {
  String? orderId;
  String? paymentStatus;
  int? orderStatus;
  String? code;

  PaymentStatusData({
    this.orderId,
    this.paymentStatus,
    this.orderStatus,
    this.code,
  });

  PaymentStatusData.fromJson(Map<String, dynamic> json) {
    orderId = json['orderId'];
    paymentStatus = json['paymentStatus'];
    orderStatus = json['orderStatus'];
    code = json['code'];
  }

  bool get isPaid => paymentStatus == 'paid';
}
