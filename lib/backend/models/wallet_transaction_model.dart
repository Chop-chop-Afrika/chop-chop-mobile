/// GET /user/wallet/transactions — paginated wallet ledger.
class WalletTransactionModel {
  bool? status;
  String? message;
  WalletTransactionData? data;

  WalletTransactionModel({this.status, this.message, this.data});

  WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null
        ? WalletTransactionData.fromJson(json['data'])
        : null;
  }
}

class WalletTransactionData {
  List<WalletTransaction>? record;
  int? currentPage;
  int? totalPages;
  bool? hasNextPage;

  WalletTransactionData({this.record, this.currentPage, this.hasNextPage});

  WalletTransactionData.fromJson(Map<String, dynamic> json) {
    if (json['record'] != null) {
      record = (json['record'] as List)
          .map((v) => WalletTransaction.fromJson(Map<String, dynamic>.from(v)))
          .toList();
    }
    currentPage = json['currentPage'];
    totalPages = (json['totalPages'] as num?)?.toInt();
    hasNextPage = json['hasNextPage'] ?? false;
  }
}

class WalletTransaction {
  String? id;
  String? orderId;
  String? packageId;

  /// e.g. charge, wallet_debit, wallet_credit, refund
  String? type;

  /// e.g. pending, succeeded, failed
  String? status;
  num? amount;
  String? currency;
  String? createdAt;

  WalletTransaction({this.id, this.type, this.status, this.amount});

  WalletTransaction.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['orderId'];
    packageId = json['packageId'];
    type = json['type'];
    status = json['status'];
    amount = json['amount'];
    currency = json['currency'];
    createdAt = json['createdAt'];
  }

  /// Money leaving the wallet, for the +/- sign and colour.
  bool get isDebit =>
      type == 'charge' || type == 'wallet_debit' || type == 'withdrawal';

  bool get isPending => status == 'pending';

  bool get isFailed => status == 'failed' || status == 'canceled';

  /// What the transaction relates to, for the row subtitle.
  String get subject {
    if (orderId != null) return 'Order payment';
    if (packageId != null) return 'Delivery payment';
    return type?.replaceAll('_', ' ') ?? 'Transaction';
  }
}
