import 'package:billing/app/config/color_constants.dart';
import 'package:billing/app/config/design_constants.dart';
import 'package:billing/controllers/scribble_controller.dart';
import 'package:billing/print/print_page.dart';
import 'package:billing/utils/one_pointer_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Ink;
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:pdf/pdf.dart';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';

import '../../utils/utility.dart';

class Billing extends StatelessWidget {
  ScribbleController scribbleController = Get.put(ScribbleController());
  final ScrollController scrollController = ScrollController();

  Map<int, List<Offset>> fingerPaths = {};

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ScribbleController>(
      builder: (context) {
        return SafeArea(
          child: Stack(
            children: [
              Scaffold(
                backgroundColor: Colors.white,
                body: Container(
                  width: Get.width,
                  height: Get.height * 0.97,
                  margin: const EdgeInsets.only(left: 5.0, right: 5, top: 20),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.stainedGlass),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: Get.width,
                        child: Stack(
                          children: [
                            Center(
                              child: Container(
                                  padding: const EdgeInsets.only(bottom: 20.0),
                                  child: Image.asset(
                                    "assets/ganpati.jpg",
                                    height: 50,
                                    width: 50,
                                  )),
                            ),
                            Positioned(
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: DesignConstants.padding5),
                                child: Obx(() => Text(
                                      scribbleController
                                          .formattedDateTime.value,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.stainedGlass,
                                      ),
                                    )),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Row(
                        children: [
                          descBox(0.44),
                          SizedBox(
                            width: 5,
                          ),
                          quantityTextBox(0.20),
                          SizedBox(
                            width: 5,
                          ),
                          rateTextBox(0.27),
                          Spacer(),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () {
                                  scribbleController.clearPadAndSignature();
                                },
                                child: Container(
                                  height: 20,
                                  width: 20,
                                  alignment: Alignment.topLeft,
                                  child: Icon(
                                    Icons.close,
                                    color: AppColors.stainedGlass,
                                  ),
                                ),
                              ),
                              IconButton(
                                  onPressed: () async {
                                    await scribbleController.addItem();
                                    scribbleController.clearPadAndSignature();
                                  },
                                  icon: const Icon(Icons.add)),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      // Table Header (with vertical borders only)
                      Obx(
                        () => Container(
                          padding: const EdgeInsets.only(right: 20.0),
                          child: Table(
                            // border: TableBorder(verticalInside: BorderSide(color: AppColors.stainedGlass)), // Only vertical borders
                            border:
                                TableBorder.all(color: AppColors.stainedGlass),
                            columnWidths: {
                              0: FixedColumnWidth(60.0), // Sr.No
                              1: FlexColumnWidth(), // Particulars
                              2: FixedColumnWidth(
                                  scribbleController.showButtons.value
                                      ? 120.0
                                      : 100), // QTY
                              3: FixedColumnWidth(
                                  scribbleController.showButtons.value
                                      ? 120.0
                                      : 100), // Rate
                              4: FixedColumnWidth(
                                  scribbleController.showButtons.value
                                      ? 125.0
                                      : 100), // Amount
                            },
                            children: const [
                              TableRow(
                                children: [
                                  TableCell(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Sr. No.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  TableCell(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('PARTICULARS',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  TableCell(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('QTY.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  TableCell(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('RATE',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  TableCell(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('AMOUNT',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Dynamic Rows
                      Expanded(
                        child: Obx(
                          () {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (scrollController.hasClients) {
                                scrollController.animateTo(
                                  scrollController.position.maxScrollExtent,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                );
                              }
                            });
                            return ListView.builder(
                              itemCount: scribbleController.itemList.length,
                              padding: EdgeInsets.zero,
                              controller: scrollController,
                              itemBuilder: (context, index) {
                                final item = scribbleController.itemList[index];
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

                                return Obx(
                                  () => Row(
                                    children: [
                                      Expanded(
                                        child: Table(
                                          border: const TableBorder(
                                            verticalInside: BorderSide(
                                                color: AppColors.stainedGlass),
                                          ),
                                          columnWidths: {
                                            0: FixedColumnWidth(60.0),
                                            1: FlexColumnWidth(),
                                            2: FixedColumnWidth(
                                                scribbleController
                                                        .showButtons.value
                                                    ? 120.0
                                                    : 100),
                                            3: FixedColumnWidth(
                                                scribbleController
                                                        .showButtons.value
                                                    ? 120.0
                                                    : 100),
                                            4: FixedColumnWidth(
                                                scribbleController
                                                        .showButtons.value
                                                    ? 120.0
                                                    : 120),
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
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 22.0),
                                                  child: Text(
                                                    item['rate'] ?? '',
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 22.0),
                                                  child: Text(
                                                    '$amountDisplay',
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Obx(
                                        () => Visibility(
                                          visible: scribbleController
                                              .showButtons.value,
                                          child: GestureDetector(
                                            onTap: () {
                                              scribbleController
                                                  .editItem(index);
                                            },
                                            onDoubleTap: () {
                                              scribbleController
                                                  .deleteItem(index);
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 10.0),
                                              child: Container(
                                                width: 15.0,
                                                height: 15.0,
                                                alignment:
                                                    Alignment.bottomCenter,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color:
                                                      Colors.black, // Dot color
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      // Total Row
                      Obx(
                        () => Table(
                          border:
                              TableBorder.all(color: AppColors.stainedGlass),
                          columnWidths: {
                            0: FixedColumnWidth(60.0),
                            1: FlexColumnWidth(),
                            2: FixedColumnWidth(
                                scribbleController.showButtons.value
                                    ? 240.0
                                    : 200),
                            3: FixedColumnWidth(
                                scribbleController.showButtons.value
                                    ? 145.0
                                    : 120),
                            4: FixedColumnWidth(
                                scribbleController.showButtons.value
                                    ? 120.0
                                    : 120),
                          },
                          children: [
                            TableRow(
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
                                    child: Text('',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                const TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('TOTAL',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '${scribbleController.totalAmount}',
                                    textAlign: TextAlign.center,
                                  ), // Dynamic total calculation
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        // margin: const EdgeInsets.only(top: 20.0),
                        height: 110,

                        padding: EdgeInsets.zero,
                        // decoration: BoxDecoration(
                        //     border: Border.all(color: AppColors.stainedGlass)),
                        child: Obx(
                          () => Column(
                            children: [
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.only(
                                    top: DesignConstants.padding5),
                                child: Visibility(
                                  // visible: false,
                                  visible: scribbleController.showButtons.value,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Visibility(
                                        visible: false,
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.stainedGlass,
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
                                                  AppColors.stainedGlass,
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
                                                  AppColors.stainedGlass,
                                              shape:
                                                  const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  5))),
                                            ),
                                            onPressed: scribbleController
                                                    .isPrinting.value
                                                ? null
                                                : () {
                                                    scribbleController
                                                        .printPdfReceipt();
                                                  },
                                            child: scribbleController
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
                                                  AppColors.stainedGlass,
                                              shape:
                                                  const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  5))),
                                            ),
                                            onPressed: () {
                                              scribbleController.itemList
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
                                        scribbleController.showButtons.value =
                                            !scribbleController
                                                .showButtons.value;
                                      },
                                      icon: const Icon(
                                        Icons.house_siding_rounded,
                                        size: 30,
                                        color: AppColors.stainedGlass,
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

              // Add loading overlay
              // Improved loading overlay
              Obx(() => scribbleController.isModelLoading.value
                  ? Container(
                      color: Colors.black54,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 20),
                              Obx(() => Text(
                                    scribbleController.downloadStatus.value,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink()),
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
            border: Border.all(color: AppColors.stainedGlass),
          ),
          child: ClipRect(
              child: Listener(
            onPointerDown: (event) {
              if (event.kind == PointerDeviceKind.stylus ||
                  event.kind == PointerDeviceKind.touch) {
                if (isTouchInsideBox(
                    event.localPosition, Get.width * widthFactor)) {
                  scribbleController.rateInk.strokes.add(Stroke());
                  scribbleController.update();
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
                    scribbleController.rateInk.strokes.isNotEmpty) {
                  scribbleController.rateInk.strokes.last.points.add(
                    StrokePoint(
                      x: localPosition.dx,
                      y: localPosition.dy,
                      t: DateTime.now().millisecondsSinceEpoch,
                    ),
                  );
                  scribbleController.update();
                }
              }
            },
            onPointerUp: (event) {
              if (event.kind == PointerDeviceKind.stylus ||
                  event.kind == PointerDeviceKind.touch) {
                scribbleController.update();
              }
            },
            onPointerCancel: (event) {
              debugPrint('Pointer Cancelled');
            },
            child: CustomPaint(
              painter: SignatureStyle(ink: scribbleController.rateInk),
              size: Size.infinite,
            ),
          )),
        ),
        Positioned(
          top: -0,
          right: -0,
          child: GestureDetector(
            onTap: () {
              scribbleController.rateInk.strokes.clear();
              scribbleController.ratePoints.clear();
              scribbleController.update();
            },
            child: Container(
              decoration: BoxDecoration(
                // color: Colors.white, // Background color to make the button stand out
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, color: Colors.black),
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
            border: Border.all(color: AppColors.stainedGlass),
          ),
          child: ClipRRect(
            child: Listener(
              onPointerDown: (event) {
                if (isTouchInsideBox(
                    event.localPosition, Get.width * widthFactor)) {
                  scribbleController.quantityInk.strokes.add(Stroke());
                  scribbleController.update();
                }
              },
              onPointerMove: (event) {
                final RenderObject? object = Get.context?.findRenderObject();
                final localPosition =
                    (object as RenderBox?)?.globalToLocal(event.localPosition);
                if (localPosition != null) {
                  scribbleController.quantityInk.strokes.last.points.add(
                    StrokePoint(
                      x: localPosition.dx,
                      y: localPosition.dy,
                      t: DateTime.now().millisecondsSinceEpoch,
                    ),
                  );
                  scribbleController.update();
                }
              },
              onPointerUp: (event) {
                scribbleController.update();
              },
              onPointerCancel: (event) {
                // Ignore the cancel event, don't stop drawing
                debugPrint('Pointer Cancelled');
              },
              child: CustomPaint(
                painter: SignatureStyle(ink: scribbleController.quantityInk),
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
              scribbleController.quantityInk.strokes.clear();
              scribbleController.quantityPoints.clear();
              scribbleController.update();
            },
            child: Container(
              decoration: BoxDecoration(
                // color: Colors.white, // Background color to make the button stand out
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, color: Colors.black),
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
            border: Border.all(color: AppColors.stainedGlass),
          ),
          child: ClipRect(
            child: Listener(
              onPointerDown: (event) async {
                if (isTouchInsideBox(
                    event.localPosition, Get.width * widthFactor)) {
                  scribbleController.descriptionInk.strokes.add(Stroke());
                  scribbleController.update();
                }
              },
              onPointerMove: (event) async {
                final RenderObject? object = Get.context?.findRenderObject();
                final localPosition =
                    (object as RenderBox?)?.globalToLocal(event.localPosition);
                if (localPosition != null &&
                    scribbleController.descriptionInk.strokes.isNotEmpty) {
                  scribbleController.descriptionInk.strokes.last.points.add(
                    StrokePoint(
                      x: localPosition.dx,
                      y: localPosition.dy,
                      t: DateTime.now().millisecondsSinceEpoch,
                    ),
                  );
                  scribbleController.update();
                }
              },
              onPointerUp: (event) async {
                scribbleController.update();
              },
              onPointerCancel: (event) async {
                debugPrint('Pointer Cancelled');
              },
              child: CustomPaint(
                painter: SignatureStyle(ink: scribbleController.descriptionInk),
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
              scribbleController.descriptionInk.strokes.clear();
              scribbleController.descriptionPoints.clear();
              scribbleController.update();
            },
            child: Container(
              decoration: BoxDecoration(
                // color: Colors.white, // Background color to make the button stand out
                shape: BoxShape.circle,
              ),
              // padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.close,
                color: Colors.black,
              ),
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
  var controller = Get.put(ScribbleController());

  SignatureStyle({required this.ink});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppColors.stainedGlass
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 5.0;

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
