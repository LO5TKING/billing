import 'dart:io';

import 'package:billing/app/config/color_constants.dart';
import 'package:billing/app/config/design_constants.dart';
import 'package:billing/controllers/billing_controller.dart';
import 'package:billing/model/customer_response_model.dart';
import 'package:billing/print/print_page.dart';
import 'package:billing/utils/draggable_fab.dart';
import 'package:billing/utils/one_pointer_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Ink;
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:pdf/pdf.dart';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/config/constants_text.dart';
import '../../controllers/billing_controller_new.dart';
import '../../utils/utility.dart';

class BillingNew extends StatefulWidget {
  final Datum? customer;
  BillingNew({this.customer});

  @override
  State<BillingNew> createState() => _BillingNewState();
}

class _BillingNewState extends State<BillingNew> {
  BillingControllerNew billingControllerNew = Get.find<BillingControllerNew>();

  Rx<Datum?> selectedClient = Rx<Datum?>(null);

  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // billingControllerNew.getClients();
      // customerListWidget();
    },);

  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BillingControllerNew>(
      builder: (context) {
        return SafeArea(
          child: Scaffold(
            backgroundColor:AppColors.peachColor,
            body: Stack(
              children: [
                Container(
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
                                      billingControllerNew
                                          .formattedDateTime.value,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.appBgColor,
                                      ),
                                    )),
                                  ),
                                  Obx(() => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: DesignConstants.padding5),
                                    child: Text(
                                      'To : ${selectedClient.value?.name ?? ""}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.appBgColor,
                                      ),
                                    ),
                                  )),

                                  Obx(() => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: DesignConstants.padding5),
                                    child: Text(
                                      'Mob : ${selectedClient.value?.mobileNo ?? ""}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.appBgColor,
                                      ),
                                    ),
                                  )),

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
                          quantityTextBox(0.20),
                          const SizedBox(
                            width: 5,
                          ),
                          rateTextBox(0.27),
                          const Spacer(),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () {
                                  billingControllerNew.clearPadAndSignature();
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
                                    await billingControllerNew.addItem();
                                    billingControllerNew.clearPadAndSignature();
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
                                        0: const FixedColumnWidth(60.0), // Sr.No
                                        1: const FlexColumnWidth(), // Particulars
                                        2: FixedColumnWidth(
                                            billingControllerNew.showButtons.value
                                                ? 120.0
                                                : 100), // QTY
                                        3: FixedColumnWidth(
                                            billingControllerNew.showButtons.value
                                                ? 120.0
                                                : 100), // Rate
                                        4: FixedColumnWidth(
                                            billingControllerNew.showButtons.value
                                                ? 125.0
                                                : 100), // Amount
                                      },
                                      children: const [
                                        TableRow(
                                          decoration: BoxDecoration(
                                              color: AppColors.blueGradient
                                          ),
                                          children: [
                                            TableCell(
                                              child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text('Sr. No.',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold)),
                                              ),
                                            ),
                                            TableCell(
                                              child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text('PARTICULARS',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold)),
                                              ),
                                            ),
                                            TableCell(
                                              child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text('QTY.',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold)),
                                              ),
                                            ),
                                            TableCell(
                                              child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text('RATE',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold)),
                                              ),
                                            ),
                                            TableCell(
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
                                        itemCount: billingControllerNew.itemList.length,
                                        padding: EdgeInsets.zero,
                                        controller: scrollController,
                                        itemBuilder: (context, index) {
                                          final item = billingControllerNew.itemList[index];
                                          final rate =
                                              double.tryParse(item['rate'] ?? '0') ?? 0;
                                          final quantity =
                                              double.tryParse(item['quantity'] ?? '0') ??
                                                  0;
                                          final amount = rate * quantity;
                                          final amountDisplay =
                                          amount.truncateToDouble() == amount
                                              ? amount.toInt().toString()
                                              : amount.toString();

                                          return Row(
                                            children: [
                                              Expanded(
                                                child: Table(
                                                  columnWidths: {
                                                    0: const FixedColumnWidth(60.0),
                                                    1: const FlexColumnWidth(),
                                                    2: FixedColumnWidth(
                                                        billingControllerNew
                                                            .showButtons.value
                                                            ? 130.0
                                                            : 120),
                                                    3: FixedColumnWidth(
                                                        billingControllerNew
                                                            .showButtons.value
                                                            ? 130.0
                                                            : 120),
                                                    4: FixedColumnWidth(
                                                        billingControllerNew
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
                                                              top: 22.0),
                                                          child: Text(
                                                            '${index + 1}',
                                                            textAlign: TextAlign.center,
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
                                                              child: Image.memory(
                                                                  item[
                                                                  'particulars'],
                                                                  height: 65,
                                                                  fit: BoxFit
                                                                      .contain))
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
                                                              top: 22.0),
                                                          child: Text(
                                                            item['rate'] ?? '',
                                                            textAlign: TextAlign.right,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                          const EdgeInsets.only(
                                                              top: 22.0,right: 10),
                                                          child: Text(
                                                            '$amountDisplay',
                                                            textAlign: TextAlign.right,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Obx(
                                                    () => Visibility(
                                                  visible: billingControllerNew
                                                      .showButtons.value,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      billingControllerNew
                                                          .editItem(index);
                                                    },
                                                    onDoubleTap: () {
                                                      billingControllerNew
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
                                billingControllerNew
                                    .showButtons.value
                                    ? 120.0
                                    : 100),
                            3: FixedColumnWidth(
                                billingControllerNew
                                    .showButtons.value
                                    ? 121.0
                                    : 100),
                            4: FixedColumnWidth(
                                billingControllerNew
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
                                        '${billingControllerNew.totalQty}',
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
                                    '${billingControllerNew.totalAmount}',
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
                                  visible: billingControllerNew.showButtons.value,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
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
                                            onPressed: billingControllerNew
                                                .isPrinting.value
                                                ? null
                                                : () async {
                                              billingControllerNew.printPdfReceipt(selectedClient?.value);
                                              await billingControllerNew.shopDetailApi();
                                            },
                                            child: billingControllerNew
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
                                                : const Icon(Icons.print,color: Colors.white,size: 40,)
                                        )),
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
                                              billingControllerNew.itemList
                                                  .clear();
                                            },
                                            child: const Icon(Icons.cleaning_services_sharp,color: Colors.white,size: 40,)
                                        ),
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
                                              await billingControllerNew.saveReceiptAsPdf();
                                            },
                                            child: const Icon(Icons.save,color: Colors.white,size: 40,)
                                        ),
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
                                              File? pdfFile = await billingControllerNew.saveReceiptAsPdf();
                                              if (pdfFile != null && await pdfFile.exists()) {
                                                final XFile xfile = XFile(pdfFile.path);
                                                // SharePlus.instance.share([xfile], text: 'Here is your receipt!');
                                                SharePlus.instance.share(ShareParams(files: [xfile],text: "Here is your receipt!"));
                                              } else {
                                                Get.snackbar('Error', 'Unable to share receipt');
                                              }
                                            },
                                            child: const Icon(Icons.share,color: Colors.white,size: 40,)
                                        ),
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
                                        billingControllerNew.showButtons.value =
                                        !billingControllerNew
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
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: GestureDetector(
                    onLongPress: () async {
                      await billingControllerNew.getClients();
                      customerListWidget();
                    },
                    child: DraggableFab(
                      targetRoute: '/billing',
                      arguments: {'customer': widget.customer},
                      backgroundColor: AppColors.blueGradient,
                      icon: Icons.receipt_long,
                    ),
                  ),
                ),
              ]
            ),
          ),
        );
      },
    );
  }

  Widget rateTextBox(double widthFactor) {
    return Stack(
      children: [
        Container(
          height: 75,
          width: Get.width * widthFactor,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.blueGradient),
          ),
          child: ClipRect(
              child: Listener(
            onPointerDown: (event) {
              if (event.kind == PointerDeviceKind.stylus ||
                  event.kind == PointerDeviceKind.touch) {
                if (isTouchInsideBox(
                    event.localPosition, Get.width * widthFactor)) {
                  billingControllerNew.rateInk.strokes.add(Stroke());
                  billingControllerNew.update();
                }
              }
            },
            onPointerMove: (event) {
              if (event.kind == PointerDeviceKind.stylus ||
                  event.kind == PointerDeviceKind.touch) {
                final RenderObject? object = Get.context?.findRenderObject();
                final localPosition =
                    (object as RenderBox?)?.globalToLocal(event.localPosition);
                if (localPosition != null &&
                    billingControllerNew.rateInk.strokes.isNotEmpty) {
                  billingControllerNew.rateInk.strokes.last.points.add(
                    StrokePoint(
                      x: localPosition.dx,
                      y: localPosition.dy,
                      t: DateTime.now().millisecondsSinceEpoch,
                    ),
                  );
                  billingControllerNew.update();
                }
              }
            },
            onPointerUp: (event) {
              if (event.kind == PointerDeviceKind.stylus ||
                  event.kind == PointerDeviceKind.touch) {
                billingControllerNew.update();
              }
            },
            onPointerCancel: (event) {
              debugPrint('Pointer Cancelled');
            },
            child: CustomPaint(
              painter: SignatureStyle(ink: billingControllerNew.rateInk),
              size: Size.infinite,
            ),
          )),
        ),
        Positioned(
          top: -0,
          right: -0,
          child: GestureDetector(
            onTap: () {
              billingControllerNew.rateInk.strokes.clear();
              billingControllerNew.ratePoints.clear();
              billingControllerNew.update();
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
                  billingControllerNew.quantityInk.strokes.add(Stroke());
                  billingControllerNew.update();
                }
              },
              onPointerMove: (event) {
                final RenderObject? object = Get.context?.findRenderObject();
                final localPosition =
                    (object as RenderBox?)?.globalToLocal(event.localPosition);
                if (localPosition != null) {
                  billingControllerNew.quantityInk.strokes.last.points.add(
                    StrokePoint(
                      x: localPosition.dx,
                      y: localPosition.dy,
                      t: DateTime.now().millisecondsSinceEpoch,
                    ),
                  );
                  billingControllerNew.update();
                }
              },
              onPointerUp: (event) {
                billingControllerNew.update();
              },
              onPointerCancel: (event) {
                // Ignore the cancel event, don't stop drawing
                debugPrint('Pointer Cancelled');
              },
              child: CustomPaint(
                painter: SignatureStyle(ink: billingControllerNew.quantityInk),
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
              billingControllerNew.quantityInk.strokes.clear();
              billingControllerNew.quantityPoints.clear();
              billingControllerNew.update();
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
                  billingControllerNew.descriptionInk.strokes.add(Stroke());
                  billingControllerNew.update();
                }
              },
              onPointerMove: (event) async {
                final RenderObject? object = Get.context?.findRenderObject();
                final localPosition =
                    (object as RenderBox?)?.globalToLocal(event.localPosition);
                if (localPosition != null &&
                    billingControllerNew.descriptionInk.strokes.isNotEmpty) {
                  billingControllerNew.descriptionInk.strokes.last.points.add(
                    StrokePoint(
                      x: localPosition.dx,
                      y: localPosition.dy,
                      t: DateTime.now().millisecondsSinceEpoch,
                    ),
                  );
                  billingControllerNew.update();
                }
              },
              onPointerUp: (event) async {
                billingControllerNew.update();
              },
              onPointerCancel: (event) async {
                debugPrint('Pointer Cancelled');
              },
              child: CustomPaint(
                painter: SignatureStyle(ink: billingControllerNew.descriptionInk),
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
              billingControllerNew.descriptionInk.strokes.clear();
              billingControllerNew.descriptionPoints.clear();
              billingControllerNew.update();
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

    // Initialize filtered list with all clients
    filteredClientList.assignAll(billingControllerNew.clientList);

    void filterClients(String query) {
      if (query.isEmpty) {
        filteredClientList.assignAll(billingControllerNew.clientList);
      } else {
        filteredClientList.assignAll(
            billingControllerNew.clientList.where((client) =>
            client.name?.toLowerCase().contains(query.toLowerCase()) ?? false
            ).toList()
        );
      }
    }

    Get.dialog(
      barrierDismissible: false,
      Obx(() => billingControllerNew.loadingClient.value ?
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
  bool isTouchInsideBox(Offset localPosition, double widthFactor) {
    return localPosition.dx >= 0 &&
        localPosition.dx <= Get.width * widthFactor &&
        localPosition.dy >= 0 &&
        localPosition.dy <= 75; // Adjust height if needed
  }
}

class SignatureStyle extends CustomPainter {
  Ink ink;
  var controller = Get.put(BillingControllerNew());

  SignatureStyle({required this.ink});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.black87
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 4.0;

    for (final stroke in ink.strokes) {
      for (int i = 0; i < stroke.points.length - 1; i++) {
        final p1 = stroke.points[i];
        final p2 = stroke.points[i + 1];
        canvas.drawLine(Offset(p1.x.toDouble(), p1.y.toDouble()),
            Offset(p2.x.toDouble(), p2.y.toDouble()), paint);
      }
    }
  }

  @override
  bool shouldRepaint(SignatureStyle oldDelegate) => true;
}

// This custom widget draws the vertical lines that will always be visible
class VerticalBorderLines extends StatelessWidget {

  BillingControllerNew billingControllerNew = Get.find<BillingControllerNew>();

  @override
  Widget build(BuildContext context) {
    return Obx(() =>
      Row(
        children: [
          // First column (Sr.No - 60px)
          const SizedBox(width: 60),
          // Vertical line
          _buildVerticalLine(),

          // Second column (Particulars - flexible)
          const Expanded(child: SizedBox()),
          // Vertical line
          _buildVerticalLine(),

          // Third column (QTY - 100/120px based on showButtons)
          SizedBox(width: billingControllerNew.showButtons.value
              ? 118.0
              : 98), // You might need to adjust this with Obx() if it changes
          // Vertical line
          _buildVerticalLine(),

          // Fourth column (Rate - 100/120px based on showButtons)
          SizedBox(width: billingControllerNew.showButtons.value
              ? 120.0
              : 100), // You might need to adjust this with Obx() if it changes
          // Vertical line
          _buildVerticalLine(),

          // Fifth column (Amount - 100/120px based on showButtons)
          SizedBox(width: billingControllerNew.showButtons.value
              ? 145.0
              : 120), // You might need to adjust this with Obx() if it changes
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
