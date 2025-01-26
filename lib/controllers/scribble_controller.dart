import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:billing/ui/billing/billing.dart';
import 'package:flutter/material.dart' hide Ink;
import 'package:get/get.dart';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';
import '../utils/activity_indicator.dart';
import 'package:flutter/services.dart'; // Import this package

class ScribbleController extends GetxController {

  var itemList = <Map<String, dynamic>>[].obs;

  final DigitalInkRecognizerModelManager modelManager =
  DigitalInkRecognizerModelManager();
  final String language = 'en-US';
  late final DigitalInkRecognizer digitalInkRecognizer =
  DigitalInkRecognizer(languageCode: language);
  final Ink rateInk = Ink();
  final Ink quantityInk = Ink();
  final Ink descriptionInk = Ink();
  List<StrokePoint> ratePoints = [];
  List<StrokePoint> descriptionPoints = [];
  List<StrokePoint> quantityPoints = [];
  String recognizedRate = '';
  String recognizedQuantity = '';
  RxBool showButtons = false.obs;

  RxBool isModelLoading = true.obs;
  RxString downloadStatus = 'Initializing...'.obs;

  Future<bool> _downloadModelWithTimeout() async {
    try {
      // Create a timeout future
      final timeout = Future.delayed(const Duration(seconds: 30), () {
        throw TimeoutException('Model download took too long');
      });

      // Create the download future
      final download = modelManager.downloadModel(language);

      // Race between timeout and download
      final result = await Future.any([download, timeout]);
      return result;
    } on TimeoutException {
      throw 'Download timed out. Please check your internet connection and try again.';
    } catch (e) {
      throw 'Failed to download model: $e';
    }
  }

  @override
  void onInit() async {
    super.onInit();
    try {
      clearPadAndSignature();
      isModelLoading(true);
      downloadStatus('Checking model status...');

      bool downloadedModel = await isModelDownloaded();
      if (!downloadedModel) {
        downloadStatus('Downloading recognition model...');

        // Try to download with timeout
        bool success = await _downloadModelWithTimeout();
        if (!success) {
          throw 'Model download failed';
        }

        // Verify download
        downloadStatus('Verifying download...');
        bool verified = await isModelDownloaded();
        if (!verified) {
          throw 'Model verification failed';
        }
      }

      downloadStatus('Model ready');
      isModelLoading(false);
    } catch (e) {
      isModelLoading(false);
      downloadStatus('Error: $e');

      // Show error dialog
      Get.dialog(
        AlertDialog(
          title: const Text('Initialization Error'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              child: const Text('Retry'),
              onPressed: () {
                Get.back();
                onInit(); // Retry initialization
              },
            ),
            TextButton(
              child: const Text('Close App'),
              onPressed: () {
                SystemNavigator.pop(); // Close the app
              },
            ),
          ],
        ),
        barrierDismissible: false,
      );
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    digitalInkRecognizer.close();
    super.onClose();
  }

  void clearPad() {
    rateInk.strokes.clear();
    ratePoints.clear();
    quantityInk.strokes.clear();
    quantityPoints.clear();
    descriptionInk.strokes.clear();
    descriptionPoints.clear();
    recognizedRate = '';
    recognizedQuantity = '';
    update();
  }

  Future<bool> isModelDownloaded() async {
    // Check if the model is downloaded
    bool isDownloaded = await modelManager.isModelDownloaded(language);

    // Return the appropriate string based on the download status
    return isDownloaded;
  }

  Future<void> deleteModel() async {
    Toast().show(
      'Deleting model...',
      modelManager
          .deleteModel(language)
          .then((value) => value ? 'success' : 'failed'),
      Get.context!,
    );
  }

  Future<void> downloadModel() async {
    Toast().show(
      'Downloading model...',
      modelManager
          .downloadModel(language)
          .then((value) => value ? 'success' : 'failed'),
      Get.context!,
    );
  }

  Future<void> recogniseRateText() async {
    try {
      final candidates = await digitalInkRecognizer.recognize(rateInk);

      // Initialize recognizedRate as empty
      recognizedRate = '';

      if (candidates.isNotEmpty) {
        var text = candidates[0].text;

        // Perform replacements and assign them back to `text`
        text = text.toUpperCase()
            .replaceAll('O', '0')
            .replaceAll('I', '1')
            .replaceAll('L', '1')
            .replaceAll('U', '4')
            .replaceAll('A', '4')
            .replaceAll('Z', '2')
            .replaceAll('\\', '1')
            .replaceAll('/', '1')
            .replaceAll('H', '4')
            .replaceAll('B', '3')
            .replaceAll('S', '5')
            .replaceAll('Z', '2')
            .replaceAll('T', '7');

        recognizedRate = text.replaceAll(RegExp(r'[^0-9]'), '');

        // If no digits are found after cleaning, set as 'No'
        if (recognizedRate.isEmpty) {
          recognizedRate = 'No';
        }
      } else {
        recognizedRate = 'No candidates recognized';
      }

      update();
    } catch (e) {

    }
  }

  Future<void> recogniseQuantityText() async {
    try {
      final candidates = await digitalInkRecognizer.recognize(quantityInk);

      recognizedQuantity = ''; // Initialize recognizedQuantity

      if (candidates.isNotEmpty) {
        var text = candidates[0].text;

        // Perform replacements and assign them back to `text`
        text = text.toUpperCase()
            .replaceAll('O', '0')
            .replaceAll('I', '1')
            .replaceAll('L', '1')
            .replaceAll('U', '4')
            .replaceAll('A', '4')
            .replaceAll('Z', '2')
            .replaceAll('\\', '1')
            .replaceAll('/', '1')
            .replaceAll('H', '4')
            .replaceAll('B', '3')
            .replaceAll('S', '5')
            .replaceAll('Z', '2')
            .replaceAll('T', '7');

        recognizedQuantity = text.replaceAll(RegExp(r'[^0-9]'), '');

        // If no digits are found after cleaning, set as 'No'
        if (recognizedQuantity.isEmpty) {
          recognizedQuantity = 'No';
        }
      } else {
        recognizedQuantity = 'No candidates recognized';
      }

      update();
    } catch (e) {
      // Error handling
    }
  }

  Future<Uint8List?> convertToPngBytes(double width, double height) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
        recorder, Rect.fromPoints(Offset.zero, Offset(width, height)));

    final painter = SignatureStyle(ink: descriptionInk);
    painter.paint(canvas, Size(width, height));

    final ui.Image image = await recorder.endRecording().toImage(
        width.toInt(), height.toInt());

    final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }


  Future<void> addItem() async {
    await recogniseRateText();
    await recogniseQuantityText();

    Uint8List? particularImage = await convertToPngBytes(Get.width * 0.8, 75,);
    if (particularImage != null && recognizedQuantity.isNotEmpty &&
        recognizedRate.isNotEmpty) {
      itemList.add({
        'particulars': particularImage,
        'quantity': recognizedQuantity,
        'rate': recognizedRate,
      });
      update();

    } else {
      Get.snackbar("Error", "Field is Empty");
    }
  }

  double get totalAmount {
    return itemList.fold(0, (sum, item) {
      final rate = double.tryParse(item['rate'] ?? '0') ?? 0;
      final quantity = double.tryParse(item['quantity'] ?? '0') ?? 0;
      return sum + (rate * quantity);
    });
  }

  void clearPadAndSignature() {
    clearPad();
  }

  void editItem(int index) {
    final item = itemList[index];

    Get.defaultDialog(
      title: 'Edit Item',
      content: Column(
        children: [
          TextField(
            keyboardType: TextInputType.number,
            controller: TextEditingController(text: item['quantity']),
            decoration: const InputDecoration(labelText: 'quantity'),
            onChanged: (value) {
              itemList[index]['quantity'] = value;
            },
          ),
          TextField(
            keyboardType: TextInputType.number,
            controller: TextEditingController(text: item['rate']),
            decoration: const InputDecoration(labelText: 'rate'),
            onChanged: (value) {
              itemList[index]['rate'] = value;
            },
          ),
        ],
      ),
      textConfirm: 'Save',
      onConfirm: () {
        update();
        Get.back();
      },
    );
  }

  void deleteItem(int index) {
    itemList.removeAt(index);
    update();
  }

  // Future<void> printDocument({required PdfPageFormat pageFormat}) async {
  //   final doc = pw.Document();
  //
  //   // Define margins and calculate available height dynamically
  //   const double topMargin = 10.0;
  //   const double bottomMargin = 10.0;
  //   const double headerHeight = 20.0; // Height of the header section
  //   final double maxHeight = pageFormat.height - topMargin - bottomMargin;
  //
  //   double currentHeight = 0;
  //
  //   // Function to build table rows and handle height check
  //   List<pw.TableRow> buildTableRows(
  //       List<Map<String, dynamic>> items, int startingIndex, double startHeight) {
  //     final rows = <pw.TableRow>[];
  //     currentHeight = startHeight;
  //
  //     const double rowHeight = 50.0;
  //     const double columnWidth = 100.0; // Fixed column width
  //     const int maxRowsPerPage = 12; // Max number of rows per page
  //
  //     for (int localIndex = 0; localIndex < items.length; localIndex++) {
  //       final globalIndex = startingIndex + localIndex; // Adjust index globally
  //       final item = items[localIndex];
  //       final rate = double.tryParse(item['rate'] ?? '0') ?? 0;
  //       final quantity = double.tryParse(item['quantity'] ?? '0') ?? 0;
  //       final amount = rate * quantity;
  //
  //       // If adding another row exceeds the maxHeight or max rows, break to create a new page
  //       if (rows.length >= maxRowsPerPage) {
  //         break;
  //       }
  //
  //       final particularsWidget = item['particulars'] is Uint8List
  //           ? pw.Image(
  //         pw.MemoryImage(item['particulars']),
  //         height: 50,
  //         fit: pw.BoxFit.contain,
  //       )
  //           : pw.Text(item['particulars'] ?? '', textAlign: pw.TextAlign.center);
  //
  //       rows.add(pw.TableRow(children: [
  //         pw.Container(
  //           width: columnWidth,
  //           height: rowHeight,
  //           alignment: pw.Alignment.center,
  //           child: pw.Text('${globalIndex + 1}', textAlign: pw.TextAlign.center), // Use global index
  //         ),
  //         pw.Container(
  //           // width: columnWidth,
  //           // height: rowHeight,
  //           alignment: pw.Alignment.center,
  //           child: particularsWidget,
  //         ),
  //         pw.Container(
  //           width: columnWidth,
  //           height: rowHeight,
  //           alignment: pw.Alignment.center,
  //           child: pw.Text(item['quantity'] ?? '', textAlign: pw.TextAlign.center),
  //         ),
  //         pw.Container(
  //           width: columnWidth,
  //           height: rowHeight,
  //           alignment: pw.Alignment.center,
  //           child: pw.Text(item['rate'] ?? '', textAlign: pw.TextAlign.center),
  //         ),
  //         pw.Container(
  //           width: columnWidth,
  //           height: rowHeight,
  //           alignment: pw.Alignment.center,
  //           child: pw.Text('$amount', textAlign: pw.TextAlign.center),
  //         ),
  //       ]));
  //     }
  //
  //     return rows;
  //   }
  //
  //   int itemIndex = 0;
  //   while (itemIndex < itemList.length) {
  //     // Start with the header height
  //     currentHeight = headerHeight;
  //
  //     // Add rows to the page while respecting the height limit
  //     final rows = buildTableRows(itemList.sublist(itemIndex), itemIndex, currentHeight);
  //
  //     // Check if this is the last page
  //     bool isLastPage = itemIndex + rows.length >= itemList.length;
  //
  //     doc.addPage(
  //       pw.Page(
  //         pageFormat: pageFormat,
  //         build: (context) => pw.Column(
  //           children: [
  //             // Table with fixed cell size and dynamic content
  //
  //             pw.Text('Logo',style: pw.TextStyle(fontSize: 24)),
  //             pw.SizedBox(height: 20),
  //             pw.Table(
  //               border: pw.TableBorder.all(),
  //               children: [
  //                 pw.TableRow(children: [
  //                   pw.Container(
  //                     width: 100,
  //                     height: 50,
  //                     alignment: pw.Alignment.center,
  //                     child: pw.Text('Sr.No.', textAlign: pw.TextAlign.center),
  //                   ),
  //                   pw.Container(
  //                     width: 100,
  //                     height: 50,
  //                     alignment: pw.Alignment.center,
  //                     child: pw.Text('Particulars', textAlign: pw.TextAlign.center),
  //                   ),
  //                   pw.Container(
  //                     width: 100,
  //                     height: 50,
  //                     alignment: pw.Alignment.center,
  //                     child: pw.Text('QTY', textAlign: pw.TextAlign.center),
  //                   ),
  //                   pw.Container(
  //                     width: 100,
  //                     height: 50,
  //                     alignment: pw.Alignment.center,
  //                     child: pw.Text('RATE', textAlign: pw.TextAlign.center),
  //                   ),
  //                   pw.Container(
  //                     width: 100,
  //                     height: 50,
  //                     alignment: pw.Alignment.center,
  //                     child: pw.Text('AMOUNT', textAlign: pw.TextAlign.center),
  //                   ),
  //                 ]),
  //                 ...rows,
  //                 // Add the total row only on the last page
  //                 if (isLastPage)
  //                   pw.TableRow(children: [
  //                     pw.Text('', textAlign: pw.TextAlign.center),
  //                     pw.Text('', textAlign: pw.TextAlign.center),
  //                     pw.Text('', textAlign: pw.TextAlign.center),
  //                     pw.Container(
  //                       width: 100,
  //                       height: 50,
  //                       alignment: pw.Alignment.center,
  //                       child: pw.Text('Total', textAlign: pw.TextAlign.center),
  //                     ),
  //                     pw.Container(
  //                       width: 100,
  //                       height: 50,
  //                       alignment: pw.Alignment.center,
  //                       child: pw.Text('$totalAmount', textAlign: pw.TextAlign.center),
  //                     ),
  //                   ]),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //
  //     itemIndex += rows.length; // Move to the next chunk of items
  //   }
  //
  //   // Print the document
  //   await Printing.layoutPdf(
  //     onLayout: (PdfPageFormat format) async => doc.save(),
  //   );
  // }
  //
  // Future<void> printPOSReceipt({required PdfPageFormat pageFormat}) async {
  //   final doc = pw.Document();
  //
  //   const double topMargin = 10.0;
  //   const double bottomMargin = 10.0;
  //   const double headerHeight = 20.0;
  //   final double maxHeight = pageFormat.height - topMargin - bottomMargin;
  //
  //   // Define row height and column width for POS
  //   const double rowHeight = 30.0;
  //   const double columnWidth = 100.0; // Adjust based on receipt width
  //   const int maxRowsPerPage = 10;
  //
  //   // Sample receipt data
  //   List<Map<String, dynamic>> items = [
  //     {'particulars': 'Item 1', 'quantity': '1', 'rate': '10.00', 'amount': '10.00'},
  //     {'particulars': 'Item 2', 'quantity': '2', 'rate': '5.00', 'amount': '10.00'},
  //     {'particulars': 'Item 3', 'quantity': '1', 'rate': '20.00', 'amount': '20.00'},
  //   ];
  //
  //   double currentHeight = headerHeight;
  //
  //   List<pw.TableRow> buildTableRows(
  //       List<Map<String, dynamic>> items, int startingIndex, double startHeight) {
  //     final rows = <pw.TableRow>[];
  //     currentHeight = startHeight;
  //
  //     for (int localIndex = 0; localIndex < items.length; localIndex++) {
  //       final globalIndex = startingIndex + localIndex;
  //       final item = items[localIndex];
  //       final rate = double.tryParse(item['rate'] ?? '0') ?? 0;
  //       final quantity = double.tryParse(item['quantity'] ?? '0') ?? 0;
  //       final amount = rate * quantity;
  //
  //       // Add the row only if it fits within the maxRowsPerPage
  //       if (rows.length >= maxRowsPerPage) {
  //         break;
  //       }
  //
  //       rows.add(pw.TableRow(children: [
  //         pw.Container(
  //           width: columnWidth,
  //           height: rowHeight,
  //           alignment: pw.Alignment.centerLeft,
  //           padding: const pw.EdgeInsets.symmetric(horizontal: 5),
  //           child: pw.Text('${globalIndex + 1}', style: pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.left),
  //         ),
  //         pw.Container(
  //           width: columnWidth * 2, // Adjust to fit content
  //           height: rowHeight,
  //           alignment: pw.Alignment.centerLeft,
  //           padding: const pw.EdgeInsets.symmetric(horizontal: 5),
  //           child: pw.Text(item['particulars'] ?? '', style: pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.left),
  //         ),
  //         pw.Container(
  //           width: columnWidth,
  //           height: rowHeight,
  //           alignment: pw.Alignment.centerRight,
  //           padding: const pw.EdgeInsets.symmetric(horizontal: 5),
  //           child: pw.Text(item['quantity'] ?? '', style: pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.right),
  //         ),
  //         pw.Container(
  //           width: columnWidth,
  //           height: rowHeight,
  //           alignment: pw.Alignment.centerRight,
  //           padding: const pw.EdgeInsets.symmetric(horizontal: 5),
  //           child: pw.Text(item['rate'] ?? '', style: pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.right),
  //         ),
  //         pw.Container(
  //           width: columnWidth,
  //           height: rowHeight,
  //           alignment: pw.Alignment.centerRight,
  //           padding: const pw.EdgeInsets.symmetric(horizontal: 5),
  //           child: pw.Text('$amount', style: pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.right),
  //         ),
  //       ]));
  //     }
  //
  //     return rows;
  //   }
  //
  //   int itemIndex = 0;
  //   while (itemIndex < items.length) {
  //     // Start with the header height
  //     currentHeight = headerHeight;
  //
  //     // Add rows to the page while respecting the height limit
  //     final rows = buildTableRows(items.sublist(itemIndex), itemIndex, currentHeight);
  //
  //     // Create the receipt page
  //     doc.addPage(
  //       pw.Page(
  //         pageFormat: pageFormat,
  //         build: (context) => pw.Column(
  //           children: [
  //             pw.Align(
  //               alignment: pw.Alignment.center,
  //               child: pw.Text('Receipt', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
  //             ),
  //             pw.SizedBox(height: 10),
  //             pw.Table(
  //               border: pw.TableBorder.all(),
  //               children: [
  //                 pw.TableRow(children: [
  //                   pw.Container(
  //                     width: columnWidth,
  //                     height: rowHeight,
  //                     alignment: pw.Alignment.centerLeft,
  //                     padding: const pw.EdgeInsets.symmetric(horizontal: 5),
  //                     child: pw.Text('Sr. No.', style: pw.TextStyle(fontSize: 10)),
  //                   ),
  //                   pw.Container(
  //                     width: columnWidth * 2, // Adjust to fit content
  //                     height: rowHeight,
  //                     alignment: pw.Alignment.centerLeft,
  //                     padding: const pw.EdgeInsets.symmetric(horizontal: 5),
  //                     child: pw.Text('Particulars', style: pw.TextStyle(fontSize: 10)),
  //                   ),
  //                   pw.Container(
  //                     width: columnWidth,
  //                     height: rowHeight,
  //                     alignment: pw.Alignment.centerRight,
  //                     padding: const pw.EdgeInsets.symmetric(horizontal: 5),
  //                     child: pw.Text('Qty', style: pw.TextStyle(fontSize: 10)),
  //                   ),
  //                   pw.Container(
  //                     width: columnWidth,
  //                     height: rowHeight,
  //                     alignment: pw.Alignment.centerRight,
  //                     padding: const pw.EdgeInsets.symmetric(horizontal: 5),
  //                     child: pw.Text('Rate', style: pw.TextStyle(fontSize: 10)),
  //                   ),
  //                   pw.Container(
  //                     width: columnWidth,
  //                     height: rowHeight,
  //                     alignment: pw.Alignment.centerRight,
  //                     padding: const pw.EdgeInsets.symmetric(horizontal: 5),
  //                     child: pw.Text('Amount', style: pw.TextStyle(fontSize: 10)),
  //                   ),
  //                 ]),
  //                 ...rows,
  //                 // Add Total at the end of the receipt
  //                 pw.TableRow(children: [
  //                   pw.Text('', style: pw.TextStyle(fontSize: 10)),
  //                   pw.Text('Total', style: pw.TextStyle(fontSize: 10)),
  //                   pw.Text('', style: pw.TextStyle(fontSize: 10)),
  //                   pw.Text('', style: pw.TextStyle(fontSize: 10)),
  //                   pw.Text('30.00', style: pw.TextStyle(fontSize: 10)), // Update with actual total
  //                 ]),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //
  //     itemIndex += rows.length;
  //   }
  //
  //   // Print the document
  //   await Printing.layoutPdf(
  //     onLayout: (PdfPageFormat format) async => doc.save(),
  //   );
  // }




}
