class OrderDetailModel {
  bool? status;
  String? message;
  OrderDetailData? data;

  OrderDetailModel({this.status, this.message, this.data});

  OrderDetailModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data =
        json['data'] != null ? OrderDetailData.fromJson(json['data']) : null;
  }
}

class OrderDetailData {
  String? id;
  String? storeId;

  /// 1 paid · 2 vendor confirmed · 3 rider accepted · 4 in transit
  /// 5 arrived · 6 completed · 7 canceled · 8 delivery failed
  int? status;
  String? statusText;

  /// Short human-facing order reference, e.g. AB12CD34.
  String? code;

  /// 4-digit PIN the customer shows the rider on delivery.
  String? deliveryConfirmationCode;
  String? deliveryAddress;
  num? total;
  num? subtotal;
  num? deliveryFee;
  num? serviceFee;
  String? paymentMethod;
  String? createdAt;
  OrderStore? stores;
  OrderRider? rider;
  List<OrderCartItem>? cart;
  num? storeRating;

  OrderDetailData({
    this.id,
    this.storeId,
    this.status,
    this.statusText,
    this.code,
    this.deliveryConfirmationCode,
    this.deliveryAddress,
    this.total,
    this.subtotal,
    this.deliveryFee,
    this.serviceFee,
    this.paymentMethod,
    this.createdAt,
    this.stores,
    this.rider,
    this.cart,
    this.storeRating,
  });

  OrderDetailData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    storeId = json['storeId'];
    status = json['status'];
    statusText = json['statusText'];
    code = json['code'];
    deliveryConfirmationCode = json['deliveryConfirmationCode'];
    deliveryAddress = json['deliveryAddress'];
    total = json['total'];
    subtotal = json['subtotal'];
    deliveryFee = json['deliveryFee'];
    serviceFee = json['serviceFee'];
    paymentMethod = json['paymentMethod'];
    createdAt = json['createdAt'];
    stores = json['Stores'] != null ? OrderStore.fromJson(json['Stores']) : null;
    rider = json['Rider'] != null ? OrderRider.fromJson(json['Rider']) : null;
    if (json['Cart'] != null) {
      cart = <OrderCartItem>[];
      json['Cart'].forEach((v) {
        cart!.add(OrderCartItem.fromJson(v));
      });
    }
    // StoreRating is null until the customer rates the order. The API returns
    // it either as a bare number or as an object holding one.
    final dynamic rating = json['StoreRating'];
    if (rating is num) {
      storeRating = rating;
    } else if (rating is Map && rating['rating'] is num) {
      storeRating = rating['rating'];
    }
  }

  bool get hasRider => rider?.phone != null && rider!.phone!.isNotEmpty;

  String get riderName =>
      '${rider?.firstName ?? ''} ${rider?.lastName ?? ''}'.trim();
}

class OrderStore {
  String? id;
  String? name;
  String? logo;
  String? phone;
  String? location;
  String? deliveryTime;

  OrderStore({
    this.id,
    this.name,
    this.logo,
    this.phone,
    this.location,
    this.deliveryTime,
  });

  OrderStore.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    logo = json['logo'];
    phone = json['phone'];
    location = json['location'];
    deliveryTime = json['delivery_time'];
  }
}

class OrderRider {
  String? firstName;
  String? lastName;
  String? phone;
  String? avatar;

  OrderRider({this.firstName, this.lastName, this.phone, this.avatar});

  OrderRider.fromJson(Map<String, dynamic> json) {
    firstName = json['firstName'];
    lastName = json['lastName'];
    phone = json['phone'];
    avatar = json['avatar'];
  }
}

class OrderCartItem {
  String? id;
  String? productId;
  String? name;
  String? banner;
  int? quantity;
  num? unitPrice;

  OrderCartItem({
    this.id,
    this.productId,
    this.name,
    this.banner,
    this.quantity,
    this.unitPrice,
  });

  OrderCartItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['productId'];
    quantity = json['quantity'];
    // The product is nested under `Product` on orders and `product` on the
    // cart endpoint; the price lives on the product, not the line item.
    final dynamic product = json['Product'] ?? json['product'];
    if (product is Map) {
      name = product['name'];
      banner = product['banner'];
      unitPrice = product['price'];
    } else {
      name = json['name'];
      banner = json['banner'];
      unitPrice = json['unitPrice'];
    }
    unitPrice ??= json['unitPrice'];
  }

  num get lineTotal => (unitPrice ?? 0) * (quantity ?? 0);
}

/// One page of GET /user/orders. `status` there is `ongoing` or `completed`.
class OrderListModel {
  bool? status;
  String? message;
  OrderListData? data;

  OrderListModel({this.status, this.message, this.data});

  OrderListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? OrderListData.fromJson(json['data']) : null;
  }
}

class OrderListData {
  List<OrderDetailData>? record;
  int? currentPage;
  int? totalPages;
  bool? hasNextPage;
  bool? hasPrevPage;
  int? nextPage;
  int? prevPage;

  OrderListData({
    this.record,
    this.currentPage,
    this.totalPages,
    this.hasNextPage,
    this.hasPrevPage,
    this.nextPage,
    this.prevPage,
  });

  OrderListData.fromJson(Map<String, dynamic> json) {
    if (json['record'] != null) {
      record = <OrderDetailData>[];
      json['record'].forEach((v) {
        record!.add(OrderDetailData.fromJson(v));
      });
    }
    currentPage = json['currentPage'];
    totalPages = (json['totalPages'] as num?)?.toInt();
    hasNextPage = json['hasNextPage'];
    hasPrevPage = json['hasPrevPage'];
    nextPage = json['nextPage'];
    prevPage = json['prevPage'];
  }
}
