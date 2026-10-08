class GetUserTicketsModel {
  bool? status;
  String? message;
  Data? data;

  GetUserTicketsModel({this.status, this.message, this.data});

  GetUserTicketsModel.fromJson(Map<String, dynamic> json) {
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
  List<Record>? record;

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
      record = <Record>[];
      json['record'].forEach((v) {
        record!.add(new Record.fromJson(v));
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

class Record {
  String? id;
  String? userId;
  String? ticketId;
  String? category;
  String? subject;
  String? status;
  String? attachment;
  String? createdAt;
  String? updatedAt;
  List<Messages>? messages;

  Record(
      {this.id,
        this.userId,
        this.ticketId,
        this.category,
        this.subject,
        this.status,
        this.attachment,
        this.createdAt,
        this.updatedAt,
        this.messages});

  Record.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    ticketId = json['ticketId'];
    category = json['category'];
    subject = json['subject'];
    status = json['status'];
    attachment = json['attachment'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    if (json['messages'] != null) {
      messages = <Messages>[];
      json['messages'].forEach((v) {
        messages!.add(new Messages.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['userId'] = this.userId;
    data['ticketId'] = this.ticketId;
    data['category'] = this.category;
    data['subject'] = this.subject;
    data['status'] = this.status;
    data['attachment'] = this.attachment;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    if (this.messages != null) {
      data['messages'] = this.messages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Messages {
  String? id;
  String? ticketId;
  String? senderType;
  String? senderId;
  String? message;
  String? attachment;
  String? createdAt;
  String? updatedAt;

  Messages(
      {this.id,
        this.ticketId,
        this.senderType,
        this.senderId,
        this.message,
        this.attachment,
        this.createdAt,
        this.updatedAt});

  Messages.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    ticketId = json['ticketId'];
    senderType = json['senderType'];
    senderId = json['senderId'];
    message = json['message'];
    attachment = json['attachment'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['ticketId'] = this.ticketId;
    data['senderType'] = this.senderType;
    data['senderId'] = this.senderId;
    data['message'] = this.message;
    data['attachment'] = this.attachment;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}
