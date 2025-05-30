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

import '../../app/config/constants_text.dart';
import '../../utils/utility.dart';

class Billing extends StatelessWidget {
  BillingController billingController = Get.find<BillingController>();
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BillingController>(
      builder: (context) {
        return SafeArea(
          child: Stack(
            children: [
              Scaffold(
                backgroundColor:AppColors.peachColor,
                body: Container(
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
                                      billingController
                                          .formattedDateTime.value,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.appBgColor,
                                      ),
                                    )),
                                  ),
                                  Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: DesignConstants.padding5),
                                      child: Text(
                                        'To : Customer',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.appBgColor,
                                        ),
                                      )),
                                  Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: DesignConstants.padding5),
                                      child: Text(
                                        'Mob : ********00',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.appBgColor,
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
                                  billingController.clearPadAndSignature();
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
                                    await billingController.addItem();
                                    billingController.clearPadAndSignature();
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
                                            billingController.showButtons.value
                                                ? 120.0
                                                : 100), // QTY
                                        3: FixedColumnWidth(
                                            billingController.showButtons.value
                                                ? 120.0
                                                : 100), // Rate
                                        4: FixedColumnWidth(
                                            billingController.showButtons.value
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
                                        itemCount: billingController.itemList.length,
                                        padding: EdgeInsets.zero,
                                        controller: scrollController,
                                        itemBuilder: (context, index) {
                                          final item = billingController.itemList[index];
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
                                                        billingController
                                                            .showButtons.value
                                                            ? 130.0
                                                            : 120),
                                                    3: FixedColumnWidth(
                                                        billingController
                                                            .showButtons.value
                                                            ? 130.0
                                                            : 120),
                                                    4: FixedColumnWidth(
                                                        billingController
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
                                                  visible: billingController
                                                      .showButtons.value,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      billingController
                                                          .editItem(index);
                                                    },
                                                    onDoubleTap: () {
                                                      billingController
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
                                billingController
                                    .showButtons.value
                                    ? 120.0
                                    : 100),
                            3: FixedColumnWidth(
                                billingController
                                    .showButtons.value
                                    ? 121.0
                                    : 100),
                            4: FixedColumnWidth(
                                billingController
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
                                        '${billingController.totalQty}',
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
                                    '${billingController.totalAmount}',
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
                                  visible: billingController.showButtons.value,
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
                                            onPressed: billingController
                                                .isPrinting.value
                                                ? null
                                                : () async {
                                              billingController.printPdfReceipt();
                                              await billingController.shopDetailApi();
                                            },
                                            child: billingController
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
                                                : const Text(
                                              'Print Receipt',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize:
                                                  DesignConstants
                                                      .fontSize16),
                                            ))),
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
                                              billingController.itemList
                                                  .clear();
                                            },
                                            child: const Text(
                                              'Clear Receipt',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: DesignConstants
                                                      .fontSize16),
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
                                            onPressed: () async {
                                              await billingController.saveReceiptAsPdf();
                                            },
                                            child: const Text(
                                              'Save Receipt',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: DesignConstants
                                                      .fontSize16),
                                            )),
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
                                        billingController.showButtons.value =
                                        !billingController
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
            ],
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
                  billingController.rateInk.strokes.add(Stroke());
                  billingController.update();
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
                    billingController.rateInk.strokes.isNotEmpty) {
                  billingController.rateInk.strokes.last.points.add(
                    StrokePoint(
                      x: localPosition.dx,
                      y: localPosition.dy,
                      t: DateTime.now().millisecondsSinceEpoch,
                    ),
                  );
                  billingController.update();
                }
              }
            },
            onPointerUp: (event) {
              if (event.kind == PointerDeviceKind.stylus ||
                  event.kind == PointerDeviceKind.touch) {
                billingController.update();
              }
            },
            onPointerCancel: (event) {
              debugPrint('Pointer Cancelled');
            },
            child: CustomPaint(
              painter: SignatureStyle(ink: billingController.rateInk),
              size: Size.infinite,
            ),
          )),
        ),
        Positioned(
          top: -0,
          right: -0,
          child: GestureDetector(
            onTap: () {
              billingController.rateInk.strokes.clear();
              billingController.ratePoints.clear();
              billingController.update();
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
                  billingController.quantityInk.strokes.add(Stroke());
                  billingController.update();
                }
              },
              onPointerMove: (event) {
                final RenderObject? object = Get.context?.findRenderObject();
                final localPosition =
                    (object as RenderBox?)?.globalToLocal(event.localPosition);
                if (localPosition != null) {
                  billingController.quantityInk.strokes.last.points.add(
                    StrokePoint(
                      x: localPosition.dx,
                      y: localPosition.dy,
                      t: DateTime.now().millisecondsSinceEpoch,
                    ),
                  );
                  billingController.update();
                }
              },
              onPointerUp: (event) {
                billingController.update();
              },
              onPointerCancel: (event) {
                // Ignore the cancel event, don't stop drawing
                debugPrint('Pointer Cancelled');
              },
              child: CustomPaint(
                painter: SignatureStyle(ink: billingController.quantityInk),
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
              billingController.quantityInk.strokes.clear();
              billingController.quantityPoints.clear();
              billingController.update();
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
                  billingController.descriptionInk.strokes.add(Stroke());
                  billingController.update();
                }
              },
              onPointerMove: (event) async {
                final RenderObject? object = Get.context?.findRenderObject();
                final localPosition =
                    (object as RenderBox?)?.globalToLocal(event.localPosition);
                if (localPosition != null &&
                    billingController.descriptionInk.strokes.isNotEmpty) {
                  billingController.descriptionInk.strokes.last.points.add(
                    StrokePoint(
                      x: localPosition.dx,
                      y: localPosition.dy,
                      t: DateTime.now().millisecondsSinceEpoch,
                    ),
                  );
                  billingController.update();
                }
              },
              onPointerUp: (event) async {
                billingController.update();
              },
              onPointerCancel: (event) async {
                debugPrint('Pointer Cancelled');
              },
              child: CustomPaint(
                painter: SignatureStyle(ink: billingController.descriptionInk),
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
              billingController.descriptionInk.strokes.clear();
              billingController.descriptionPoints.clear();
              billingController.update();
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
  var controller = Get.put(BillingController());

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

  BillingController billingController = Get.find<BillingController>();

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
          SizedBox(width: billingController.showButtons.value
              ? 118.0
              : 98), // You might need to adjust this with Obx() if it changes
          // Vertical line
          _buildVerticalLine(),

          // Fourth column (Rate - 100/120px based on showButtons)
          SizedBox(width: billingController.showButtons.value
              ? 120.0
              : 100), // You might need to adjust this with Obx() if it changes
          // Vertical line
          _buildVerticalLine(),

          // Fifth column (Amount - 100/120px based on showButtons)
          SizedBox(width: billingController.showButtons.value
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
