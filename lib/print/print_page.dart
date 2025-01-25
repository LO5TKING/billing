import 'package:billing/app/config/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'print_controller.dart';

class PrintDialog extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const PrintDialog({Key? key, required this.data}) : super(key: key);

  static Future<void> show(List<Map<String, dynamic>> data) async {
    await Get.dialog(
      PrintDialog(data: data),
      barrierDismissible: true,
    );
  }

  Future<bool> _checkPermissions() async {
    if (GetPlatform.isAndroid) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
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
    final PrintController controller = Get.put(PrintController());

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
                  borderRadius: BorderRadius.only(
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
                        Obx(() => controller.isScanning.value
                            ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                            : IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          onPressed: () async {
                            if (await _checkPermissions()) {
                              controller.initBluetooth();
                            }
                          },
                        ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            controller.onClose();
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
                      if (controller.isScanning.value) {
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

                      if (controller.devices.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                controller.devicesMsg.value,
                                style: const TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  if (await _checkPermissions()) {
                                    controller.initBluetooth();
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
                        itemCount: controller.devices.length,
                        padding: const EdgeInsets.all(8),
                        itemBuilder: (context, index) {
                          final scanResult = controller.devices[index];
                          final device = scanResult.device;
                          final name = device.localName.isNotEmpty
                              ? device.localName
                              : scanResult.advertisementData.localName.isNotEmpty
                              ? scanResult.advertisementData.localName
                              : 'Unknown Device';

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: const Icon(Icons.print),
                              title: Text(name),
                              subtitle: Text(device.id.toString()),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('${scanResult.rssi} dBm'),
                                  const SizedBox(width: 8),
                                  Obx(() => controller.isConnected.value
                                      ? const Icon(Icons.check_circle,
                                      color: Colors.green)
                                      : const Icon(Icons.circle_outlined)),
                                ],
                              ),
                              onTap: () async {
                                try {
                                  // Show connecting dialog
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

                                  // Connect and print
                                  await controller.connectAndPrint(device, data);

                                  // Close all dialogs
                                  while (Get.isDialogOpen ?? false) {
                                    Get.back();
                                  }

                                  // Show success message
                                  Get.snackbar(
                                    'Success',
                                    'Printing completed',
                                    snackPosition: SnackPosition.TOP,
                                    backgroundColor: Colors.green[100],
                                    colorText: Colors.green[900],
                                  );

                                  await Future.delayed(
                                      const Duration(milliseconds: 500));
                                } catch (e) {
                                  // Close dialog if open
                                  if (Get.isDialogOpen ?? false) {
                                    Get.back();
                                  }

                                  Get.snackbar(
                                    'Error',
                                    'Failed to print: ${e.toString()}',
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