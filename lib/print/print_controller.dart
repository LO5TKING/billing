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

class PrintController extends GetxController {
  RxList<ScanResult> devices = <ScanResult>[].obs;
  RxString devicesMsg = "".obs;
  RxBool isScanning = false.obs;
  RxBool isConnected = false.obs;
  StreamSubscription? _scanSubscription;
  BluetoothDevice? _connectedDevice;
  Rx<String?> savedPrinterId = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadSavedPrinter();
    initBluetooth();
  }

  Future<void> _loadSavedPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    savedPrinterId.value = prefs.getString('saved_printer_id');
  }

  Future<void> saveSelectedPrinter(BluetoothDevice? device) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deviceId = device?.id.toString();
      await prefs.setString('saved_printer_id', deviceId ?? "");
      savedPrinterId.value = deviceId;
      print('Printer saved successfully: ${device?.name} ($deviceId)');
    } catch (e) {
      print('Error saving printer: $e');
      // Don't throw - this is not critical
    }
  }

  Future<void> clearSavedPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_printer_id');
    savedPrinterId.value = null;
  }

  Future<void> initBluetooth() async {
    try {
      // First try to check if Bluetooth is on without turning it on
      // This avoids making network calls that require internet
      if (!await FlutterBluePlus.isSupported) {
        devicesMsg("Bluetooth is not supported on this device");
        return;
      }

      // Check if Bluetooth is enabled instead of forcing it on
      final isOn = await FlutterBluePlus.isOn;
      if (!isOn) {
        // Just notify instead of trying to turn it on (which requires internet)
        devicesMsg("Please enable Bluetooth manually");
        return;
      }

      // Now we know Bluetooth is supported and enabled, proceed with scanning
      int retryCount = 0;
      while (retryCount < 3) {
        try {
          await startScanning();
          if (devices.isNotEmpty) {
            break;
          }
          retryCount++;
          if (retryCount < 3) {
            await Future.delayed(const Duration(seconds: 2));
          }
        } catch (e) {
          print('Scan attempt $retryCount failed: $e');
          retryCount++;
          if (retryCount >= 3) {
            // Don't rethrow, just log the error
            print('Failed to scan after 3 attempts: $e');
            devicesMsg("Could not scan for devices. Please try again later.");
            return;
          }
          await Future.delayed(const Duration(seconds: 2));
        }
      }
    } catch (e) {
      // Handle errors without requiring internet
      if (e.toString().contains('bluetooth_unavailable')) {
        devicesMsg("Please enable Bluetooth");
      } else {
        // Log the error but don't crash
        print('Non-fatal Bluetooth init error: $e');
        devicesMsg("Bluetooth initialization issue, but app can continue");
      }
    }
  }

  Future<void> startScanning() async {
    if (isScanning.value) return;

    try {
      isScanning(true);
      devices.clear();
      devicesMsg("Scanning...");

      if (FlutterBluePlus.isScanningNow) {
        try {
          await FlutterBluePlus.stopScan();
        } catch (e) {
          print('Error stopping scan: $e');
          // Continue anyway, don't block the app
        }
      }

      await _scanSubscription?.cancel();

      _scanSubscription = FlutterBluePlus.scanResults.listen(
        (results) {
          devices.value = results
              .where((result) =>
                  result.device.localName.isNotEmpty ||
                  result.advertisementData.localName.isNotEmpty)
              .toList();

          for (var device in results) {
            print(
                'Found device: ${device.device.localName} (${device.device.id})');
            print('Advertisement name: ${device.advertisementData.localName}');
            print('RSSI: ${device.rssi}');
          }

          if (devices.isNotEmpty) {
            devicesMsg("");
          }
        },
        onError: (e) {
          print('Scan error: $e');
          isScanning(false);
          devicesMsg("Error scanning: $e");
        },
      );

      try {
        await FlutterBluePlus.startScan(
          timeout: const Duration(seconds: 15),
          androidUsesFineLocation: true,
        );
      } catch (e) {
        print('Error starting scan: $e');
        isScanning(false);
        devicesMsg(
            "Could not start scanning. ${e.toString().substring(0, 50)}...");
        return;
      }

      await Future.delayed(const Duration(seconds: 15));
      if (isScanning.value) {
        isScanning(false);
        try {
          await FlutterBluePlus.stopScan();
        } catch (e) {
          print('Error stopping scan after delay: $e');
          // Continue anyway
        }
        if (devices.isEmpty) {
          devicesMsg("No devices found");
        }
      }
    } catch (e) {
      print('Scanning error: $e');
      isScanning(false);
      // Truncate the error message if it's too long to avoid UI issues
      String errorMsg = e.toString();
      if (errorMsg.length > 100) {
        errorMsg = "${errorMsg.substring(0, 100)}...";
      }
      devicesMsg("Error: $errorMsg");
    }
  }

  Future<void> printWithSavedPrinter(List<Uint8List?> data) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPrinterIdFromPrefs = prefs.getString('saved_printer_id');

    if (savedPrinterIdFromPrefs == null || savedPrinterIdFromPrefs.isEmpty) {
      throw Exception('No saved printer found');
    }

    try {
      if (!await FlutterBluePlus.isOn) {
        await FlutterBluePlus.turnOn();
        await Future.delayed(const Duration(milliseconds: 500));
      }

      BluetoothDevice? savedDevice;
      bool deviceFound = false;

      final completer = Completer<void>();

      await startScanning();

      final subscription = FlutterBluePlus.scanResults.listen((results) {
        savedDevice = results
            .firstWhereOrNull((result) =>
                result.device.id.toString() == savedPrinterIdFromPrefs)
            ?.device;

        if (savedDevice != null && !deviceFound) {
          deviceFound = true;
          completer.complete();
        }
      });

      try {
        await Future.any([
          completer.future,
          Future.delayed(const Duration(seconds: 30)).then((_) {
            if (!deviceFound) {
              throw Exception(
                  'Scan timeout: Printer not found after 30 seconds');
            }
          })
        ]);
      } catch (e) {
        print('Scan error or timeout: $e');
        throw Exception(
            'Could not find saved printer. Please try again or select a new printer.');
      }

      await subscription.cancel();

      if (FlutterBluePlus.isScanningNow) {
        await FlutterBluePlus.stopScan();
      }

      if (savedDevice == null) {
        await prefs.remove('saved_printer_id');
        savedPrinterId.value = null;
        throw Exception('Saved printer not found. Please scan for printers.');
      }

      if (savedDevice != null) {
        await connectAndPrint(savedDevice!, data);
      } else {
        throw Exception('Saved printer not found. Please scan for printers.');
      }
    } catch (e) {
      print('Error printing with saved printer: $e');
      rethrow;
    } finally {
      if (FlutterBluePlus.isScanningNow) {
        await FlutterBluePlus.stopScan();
      }
    }
  }

  Future<void> connectAndPrint(
      BluetoothDevice device, List<Uint8List?> data) async {
    try {
      if (_connectedDevice != null) {
        await _connectedDevice!.disconnect();
        await Future.delayed(const Duration(milliseconds: 500));
      }

      await device.connect(timeout: const Duration(seconds: 5));
      _connectedDevice = device;
      isConnected(true);

      await Future.delayed(const Duration(seconds: 1));

      List<BluetoothService> services = await device.discoverServices();
      BluetoothCharacteristic? writeCharacteristic;

      for (var service in services) {
        var characteristics = service.characteristics;
        for (var characteristic in characteristics) {
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

      int mtuSize = 20;
      try {
        final negotiatedMtu = await device.mtu.first;
        mtuSize = negotiatedMtu - 3;
      } catch (e) {
        print('Could not get MTU size: $e');
      }

      final bytes = await generatePrintData(data);

      final chunkSize = mtuSize < 180 ? mtuSize : 180;
      print('Using chunk size: $chunkSize bytes');

      for (var i = 0; i < bytes.length; i += chunkSize) {
        try {
          final end =
              (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
          final chunk = bytes.sublist(i, end);

          print(
              'Sending chunk ${i ~/ chunkSize + 1} of ${(bytes.length / chunkSize).ceil()} (${chunk.length} bytes)');

          int retryCount = 0;
          while (retryCount < 3) {
            try {
              await writeCharacteristic.write(chunk, withoutResponse: true);
              break;
            } catch (e) {
              retryCount++;
              if (retryCount == 3) rethrow;
              await Future.delayed(Duration(milliseconds: 200));
            }
          }

          await Future.delayed(Duration(milliseconds: 150));
        } catch (e) {
          print('Error sending chunk: $e');
          rethrow;
        }
      }

      await Future.delayed(Duration(seconds: 1));

      await device.disconnect();
      _connectedDevice = null;
      isConnected(false);
    } catch (e) {
      print('Print error: $e');
      isConnected(false);
      _connectedDevice = null;
      rethrow;
    }
  }

  Future<List<int>> generatePrintData(List<Uint8List?> data) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];

    bytes += generator.text(
      'Date: ${DateTime.now().toString().split(' ')[0]}',
      styles: PosStyles(align: PosAlign.right),
    );
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

      if (item != null) {
        final img.Image originalImage = img.decodeImage(item)!;

        // Resize image to fit receipt width
        final img.Image resizedImage = img.copyResize(
          originalImage,
          width: 576,
          height: 100,
        );

        bytes += generator.image(resizedImage, align: PosAlign.left);
      } else {
        bytes += generator.text('(Image failed to load)',
            styles: PosStyles(align: PosAlign.left));
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
        styles: PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);
    bytes += generator.hr();

    bytes += generator.text('Thank you for your business!',
        styles: PosStyles(align: PosAlign.center));
    bytes += generator.text('Please visit again',
        styles: PosStyles(align: PosAlign.center));
    bytes += generator.feed(2);
    bytes += generator.cut();

    return bytes;
  }

  Future<void> printPdfWithSavedPrinter(
      List<Map<String, dynamic>> items) async {
    try {
      // If already connected to a printer, try to print directly first
      if (isConnected.value && _connectedDevice != null) {
        try {
          print('Using already connected printer: ${_connectedDevice!.name}');
          await _printDirectWithConnectedPrinter(items);
          // Save this printer if not already saved
          await saveSelectedPrinter(_connectedDevice!);
          return;
        } catch (e) {
          print('Direct print failed, falling back to reconnection: $e');
          isConnected(false);
          _connectedDevice = null;
        }
      }

      // Check for saved printer
      final prefs = await SharedPreferences.getInstance();
      final savedPrinterIdFromPrefs = prefs.getString('saved_printer_id');

      // Quick Bluetooth check
      if (!await FlutterBluePlus.isOn) {
        throw Exception('Please turn on Bluetooth to print');
      }

      // Start scanning for printers
      print('Scanning for printers...');
      BluetoothDevice? targetDevice;
      bool deviceFound = false;
      final completer = Completer<void>();

      // If we have a saved printer ID, look for it specifically
      if (savedPrinterIdFromPrefs != null &&
          savedPrinterIdFromPrefs.isNotEmpty) {
        print('Looking for saved printer: $savedPrinterIdFromPrefs');
        final subscription = FlutterBluePlus.scanResults.listen((results) {
          targetDevice = results
              .firstWhereOrNull((result) =>
                  result.device.id.toString() == savedPrinterIdFromPrefs)
              ?.device;

          if (targetDevice != null && !deviceFound) {
            deviceFound = true;
            completer.complete();
          }
        });

        await startScanning();

        try {
          await Future.any([
            completer.future,
            Future.delayed(const Duration(seconds: 10)).then((_) {
              if (!deviceFound) {
                print('Saved printer not found, will look for any printer');
              }
            })
          ]);
        } catch (e) {
          print('Error looking for saved printer: $e');
        }

        await subscription.cancel();
        if (FlutterBluePlus.isScanningNow) {
          await FlutterBluePlus.stopScan();
        }
      }

      // If no saved printer found, look for any printer
      if (!deviceFound) {
        print('Looking for any available printer...');
        deviceFound = false;
        final newCompleter = Completer<void>();

        final subscription = FlutterBluePlus.scanResults.listen((results) {
          // Look for devices that might be printers (you might want to add more specific criteria)
          targetDevice = results.firstWhereOrNull((result) {
            final name = result.device.localName.toLowerCase();
            return name.contains('printer') ||
                name.contains('pos') ||
                name.contains('thermal') ||
                name.contains('bt');
          })?.device;

          if (targetDevice != null && !deviceFound) {
            deviceFound = true;
            newCompleter.complete();
          }
        });

        await startScanning();

        try {
          await Future.any([
            newCompleter.future,
            Future.delayed(const Duration(seconds: 15)).then((_) {
              if (!deviceFound) {
                throw Exception(
                    'No printers found. Please make sure your printer is turned on and nearby.');
              }
            })
          ]);
        } finally {
          await subscription.cancel();
          if (FlutterBluePlus.isScanningNow) {
            await FlutterBluePlus.stopScan();
          }
        }
      }

      if (targetDevice == null) {
        throw Exception(
            'No printer found. Please make sure your printer is turned on and nearby.');
      }

      // Try to connect and print
      print('Attempting to connect to printer: ${targetDevice?.name}');
      await _connectAndPrintDirect(targetDevice!, items);

      // If we successfully printed, save this printer
      await saveSelectedPrinter(targetDevice);
      print('Successfully saved printer: ${targetDevice?.name}');
    } catch (e) {
      print('Error in printPdfWithSavedPrinter: $e');
      rethrow;
    } finally {
      if (FlutterBluePlus.isScanningNow) {
        await FlutterBluePlus.stopScan();
      }
    }
  }

  // Optimize the direct print method
  Future<void> _printDirectWithConnectedPrinter(
      List<Map<String, dynamic>> items) async {
    try {
      if (_connectedDevice == null) throw Exception('No printer connected');

      List<BluetoothService> services =
          await _connectedDevice!.discoverServices();
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
        final negotiatedMtu = await _connectedDevice!.mtu.first;
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
      print('Error in direct print: $e');
      isConnected(false);
      _connectedDevice = null;
      rethrow;
    }
  }

  // New method to connect and print directly without PDF intermediary
  Future<void> _connectAndPrintDirect(
      BluetoothDevice? device, List<Map<String, dynamic>> items) async {
    try {
      // If already connected to a different device, disconnect first
      if (_connectedDevice != null && _connectedDevice!.id != device?.id) {
        print('Disconnecting from previous device: ${_connectedDevice!.name}');
        await _connectedDevice!.disconnect();
        await Future.delayed(const Duration(milliseconds: 500));
        _connectedDevice = null;
        isConnected(false);
      }

      // If not connected to any device, connect now
      if (!isConnected.value || _connectedDevice == null) {
        print('Connecting to device: ${device?.name}');
        await device?.connect(timeout: const Duration(seconds: 5));
        _connectedDevice = device;
        isConnected(true);
        print('Successfully connected to: ${device?.name}');
      }

      await Future.delayed(const Duration(seconds: 1));

      List<BluetoothService> services = await device!.discoverServices();
      BluetoothCharacteristic? writeCharacteristic;

      for (var service in services) {
        var characteristics = service.characteristics;
        for (var characteristic in characteristics) {
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

      int mtuSize = 20;
      try {
        final negotiatedMtu = await device.mtu.first;
        mtuSize = negotiatedMtu - 3;
      } catch (e) {
        print('Could not get MTU size: $e');
      }

      // Generate receipt data directly from items
      final bytes = await generateDirectReceiptData(items);

      final chunkSize = mtuSize < 180 ? mtuSize : 180;
      print('Using chunk size: $chunkSize bytes');

      for (int i = 0; i < bytes.length; i += chunkSize) {
        int end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
        await writeCharacteristic.write(bytes.sublist(i, end));
        await Future.delayed(const Duration(milliseconds: 20));
      }

      print('Successfully sent data to printer');

      // IMPORTANT: We do NOT disconnect here to maintain the connection for future prints
    } catch (e) {
      print('Error connecting to printer: $e');
      // If connection fails, reset the connection state
      isConnected(false);
      _connectedDevice = null;
      rethrow;
    }
  }

  // Generate PDF for receipt
  Future<Uint8List> generateReceiptPdf(List<Map<String, dynamic>> items) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat:
            PdfPageFormat(80 * PdfPageFormat.mm, 150 * PdfPageFormat.mm),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text('RECEIPT',
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('Date: ${DateTime.now().toString().split(' ')[0]}'),
              pw.Divider(),

              // Header row
              pw.Row(
                children: [
                  pw.Expanded(flex: 3, child: pw.Text('Item')),
                  pw.Expanded(
                      child: pw.Text('Qty', textAlign: pw.TextAlign.center)),
                  pw.Expanded(
                      child: pw.Text('Rate', textAlign: pw.TextAlign.center)),
                  pw.Expanded(
                      child: pw.Text('Amt', textAlign: pw.TextAlign.center)),
                ],
              ),
              pw.Divider(),

              // Item rows
              pw.Column(
                children: items.map((item) {
                  final quantity =
                      int.tryParse(item['quantity'].toString()) ?? 0;
                  final rate = int.tryParse(item['rate'].toString()) ?? 0;
                  final amount = quantity * rate;

                  return pw.Row(
                    children: [
                      pw.Expanded(
                          flex: 3,
                          child: pw.Text(
                              'Item')), // Cannot display images from particulars in this version
                      pw.Expanded(
                          child: pw.Text('$quantity',
                              textAlign: pw.TextAlign.center)),
                      pw.Expanded(
                          child:
                              pw.Text('$rate', textAlign: pw.TextAlign.center)),
                      pw.Expanded(
                          child: pw.Text('$amount',
                              textAlign: pw.TextAlign.center)),
                    ],
                  );
                }).toList(),
              ),

              pw.Divider(),
              // Total row
              pw.Row(
                children: [
                  pw.Expanded(flex: 3, child: pw.Text('')),
                  pw.Expanded(
                      flex: 2,
                      child: pw.Text('TOTAL', textAlign: pw.TextAlign.center)),
                  pw.Expanded(
                      child: pw.Text(
                          '${items.fold<int>(0, (sum, item) {
                            final quantity =
                                int.tryParse(item['quantity'].toString()) ?? 0;
                            final rate =
                                int.tryParse(item['rate'].toString()) ?? 0;
                            return sum + (quantity * rate);
                          })}',
                          textAlign: pw.TextAlign.center)),
                ],
              ),

              pw.SizedBox(height: 20),
              pw.Text('Thank you for your business!',
                  textAlign: pw.TextAlign.center),
              pw.Text('Please visit again', textAlign: pw.TextAlign.center),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // New method to directly generate receipt data without PDF intermediary
  Future<List<int>> generateDirectReceiptData(
      List<Map<String, dynamic>> items) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];

    // Add receipt header
    bytes += generator.text(
      'RECEIPT',
      styles: PosStyles(
          align: PosAlign.center, bold: true, height: PosTextSize.size2),
    );
    bytes += generator.text(
      'Date: ${DateTime.now().toString().split(' ')[0]}',
      styles: PosStyles(align: PosAlign.right),
    );
    bytes += generator.hr();

    // Add headers with proper alignment
    bytes += generator.row([
      PosColumn(
          text: 'Particulars',
          width: 6,
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
    for (var item in items) {
      try {
        if (item['particulars'] != null && item['particulars'] is Uint8List) {
          final quantity = int.tryParse(item['quantity'].toString()) ?? 0;
          final rate = int.tryParse(item['rate'].toString()) ?? 0;
          final amount = quantity * rate;

          // Get the handwritten image
          final Uint8List handwrittenBytes = item['particulars'];
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

            // Create a new blank image with minimal height
            final img.Image finalImage = img.Image.rgb(
              resizedImage.width,
              resizedImage.height + 10, // Reduced extra space
            );

            // Make background transparent/white
            for (int y = 0; y < finalImage.height; y++) {
              for (int x = 0; x < finalImage.width; x++) {
                finalImage.setPixel(x, y, 0xFFFFFFFF);
              }
            }

            // Copy the handwriting with proper thresholding
            for (int y = 0; y < resizedImage.height; y++) {
              for (int x = 0; x < resizedImage.width; x++) {
                final pixel = resizedImage.getPixel(x, y);
                final brightness = img.getLuminance(pixel);
                if (brightness < 128) {
                  // Dark pixels become black
                  finalImage.setPixel(x, y, 0xFF000000);
                }
              }
            }

            // Print the combined row with image and text
            bytes += generator.row([
              PosColumn(
                width: 6,
                text: '', // Space for image that we'll print right after
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

            // Move up and print the image with minimal spacing
            bytes += generator.feed(-1);
            bytes += generator.imageRaster(finalImage, align: PosAlign.left);

            // Add minimal separator line with less spacing
            bytes += generator.hr(ch: '-', linesAfter: 0);
          }
        }
      } catch (e) {
        print('Error processing item image: $e');
        continue;
      }

      // Removed the extra hr here since we're adding it after the image
    }

    // Add total with minimal spacing
    final total = items.fold<int>(0, (sum, item) {
      final quantity = int.tryParse(item['quantity'].toString()) ?? 0;
      final rate = int.tryParse(item['rate'].toString()) ?? 0;
      return sum + (quantity * rate);
    });

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

    // Add receipt footer with reduced spacing
    bytes += generator.hr();
    bytes += generator.text('Thank you for your business!',
        styles: PosStyles(align: PosAlign.center));
    bytes += generator.text('Please visit again',
        styles: PosStyles(align: PosAlign.center));
    bytes += generator.feed(1); // Reduced from 2 to 1
    bytes += generator.cut();

    return bytes;
  }

  @override
  void onClose() {
    _scanSubscription?.cancel();
    if (_connectedDevice != null) {
      // Finally disconnect the device when the controller is closed (app closing)
      print('Disconnecting printer on app close: ${_connectedDevice!.name}');
      try {
        _connectedDevice!.disconnect();
      } catch (e) {
        print('Error disconnecting printer: $e');
      }
      _connectedDevice = null;
      isConnected(false);
    }
    if (FlutterBluePlus.isScanningNow) {
      try {
        FlutterBluePlus.stopScan();
      } catch (e) {
        print('Error stopping scan on close: $e');
      }
    }
    super.onClose();
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
