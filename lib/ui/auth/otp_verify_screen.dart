import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/forgot_password_controller.dart';

class OtpVerificationScreen extends StatelessWidget {
  final ForgotPasswordController controller =
  Get.find<ForgotPasswordController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          children: [
            const SizedBox(height: 100),
            Text(
              'Verify Otp',
              style: GoogleFonts.poppins(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            Spacer(),
            Text(
              'Enter the 6-digit OTP sent to your mobile number',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 30),

            // OTP Input Fields
            TextField(
              maxLength: 4,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              onChanged: controller.onOtpChanged,
              decoration: InputDecoration(
                labelText: 'Enter OTP',
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
            ),

            const SizedBox(height: 20),

            // Verify Button
            Obx(() => ElevatedButton(
              onPressed: controller.isVerifying.value
                  ? null
                  : controller.verifyOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: controller.isVerifying.value
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Text(
                "Verify OTP",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            )),

            const SizedBox(height: 20),

            // Timer + Resend link
            Obx(() => GestureDetector(
              onTap: controller.isOtpSent.value
                  ? null
                  : controller.sendOtp, // resend OTP
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
            Spacer()
          ],
        ),
      ),
    );
  }
}
