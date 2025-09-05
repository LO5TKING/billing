import 'package:billing/networks/api_service.dart';
import 'package:billing/validation/validation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpController extends GetxController{

  ApiService apiService = ApiService();

  TextEditingController shopName = TextEditingController();
  TextEditingController personName = TextEditingController();
  TextEditingController mobileNo = TextEditingController();
  TextEditingController emailId = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController street = TextEditingController();
  TextEditingController area = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController gstNo = TextEditingController();

  


  // For form validation
  final formKey = GlobalKey<FormState>();
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  // Validate all fields
  bool validateFields() {
    // Clear previous error message
    errorMessage.value = '';
    
    // Validate required fields
    String? shopNameError = Validation.validateShopName(shopName.text);
    String? mobileError = Validation.validateMobileNumber(mobileNo.text);
    String? passwordError = Validation.validatePassword(password.text);
    String? emailError = Validation.validateEmail(emailId.text);
    String? gstError = Validation.validateGSTNumber(gstNo.text);
    
    // If any required field has error
    if (shopNameError != null) {
      errorMessage.value = shopNameError;
      return false;
    } else if (mobileError != null) {
      errorMessage.value = mobileError;
      return false;
    } else if (passwordError != null) {
      errorMessage.value = passwordError;
      return false;
    } else if (emailError != null) {
      errorMessage.value = emailError;
      return false;
    } else if (gstError != null) {
      errorMessage.value = gstError;
      return false;
    }
    
    return true;
  }

  Future<void> registrationPostAPi() async {
    // Validate fields before making API call
    if (!validateFields()) {
      Get.snackbar(
        'Validation Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    // Set loading state
    isLoading.value = true;
    String url = "https://roughbill.com/api/Registration";

    var registrationData = {
      "userId":0,
      'companyName': shopName.text,
      'personName': personName.text,
      'mobileNo': mobileNo.text,
      'emailId': emailId.text,
      'password': password.text,
      'street': street.text,
      'area': area.text,
      'city': city.text,
      'gstNo': gstNo.text,
      "shopNo": "",
      "signU": "",
      "photo": "",
      "state":"",
      "country":"",
      "createdDate": "${DateTime.now().toString().split(' ')[0]}",
      "modifiedDate": "${DateTime.now().toString().split(' ')[0]}",
      "deviceLimit": 0,
      "status": true,
      "clientId": null,
    };
    try {
      final response = await apiService.postRequest(url: url, data: registrationData);

      if (response.statusCode == 200) {
        print('Success: ${response.body}');
        Get.snackbar(
          'Success',
          'Registration successful',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // Navigate back or to login
        Get.back();
      } else {
        print('Error ${response.statusCode}: ${response.body}');
        Get.snackbar(
          'Error',
          'Registration failed: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Exception: $e');
      Get.snackbar(
        'Error',
        'An error occurred during registration',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }













}