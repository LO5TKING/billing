import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/config/color_constants.dart';
import '../../app/config/design_constants.dart';
import '../../utils/utility.dart';

class AddGuest extends StatelessWidget {
  AddGuest({super.key});

  TextEditingController nameController = TextEditingController(text: "Guest");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: Get.height*0.1,
              ),
              Card(
                elevation: 20,
                color: Colors.white,
                child: Container(
                  width: Get.width * 0.9,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: DesignConstants.padding10,
                      vertical: DesignConstants.padding20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: shadowText(
                          text: 'Add Guest',
                          fontsize: DesignConstants.fontSize16,
                        ),
                      )),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: DesignConstants.padding15,horizontal: DesignConstants.padding20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            shadowText(text: 'Name',fontsize: DesignConstants.fontSize16,fontWeight: FontWeight.w400),
                            Container(
                                width: Get.width*0.4,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: TextFormField(
                                  keyboardType: TextInputType.emailAddress,
                                  onChanged: (value){

                                  },
                                  controller: nameController,
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
                            shadowText(text: 'Mobile',fontsize: DesignConstants.fontSize16,fontWeight: FontWeight.w400),
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
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: DesignConstants.padding15,horizontal: DesignConstants.padding20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            shadowText(text: 'GST No.',fontsize: DesignConstants.fontSize16,fontWeight: FontWeight.w400),
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
                            shadowText(text: 'Address',fontsize: DesignConstants.fontSize16,fontWeight: FontWeight.w400),
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
                      const SizedBox(
                        height: DesignConstants.padding20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          InkWell(
                            onTap: () {},
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
                                        offset: const Offset(3, 4))
                                  ]),
                              child: Center(
                                  child: shadowText(
                                      text: 'Ok',
                                      textcolor: Colors.white,
                                      fontsize: 16)),
                            ),
                          ),
                          InkWell(
                            onTap: () {},
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
                                        offset: const Offset(3, 4))
                                  ]),
                              child: Center(
                                  child: shadowText(
                                      text: 'Cancel',
                                      textcolor: Colors.white,
                                      fontsize: 16)),
                            ),
                          ),
                        ],
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
