class SubmitInitialMessageModel {
  bool? status;
  String? message;
  Data? data;

  SubmitInitialMessageModel({this.status, this.message, this.data});

  SubmitInitialMessageModel.fromJson(Map<String, dynamic> json) {
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
  String? ticketId;
  String? id;

  Data({this.ticketId, this.id});

  Data.fromJson(Map<String, dynamic> json) {
    ticketId = json['ticketId'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ticketId'] = this.ticketId;
    data['id'] = this.id;
    return data;
  }
}
