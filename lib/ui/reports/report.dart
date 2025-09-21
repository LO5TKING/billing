import 'package:billing/controllers/report_controller.dart';
import 'package:billing/ui/billing/billing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/config/color_constants.dart';
import '../../app/config/design_constants.dart';
import '../../model/report_response_model.dart';
import '../../utils/utility.dart';

class SearchAndReports extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final ReportController reportController = Get.put(ReportController());
  
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
                                    controller: nameController,
                                    keyboardType: TextInputType.text,
                                    onChanged: (value) {
                                      reportController.searchName.value = value;
                                      reportController.setSearchFilters(
                                        nameController.text,
                                        mobileController.text,
                                        reportController.fromDate.value,
                                        reportController.toDate.value,
                                      );
                                    },
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w500,
                                        fontSize: DesignConstants.fontSize12,
                                        color: Colors.black),
                                    decoration: InputDecoration(
                                      hintText: 'Search by name',
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
                                    controller: mobileController,
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      reportController.searchMobile.value = value;
                                    },
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w500,
                                        fontSize: DesignConstants.fontSize12,
                                        color: Colors.black),
                                    decoration: InputDecoration(
                                      hintText: 'Search by mobile',
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
                            InkWell(
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: reportController.fromDate.value ?? DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                );
                                if (picked != null) {
                                  reportController.fromDate.value = picked;
                                }
                              },
                              child: Container(
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
                                  child: Obx(() => Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      shadowText(
                                          text: reportController.fromDate.value != null
                                              ? '${reportController.fromDate.value!.day}/${reportController.fromDate.value!.month}/${reportController.fromDate.value!.year}'
                                              : 'Select',
                                          fontsize: 12,
                                          fontWeight: FontWeight.w400),
                                      const Icon(Icons.calendar_month),
                                    ],
                                  )),
                                ),
                              ),
                            ),
                            shadowText(
                                 text: 'To',
                                 fontsize: DesignConstants.fontSize16,
                                 fontWeight: FontWeight.w400),
                            InkWell(
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: reportController.toDate.value ?? DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                );
                                if (picked != null) {
                                  reportController.toDate.value = picked;
                                }
                              },
                              child: Container(
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
                                  child: Obx(() => Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      shadowText(
                                          text: reportController.toDate.value != null
                                              ? '${reportController.toDate.value!.day}/${reportController.toDate.value!.month}/${reportController.toDate.value!.year}'
                                              : 'Select',
                                          fontsize: 12,
                                          fontWeight: FontWeight.w400),
                                      const Icon(Icons.calendar_month),
                                    ],
                                  )),
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
                              onTap: () {
                                reportController.setSearchFilters(
                                  nameController.text,
                                  mobileController.text,
                                  reportController.fromDate.value,
                                  reportController.toDate.value,
                                );
                                // API call is made in setSearchFilters method
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
                              onTap: () {
                                nameController.clear();
                                mobileController.clear();
                                reportController.clearFilters();
                                // API call is made in clearFilters method
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
                                          offset: const Offset(3, 4))
                                    ]),
                                child: Center(
                                    child: shadowText(
                                        text: 'Clear',
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      width: Get.width ,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: DesignConstants.padding5,
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
                                          decoration: const BoxDecoration(),
                                          children: [
                                            tableHeader('Sr\nNo.'),
                                            tableHeader('Date'),
                                            tableHeader('Time'),
                                            tableHeader('Client\nName'),
                                            tableHeader('Amount'),
                                            tableHeader('Balance\nAmount'),
                                            tableHeader(''),
                                            tableHeader(''),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  Expanded(
                                    child: Obx(() => reportController.isLoading.value
                                      ? const Center(
                                          child: CircularProgressIndicator(),
                                        )
                                      : reportController.reportList.value?.billingReports == null ||
                                        reportController.reportList.value!.billingReports!.isEmpty
                                        ? const Center(
                                            child: Text('No reports found'),
                                          )
                                        : SingleChildScrollView(
                                            child: Column(
                                              children: List.generate(
                                                reportController.reportList.value!.billingReports!.length,
                                                (index) {
                                                  final report = reportController.reportList.value!.billingReports![index];
                                                  final dateTime = DateTime.parse(report.paymentDate!.toString());
                                                  final date = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
                                                  final time = '${dateTime.hour}:${dateTime.minute}';

                                                  return Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 5),
                                                    child: Card(
                                                      elevation: 6,
                                                      color: Colors.white,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Table(
                                                          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                                          children: [
                                                            TableRow(
                                                              children: [
                                                                tableCell('${index + 1}'),
                                                                tableCell(date),
                                                                tableCell(time),
                                                                tableCell(report.customerName ?? ''),
                                                                tableCell('₹${report.totalAmount?.toStringAsFixed(2) ?? '0.00'}'),
                                                                tableCell('₹${report.balanceAmount?.toStringAsFixed(2) ?? '0.00'}'),
                                                                report.paymentStatus == 'Pending' ? payButton() : tableCell('Paid'),
                                                                editButton(report),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                    ),
                                  ),
                                  Obx(() => reportController.reportList.value != null &&
                                      reportController.reportList.value!.billingReports != null &&
                                      reportController.reportList.value!.billingReports!.isNotEmpty
                                      ? Container(
                                    alignment: Alignment.bottomRight,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.blueGradient,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        shadowText(
                                          text: 'Total Balance Amount: ',
                                          textcolor: Colors.white,
                                          fontsize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        shadowText(
                                          text: '₹${reportController.totalBalanceAmount.value.toStringAsFixed(2)}',
                                          textcolor: Colors.white,
                                          fontsize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ],
                                    ),
                                  )
                                      : const SizedBox(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Obx(() => reportController.reportList.value?.totalPages != null && 
                                    reportController.reportList.value!.totalPages! > 1
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_back),
                                    onPressed: reportController.currentPage.value > 1
                                      ? () {
                                          reportController.previousPage();
                                          // API call is made in previousPage method
                                        }
                                      : null,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Page ${reportController.currentPage.value} of ${reportController.totalPages.value}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(width: 10),
                                  IconButton(
                                    icon: const Icon(Icons.arrow_forward),
                                    onPressed: reportController.currentPage.value < reportController.totalPages.value
                                      ? () {
                                          reportController.nextPage();
                                          // API call is made in nextPage method
                                        }
                                      : null,
                                  ),
                                ],
                              )
                            : const SizedBox(),
                          ),
                          // Display Total Balance Amount
                          const SizedBox(height: 20),
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

  Widget payButton(){
    return InkWell(
      onTap: (){},
      child: Container(
        height: 35,
        width: 20,
        margin: const EdgeInsets.symmetric(horizontal: 5),
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
        child: Center(child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.attach_money,color: Colors.white),
          iconSize: 20,
        )),
      ),
    );
  }

  Widget editButton(BillingReport report){
    return InkWell(
      onTap: (){
        Get.to(() => Billing(billingDetail: report));
      },
      child: Container(
        height: 35,
        width: 20,
        margin: const EdgeInsets.symmetric(horizontal: 5),
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
        child: Center(child: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.edit,color: Colors.white),
          iconSize: 20,
        )),
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
