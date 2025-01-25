import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/config/color_constants.dart';
import '../../app/config/design_constants.dart';
import '../../utils/utility.dart';

class PurchaseSettings extends StatelessWidget {
  const PurchaseSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: InkWell(
            onTap: (){
              Get.back();
            },
            child: const Icon(Icons.arrow_back_ios_new,color: Colors.grey,)),
      ),
      body: Container(
        height: Get.height,
        padding: const EdgeInsets.symmetric(horizontal: DesignConstants.padding20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            shadowText(text: 'Settings',textcolor: Colors.black),
            const SizedBox(
              height: DesignConstants.padding10,
            ),
            Flexible(
              child: Container(
                height: Get.height,
                padding: const EdgeInsets.symmetric(horizontal: DesignConstants.padding20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: DesignConstants.padding10,
                    ),
                    Card(
                      elevation: 20,
                      child: Container(
                        padding: const EdgeInsets.all(DesignConstants.padding20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(DesignConstants.padding20),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.lightPurpleGradient,
                              Colors.white,
                            ],
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.shopping_basket,size: 40,color: AppColors.blueGradient,),
                                const SizedBox(width: DesignConstants.padding20,),
                                shadowText(text: 'Purchase'),

                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: DesignConstants.padding30,vertical: DesignConstants.padding10),
                              child: Row(
                                children: [
                                  Container(
                                    height: DesignConstants.padding10,
                                    width: DesignConstants.padding10,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(width: DesignConstants.padding10,),
                                  Container(
                                    child: shadowText(text: 'Printer',fontWeight: FontWeight.w400),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: DesignConstants.padding30,vertical: DesignConstants.padding10),
                              child: Row(
                                children: [
                                  Container(
                                    height: DesignConstants.padding10,
                                    width: DesignConstants.padding10,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(width: DesignConstants.padding10,),
                                  Container(
                                    child: shadowText(text: 'Pen',fontWeight: FontWeight.w400),
                                  )
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
            )

          ],
        ),
      ),
    );
  }
}