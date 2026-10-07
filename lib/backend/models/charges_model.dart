class ChargesModel {
  bool? status;
  String? message;
  ChargesData? data;

  ChargesModel({this.status, this.message, this.data});

  ChargesModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? ChargesData.fromJson(json['data']) : null;
  }
}

class ChargesData {
  String? currency;
  num? taxRatePercent;
  num? serviceChargePercent;
  num? deliveryFee;
  PackageCharge? package;
  ChargesBreakdown? breakdown;

  ChargesData({
    this.currency,
    this.taxRatePercent,
    this.serviceChargePercent,
    this.deliveryFee,
    this.package,
    this.breakdown,
  });

  ChargesData.fromJson(Map<String, dynamic> json) {
    currency = json['currency'];
    taxRatePercent = json['taxRatePercent'];
    serviceChargePercent = json['serviceChargePercent'];
    deliveryFee = json['deliveryFee'];
    package =
        json['package'] != null ? PackageCharge.fromJson(json['package']) : null;
    breakdown = json['breakdown'] != null
        ? ChargesBreakdown.fromJson(json['breakdown'])
        : null;
  }
}

class PackageCharge {
  num? baseCharge;
  num? perKmRate;

  PackageCharge({this.baseCharge, this.perKmRate});

  PackageCharge.fromJson(Map<String, dynamic> json) {
    baseCharge = json['baseCharge'];
    perKmRate = json['perKmRate'];
  }
}

/// Only returned when `subtotal` is passed to GET /user/charges.
class ChargesBreakdown {
  num? subtotal;
  num? serviceFee;
  num? deliveryFee;
  num? total;

  ChargesBreakdown({this.subtotal, this.serviceFee, this.deliveryFee, this.total});

  ChargesBreakdown.fromJson(Map<String, dynamic> json) {
    subtotal = json['subtotal'];
    serviceFee = json['serviceFee'];
    deliveryFee = json['deliveryFee'];
    total = json['total'];
  }
}
