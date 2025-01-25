import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/config/color_constants.dart';
import '../../app/config/design_constants.dart';
import '../../utils/utility.dart';

class AboutUsSettings extends StatelessWidget {
  const AboutUsSettings({super.key});

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
                        height: 300,
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
                                const Icon(Icons.info,size: 40,color: AppColors.blueGradient,),
                                const SizedBox(width: DesignConstants.padding20,),
                                shadowText(text: 'About Us'),

                              ],
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