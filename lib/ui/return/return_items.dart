import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/config/color_constants.dart';
import '../../app/config/design_constants.dart';
import '../../utils/utility.dart';

class ReturnItems extends StatelessWidget {
  const ReturnItems({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        height: Get.height,
        width: Get.width,
        child: Column(
          children: [
            const Spacer(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Card(
                  elevation: 20,
                  color: Colors.white,
                  child: Container(
                    width: Get.width * 0.9,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal:  DesignConstants.padding10,vertical: DesignConstants.padding20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: shadowText(
                            text: 'Return Items',
                            fontsize: DesignConstants.fontSize16,
                          ),
                        ),
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
                                    onChanged: (value){},
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w500,
                                        fontSize: DesignConstants.fontSize12,
                                        color: Colors.black),
                                    decoration:InputDecoration(
                                      fillColor: Colors.white,
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Colors.grey,
                                          ),
                                          borderRadius: BorderRadius.circular(20)
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
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
                                          borderSide: const BorderSide(
                                            color: Colors.grey,
                                          ),
                                          borderRadius: BorderRadius.circular(20)
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
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
                          height: DesignConstants.padding10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            shadowText(text: 'Date From',fontsize: DesignConstants.fontSize16,fontWeight: FontWeight.w400),
                            Container(
                              height: 40,
                              width: 100,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white
                              ),
                              child: Card(
                                elevation: 5,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                    color: Colors.grey,
                                  ),
                                  borderRadius: BorderRadius.circular(20),

                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    shadowText(text: '08/12/24',fontsize: 12,fontWeight: FontWeight.w400),
                                    const Icon(Icons.calendar_month),
                                  ],
                                ),
                              ),
                            ),
                            shadowText(text: 'To',fontsize: DesignConstants.fontSize16,fontWeight: FontWeight.w400),
                            Container(
                              height: 40,
                              width: 100,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white
                              ),
                              child: Card(
                                elevation: 5,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                    color: Colors.grey,
                                  ),
                                  borderRadius: BorderRadius.circular(20),

                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    shadowText(text: '08/12/24',fontsize: 12,fontWeight: FontWeight.w400),
                                    const Icon(Icons.calendar_month),
                                  ],
                                ),
                              ),
                            ),
                          ],
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
                                child: Center(child: shadowText(text: 'Search',textcolor: Colors.white,fontsize: 16)),
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
              ],
            ),
            const SizedBox(height: DesignConstants.padding30,),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 20,
                  color: Colors.white,
                  child: Container(
                    width: Get.width * 0.9,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal:  DesignConstants.padding10,vertical: DesignConstants.padding20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: shadowText(
                            text: 'Item Details',
                            fontsize: DesignConstants.fontSize16,
                          ),
                        ),
                        const SizedBox(height: DesignConstants.padding20,),
                        Container(
                          padding: const EdgeInsets.all(DesignConstants.padding5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: AppColors.blueGradient,
                          ),
                          child: Container(
                            width: Get.width*0.7,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                shadowText(text: 'Sr\nNo.',textcolor: Colors.white,fontsize: 14),
                                shadowText(text: 'Date',textcolor: Colors.white,fontsize: 14),
                                shadowText(text: 'Time',textcolor: Colors.white,fontsize: 14),
                                shadowText(text: 'Client\nName',textcolor: Colors.white,fontsize: 14),
                                shadowText(text: 'Amount',textcolor: Colors.white,fontsize: 14),
                                shadowText(text: 'Balance\nAmount',textcolor: Colors.white,fontsize: 14),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: DesignConstants.padding15,),
                        SizedBox(
                          width: Get.width,
                          height: 250,
                          child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: 10,
                              itemBuilder: (context,index){
                                return SizedBox(
                                  height: 70,
                                  width: Get.width,
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 50,
                                        width: Get.width*0.735,
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
                                              noShadowText(text: '13',textcolor: Colors.black,fontsize: 14,fontWeight: FontWeight.w400),
                                              noShadowText(text: '30/08/22',textcolor: Colors.black,fontsize: 14,fontWeight: FontWeight.w400),
                                              noShadowText(text: '05:45',textcolor: Colors.black,fontsize: 14,fontWeight: FontWeight.w400),
                                              noShadowText(text: 'ABC',textcolor: Colors.black,fontsize: 14,fontWeight: FontWeight.w400),
                                              noShadowText(text: '5000',textcolor: Colors.black,fontsize: 14,fontWeight: FontWeight.w400),
                                              noShadowText(text: '1000',textcolor: Colors.black,fontsize: 14,fontWeight: FontWeight.w400),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                      InkWell(
                                        onTap: (){},
                                        child: Container(
                                          height: 30,
                                          width: 50,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              color: AppColors.blueGradient,
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Colors.grey.withOpacity(0.3),
                                                    blurRadius: 0.4,
                                                    offset: const Offset(3, 4)
                                                )
                                              ]
                                          ),
                                          child: Center(child: shadowText(text: 'Return',textcolor: Colors.white,fontsize: 14)),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                        )

                      ],
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
