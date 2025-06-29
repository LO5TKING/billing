import 'dart:convert';

ReportResponseModel reportResponseModelFromJson(String str) => ReportResponseModel.fromJson(json.decode(str));

String reportResponseModelToJson(ReportResponseModel data) => json.encode(data.toJson());

class ReportResponseModel {
  bool? success;
  List<BillingReport>? billingReports;
  int? totalCount;
  int? pageNumber;
  int? pageSize;
  int? totalPages;

  ReportResponseModel({
    this.success,
    this.billingReports,
    this.totalCount,
    this.pageNumber,
    this.pageSize,
    this.totalPages,
  });

  factory ReportResponseModel.fromJson(Map<String, dynamic> json) => ReportResponseModel(
    success: json["success"],
    billingReports: json["billingReports"] == null ? [] : List<BillingReport>.from(json["billingReports"]!.map((x) => BillingReport.fromJson(x))),
    totalCount: json["totalCount"],
    pageNumber: json["pageNumber"],
    pageSize: json["pageSize"],
    totalPages: json["totalPages"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "billingReports": billingReports == null ? [] : List<dynamic>.from(billingReports!.map((x) => x.toJson())),
    "totalCount": totalCount,
    "pageNumber": pageNumber,
    "pageSize": pageSize,
    "totalPages": totalPages,
  };
}

class BillingReport {
  int? billingId;
  String? orderNo;
  int? customerId;
  String? customerName;
  String? clientId;
  double totalAmount;
  double? balanceAmount;
  double? discount;
  double? gst;
  String? discountType;
  double? paidAmount;
  String? paidAmountType;
  String? transactionNo;
  String? referenceNo;
  String? paymentStatus;
  DateTime? paymentDate;
  DateTime? postedOn;
  dynamic modifiedOn;
  bool? isDelete;
  bool? isRefund;
  int? refundAmoount;
  String? refundRemark;
  String? refundType;
  dynamic refundDate;
  String? refundTransNo;
  String? refundStatus;
  int? clientUserId;

  BillingReport({
    this.billingId,
    this.orderNo,
    this.customerId,
    this.customerName,
    this.clientId,
    this.totalAmount = 0,
    this.balanceAmount,
    this.discount,
    this.gst,
    this.discountType,
    this.paidAmount,
    this.paidAmountType,
    this.transactionNo,
    this.referenceNo,
    this.paymentStatus,
    this.paymentDate,
    this.postedOn,
    this.modifiedOn,
    this.isDelete,
    this.isRefund,
    this.refundAmoount,
    this.refundRemark,
    this.refundType,
    this.refundDate,
    this.refundTransNo,
    this.refundStatus,
    this.clientUserId,
  });

  factory BillingReport.fromJson(Map<String, dynamic> json) => BillingReport(
    billingId: json["billingId"],
    orderNo: json["orderNo"],
    customerId: json["customerId"],
    customerName: json["customerName"],
    clientId: json["clientId"],
    totalAmount: json["totalAmount"],
    balanceAmount: json["balanceAmount"],
    discount: json["discount"],
    gst: json["gst"],
    discountType: json["discountType"],
    paidAmount: json["paidAmount"],
    paidAmountType: json["paidAmountType"],
    transactionNo: json["transactionNo"],
    referenceNo: json["referenceNo"],
    paymentStatus: json["paymentStatus"],
    paymentDate: json["paymentDate"] == null ? null : DateTime.parse(json["paymentDate"]),
    postedOn: json["postedOn"] == null ? null : DateTime.parse(json["postedOn"]),
    modifiedOn: json["modifiedOn"],
    isDelete: json["isDelete"],
    isRefund: json["isRefund"],
    refundAmoount: json["refundAmoount"],
    refundRemark: json["refundRemark"],
    refundType: json["refundType"],
    refundDate: json["refundDate"],
    refundTransNo: json["refundTransNo"],
    refundStatus: json["refundStatus"],
    clientUserId: json["clientUserId"],
  );

  Map<String, dynamic> toJson() => {
    "billingId": billingId,
    "orderNo": orderNo,
    "customerId": customerId,
    "customerName": customerName,
    "clientId": clientId,
    "totalAmount": totalAmount,
    "balanceAmount": balanceAmount,
    "discount": discount,
    "gst": gst,
    "discountType": discountType,
    "paidAmount": paidAmount,
    "paidAmountType": paidAmountType,
    "transactionNo": transactionNo,
    "referenceNo": referenceNo,
    "paymentStatus": paymentStatus,
    "paymentDate": paymentDate?.toIso8601String(),
    "postedOn": postedOn?.toIso8601String(),
    "modifiedOn": modifiedOn,
    "isDelete": isDelete,
    "isRefund": isRefund,
    "refundAmoount": refundAmoount,
    "refundRemark": refundRemark,
    "refundType": refundType,
    "refundDate": refundDate,
    "refundTransNo": refundTransNo,
    "refundStatus": refundStatus,
    "clientUserId": clientUserId,
  };
}
