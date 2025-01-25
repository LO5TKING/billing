import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'print_controller.dart';

class PrintPage extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const PrintPage({Key? key, required this.data}) : super(key: key);

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
              onPressed: () => controller.startScanning(),
            ),
            ),
          ],
        ),
        body: Obx(() {
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
                    onPressed: () => controller.startScanning(),
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

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: const Icon(Icons.print),
                  title: Text(device.name.isNotEmpty ? device.name : 'Unknown Device'),
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

                      Get.snackbar(
                        'Success',
                        'Printing completed',
                        snackPosition: SnackPosition.BOTTOM,
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
        }),
      ),
    );
  }
}