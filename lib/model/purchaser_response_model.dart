// To parse this JSON data, do
//
//     final purchaserResponseModel = purchaserResponseModelFromJson(jsonString);

import 'dart:convert';

PurchaserResponseModel purchaserResponseModelFromJson(String str) => PurchaserResponseModel.fromJson(json.decode(str));

String purchaserResponseModelToJson(PurchaserResponseModel data) => json.encode(data.toJson());

class PurchaserResponseModel {
  bool? success;
  List<PurchaserData>? data;

  PurchaserResponseModel({
    this.success,
    this.data,
  });

  factory PurchaserResponseModel.fromJson(Map<String, dynamic> json) => PurchaserResponseModel(
    success: json["success"],
    data: json["data"] == null ? [] : List<PurchaserData>.from(json["data"]!.map((x) => PurchaserData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class PurchaserData {
  int? purchaserId;
  String? purchaserName;
  String? mobileNo;
  String? gstNo;
  String? emailId;
  String? address;
  String? clientId;
  DateTime? createdDate;
  DateTime? modifiedDate;
  bool? status;
  int? clientUserId;

  PurchaserData({
    this.purchaserId,
    this.purchaserName,
    this.mobileNo,
    this.gstNo,
    this.emailId,
    this.address,
    this.clientId,
    this.createdDate,
    this.modifiedDate,
    this.status,
    this.clientUserId,
  });

  factory PurchaserData.fromJson(Map<String, dynamic> json) => PurchaserData(
    purchaserId: json["purchaserId"],
    purchaserName: json["purchaserName"],
    mobileNo: json["mobileNo"],
    gstNo: json["gstNo"],
    emailId: json["emailId"],
    address: json["address"],
    clientId: json["clientId"],
    createdDate: json["createdDate"] == null ? null : DateTime.parse(json["createdDate"]),
    modifiedDate: json["modifiedDate"] == null ? null : DateTime.parse(json["modifiedDate"]),
    status: json["status"],
    clientUserId: json["clientUserId"],
  );

  Map<String, dynamic> toJson() => {
    "purchaserId": purchaserId,
    "purchaserName": purchaserName,
    "mobileNo": mobileNo,
    "gstNo": gstNo,
    "emailId": emailId,
    "address": address,
    "clientId": clientId,
    "createdDate": createdDate?.toIso8601String(),
    "modifiedDate": modifiedDate?.toIso8601String(),
    "status": status,
    "clientUserId": clientUserId,
  };
}
