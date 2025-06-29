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
  Rx<ReportResponseModel?> originalReportList = Rx<ReportResponseModel?>(null);
  
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
      // Build the URL with pagination parameters only
      String url = 'https://roughbill.com/api/Report/GetBillingReport?ClientId=$clientId&ClientUserId=$clientUserId'
          '&pageNumber=${currentPage.value}'
          '&pageSize=${pageSize.value}';
      
      final response = await _apiService.getRequest(url: url);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        originalReportList.value = ReportResponseModel.fromJson(jsonResponse);
        
        // Update total pages
        if (originalReportList.value != null && originalReportList.value!.totalPages != null) {
          totalPages.value = originalReportList.value!.totalPages!;
        }
        
        // Apply filters locally
        applyFilters();
      } else {
        originalReportList.value = null;
        reportList.value = null;
        Get.snackbar('Error', 'Failed to load reports');
      }
    } catch (e) {
      originalReportList.value = null;
      reportList.value = null;
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Store the full filtered list for pagination
  RxList<BillingReport> allFilteredReports = RxList<BillingReport>([]);
  
  // Apply filters locally to the original report list
  void applyFilters() {
    if (originalReportList.value == null || originalReportList.value!.billingReports == null) {
      reportList.value = originalReportList.value;
      allFilteredReports.clear();
      return;
    }
    
    // Create a copy of the original report list
    reportList.value = ReportResponseModel(
      success: originalReportList.value!.success,
      totalCount: originalReportList.value!.totalCount,
      pageNumber: originalReportList.value!.pageNumber,
      pageSize: originalReportList.value!.pageSize,
      totalPages: originalReportList.value!.totalPages,
      billingReports: []
    );
    
    // Filter the reports based on search criteria
    allFilteredReports.value = List.from(originalReportList.value!.billingReports!);
    
    if (searchName.value.isNotEmpty) {
      allFilteredReports.value = allFilteredReports.where((report) => 
        report.customerName != null && 
        report.customerName!.toLowerCase().contains(searchName.value.toLowerCase())
      ).toList();
    }
    
    if (searchMobile.value.isNotEmpty) {
      // Assuming there's a mobile field in the report, adjust as needed
      // This is a placeholder since I don't see a mobile field in BillingReport
      // You may need to adjust this based on your actual data structure
      allFilteredReports.value = allFilteredReports.where((report) => 
        report.orderNo != null && 
        report.orderNo!.contains(searchMobile.value)
      ).toList();
    }
    
    if (fromDate.value != null) {
      allFilteredReports.value = allFilteredReports.where((report) => 
        report.paymentDate != null && 
        (report.paymentDate!.isAfter(fromDate.value!) || 
        report.paymentDate!.isAtSameMomentAs(fromDate.value!))
      ).toList();
    }
    
    if (toDate.value != null) {
      // Add one day to include the end date fully
      DateTime endDate = toDate.value!.add(const Duration(days: 1));
      allFilteredReports.value = allFilteredReports.where((report) => 
        report.paymentDate != null && 
        report.paymentDate!.isBefore(endDate)
      ).toList();
    }
    
    // Update pagination based on filtered results
    if (allFilteredReports.isNotEmpty) {
      int totalItems = allFilteredReports.length;
      int calculatedTotalPages = (totalItems / pageSize.value).ceil();
      totalPages.value = calculatedTotalPages > 0 ? calculatedTotalPages : 1;
      
      // Ensure current page is valid
      if (currentPage.value > totalPages.value) {
        currentPage.value = totalPages.value;
      }
    } else {
      totalPages.value = 1;
      currentPage.value = 1;
    }
    
    // Apply pagination to get the current page of results
    applyPagination();
  }
  
  // Helper method to format date for API
  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
  
  // Pagination methods
  void nextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      // Apply pagination locally
      applyPagination();
    }
  }
  
  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      // Apply pagination locally
      applyPagination();
    }
  }
  
  void goToPage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
      // Apply pagination locally
      applyPagination();
    }
  }
  
  // Apply pagination to filtered results
  void applyPagination() {
    // If we don't have filtered results yet, do nothing
    if (reportList.value == null || allFilteredReports.isEmpty) {
      return;
    }
    
    // Calculate start and end indices for current page
    int startIndex = (currentPage.value - 1) * pageSize.value;
    int endIndex = startIndex + pageSize.value;
    
    // Ensure indices are within bounds
    if (startIndex >= allFilteredReports.length) {
      // If start index is out of bounds, reset to first page
      currentPage.value = 1;
      startIndex = 0;
      endIndex = pageSize.value;
    }
    
    if (endIndex > allFilteredReports.length) {
      endIndex = allFilteredReports.length;
    }
    
    // Get the reports for the current page
    List<BillingReport> pagedReports = allFilteredReports.sublist(startIndex, endIndex);
    
    // Update the reportList with the paged reports
    reportList.value!.billingReports = pagedReports;
  }
  
  // Search methods
  void setSearchFilters(String name, String mobile, DateTime? from, DateTime? to) {
    searchName.value = name;
    searchMobile.value = mobile;
    fromDate.value = from;
    toDate.value = to;
    currentPage.value = 1; // Reset to first page when applying new filters
    applyFilters(); // Apply filters locally instead of making API call
  }
  
  void clearFilters() {
    searchName.value = '';
    searchMobile.value = '';
    fromDate.value = null;
    toDate.value = null;
    currentPage.value = 1;
    applyFilters(); // Apply filters locally instead of making API call
  }
}