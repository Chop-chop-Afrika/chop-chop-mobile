/// POST /user/packages/quote — the delivery price before paying.
class PackageQuoteModel {
  bool? status;
  String? message;
  PackageQuote? data;

  PackageQuoteModel({this.status, this.message, this.data});

  PackageQuoteModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? PackageQuote.fromJson(json['data']) : null;
  }
}

class PackageQuote {
  String? currency;
  num? distanceKm;
  num? baseCharge;
  num? distanceCharge;
  num? serviceFee;
  num? total;

  PackageQuote({
    this.currency,
    this.distanceKm,
    this.baseCharge,
    this.distanceCharge,
    this.serviceFee,
    this.total,
  });

  PackageQuote.fromJson(Map<String, dynamic> json) {
    currency = json['currency'];
    distanceKm = json['distanceKm'];
    baseCharge = json['baseCharge'];
    distanceCharge = json['distanceCharge'];
    serviceFee = json['serviceFee'];
    total = json['total'];
  }
}

/// POST /user/packages/make-payment — creates the package and pays for it.
/// Mirrors the order flow: `wallet` settles immediately, `card` returns a
/// Stripe Checkout URL to open in a webview.
class PackagePaymentModel {
  bool? status;
  String? message;
  PackagePaymentData? data;

  PackagePaymentModel({this.status, this.message, this.data});

  PackagePaymentModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data =
        json['data'] != null ? PackagePaymentData.fromJson(json['data']) : null;
  }
}

class PackagePaymentData {
  String? packageId;
  num? total;
  String? paymentMethod;
  String? paymentStatus;
  String? checkoutUrl;
  String? sessionId;
  String? expiresAt;

  PackagePaymentData({
    this.packageId,
    this.total,
    this.paymentMethod,
    this.paymentStatus,
    this.checkoutUrl,
    this.sessionId,
    this.expiresAt,
  });

  PackagePaymentData.fromJson(Map<String, dynamic> json) {
    packageId = json['packageId'];
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

/// One package, as returned by GET /user/packages, /active, /completed and
/// /user/packages/{id}.
class PackageData {
  String? id;
  String? userId;
  String? riderId;
  String? code;
  String? pickupAddress;
  String? dropOffAddress;
  String? senderName;
  String? senderPhone;
  String? receiverName;
  String? receiverPhone;
  String? type;
  String? mode;

  /// 1 paid, waiting for a rider · 2 rider accepted / in transit
  /// 3 delivered · 4 canceled · 5 delivery failed
  int? status;
  String? statusText;
  num? total;
  num? deliveryFee;
  String? deliveryConfirmationCode;
  num? pickupLatitude;
  num? pickupLongitude;
  num? dropOffLatitude;
  num? dropOffLongitude;
  String? createdAt;
  PackageRider? rider;

  PackageData({this.id, this.status, this.createdAt});

  PackageData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    riderId = json['riderId'];
    code = json['code'];
    pickupAddress = json['pickupAddress'];
    dropOffAddress = json['dropOffAddress'];
    senderName = json['senderName'];
    senderPhone = json['senderPhone'];
    receiverName = json['receiverName'];
    receiverPhone = json['receiverPhone'];
    type = json['type'];
    mode = json['mode'];
    status = json['status'];
    statusText = json['statusText'];
    total = json['total'];
    deliveryFee = json['deliveryFee'] ?? json['fee'];
    deliveryConfirmationCode = json['deliveryConfirmationCode'];
    pickupLatitude = json['pickupLatitude'];
    pickupLongitude = json['pickupLongitude'];
    dropOffLatitude = json['dropOffLatitude'];
    dropOffLongitude = json['dropOffLongitude'];
    createdAt = json['createdAt'];
    final dynamic r = json['Rider'] ?? json['rider'];
    if (r is Map) rider = PackageRider.fromJson(Map<String, dynamic>.from(r));
  }

  bool get hasRider => rider?.phone != null && rider!.phone!.isNotEmpty;

  String get riderName =>
      '${rider?.firstName ?? ''} ${rider?.lastName ?? ''}'.trim();

  /// Only worth offering a cancel before a rider is carrying it.
  bool get isCancellable => (status ?? 0) <= 1;
}

class PackageRider {
  String? firstName;
  String? lastName;
  String? phone;
  String? avatar;

  PackageRider({this.firstName, this.lastName, this.phone, this.avatar});

  PackageRider.fromJson(Map<String, dynamic> json) {
    firstName = json['firstName'];
    lastName = json['lastName'];
    phone = json['phone'];
    avatar = json['avatar'];
  }
}

/// GET /user/packages/{id}
class PackageDetailModel {
  bool? status;
  String? message;
  PackageData? data;

  PackageDetailModel({this.status, this.message, this.data});

  PackageDetailModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? PackageData.fromJson(json['data']) : null;
  }
}

/// GET /user/packages (paginated) and /active and /completed, which return a
/// bare list rather than a page.
class PackageListModel {
  bool? status;
  String? message;
  List<PackageData>? record;
  int? currentPage;
  int? totalPages;
  bool? hasNextPage;

  PackageListModel({this.status, this.message, this.record});

  PackageListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    final dynamic data = json['data'];
    if (data is List) {
      // /active and /completed return the list directly.
      record = data
          .map((v) => PackageData.fromJson(Map<String, dynamic>.from(v)))
          .toList();
      hasNextPage = false;
    } else if (data is Map) {
      final dynamic rows = data['record'];
      if (rows is List) {
        record = rows
            .map((v) => PackageData.fromJson(Map<String, dynamic>.from(v)))
            .toList();
      }
      currentPage = data['currentPage'];
      totalPages = (data['totalPages'] as num?)?.toInt();
      hasNextPage = data['hasNextPage'] ?? false;
    }
  }
}
