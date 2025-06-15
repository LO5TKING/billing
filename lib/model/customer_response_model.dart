import 'dart:convert';

CustomerResponseModel customerResponseModelFromJson(String str) => CustomerResponseModel.fromJson(json.decode(str));

String customerResponseModelToJson(CustomerResponseModel data) => json.encode(data.toJson());

class CustomerResponseModel {
  bool? success;
  List<Datum>? data;

  CustomerResponseModel({
    this.success,
    this.data,
  });

  factory CustomerResponseModel.fromJson(Map<String, dynamic> json) => CustomerResponseModel(
    success: json["success"],
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  int? custId;
  String? name;
  String? mobileNo;
  String? gstNo;
  String? emailId;
  String? address;
  String? clientId;
  DateTime? createdDate;
  DateTime? modifiedDate;
  bool? status;
  int? clientUserId;

  Datum({
    this.custId,
    this.name,
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

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    custId: json["custId"],
    name: json["name"],
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
    "custId": custId,
    "name": name,
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
