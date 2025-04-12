import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreenController extends GetxController {
  RxBool isScanning = false.obs;
  RxBool isConnected = false.obs;
  RxString devicesMsg = "".obs;
  RxList<BluetoothDevice> devices = <BluetoothDevice>[].obs;
  BluetoothDevice? _connectedDevice;
  StreamSubscription? _scanSubscription;
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
    }
  }

  Future<void> clearSavedPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_printer_id');
    savedPrinterId.value = null;
  }

  Future<void> initBluetooth() async {
    try {
      if (!await FlutterBluePlus.isSupported) {
        devicesMsg("Bluetooth is not supported on this device");
        return;
      }

      final isOn = await FlutterBluePlus.isOn;
      if (!isOn) {
        devicesMsg("Please enable Bluetooth manually");
        return;
      }

      int retryCount = 0;
      while (retryCount < 3) {
        try {
          await startScanning();
          if (_connectedDevice != null) {
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
            print('Failed to scan after 3 attempts: $e');
            devicesMsg("Could not scan for devices. Please try again later.");
            return;
          }
          await Future.delayed(const Duration(seconds: 2));
        }
      }
    } catch (e) {
      if (e.toString().contains('bluetooth_unavailable')) {
        devicesMsg("Please enable Bluetooth");
      } else {
        print('Non-fatal Bluetooth init error: $e');
        devicesMsg("Bluetooth initialization issue, but app can continue");
      }
    }
  }

  Future<void> startScanning() async {
    if (isScanning.value) return;

    try {
      isScanning(true);
      devicesMsg("Scanning...");

      if (FlutterBluePlus.isScanningNow) {
        try {
          await FlutterBluePlus.stopScan();
        } catch (e) {
          print('Error stopping scan: $e');
        }
      }

      await _scanSubscription?.cancel();

      _scanSubscription = FlutterBluePlus.scanResults.listen(
        (results) async {
          // First try to find saved printer
          if (savedPrinterId.value != null) {
            final savedDevice = results
                .firstWhereOrNull(
                  (result) =>
                      result.device.id.toString() == savedPrinterId.value,
                )
                ?.device;

            if (savedDevice != null) {
              try {
                await connectToPrinter(savedDevice);
                return;
              } catch (e) {
                print('Failed to connect to saved printer: $e');
              }
            }
          }

          // If no saved printer or connection failed, look for any printer
          final printerDevice = results.firstWhereOrNull((result) {
            final name = result.device.localName.toLowerCase();
            return name.contains('printer') ||
                name.contains('pos') ||
                name.contains('thermal') ||
                name.contains('bt');
          })?.device;

          if (printerDevice != null) {
            try {
              await connectToPrinter(printerDevice);
            } catch (e) {
              print('Failed to connect to found printer: $e');
            }
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
        }
        if (_connectedDevice == null) {
          devicesMsg("No printers found");
        }
      }
    } catch (e) {
      print('Scanning error: $e');
      isScanning(false);
      String errorMsg = e.toString();
      if (errorMsg.length > 100) {
        errorMsg = "${errorMsg.substring(0, 100)}...";
      }
      devicesMsg("Error: $errorMsg");
    }
  }

  Future<void> connectToPrinter(BluetoothDevice device) async {
    try {
      if (_connectedDevice != null) {
        await _connectedDevice!.disconnect();
        await Future.delayed(const Duration(milliseconds: 500));
      }

      await device.connect(timeout: const Duration(seconds: 5));
      _connectedDevice = device;
      isConnected(true);
      await saveSelectedPrinter(device);
      // Get.snackbar("Connected","Successfully connected to printer: ${device.name}");
      print('Successfully connected to printer: ${device.name}');
    } catch (e) {
      // Get.snackbar("Error","Error connecting to printer");
      print('Error connecting to printer: $e');
      isConnected(false);
      _connectedDevice = null;
      rethrow;
    }
  }

  BluetoothDevice? get connectedDevice => _connectedDevice;

  @override
  void onClose() {
    _scanSubscription?.cancel();
    if (_connectedDevice != null) {
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
