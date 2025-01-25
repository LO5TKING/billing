import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'print_controller.dart';

class PrintPage extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const PrintPage({Key? key, required this.data}) : super(key: key);

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

    return WillPopScope(
      onWillPop: () async {
        controller.onClose();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Select Printer'),
          backgroundColor: Colors.redAccent,
          actions: [
            Obx(() => controller.isScanning.value
                ? const SizedBox(
              width: 40,
              height: 40,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
                : IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () async {
                if (await _checkPermissions()) {
                  controller.initBluetooth();
                }
              },
            ),
            ),
          ],
        ),
        body: FutureBuilder<bool>(
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
                itemBuilder: (context, index) {
                  final scanResult = controller.devices[index];
                  final device = scanResult.device;
                  final name = device.localName.isNotEmpty
                      ? device.localName
                      : scanResult.advertisementData.localName.isNotEmpty
                      ? scanResult.advertisementData.localName
                      : 'Unknown Device';

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : const Icon(Icons.circle_outlined)),
                        ],
                      ),
                      onTap: () async {
                        try {
                          // Show connecting dialog
                          Get.dialog(
                            WillPopScope(
                              onWillPop: () async => false,
                              child: const Dialog(
                                backgroundColor: Colors.white,
                                child: Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Column(
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

                          // Close dialog
                          if (Get.isDialogOpen ?? false) {
                            Get.back();
                          }

                          // Navigate back to previous screen
                          Get.back();

                          // Show success message
                          Get.snackbar(
                            'Success',
                            'Printing completed',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.green[100],
                            colorText: Colors.green[900],
                          );

                          // Wait a brief moment for the snackbar to be visible
                          await Future.delayed(const Duration(milliseconds: 500));

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
    );
  }
}