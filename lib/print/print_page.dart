import 'dart:typed_data';

import 'package:billing/app/config/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'print_controller.dart';
import '../controllers/splash_screen_controller.dart';

class PrintDialog extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const PrintDialog({Key? key, required this.data}) : super(key: key);

  static Future<void> show(List<Map<String, dynamic>> data) async {
    // Use Get.find instead of Get.put for PrintController
    final PrintController printController = Get.isRegistered<PrintController>() 
        ? Get.find<PrintController>() 
        : Get.put(PrintController());
    final splashController = Get.find<SplashScreenController>();

    try {
      // Show loading dialog while connecting
      Get.dialog(
        Material(
          type: MaterialType.transparency,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Connecting to printer...'),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // Wait for printer connection
      if (!splashController.isConnected.value) {
        throw Exception('No printer connected');
      }

      // Print the data
      await printController.printPdfReceipt(data);

      // Close loading dialog
      Get.back();

      // Show success message
      Get.snackbar(
        'Success',
        'Printing completed',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
      );
    } catch (e) {
      // Close loading dialog if open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Show error message
      Get.snackbar(
        'Error',
        'Failed to print: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        duration: const Duration(seconds: 5),
      );
    }
  }

  Future<bool> _checkPermissions() async {
    if (GetPlatform.isAndroid) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
        Permission.manageExternalStorage,
        Permission.storage
      ].request();

      bool allGranted = true;
      statuses.forEach((permission, status) {
        if (!status.isGranted) {
          allGranted = false;
        }
      });

      if (!allGranted) {
        Get.snackbar(
          'Permissions Required',
          'Please grant all required permissions to use the printer',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
          duration: const Duration(seconds: 5),
        );
      }

      return allGranted;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final splashController = Get.find<SplashScreenController>();

    return Dialog(
      backgroundColor: AppColors.stainedGlass.withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: Get.width * 0.5,
        height: Get.height * 0.4,
        child: Material(
          color: Colors.transparent,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.baseLoadColor.withOpacity(0.3),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Printer',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Obx(
                          () => splashController.isScanning.value
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                    strokeWidth: 2,
                                  ),
                                )
                              : IconButton(
                                  icon: const Icon(Icons.refresh,
                                      color: Colors.white),
                                  onPressed: () async {
                                    if (await _checkPermissions()) {
                                      await splashController.startScanning();
                                    }
                                  },
                                ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            Get.back();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<bool>(
                  future: _checkPermissions(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.data == false) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Bluetooth and Location permissions are required',
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => _checkPermissions(),
                              child: const Text('Grant Permissions'),
                            ),
                          ],
                        ),
                      );
                    }

                    return Obx(() {
                      if (splashController.isScanning.value) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Scanning for printers...'),
                            ],
                          ),
                        );
                      }

                      if (splashController.devices.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                splashController.devicesMsg.value,
                                style: const TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  if (await _checkPermissions()) {
                                    await splashController.startScanning();
                                  }
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Scan Again'),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: splashController.devices.length,
                        padding: const EdgeInsets.all(8),
                        itemBuilder: (context, index) {
                          final device = splashController.devices[index];
                          final name = device.localName.isNotEmpty
                              ? device.localName
                              : 'Unknown Device';

                          final isSelected = device.id.toString() ==
                              splashController.savedPrinterId.value;

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: Radio<String>(
                                value: device.id.toString(),
                                groupValue:
                                    splashController.savedPrinterId.value,
                                onChanged: (String? value) async {
                                  if (value != null) {
                                    await splashController
                                        .saveSelectedPrinter(device);
                                  }
                                },
                              ),
                              title: Text(name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(device.id.toString()),
                                  if (isSelected)
                                    const Text(
                                      'Saved Printer',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('${device.remoteId}'),
                                  const SizedBox(width: 8),
                                  Obx(() => splashController.isConnected.value
                                      ? const Icon(Icons.check_circle,
                                          color: Colors.green)
                                      : const Icon(Icons.circle_outlined)),
                                ],
                              ),
                              onTap: () async {
                                try {
                                  // Save the selected printer
                                  await splashController
                                      .saveSelectedPrinter(device);

                                  // Show connecting dialog
                                  Get.dialog(
                                    Material(
                                      type: MaterialType.transparency,
                                      child: Center(
                                        child: Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              CircularProgressIndicator(),
                                              SizedBox(height: 16),
                                              Text('Connecting to printer...'),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    barrierDismissible: false,
                                  );

                                  // Connect to printer
                                  await splashController
                                      .connectToPrinter(device);

                                  // Close all dialogs
                                  while (Get.isDialogOpen ?? false) {
                                    Get.back();
                                  }

                                  // Show success message
                                  Get.snackbar(
                                    'Success',
                                    'Printer connected successfully',
                                    snackPosition: SnackPosition.TOP,
                                    backgroundColor: Colors.green[100],
                                    colorText: Colors.green[900],
                                  );
                                } catch (e) {
                                  // Close dialog if open
                                  if (Get.isDialogOpen ?? false) {
                                    Get.back();
                                  }

                                  Get.snackbar(
                                    'Error',
                                    'Failed to connect: ${e.toString()}',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.red[100],
                                    colorText: Colors.red[900],
                                    duration: const Duration(seconds: 5),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      );
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
