class SupportInfoModel {
  bool? status;
  String? message;
  Data? data;

  SupportInfoModel({this.status, this.message, this.data});

  SupportInfoModel.fromJson(Map<String, dynamic> json) {
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
  String? responseTime;
  bool? available;
  List<String>? categories;

  Data({this.responseTime, this.available, this.categories});

  Data.fromJson(Map<String, dynamic> json) {
    responseTime = json['responseTime'];
    available = json['available'];
    categories = json['categories'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['responseTime'] = this.responseTime;
    data['available'] = this.available;
    data['categories'] = this.categories;
    return data;
  }
}
