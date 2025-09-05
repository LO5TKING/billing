import 'package:billing/app/config/color_constants.dart';
import 'package:billing/app/config/design_constants.dart';
import 'package:billing/controllers/signup_controller.dart';
import 'package:billing/validation/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupScreen extends StatelessWidget {
  SignUpController signUpController = Get.put(SignUpController());

  SignupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
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
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Create Account',
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: DesignConstants.padding20),
                    child: Form(
                        key: signUpController.formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                "Shop Name *",
                                style: headerTextStyleWhite(),
                              ),
                            ),
                            TextFormField(
                              controller: signUpController.shopName,
                              validator: Validation.validateShopName,
                              decoration: InputDecoration(
                                hintText: 'Shop Name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.black),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.black),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.black),
                                ),
                                prefixIcon: const Icon(Icons.person),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                "Person Name *",
                                style: headerTextStyleWhite(),
                              ),
                            ),
                            TextFormField(
                              controller: signUpController.personName,
                              validator: Validation.validatePersonName,
                              decoration: InputDecoration(
                                hintText: 'Person Name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.black),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.black),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.black),
                                ),
                                prefixIcon: const Icon(Icons.person),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                "Mobile Number *",
                                style: headerTextStyleWhite(),
                              ),
                            ),
                            TextFormField(
                              controller: signUpController.mobileNo,
                              validator: Validation.validateMobileNumber,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                hintText: 'Mobile No.',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.black),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.black),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.black),
                                ),
                                prefixIcon:
                                    const Icon(Icons.phone_iphone_outlined),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                "Email *",
                                style: headerTextStyleWhite(),
                              ),
                            ),
                            TextFormField(
                              controller: signUpController.emailId,
                              validator: Validation.validateEmail,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                hintText: 'Email Id.',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.black),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.black),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.black),
                                ),
                                prefixIcon:
                                    const Icon(Icons.phone_iphone_outlined),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                "Password *",
                                style: headerTextStyleWhite(),
                              ),
                            ),
                            TextFormField(
                              controller: signUpController.password,
                              validator: Validation.validatePassword,
                              obscureText: true,
                              decoration: InputDecoration(
                                hintText: 'Password',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.black),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.black),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.black),
                                ),
                                prefixIcon: const Icon(Icons.lock),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                "Confirm Password *",
                                style: headerTextStyleWhite(),
                              ),
                            ),
                            TextFormField(
                              validator: (value) =>
                                  Validation.validateConfirmPassword(
                                      value, signUpController.password.text),
                              obscureText: true,
                              decoration: InputDecoration(
                                hintText: 'Confirm Password',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.black),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.black),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.black),
                                ),
                                prefixIcon: const Icon(Icons.lock),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                "Street",
                                style: headerTextStyleWhite(),
                              ),
                            ),
                            TextFormField(
                              controller: signUpController.street,
                              validator: Validation.validateStreet,
                              decoration: InputDecoration(
                                hintText: 'Street',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.black),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.black),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.black),
                                ),
                                prefixIcon: const Icon(Icons.person),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                "Area",
                                style: headerTextStyleWhite(),
                              ),
                            ),
                            TextFormField(
                              controller: signUpController.area,
                              validator: Validation.validateArea,
                              decoration: InputDecoration(
                                hintText: 'Area',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.black),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.black),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.black),
                                ),
                                prefixIcon: const Icon(Icons.person),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                "City",
                                style: headerTextStyleWhite(),
                              ),
                            ),
                            TextFormField(
                              controller: signUpController.city,
                              validator: Validation.validateCity,
                              decoration: InputDecoration(
                                hintText: 'City',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.black),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.black),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.black),
                                ),
                                prefixIcon: const Icon(Icons.person),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                "GST Number",
                                style: headerTextStyleWhite(),
                              ),
                            ),
                            TextFormField(
                              controller: signUpController.gstNo,
                              validator: Validation.validateGSTNumber,
                              keyboardType: TextInputType.streetAddress,
                              decoration: InputDecoration(
                                hintText: 'Gst No.',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.black),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.black),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.black),
                                ),
                                prefixIcon:
                                    const Icon(Icons.phone_iphone_outlined),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Center(
                              child: Obx(
                                () => ElevatedButton(
                                  onPressed: signUpController.isLoading.value
                                      ? null
                                      : () async {
                                          await signUpController
                                              .registrationPostAPi();
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
                                  child: signUpController.isLoading.value
                                      ? const CircularProgressIndicator(
                                          color: Colors.white)
                                      : const Text(
                                          'Sign Up',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  Get.back();
                                },
                                child: const Text(
                                  "Already have an account? Login",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            // const SizedBox(height: 150,)
                          ],
                        )),
                  ),
                  // const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextStyle headerTextStyleWhite() {
    return GoogleFonts.poppins(
        color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold);
  }

  TextStyle headerTextStyleBlack() {
    return GoogleFonts.poppins(
        color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold);
  }
}
