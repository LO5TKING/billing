import 'dart:convert';

OrderDeatailsResponseModel orderDeatailsResponseModelFromJson(String str) => OrderDeatailsResponseModel.fromJson(json.decode(str));

String orderDeatailsResponseModelToJson(OrderDeatailsResponseModel data) => json.encode(data.toJson());

class OrderDeatailsResponseModel {
  bool? success;
  int? ordersCount;
  List<Order>? orders;

  OrderDeatailsResponseModel({
    this.success,
    this.ordersCount,
    this.orders,
  });

  factory OrderDeatailsResponseModel.fromJson(Map<String, dynamic> json) => OrderDeatailsResponseModel(
    success: json["success"],
    ordersCount: json["ordersCount"],
    orders: json["orders"] == null ? [] : List<Order>.from(json["orders"]!.map((x) => Order.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "ordersCount": ordersCount,
    "orders": orders == null ? [] : List<dynamic>.from(orders!.map((x) => x.toJson())),
  };
}

class Order {
  OBilling? oBilling;
  List<OrderDetail>? orderDetails;

  Order({
    this.oBilling,
    this.orderDetails,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    oBilling: json["oBilling"] == null ? null : OBilling.fromJson(json["oBilling"]),
    orderDetails: json["orderDetails"] == null ? [] : List<OrderDetail>.from(json["orderDetails"]!.map((x) => OrderDetail.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "oBilling": oBilling?.toJson(),
    "orderDetails": orderDetails == null ? [] : List<dynamic>.from(orderDetails!.map((x) => x.toJson())),
  };
}

class OBilling {
  int? billingId;
  String? orderNo;
  int? customerId;
  String? customerName;
  String? clientId;
  int? totalAmount;
  int? balanceAmount;
  int? discount;
  int? gst;
  String? discountType;
  int? paidAmount;
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

  OBilling({
    this.billingId,
    this.orderNo,
    this.customerId,
    this.customerName,
    this.clientId,
    this.totalAmount,
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

  factory OBilling.fromJson(Map<String, dynamic> json) => OBilling(
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

class OrderDetail {
  int? orderDetailsId;
  int? billingId;
  int? customerId;
  String? clientId;
  String? customerName;
  String? productName;
  int? quantity;
  int? pricePerQuantity;
  int? totalPrice;
  String? productType;
  bool? isDelete;
  DateTime? postedOn;
  dynamic modifiedOn;
  int? clientUserId;
  dynamic orderNo;

  OrderDetail({
    this.orderDetailsId,
    this.billingId,
    this.customerId,
    this.clientId,
    this.customerName,
    this.productName,
    this.quantity,
    this.pricePerQuantity,
    this.totalPrice,
    this.productType,
    this.isDelete,
    this.postedOn,
    this.modifiedOn,
    this.clientUserId,
    this.orderNo,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) => OrderDetail(
    orderDetailsId: json["orderDetailsId"],
    billingId: json["billingId"],
    customerId: json["customerId"],
    clientId: json["clientId"],
    customerName: json["customerName"],
    productName: json["productName"],
    quantity: json["quantity"],
    pricePerQuantity: json["pricePerQuantity"],
    totalPrice: json["totalPrice"],
    productType: json["productType"],
    isDelete: json["isDelete"],
    postedOn: json["postedOn"] == null ? null : DateTime.parse(json["postedOn"]),
    modifiedOn: json["modifiedOn"],
    clientUserId: json["clientUserId"],
    orderNo: json["orderNo"],
  );

  Map<String, dynamic> toJson() => {
    "orderDetailsId": orderDetailsId,
    "billingId": billingId,
    "customerId": customerId,
    "clientId": clientId,
    "customerName": customerName,
    "productName": productName,
    "quantity": quantity,
    "pricePerQuantity": pricePerQuantity,
    "totalPrice": totalPrice,
    "productType": productType,
    "isDelete": isDelete,
    "postedOn": postedOn?.toIso8601String(),
    "modifiedOn": modifiedOn,
    "clientUserId": clientUserId,
    "orderNo": orderNo,
  };
}
