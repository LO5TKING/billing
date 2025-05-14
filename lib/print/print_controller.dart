import 'dart:ui' as ui;

import 'package:billing/app/config/constants_text.dart';
import 'package:billing/utils/constants.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:typed_data';
import 'dart:async';
import 'package:image/image.dart' as img;
import 'package:image/image.dart' show dilate;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/material.dart' hide Image;
import 'dart:math' as math;

import 'package:shared_preferences/shared_preferences.dart';
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

      // Initialize printer
      final initCommands = [
        // Reset printer
        Uint8List.fromList([0x1B, 0x40]),
        // Set line spacing to 0
        Uint8List.fromList([0x1B, 0x33, 0x00]),
        // Set character code table
        Uint8List.fromList([0x1B, 0x74, 0x00]),
        // Set justification to left
        Uint8List.fromList([0x1B, 0x61, 0x00]),
        // Set character size to normal
        Uint8List.fromList([0x1D, 0x21, 0x00]),
      ];

      for (var cmd in initCommands) {
        await writeCharacteristic.write(cmd, withoutResponse: true);
        await Future.delayed(const Duration(milliseconds: 50));
      }

      // Generate receipt data
      final bytes = await generateDirectReceiptData(items);

      // Use even larger chunk size for faster transfer
      int chunkSize = 200; // Increased from 100 to 200
      try {
        final negotiatedMtu = await device.mtu.first;
        chunkSize = (negotiatedMtu - 3)
            .clamp(200, 400); // Increased minimum and maximum
      } catch (e) {
        print('Using default chunk size: $chunkSize');
      }

      // Send data in chunks with minimal delay
      for (int i = 0; i < bytes.length; i += chunkSize) {
        int end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
        await writeCharacteristic.write(bytes.sublist(i, end),
            withoutResponse: true);
        await Future.delayed(const Duration(milliseconds: 10));
      }

      // Final commands with proper sequencing
      final finalCommands = [
        // Feed paper
        Uint8List.fromList([0x1B, 0x64, 0x00]), // Feed 3 lines
        // Ensure all data is printed
        Uint8List.fromList([0x1B, 0x40]), // Initialize printer
        // Cut paper
        // Uint8List.fromList([0x1B, 0x69]), // Full cut
      ];

      // Send final commands with proper delays
      for (var cmd in finalCommands) {
        await writeCharacteristic.write(cmd, withoutResponse: true);
        await Future.delayed(const Duration(
            milliseconds: 100)); // Increased delay for final commands
      }

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

    // Load and add the logo image with minimal top spacing
    try {
      final ByteData imageData = await rootBundle.load('assets/ganpati.png');
      final Uint8List logoBytes = imageData.buffer.asUint8List();
      final img.Image logoImage = img.decodeImage(logoBytes)!;
      final img.Image resizedLogo =
          img.copyResize(logoImage, height: 100, width: 100);
      bytes += generator.image(resizedLogo, align: PosAlign.center);
    } catch (e) {
      print('Error loading logo: $e');
    }

    // Add receipt header with minimal spacing
    bytes += generator.text(
      ConstantsText.shopName.toUpperCase(),
      styles: PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size1,
          fontType: PosFontType.fontA),
    );

    bytes += generator.text(
      '${ConstantsText.address}\n${ConstantsText.mobileNo}',
      styles: PosStyles(align: PosAlign.center, fontType: PosFontType.fontA),
    );
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
    final total = items.fold<double>(0, (sum, item) {
      final quantity = double.tryParse(item['quantity'].toString()) ?? 0;
      final rate = double.tryParse(item['rate'].toString()) ?? 0;
      return sum + (quantity * rate);
    });

    // Process items in optimized batches
    final int batchSize = 5;
    for (var i = 0; i < items.length; i += batchSize) {
      final end = (i + batchSize < items.length) ? i + batchSize : items.length;
      final batch = items.sublist(i, end);

      for (var item in batch) {
        try {
          if (item['particulars'] != null && item['particulars'] is Uint8List) {
            final quantity = double.tryParse(item['quantity'].toString()) ?? 0;
            final rate = double.tryParse(item['rate'].toString()) ?? 0;
            final amount = quantity * rate;

            // Create a canvas for the complete row
            final recorder = ui.PictureRecorder();
            final width = 580;
            final height = 85;
            final canvas = Canvas(recorder,
                Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()));

            // Set white background
            final Paint bgPaint = Paint()..color = Colors.white;
            canvas.drawRect(
                Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
                bgPaint);

            // Define column widths and positions
            final srNoWidth =
                width * 0.10; // Slightly reduced for better alignment
            final particularsWidth =
                width * 0.40; // Increased for larger handwriting
            final qtyWidth = width * 0.15;
            final rateWidth = width * 0.15;
            final amtWidth = width * 0.20;

            // Calculate column start positions
            final qtyStartX = srNoWidth + particularsWidth;
            final rateStartX = qtyStartX + qtyWidth;
            final amtStartX = rateStartX + rateWidth;

            // Draw Sr.No with proper formatting
            final textStyle = TextStyle(
              color: Colors.black,
              fontSize: 24, // Increased font size
              fontWeight: FontWeight.bold,
            );
            final textPainter = TextPainter(
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.right, // Changed to center
            );

            // Format Sr.No to ensure single digit
            final srNo = "${(items.indexOf(item) + 1).toString()}.";
            textPainter.text = TextSpan(
              text: srNo,
              style: textStyle,
            );
            textPainter.layout();
            textPainter.paint(
              canvas,
              Offset(
                (srNoWidth - textPainter.width) / 2, // Center align Sr.No
                (height - textPainter.height) / 2,
              ),
            );

            // Draw handwritten particulars with increased size
            final Uint8List particularBytes = item['particulars'];
            final img.Image? decodedParticulars =
                img.decodeImage(particularBytes);
            if (decodedParticulars != null) {
              // Increase size more significantly
              final dilatedImage = img.copyResize(
                decodedParticulars,
                width: (decodedParticulars.width * 2.4)
                    .toInt(), // Increased from 1.8 to 2.2
                height: (decodedParticulars.height * 2.8)
                    .toInt(), // Increased from 1.6 to 2.0
              );

              // Enhanced contrast and darkness
              var darkenedImage = img.brightness(dilatedImage, -65) ??
                  dilatedImage; // Slightly increased darkness
              darkenedImage = img.contrast(darkenedImage, 170) ??
                  darkenedImage; // Increased contrast

              final scaleWidth = particularsWidth / darkenedImage.width;
              final scaleHeight = height / darkenedImage.height;
              final scale = math.min(scaleWidth, scaleHeight) *
                  1.8; // Increased from 1.2 to 1.5

              final scaledWidth = darkenedImage.width * scale;
              final scaledHeight = darkenedImage.height * scale;

              // Adjust the x-offset to add left padding (align with Particulars header)
              final xOffset = srNoWidth +
                  0; // Reduced from 30 to 15 for more left alignment

              // Center vertically but with slight upward adjustment
              final yOffset =
                  (height - scaledHeight) / 2 - 5; // Slight upward adjustment

              final resizedParticulars = img.copyResize(
                darkenedImage,
                width: scaledWidth.toInt(),
                height: scaledHeight.toInt(),
              );

              final particularsPngBytes = img.encodePng(resizedParticulars);
              final codec = await ui.instantiateImageCodec(
                  Uint8List.fromList(particularsPngBytes));
              final frame = await codec.getNextFrame();

              // Draw with adjusted position
              canvas.drawImage(frame.image, Offset(xOffset, yOffset), Paint());
            }

            // Draw numbers with optimized text painting and center alignment
            final centerY = (height - textPainter.height) / 2;

            // Draw quantity, rate, and amount (all center-aligned)
            textPainter.text =
                TextSpan(text: quantity.toString(), style: textStyle);
            textPainter.layout();
            textPainter.paint(
                canvas,
                Offset(
                    qtyStartX + (qtyWidth - textPainter.width) / 2, centerY));

            textPainter.text =
                TextSpan(text: rate.toString(), style: textStyle);
            textPainter.layout();
            textPainter.paint(
                canvas,
                Offset(
                    rateStartX + (rateWidth - textPainter.width) / 2, centerY));

            textPainter.text =
                TextSpan(text: amount.toString(), style: textStyle);
            textPainter.layout();
            textPainter.paint(
                canvas,
                Offset(
                    amtStartX + (amtWidth - textPainter.width) / 2, centerY));

            // Convert to image
            final ui.Image rowImage = await recorder
                .endRecording()
                .toImage(width.toInt(), height.toInt());
            final ByteData? rowImageData =
                await rowImage.toByteData(format: ui.ImageByteFormat.png);

            if (rowImageData != null) {
              final img.Image? decodedRowImage =
                  img.decodeImage(rowImageData.buffer.asUint8List());
              if (decodedRowImage != null) {
                final printImage = img.copyResize(
                  decodedRowImage,
                  width: decodedRowImage.width,
                  height: decodedRowImage.height,
                );
                bytes += generator.imageRaster(printImage,
                    align: PosAlign.center); // Changed to center alignment
                bytes += generator.hr(ch: '-', linesAfter: 0);
              }
            }
          }
        } catch (e) {
          print('Error processing row image: $e');
          continue;
        }
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
    bytes += generator.feed(1);
    bytes += generator.cut();

    return bytes;
  }
}

/*
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
