import 'package:billing/model/registration_response_model.dart';
import 'package:billing/networks/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/config/constants_text.dart';
import '../../../utils/shared_pref.dart';

class ProfileSettingController extends GetxController{

  RxBool edit = false.obs;
  TextEditingController companyName = TextEditingController();

  TextEditingController personName = TextEditingController();

  TextEditingController mobileNumber = TextEditingController();

  TextEditingController address = TextEditingController();

  TextEditingController gstNumber = TextEditingController();

  TextEditingController emailId = TextEditingController();

  TextEditingController password = TextEditingController();

  RxBool loading = false.obs;

  Rx<RegistrationDetailResponseModel?> profileData = Rx<RegistrationDetailResponseModel?>(null);
  RxBool loadingProfile = true.obs;

  ApiService apiService = ApiService();

  @override
  void onInit() {
    super.onInit();
    getProfileData();
  }


  Future<void> profileUpdate() async {

    loading.value = true;

    String? clientId = SharedPrefs.getString(ConstantsText.clientId);
    int? clientUserId = SharedPrefs.getInt(ConstantsText.clientUserId);
    String? mobileNumber = SharedPrefs.getString(ConstantsText.mobileNumber);
    String? shopNumber = SharedPrefs.getString(ConstantsText.shopNo);
    String? gstNumer = SharedPrefs.getString(ConstantsText.gstNumber);
    String url = "https://roughbill.com/api/Registration/Update";

    Map<String,dynamic> data =
      {
        "userId": clientId,
        "companyName": companyName.text,
        "personName": personName.text,
        "mobileNo": mobileNumber,
        "emailId": emailId.text,
        "shopNo": shopNumber,
        "street": "Juhu Tara Road",
        "area": address.text,
        "city": "Mumbai",
        "state": "Maharashtra",
        "country": "India",
        "gstNo": gstNumber.text != "" ? gstNumber.text : gstNumer ,
        "signU": "rahulgupta_signature.png",
        "photo": "rahulgupta_profile.jpg",
        "createdDate": "${DateTime.now().toString().split(' ')[0]}",
        "modifiedDate": "${DateTime.now().toString().split(' ')[0]}",
        "deviceLimit": 2,
        "status": true,
        "clientId":clientId ,
        "password": password.text
    };
    try {

      var response = await apiService.postRequest(url: url,data: data);

      if(response.statusCode == 200){
        loading.value = false;
        await getProfileData();
        Get.snackbar(
          'Success',
          'Customer Updated Successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }catch (e){
      print("error in Customer Updated is $e");
    } finally{
      loading.value = false;
    }

  }

  Future<RegistrationDetailResponseModel?> getProfileData() async {
    loadingProfile.value = true;
    String? clientId = SharedPrefs.getString(ConstantsText.clientId);
    int? clientUserId = SharedPrefs.getInt(ConstantsText.clientUserId);
    String url = "https://roughbill.com/api/Registration/getregistrationdetail?clientId=$clientId&clientUserId=$clientUserId";

    try {
      var response = await apiService.getRequest(url: url);

      if (response.statusCode == 200) {
        // Parse the response directly into the observable
        profileData.value = registrationDetailResponseModelFromJson(response.body);

        ConstantsText.shopName = profileData.value?.companyName ?? "";
        ConstantsText.mobileNo = profileData.value?.mobileNo ?? "";
        ConstantsText.address = profileData.value?.area ?? "";

        loadingProfile.value = false;
        companyName.text = profileData.value?.companyName ?? "";
        personName.text = profileData.value?.personName ?? "";
        mobileNumber.text = profileData.value?.mobileNo ?? "";
        address.text = profileData.value?.area ?? "";
        gstNumber.text = profileData.value?.gstNo ?? "";
        emailId.text = profileData.value?.emailId ?? "";
        password.text = profileData.value?.password ?? "";

        return profileData.value;
      } else {
        profileData.value = null; // Clear data on error
        Get.snackbar(
          'Error',
          'Failed to fetch profile details',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      profileData.value = null; // Clear data on error
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