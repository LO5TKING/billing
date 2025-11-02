import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/forgot_password_controller.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final ForgotPasswordController controller =
  Get.put(ForgotPasswordController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bg_splash.png"),
            fit: BoxFit.fill,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 100),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 100),
            Center(
              child: Text(
                'Forget Password',
                style: GoogleFonts.poppins(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Spacer(),
            const Text(
              "Enter your registered mobile number",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 20),
             TextField(
              keyboardType: TextInputType.phone,
              maxLength: 10,
               decoration: InputDecoration(
                 labelText: 'Mobile No.',
                 counterText: "",
                 border: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(10),
                   borderSide: const BorderSide(color: Colors.black),
                 ),
                 enabledBorder: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(10),
                   borderSide: const BorderSide(color: Colors.black),
                 ),
                 focusedBorder: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(10),
                   borderSide: const BorderSide(color: Colors.black),
                 ),
                 prefixIcon: const Icon(Icons.phone_iphone_outlined),
               ),
              onChanged: controller.onMobileChanged,
            ),
            const SizedBox(height: 20),
            Obx(() => ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: controller.isButtonEnabled.value
                    ? Colors.blue
                    : Colors.grey.shade400,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: controller.isButtonEnabled.value
                  ? controller.sendOtp
                  : null,
              child: controller.isOtpSent.value
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ) : const Text(
                "Send OTP",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            )),
            const SizedBox(height: 20),
            Center(
              child: Obx(() => GestureDetector(
                onTap: controller.isOtpSent.value
                    ? null
                    : controller.sendOtp,
                child: Text(
                  controller.timerText.value,
                  style: TextStyle(
                    color: controller.isOtpSent.value
                        ? Colors.grey
                        : Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}

