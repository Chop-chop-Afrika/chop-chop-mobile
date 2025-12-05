class GetCartModel {
  bool? status;
  String? message;
  Data? data;

  GetCartModel({this.status, this.message, this.data});

  GetCartModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  List<Carts>? carts;
  double? grandTotal;
  int? itemCount;

  Data({this.carts, this.grandTotal, this.itemCount});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['carts'] != null) {
      carts = <Carts>[];
      json['carts'].forEach((v) {
        carts!.add(new Carts.fromJson(v));
      });
    }
    grandTotal = json['grandTotal'];
    itemCount = json['itemCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.carts != null) {
      data['carts'] = this.carts!.map((v) => v.toJson()).toList();
    }
    data['grandTotal'] = this.grandTotal;
    data['itemCount'] = this.itemCount;
    return data;
  }
}

class Carts {
  String? orderId;
  Store? store;
  List<CartItems>? items;
  double? subtotal;

  Carts({this.orderId, this.store, this.items, this.subtotal});

  Carts.fromJson(Map<String, dynamic> json) {
    orderId = json['orderId'];
    store = json['store'] != null ? new Store.fromJson(json['store']) : null;
    if (json['items'] != null) {
      items = <CartItems>[];
      json['items'].forEach((v) {
        items!.add(new CartItems.fromJson(v));
      });
    }
    subtotal = json['subtotal'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['orderId'] = this.orderId;
    if (this.store != null) {
      data['store'] = this.store!.toJson();
    }
    if (this.items != null) {
      data['items'] = this.items!.map((v) => v.toJson()).toList();
    }
    data['subtotal'] = this.subtotal;
    return data;
  }
}

class Store {
  String? id;
  String? name;
  String? logo;
  String? location;
  String? deliveryTime;

  Store({this.id, this.name, this.logo, this.location, this.deliveryTime});

  Store.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    logo = json['logo'];
    location = json['location'];
    deliveryTime = json['delivery_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['logo'] = this.logo;
    data['location'] = this.location;
    data['delivery_time'] = this.deliveryTime;
    return data;
  }
}

class CartItems {
  String? id;
  Product? product;
  dynamic variant;
  int? quantity;
  double? unitPrice;
  double? totalPrice;
  int? isSelected = 0;

  CartItems(
      {this.id,
        this.product,
        this.variant,
        this.quantity,
        this.unitPrice,
        this.totalPrice,
       this.isSelected = 0});

  CartItems.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    product =
    json['product'] != null ? new Product.fromJson(json['product']) : null;
    variant = json['variant'];
    quantity = json['quantity'];
    unitPrice = json['unitPrice'];
    totalPrice = json['totalPrice'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.product != null) {
      data['product'] = this.product!.toJson();
    }
    data['variant'] = this.variant;
    data['quantity'] = this.quantity;
    data['unitPrice'] = this.unitPrice;
    data['totalPrice'] = this.totalPrice;
    return data;
  }
}

class Product {
  String? id;
  String? name;
  String? description;
  String? banner;

  Product({this.id, this.name, this.description, this.banner});

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    banner = json['banner'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['banner'] = this.banner;
    return data;
  }
}
