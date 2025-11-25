class SendAndReceivePackageModel {
  bool? status;
  String? message;
  Data? data;

  SendAndReceivePackageModel({this.status, this.message, this.data});

  SendAndReceivePackageModel.fromJson(Map<String, dynamic> json) {
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
  String? id;
  String? userId;
  String? pickupAddress;
  String? dropOffAddress;
  String? senderName;
  String? senderPhone;
  String? senderEmail;
  String? receiverName;
  String? receiverPhone;
  String? receiverEmail;
  String? type;
  String? mode;
  double? pickupLongitude;
  double? pickupLatitude;
  double? dropOffLongitude;
  double? dropOffLatitude;
  int? status;
  String? createdAt;
  String? updatedAt;

  Data(
      {this.id,
        this.userId,
        this.pickupAddress,
        this.dropOffAddress,
        this.senderName,
        this.senderPhone,
        this.senderEmail,
        this.receiverName,
        this.receiverPhone,
        this.receiverEmail,
        this.type,
        this.mode,
        this.pickupLongitude,
        this.pickupLatitude,
        this.dropOffLongitude,
        this.dropOffLatitude,
        this.status,
        this.createdAt,
        this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    pickupAddress = json['pickupAddress'];
    dropOffAddress = json['dropOffAddress'];
    senderName = json['senderName'];
    senderPhone = json['senderPhone'];
    senderEmail = json['senderEmail'];
    receiverName = json['receiverName'];
    receiverPhone = json['receiverPhone'];
    receiverEmail = json['receiverEmail'];
    type = json['type'];
    mode = json['mode'];
    pickupLongitude = json['pickupLongitude'];
    pickupLatitude = json['pickupLatitude'];
    dropOffLongitude = json['dropOffLongitude'];
    dropOffLatitude = json['dropOffLatitude'];
    status = json['status'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['userId'] = this.userId;
    data['pickupAddress'] = this.pickupAddress;
    data['dropOffAddress'] = this.dropOffAddress;
    data['senderName'] = this.senderName;
    data['senderPhone'] = this.senderPhone;
    data['senderEmail'] = this.senderEmail;
    data['receiverName'] = this.receiverName;
    data['receiverPhone'] = this.receiverPhone;
    data['receiverEmail'] = this.receiverEmail;
    data['type'] = this.type;
    data['mode'] = this.mode;
    data['pickupLongitude'] = this.pickupLongitude;
    data['pickupLatitude'] = this.pickupLatitude;
    data['dropOffLongitude'] = this.dropOffLongitude;
    data['dropOffLatitude'] = this.dropOffLatitude;
    data['status'] = this.status;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}
