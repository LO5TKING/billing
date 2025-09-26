import 'dart:convert';

import 'package:billing/app/config/constants_text.dart';
import 'package:billing/model/customer_response_model.dart';
import 'package:billing/model/purchaser_response_model.dart';
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
  Rx<CustomerResponseModel?> customerResponse = Rx<CustomerResponseModel?>(null);
  RxList<Datum> filteredClientList = <Datum>[].obs;
  List<Datum> get clientList => filteredClientList;

  Rx<PurchaserResponseModel?> purchaseResponse = Rx<PurchaserResponseModel?>(null);
  RxList<PurchaserData> filteredpurchaseList = <PurchaserData>[].obs;
  List<PurchaserData> get purchaseList => filteredpurchaseList;
  RxBool addPurchaser = false.obs;
  RxBool loadingClient = true.obs;




  @override
  void onInit() {
    super.onInit();
    getClients();
    
    // Add listeners to search controllers
    searchNameController.addListener(() {
      addPurchaser.value ? filterPurchaser() : filterClients();
    });
    
    searchMobileController.addListener(() {
      addPurchaser.value ? filterPurchaser() : filterClients();
    });
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
  Future<void> addClientPostApi() async {
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

  void updateClientPostApi({
    int? custId,
    String? name,
    String? mobileNo,
    String? gstNo,
    String? emailId,
    String? address,

  }) async {
      isLoading.value = true;
      String url = "https://roughbill.com/api/Customer/update";
      String? clientId = SharedPrefs.getString(ConstantsText.clientId);
      int? clientUserId = SharedPrefs.getInt(ConstantsText.clientUserId);

      try {
        Map<String, dynamic> data = {
          'custId':custId,
          'name': name,
          'mobileNo': mobileNo,
          'gstNo': gstNo,
          'emailId': emailId,
          'address': address,
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

  void updatePurchaserPostApi({
    int? purId,
    String? name,
    String? mobileNo,
    String? gstNo,
    String? emailId,
    String? address,

  }) async {
    isLoading.value = true;
    String url = "https://roughbill.com/api/Purchaser/update";
    String? clientId = SharedPrefs.getString(ConstantsText.clientId);
    int? clientUserId = SharedPrefs.getInt(ConstantsText.clientUserId);

    try {
      Map<String, dynamic> data = {
        'purchaserId':purId,
        'purchaserName': name,
        'mobileNo': mobileNo,
        'gstNo': gstNo,
        'emailId': emailId,
        'address': address,
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

  Future<void> addPurchaserPostApi() async {
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
  Future<void> getClients() async {
    loadingClient.value = true;
    String? clientId = SharedPrefs.getString(ConstantsText.clientId);
    int? clientUserId = SharedPrefs.getInt(ConstantsText.clientUserId);
    String url = "https://roughbill.com/api/Customer/GetCustomer?clientId=$clientId&ClientUserId=$clientUserId";

    try {
      var response = await apiService.getRequest(url: url);

      if (response.statusCode == 200) {
        // Parse the response directly into the observable
        customerResponse.value = customerResponseModelFromJson(response.body);
        
        // Initialize filtered list with all clients
        filteredClientList.value = customerResponse.value?.data ?? [];

        loadingClient.value = false;
      } else {
        loadingClient.value = false;
        customerResponse.value = null; // Clear data on error
        filteredClientList.clear();
        Get.snackbar(
          'Error',
          'Failed to search clients',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.grey,
          colorText: Colors.black,
        );
      }
    } catch (e) {
      customerResponse.value = null; // Clear data on error
      filteredClientList.clear();
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

  Future<void> getPurchaser() async {
    loadingClient.value = true;
    String? clientId = SharedPrefs.getString(ConstantsText.clientId);
    int? clientUserId = SharedPrefs.getInt(ConstantsText.clientUserId);
    String url = "https://roughbill.com/api/Purchaser/pruchaserget?clientId=$clientId&ClientUserId=$clientUserId";

    try {
      var response = await apiService.getRequest(url: url);

      if (response.statusCode == 200) {
        // Parse the response directly into the observable
        purchaseResponse.value = purchaserResponseModelFromJson(response.body);

        // Initialize filtered list with all clients
        filteredpurchaseList.value = purchaseResponse.value?.data ?? [];

        loadingClient.value = false;
      } else {
        loadingClient.value = false;
        purchaseResponse.value = null; // Clear data on error
        filteredpurchaseList.clear();
        Get.snackbar(
          'Error',
          'Failed to search purchaser',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.grey,
          colorText: Colors.black,
        );
      }
    } catch (e) {
      purchaseResponse.value = null; // Clear data on error
      filteredpurchaseList.clear();
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

  void deleteClients(String? custId) async {
    String? clientId = SharedPrefs.getString(ConstantsText.clientId);
    int? clientUserId = SharedPrefs.getInt(ConstantsText.clientUserId);
    String url = "https://roughbill.com/api/Customer/delete";

    Map<String,dynamic> data = {
      "custId": custId,
      "clientId": clientId,
      "clientUserId": clientUserId
    };
    try {

      var response = await apiService.postRequest(url: url,data: data);

      if(response.statusCode == 200){
        Get.snackbar(
          'Success',
          'Customer Deleted Successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }catch (e){
      print("error in deleting customer is $e");
    }



  }

  void deletePurchaser(int? custId) async {
    String? clientId = SharedPrefs.getString(ConstantsText.clientId);
    int? clientUserId = SharedPrefs.getInt(ConstantsText.clientUserId);
    String url = "https://roughbill.com/api/Purchaser/deletepurchaser";

    Map<String,dynamic> data = {
      "purchaserId": custId,
      "clientId": clientId,
      "clientUserId": (clientUserId)
    };
    try {

      var response = await apiService.postRequest(url: url,data: data);

      if(response.statusCode == 200){
        Get.snackbar(
          'Success',
          'Customer Deleted Successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }catch (e){
      print("error in deleting purchaser is $e");
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

  // Filter clients based on search criteria
  void filterClients() {
    String nameQuery = searchNameController.text.toLowerCase().trim();
    String mobileQuery = searchMobileController.text.toLowerCase().trim();
    
    if (nameQuery.isEmpty && mobileQuery.isEmpty) {
      // If both search fields are empty, show all clients
      filteredClientList.value = customerResponse.value?.data ?? [];
      return;
    }
    
    // Filter the list based on name or mobile number
    List<Datum> filtered = (customerResponse.value?.data ?? []).where((client) {
      bool nameMatch = nameQuery.isEmpty || 
          (client.name?.toLowerCase().contains(nameQuery) ?? false);
      
      bool mobileMatch = mobileQuery.isEmpty || 
          (client.mobileNo?.toLowerCase().contains(mobileQuery) ?? false);
      
      // If only name is provided, filter by name only
      if (nameQuery.isNotEmpty && mobileQuery.isEmpty) {
        return nameMatch;
      }
      
      // If only mobile is provided, filter by mobile only
      if (mobileQuery.isNotEmpty && nameQuery.isEmpty) {
        return mobileMatch;
      }
      
      // If both are provided, match both criteria
      return nameMatch && mobileMatch;
    }).toList();
    
    filteredClientList.value = filtered;
  }

  void filterPurchaser() {
    String nameQuery = searchNameController.text.toLowerCase().trim();
    String mobileQuery = searchMobileController.text.toLowerCase().trim();

    if (nameQuery.isEmpty && mobileQuery.isEmpty) {
      // If both search fields are empty, show all clients
      filteredpurchaseList.value = purchaseResponse.value?.data ?? [];
      return;
    }

    // Filter the list based on name or mobile number
    List<PurchaserData> filtered = (purchaseResponse.value?.data ?? []).where((client) {
      bool nameMatch = nameQuery.isEmpty ||
          (client.purchaserName?.toLowerCase().contains(nameQuery) ?? false);

      bool mobileMatch = mobileQuery.isEmpty ||
          (client.mobileNo?.toLowerCase().contains(mobileQuery) ?? false);

      // If only name is provided, filter by name only
      if (nameQuery.isNotEmpty && mobileQuery.isEmpty) {
        return nameMatch;
      }

      // If only mobile is provided, filter by mobile only
      if (mobileQuery.isNotEmpty && nameQuery.isEmpty) {
        return mobileMatch;
      }

      // If both are provided, match both criteria
      return nameMatch && mobileMatch;
    }).toList();

    filteredpurchaseList.value = filtered;
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