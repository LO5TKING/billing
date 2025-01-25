import 'dart:ui';

import 'package:get/get.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:typed_data';
import 'dart:async';
import 'package:image/image.dart';
import 'dart:ui' as ui;

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
      // Initialize FlutterBluePlus
      await FlutterBluePlus.turnOn();

      // Check if Bluetooth is available
      if (!await FlutterBluePlus.isSupported) {
        devicesMsg("Bluetooth is not supported on this device");
        return;
      }

      // Wait for Bluetooth state to stabilize
      await Future.delayed(const Duration(milliseconds: 500));

      // Check Bluetooth state
      final isOn = await FlutterBluePlus.isOn;
      if (!isOn) {
        devicesMsg("Please enable Bluetooth");
        return;
      }

      // Start scanning with retry mechanism
      int retryCount = 0;
      while (retryCount < 3) {
        try {
          await startScanning();
          if (devices.isNotEmpty) {
            break; // Successfully found devices
          }
          retryCount++;
          if (retryCount < 3) {
            await Future.delayed(const Duration(seconds: 2)); // Wait before retry
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

      // Stop any existing scan
      if (FlutterBluePlus.isScanningNow) {
        await FlutterBluePlus.stopScan();
      }

      // Start new scan
      // Cancel existing subscription
      await _scanSubscription?.cancel();

      _scanSubscription = FlutterBluePlus.scanResults.listen(
            (results) {
          // Update devices list with new results
          devices.value = results.where((result) =>
          result.device.localName.isNotEmpty ||
              result.advertisementData.localName.isNotEmpty
          ).toList();

          // Debug print for found devices
          for (var device in results) {
            print('Found device: ${device.device.localName} (${device.device.id})');
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

      // Start scanning with longer timeout
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 15),
        androidUsesFineLocation: true,
      );

      // Wait for scan to complete
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

  // Method to directly print with saved printer
  Future<void> printWithSavedPrinter(List<Map<String, dynamic>> data) async {
    // Get printer ID directly from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final savedPrinterIdFromPrefs = prefs.getString('saved_printer_id');

    // Null check for saved printer ID
    if (savedPrinterIdFromPrefs == null || savedPrinterIdFromPrefs.isEmpty) {
      throw Exception('No saved printer found');
    }

    try {
      // Initialize Bluetooth if needed
      if (!await FlutterBluePlus.isOn) {
        await FlutterBluePlus.turnOn();
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // Start scanning and wait for the saved device
      BluetoothDevice? savedDevice;
      bool deviceFound = false;

      // Create a completer to handle the timeout
      final completer = Completer<void>();

      // Start scanning
      await startScanning();

      // Listen to scan results
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

      // Wait for device to be found or timeout
      try {
        await Future.any([
          completer.future,
          Future.delayed(const Duration(seconds: 30)) // Increased timeout to 30 seconds
              .then((_) {
            if (!deviceFound) {
              throw Exception('Scan timeout: Printer not found after 30 seconds');
            }
          })
        ]);
      } catch (e) {
        print('Scan error or timeout: $e');
        throw Exception('Could not find saved printer. Please try again or select a new printer.');
      }

      // Clean up subscription
      await subscription.cancel();

      // Stop scanning
      if (FlutterBluePlus.isScanningNow) {
        await FlutterBluePlus.stopScan();
      }

      // Check if device was found
      if (savedDevice == null) {
        // If printer not found, clear the saved ID
        await prefs.remove('saved_printer_id');
        savedPrinterId.value = null;
        throw Exception('Saved printer not found. Please scan for printers.');
      }

      // Print with the saved printer
      if(savedDevice != null) {
        await connectAndPrint(savedDevice!, data);
      }else{
        throw Exception('Saved printer not found. Please scan for printers.');
      }
    } catch (e) {
      print('Error printing with saved printer: $e');
      rethrow;
    } finally {
      // Clean up
      if (FlutterBluePlus.isScanningNow) {
        await FlutterBluePlus.stopScan();
      }
    }
  }

  Future<void> connectAndPrint(BluetoothDevice device, List<Map<String, dynamic>> data) async {
    try {
      // Disconnect from any existing connection
      if (_connectedDevice != null) {
        await _connectedDevice!.disconnect();
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // Connect to the device
      await device.connect(timeout: const Duration(seconds: 5));
      _connectedDevice = device;
      isConnected(true);

      // Wait for connection to stabilize
      await Future.delayed(const Duration(seconds: 1));

      // Discover services
      List<BluetoothService> services = await device.discoverServices();
      BluetoothCharacteristic? writeCharacteristic;

      // Find the printer service and characteristic
      for (var service in services) {
        var characteristics = service.characteristics;
        for (var characteristic in characteristics) {
          if (characteristic.properties.write || characteristic.properties.writeWithoutResponse) {
            writeCharacteristic = characteristic;
            break;
          }
        }
        if (writeCharacteristic != null) break;
      }

      if (writeCharacteristic == null) {
        throw Exception('Printer service not found');
      }

      // Get the MTU size (Maximum Transmission Unit)
      int mtuSize = 20; // Default minimum BLE MTU size
      try {
        // Some devices support requesting MTU size
        final negotiatedMtu = await device.mtu.first;
        mtuSize = negotiatedMtu - 3; // Subtract 3 bytes for ATT header
      } catch (e) {
        print('Could not get MTU size: $e');
      }

      // Generate print data
      final bytes = await _generatePrintData(data);

      // Send data in smaller chunks
      final chunkSize = mtuSize < 180 ? mtuSize : 180; // Use smaller of MTU or 180 bytes
      print('Using chunk size: $chunkSize bytes');

      for (var i = 0; i < bytes.length; i += chunkSize) {
        try {
          final end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
          final chunk = bytes.sublist(i, end);

          // Print progress
          print('Sending chunk ${i ~/ chunkSize + 1} of ${(bytes.length / chunkSize).ceil()} (${chunk.length} bytes)');

          // Write chunk with retry mechanism
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

          // Add delay between chunks to prevent data loss
          await Future.delayed(Duration(milliseconds: 150));
        } catch (e) {
          print('Error sending chunk: $e');
          rethrow;
        }
      }

      // Add final delay to ensure all data is processed
      await Future.delayed(Duration(seconds: 1));

      // Disconnect after printing
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

  Future<List<int>> _generatePrintData(List<Map<String, dynamic>> data) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    // Add header
    bytes += generator.text('Logo',
        styles: PosStyles(align: PosAlign.center, height: PosTextSize.size1, width: PosTextSize.size1));
    bytes += generator.hr();

    // Add date
    bytes += generator.text('Date:- ${DateTime.now().toString().split(' ')[0]}',
        styles: PosStyles(align: PosAlign.right));
    bytes += generator.hr();

    // Add items
    double total = 0;
    for (int i = 0; i < data.length; i++) {
      var item = data[i];
      int qty = int.tryParse(item['quantity']?.toString() ?? '0') ?? 0;
      double rate = double.tryParse(item['rate']?.toString() ?? '0') ?? 0;
      double amount = qty * rate;
      total += amount;

      // Add serial number
      bytes += generator.text('${i + 1}.',
          styles: PosStyles(align: PosAlign.left));

      // Handle the image data for particulars
      if (item['particulars'] is Uint8List) {
        try {
          // Process and add the image
          final imageBytes = await processImage(item['particulars']);
          bytes += imageBytes;
          bytes += generator.feed(1); // Add some space after the image
        } catch (e) {
          print('Error processing image: $e');
          bytes += generator.text('(Image processing failed)',
              styles: PosStyles(align: PosAlign.left));
        }
      }

      // Add quantity, rate and amount
      bytes += generator.row([
        PosColumn(text: 'Qty: $qty', width: 4),
        PosColumn(text: 'Rate: $rate', width: 4),
        PosColumn(text: 'Amt: ${amount.toStringAsFixed(2)}', width: 4),
      ]);

      bytes += generator.hr(); // Add a line after each item
    }

    // Add total
    bytes += generator.row([
      PosColumn(
          text: 'TOTAL',
          width: 6,
          styles: PosStyles(bold: true, align: PosAlign.left)),
      PosColumn(
          text: total.toStringAsFixed(2),
          width: 6,
          styles: PosStyles(bold: true, align: PosAlign.right)),
    ]);

    bytes += generator.hr();
    bytes += generator.feed(2);
    bytes += generator.cut();

    return bytes;
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

  Future<List<int>> processImage(Uint8List imageBytes) async {
    try {
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);

      // Create ESC/POS command for image
      final List<int> bytes = [];

      // Select bit image mode
      bytes.add(0x1B);
      bytes.add(0x2A);
      bytes.add(33); // 24-dot double-density
      bytes.add(imageBytes.length % 256);
      bytes.add(imageBytes.length ~/ 256);

      // Add the image data
      bytes.addAll(imageBytes);

      // Add line feeds
      bytes.add(0x0A);
      bytes.add(0x0A);

      return bytes;
    } catch (e) {
      print('Error processing image: $e');
      return [];
    }
  }

}

// bytes += generator.hr();f
// bytes += generator.text('Thank you for your business!',
// styles: PosStyles(align: PosAlign.center));
// bytes += generator.text('Please visit again',
// styles: PosStyles(align: PosAlign.center));