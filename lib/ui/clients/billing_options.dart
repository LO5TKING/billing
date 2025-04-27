import 'package:billing/app/config/color_constants.dart';
import 'package:billing/app/config/design_constants.dart';
import 'package:billing/ui/billing/billing.dart';
import 'package:billing/ui/clients/search_add_client_details.dart';
import 'package:billing/ui/guest/add_guest.dart';
import 'package:billing/ui/reports/search_and_reports.dart';
import 'package:billing/ui/return/return_items.dart';
import 'package:billing/ui/settings/setting_options.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

import '../../controllers/scribble_controller.dart';
import '../../utils/utility.dart';

class BillingOptions extends StatelessWidget {
  ScribbleController scribbleController = Get.put(ScribbleController());

  BillingOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            SizedBox(
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(1.5, 7),
                          ),
                        ],
                      ),
                      child: Card(
                        elevation: 5,
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
                                      Get.to(() => const AddGuest());
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
                                    text: 'Return',
                                    icon: Icons.shopping_cart,
                                    onItemTap: () {
                                      Get.to(() => const ReturnItems());
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
                  ),
                  const Spacer(),
                ],
              ),
            ),
            Obx(() => scribbleController.isModelLoading.value
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
                                    scribbleController.downloadStatus.value,
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

/*  clientsDialogBox(){
    return Get.dialog(
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: Get.width * 0.9,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Dialog(
              surfaceTintColor: Colors.white,
              shadowColor: Colors.white,
              elevation: DesignConstants.padding0,
              child: Container(
                color: Colors.white,
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        child:FittedBox(
                          fit: BoxFit.scaleDown,
                          child: shadowText(
                              text: 'Search and add clients',
                            fontsize: DesignConstants.fontSize16,
                          ),
                        )
                    ),
                    Container(
                        padding: const EdgeInsets.symmetric(vertical: DesignConstants.padding15,horizontal: DesignConstants.padding20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          shadowText(text: 'Name',fontsize: DesignConstants.fontSize14),
                          Container(
                              width: Get.width*0.4,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (value){},
                                style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w500,
                                    fontSize: DesignConstants.fontSize12,
                                    color: Colors.black),
                                decoration:InputDecoration(
                                  fillColor: Colors.white,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.grey,
                                    ),
                                    borderRadius: BorderRadius.circular(20)
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.grey,
                                      width: 1.0,
                                    ),
                                      borderRadius: BorderRadius.circular(20)
                                  ),
                                ),
                              ))
                        ],
                      ),
                    ),
                    Container(
                        padding: const EdgeInsets.symmetric(vertical: DesignConstants.padding15,horizontal: DesignConstants.padding20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          shadowText(text: 'Mobile',fontsize: DesignConstants.fontSize14),
                          Container(
                              width: Get.width*0.4,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                onChanged: (value){},
                                style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w500,
                                    fontSize: DesignConstants.fontSize12,
                                    color: Colors.black),
                                decoration:InputDecoration(
                                  fillColor: Colors.white,
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey,
                                      ),
                                      borderRadius: BorderRadius.circular(20)
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(20)
                                  ),
                                ),
                              ))
                        ],
                      ),
                    ),
                    Center(
                      child: InkWell(
                        onTap: (){
                          searchResultDialogBox();
                        },
                        child: Container(
                          height: 40,
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: AppColors.blueGradient,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  blurRadius: 0.4,
                                  offset: const Offset(3, 4)
                              )
                            ]
                          ),
                          child: Center(child: shadowText(text: 'Search',textcolor: Colors.white,fontsize: 16)),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: DesignConstants.padding20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          onTap: (){},
                          child: Container(
                            height: 40,
                            width: 100,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: AppColors.blueGradient,
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      blurRadius: 0.4,
                                      offset: const Offset(3, 4)
                                  )
                                ]
                            ),
                            child: Center(child: shadowText(text: 'Add',textcolor: Colors.white,fontsize: 16)),
                          ),
                        ),
                        InkWell(
                          onTap: (){},
                          child: Container(
                            height: 40,
                            width: 100,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: AppColors.blueGradient,
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      blurRadius: 0.4,
                                      offset: const Offset(3, 4)
                                  )
                                ]
                            ),
                            child: Center(child: shadowText(text: 'Cancel',textcolor: Colors.white,fontsize: 16)),
                          ),
                        ),
                      ],
                    ),

                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }*/

  /*searchResultDialogBox(){
    return Get.dialog(
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: Get.width * 0.9,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Dialog(
              surfaceTintColor: Colors.white,
              shadowColor: Colors.white,
              elevation: DesignConstants.padding0,
              child: Container(
                color: Colors.white,
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        child:FittedBox(
                          fit: BoxFit.scaleDown,
                          child: shadowText(
                            text: 'Clients Details',
                            fontsize: DesignConstants.fontSize16,
                          ),
                        )
                    ),
                    const SizedBox(height: DesignConstants.padding20,),
                    Container(
                      padding: const EdgeInsets.all(DesignConstants.padding5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: AppColors.blueGradient,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          shadowText(text: 'Sr No.',textcolor: Colors.white,fontsize: 14),
                          shadowText(text: 'Name',textcolor: Colors.white,fontsize: 14),
                          shadowText(text: 'Mobile',textcolor: Colors.white,fontsize: 14),
                          shadowText(text: 'Address',textcolor: Colors.white,fontsize: 14),
                        ],
                      ),
                    ),
                    const SizedBox(height: DesignConstants.padding10,),
                    Container(
                      width: Get.width,
                      height: 300,
                      child: ListView.builder(
                          itemCount: 10,
                          itemBuilder: (context,index){
                            return SizedBox(
                              height: 50,
                              width: Get.width,
                              child: Card(
                                elevation: 5,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                    color: Colors.grey,
                                  ),
                                  borderRadius: BorderRadius.circular(10),

                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    noShadowText(text: '123',textcolor: Colors.black,fontsize: 14,fontWeight: FontWeight.w400),
                                    noShadowText(text: 'ABC',textcolor: Colors.black,fontsize: 14,fontWeight: FontWeight.w400),
                                    noShadowText(text: '9874874456',textcolor: Colors.black,fontsize: 14,fontWeight: FontWeight.w400),
                                    noShadowText(text: 'Andheri',textcolor: Colors.black,fontsize: 14,fontWeight: FontWeight.w400),
                                  ],
                                ),
                              ),
                            );
                          }),
                    )

                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }*/
}
