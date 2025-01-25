import 'package:billing/app/config/color_constants.dart';
import 'package:billing/app/config/design_constants.dart';
import 'package:billing/controllers/scribble_controller.dart';
import 'package:billing/print/print_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Ink;
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:pdf/pdf.dart';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';

class Billing extends StatelessWidget {
  ScribbleController scribbleController = Get.put(ScribbleController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ScribbleController>(
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Container(
            width: Get.width,
            height: Get.height * 0.97,
            margin:
            const EdgeInsets.only(left: 5.0,right: 5,top: 20),
            // Replace your DesignConstants
            decoration: BoxDecoration(
              border: Border.all(
                  color: AppColors.stainedGlass), // Replace with your color
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 30.0),
                  child: const Text(
                    'Logo',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 24.0,
                    ),
                  ),
                ),
                // Top scribble row
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    descBox(
                        0.44),
                    SizedBox(width: 5,),
                    quantityTextBox(0.20),
                    SizedBox(width: 5,),
                    // Spacer(),
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
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.stainedGlass, width: 2)),
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              scribbleController.addItem();
                            },
                            icon: const Icon(Icons.add)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 10.0),
                // Table Header (with vertical borders only)
                Obx(() => Container(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Table(
                    // border: TableBorder(verticalInside: BorderSide(color: AppColors.stainedGlass)), // Only vertical borders
                    border: TableBorder.all(color: AppColors.stainedGlass),
                    columnWidths: {
                      0: FixedColumnWidth(60.0), // Sr.No
                      1: FlexColumnWidth(), // Particulars
                      2: FixedColumnWidth(scribbleController.showButtons.value ? 120.0 : 100), // QTY
                      3: FixedColumnWidth(scribbleController.showButtons.value ? 120.0 : 100), // Rate
                      4: FixedColumnWidth(scribbleController.showButtons.value ? 120.0 : 100), // Amount
                    },
                    children: const [
                      TableRow(
                        children: [
                          TableCell(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Sr. No.',
                                  textAlign: TextAlign.center,
                                  style:
                                  TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('PARTICULARS',
                                  textAlign: TextAlign.center,
                                  style:
                                  TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('QTY.',
                                  textAlign: TextAlign.center,
                                  style:
                                  TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('RATE',
                                  textAlign: TextAlign.center,
                                  style:
                                  TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('AMOUNT',
                                  textAlign: TextAlign.center,
                                  style:
                                  TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),),
                // Dynamic Rows
                Expanded(
                  child: Obx(
                        () => IgnorePointer(
                      ignoring: true,
                      child: ListView.builder(
                        itemCount: scribbleController.itemList.length,
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, index) {
                          final item = scribbleController.itemList[index];
                          final rate = double.tryParse(item['rate'] ?? '0') ?? 0;
                          final quantity =
                              double.tryParse(item['quantity'] ?? '0') ?? 0;
                          final amount = rate * quantity;

                          return Obx(() =>
                              Row(
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
                                        2: FixedColumnWidth(scribbleController.showButtons.value ? 120.0 : 100),
                                        3: FixedColumnWidth(scribbleController.showButtons.value ? 120.0 : 100),
                                        4: FixedColumnWidth(scribbleController.showButtons.value ? 120.0 : 120),
                                      },
                                      children: [
                                        TableRow(
                                          children: [
                                            Padding(
                                              padding:
                                              const EdgeInsets.only(top: 22.0),
                                              child: Text(
                                                '${index + 1}',
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: item['particulars'] != null
                                                  ? Container(
                                                  alignment: Alignment.topLeft,
                                                  child: Image.memory(
                                                      item['particulars'],
                                                      height: 50,
                                                      fit: BoxFit.contain))
                                                  : Container(),
                                            ),
                                            Padding(
                                              padding:
                                              const EdgeInsets.only(top: 22.0),
                                              child: Text(
                                                item['quantity'] ?? '',
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                              const EdgeInsets.only(top: 22.0),
                                              child: Text(
                                                item['rate'] ?? '',
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                              const EdgeInsets.only(top: 22.0),
                                              child: Text(
                                                '$amount',
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Obx(() =>
                                      Visibility(
                                        visible: scribbleController.showButtons.value,
                                        child: GestureDetector(
                                          onTap: () {
                                            scribbleController.editItem(index);
                                          },
                                          onDoubleTap: () {
                                            scribbleController.deleteItem(index);
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(right: 10.0),
                                            child: Container(
                                              width: 10.0,
                                              height: 10.0,
                                              alignment: Alignment.bottomCenter,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.black, // Dot color
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
                      ),
                    ),
                  ),
                ),
                // Total Row
                Obx(() =>
                    IgnorePointer(
                      ignoring: true,
                      child: Table(
                        border: TableBorder.all(color: AppColors.stainedGlass),
                        columnWidths: {
                          0: FixedColumnWidth(60.0),
                          1: FlexColumnWidth(),
                          2: FixedColumnWidth(scribbleController.showButtons.value ? 240.0 : 200),
                          3: FixedColumnWidth(scribbleController.showButtons.value ? 140.0 : 120),
                          4: FixedColumnWidth(scribbleController.showButtons.value ? 120.0 : 120),
                        },
                        children: [
                          TableRow(
                            children: [
                              const TableCell(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('',
                                      style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                              const TableCell(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('',
                                      style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                              const TableCell(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('TOTAL',
                                      style: TextStyle(fontWeight: FontWeight.bold)),
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
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.stainedGlass,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5))),
                                    ),
                                    onPressed: () {},
                                    child: const Text(
                                      'View',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: DesignConstants.fontSize20),
                                    )),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.stainedGlass,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5))),
                                    ),
                                    onPressed: () {
                                      ///PdfPageFormat.roll57 for pos printer
                                      /// a4 is standard
                                      // scribbleController.printDocument(pageFormat: PdfPageFormat.a4);

                                      final List<Map<String, dynamic>> data = [
                                        {'title': 'Cadbury Dairy Milk', 'price': 15, 'qty': 2},
                                        {'title': 'Parle-G Gluco Biscut', 'price': 5, 'qty': 5},
                                        {'title': 'Fresh Onion - 1KG', 'price': 20, 'qty': 1},
                                        {'title': 'Fresh Sweet Lime', 'price': 20, 'qty': 5},
                                        {'title': 'Maggi', 'price': 10, 'qty': 5},
                                      ];

                                      // Get.to(() =>PrintPage(data));
                                      // scribbleController.printDocument(pageFormat: PdfPageFormat.a4);
                                      // scribbleController.printPOSReceipt(pageFormat: PdfPageFormat.roll57);
                                    },
                                    child: const Text(
                                      'Print',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: DesignConstants.fontSize20),
                                    )),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.stainedGlass,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5))),
                                    ),
                                    onPressed: () {},
                                    child: const Text(
                                      'Save',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: DesignConstants.fontSize20),
                                    )),
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
                                  scribbleController.showButtons.value = !scribbleController.showButtons.value;
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
        );
      },
    );
  }

  Widget rateTextBox(double widthFactor) {
    return Container(
      height: 75,
      width: Get.width * widthFactor,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.stainedGlass),
      ),
      child: ClipRect(
        child: Listener(
          onPointerDown: (event) {
            debugPrint("event kind is ${event.kind}");
            scribbleController.rateInk.strokes.add(Stroke());
            scribbleController.update();
          },
          onPointerMove: (event) {
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
          },
          onPointerUp: (event) {
            scribbleController.update();
          },
          child: CustomPaint(
            painter: SignatureStyle(ink: scribbleController.rateInk),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }


  Widget quantityTextBox(double widthFactor) {
    return Container(
      height: 75,
      width: Get.width * widthFactor,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.stainedGlass),
      ),
      child: ClipRRect(
        child: Listener(

          onPointerDown: (event) {
            // if (event.kind == PointerDeviceKind.stylus) {
            scribbleController.quantityInk.strokes.add(Stroke());
            scribbleController.update();
            // }
          },
          onPointerMove: (event) {
            // if (event.kind == PointerDeviceKind.stylus) {
            final RenderObject? object = Get.context?.findRenderObject();
            final localPosition =
            (object as RenderBox?)?.globalToLocal(event.localPosition);
            if (localPosition != null) {
              scribbleController.quantityInk.strokes.last.points.add(
                StrokePoint(
                    x: localPosition.dx,
                    y: localPosition.dy,
                    t: DateTime.now().millisecondsSinceEpoch),
              );
            }
            scribbleController.update();
            // }
          },
          onPointerUp: (event) {
            // if (event.kind == PointerDeviceKind.stylus) {
            scribbleController.update();
            // }
          },
          child: CustomPaint(
            painter: SignatureStyle(ink: scribbleController.quantityInk),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }

  Widget descBox(double widthFactor) {
    return Container(
      height: 75,
      width: Get.width * widthFactor,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.stainedGlass),
      ),
      child: ClipRect(
        child: Listener(
          onPointerDown: (event) {
            scribbleController.descriptionInk.strokes.add(Stroke());
            scribbleController.update();
          },
          onPointerMove: (event) {
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
          onPointerUp: (event) {
            scribbleController.update();
          },
          child: CustomPaint(
            painter: SignatureStyle(ink: scribbleController.descriptionInk),
            size: Size.infinite,
          ),
        ),
      ),
    );
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
