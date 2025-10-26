import 'dart:convert';

import 'package:billing/app/config/constants_text.dart';
import 'package:billing/model/login_response_model.dart';
import 'package:billing/networks/api_service.dart';
import 'package:billing/ui/clients/billing_options.dart';
import 'package:billing/utils/shared_pref.dart';
import 'package:billing/validation/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  ApiService apiService = ApiService();
  
  // Text controllers
  TextEditingController mobileNo = TextEditingController();
  TextEditingController password = TextEditingController();
  
  // For form validation
  final formKey = GlobalKey<FormState>();
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;
  
  // Validate login fields
  bool validateFields() {
    // Clear previous error message
    errorMessage.value = '';
    
    // Validate required fields
    String? mobileError = Validation.validateMobileNumber(mobileNo.text);
    String? passwordError = Validation.validatePassword(password.text);
    
    // If any required field has error
    if (mobileError != null) {
      errorMessage.value = mobileError;
      return false;
    } else if (passwordError != null) {
      errorMessage.value = passwordError;
      return false;
    }
    
    return true;
  }
  
  // Login API call
  Future<void> loginPostApi() async {
    // Validate form first
    if (!formKey.currentState!.validate()) {
      return;
    }
    
    // Set loading state
    isLoading.value = true;
    
    try {
      // Prepare login data
      Map<String, dynamic> loginData = {
        'mobileNo': mobileNo.text,
        'password': password.text,
      };
      
      // Make API call
      final response = await apiService.postRequest(
        url: 'https://roughbill.com/api/Login', // Replace with your actual login API endpoint
        data: loginData,
      );
      
      // Handle response
      if (response.statusCode == 200) {
        LoginResponseModel loginResponse = loginResponseModelFromJson(response.body);
        await SharedPrefs.setInt(ConstantsText.clientUserId,loginResponse.clientUserId ?? 0);
        await SharedPrefs.setString(ConstantsText.clientId,loginResponse.clientId ?? "0");
        await SharedPrefs.setBool(ConstantsText.isloggedIn,true);
        await SharedPrefs.setString(ConstantsText.companyName,loginResponse.companyName ?? "");
        await SharedPrefs.setString(ConstantsText.personName,loginResponse.personName ?? "");
        await SharedPrefs.setString(ConstantsText.mobileNumber,loginResponse.mobileNo ?? "");
        await SharedPrefs.setString(ConstantsText.addresss,loginResponse.area ?? "");
        await SharedPrefs.setString(ConstantsText.gstNumber,loginResponse.gstNo ?? "");
        await SharedPrefs.setString(ConstantsText.emailId,loginResponse.emailId ?? "");
        await SharedPrefs.setString(ConstantsText.shopNo,loginResponse.shopNo ?? "");

        // ConstantsText.shopName = loginResponse.companyName ?? "";
        // ConstantsText.mobileNo = loginResponse.mobileNo ?? "";
        // ConstantsText.address = loginResponse.area ?? "";

        // Login successful
        Get.offAllNamed('/billing_options');
      } else {
        // Login failed
        final responseData = response.body;
        Get.snackbar(
          'Login Failed',
          "Invalid mobile number or password.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          colorText: Colors.black,
        );
      }
    } catch (e) {
      // Handle error
      Get.snackbar(
        'Error',
        'Failed to login: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      // Reset loading state
      isLoading.value = false;
    }
  }
}