class AllAddressesModel {
  bool? status;
  String? message;
  List<AddressList>? data;

  AllAddressesModel({this.status, this.message, this.data});

  AllAddressesModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <AddressList>[];
      json['data'].forEach((v) { data!.add(new AddressList.fromJson(v)); });
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

class AddressList {
  String? id;
  String? userId;
  String? address;
  double? longitude;
  double? latitude;
  bool? defaut;
  String? createdAt;
  String? updatedAt;

  AddressList({this.id, this.userId, this.address, this.longitude, this.latitude, this.defaut, this.createdAt, this.updatedAt});

AddressList.fromJson(Map<String, dynamic> json) {
id = json['id'];
userId = json['userId'];
address = json['address'];
longitude = json['longitude'];
latitude = json['latitude'];
defaut = json['default'];
createdAt = json['createdAt'];
updatedAt = json['updatedAt'];
}

Map<String, dynamic> toJson() {
final Map<String, dynamic> data = new Map<String, dynamic>();
data['id'] = this.id;
data['userId'] = this.userId;
data['address'] = this.address;
data['longitude'] = this.longitude;
data['latitude'] = this.latitude;
data['default'] = this.defaut;
data['createdAt'] = this.createdAt;
data['updatedAt'] = this.updatedAt;
return data;
}
}
