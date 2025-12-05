class SearchProductModel {
  bool? status;
  String? message;
  List<SearchProductData>? data;

  SearchProductModel({this.status, this.message, this.data});

  SearchProductModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <SearchProductData>[];
      json['data'].forEach((v) {
        data!.add(new SearchProductData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SearchProductData {
  String? id;
  String? productCategoryId;
  String? storeId;
  String? name;
  double? price;
  String? description;
  String? banner;
  String? status;
  String? createdAt;
  String? updatedAt;
  Stores? stores;
  ProductCategory? productCategory;
  List<Variants>? variants;

  SearchProductData(
      {this.id,
        this.productCategoryId,
        this.storeId,
        this.name,
        this.price,
        this.description,
        this.banner,
        this.status,
        this.createdAt,
        this.updatedAt,
        this.stores,
        this.productCategory,
        this.variants});

  SearchProductData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productCategoryId = json['productCategoryId'];
    storeId = json['storeId'];
    name = json['name'];
    price = json['price'];
    description = json['description'];
    banner = json['banner'];
    status = json['status'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    stores =
    json['Stores'] != null ? new Stores.fromJson(json['Stores']) : null;
    productCategory = json['ProductCategory'] != null
        ? new ProductCategory.fromJson(json['ProductCategory'])
        : null;
    if (json['variants'] != null) {
      variants = <Variants>[];
      json['variants'].forEach((v) {
        variants!.add(new Variants.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['productCategoryId'] = this.productCategoryId;
    data['storeId'] = this.storeId;
    data['name'] = this.name;
    data['price'] = this.price;
    data['description'] = this.description;
    data['banner'] = this.banner;
    data['status'] = this.status;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    if (this.stores != null) {
      data['Stores'] = this.stores!.toJson();
    }
    if (this.productCategory != null) {
      data['ProductCategory'] = this.productCategory!.toJson();
    }
    if (this.variants != null) {
      data['variants'] = this.variants!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Stores {
  String? id;
  String? userId;
  String? name;
  String? email;
  String? phone;
  String? logo;
  String? location;
  double? longitude;
  double? latitude;
  String? deliveryTime;
  String? openTime;
  String? closeTime;
  String? type;
  String? createdAt;
  String? updatedAt;
  int? status;

  Stores(
      {this.id,
        this.userId,
        this.name,
        this.email,
        this.phone,
        this.logo,
        this.location,
        this.longitude,
        this.latitude,
        this.deliveryTime,
        this.openTime,
        this.closeTime,
        this.type,
        this.createdAt,
        this.updatedAt,
        this.status});

  Stores.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    logo = json['logo'];
    location = json['location'];
    longitude = json['longitude'];
    latitude = json['latitude'];
    deliveryTime = json['delivery_time'];
    openTime = json['open_time'];
    closeTime = json['close_time'];
    type = json['type'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['userId'] = this.userId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['logo'] = this.logo;
    data['location'] = this.location;
    data['longitude'] = this.longitude;
    data['latitude'] = this.latitude;
    data['delivery_time'] = this.deliveryTime;
    data['open_time'] = this.openTime;
    data['close_time'] = this.closeTime;
    data['type'] = this.type;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['status'] = this.status;
    return data;
  }
}

class ProductCategory {
  String? id;
  String? name;
  String? icon;
  String? createdAt;
  String? updatedAt;

  ProductCategory(
      {this.id, this.name, this.icon, this.createdAt, this.updatedAt});

  ProductCategory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    icon = json['icon'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['icon'] = this.icon;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}

class Variants {
  String? id;
  String? productId;
  String? type;
  String? size;
  double? price;
  int? availableQty;
  int? stockQty;
  String? createdAt;
  String? updatedAt;

  Variants(
      {this.id,
        this.productId,
        this.type,
        this.size,
        this.price,
        this.availableQty,
        this.stockQty,
        this.createdAt,
        this.updatedAt});

  Variants.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['productId'];
    type = json['type'];
    size = json['size'];
    price = json['price'];
    availableQty = json['availableQty'];
    stockQty = json['stockQty'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['productId'] = this.productId;
    data['type'] = this.type;
    data['size'] = this.size;
    data['price'] = this.price;
    data['availableQty'] = this.availableQty;
    data['stockQty'] = this.stockQty;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}
