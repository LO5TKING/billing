import 'package:billing/app/config/color_constants.dart';
import 'package:billing/app/config/design_constants.dart';
import 'package:billing/controllers/login_controller.dart';
import 'package:billing/ui/auth/signup_screen.dart';
import 'package:billing/validation/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../clients/billing_options.dart';

class LoginScreen extends StatelessWidget {
  final LoginController loginController = Get.put(LoginController());
  
  LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/bg_splash.png"),
              fit: BoxFit.fill,
            ),
          ),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.all(DesignConstants.padding20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 100),
                Text(
                  'Login Account',
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.all(DesignConstants.padding20),
                  child: Form(
                    key: loginController.formKey,
                    child: Column(
                    children: [
                      TextFormField(
                        controller: loginController.mobileNo,
                        validator: Validation.validateMobileNumber,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Mobile No.',
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
                      TextFormField(
                        controller: loginController.password,
                        validator: Validation.validatePassword,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
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
                          prefixIcon: const Icon(Icons.lock),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Obx(() => ElevatedButton(
                        onPressed: loginController.isLoading.value
                            ? null
                            : () async {
                                await loginController.loginPostApi();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blueGradient,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: loginController.isLoading.value
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      )),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Get.to(() => SignupScreen());
                        },
                        child: const Text(
                          "Don't have an account? Sign Up",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  )),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
