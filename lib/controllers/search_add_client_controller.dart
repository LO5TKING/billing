import 'dart:convert';

import 'package:billing/app/config/constants_text.dart';
import 'package:billing/model/customer_response_model.dart';
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
  ApiService apiService = ApiService();
  Rx<CustomerResponseModel?> customerList = Rx<CustomerResponseModel?>(null);
  List<Datum> get clientList => customerList.value?.data ?? [];
  RxBool addPurchaser = false.obs;



  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getClients();
  }

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
    int? clientUserId = SharedPrefs.getInt(ConstantsText.clientUserId);

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
        'clientUserId':clientUserId.toString(),
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

  void addPurchaserPostApi() async {
    isLoading.value = true;
    String url = "https://roughbill.com/api/Purchaser/add";
    String? clientId = SharedPrefs.getString(ConstantsText.clientId);
    int? clientUserId = SharedPrefs.getInt(ConstantsText.clientUserId);

    try {
      Map<String, dynamic> data = {
        'purchaserId':0,
        'purchaserName': nameController.text,
        'mobileNo': mobileController.text,
        'gstNo': gstController.text,
        'emailId': emailController.text,
        'address': addressController.text,
        'clientId':clientId,
        "createdDate": "${DateTime.now().toString().split(' ')[0]}",
        "modifiedDate": "${DateTime.now().toString().split(' ')[0]}",
        'status':true,
        'clientUserId':clientUserId.toString(),
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
  void getClients() async {
    String? clientId = SharedPrefs.getString(ConstantsText.clientId);
    int? clientUserId = SharedPrefs.getInt(ConstantsText.clientUserId);
    String url = "https://roughbill.com/api/Customer/GetCustomer?clientId=$clientId&ClientUserId=$clientUserId";

    try {
      var response = await apiService.getRequest(url: url);

      if (response.statusCode == 200) {
        // Parse the response directly into the observable
        customerList.value = customerResponseModelFromJson(response.body);

        print("Parsed ${customerList.value?.data?.length ?? 0} customers");
        print("API Success: ${customerList.value?.success}");
        print(response.body.toString());

      } else {
        customerList.value = null; // Clear data on error
        Get.snackbar(
          'Error',
          'Failed to search clients',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      customerList.value = null; // Clear data on error
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