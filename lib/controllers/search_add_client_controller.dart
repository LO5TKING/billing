import 'package:billing/app/config/constants_text.dart';
import 'package:billing/utils/constants.dart';
import 'package:billing/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../networks/api_service.dart';
import '../validation/validation.dart';

class SearchAddClientController extends GetxController{
  final formKey = GlobalKey<FormState>();
  final searchFormKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController gstController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  
  TextEditingController searchNameController = TextEditingController();
  TextEditingController searchMobileController = TextEditingController();
  
  RxBool isLoading = false.obs;
  RxBool isSearching = false.obs;
  RxList clientList = [].obs;
  ApiService apiService = ApiService();

  // Validation methods
  String? validateName(String? value) {
    return Validation.validatePersonName(value);
  }
  
  String? validateMobile(String? value) {
    return Validation.validateMobileNumber(value);
  }
  
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Email is optional
    }
    return Validation.validateEmail(value);
  }
  
  String? validateGST(String? value) {
    if (value == null || value.isEmpty) {
      return null; // GST is optional
    }
    // GST format validation - 15 characters with specific pattern
    RegExp gstRegex = RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$');
    if (!gstRegex.hasMatch(value)) {
      return 'Please enter a valid GST number';
    }
    return null;
  }
  
  // API call to add client
  void addClientPostApi() async {
    isLoading.value = true;
    String url = "https://roughbill.com/api/Customer/add";
    String? clientId = SharedPrefs.getString(ConstantsText.clientId);
    String? clientUserId = SharedPrefs.getString(ConstantsText.userId);

    try {
      Map<String, dynamic> data = {
        'custId':0,
        'name': nameController.text,
        'mobileNo': mobileController.text,
        'gstNo': gstController.text,
        'emailId': emailController.text,
        'address': addressController.text,
        'clientId':clientId,
        "createdDate": "${DateTime.now().toString().split(' ')[0]}",
        "modifiedDate": "${DateTime.now().toString().split(' ')[0]}",
        'status':true,
        'clientUserId':clientUserId,
      };
      
      var response = await apiService.postRequest(url: url, data : data);
      
      if (response.statusCode == 200) {
        Get.back(); // Close dialog
        Get.snackbar(
          'Success',
          'Client added successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        // Clear form fields
        clearFields();
        
        // Refresh client list
        searchClients();
      } else {
        Get.snackbar(
          'Error',
          'Failed to add client',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // API call to search clients
  void searchClients() async {
    isSearching.value = true;
    String url = "";
    try {
      Map<String, dynamic> data = {
        'name': searchNameController.text,
        'mobile': searchMobileController.text,
      };
      
      var response = await apiService.postRequest(url: url, data: data);
      
      if (response.statusCode == 200) {
        // clientList.value = response.body ?? [];
        // if (clientList.isEmpty) {
        //   Get.snackbar(
        //     'Info',
        //     'No clients found',
        //     snackPosition: SnackPosition.BOTTOM,
        //     backgroundColor: Colors.blue,
        //     colorText: Colors.white,
        //   );
        // }
      } else {
        Get.snackbar(
          'Error',
          'Failed to search clients',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSearching.value = false;
    }
  }
  
  // Clear all form fields
  void clearFields() {
    nameController.clear();
    mobileController.clear();
    gstController.clear();
    emailController.clear();
    addressController.clear();
  }

  @override
  void onClose() {
    nameController.dispose();
    mobileController.dispose();
    gstController.dispose();
    emailController.dispose();
    addressController.dispose();
    searchNameController.dispose();
    searchMobileController.dispose();
    super.onClose();
  }
}