import 'package:billing/app/config/color_constants.dart';
import 'package:billing/app/config/design_constants.dart';
import 'package:billing/controllers/billing_controller_new.dart';
import 'package:billing/controllers/order_controller_new.dart';
import 'package:billing/controllers/purchase_controller.dart';
import 'package:billing/ui/billing/billing.dart';
import 'package:billing/ui/clients/search_add_client_details.dart';
import 'package:billing/ui/guest/add_guest.dart';
import 'package:billing/ui/purchase/purchase.dart';
import 'package:billing/ui/reports/report.dart';
import 'package:billing/ui/return/return_items.dart';
import 'package:billing/ui/settings/setting_options.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

import '../../controllers/order_controller.dart';
import '../../controllers/billing_controller.dart';
import '../../utils/utility.dart';
import '../order/order.dart';

class BillingOptions extends StatelessWidget {
  // Use lazy initialization with Get.find() instead of Get.put() to prevent unnecessary initialization
  late final BillingController billingController;
  late final BillingControllerNew billingControllerNew;
  late final OrderController orderController;
  late final OrderControllerNew orderControllerNew;
  late final PurchaseController purchaseController;

  BillingOptions({super.key}){
    _initControllers();

  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.peachColor,
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage("assets/bg_splash.png")),
              ),
              height: Get.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),
                  const Spacer(),
                  Center(
                    child: Container(
                      height: Get.height * 0.75,
                      width: Get.width * 0.95,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(DesignConstants.padding20),
                        // boxShadow: [
                        //   BoxShadow(
                        //     color: Colors.grey.withOpacity(0.5),
                        //     spreadRadius: 5,
                        //     blurRadius: 7,
                        //     offset: const Offset(1.5, 7),
                        //   ),
                        // ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(
                                left: DesignConstants.padding20,
                                top: DesignConstants.padding30),
                            child: shadowText(
                              text: 'Billing Options',
                              fontsize: DesignConstants.fontSize24,
                              textcolor: Colors.white
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              billingOptionsBlock(
                                  text: 'My Clients',
                                  icon: Icons.people_alt_sharp,
                                  onItemTap: () {
                                    Get.to(() => SearchAddClientDetails());
                                  }),
                              billingOptionsBlock(
                                  text: 'Guest',
                                  icon: Icons.person,
                                  onItemTap: () {
                                    Get.to(() => AddGuest());
                                  }),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              billingOptionsBlock(
                                  text: 'Bills',
                                  icon: Icons.file_copy_outlined,
                                  onItemTap: () {
                                    Get.to(() => Billing());
                                  }),
                              billingOptionsBlock(
                                  text: 'Orders',
                                  icon: Icons.edit,
                                  onItemTap: () {
                                    Get.to(() => Order());
                                  }),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              billingOptionsBlock(
                                  text: 'Purchase',
                                  icon: Icons.book,
                                  onItemTap: () {
                                    Get.to(() => Purchase());
                                  }),
                              billingOptionsBlock(
                                  text: 'Reports',
                                  icon: Icons.folder_copy_outlined,
                                  onItemTap: () {
                                    Get.to(() => SearchAndReports());
                                  }),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              billingOptionsBlock(
                                  text: 'Queue',
                                  icon: Icons.queue,
                                  onItemTap: () {
                                    // Get.to(() => const ReturnItems());
                                  }),
                              billingOptionsBlock(
                                  text: 'Settings',
                                  icon: Icons.settings_suggest_rounded,
                                  onItemTap: () {
                                    Get.to(() => const SettingOptions());
                                  }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            Obx(() => billingController.isModelLoading.value
                ? BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                      child: Center(
                        child: Container(
                          width: Get.width * 0.8,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.3)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 20),
                              Obx(() => Text(
                                    billingController.downloadStatus.value,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  Widget billingOptionsBlock(
      {required String text,
      required IconData icon,
      required void Function() onItemTap}) {
    return InkWell(
      onTap: onItemTap,
      child: Column(
        children: <Widget>[
          Icon(
            icon,
            color: AppColors.blueGradient,
            size: 100,
            shadows: [
              Shadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(3, 7)),
            ],
          ),
          const SizedBox(
            height: DesignConstants.padding5,
          ),
          shadowText(
            text: text,
            fontsize: 18,
          ),
        ],
      ),
    );
  }

  // Initialize controllers only when needed
  void _initControllers() {
    try {
      if (!Get.isRegistered<BillingController>()) {
        Get.lazyPut<BillingController>(() => BillingController(), fenix: true);
        billingController = Get.find<BillingController>();
      } else {
        billingController = Get.find<BillingController>();
      }
      
      if (!Get.isRegistered<BillingControllerNew>()) {
        Get.lazyPut<BillingControllerNew>(() => BillingControllerNew(), fenix: true);
        billingControllerNew = Get.find<BillingControllerNew>();
      } else {
        billingControllerNew = Get.find<BillingControllerNew>();
      }

      if (!Get.isRegistered<OrderController>()) {
        Get.lazyPut<OrderController>(() => OrderController(), fenix: true);
        orderController = Get.find<OrderController>();
      } else {
        orderController = Get.find<OrderController>();
      }
      if (!Get.isRegistered<OrderControllerNew>()) {
        Get.lazyPut<OrderControllerNew>(() => OrderControllerNew(), fenix: true);
        orderControllerNew = Get.find<OrderControllerNew>();
      } else {
        orderControllerNew = Get.find<OrderControllerNew>();
      }

      if (!Get.isRegistered<PurchaseController>()) {
        Get.lazyPut<PurchaseController>(() => PurchaseController(), fenix: true);
        purchaseController = Get.find<PurchaseController>();
      } else {
        purchaseController = Get.find<PurchaseController>();
      }
    } catch (e) {
      print('Error initializing controllers: $e');
    }
  }
}

