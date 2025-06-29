import 'package:billing/model/report_response_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../app/config/constants_text.dart';
import '../networks/api_service.dart';
import '../utils/shared_pref.dart';

class ReportController extends GetxController {

  ApiService apiService = ApiService();
  Rx<ReportResponseModel?> reportList = Rx<ReportResponseModel?>(null);

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getReports();
  }

  void getReports() async {
    String? clientId = SharedPrefs.getString(ConstantsText.clientId);
    int? clientUserId = SharedPrefs.getInt(ConstantsText.clientUserId);

    print("clientId is $clientId & clientUserId is $clientUserId");
    String url = "https://roughbill.com/api/Report/GetBillingReport?ClientId=$clientId&ClientUserId=$clientUserId&pageNumber=1&pageSize=5";

    try {
      var response = await apiService.getRequest(url: url);

      if (response.statusCode == 200) {
        // Parse the response directly into the observable
        reportList.value = reportResponseModelFromJson(response.body);

        print(response.body.toString());

      } else {
        reportList.value = null; // Clear data on error
        Get.snackbar(
          'Error',
          'Failed to search clients',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      reportList.value = null; // Clear data on error
      print("Error parsing customer data: $e");
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}