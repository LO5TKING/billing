import 'package:billing/ui/billing/billing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/config/color_constants.dart';
import '../../app/config/design_constants.dart';
import '../../controllers/search_add_client_controller.dart';
import '../../model/customer_response_model.dart';
import '../../utils/utility.dart';

class SearchAddClientDetails extends StatelessWidget {

  SearchAddClientController searchAddClientController = Get.put(SearchAddClientController());

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
                Obx(
                () => Container(
                    margin: const EdgeInsets.only(right: DesignConstants.padding30),
                    alignment: Alignment.topRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text("Add Purchaser",style: TextStyle(color: Colors.black,fontSize: 22,fontWeight: FontWeight.bold),),
                        Switch(
                            value: searchAddClientController.addPurchaser.value,
                            onChanged: (value){
                              searchAddClientController.addPurchaser.value = value;
                        }),
                      ],
                    ),
                  ),
                ),
                Container(
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
                      Form(
                        key: searchAddClientController.searchFormKey,
                        child: Column(
                          children: [
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
                                        controller: searchAddClientController.searchNameController,
                                        keyboardType: TextInputType.name,
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
                                        controller: searchAddClientController.searchMobileController,
                                        keyboardType: TextInputType.phone,
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
                                  child: Center(
                                    child: shadowText(text: 'Search',textcolor: Colors.white,fontsize: 16)
                                    ),
                                  ),
                                )
                            ),
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
                                  text: 'Clients',
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
                                        child: Obx(() => SingleChildScrollView(
                                          child: searchAddClientController.clientList.isEmpty
                                              ? Center(
                                            child: Container(
                                              padding: const EdgeInsets.all(DesignConstants.padding20),
                                              child: shadowText(
                                                  text: 'No clients found. Try searching or add a new client.',
                                                  fontsize: DesignConstants.fontSize14
                                              ),
                                            ),
                                          )
                                              : Column(
                                            children: searchAddClientController.clientList.asMap().entries.map((entry) {
                                              int index = entry.key;
                                              Datum customer = entry.value; // Now using Datum object
                                              return Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 5),
                                                child: Card(
                                                  elevation: 6,
                                                  color: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: InkWell(
                                                    onTap: () {
                                                      // Handle row tap here
                                                      print('Tapped on ${customer.name}');
                                                      Get.to(() => Billing(customer: customer));
                                                      // You can navigate to another screen, show dialog, etc.
                                                      // Example: Get.to(() => ClientDetailScreen(client: customer));
                                                    },
                                                    borderRadius: BorderRadius.circular(10),
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Table(
                                                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                                        children: [
                                                          TableRow(
                                                            children: [
                                                              tableCell((index + 1).toString()),
                                                              tableCell(customer.name ?? ""),
                                                              tableCell(customer.mobileNo ?? ""),
                                                              tableCell(customer.address ?? ""),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        )),
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

  void addClientDialogBox(){
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(DesignConstants.padding20),
          child: Form(
            key: searchAddClientController.formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                shadowText(text: 'Add Client',fontsize: DesignConstants.fontSize16),
                const SizedBox(height: DesignConstants.padding10),
                Container(
                    width: Get.width*0.8,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextFormField(
                      controller: searchAddClientController.nameController,
                      keyboardType: TextInputType.name,
                      validator: (value) => searchAddClientController.validateName(value),
                      style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w500,
                          fontSize: DesignConstants.fontSize12,
                          color: Colors.black),
                      decoration:InputDecoration(
                        hintText: 'Name',
                        fillColor: Colors.white,
                        errorStyle: const TextStyle(fontSize: 10),
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
                    )),
                const SizedBox(height: DesignConstants.padding10),
                Container(
                    width: Get.width*0.8,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextFormField(
                      controller: searchAddClientController.mobileController,
                      keyboardType: TextInputType.phone,
                      validator: (value) => searchAddClientController.validateMobile(value),
                      style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w500,
                          fontSize: DesignConstants.fontSize12,
                          color: Colors.black),
                      decoration:InputDecoration(
                        hintText: 'Mobile',
                        fillColor: Colors.white,
                        errorStyle: const TextStyle(fontSize: 10),
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
                    )),
                const SizedBox(height: DesignConstants.padding10),
                Container(
                    width: Get.width*0.8,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextFormField(
                      controller: searchAddClientController.gstController,
                      keyboardType: TextInputType.text,
                      validator: (value) => searchAddClientController.validateGST(value),
                      style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w500,
                          fontSize: DesignConstants.fontSize12,
                          color: Colors.black),
                      decoration:InputDecoration(
                        hintText: 'GST',
                        fillColor: Colors.white,
                        errorStyle: const TextStyle(fontSize: 10),
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
                    )),
                const SizedBox(height: DesignConstants.padding10),
                Container(
                    width: Get.width*0.8,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextFormField(
                      controller: searchAddClientController.emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => searchAddClientController.validateEmail(value),
                      style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w500,
                          fontSize: DesignConstants.fontSize12,
                          color: Colors.black),
                      decoration:InputDecoration(
                        hintText: 'Email',
                        fillColor: Colors.white,
                        errorStyle: const TextStyle(fontSize: 10),
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
                    )),
                const SizedBox(height: DesignConstants.padding10),
                Container(
                    width: Get.width*0.8,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextFormField(
                      controller: searchAddClientController.addressController,
                      keyboardType: TextInputType.streetAddress,
                      style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w500,
                          fontSize: DesignConstants.fontSize12,
                          color: Colors.black),
                      decoration:InputDecoration(
                        hintText: 'Address',
                        fillColor: Colors.white,
                        errorStyle: const TextStyle(fontSize: 10),
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
                    )),
                const SizedBox(height: DesignConstants.padding10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                      onTap: (){
                        Get.back();
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
                        child: Center(child: shadowText(text: 'Cancel',textcolor: Colors.white,fontsize: 16)),
                      ),
                    ),
                    Obx(() => InkWell(
                      onTap: (){
                        if (!searchAddClientController.isLoading.value) {
                          if (searchAddClientController.formKey.currentState!.validate()) {
                            searchAddClientController.addPurchaser.value
                                ? searchAddClientController.addPurchaserPostApi() :
                            searchAddClientController.addClientPostApi();
                          }
                        }
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
                        child: Center(
                          child: searchAddClientController.isLoading.value
                              ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                              : shadowText(text: 'Add',textcolor: Colors.white,fontsize: 16)
                        ),
                      ),
                    )),
                  ],
                )
              ],
            ),
          ),
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
