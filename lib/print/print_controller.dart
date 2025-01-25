import 'package:get/get.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:typed_data';
import 'dart:async';

class PrintController extends GetxController {
  RxList<ScanResult> devices = <ScanResult>[].obs;
  RxString devicesMsg = "".obs;
  RxBool isScanning = false.obs;
  RxBool isConnected = false.obs;
  StreamSubscription? _scanSubscription;
  BluetoothDevice? _connectedDevice;

  @override
  void onInit() {
    super.onInit();
    // initBluetooth();
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
          // Add all devices that have a name
          final newDevices = results.toList();

          // Debug print for found devices
          for (var device in newDevices) {
            print('Found device: ${device.device.localName} (${device.device.id})');
            print('Advertisement name: ${device.advertisementData.localName}');
            print('RSSI: ${device.rssi}');
          }

          devices(newDevices);

          if (newDevices.isNotEmpty) {
            devicesMsg("");
            isScanning(false);
            FlutterBluePlus.stopScan(); // Stop scan when devices are found
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
        timeout: const Duration(seconds: 15),  // Increased timeout
        androidUsesFineLocation: true,        // Use fine location for better results
      );

      // Wait for scan to complete
      await Future.delayed(const Duration(seconds: 15));
      if (isScanning.value) {
        isScanning(false);
        await FlutterBluePlus.stopScan();
      }
    } catch (e) {
      print('Scanning error: $e');
      isScanning(false);
      devicesMsg("Error: ${e.toString()}");
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
    var profile = await CapabilityProfile.load();
    var generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    // Add header
    bytes += generator.text('Store Name',
        styles: PosStyles(align: PosAlign.center, height: PosTextSize.size2, width: PosTextSize.size2));
    bytes += generator.text('Address Line 1', styles: PosStyles(align: PosAlign.center));
    bytes += generator.text('Address Line 2', styles: PosStyles(align: PosAlign.center));
    bytes += generator.hr();

    // Add date
    bytes += generator.text('Date: ${DateTime.now().toString().split('.')[0]}',
        styles: PosStyles(align: PosAlign.left));
    bytes += generator.hr();

    // Add items
    double total = 0;
    for (var item in data) {
      double price = double.tryParse(item['price']?.toString() ?? '0') ?? 0;
      int qty = int.tryParse(item['quantity']?.toString() ?? '0') ?? 0;
      double itemTotal = price * qty;
      total += itemTotal;

      bytes += generator.row([
        PosColumn(text: item['title']?.toString() ?? '', width: 4),
        PosColumn(text: qty.toString(), width: 2),
        PosColumn(text: price.toStringAsFixed(2), width: 2),
        PosColumn(text: itemTotal.toStringAsFixed(2), width: 4),
      ]);
    }

    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(text: 'TOTAL', width: 6, styles: PosStyles(bold: true)),
      PosColumn(text: total.toStringAsFixed(2), width: 6, styles: PosStyles(bold: true)),
    ]);
    bytes += generator.hr();

    // Add footer
    bytes += generator.text('Thank you for your business!',
        styles: PosStyles(align: PosAlign.center));
    bytes += generator.text('Please visit again',
        styles: PosStyles(align: PosAlign.center));
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
}