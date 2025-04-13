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

      if (writeCharacteristic == null) {
        throw Exception('Printer service not found');
      }

      // Generate receipt data directly
      final bytes = await generateDirectReceiptData(items);

      // Use cached MTU size if available, or default to a safe value
      int chunkSize = 180;
      try {
        final negotiatedMtu = await device.mtu.first;
        chunkSize = (negotiatedMtu - 3).clamp(20, 180);
      } catch (e) {
        print('Using default chunk size: $e');
      }

      // Send data in chunks with minimal delay
      for (int i = 0; i < bytes.length; i += chunkSize) {
        int end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
        await writeCharacteristic.write(bytes.sublist(i, end),
            withoutResponse: true);
        await Future.delayed(const Duration(milliseconds: 10));
      }

      print('Print completed successfully');
    } catch (e) {
      throw Exception('Failed to print: $e');
    }
  }

  Future<List<int>> generateDirectReceiptData(
      List<Map<String, dynamic>> items) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];

    // Load and add the logo image
    try {
      final ByteData imageData = await rootBundle.load('assets/sai.png');
      final Uint8List logoBytes = imageData.buffer.asUint8List();
      final img.Image logoImage = img.decodeImage(logoBytes)!;
      final img.Image resizedLogo =
          img.copyResize(logoImage, height: 100, width: 100);
      bytes += generator.image(resizedLogo, align: PosAlign.center);
    } catch (e) {
      print('Error loading logo: $e');
    }

    // Add receipt header
    bytes += generator.text(
      'Sri Sai Ram Farsan & Sweets'.toUpperCase(),
      styles: PosStyles(
          align: PosAlign.center, bold: true, height: PosTextSize.size2),
    );

    bytes += generator.emptyLines(1);

    bytes += generator.text(
      'Shop No.5 Balaji Nagar, Near Kamraj School,',
      styles: PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      '90 Feet Road, Dharavi, Mumbai - 40017',
      styles: PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      'Mobile No: 9892814985 ',
      styles: PosStyles(align: PosAlign.center),
    );

    bytes += generator.emptyLines(1);

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

    // Process each item
    for (var i = 0; i < items.length; i++) {
      try {
        if (items[i]['particulars'] != null &&
            items[i]['particulars'] is Uint8List) {
          final quantity = int.tryParse(items[i]['quantity'].toString()) ?? 0;
          final rate = int.tryParse(items[i]['rate'].toString()) ?? 0;
          final amount = quantity * rate;

          // Get the handwritten image
          final Uint8List handwrittenBytes = items[i]['particulars'];
          final img.Image? decodedImage = img.decodeImage(handwrittenBytes);

          if (decodedImage != null) {
            // Convert to grayscale
            final img.Image processedImage =
                img.grayscale(decodedImage) as img.Image;

            // Resize image to fit receipt width while maintaining aspect ratio
            final int targetWidth = 310;
            final int targetHeight =
                (targetWidth * processedImage.height / processedImage.width)
                    .round();
            final img.Image resizedImage = img.copyResize(
              processedImage,
              width: targetWidth,
              height: targetHeight,
            ) as img.Image;

            // Create a new blank image with minimal height and proper width for Particulars column
            final img.Image finalImage = img.Image.rgb(
              targetWidth,
              resizedImage.height,
            );

            // Make background transparent/white
            for (int y = 0; y < finalImage.height; y++) {
              for (int x = 0; x < finalImage.width; x++) {
                finalImage.setPixel(x, y, 0xFFFFFFFF);
              }
            }

            // Calculate the offset for Particulars column (width of Sr.No column)
            final int srNoColumnWidth =
                (targetWidth * 0.20).round(); // Increased padding to 20%

            // Copy the handwriting with proper thresholding, adding left padding
            for (int y = 0; y < resizedImage.height; y++) {
              for (int x = 0; x < resizedImage.width; x++) {
                if (x + srNoColumnWidth < finalImage.width) {
                  final pixel = resizedImage.getPixel(x, y);
                  final brightness = img.getLuminance(pixel);
                  if (brightness < 128) {
                    // Dark pixels become black, with offset
                    finalImage.setPixel(x + srNoColumnWidth, y, 0xFF000000);
                  }
                }
              }
            }

            // Print the combined row with image and text
            bytes += generator.row([
              PosColumn(
                text: '${i + 1}',
                width: 2,
                styles: PosStyles(align: PosAlign.left),
              ),
              PosColumn(
                width: 4,
                text: '',
                styles: PosStyles(align: PosAlign.left),
              ),
              PosColumn(
                  text: quantity.toString(),
                  width: 2,
                  styles: PosStyles(align: PosAlign.right)),
              PosColumn(
                  text: rate.toString(),
                  width: 2,
                  styles: PosStyles(align: PosAlign.right)),
              PosColumn(
                  text: amount.toString(),
                  width: 2,
                  styles: PosStyles(align: PosAlign.right)),
            ]);

            // Print the image with negative spacing
            bytes += generator.feed(-5);
            bytes += generator.imageRaster(finalImage, align: PosAlign.left);

            // Add separator line with negative spacing
            bytes += generator.feed(-5);
            bytes += generator.hr(ch: '-', linesAfter: 0);
          }
        }
      } catch (e) {
        print('Error processing item image: $e');
        continue;
      }
    }

    // Add total with minimal spacing
    final total = items.fold<int>(0, (sum, item) {
      final quantity = int.tryParse(item['quantity'].toString()) ?? 0;
      final rate = int.tryParse(item['rate'].toString()) ?? 0;
      return sum + (quantity * rate);
    });

    bytes += generator.row([
      PosColumn(text: '', width: 2),
      PosColumn(text: '', width: 2),
      PosColumn(text: '', width: 4),
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

    // Add receipt footer with reduced spacing
    bytes += generator.hr();
    bytes += generator.text('Thank you for your business!',
        styles: PosStyles(align: PosAlign.center));
    bytes += generator.text('Please visit again',
        styles: PosStyles(align: PosAlign.center));
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
