import 'dart:async';
import 'package:flutter/material.dart';
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
  bool _isDialogShowing = false;

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

      // First try to connect to saved printer if exists
      if (savedPrinterId.value != null) {
        try {
          final savedDevice = await _findSavedPrinter();
          if (savedDevice != null) {
            await connectToPrinter(savedDevice);
            return;
          }
        } catch (e) {
          print('Error connecting to saved printer: $e');
          // If saved printer connection fails, continue to show dialog
        }
      }

      // If no active connection and no dialog showing, show device selection
      if (!isConnected.value && !_isDialogShowing) {
        _isDialogShowing = true;
        await showDeviceSelectionDialog();
        _isDialogShowing = false;
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

  Future<BluetoothDevice?> _findSavedPrinter() async {
    if (savedPrinterId.value == null) return null;

    try {
      await startScanning();
      for (var device in devices) {
        if (device.id.toString() == savedPrinterId.value) {
          return device;
        }
      }
      return null;
    } catch (e) {
      print('Error finding saved printer: $e');
      return null;
    }
  }

  Future<void> showDeviceSelectionDialog() async {
    devices.clear();
    isScanning(true);
    devicesMsg("Scanning for Bluetooth devices...");

    try {
      await _scanSubscription?.cancel();
      _scanSubscription = FlutterBluePlus.scanResults.listen(
        (results) {
          for (var result in results) {
            if (!devices.contains(result.device)) {
              devices.add(result.device);
              print(
                  'Found device: ${result.device.localName} (${result.device.id})');
            }
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

      // Show device selection dialog
      Get.dialog(
        AlertDialog(
          title: const Text('Select Bluetooth Device'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(() => Text(devicesMsg.value)),
                const SizedBox(height: 10),
                Obx(() => isScanning.value
                    ? const CircularProgressIndicator()
                    : const SizedBox.shrink()),
                const SizedBox(height: 10),
                Obx(() => devices.isEmpty && !isScanning.value
                    ? const Text('No devices found. Please try rescanning.')
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: devices.length,
                        itemBuilder: (context, index) {
                          final device = devices[index];
                          return ListTile(
                            title: Text(device.localName.isEmpty
                                ? 'Unknown Device'
                                : device.localName),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ID: ${device.id}'),
                                Text('Type: ${_getDeviceType(device)}'),
                              ],
                            ),
                            onTap: () async {
                              try {
                                await connectToPrinter(device);
                                Get.back();
                              } catch (e) {
                                Get.snackbar(
                                  'Error',
                                  'Failed to connect to device: ${e.toString()}',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              }
                            },
                          );
                        },
                      )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                isScanning(false);
                await FlutterBluePlus.stopScan();
                Get.back();
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () async {
                devices.clear();
                isScanning(true);
                devicesMsg("Scanning for Bluetooth devices...");
                await startScanning();
              },
              child: const Text('Rescan'),
            ),
          ],
        ),
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
      print('Error showing device dialog: $e');
      isScanning(false);
      devicesMsg("Error: ${e.toString().substring(0, 100)}...");
    }
  }

  String _getDeviceType(BluetoothDevice device) {
    // This is a simple classification based on device name
    // You can enhance this based on your needs
    final name = device.localName.toLowerCase();
    if (name.contains('printer')) return 'Printer';
    if (name.contains('headphone') ||
        name.contains('earbud') ||
        name.contains('earphone')) return 'Audio Device';
    if (name.contains('phone') || name.contains('mobile')) return 'Phone';
    if (name.contains('watch') || name.contains('band')) return 'Wearable';
    return 'Other Device';
  }

  Future<void> startScanning() async {
    if (isScanning.value) {
      // If already scanning, stop current scan first
      await FlutterBluePlus.stopScan();
      isScanning(false);
      await Future.delayed(const Duration(milliseconds: 500));
    }

    try {
      isScanning(true);
      devices.clear();
      devicesMsg("Scanning for Bluetooth devices...");

      await _scanSubscription?.cancel();
      _scanSubscription = FlutterBluePlus.scanResults.listen(
        (results) {
          for (var result in results) {
            if (!devices.contains(result.device)) {
              devices.add(result.device);
              print(
                  'Found device: ${result.device.localName} (${result.device.id})');
            }
          }
        },
        onError: (e) {
          print('Scan error: $e');
          isScanning(false);
          devicesMsg("Error scanning: $e");
        },
      );

      // Start scan with timeout
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 10),
        androidUsesFineLocation: true,
      );

      // Wait for scan to complete or timeout
      await Future.delayed(const Duration(seconds: 10));

      // Stop scanning and update UI
      if (isScanning.value) {
        isScanning(false);
        await FlutterBluePlus.stopScan();
        if (devices.isEmpty) {
          devicesMsg("No devices found. Please try rescanning.");
        } else {
          devicesMsg("Scan complete. Found ${devices.length} devices.");
        }
      }
    } catch (e) {
      print('Scanning error: $e');
      isScanning(false);
      devicesMsg("Error: ${e.toString().substring(0, 100)}...");
      // Make sure to stop scanning on error
      try {
        await FlutterBluePlus.stopScan();
      } catch (e) {
        print('Error stopping scan: $e');
      }
    }
  }

  Future<void> connectToPrinter(BluetoothDevice device) async {
    try {
      if (_connectedDevice != null) {
        await _connectedDevice!.disconnect();
        await Future.delayed(const Duration(milliseconds: 500));
      }

      await device.connect(timeout: const Duration(seconds: 10));
      _connectedDevice = device;
      isConnected(true);
      await saveSelectedPrinter(device);
      Get.snackbar(
        "Success",
        "Connected to device: ${device.localName}",
        snackPosition: SnackPosition.BOTTOM,
      );
      print('Successfully connected to device: ${device.localName}');
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to connect to device: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
      );
      print('Error connecting to device: $e');
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
      print('Disconnecting device on app close: ${_connectedDevice!.name}');
      try {
        _connectedDevice!.disconnect();
      } catch (e) {
        print('Error disconnecting device: $e');
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
