import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/config/color_constants.dart';
import '../../app/config/design_constants.dart';
import '../../utils/utility.dart';

class SearchAddClientDetails extends StatelessWidget {

  final List<Map<String, String>> dummyData = [
    {
      "sr": "1",
      "name": "Rahul",
      "mobile": "9812345678",
      "address": "ABC",
    },
    {
      "sr": "2",
      "name": "David",
      "mobile": "9708765432",
      "address": "ABC",
    },
    {
      "sr": "3",
      "name": "Bala",
      "mobile": "9667890345",
      "address": "ABC",
    },
    {
      "sr": "1",
      "name": "Rahul",
      "mobile": "9812345678",
      "address": "ABC",
    },
    {
      "sr": "2",
      "name": "David",
      "mobile": "9708765432",
      "address": "ABC",
    },
    {
      "sr": "3",
      "name": "Bala",
      "mobile": "9667890345",
      "address": "ABC",
    },
    {
      "sr": "1",
      "name": "Rahul",
      "mobile": "9812345678",
      "address": "ABC",
    },
    {
      "sr": "2",
      "name": "David",
      "mobile": "9708765432",
      "address": "ABC",
    },
    {
      "sr": "3",
      "name": "Bala",
      "mobile": "9667890345",
      "address": "ABC",
    },
    {
      "sr": "1",
      "name": "Rahul",
      "mobile": "9812345678",
      "address": "ABC",
    },
    {
      "sr": "2",
      "name": "David",
      "mobile": "9708765432",
      "address": "ABC",
    },
    {
      "sr": "3",
      "name": "Bala",
      "mobile": "9667890345",
      "address": "ABC",
    },
    {
      "sr": "1",
      "name": "Rahul",
      "mobile": "9812345678",
      "address": "ABC",
    },
    {
      "sr": "2",
      "name": "David",
      "mobile": "9708765432",
      "address": "ABC",
    },
    {
      "sr": "3",
      "name": "Bala",
      "mobile": "9667890345",
      "address": "ABC",
    },

    // Add more rows as needed
  ];


  SearchAddClientDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        height: Get.height,
        width: Get.width,
        child: Column(
          children: [
            const SizedBox(height: DesignConstants.padding100,),
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
                            text: 'Search and add clients',
                            fontsize: DesignConstants.fontSize16,
                          ),
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
                        Center(
                          child: InkWell(
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
                        ),
                        const SizedBox(
                          height: DesignConstants.padding20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            InkWell(
                              onTap: (){
                                addClientDialogBox();
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
              ],
            ),
            const SizedBox(height: DesignConstants.padding30,),
            Expanded(
              child: Container(
                width: Get.width * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(vertical: DesignConstants.padding20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Card(
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
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: shadowText(
                                  text: 'Reports',
                                  fontsize: DesignConstants.fontSize16,
                                ),
                              ),
                              const SizedBox(
                                height: DesignConstants.padding20,
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          color: AppColors.blueGradient,
                                        ),
                                        child: Table(
                                          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                          children: [
                                            // Table header
                                            TableRow(
                                              decoration: BoxDecoration(),
                                              children: [
                                                tableHeader('Sr No.'),
                                                tableHeader('Name'),
                                                tableHeader('Mobile'),
                                                tableHeader('Address'),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      Expanded(
                                        child: SingleChildScrollView(
                                          child: Column(
                                            children: dummyData.map((row) {
                                              return Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 5), // Padding between rows
                                                child: Card(
                                                  elevation: 6, // Elevation for the row's card
                                                  color: Colors.white, // Card background color
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10), // Card border radius
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Table(
                                                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                                      children: [
                                                        TableRow(
                                                          children: [
                                                            tableCell(row["sr"] ?? ""),
                                                            tableCell(row["name"] ?? ""),
                                                            tableCell(row["mobile"] ?? ""),
                                                            tableCell(row["address"] ?? ""),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
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
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: DesignConstants.padding30,
            ),
          ],
        ),
      ),
    );
  }

  addClientDialogBox(){
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: shadowText(
                        text: 'Add client',
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
                          shadowText(text: 'Email Id',fontsize: DesignConstants.fontSize16,fontWeight: FontWeight.w400),
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
                            child: Center(child: shadowText(text: 'Ok',textcolor: Colors.white,fontsize: 16)),
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
  }

  Widget payButton(String text){
    return InkWell(
      onTap: (){},
      child: Container(
        height: 30,
        width: 40,
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
        child: Center(child: shadowText(text: text,textcolor: Colors.white,fontsize: 14)),
      ),
    );
  }

  // Reusable table header cell widget
  Widget tableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  // Reusable table cell widget
  Widget tableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black,
        ),
      ),
    );
  }

}
