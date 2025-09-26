import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../app/config/color_constants.dart';
import '../app/config/constants_text.dart';
import '../model/customer_response_model.dart';
import '../model/report_response_model.dart';
import '../networks/api_service.dart';
import '../print/print_controller.dart';
import '../utils/shared_pref.dart';

class ReportController extends GetxController {
  final ApiService _apiService = ApiService();
  Rx<ReportResponseModel?> reportList = Rx<ReportResponseModel?>(null);
  Rx<ReportResponseModel?> originalReportList = Rx<ReportResponseModel?>(null);
  TextEditingController amountPaid = TextEditingController();
  TextEditingController discountAmount = TextEditingController();
  late PrintController printController;
  ApiService apiService = ApiService();
  
  // Pagination variables
  RxInt currentPage = 1.obs;
  RxInt pageSize = 5.obs;
  RxInt totalPages = 1.obs;
  
  // Loading state
  RxBool isLoading = false.obs;
  
  // Search filters
  RxString searchName = ''.obs;
  RxString searchMobile = ''.obs;
  Rx<DateTime?> fromDate = Rx<DateTime?>(null);
  Rx<DateTime?> toDate = Rx<DateTime?>(null);
  
  // Total balance amount
  RxDouble totalBalanceAmount = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    getReports();
    if (!Get.isRegistered<PrintController>()) {
      Get.lazyPut(() => PrintController(), fenix: true);
    }
    printController = Get.find<PrintController>();
  }

  Future<void> getReports() async {
    isLoading.value = true;
    String? clientId = SharedPrefs.getString(ConstantsText.clientId);
    int? clientUserId = SharedPrefs.getInt(ConstantsText.clientUserId);
    try {
      // Build the URL with pagination parameters
      String url = 'https://roughbill.com/api/Report/GetBillingReport?ClientId=$clientId&ClientUserId=$clientUserId'
          '&pageNumber=${currentPage.value}'
          '&pageSize=${pageSize.value}';
      
      // Add filter parameters if they exist
      if (searchName.value.isNotEmpty) {
        url += '&CustomerName=${Uri.encodeComponent(searchName.value)}';
      }
      if (searchMobile.value.isNotEmpty) {
        url += '&MobileNo=${Uri.encodeComponent(searchMobile.value)}';
      }
      if (fromDate.value != null) {
        url += '&FromDate=${_formatDate(fromDate.value!)}';
      }
      if (toDate.value != null) {
        url += '&ToDate=${_formatDate(toDate.value!)}';
      }
      
      final response = await _apiService.getRequest(url: url);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        reportList.value = ReportResponseModel.fromJson(jsonResponse);
        originalReportList.value = reportList.value;
        
        // Update total pages
        if (reportList.value != null && reportList.value!.totalPages != null) {
          totalPages.value = reportList.value!.totalPages!;
        }
        
        // Calculate total balance amount
        calculateTotalBalanceAmount();
      } else {
        reportList.value = null;
        originalReportList.value = null;
        totalBalanceAmount.value = 0.0;
        Get.snackbar('Error', 'Failed to load reports');
      }
    } catch (e) {
      reportList.value = null;
      originalReportList.value = null;
      totalBalanceAmount.value = 0.0;
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Calculate total balance amount from reports
  void calculateTotalBalanceAmount() {
    if (reportList.value == null || reportList.value!.billingReports == null) {
      totalBalanceAmount.value = 0.0;
      return;
    }
    
    double total = 0.0;
    for (var report in reportList.value!.billingReports!) {
      if (report.balanceAmount != null) {
        total += report.balanceAmount!;
      }
    }
    totalBalanceAmount.value = total;
  }
  
  // Helper method to format date for API
  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
  
  // Pagination methods
  void nextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      getReports(); // Make API call with new page number
    }
  }
  
  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      getReports(); // Make API call with new page number
    }
  }
  
  void goToPage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
      getReports(); // Make API call with new page number
    }
  }
  
  // Search methods
  void setSearchFilters(String name, String mobile, DateTime? from, DateTime? to) {
    searchName.value = name;
    searchMobile.value = mobile;
    fromDate.value = from;
    toDate.value = to;
    currentPage.value = 1; // Reset to first page when applying new filters
    getReports(); // Make API call with filters
  }
  
  void clearFilters() {
    searchName.value = '';
    searchMobile.value = '';
    fromDate.value = null;
    toDate.value = null;
    currentPage.value = 1;
    getReports(); // Make API call without filters
  }

  /*Future<void> printPdfReceipt(BillingReport? report) async {

    double discountAmount = 0;
    double amountToBePaid = report?.totalAmount ?? 0;
    double balanceAmount = 0;
    String discountType = 'Flat'; // 'Flat' or 'Percentage'

    amountPaid.text = report?.totalAmount.toString() ?? "0";
    Get.defaultDialog(
      title: 'Payment Details',
      barrierDismissible: false,
      content: StatefulBuilder(
        builder: (context, setState) {
          // Calculate amounts based on current values
          double calculatedTotal = report?.totalAmount ?? 0;
          double finalAmount = calculatedTotal;

          // Apply discount based on type
          if (discountType == 'Percentage' && discountAmount > 0) {
            finalAmount = calculatedTotal - (calculatedTotal * discountAmount / 100);
          } else if (discountType == 'Flat') {
            finalAmount = calculatedTotal - discountAmount;
          }

          // Ensure final amount is not negative
          finalAmount = finalAmount < 0 ? 0 : finalAmount;

          // Calculate balance
          balanceAmount = finalAmount - amountToBePaid;
          balanceAmount = balanceAmount < 0 ? 0 : balanceAmount;
          return Container(
            width: Get.width * 0.8,
            padding: const EdgeInsets.all(20),
            child: Table(
              columnWidths: const {
                0: FixedColumnWidth(150),   // Fixed label width
                1: FixedColumnWidth(150),      // Remaining space for inputs/values
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [

                // Total Amount
                TableRow(children: [
                  const Text('Total Amount:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Container(
                    height: 40,
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 0.5),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('₹ ${calculatedTotal.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ]),

                const TableRow(children: [SizedBox(height: 12), SizedBox(height: 12)]),

                // Discount Type
                TableRow(children: [
                  const Text('Discount Type:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Row(
                        children: [
                          Radio(
                            value: 'Flat',
                            groupValue: discountType,
                            onChanged: (value) {
                              setState(() {
                                discountType = value.toString();
                                discountAmount = 0;
                              });
                            },
                          ),
                          const Text('Flat Amount'),
                        ],
                      ),
                      Row(
                        children: [
                          Radio(
                            value: 'Percentage',
                            groupValue: discountType,
                            onChanged: (value) {
                              setState(() {
                                discountType = value.toString();
                                discountAmount = 0;
                              });
                            },
                          ),
                          const Text('Percentage'),
                        ],
                      ),
                    ],
                  )
                ]),

                const TableRow(children: [SizedBox(height: 12), SizedBox(height: 12)]),

                // Discount Amount
                TableRow(children: [
                  Text(
                    discountType == 'Percentage' ? 'Discount %:' : 'Discount Amount:',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 100,
                    height: 40,
                    child: TextField(
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        prefixText: discountType == 'Percentage' ? '% ' : '₹ ',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      ),
                      onChanged: (value) {
                        setState(() {
                          discountAmount = double.tryParse(value) ?? 0;
                        });
                      },
                    ),
                  ),
                ]),

                const TableRow(children: [SizedBox(height: 12), SizedBox(height: 12)]),

                // Final Amount
                TableRow(children: [
                  const Text('Final Amount:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Container(
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 0.5),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text('₹ ${finalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.blueGradient)),
                  ),
                ]),

                const TableRow(children: [SizedBox(height: 12), SizedBox(height: 12)]),

                // Amount Paid
                TableRow(children: [
                  const Text('Amount Paid:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(
                    width: 100,
                    height: 40,
                    child: TextField(
                      controller: amountPaid,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixText: '₹ ',
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      ),
                      onChanged: (value) {
                        setState(() {
                          amountToBePaid = double.tryParse(value) ?? 0;
                        });
                      },
                    ),
                  )
                ]),

                const TableRow(children: [SizedBox(height: 12), SizedBox(height: 12)]),

                // Balance Amount
                TableRow(children: [
                  const Text('Balance Amount:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Container(
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 0.5),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text('₹ ${balanceAmount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  ),
                ]),
              ],
            ),
          );
        },
      ),
      actions: [
        GestureDetector(
          onTap: () async {
            await submitBillingData(
                customerId: report?.customerId,
                customerName: report?.customerName,
                clientId: report?.clientId,
              report: report
            );
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(100)),
            child: const Text(
              "Save Reciept",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
        GestureDetector(
          onTap: () async {
            try {
              Get.back();
              double finalAmount = report?.totalAmount ?? 0;
              if (discountType == 'Percentage' && discountAmount > 0) {
                finalAmount = report?.totalAmount ?? 0 - (report?.totalAmount ?? 0 * discountAmount / 100);
              } else if (discountType == 'Flat') {
                finalAmount = report?.totalAmount ?? 0 - discountAmount;
              }
              finalAmount = finalAmount < 0 ? 0 : finalAmount;

              // Pass discount information to print controller
              // Calculate actual discount amount in flat value
              double actualDiscountAmount = discountType == 'Percentage' ?
              (report?.totalAmount ?? 0 * discountAmount / 100) : discountAmount;

              await submitBillingData(
                  customerId: report?.customerId,
                  customerName: report?.customerName,
                  clientId: report?.clientId,
                report: report


              );
              await printController.printPdfReceipt(
                  itemList,
                  discountAmount: actualDiscountAmount,
                  amountPaid: amountToBePaid
              );

              Get.snackbar('Success', 'Receipt sent to printer');
            } catch (e) {
              Get.snackbar("Error", "Failed to print: $e");
            }
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(100)),
            child: const Text(
              "Print Receipt",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(100)),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }


  Future<void> submitBillingData({
    String orderNo = '',
    int? customerId = 0,
    String? customerName = '',
    String? clientId = '',
    double discount = 0,
    double gst = 0,
    String discountType = 'Flat',
    double paidAmount = 0,
    String paidAmountType = 'Cash',
    String transactionNo = '',
    String referenceNo = '',
    String paymentStatus = 'Pending',
    BillingReport? report
  }) async {
    try {
      // Show loading indicator
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Calculate total amount from items
      final double calculatedTotal = report?.totalAmount ?? 0;
      final double balanceAmount = calculatedTotal - double.parse(amountPaid.text);

      // Current date time
      final DateTime now = DateTime.now();
      final String formattedDate = now.toIso8601String();
      int? clientUserId = SharedPrefs.getInt(ConstantsText.clientUserId);

      // Prepare order details from itemList
      List<Map<String, dynamic>> orderDetails = [];
      orderNo = DateTime.now().millisecondsSinceEpoch.toString();

      for (int i = 0; i < itemList.length; i++) {
        final item = itemList[i];
        final double qty = double.tryParse(item['quantity'] ?? '0') ?? 0;
        final double rate = double.tryParse(item['rate'] ?? '0') ?? 0;
        final double totalPrice = qty * rate;

        // Convert image to base64 if available
        String productName = '';
        if (item['particulars'] is Uint8List) {
          productName = _convertImageToBase64(item['particulars']);
          // productName = "trying test";
        }

        orderDetails.add({
          "orderNo": orderNo,
          "orderDetailsId": 0,
          "billingId": 0,
          "customerId": customerId,
          "clientId": clientId,
          "customerName": customerName,
          "productName": productName,
          "quantity": qty,
          "pricePerQuantity": rate,
          "totalPrice": totalPrice,
          "productType": "",
          "isDelete": false,
          "postedOn": formattedDate,
          "modifiedOn": formattedDate,
          "clientUserId": clientUserId
        });
      }

      // Prepare billing data
      Map<String, dynamic> billingData = {
        "oBilling": {
          "billingId": 0,
          "orderNo": orderNo,
          "customerId": customerId,
          "customerName": customerName,
          "clientId": clientId,
          "totalAmount": calculatedTotal,
          "balanceAmount": balanceAmount,
          "discount": discount,
          "gst": gst,
          "discountType": discountType,
          "paidAmount": paidAmount,
          "paidAmountType": paidAmountType,
          "transactionNo": transactionNo,
          "referenceNo": referenceNo,
          "paymentStatus": paymentStatus,
          "paymentDate": formattedDate,
          "postedOn": formattedDate,
          "modifiedOn": formattedDate,
          "isDelete": false,
          "isRefund": false,
          "refundAmount": 0,
          "refundRemark": "",
          "refundType": "",
          "refundDate": null,
          "refundTransNo": "",
          "refundStatus": "",
          "clientUserId": clientUserId
        },
        "orderDetails": orderDetails
      };

      // Make API call
      final response = await apiService.postRequest(
        url: "https://roughbill.com/api/Order/addorder",
        data: billingData,
      );

      // Close loading dialog
      Get.back();

      if (response.statusCode == 200) {
        // Success
        Get.snackbar(
          "Success",
          "Billing data submitted successfully",
          snackPosition: SnackPosition.BOTTOM,
        );

        itemList.clear();
        update();
      } else {
        // Error
        Get.snackbar(
          "Error",
          "Failed to submit billing data: ${response.body}",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      // Close loading dialog if open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Show error
      Get.snackbar(
        "Error",
        "Exception occurred: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  String _convertImageToBase64(Uint8List? imageBytes) {
    if (imageBytes == null) return '';
    return base64Encode(imageBytes);
  }*/
}