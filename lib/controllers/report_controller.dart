import 'dart:convert';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../app/config/constants_text.dart';
import '../model/report_response_model.dart';
import '../networks/api_service.dart';
import '../utils/shared_pref.dart';

class ReportController extends GetxController {
  final ApiService _apiService = ApiService();
  Rx<ReportResponseModel?> reportList = Rx<ReportResponseModel?>(null);
  
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

  @override
  void onInit() {
    super.onInit();
    getReports();
  }

  Future<void> getReports() async {
    isLoading.value = true;
    String? clientId = SharedPrefs.getString(ConstantsText.clientId);
    int? clientUserId = SharedPrefs.getInt(ConstantsText.clientUserId);
    try {
      // Build the URL with pagination and search parameters
      String url = 'https://roughbill.com/api/Report/GetBillingReport?ClientId=$clientId&ClientUserId=$clientUserId'
          '&pageNumber=${currentPage.value}'
          '&pageSize=${pageSize.value}';
      /// https://roughbill.com/api/Report/GetBillingReport?ClientId=RB2526-01&ClientUserId=1&pageNumber=1&pageSize=5
      
      final response = await _apiService.getRequest(url: url);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        reportList.value = ReportResponseModel.fromJson(jsonResponse);


        
        // Update total pages
        if (reportList.value != null && reportList.value!.totalPages != null) {
          totalPages.value = reportList.value!.totalPages!;
        }
      } else {
        reportList.value = null;
        Get.snackbar('Error', 'Failed to load reports');
      }
    } catch (e) {
      reportList.value = null;
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Helper method to format date for API
  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
  
  // Pagination methods
  void nextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      getReports();
    }
  }
  
  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      getReports();
    }
  }
  
  void goToPage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
      getReports();
    }
  }
  
  // Search methods
  void setSearchFilters(String name, String mobile, DateTime? from, DateTime? to) {
    searchName.value = name;
    searchMobile.value = mobile;
    fromDate.value = from;
    toDate.value = to;
    currentPage.value = 1; // Reset to first page when applying new filters
  }
  
  void clearFilters() {
    searchName.value = '';
    searchMobile.value = '';
    fromDate.value = null;
    toDate.value = null;
    currentPage.value = 1;
    getReports();
  }
}