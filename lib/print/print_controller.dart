import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:typed_data';
import 'dart:async';
import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

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
        Uint8List.fromList([0x1B, 0x64, 0x03]), // Feed 3 lines
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

    // Initialize printer with consistent settings
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

    // Add receipt header with consistent spacing
    bytes += generator.text(
      'Shri Ganesh Farsan'.toUpperCase(),
      styles: PosStyles(
          align: PosAlign.center, bold: true, height: PosTextSize.size1),
    );
    bytes += generator.feed(1);

    bytes += generator.text(
      '95/96, Floor-0,Balaji Nagar kk krishnana Menan Marg',
      styles: PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      '90 Feet Road,Dharavi, Mumbai-400017',
      styles: PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      'Mobile No: 9324755451',
      styles: PosStyles(align: PosAlign.center),
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
      styles: PosStyles(align: PosAlign.right),
    );
    bytes += generator.text(
      'Time: $formattedTime',
      styles: PosStyles(align: PosAlign.right),
    );
    bytes += generator.hr();

    // Add headers with proper alignment
    bytes += generator.row([
      PosColumn(
          text: 'Sr.No',
          width: 2,
          styles: PosStyles(bold: true, align: PosAlign.left)),
      PosColumn(
          text: 'Particulars',
          width: 4,
          styles: PosStyles(bold: true, align: PosAlign.left)),
      PosColumn(
          text: 'Qty',
          width: 2,
          styles: PosStyles(bold: true, align: PosAlign.right)),
      PosColumn(
          text: 'Rate',
          width: 2,
          styles: PosStyles(bold: true, align: PosAlign.right)),
      PosColumn(
          text: 'Amt',
          width: 2,
          styles: PosStyles(bold: true, align: PosAlign.right)),
    ]);
    bytes += generator.hr();

    // Calculate total
    final total = items.fold<int>(0, (sum, item) {
      final quantity = int.tryParse(item['quantity'].toString()) ?? 0;
      final rate = int.tryParse(item['rate'].toString()) ?? 0;
      return sum + (quantity * rate);
    });

    // Process items in batches for better performance
    final int batchSize = 3; // Process 3 items at a time
    for (var i = 0; i < items.length; i += batchSize) {
      final end = (i + batchSize < items.length) ? i + batchSize : items.length;
      final batch = items.sublist(i, end);

      for (var item in batch) {
        try {
          if (item['particulars'] != null && item['particulars'] is Uint8List) {
            final quantity = int.tryParse(item['quantity'].toString()) ?? 0;
            final rate = int.tryParse(item['rate'].toString()) ?? 0;
            final amount = quantity * rate;

            // Get the handwritten image
            final Uint8List handwrittenBytes = item['particulars'];
            final img.Image? decodedImage = img.decodeImage(handwrittenBytes);

            if (decodedImage != null) {
              // Optimized image processing with reduced size
              final int targetWidth =
                  320; // Increased from 280 for larger handwriting
              final int targetHeight =
                  ((targetWidth * decodedImage.height) / decodedImage.width)
                      .round();

              // Single resize operation with optimized parameters
              final img.Image resizedImage = img.copyResize(
                decodedImage,
                width: targetWidth,
                height: targetHeight,
                interpolation: img.Interpolation.linear, // Faster interpolation
              );

              // Create padded image with optimized dimensions
              final img.Image paddedImage = img.Image.rgb(
                targetWidth + (targetWidth * 0.3).round(),
                targetHeight,
              );

              // Make background white in a single operation
              paddedImage.fill(0xFFFFFFFF);

              // Optimized pixel copying with padding
              final int paddingOffset = (targetWidth * 0.3).round();
              final int maxY = resizedImage.height;
              final int maxX = resizedImage.width;

              // Use row-based copying for better performance
              for (int y = 0; y < maxY; y++) {
                final int yOffset = y * paddedImage.width;
                final int srcYOffset = y * resizedImage.width;
                for (int x = 0; x < maxX; x++) {
                  paddedImage.data[yOffset + x + paddingOffset] =
                      resizedImage.data[srcYOffset + x];
                }
              }

              // Print the combined row with image and text
              bytes += generator.row([
                PosColumn(
                  text: '${items.indexOf(item) + 1}',
                  width: 2,
                  styles: PosStyles(align: PosAlign.left, bold: true),
                ),
                PosColumn(
                  width: 4,
                  text: '',
                  styles: PosStyles(align: PosAlign.left),
                ),
                PosColumn(
                    text: quantity.toString(),
                    width: 2,
                    styles: PosStyles(align: PosAlign.right, bold: true)),
                PosColumn(
                    text: rate.toString(),
                    width: 2,
                    styles: PosStyles(align: PosAlign.right, bold: true)),
                PosColumn(
                    text: amount.toString(),
                    width: 2,
                    styles: PosStyles(align: PosAlign.right, bold: true)),
              ]);

              // Print the image with optimized spacing
              bytes += generator.imageRaster(paddedImage, align: PosAlign.left);
              bytes += generator.hr(ch: '-', linesAfter: 0);
            }
          }
        } catch (e) {
          print('Error processing item image: $e');
          continue;
        }
      }
    }

    bytes += generator.row([
      PosColumn(text: '', width: 8),
      PosColumn(
          text: 'TOTAL',
          width: 2,
          styles: PosStyles(align: PosAlign.right, bold: true)),
      PosColumn(
        text: total.toString(),
        width: 2,
        styles: PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);

    bytes += generator.hr();
    bytes += generator.text('Thank you for your business!',
        styles: PosStyles(align: PosAlign.center));
    bytes += generator.text('Please visit again',
        styles: PosStyles(align: PosAlign.center));
    // bytes += generator.feed(1);
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
