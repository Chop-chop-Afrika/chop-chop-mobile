class StoreDetailModel {
  bool? status;
  String? message;
  Data? data;

  StoreDetailModel({this.status, this.message, this.data});

  StoreDetailModel.fromJson(Map<String, dynamic> json) {
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
  int? currentPage;
  int? totalPages;
  bool? hasNextPage;
  bool? hasPrevPage;
  int? nextPage;
  int? prevPage;
  List<StoreDetailRecord>? record;

  Data(
      {this.currentPage,
        this.totalPages,
        this.hasNextPage,
        this.hasPrevPage,
        this.nextPage,
        this.prevPage,
        this.record});

  Data.fromJson(Map<String, dynamic> json) {
    currentPage = json['currentPage'];
    totalPages = (json['totalPages'] as num?)?.toInt();
    hasNextPage = json['hasNextPage'];
    hasPrevPage = json['hasPrevPage'];
    nextPage = json['nextPage'];
    prevPage = json['prevPage'];
    if (json['record'] != null) {
      record = <StoreDetailRecord>[];
      json['record'].forEach((v) {
        record!.add(new StoreDetailRecord.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['currentPage'] = this.currentPage;
    data['totalPages'] = this.totalPages;
    data['hasNextPage'] = this.hasNextPage;
    data['hasPrevPage'] = this.hasPrevPage;
    data['nextPage'] = this.nextPage;
    data['prevPage'] = this.prevPage;
    if (this.record != null) {
      data['record'] = this.record!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class StoreDetailRecord {
  String? id;
  String? productCategoryId;
  String? storeId;
  String? name;
  dynamic price;
  String? description;
  String? banner;
  String? status;
  String? createdAt;
  String? updatedAt;
  ProductCategory? productCategory;
  List<Variants>? variants;

  StoreDetailRecord(
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
        this.productCategory,
        this.variants});

  StoreDetailRecord.fromJson(Map<String, dynamic> json) {
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
    if (this.productCategory != null) {
      data['ProductCategory'] = this.productCategory!.toJson();
    }
    if (this.variants != null) {
      data['variants'] = this.variants!.map((v) => v.toJson()).toList();
    }
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
  dynamic price;
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
