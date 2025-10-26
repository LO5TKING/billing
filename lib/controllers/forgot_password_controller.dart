import 'dart:async';
import 'package:billing/networks/api_service.dart';
import 'package:billing/ui/auth/login_screen.dart';
import 'package:billing/ui/auth/otp_verify_screen.dart';
import 'package:billing/ui/auth/reset_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  // --- Existing Fields ---
  final mobileNumber = ''.obs;
  final otp = ''.obs;

  final isButtonEnabled = false.obs;
  final isOtpSent = false.obs;
  final isVerifying = false.obs;
  final timerText = 'Resend OTP in 60s'.obs;

  // --- New Fields for Reset Password ---
  final password = ''.obs;
  final confirmPassword = ''.obs;
  final isSubmitting = false.obs;

  Timer? _timer;
  int _seconds = 60;

  ApiService apiService = ApiService();

  // --- Mobile Number ---
  void onMobileChanged(String value) {
    mobileNumber.value = value;
    isButtonEnabled.value = value.length == 10;
  }

  // --- OTP ---
  Future<void> sendOtp() async {
    if (!isButtonEnabled.value) return;
    isOtpSent.value = true;
    startTimer();
    Map<String, dynamic> loginData = {
      'mobileno': mobileNumber.value,
    };
    try {
      final response = await apiService.postRequest(
        url: 'https://roughbill.com/api/Login/SendOtp', // Replace with your actual login API endpoint
        data: loginData,
      );
      if(response.statusCode == 200){
        isOtpSent.value = false;
        Get.snackbar("OTP Sent", "OTP sent to ${mobileNumber.value}",
            snackPosition: SnackPosition.BOTTOM);
        Get.to(() => OtpVerificationScreen());
      }
    } catch (e) {

    }
  }

  void startTimer() {
    _seconds = 60;
    timerText.value = 'Resend OTP in $_seconds s';
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds--;
      if (_seconds > 0) {
        timerText.value = 'Resend OTP in $_seconds s';
      } else {
        timerText.value = 'Resend OTP';
        isOtpSent.value = false;
        timer.cancel();
      }
    });
  }

  void onOtpChanged(String value) {
    otp.value = value;
  }

  Future<void> verifyOtp() async {
    if (otp.value.length != 4) {
      Get.snackbar("Error", "Please enter a valid 4-digit OTP");
      return;
    }

    isVerifying.value = true;

    Map<String, dynamic> loginData = {
      'mobileNo': mobileNumber.value,
      'otpNo':otp.value
    };
    try {
      final response = await apiService.postRequest(
        url: 'https://roughbill.com/api/Login/VerifyOtp', // Replace with your actual login API endpoint
        data: loginData,
      );
      if(response.statusCode == 200){
        isVerifying.value = false;
        Get.to(() => ResetPasswordScreen());
        Get.snackbar("Success", "OTP Verified Successfully",
            snackPosition: SnackPosition.BOTTOM);
      }else {
        Get.snackbar("Invalid OTP", "Please try again");
      }
    } catch (e) {

    }
  }

  // --- Password Reset ---
  void onPasswordChanged(String value) {
    password.value = value;
  }

  void onConfirmPasswordChanged(String value) {
    confirmPassword.value = value;
  }

  Future<void> submitNewPassword() async {
    if (password.value.isEmpty || confirmPassword.value.isEmpty) {
      Get.snackbar("Error", "Please fill in all fields");
      return;
    }

    if (password.value != confirmPassword.value) {
      Get.snackbar("Error", "Passwords do not match ❌");
      return;
    }

    isSubmitting.value = true;

    // Simulate API call delay
    Map<String, dynamic> loginData = {
      'mobileNo': mobileNumber.value,
      'password':password.value
    };
    try {
      final response = await apiService.postRequest(
        url: 'https://roughbill.com/api/Login/SetPassword', // Replace with your actual login API endpoint
        data: loginData,
      );
      if(response.statusCode == 200){
        isSubmitting.value = false;
        Get.to(() => LoginScreen());
        Get.snackbar("Success", "Password Changed Successfully",
            snackPosition: SnackPosition.BOTTOM);
      }else {
        Get.snackbar("Error", "Something went wrong please try again later");
      }
    } catch (e) {

    }

    await Future.delayed(const Duration(seconds: 2));

    // Mock success
    Get.snackbar("Success", "Password reset successfully ✅",
        snackPosition: SnackPosition.BOTTOM);

    isSubmitting.value = false;

    // Navigate back or to login
    // Get.offAllNamed('/login');
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
