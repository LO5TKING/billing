import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/config/color_constants.dart';
import '../../app/config/design_constants.dart';
import '../../utils/utility.dart';

class SearchAndReports extends StatelessWidget {
  final List<Map<String, String>> dummyData = [
    {
      "sr": "1",
      "date": "30/08/22",
      "time": "05:45",
      "client": "ABC",
      "amount": "5000",
      "balance": "1000"
    },
    {
      "sr": "2",
      "date": "31/08/22",
      "time": "04:15",
      "client": "XYZ",
      "amount": "2500",
      "balance": "500"
    },
    {
      "sr": "3",
      "date": "01/09/22",
      "time": "02:30",
      "client": "PQR",
      "amount": "1200",
      "balance": "200"
    },
    {
      "sr": "1",
      "date": "30/08/22",
      "time": "05:45",
      "client": "ABC",
      "amount": "5000",
      "balance": "1000"
    },
    {
      "sr": "2",
      "date": "31/08/22",
      "time": "04:15",
      "client": "XYZ",
      "amount": "2500",
      "balance": "500"
    },
    {
      "sr": "3",
      "date": "01/09/22",
      "time": "02:30",
      "client": "PQR",
      "amount": "1200",
      "balance": "200"
    },
    {
      "sr": "1",
      "date": "30/08/22",
      "time": "05:45",
      "client": "ABC",
      "amount": "5000",
      "balance": "1000"
    },
    {
      "sr": "2",
      "date": "31/08/22",
      "time": "04:15",
      "client": "XYZ",
      "amount": "2500",
      "balance": "500"
    },
    {
      "sr": "3",
      "date": "01/09/22",
      "time": "02:30",
      "client": "PQR",
      "amount": "1200",
      "balance": "200"
    },
    {
      "sr": "1",
      "date": "30/08/22",
      "time": "05:45",
      "client": "ABC",
      "amount": "5000",
      "balance": "1000"
    },
    {
      "sr": "2",
      "date": "31/08/22",
      "time": "04:15",
      "client": "XYZ",
      "amount": "2500",
      "balance": "500"
    },
    {
      "sr": "3",
      "date": "01/09/22",
      "time": "02:30",
      "client": "PQR",
      "amount": "1200",
      "balance": "200"
    },
    // Add more rows as needed
  ];

  SearchAndReports({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        height: Get.height,
        width: Get.width,
        child: Column(
          children: [
            const SizedBox(
              height: DesignConstants.padding100,
            ),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: DesignConstants.padding10,
                        vertical: DesignConstants.padding20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: shadowText(
                            text: 'Search Reports',
                            fontsize: DesignConstants.fontSize16,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: DesignConstants.padding15,
                              horizontal: DesignConstants.padding20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              shadowText(
                                  text: 'Name',
                                  fontsize: DesignConstants.fontSize16,
                                  fontWeight: FontWeight.w400),
                              Container(
                                  width: Get.width * 0.4,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: TextFormField(
                                    keyboardType: TextInputType.emailAddress,
                                    onChanged: (value) {},
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w500,
                                        fontSize: DesignConstants.fontSize12,
                                        color: Colors.black),
                                    decoration: InputDecoration(
                                      fillColor: Colors.white,
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Colors.grey,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Colors.grey,
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                    ),
                                  ))
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: DesignConstants.padding15,
                              horizontal: DesignConstants.padding20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              shadowText(
                                  text: 'Mobile',
                                  fontsize: DesignConstants.fontSize16,
                                  fontWeight: FontWeight.w400),
                              Container(
                                  width: Get.width * 0.4,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {},
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w500,
                                        fontSize: DesignConstants.fontSize12,
                                        color: Colors.black),
                                    decoration: InputDecoration(
                                      fillColor: Colors.white,
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Colors.grey,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Colors.grey,
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(20)),
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
                            shadowText(
                                text: 'Date From',
                                fontsize: DesignConstants.fontSize16,
                                fontWeight: FontWeight.w400),
                            Container(
                              height: 40,
                              width: 100,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    shadowText(
                                        text: '08/12/24',
                                        fontsize: 12,
                                        fontWeight: FontWeight.w400),
                                    const Icon(Icons.calendar_month),
                                  ],
                                ),
                              ),
                            ),
                            shadowText(
                                text: 'To',
                                fontsize: DesignConstants.fontSize16,
                                fontWeight: FontWeight.w400),
                            Container(
                              height: 40,
                              width: 100,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    shadowText(
                                        text: '08/12/24',
                                        fontsize: 12,
                                        fontWeight: FontWeight.w400),
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
                                        text: 'Search',
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
            const SizedBox(
              height: DesignConstants.padding30,
            ),
            Expanded(
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
                                              tableHeader('Sr\nNo.'),
                                              tableHeader('Date'),
                                              tableHeader('Time'),
                                              tableHeader('Client\nName'),
                                              tableHeader('Amount'),
                                              tableHeader('Balance\nAmount'),
                                              tableHeader(''),
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
                                                          tableCell(row["date"] ?? ""),
                                                          tableCell(row["time"] ?? ""),
                                                          tableCell(row["client"] ?? ""),
                                                          tableCell(row["amount"] ?? ""),
                                                          tableCell(row["balance"] ?? ""),
                                                          payButton('Pay'),
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
            const SizedBox(
              height: DesignConstants.padding30,
            ),
          ],
        ),
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

/*
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
                          height: 600,
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
                                          child: Center(child: shadowText(text: 'Pay',textcolor: Colors.white,fontsize: 14)),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                        )
 */
