import 'package:billing/networks/api_service.dart';
import 'package:flutter/cupertino.dart';
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


  Future<void>registrationPostAPi() async {
    String url = "";
    var registrationData = {
      'shopname': shopName.text,
      'personname': personName.text,
      'mobileno': mobileNo.text,
      'emailid': emailId.text,
      'password': password.text,
      'street': street.text,
      'area': area.text,
      'city': city.text,
      'gtno': gstNo.text,
    };


    final response = await apiService.postRequest(url: url, data: registrationData);

    if (response.statusCode == 200) {
      print('Success: ${response.body}');
    } else {
      print('Error ${response.statusCode}: ${response.body}');
    }


  }













}