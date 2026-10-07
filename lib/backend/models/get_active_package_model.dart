class GetActivePackageModel {
  bool? status;
  String? message;
  List<ActivePackageList>? data;

  GetActivePackageModel({this.status, this.message, this.data});

  GetActivePackageModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <ActivePackageList>[];
      json['data'].forEach((v) {
        data!.add(new ActivePackageList.fromJson(v));
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

class ActivePackageList {
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

  ActivePackageList(
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
        this.updatedAt
      });
  DateTime get updatedAtDateTime => DateTime.parse(updatedAt!);

  ActivePackageList.fromJson(Map<String, dynamic> json) {
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
    pickupLongitude = (json['pickupLongitude'] as num?)?.toDouble();
    pickupLatitude = (json['pickupLatitude'] as num?)?.toDouble();
    dropOffLongitude = (json['dropOffLongitude'] as num?)?.toDouble();
    dropOffLatitude = (json['dropOffLatitude'] as num?)?.toDouble();
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
