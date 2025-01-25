import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'print_controller.dart'; // Import the controller

class PrintPage extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  PrintPage(this.data);

  @override
  Widget build(BuildContext context) {
    final PrintController controller = Get.put(PrintController());

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Printer'),
        backgroundColor: Colors.redAccent,
      ),
      body: Obx(
            () {
          // Display message if no devices are found
          if (controller.devices.isEmpty) {
            return Center(
              child: Text(controller.devicesMsg.value),
            );
          }

          return ListView.builder(
            itemCount: controller.devices.length,
            itemBuilder: (context, index) {
              final device = controller.devices[index];

              return ListTile(
                leading: Icon(Icons.print),
                title: Text(device.name ?? ''),
                subtitle: Text(device.address ?? ''),
                onTap: () {
                  controller.connectToPrinter(device);
                  controller.printData(data);
                },
              );
            },
          );
        },
      ),
    );
  }
}
