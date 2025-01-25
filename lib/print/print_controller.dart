import 'package:get/get.dart';
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';

class PrintController extends GetxController {
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  RxList<BluetoothDevice> devices = <BluetoothDevice>[].obs;
  RxString devicesMsg = "".obs;
  RxBool isConnected = false.obs;

  @override
  void onInit() {
    super.onInit();
    startScanning();
  }

  Future<void> startScanning() async {
    try {
      await bluetoothPrint.startScan(timeout: const Duration(seconds: 10));

      bluetoothPrint.scanResults.listen((val) {
              devices(val);
              if (devices.isEmpty) {
                devicesMsg("No Devices Found");
              }
            },
          );
    } catch (e) {
      print(e);
    }
  }

  Future<void> connectToPrinter(BluetoothDevice device) async {
    if (device.address != null) {
      await bluetoothPrint.connect(device);
      isConnected(true);
    }
  }

  Future<void> printData(List<Map<String, dynamic>> data) async {
    if (isConnected.value) {
      Map<String, dynamic> config = Map();
      List<LineText> list = [];

      // Add header
      list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: "Grocery App",
        weight: 2,
        width: 2,
        height: 2,
        align: LineText.ALIGN_CENTER,
        linefeed: 1,
      ));

      // Add items
      for (var i = 0; i < data.length; i++) {
        list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: data[i]['title'],
          weight: 0,
          align: LineText.ALIGN_LEFT,
          linefeed: 1,
        ));
      }

      // Start printing
      await bluetoothPrint.printReceipt(config, list);
    }
  }

  @override
  void onClose() {
    bluetoothPrint.stopScan();
    super.onClose();
  }
}
