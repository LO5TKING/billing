import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:typed_data';
import 'dart:async';
import 'package:image/image.dart' as img;
// Removed unused import: import 'package:image/image.dart' show dilate;
// Removed unused import: import 'package:pdf/pdf.dart';
// Removed unused import: import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart'; // Keep commented if not used
// Removed unused import: import 'package:path_provider/path_provider.dart';
// Removed unused import: import 'dart:io';
import 'package:flutter/material.dart' hide Image;
import 'dart:math' as math;

// Removed unused import: import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/splash_screen_controller.dart';

class PrintController extends GetxController {
  final SplashScreenController _splashController =
      Get.find<SplashScreenController>();

  Future<void> printPdfReceipt(List<Map<String, dynamic>> items) async {
    if (!_splashController.isConnected.value) {
      throw Exception('No printer connected');
    }

    final device = _splashController.connectedDevice;
    if (device == null) {
      throw Exception('No printer device available');
    }

    try {
      List<BluetoothService> services = await device.discoverServices();
      BluetoothCharacteristic? writeCharacteristic;

      // Look for the printer service (usually 0xFF00)
      for (var service in services) {
        if (service.uuid.toString().toUpperCase().contains('FF00')) {
          for (var characteristic in service.characteristics) {
            if (characteristic.properties.write ||
                characteristic.properties.writeWithoutResponse) {
              writeCharacteristic = characteristic;
              break;
            }
          }
        }
      }

      if (writeCharacteristic == null) {
        // If FF00 not found, try finding any write characteristic
        for (var service in services) {
          for (var characteristic in service.characteristics) {
            if (characteristic.properties.write ||
                characteristic.properties.writeWithoutResponse) {
              writeCharacteristic = characteristic;
              break;
            }
          }
          if (writeCharacteristic != null) break;
        }
      }

      if (writeCharacteristic == null) {
        throw Exception('Printer service not found');
      }

      // Optimized printer initialization with minimal commands
      final initCommands = Uint8List.fromList([
        0x1B, 0x40,  // Reset printer
        0x1B, 0x74, 0x00  // Set character code table
      ]);
      
      await writeCharacteristic.write(initCommands, withoutResponse: true);

      // Generate receipt data
      final bytes = await generateDirectReceiptData(items);
      // Fixed chunk size for printer compatibility
      const int chunkSize = 200; // Fixed size for printer capability
      int finalChunkSize = chunkSize;
      try {
        // Validate chunk size
        if (bytes.length < chunkSize) {
          finalChunkSize = bytes.length;
        }
      } catch (e) {
        print('Using default chunk size: $chunkSize');
      }

      // Send data in optimized chunks with parallel processing
      final int numChunks = (bytes.length / chunkSize).ceil();
      List<Future<void>> writeFutures = [];
      
      for (int i = 0; i < numChunks; i++) {
        int start = i * chunkSize;
        int end = (start + chunkSize < bytes.length) ? start + chunkSize : bytes.length;
        writeFutures.add(writeCharacteristic.write(bytes.sublist(start, end), withoutResponse: true));
        
        // Process in batches of 5 to avoid overwhelming the printer
        if (writeFutures.length >= 5 || i == numChunks - 1) {
          await Future.wait(writeFutures);
          writeFutures.clear();
        }
      }

      print("total bytes size is $numChunks");

      // Send final commands in a single batch
      final finalCommands = Uint8List.fromList([
        0x1B, 0x64, 0x00,  // Feed paper
        0x1B, 0x40,  // Initialize printer
      ]);
      await writeCharacteristic.write(finalCommands, withoutResponse: true);

      Get.snackbar("Printed", "Successfully");
    } catch (e) {
      Get.snackbar("Not Printed", "Unsuccessful: $e");
      print('Print error: $e');
    }
  }

  Future<List<int>> generateDirectReceiptData(
      List<Map<String, dynamic>> items) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];

    // Initialize printer with optimized settings
    bytes += generator.reset();
    bytes += generator.setGlobalCodeTable('CP437');
    bytes += generator.setGlobalFont(PosFontType.fontA);

    // Load and add the logo image with optimized processing
    try {
      final ByteData imageData = await rootBundle.load('assets/ganpati.png');
      final Uint8List logoBytes = imageData.buffer.asUint8List();
      final img.Image logoImage = img.decodeImage(logoBytes)!;
      // Aggressive optimization for logo
      final img.Image optimizedLogo = img.copyResize(
        logoImage,
        height: 60,  // Further reduced height
        width: 60,   // Further reduced width
        interpolation: img.Interpolation.nearest  // Fastest interpolation
      );
      // Optimize image for thermal printing
      var processedLogo = img.grayscale(optimizedLogo);
      // Removed commented out processing: processedLogo = img.brightness(processedLogo, 20);
      // Removed commented out processing: processedLogo = img.contrast(processedLogo, 150);
      bytes += generator.imageRaster(processedLogo, align: PosAlign.center);
    } catch (e) {
      print('Error loading logo: $e');
    }

    // Optimize header text formatting by combining text
    final headerStyle = PosStyles(align: PosAlign.center, fontType: PosFontType.fontA);
    final headerBoldStyle = PosStyles(align: PosAlign.center, bold: true, fontType: PosFontType.fontA);
    
    bytes += generator.text('Shri Ganesh Farsan'.toUpperCase(), styles: headerBoldStyle);
    bytes += generator.text('Shop No:- 95/96,Balaji Nagar\n90 Feet Road,Dharavi, Mumbai-400017\nMobile No: 9324755451', styles: headerStyle);
    bytes += generator.feed(1);

    // Format date and time
    final now = DateTime.now();
    final formattedDate =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
    final formattedTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

    bytes += generator.text(
      'Date: $formattedDate',
      styles: PosStyles(align: PosAlign.right, fontType: PosFontType.fontA),
    );
    bytes += generator.text(
      'Time: $formattedTime',
      styles: PosStyles(align: PosAlign.right, fontType: PosFontType.fontA),
    );
    bytes += generator.hr();

    // Add headers with proper alignment
    bytes += generator.row([
      PosColumn(
          text: 'Sr',
          width: 2,
          styles: PosStyles(
              bold: true, align: PosAlign.left, fontType: PosFontType.fontA)),
      PosColumn(
          text: 'Particulars',
          width: 4,
          styles: PosStyles(
              bold: true, align: PosAlign.left, fontType: PosFontType.fontA)),
      PosColumn(
          text: 'Qty',
          width: 2,
          styles: PosStyles(
              bold: true, align: PosAlign.center, fontType: PosFontType.fontA)),
      PosColumn(
          text: 'Rate',
          width: 2,
          styles: PosStyles(
              bold: true, align: PosAlign.left, fontType: PosFontType.fontA)),
      PosColumn(
          text: 'Amt',
          width: 2,
          styles: PosStyles(
              bold: true, align: PosAlign.center, fontType: PosFontType.fontA)),
    ]);
    bytes += generator.hr();

    // Calculate total
    final total = items.fold<int>(0, (sum, item) {
      final quantity = int.tryParse(item['quantity'].toString()) ?? 0;
      final rate = int.tryParse(item['rate'].toString()) ?? 0;
      return sum + (quantity * rate);
    });

    // Process items - Refactored for performance
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      try {
        final quantity = int.tryParse(item['quantity'].toString()) ?? 0;
        final rate = int.tryParse(item['rate'].toString()) ?? 0;
        final amount = quantity * rate;
        final srNo = "${(i + 1).toString()}.";

        if (item['particulars'] != null && item['particulars'] is Uint8List) {
          final Uint8List particularBytes = item['particulars'];
          final img.Image? decodedParticulars = img.decodeImage(particularBytes);

          if (decodedParticulars != null) {
            // --- Start: Optimized Handwritten Image Processing ---
            // Resize based on target height for consistency, maintain aspect ratio
            const int targetHeight = 50; // Adjust as needed for clarity vs size
            final double aspectRatio = decodedParticulars.width / decodedParticulars.height;
            final int targetWidth = (targetHeight * aspectRatio).round();

            final optimizedImage = img.copyResize(
              decodedParticulars,
              width: targetWidth,
              height: targetHeight,
              interpolation: img.Interpolation.average // Average might give better results for handwriting
            );

            var processedImage = img.grayscale(optimizedImage);
            // processedImage = img.contrast(processedImage, 150); // Optional: Test contrast if needed
            // --- End: Optimized Handwritten Image Processing ---

            // Print Sr.No, Qty, Rate, Amt first (leaving space for image)
            bytes += generator.row([
              PosColumn(
                  text: srNo,
                  width: 2,
                  styles: PosStyles(align: PosAlign.left, fontType: PosFontType.fontA)),
              PosColumn(
                  text: '', // Placeholder for image
                  width: 4,
                  styles: PosStyles(align: PosAlign.left, fontType: PosFontType.fontA)),
              PosColumn(
                  text: quantity.toString(),
                  width: 2,
                  styles: PosStyles(align: PosAlign.center, fontType: PosFontType.fontA)),
              PosColumn(
                  text: rate.toString(),
                  width: 2,
                  styles: PosStyles(align: PosAlign.left, fontType: PosFontType.fontA)), // Keep left align like header
              PosColumn(
                  text: amount.toString(),
                  width: 2,
                  styles: PosStyles(align: PosAlign.center, fontType: PosFontType.fontA)),
            ]);

            // Print the processed image below the Sr.No, aligned left within the 'Particulars' column space
            // Add slight indentation if needed
            bytes += generator.imageRaster(processedImage, align: PosAlign.left);
            // bytes += generator.feed(1); // Remove this line feed to keep image on the same conceptual line

          } else {
            // Handle case where image decoding fails but data is Uint8List
            bytes += generator.row([
              PosColumn(text: srNo, width: 2, styles: PosStyles(align: PosAlign.left, fontType: PosFontType.fontA)),
              PosColumn(text: '(Image Error)', width: 4, styles: PosStyles(align: PosAlign.left, fontType: PosFontType.fontA)),
              PosColumn(text: quantity.toString(), width: 2, styles: PosStyles(align: PosAlign.center, fontType: PosFontType.fontA)),
              PosColumn(text: rate.toString(), width: 2, styles: PosStyles(align: PosAlign.left, fontType: PosFontType.fontA)),
              PosColumn(text: amount.toString(), width: 2, styles: PosStyles(align: PosAlign.center, fontType: PosFontType.fontA)),
            ]);
          }
        } else {
          // Handle case where 'particulars' is text or null
          bytes += generator.row([
            PosColumn(text: srNo, width: 2, styles: PosStyles(align: PosAlign.left, fontType: PosFontType.fontA)),
            PosColumn(text: item['particulars']?.toString() ?? '', width: 4, styles: PosStyles(align: PosAlign.left, fontType: PosFontType.fontA)),
            PosColumn(text: quantity.toString(), width: 2, styles: PosStyles(align: PosAlign.center, fontType: PosFontType.fontA)),
            PosColumn(text: rate.toString(), width: 2, styles: PosStyles(align: PosAlign.left, fontType: PosFontType.fontA)),
            PosColumn(text: amount.toString(), width: 2, styles: PosStyles(align: PosAlign.center, fontType: PosFontType.fontA)),
          ]);
        }
        bytes += generator.hr(ch: '-', linesAfter: 0); // Separator after each item
      } catch (e) {
        print('Error processing item row: $e');
        // Optionally add a placeholder row in case of error
        bytes += generator.text('Error processing item ${i + 1}', styles: PosStyles(align: PosAlign.left));
        continue;
      }
    }

    // Add total with proper right alignment
    bytes += generator.row([
      PosColumn(text: '', width: 7),
      PosColumn(
          text: 'TOTAL',
          width: 2,
          styles: PosStyles(
            align: PosAlign.right,
            bold: true,
            fontType: PosFontType.fontA,
          )),
      PosColumn(
        text: total.toString(),
        width: 3,
        styles: PosStyles(
          align: PosAlign.center,
          bold: true,
          fontType: PosFontType.fontA,
        ),
      ),
    ]);

    bytes += generator.hr();
    bytes += generator.text('Thank you for your business!',
        styles: PosStyles(align: PosAlign.center, fontType: PosFontType.fontA));
    bytes += generator.text('Please visit again',
        styles: PosStyles(align: PosAlign.center, fontType: PosFontType.fontA));
    bytes += generator.feed(2);
    bytes += generator.cut();

    return bytes;
  }
}

/* // Removed large commented out block
Future<List<int>> _generatePrintData(List<Map<String, dynamic>> data) async {
  final profile = await CapabilityProfile.load();
  final generator = Generator(PaperSize.mm80, profile);
  List<int> bytes = [];

  // final ByteData imageData = await rootBundle.load('assets/sai.png');
  // final Uint8List bytesss = imageData.buffer.asUint8List();
  // final img.Image image = img.decodeImage(bytesss)!;
  // final img.Image resizedSaiImage =
  //     img.copyResize(image, height: 150, width: 150);
  //
  // bytes += generator.image(resizedSaiImage, align: PosAlign.center);

  // bytes += generator.hr();

  bytes += generator.text('Date: ${DateTime.now().toString().split(' ')[0]}',
      styles: PosStyles(align: PosAlign.right));
  bytes += generator.hr();

  bytes += generator.row([
    PosColumn(
        text: '#',
        width: 1,
        styles: PosStyles(bold: true, align: PosAlign.center)),
    PosColumn(text: 'Particulars', width: 5, styles: PosStyles(bold: true)),
    PosColumn(
        text: 'Qty',
        width: 2,
        styles: PosStyles(bold: true, align: PosAlign.center)),
    PosColumn(
        text: 'Rate',
        width: 2,
        styles: PosStyles(bold: true, align: PosAlign.center)),
    PosColumn(
        text: 'Amt',
        width: 2,
        styles: PosStyles(bold: true, align: PosAlign.center)),
  ]);
  bytes += generator.hr();

  double total = 0;
  for (int i = 0; i < data.length; i++) {
    var item = data[i];
    int qty = int.tryParse(item['quantity']?.toString() ?? '0') ?? 0;
    double rate = double.tryParse(item['rate']?.toString() ?? '0') ?? 0;
    double amount = qty * rate;
    total += amount;

    if (item['particulars'] is Uint8List) {
      try {
        final imageBytes = item['particulars'];
        final img.Image originalImage = img.decodeImage(imageBytes)!;

        final img.Image resizedImage =
        img.copyResize(originalImage, height: 50);

        bytes += generator.row([
          PosColumn(
              text: '${i + 1}',
              width: 1,
              styles: PosStyles(align: PosAlign.center)),
          PosColumn(width: 5, text: ''),
          PosColumn(
              text: '$qty',
              width: 2,
              styles: PosStyles(align: PosAlign.center)),
          PosColumn(
              text: '$rate',
              width: 2,
              styles: PosStyles(align: PosAlign.center)),
          PosColumn(
              text: '${amount.toStringAsFixed(2)}',
              width: 2,
              styles: PosStyles(align: PosAlign.center)),
        ]);

        // bytes += generator.image(resizedImage, align: PosAlign.left);
      } catch (e) {
        print('Error processing image: $e');
        bytes += generator.row([
          PosColumn(
              text: '${i + 1}',
              width: 1,
              styles: PosStyles(align: PosAlign.center)),
          PosColumn(
              text: '(Image failed)',
              width: 5,
              styles: PosStyles(align: PosAlign.left)),
          PosColumn(
              text: '$qty',
              width: 2,
              styles: PosStyles(align: PosAlign.center)),
          PosColumn(
              text: '$rate',
              width: 2,
              styles: PosStyles(align: PosAlign.center)),
          PosColumn(
              text: '${amount.toStringAsFixed(2)}',
              width: 2,
              styles: PosStyles(align: PosAlign.center)),
        ]);
      }
    } else {
      bytes += generator.row([
        PosColumn(
            text: '${i + 1}',
            width: 1,
            styles: PosStyles(align: PosAlign.center)),
        PosColumn(text: '${item['particulars'] ?? ''}', width: 5),
        PosColumn(
            text: '$qty',
            width: 2,
            styles: PosStyles(align: PosAlign.center)),
        PosColumn(
            text: '$rate',
            width: 2,
            styles: PosStyles(align: PosAlign.center)),
        PosColumn(
            text: '${amount.toStringAsFixed(2)}',
            width: 2,
            styles: PosStyles(align: PosAlign.center)),
      ]);
    }
  }

  bytes += generator.hr();
  bytes += generator.row([
    PosColumn(text: 'TOTAL', width: 6, styles: PosStyles(bold: true)),
    PosColumn(text: '', width: 2),
    PosColumn(text: '', width: 2),
    PosColumn(
        text: '${total.toStringAsFixed(2)}',
        width: 2,
        styles: PosStyles(align: PosAlign.right, bold: true)),
  ]);
  bytes += generator.hr();

  bytes += generator.text('Thank you for your business!',
      styles: PosStyles(align: PosAlign.center));
  bytes += generator.text('Please visit again',
      styles: PosStyles(align: PosAlign.center));
  bytes += generator.feed(2);
  bytes += generator.cut();

  return bytes;
}*/

Future<ui.Image> createCompleteRowImage(String srNo, ui.Image handwrittenImage,
    String qty, String rate, String amt) async {
  final recorder = ui.PictureRecorder();
  final width = 580;
  final height = 85;
  final canvas = Canvas(
      recorder, Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()));

  // Set white background
  final Paint bgPaint = Paint()..color = Colors.white;
  canvas.drawRect(
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()), bgPaint);

  // Define column widths
  final srNoWidth = width * 0.08;
  final particularsWidth = width * 0.52;
  final otherColumnWidth = (width - srNoWidth - particularsWidth) / 3;

  // Draw Sr.No
  final textStyle = TextStyle(
    color: Colors.black,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  final textPainter = TextPainter(
    textDirection: TextDirection.ltr,
    textAlign: TextAlign.center,
  );

  textPainter.text = TextSpan(text: srNo, style: textStyle);
  textPainter.layout();
  textPainter.paint(
    canvas,
    Offset(
      (srNoWidth - textPainter.width) / 2,
      (height - textPainter.height) / 2,
    ),
  );

  // Draw Particulars (handwritten)
  canvas.drawImage(handwrittenImage, Offset(srNoWidth, 0), Paint());

  // Draw Quantity
  textPainter.text = TextSpan(text: qty, style: textStyle);
  textPainter.layout();
  textPainter.paint(
    canvas,
    Offset(
      srNoWidth + particularsWidth + (otherColumnWidth - textPainter.width) / 2,
      (height - textPainter.height) / 2,
    ),
  );

  // Draw Rate
  textPainter.text = TextSpan(text: rate, style: textStyle);
  textPainter.layout();
  textPainter.paint(
    canvas,
    Offset(
      srNoWidth +
          particularsWidth +
          otherColumnWidth +
          (otherColumnWidth - textPainter.width) / 2,
      (height - textPainter.height) / 2,
    ),
  );

  // Draw Amount
  textPainter.text = TextSpan(text: amt, style: textStyle);
  textPainter.layout();
  textPainter.paint(
    canvas,
    Offset(
      srNoWidth +
          particularsWidth +
          2 * otherColumnWidth +
          (otherColumnWidth - textPainter.width) / 2,
      (height - textPainter.height) / 2,
    ),
  );

  // Convert to image
  final ui.Image image =
      await recorder.endRecording().toImage(width.toInt(), height.toInt());
  return image;
}
