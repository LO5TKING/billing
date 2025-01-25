import 'package:billing/app/config/color_constants.dart';
import 'package:billing/app/config/design_constants.dart';
import 'package:billing/ui/clients/billing_options.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/scribble_controller.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          height: Get.height,
          width: Get.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(left: DesignConstants.padding50),
                width: Get.width,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(1, -0.5),
                    end: Alignment(0.9, 0.9),
                    colors: [
                      AppColors.lightBlueGradient,
                      AppColors.blueGradient,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 160),
                    Text(
                      'Welcome',
                      style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: DesignConstants.padding50),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.topRight,
                      colors: [AppColors.lightYelloGradient, Colors.white],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start with this here',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/billing.png',
                              height: 400,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(
                              height: DesignConstants.padding10,
                            ),
                            Text(
                              'Rough Bill',
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      blurRadius: 1,
                                      offset: const Offset(3, 6)),
                                ],
                              ),
                            ),
                            Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: DesignConstants.padding20),
                                height: DesignConstants.padding50,
                                width: DesignConstants.padding50,
                                alignment: Alignment.center,
                                child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      elevation: DesignConstants.padding20,
                                      padding: EdgeInsets.zero,
                                      backgroundColor: Colors.white,
                                      iconColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                      ),
                                    ),
                                    onPressed: () {
                                      Get.to(() =>const BillingOptions());
                                    },
                                    label: const Center(
                                        child: Icon(
                                      Icons.arrow_forward,
                                      size: 20,
                                    ))
                                )
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
