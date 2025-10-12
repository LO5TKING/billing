import 'dart:io';

import 'package:billing/app/config/color_constants.dart';
import 'package:billing/app/config/design_constants.dart';
import 'package:billing/controllers/billing_controller.dart';
import 'package:billing/print/print_page.dart';
import 'package:billing/utils/one_pointer_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Ink;
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:pdf/pdf.dart';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/config/constants_text.dart';
import '../../app/routes/app_pages.dart';
import '../../controllers/order_controller.dart';
import '../../model/customer_response_model.dart';
import '../../utils/draggable_fab.dart';
import '../../utils/utility.dart';

class Order extends StatefulWidget {
  final Datum? customer;
  final List<Datum>? clientList;
  bool? clearPage;

  Order({this.customer,this.clientList,this.clearPage});

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  OrderController orderController = Get.find<OrderController>();

  final ScrollController scrollController = ScrollController();

  Rx<Datum?> selectedClient = Rx<Datum?>(null);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.clearPage == true){
      orderController.itemList.clear();
      orderController.clearPadAndSignature();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderController>(
      builder: (context) {
        return SafeArea(
          child: Stack(
            children: [
              Scaffold(
                backgroundColor:AppColors.peachColor,
              body: GestureDetector(
                onTap: () {
                  // If a rate box is currently being edited, cancel the edit
                  if (orderController.currentRateItemIndex.value >= 0) {
                    // Pass the current index to cancelRateEdit
                    int currentIndex = orderController.currentRateItemIndex.value;
                    orderController.cancelRateEdit(currentIndex);
                  }
                },
                child: Container(
                  width: Get.width,
                  height: Get.height * 0.97,
                  margin: const EdgeInsets.only(left: 5.0, right: 5, top: 5),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.blueGradient),
                  ),
                  child: Column(
                    children: [
                      // Header content (unchanged)
                      Container(
                        width: Get.width,
                        color: AppColors.blueGradient,
                        child: Stack(
                          children: [
                            Center(
                              child: Container(
                                  padding: const EdgeInsets.only(bottom: 20.0),
                                  child: Image.asset(
                                    "assets/ganpati.png",
                                    height: 50,
                                    width: 50,
                                  )),
                            ),
                            Positioned(
                              right: 0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: DesignConstants.padding5),
                                    child: Obx(() => Text(
                                      orderController
                                          .formattedDateTime.value,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.appBgColor,
                                      ),
                                    )),
                                  ),
                                  Obx( () =>
                                    Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: DesignConstants.padding5),
                                        child: Text(
                                          'To : ${selectedClient.value?.name ?? widget.customer?.name ?? "Guest"}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.appBgColor,
                                          ),
                                        )),
                                  ),
                                  Obx( () =>
                                    Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: DesignConstants.padding5),
                                        child: Text(
                                          'Mob : ${selectedClient.value?.mobileNo ?? widget.customer?.mobileNo ?? "N.A"}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.appBgColor,
                                          ),
                                        )),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              left: 0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: DesignConstants.padding5),
                                      child: Text(
                                        ConstantsText.shopName.toUpperCase(),
                                        style: GoogleFonts.poppins(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.appBgColor,
                                        ),
                                      )),
                                  Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: DesignConstants.padding5),
                                      child: Text(
                                        ConstantsText.mobileNo,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.appBgColor,
                                        ),
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Input row (unchanged)
                      Row(
                        children: [
                          descBox(0.44),
                          const SizedBox(
                            width: 5,
                          ),
                          quantityTextBox(0.40),
                          const SizedBox(
                            width: 5,
                          ),
                          // rateTextBox(0.27),
                          const Spacer(),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () {
                                  orderController.clearPadAndSignature();
                                },
                                child: Container(
                                  height: 35,
                                  width: 35,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.cancel,
                                    color: AppColors.blackLead,
                                  ),
                                ),
                              ),
                              IconButton(
                                  onPressed: () async {
                                    await orderController.addItem();
                                    orderController.clearPadAndSignature();
                                  },
                                  hoverColor: Colors.white,
                                  padding: const EdgeInsets.only(right: 3),
                                  icon: const Icon(Icons.add_box_rounded,color: AppColors.blueGradient,size: 30,)),
                            ],
                          )
                        ],
                      ),
                      // Main table area with fixed vertical lines
                      Expanded(
                        child: Obx(
                              () => Container(
                            padding: const EdgeInsets.only(right: 0.0),
                            // This Stack allows us to have fixed vertical lines
                            child: Stack(
                              children: [
                                // Fixed vertical lines
                                VerticalBorderLines(),
                                Column(
                                  children: [
                                    // Table header
                                    Table(
                                      columnWidths: {
                                        0:  FixedColumnWidth(
                                            orderController.showButtons.value
                                            ? 0.0
                                            : 100), // Sr.No
                                        1: const FlexColumnWidth(), // Particulars
                                        2: FixedColumnWidth(
                                            orderController.showButtons.value
                                                ? 120.0
                                                : 100), // QTY
                                        3: FixedColumnWidth(
                                            orderController.showButtons.value
                                                ? 220.0
                                                : 200), // Rate
                                        4: FixedColumnWidth(
                                            orderController.showButtons.value
                                                ? 125.0
                                                : 100), // Amount
                                      },
                                      children:  [
                                        TableRow(
                                          decoration: const BoxDecoration(
                                              color: AppColors.blueGradient
                                          ),
                                          children: [
                                            TableCell(
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text( orderController.showButtons.value
                                                    ? ""
                                                    : "Sr. No.",
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold)),
                                              ),
                                            ),
                                            const TableCell(
                                              child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text('PARTICULARS',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold)),
                                              ),
                                            ),
                                            const TableCell(
                                              child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text('QTY.',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold)),
                                              ),
                                            ),
                                            const TableCell(
                                              child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text('RATE',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold)),
                                              ),
                                            ),
                                            const TableCell(
                                              child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text('AMOUNT',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    // Item rows
                                    Expanded(
                                      child: ListView.builder(
                                        itemCount: orderController.itemList.length,
                                        padding: EdgeInsets.zero,
                                        controller: scrollController,
                                        // Disable scrolling when editing a rate box or when drawing ink
                                        physics: orderController.currentRateItemIndex.value >= 0 || orderController.ratePoints.isNotEmpty
                                            ? const NeverScrollableScrollPhysics()
                                            : const AlwaysScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          final item = orderController.itemList[index];
                                          final rate =
                                              double.tryParse(item['rate'] ?? '0') ?? 0;
                                          final quantity =
                                              double.tryParse(item['quantity'] ?? '0') ??
                                                  0;
                                          final amount = rate * quantity;
                                          final amountDisplay =
                                          amount.truncateToDouble() == amount
                                              ? amount.toStringAsFixed(2)
                                              : amount.toStringAsFixed(2);
                                          // Get the rate ink for this item
                                          return Row(
                                            children: [
                                              Expanded(
                                                child: Table(
                                                  columnWidths: {
                                                    0: FixedColumnWidth(
                                                        orderController.showButtons.value
                                                        ? 0.0
                                                        : 100),
                                                    1: const FlexColumnWidth(),
                                                    2: FixedColumnWidth(
                                                        orderController
                                                            .showButtons.value
                                                            ? 130.0
                                                            : 120),
                                                    3: FixedColumnWidth(
                                                        orderController
                                                            .showButtons.value
                                                            ? 230.0
                                                            : 220),
                                                    4: FixedColumnWidth(
                                                        orderController
                                                            .showButtons.value
                                                            ? 140.0
                                                            : 130),
                                                  },
                                                  children: [
                                                    TableRow(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                          const EdgeInsets.only(
                                                              top: 10.0),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              SizedBox(
                                                                width: 100,
                                                                height: 60,
                                                                child: CheckboxListTile(
                                                                  controlAffinity: ListTileControlAffinity.trailing,
                                                                  title: Text('${index + 1}'),
                                                                  value: item['checked'] ?? false,
                                                                  activeColor: AppColors.blueGradient,
                                                                  onChanged: (value) => orderController.toggleCheckbox(index),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                          const EdgeInsets.all(8.0),
                                                          child: item['particulars'] !=
                                                              null
                                                              ? Container(
                                                              alignment:
                                                              Alignment.topLeft,
                                                              width: 300,
                                                              child: Image.memory(
                                                                  item[
                                                                  'particulars'],
                                                                  height: 65,
                                                                  width: 300,
                                                                  fit: BoxFit
                                                                      .fill))
                                                              : Container(),
                                                        ),
                                                        Padding(
                                                          padding:
                                                          const EdgeInsets.only(
                                                              top: 22.0),
                                                          child: Text(
                                                            item['quantity'] ?? '',
                                                            textAlign: TextAlign.right,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                          const EdgeInsets.only(
                                                              top: 10.0,left: 40),
                                                          child: GestureDetector(
                                                            onTap: () {
                                                              // Set this item as the current one for rate input
                                                              orderController.setCurrentRateItem(index);
                                                            },
                                                            child: item['rate'] == "0" || orderController.currentRateItemIndex.value == index
                                                              ? rateTextBox(0.15, itemIndex: index)
                                                              : Material(
                                                              elevation: 30,
                                                                color: AppColors.peachColor,
                                                                child: Container(
                                                                    height: 50,
                                                                    width: Get.width * 0.15,
                                                                    decoration: BoxDecoration(
                                                                      border: Border.all(color: AppColors.blueGradient),
                                                                    ),
                                                                    alignment: Alignment.center,
                                                                    child: Text(
                                                                      item['rate'] ?? '',
                                                                      textAlign: TextAlign.center,
                                                                      style: const TextStyle(fontSize: 16),
                                                                    ),
                                                                  ),
                                                              ),
                                                          ),
                                                        ),
                                                        Container(
                                                          margin:
                                                          const EdgeInsets.only(
                                                              top: 22.0,right: 10,),
                                                          child: Row(
                                                            children: [
                                                              const Spacer(),
                                                              if (!index.isNegative)
                                                                GestureDetector(
                                                                  onTap: () async {
                                                                    await orderController.updateItemRate(index);
                                                                  },
                                                                  child: Container(
                                                                    decoration: const BoxDecoration(
                                                                      shape: BoxShape.circle,
                                                                    ),
                                                                    child: const Icon(Icons.check_circle_outline, color: AppColors.blueGradient),
                                                                  ),
                                                                ),
                                                              const Spacer(),
                                                              Text(
                                                                '${amountDisplay}',
                                                                textAlign: TextAlign.right,
                                                              ),
                                                              const Spacer(),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Obx(
                                                    () => Visibility(
                                                  visible: orderController
                                                      .showButtons.value,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      orderController
                                                          .editItem(index);
                                                    },
                                                    onDoubleTap: () {
                                                      orderController
                                                          .deleteItem(index);
                                                    },
                                                    child: Container(
                                                      width: 15.0,
                                                      height: 15.0,
                                                      margin: const EdgeInsets.only(
                                                          bottom: 25.0,
                                                          right: 10
                                                      ),
                                                      alignment:
                                                      Alignment.topRight,
                                                      decoration: const BoxDecoration(
                                                        shape: BoxShape.circle,// Dot color
                                                      ),
                                                      child: const Icon(Icons.remove_circle_outlined,color: AppColors.blackLead,),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Total row
                      Obx(
                            () => Table(
                          border:
                          TableBorder.all(color: AppColors.blueGradient),
                          columnWidths: {
                            0: const FixedColumnWidth(60.0),
                            1: const FlexColumnWidth(),
                            2: FixedColumnWidth(
                                orderController
                                    .showButtons.value
                                    ? 120.0
                                    : 100),
                            3: FixedColumnWidth(
                                orderController
                                    .showButtons.value
                                    ? 221.0
                                    : 200),
                            4: FixedColumnWidth(
                                orderController
                                    .showButtons.value
                                    ? 145.0
                                    : 120),
                          },
                          children: [
                            TableRow(
                              decoration:const BoxDecoration(
                                  color: AppColors.blueGradient
                              ),
                              children: [
                                const TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                const TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('TOTAL',
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                        '${orderController.totalQty}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                const TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '${orderController.totalAmount}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold
                                    ),
                                    textAlign: TextAlign.center,
                                  ), // Dynamic total calculation
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Bottom controls (unchanged)
                      Container(
                        height: 110,
                        padding: EdgeInsets.zero,
                        child: Obx(
                              () => Column(
                            children: [
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.only(
                                    top: DesignConstants.padding5),
                                child: Visibility(
                                  visible: orderController.showButtons.value,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Visibility(
                                        visible: false,
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                              AppColors.blueGradient,
                                              shape:
                                              const RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.all(
                                                      Radius.circular(
                                                          5))),
                                            ),
                                            onPressed: () {},
                                            child: const Text(
                                              'View',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: DesignConstants
                                                      .fontSize20),
                                            )),
                                      ),
                                      Visibility(
                                        visible: false,
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                              AppColors.blueGradient,
                                              shape:
                                              const RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.all(
                                                      Radius.circular(
                                                          5))),
                                            ),
                                            onPressed: () {},
                                            child: const Text(
                                              'Save',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: DesignConstants
                                                      .fontSize20),
                                            )),
                                      ),
                                      const SizedBox(width: 10),
                                      Container(
                                        height: 40,
                                        child: Obx(() => ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                              AppColors.blueGradient,
                                              shape:
                                              const RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.all(
                                                      Radius.circular(
                                                          5))),
                                            ),
                                            onPressed: orderController
                                                .isPrinting.value
                                                ? null
                                                : () async {
                                              orderController
                                                  .printPdfReceipt(selectedClient.value ?? widget.customer);
                                              // await orderController.shopDetailApi();
                                            },
                                            child: orderController
                                                .isPrinting.value
                                                ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child:
                                              CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                                : const Icon(Icons.print,color: Colors.white,size: 40,))),
                                      ),
                                      const SizedBox(width: 10),
                                      Container(
                                        height: 40,
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                              AppColors.blueGradient,
                                              shape:
                                              const RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.all(
                                                      Radius.circular(
                                                          5))),
                                            ),
                                            onPressed: () {
                                              orderController.itemList
                                                  .clear();
                                            },
                                            child: const Icon(Icons.clear,color: Colors.white,size: 40,)),
                                      ),
                                      const SizedBox(width: 10),
                                      Container(
                                        height: 40,
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                              AppColors.blueGradient,
                                              shape:
                                              const RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.all(
                                                      Radius.circular(
                                                          5))),
                                            ),
                                            onPressed: () async {
                                              await orderController.saveReceiptAsPdf();
                                            },
                                            child: const Icon(Icons.save,color: Colors.white,size: 40,)),
                                      ),
                                      Container(
                                        height: 40,
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                              AppColors.blueGradient,
                                              shape:
                                              const RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.all(
                                                      Radius.circular(
                                                          5))),
                                            ),
                                            onPressed: () async {
                                              File? pdfFile = await orderController.saveReceiptAsPdf();
                                              if (pdfFile != null && await pdfFile.exists()) {
                                                final XFile xfile = XFile(pdfFile.path);
                                                // SharePlus.instance.share([xfile], text: 'Here is your receipt!');
                                                SharePlus.instance.share(ShareParams(files: [xfile],text: "Here is your receipt!"));
                                              } else {
                                                Get.snackbar('Error', 'Unable to share receipt');
                                              }
                                            },
                                            child: const Icon(Icons.share,color: Colors.white,size: 40,)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Visibility(
                                visible: true,
                                child: Container(
                                  alignment: Alignment.bottomCenter,
                                  child: IconButton(
                                      onPressed: () {
                                        orderController.showButtons.value =
                                        !orderController
                                            .showButtons.value;
                                      },
                                      icon: const Icon(
                                        Icons.house_siding_rounded,
                                        size: 30,
                                        color: AppColors.blueGradient,
                                      )),
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
              Positioned(
                bottom: 20,
                left: 20,
                child: GestureDetector(
                  onLongPress: () async {
                    await orderController.getClients();
                    customerListWidget();
                  },
                  child: DraggableFab(
                    targetRoute: AppPages.orderNew,
                    arguments: {'customer': widget.customer,'clientList' : widget.clientList},
                    backgroundColor: AppColors.blueGradient,
                    icon: Icons.receipt,
                  ),
                ),
              ),
            ],

          ),
        );
      },
    );
  }

  Widget rateTextBox(double widthFactor, {int? itemIndex}) {
    return Material(
      color: AppColors.peachColor,
      elevation: 30,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 50,
            width: Get.width,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.blueGradient),
            ),
            child: ClipRect(
              child: GestureDetector(
                // Prevent the GestureDetector from handling tap events that should go to the Listener
                behavior: HitTestBehavior.opaque,
                // Prevent the outer GestureDetector from capturing this tap
                onTap: () {
                  // Prevent the tap from propagating to the outer GestureDetector
                },
                child: Listener(
                  onPointerDown: (event) {
                    // Handle both stylus and touch events
                    if (isTouchInsideBox(event.localPosition, Get.width * widthFactor)) {
                      // Add a point to ratePoints to trigger scroll locking via physics property
                      orderController.ratePoints.add(StrokePoint(
                        x: event.localPosition.dx,
                        y: event.localPosition.dy,
                        t: DateTime.now().millisecondsSinceEpoch,
                      ));

                      // Use the current item's ink object if an index is provided
                      if (itemIndex != null && itemIndex >= 0 && itemIndex < orderController.rateInkList.length) {
                        orderController.rateInkList[itemIndex].strokes.add(Stroke());
                      } else {
                        orderController.rateInk.strokes.add(Stroke());
                      }
                      orderController.update();
                    }
                  },
                  onPointerMove: (event) {
                    // Use the current item's ink object if an index is provided
                    Ink inkToUse = (itemIndex != null && itemIndex >= 0 && itemIndex < orderController.rateInkList.length)
                        ? orderController.rateInkList[itemIndex]
                        : orderController.rateInk;

                    if (inkToUse.strokes.isNotEmpty) {
                      inkToUse.strokes.last.points.add(
                        StrokePoint(
                          x: event.localPosition.dx,
                          y: event.localPosition.dy,
                          t: DateTime.now().millisecondsSinceEpoch,
                        ),
                      );
                      orderController.update();  // Update the ink state in controller
                    }
                  },
                  onPointerUp: (event) {
                    // State is updated after interaction
                    orderController.update();
                  },
                  onPointerCancel: (event) {
                    // Handle pointer cancel events to prevent issues
                    debugPrint('Pointer Cancelled in rate box');
                  },
                  child: CustomPaint(
                    painter: SignatureStyle(ink: (itemIndex != null && itemIndex >= 0 && itemIndex < orderController.rateInkList.length)
                        ? orderController.rateInkList[itemIndex]
                        : orderController.rateInk),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: -0,
            right: -0,
            child: Row(
              children: [
                // Cancel button
                GestureDetector(
                  onTap: () {
                    // Pass the itemIndex to cancelRateEdit
                    orderController.cancelRateEdit(itemIndex);
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.cancel_outlined, color: AppColors.blackLead),
                  ),
                ),
                // Confirm button is now in the table row
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget quantityTextBox(double widthFactor) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 75,
          width: Get.width * widthFactor,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.blueGradient),
          ),
          child: ClipRRect(
            child: Listener(
              onPointerDown: (event) {
                if (isTouchInsideBox(
                    event.localPosition, Get.width * widthFactor)) {
                  orderController.quantityInk.strokes.add(Stroke());
                  orderController.update();
                }
              },
              onPointerMove: (event) {
                final RenderObject? object = Get.context?.findRenderObject();
                final localPosition =
                (object as RenderBox?)?.globalToLocal(event.localPosition);
                if (localPosition != null) {
                  orderController.quantityInk.strokes.last.points.add(
                    StrokePoint(
                      x: localPosition.dx,
                      y: localPosition.dy,
                      t: DateTime.now().millisecondsSinceEpoch,
                    ),
                  );
                  orderController.update();
                }
              },
              onPointerUp: (event) {
                orderController.update();
              },
              onPointerCancel: (event) {
                // Ignore the cancel event, don't stop drawing
                debugPrint('Pointer Cancelled');
              },
              child: CustomPaint(
                painter: SignatureStyle(ink: orderController.quantityInk),
                size: Size.infinite,
              ),
            ),
          ),
        ),
        Positioned(
          top: -0,
          right: -0,
          child: GestureDetector(
            onTap: () {
              orderController.quantityInk.strokes.clear();
              orderController.quantityPoints.clear();
              orderController.update();
            },
            child: Container(
              decoration: const BoxDecoration(
                // color: Colors.white, // Background color to make the button stand out
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cancel_outlined, color: AppColors.blackLead),
            ),
          ),
        ),
      ],
    );
  }

  Widget descBox(double widthFactor) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 75,
          width: Get.width * widthFactor,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.blueGradient),
          ),
          child: ClipRect(
            child: Listener(
              onPointerDown: (event) async {
                if (isTouchInsideBox(
                    event.localPosition, Get.width * widthFactor)) {
                  orderController.descriptionInk.strokes.add(Stroke());
                  orderController.update();
                }
              },
              onPointerMove: (event) async {
                final RenderObject? object = Get.context?.findRenderObject();
                final localPosition =
                (object as RenderBox?)?.globalToLocal(event.localPosition);
                if (localPosition != null &&
                    orderController.descriptionInk.strokes.isNotEmpty) {
                  orderController.descriptionInk.strokes.last.points.add(
                    StrokePoint(
                      x: localPosition.dx,
                      y: localPosition.dy,
                      t: DateTime.now().millisecondsSinceEpoch,
                    ),
                  );
                  orderController.update();
                }
              },
              onPointerUp: (event) async {
                orderController.update();
              },
              onPointerCancel: (event) async {
                debugPrint('Pointer Cancelled');
              },
              child: CustomPaint(
                painter: SignatureStyle(ink: orderController.descriptionInk),
                size: Size.infinite,
              ),
            ),
          ),
        ),
        Positioned(
          top: -0,
          right: -0,
          child: GestureDetector(
            onTap: () {
              orderController.descriptionInk.strokes.clear();
              orderController.descriptionPoints.clear();
              orderController.update();
            },
            child: Container(
              decoration: const BoxDecoration(
                // color: Colors.white, // Background color to make the button stand out
                shape: BoxShape.circle,
              ),
              // padding: const EdgeInsets.all(8.0),
              child: const Icon(Icons.cancel_outlined, color: AppColors.blackLead),
            ),
          ),
        ),
      ],
    );
  }

  void customerListWidget(){
    final TextEditingController searchController = TextEditingController();
    RxList<Datum> filteredClientList = <Datum>[].obs;

    filteredClientList.assignAll(orderController.clientList);

    void filterClients(String query) {
      if (query.isEmpty) {
        filteredClientList.assignAll(orderController.clientList);
      } else {
        filteredClientList.assignAll(
            orderController.clientList.where((client) =>
            client.name?.toLowerCase().contains(query.toLowerCase()) ?? false
            ).toList()
        );
      }
    }

    Get.dialog(
      barrierDismissible: false,
      Obx(() => orderController.loadingClient.value ?
      const Center(child: CircularProgressIndicator(),):
      AlertDialog(
        title: const Text("Select Client", textAlign: TextAlign.center,),
        alignment: Alignment.center,
        content: Container(
          height: 500,
          width: 500,
          child: Column(
            children: [
              // Search TextField
              TextField(
                controller: searchController,
                onChanged: filterClients,
                decoration: const InputDecoration(
                  hintText: "Search clients...",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              // ListView with filtered results
              Expanded(
                child: Obx(() => ListView.builder(
                  itemCount: filteredClientList.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        selectedClient.value = filteredClientList[index];
                        Get.back();
                      },
                      child: Container(
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            border: Border.all(color: AppColors.blueMarieTime, width: 1)
                        ),
                        child: Text(
                          filteredClientList[index].name ?? "",
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 24,),
                        ),
                      ),
                    );
                  },
                )),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  /// Helper function to determine if the touch event is inside the bounding box
  /// Added buffer to better handle touch events near the edges
  bool isTouchInsideBox(Offset localPosition, double widthFactor) {
    // Add a small buffer to ensure we capture events near the edges
    const double buffer = 5.0;
    double boxWidth = widthFactor is double ? Get.width * widthFactor : widthFactor;
    double boxHeight = 75.0; // Default height for description box

    // For rate box, the height is 50
    if (boxWidth < Get.width) {
      boxHeight = 50.0;
    }

    return localPosition.dx >= -buffer &&
        localPosition.dx <= boxWidth + buffer &&
        localPosition.dy >= -buffer &&
        localPosition.dy <= boxHeight + buffer;
  }
}

class SignatureStyle extends CustomPainter {
  Ink? ink;
  var controller = Get.put(OrderController());

  SignatureStyle({this.ink});

  @override
  void paint(Canvas canvas, Size size) {
    if (ink == null || ink!.strokes.isEmpty) return;
    
    final Paint paint = Paint()
      ..color = Colors.black87
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 4.0
      ..isAntiAlias = true; // Enable anti-aliasing for smoother lines

    for (final stroke in ink!.strokes) {
      if (stroke.points.isEmpty) continue;
      
      // Handle single point (dot) case
      if (stroke.points.length == 1) {
        final point = stroke.points[0];
        canvas.drawCircle(
          Offset(point.x.toDouble(), point.y.toDouble()),
          2.0, // Radius of the dot
          paint,
        );
        continue;
      }
      
      // Draw lines between points for multiple points
      for (int i = 0; i < stroke.points.length - 1; i++) {
        final p1 = stroke.points[i];
        final p2 = stroke.points[i + 1];
        canvas.drawLine(
          Offset(p1.x.toDouble(), p1.y.toDouble()),
          Offset(p2.x.toDouble(), p2.y.toDouble()),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(SignatureStyle oldDelegate) => true;
}

// This custom widget draws the vertical lines that will always be visible
class VerticalBorderLines extends StatelessWidget {

  OrderController orderController = Get.find<OrderController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() =>
        Row(
          children: [
            // First column (Sr.No - 60px)
            SizedBox(width: orderController.showButtons.value
                ? 0.0
                : 100),
            // Vertical line
            _buildVerticalLine(),

            // Second column (Particulars - flexible)
            const Expanded(child: SizedBox()),
            // Vertical line
            _buildVerticalLine(),

            // Third column (QTY - 100/120px based on showButtons)
            SizedBox(width: orderController.showButtons.value
                ? 118.0
                : 98),
            // You might need to adjust this with Obx() if it changes
            // Vertical line
            _buildVerticalLine(),

            // Fourth column (Rate - 100/120px based on showButtons)
            SizedBox(width: orderController.showButtons.value
                ? 220.0
                : 200),
            // You might need to adjust this with Obx() if it changes
            // Vertical line
            _buildVerticalLine(),

            // Fifth column (Amount - 100/120px based on showButtons)
            SizedBox(width: orderController.showButtons.value
                ? 145.0
                : 120),
            // You might need to adjust this with Obx() if it changes
          ],
        ),
    );
  }

  Widget _buildVerticalLine() {
    return Container(
      width: 1,
      color: AppColors.blueGradient,
    );
  }
}
