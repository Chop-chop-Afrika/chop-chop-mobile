class AddToCartModel {
  bool? status;
  String? message;
  Data? data;

  AddToCartModel({this.status, this.message, this.data});

  AddToCartModel.fromJson(Map<String, dynamic> json) {
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
  double? itemPrice;
  double? totalPrice;

  Data({this.itemPrice, this.totalPrice});

  Data.fromJson(Map<String, dynamic> json) {
    itemPrice = json['itemPrice'];
    totalPrice = json['totalPrice'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['itemPrice'] = this.itemPrice;
    data['totalPrice'] = this.totalPrice;
    return data;
  }
}
