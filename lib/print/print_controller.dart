import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:typed_data';
import 'dart:async';
import 'package:image/image.dart' as img;

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

  Future<void> saveSelectedPrinter(BluetoothDevice device) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_printer_id', device.id.toString());
    savedPrinterId.value = device.id.toString();
  }

  Future<void> clearSavedPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_printer_id');
    savedPrinterId.value = null;
  }

  Future<void> initBluetooth() async {
    try {
      await FlutterBluePlus.turnOn();

      if (!await FlutterBluePlus.isSupported) {
        devicesMsg("Bluetooth is not supported on this device");
        return;
      }

      await Future.delayed(const Duration(milliseconds: 500));

      final isOn = await FlutterBluePlus.isOn;
      if (!isOn) {
        devicesMsg("Please enable Bluetooth");
        return;
      }

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
          if (retryCount >= 3) rethrow;
          await Future.delayed(const Duration(seconds: 2));
        }
      }
    } catch (e) {
      if (e.toString().contains('bluetooth_unavailable')) {
        devicesMsg("Please enable Bluetooth");
      } else {
        devicesMsg("Error initializing Bluetooth: $e");
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
        await FlutterBluePlus.stopScan();
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

      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 15),
        androidUsesFineLocation: true,
      );

      await Future.delayed(const Duration(seconds: 15));
      if (isScanning.value) {
        isScanning(false);
        await FlutterBluePlus.stopScan();
        if (devices.isEmpty) {
          devicesMsg("No devices found");
        }
      }
    } catch (e) {
      print('Scanning error: $e');
      isScanning(false);
      devicesMsg("Error: ${e.toString()}");
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

  Future<void> connectAndPrint(BluetoothDevice device, List<Uint8List?> data) async {
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
      PosColumn(text: '#', width: 1, styles: PosStyles(bold: true, align: PosAlign.center)),
      PosColumn(text: 'Particulars', width: 5, styles: PosStyles(bold: true)),
      PosColumn(text: 'Qty', width: 2, styles: PosStyles(bold: true, align: PosAlign.center)),
      PosColumn(text: 'Rate', width: 2, styles: PosStyles(bold: true, align: PosAlign.center)),
      PosColumn(text: 'Amt', width: 2, styles: PosStyles(bold: true, align: PosAlign.center)),
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
        bytes += generator.text('(Image failed to load)', styles: PosStyles(align: PosAlign.left));
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

    bytes += generator.text('Thank you for your business!', styles: PosStyles(align: PosAlign.center));
    bytes += generator.text('Please visit again', styles: PosStyles(align: PosAlign.center));
    bytes += generator.feed(2);
    bytes += generator.cut();

    return bytes;
  }



  String convertImageToAscii(img.Image image) {
    int width = 8; // Reduce to small blocks
    int height = 8; // Lower size for readability
    img.Image smallImage = img.copyResize(image, width: width, height: height);

    String ascii = '';
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        int pixel = smallImage.getPixel(x, y);
        int brightness = img.getLuminance(pixel);
        ascii += (brightness > 128) ? '⬜' : '⬛'; // White or black block
      }
      ascii += '\n'; // New row for ASCII image
    }
    return ascii;
  }

  @override
  void onClose() {
    _scanSubscription?.cancel();
    if (_connectedDevice != null) {
      _connectedDevice!.disconnect();
    }
    if (FlutterBluePlus.isScanningNow) {
      FlutterBluePlus.stopScan();
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
