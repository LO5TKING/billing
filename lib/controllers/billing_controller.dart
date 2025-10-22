import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:billing/model/order_detail_response_model.dart';
import 'package:billing/model/report_response_model.dart';
import 'package:flutter/gestures.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:billing/app/config/color_constants.dart';
import 'package:billing/ui/billing/billing.dart';
import 'package:flutter/material.dart' hide Ink;
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app/config/constants_text.dart';
import '../model/customer_response_model.dart';
import '../networks/api_service.dart';
import '../utils/activity_indicator.dart';
import 'package:flutter/services.dart'; // Import this package
import '../print/print_controller.dart';
import 'package:image/image.dart' as img;
import 'dart:convert';

import '../utils/shared_pref.dart';

class BillingController extends GetxController {
  var itemList = <Map<String, dynamic>>[].obs;

  final DigitalInkRecognizerModelManager modelManager =
      DigitalInkRecognizerModelManager();
  final String language = 'en-US';
  late final DigitalInkRecognizer digitalInkRecognizer =
      DigitalInkRecognizer(languageCode: language);
  final Ink rateInk = Ink();
  final Ink quantityInk = Ink();
  final Ink descriptionInk = Ink();
  List<StrokePoint> ratePoints = [];
  List<StrokePoint> descriptionPoints = [];
  List<StrokePoint> quantityPoints = [];
  String recognizedRate = '';
  String recognizedQuantity = '';
  RxBool showButtons = false.obs;
  RxBool loadingClient = true.obs;
  RxBool updateBill = false.obs;
  RxBool showPaymentDialog = false.obs;
  Rx<CustomerResponseModel?> customerResponse = Rx<CustomerResponseModel?>(null);
  RxList<Datum> filteredClientList = <Datum>[].obs;
  List<Datum> get clientList => filteredClientList;
  Rx<OrderDeatailsResponseModel?> orderDetailResponse = Rx<OrderDeatailsResponseModel?>(null);
  Rx<OrderDeatailsResponseModel?> oldOrderDetailResponse = Rx<OrderDeatailsResponseModel?>(null);

  //for editing the details
  // Add these variables to your controller
  String currentOrderNo = '';
  int currentBillingId = 0;
  int currentCustomerId = 0;
  String currentCustomerName = '';
  Rx<BillingReport?> ourReport = Rx<BillingReport?>(null);




  ApiService apiService = ApiService();

  RxBool isModelLoading = false.obs;
  RxString downloadStatus = ''.obs;

  // Inject the PrintController
  late PrintController printController;

  final RxBool isPrinting = false.obs;

  final RxString formattedDateTime = ''.obs;
  Timer? _dateTimeTimer;

  final Ink editRateInk = Ink();
  final Ink editQuantityInk = Ink();
  String recognizedEditRate = '';
  String recognizedEditQuantity = '';

  TextEditingController amountPaid = TextEditingController();
  TextEditingController discountAmount = TextEditingController();

  Future<bool> _downloadModelWithTimeout() async {
    try {
      // Create a timeout future
      final timeout = Future.delayed(const Duration(seconds: 30), () {
        throw TimeoutException('Model download took too long');
      });

      // Create the download future
      final download = modelManager.downloadModel(language);

      // Race between timeout and download
      final result = await Future.any([download, timeout]);
      return result;
    } on TimeoutException {
      throw 'Download timed out. Please check your internet connection and try again.';
    } catch (e) {
      throw 'Failed to download model: $e';
    }
  }

  Future<void> requestStoragePermissionOnStart() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  @override
  void onInit() async {
    super.onInit();

    // Request storage permission at app start
    await requestStoragePermissionOnStart();

    // Initialize PrintController using lazyPut to prevent multiple instances
    if (!Get.isRegistered<PrintController>()) {
      Get.lazyPut(() => PrintController(), fenix: true);
    }
    printController = Get.find<PrintController>();

    // Start the date time update timer
    _updateDateTime();
    _dateTimeTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => _updateDateTime());

    try {
      clearPadAndSignature();

      // Check if model is already downloaded (including local cache check)
      bool downloadedModel = await isModelDownloaded();

      if (downloadedModel) {
        // Model is already downloaded, do nothing
        return;
      }

      // Only show loading for new downloads
      isModelLoading(true);
      downloadStatus('Downloading recognition model...');

      try {
        // Try to download with timeout
        bool success = await _downloadModelWithTimeout();
        if (success) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('model_downloaded_$language', true);
        } else {
          throw 'Failed to download model';
        }
      } catch (e) {
        print('Model download error: $e');
        // Show error dialog only for download failures
        Get.dialog(
          AlertDialog(
            title: const Text('Model Download Error'),
            content: Text(
                'Could not download the handwriting recognition model: $e\n\nYou can still use the app, but handwriting recognition might not work properly.'),
            actions: [
              TextButton(
                child: const Text('Retry'),
                onPressed: () {
                  Get.back();
                  onInit(); // Retry initialization
                },
              ),
              TextButton(
                child: const Text('Continue Anyway'),
                onPressed: () {
                  Get.back();
                },
              ),
            ],
          ),
          barrierDismissible: false,
        );
      } finally {
        isModelLoading(false);
        downloadStatus('');
      }
    } catch (e) {
      // Show error dialog only for critical initialization errors
      Get.dialog(
        AlertDialog(
          title: const Text('Initialization Error'),
          content: Text(
              'Error initializing app: $e\n\nYou can still use basic features of the app.'),
          actions: [
            TextButton(
              child: const Text('Retry'),
              onPressed: () {
                Get.back();
                onInit(); // Retry initialization
              },
            ),
            TextButton(
              child: const Text('Continue Anyway'),
              onPressed: () {
                Get.back();
              },
            ),
          ],
        ),
        barrierDismissible: false,
      );
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    _dateTimeTimer?.cancel();
    digitalInkRecognizer.close();
    super.onClose();
  }

  void clearPad() {
    rateInk.strokes.clear();
    ratePoints.clear();
    quantityInk.strokes.clear();
    quantityPoints.clear();
    descriptionInk.strokes.clear();
    descriptionPoints.clear();
    recognizedRate = '';
    recognizedQuantity = '';
    update();
  }

  Future<bool> isModelDownloaded() async {
    try {
      // Check if we have a locally cached result first
      final prefs = await SharedPreferences.getInstance();
      bool previouslyDownloaded =
          prefs.getBool('model_downloaded_$language') ?? false;

      // If we previously downloaded it and there's no internet, return true
      if (previouslyDownloaded) {
        try {
          // Still try to check with Google, but if it fails, assume it's downloaded
          bool isDownloaded = await modelManager.isModelDownloaded(language);
          return isDownloaded;
        } catch (e) {
          print(
              'Error checking if model is downloaded, but we know it was previously downloaded: $e');
          return true; // Assume it's still there if previously downloaded
        }
      }

      // First time, we need to actually check
      bool isDownloaded = await modelManager.isModelDownloaded(language);

      // If it's downloaded, save that information for future offline use
      if (isDownloaded) {
        await prefs.setBool('model_downloaded_$language', true);
      }

      return isDownloaded;
    } catch (e) {
      print('Error checking if model is downloaded: $e');
      // If there's an error checking (likely due to no internet),
      // assume the model is already downloaded if we've previously downloaded it
      final prefs = await SharedPreferences.getInstance();
      bool previouslyDownloaded =
          prefs.getBool('model_downloaded_$language') ?? false;
      return previouslyDownloaded;
    }
  }

  Future<void> deleteModel() async {
    Toast().show(
      'Deleting model...',
      modelManager
          .deleteModel(language)
          .then((value) => value ? 'success' : 'failed'),
      Get.context!,
    );
  }

  Future<void> downloadModel() async {
    Toast().show(
      'Downloading model...',
      modelManager
          .downloadModel(language)
          .then((value) => value ? 'success' : 'failed'),
      Get.context!,
    );
  }

  Future<void> recogniseRateText() async {
    try {
      final candidates = await digitalInkRecognizer.recognize(rateInk);

      // Initialize recognizedRate as empty
      recognizedRate = '';

      if (candidates.isNotEmpty) {
        var text = candidates[0].text;

        // Perform replacements and assign them back to `text`
        text = text
            .toUpperCase()
            .replaceAll('O', '0')
            .replaceAll('I', '1')
            .replaceAll('L', '1')
            .replaceAll('U', '4')
            .replaceAll('A', '4')
            .replaceAll('Z', '2')
            .replaceAll('\\', '1')
            .replaceAll('/', '1')
            .replaceAll('H', '4')
            .replaceAll('B', '3')
            .replaceAll('S', '5')
            .replaceAll('Z', '2')
            .replaceAll('T', '7');

        recognizedRate = text.replaceAll(RegExp(r'[^0-9.]'), '');

        // If no digits are found after cleaning, set as 'No'
        if (recognizedRate.isEmpty) {
          rateInk.strokes.clear();
          ratePoints.clear();
          Get.snackbar("Error", "Rate Not Recognized");

          // recognizedRate = 'No';
        }
      } else {
        recognizedRate = 'No candidates recognized';
      }

      update();
    } catch (e) {}
  }

  Future<void> recogniseQuantityText() async {
    try {
      final candidates = await digitalInkRecognizer.recognize(quantityInk);

      recognizedQuantity = ''; // Initialize recognizedQuantity

      if (candidates.isNotEmpty) {
        var text = candidates[0].text;

        // Perform replacements and assign them back to `text`
        text = text
            .toUpperCase()
            .replaceAll('O', '0')
            .replaceAll('I', '1')
            .replaceAll('L', '1')
            .replaceAll('U', '4')
            .replaceAll('A', '4')
            .replaceAll('Z', '2')
            .replaceAll('\\', '1')
            .replaceAll('/', '1')
            .replaceAll('H', '4')
            .replaceAll('B', '3')
            .replaceAll('S', '5')
            .replaceAll('Z', '2')
            .replaceAll('T', '7');

        recognizedQuantity = text.replaceAll(RegExp(r'[^0-9.]'), '');

        // If no digits are found after cleaning, set as 'No'
        if (recognizedQuantity.isEmpty) {
          // recognizedQuantity = 'No';
          quantityInk.strokes.clear();
          quantityPoints.clear();
          Get.snackbar("Error", "Quantity Not Recognized");
        }
      } else {
        recognizedQuantity = 'No candidates recognized';
      }

      update();
    } catch (e) {
      // Error handling
    }
  }

  Future<Uint8List?> convertToPngBytes(double width, double height) async {
    // Increase the size by 50% for better visibility
    width = width * 1.5;
    height = height * 1.5;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromPoints(Offset.zero, Offset(width, height)),
    );

    // Set white background
    final Paint bgPaint = Paint()..color = AppColors.peachColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), bgPaint);

    // Draw the handwriting with thicker black strokes
    for (final stroke in descriptionInk.strokes) {
      final paint = Paint()
        ..color = AppColors.stainedGlass
        ..strokeWidth = 6.0 // Increased stroke width for bolder appearance
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      if (stroke.points.length == 1) {
        canvas.drawCircle(
          Offset(stroke.points[0].x * 1.5,
              stroke.points[0].y * 1.5), // Scale the points
          3.0, // Increased circle size
          paint,
        );
      } else {
        // For multiple points, create a smooth path
        final path = Path();
        path.moveTo(stroke.points[0].x * 1.5,
            stroke.points[0].y * 1.5); // Scale the points

        for (int i = 0; i < stroke.points.length - 1; i++) {
          final p0 = stroke.points[i];
          final p1 = stroke.points[i + 1];

          path.quadraticBezierTo(
            p0.x * 1.5, // Scale the points
            p0.y * 1.5,
            (p0.x + p1.x) / 2 * 1.5,
            (p0.y + p1.y) / 2 * 1.5,
          );
        }

        canvas.drawPath(path, paint);
      }
    }

    final ui.Image image = await recorder.endRecording().toImage(
          width.toInt(),
          height.toInt(),
        );

    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    return byteData?.buffer.asUint8List();
  }

  Future<void> addItem() async {
    // ⭐ CHECK BEFORE ANYTHING
    print('\n=== BEFORE addItem() - CHECK ITEMLIST ===');
    for (int i = 0; i < itemList.length; i++) {
      print('Item $i: orderDetailsId=${itemList[i]['orderDetailsId']}, billingId=${itemList[i]['billingId']}');
    }

    await recogniseRateText();

    // ⭐ CHECK AFTER recogniseRateText()
    print('\n=== AFTER recogniseRateText() ===');
    for (int i = 0; i < itemList.length; i++) {
      print('Item $i: orderDetailsId=${itemList[i]['orderDetailsId']}, billingId=${itemList[i]['billingId']}');
    }

    await recogniseQuantityText();

    // ⭐ CHECK AFTER recogniseQuantityText()
    print('\n=== AFTER recogniseQuantityText() ===');
    for (int i = 0; i < itemList.length; i++) {
      print('Item $i: orderDetailsId=${itemList[i]['orderDetailsId']}, billingId=${itemList[i]['billingId']}');
    }

    Uint8List? particularImage = await convertToPngBytes(
      Get.width * 0.8,
      85,
    );

    // ⭐ CHECK AFTER convertToPngBytes()
    print('\n=== AFTER convertToPngBytes() ===');
    for (int i = 0; i < itemList.length; i++) {
      print('Item $i: orderDetailsId=${itemList[i]['orderDetailsId']}, billingId=${itemList[i]['billingId']}');
    }

    if (particularImage != null &&
        recognizedQuantity.isNotEmpty &&
        recognizedRate.isNotEmpty) {

      // ⭐ CREATE NEW ITEM WITH EXPLICIT VALUES
      final Map<String, dynamic> newItem = {
        'particulars': particularImage,
        'productName': '',
        'quantity': recognizedQuantity,
        'rate': recognizedRate,
        'orderDetailsId': 0,
        'billingId': updateBill.value ? currentBillingId : 0,
        'orderNo': updateBill.value ? currentOrderNo : '',
        'customerId': updateBill.value ? currentCustomerId : 0,
      };

      itemList.add(newItem);

      print('=== NEW ITEM ADDED ===');
      print('orderDetailsId: ${newItem['orderDetailsId']}');
      print('billingId: ${newItem['billingId']}');

      // ⭐ CHECK AFTER ADDING
      print('\n=== AFTER ADDING TO LIST ===');
      for (int i = 0; i < itemList.length; i++) {
        print('Item $i: orderDetailsId=${itemList[i]['orderDetailsId']}, billingId=${itemList[i]['billingId']}');
      }

      clearPadAndSignature();

      // ⭐ CHECK AFTER clearPadAndSignature() - THIS IS LIKELY THE CULPRIT
      print('\n=== AFTER clearPadAndSignature() ===');
      for (int i = 0; i < itemList.length; i++) {
        print('Item $i: orderDetailsId=${itemList[i]['orderDetailsId']}, billingId=${itemList[i]['billingId']}');
      }

      itemList.refresh();

      // ⭐ CHECK AFTER refresh()
      print('\n=== AFTER itemList.refresh() ===');
      for (int i = 0; i < itemList.length; i++) {
        print('Item $i: orderDetailsId=${itemList[i]['orderDetailsId']}, billingId=${itemList[i]['billingId']}');
      }

      update();

      // ⭐ FINAL CHECK
      print('\n=== ALL ITEMS AFTER ADDING NEW ===');
      for (int i = 0; i < itemList.length; i++) {
        print('Item $i: orderDetailsId=${itemList[i]['orderDetailsId']}, billingId=${itemList[i]['billingId']}');
      }
    } else {
      Get.snackbar("Error", "Field is Empty");
    }
  }


  Future<List<ui.Image>> generateReceiptImages(
      List<Map<String, dynamic>> itemList) async {
    List<ui.Image> images = [];
    for (var item in itemList) {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Convert Uint8List to ui.Image
      if (item['particulars'] is Uint8List) {
        final codec =
            await ui.instantiateImageCodec(item['particulars'] as Uint8List);
        final frameInfo = await codec.getNextFrame();
        final handwrittenImage = frameInfo.image;

        final completeRowImage = await createCompleteRowImage(
            (itemList.indexOf(item) + 1).toString(),
            handwrittenImage,
            item['quantity'].toString(),
            item['rate'].toString(),
            (double.parse(item['quantity']) * double.parse(item['rate']))
                .toString());
        images.add(completeRowImage);
      }
    }
    return images;
  }


  double get totalAmount {
    return itemList.fold(0, (sum, item) {
      final rate = double.tryParse(item['rate']) ?? 0;
      final quantity = double.tryParse(item['quantity']) ?? 0;
      return sum + (rate * quantity);
    });
  }

  double get totalQty {
    return itemList.fold(0, (sum, item) {
      final quantity = double.tryParse(item['quantity'] ?? '0') ?? 0;
      return sum + (quantity);
    });
  }

  void clearPadAndSignature() {
    clearPad();
  }

  Future<OrderDeatailsResponseModel?> getBillingDetail(BillingReport billDetail) async {
    String url = "https://roughbill.com/api/Report/GetOrderDetails?billingId=${billDetail.billingId}&orderNo=${billDetail.orderNo}&clientId=${billDetail.clientId}&clientUserId=${billDetail.clientUserId}";

    try {
      var response = await apiService.getRequest(url: url);

      if (response.statusCode == 200) {
        orderDetailResponse.value = orderDeatailsResponseModelFromJson(response.body);
        // prepareItemListForUpdate();
        return orderDetailResponse.value ;
      } else {
        orderDetailResponse.value = null;
        Get.snackbar(
          'Error',
          'Failed to get order details',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e,s) {
      orderDetailResponse.value = null;
      print("Error parsing order data: $e $s");
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }


  void editItem(int index) {
    final item = itemList[index];

    // Reset the edit ink objects and recognized values
    editRateInk.strokes.clear();
    editQuantityInk.strokes.clear();
    recognizedEditRate = item['rate'];
    recognizedEditQuantity = item['quantity'];

    Get.defaultDialog(
      title: 'Edit Item',
      barrierDismissible: false,
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: [
              // Quantity handwriting box
              Text('Quantity $recognizedEditQuantity', style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold)),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 75,
                    width: Get.width * 0.6,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.blueGradient),
                    ),
                    child: ClipRRect(
                      child: Builder(  // Add Builder widget here
                        builder: (quantityContext) => Listener(
                          onPointerDown: (event) {
                            if (event.kind == PointerDeviceKind.stylus ||
                                event.kind == PointerDeviceKind.touch) {
                              editQuantityInk.strokes.add(Stroke());
                              setState(() {});
                            }
                          },
                          onPointerMove: (event) {
                            if (event.kind == PointerDeviceKind.stylus ||
                                event.kind == PointerDeviceKind.touch) {
                              final RenderObject? object = quantityContext.findRenderObject();  // Use quantityContext
                              final localPosition =
                              (object as RenderBox?)?.globalToLocal(event.position);
                              if (localPosition != null &&
                                  editQuantityInk.strokes.isNotEmpty) {
                                editQuantityInk.strokes.last.points.add(
                                  StrokePoint(
                                    x: localPosition.dx,
                                    y: localPosition.dy,
                                    t: DateTime.now().millisecondsSinceEpoch,
                                  ),
                                );
                                setState(() {});
                              }
                            }
                          },
                          onPointerUp: (event) {
                            setState(() {});
                          },
                          child: CustomPaint(
                            painter: SignatureStyle(ink: editQuantityInk),
                            size: Size.infinite,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -0,
                    right: -0,
                    child: GestureDetector(
                      onTap: () {
                        editQuantityInk.strokes.clear();
                        setState(() {});
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.cancel_outlined, color: AppColors.blackLead),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -0,
                    right: -0,
                    child: GestureDetector(
                      onTap: () async {
                        try {
                          final candidates = await digitalInkRecognizer.recognize(editQuantityInk);
                          if (candidates.isNotEmpty) {
                            var text = candidates[0].text;
                            text = text
                                .toUpperCase()
                                .replaceAll('O', '0')
                                .replaceAll('I', '1')
                                .replaceAll('L', '1')
                                .replaceAll('U', '4')
                                .replaceAll('A', '4')
                                .replaceAll('Z', '2')
                                .replaceAll('\\', '1')
                                .replaceAll('/', '1')
                                .replaceAll('H', '4')
                                .replaceAll('B', '3')
                                .replaceAll('S', '5')
                                .replaceAll('Z', '2')
                                .replaceAll('T', '7');

                            recognizedEditQuantity = text.replaceAll(RegExp(r'[^0-9.]'), '');
                            if (recognizedEditQuantity.isEmpty) {
                              Get.snackbar("Error", "Quantity Not Recognized");
                            }
                          } else {
                            Get.snackbar("Error", "No candidates recognized");
                          }
                          setState(() {});
                        } catch (e) {
                          Get.snackbar("Error", "Recognition failed: $e");
                        }
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.blueGradient,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Icons.check, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              const SizedBox(height: 20),

              // Rate handwriting box
              Text('Rate $recognizedEditRate', style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold)),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 75,
                    width: Get.width * 0.6,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.blueGradient),
                    ),
                    child: ClipRRect(
                      child: Builder(  // Add Builder widget here
                        builder: (rateContext) => Listener(
                          onPointerDown: (event) {
                            if (event.kind == PointerDeviceKind.stylus ||
                                event.kind == PointerDeviceKind.touch) {
                              editRateInk.strokes.add(Stroke());
                              setState(() {});
                            }
                          },
                          onPointerMove: (event) {
                            if (event.kind == PointerDeviceKind.stylus ||
                                event.kind == PointerDeviceKind.touch) {
                              final RenderObject? object = rateContext.findRenderObject();  // Use rateContext
                              final localPosition =
                              (object as RenderBox?)?.globalToLocal(event.position);
                              if (localPosition != null &&
                                  editRateInk.strokes.isNotEmpty) {
                                editRateInk.strokes.last.points.add(
                                  StrokePoint(
                                    x: localPosition.dx,
                                    y: localPosition.dy,
                                    t: DateTime.now().millisecondsSinceEpoch,
                                  ),
                                );
                                setState(() {});
                              }
                            }
                          },
                          onPointerUp: (event) {
                            setState(() {});
                          },
                          child: CustomPaint(
                            painter: SignatureStyle(ink: editRateInk),
                            size: Size.infinite,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -0,
                    right: -0,
                    child: GestureDetector(
                      onTap: () {
                        editRateInk.strokes.clear();
                        setState(() {});
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.cancel_outlined, color: AppColors.blackLead),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -0,
                    right: -0,
                    child: GestureDetector(
                      onTap: () async {
                        try {
                          final candidates = await digitalInkRecognizer.recognize(editRateInk);
                          if (candidates.isNotEmpty) {
                            var text = candidates[0].text;
                            text = text
                                .toUpperCase()
                                .replaceAll('O', '0')
                                .replaceAll('I', '1')
                                .replaceAll('L', '1')
                                .replaceAll('U', '4')
                                .replaceAll('A', '4')
                                .replaceAll('Z', '2')
                                .replaceAll('\\', '1')
                                .replaceAll('/', '1')
                                .replaceAll('H', '4')
                                .replaceAll('B', '3')
                                .replaceAll('S', '5')
                                .replaceAll('Z', '2')
                                .replaceAll('T', '7');

                            recognizedEditRate = text.replaceAll(RegExp(r'[^0-9.]'), '');
                            if (recognizedEditRate.isEmpty) {
                              Get.snackbar("Error", "Rate Not Recognized");
                            }
                          } else {
                            Get.snackbar("Error", "No candidates recognized");
                          }
                          setState(() {});
                        } catch (e) {
                          Get.snackbar("Error", "Recognition failed: $e");
                        }
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.blueGradient,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Icons.check, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          );
        },
      ),
      textConfirm: 'Save',
      textCancel: 'Cancel',
      onCancel: () {
        Get.back();
      },
      onConfirm: () {
        if (recognizedEditQuantity.isNotEmpty && recognizedEditRate.isNotEmpty) {
          itemList[index]['quantity'] = recognizedEditQuantity;
          itemList[index]['rate'] = recognizedEditRate;
          update();
          Get.back();
        } else {
          Get.snackbar("Error", "Quantity and Rate cannot be empty");
        }
      },
    );
  }

  void deleteItem(int index) {
    itemList.removeAt(index);
    update();
  }

  // Add a method to print PDF receipts with dialog
  Future<void> printPdfReceipt(Datum? customer) async {
    if (isPrinting.value) return;

    if (itemList.isEmpty) {
      Get.snackbar('Error', 'No items to print');
      return;
    }

    // Variables for the dialog
    double discountAmount = 0;
    double amountToBePaid = showPaymentDialog.value ? ourReport.value?.totalAmount ?? 0 : totalAmount;
    double balanceAmount = showPaymentDialog.value ? ourReport.value?.balanceAmount ?? 0 : 0;
    String discountType = 'Flat'; // 'Flat' or 'Percentage'
    double? paidAmount = (ourReport.value?.totalAmount ?? 0) - (ourReport.value?.balanceAmount ?? 0);

    amountPaid.text = showPaymentDialog.value ? (paidAmount != 0 ? paidAmount.toString() : "0") : totalAmount.toString();
    Get.defaultDialog(
      title: 'Payment Details',
      barrierDismissible: false,
      content: StatefulBuilder(
        builder: (context, setState) {
          // Calculate amounts based on current values
          double calculatedTotal = totalAmount;
          double finalAmount = calculatedTotal;

          // Apply discount based on type
          if (discountType == 'Percentage' && discountAmount > 0) {
            finalAmount = calculatedTotal - (calculatedTotal * discountAmount / 100);
          } else if (discountType == 'Flat') {
            finalAmount = calculatedTotal - discountAmount;
          }

          // Ensure final amount is not negative
          finalAmount = finalAmount < 0 ? 0 : finalAmount;

          // Calculate balance
          balanceAmount = showPaymentDialog.value ? ourReport.value?.balanceAmount ?? 0 : finalAmount - amountToBePaid;
          balanceAmount = balanceAmount < 0 ? 0 : balanceAmount;
          return Container(
            width: Get.width * 0.8,
            padding: const EdgeInsets.all(20),
            child: Table(
              columnWidths: const {
                0: FixedColumnWidth(150),   // Fixed label width
                1: FixedColumnWidth(150),      // Remaining space for inputs/values
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [

                // Total Amount
                TableRow(children: [
                  const Text('Total Amount:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Container(
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 0.5),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('₹ ${calculatedTotal.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ]),

                const TableRow(children: [SizedBox(height: 12), SizedBox(height: 12)]),

                // Discount Type
                TableRow(children: [
                  const Text('Discount Type:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Row(
                        children: [
                          Radio(
                            value: 'Flat',
                            groupValue: discountType,
                            onChanged: (value) {
                              setState(() {
                                discountType = value.toString();
                                discountAmount = 0;
                              });
                            },
                          ),
                          const Text('Flat Amount'),
                        ],
                      ),
                      Row(
                        children: [
                          Radio(
                            value: 'Percentage',
                            groupValue: discountType,
                            onChanged: (value) {
                              setState(() {
                                discountType = value.toString();
                                discountAmount = 0;
                              });
                            },
                          ),
                          const Text('Percentage'),
                        ],
                      ),
                    ],
                  )
                ]),

                const TableRow(children: [SizedBox(height: 12), SizedBox(height: 12)]),

                // Discount Amount
                TableRow(children: [
                  Text(
                    discountType == 'Percentage' ? 'Discount %:' : 'Discount Amount:',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 100,
                    height: 40,
                    child: TextField(
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        prefixText: discountType == 'Percentage' ? '% ' : '₹ ',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      ),
                      onChanged: (value) {
                        setState(() {
                          discountAmount = double.tryParse(value) ?? 0;
                        });
                      },
                    ),
                  ),
                ]),

                const TableRow(children: [SizedBox(height: 12), SizedBox(height: 12)]),

                // Final Amount
                TableRow(children: [
                  const Text('Final Amount:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Container(
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 0.5),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text('₹ ${finalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.blueGradient)),
                  ),
                ]),

                const TableRow(children: [SizedBox(height: 12), SizedBox(height: 12)]),

                // Amount Paid
                TableRow(children: [
                  const Text('Amount Paid:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(
                    width: 100,
                    height: 40,
                    child: TextField(
                      controller: amountPaid,
                      textAlign: TextAlign.center,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixText: '₹ ',
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      ),
                      onChanged: (value) {
                        setState(() {
                          amountToBePaid = double.tryParse(value) ?? 0;
                        });
                      },
                    ),
                  )
                ]),

                const TableRow(children: [SizedBox(height: 12), SizedBox(height: 12)]),

                // Balance Amount
                TableRow(children: [
                  const Text('Balance Amount:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Container(
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 0.5),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text('₹ ${balanceAmount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  ),
                ]),
              ],
            ),
          );
        },
      ),
      actions: [
        GestureDetector(
          onTap: () async {
            await submitBillingData(
                customerId: customer?.custId,
                customerName: customer?.name,
                clientId: customer?.clientId,
            );
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(100)),
            child: const Text(
              "Save Reciept",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
        GestureDetector(
          onTap: () async {
            try {
              Get.back(); // Close dialog
              isPrinting.value = true;

              // Calculate final amount based on discount
              double finalAmount = totalAmount;
              if (discountType == 'Percentage' && discountAmount > 0) {
                finalAmount = totalAmount - (totalAmount * discountAmount / 100);
              } else if (discountType == 'Flat') {
                finalAmount = totalAmount - discountAmount;
              }
              finalAmount = finalAmount < 0 ? 0 : finalAmount;

              double actualDiscountAmount = discountType == 'Percentage' ?
              (totalAmount * discountAmount / 100) : discountAmount;

              await submitBillingData(
                  customerId: customer?.custId,
                  customerName: customer?.name,
                  clientId: customer?.clientId


              );
              await printController.printPdfReceipt(
                  itemList,
                  discountAmount: actualDiscountAmount,
                  amountPaid: amountToBePaid
              );

              Get.snackbar('Success', 'Receipt sent to printer');
              // await shopDetailApi(); // Update bill count
            } catch (e) {
              Get.snackbar("Error", "Failed to print: $e");
            } finally {
              isPrinting.value = false;
            }
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(100)),
            child: const Text(
              "Print Receipt",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(100)),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  void _updateDateTime() {
    final now = DateTime.now();
    formattedDateTime.value =
        "Date:- ${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year} "
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }

  // Future<void>shopDetailApi() async {
  //   String url = "https://roughbill.com/api/ShopDetail/BillCount";
  //   var detail = {
  //     // 'ShopName': "${ConstantsText.shopName}",
  //     'BillPrint': "1",
  //   };
  //
  //   final response = await apiService.postRequest(url: url, data: detail);
  //
  //   if (response.statusCode == 200) {
  //     print('Shop Detail Api Success: ${response.body}');
  //   } else {
  //     print('Error ${response.statusCode}: ${response.body}');
  //   }
  //
  //
  // }

  Future<File?> saveReceiptAsPdf() async {
    try {
      final pdf = pw.Document();

      // Load Ganesh logo as Uint8List
      final ByteData logoData = await rootBundle.load('assets/ganpati.png');
      final Uint8List logoBytes = logoData.buffer.asUint8List();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // Ganesh logo
                pw.Image(pw.MemoryImage(logoBytes), width: 50, height: 50),
                pw.SizedBox(height: 8),
                // Business details
                pw.Text(SharedPrefs.getString(ConstantsText.companyName) ?? "",
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 18)),
                pw.Text('${SharedPrefs.getString(ConstantsText.addresss) ?? ""}\n'),
                pw.Text('${SharedPrefs.getString(ConstantsText.mobileNumber) ?? ""}'),
                pw.SizedBox(height: 8),
                // Date and Time
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Date: ${DateTime.now().toString().split(' ')[0]}'),
                    pw.Text(
                        'Time: ${DateTime.now().toString().split(' ')[1].split('.').first}'),
                  ],
                ),
                pw.Divider(),
                // Table Header
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text('Sr',
                              textAlign: pw.TextAlign.center,
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text('Particulars',
                              textAlign: pw.TextAlign.center,
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text('Qty',
                              textAlign: pw.TextAlign.center,
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text('Rate',
                              textAlign: pw.TextAlign.center,
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text('Amt',
                              textAlign: pw.TextAlign.center,
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                    // Table Rows
                    ...itemList.asMap().entries.map((entry) {
                      int idx = entry.key;
                      var item = entry.value;
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text('${idx + 1}',
                                textAlign: pw.TextAlign.center),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: item['particulars'] != null
                                ? pw.Image(pw.MemoryImage(item['particulars']),
                                    height: 30)
                                : pw.Text(''),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(item['quantity'] ?? '',
                                textAlign: pw.TextAlign.center),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(item['rate'] ?? '',
                                textAlign: pw.TextAlign.center),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(
                              ((double.tryParse(item['quantity'] ?? '0') ?? 0) *
                                      (double.tryParse(item['rate'] ?? '0') ??
                                          0))
                                  .toStringAsFixed(0),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
                pw.Divider(),
                // Total
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text('TOTAL: ${totalAmount.toStringAsFixed(0)}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 16),
                // Footer
                pw.Text('Thank you for your business!'),
                pw.Text('Please visit again'),
              ],
            );
          },
        ),
      );

      // Request manage external storage permission for Android 14
      var status = await Permission.manageExternalStorage.request();

      if (status.isGranted) {
        final downloadsDir = Directory('/storage/emulated/0/Download');
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }

        final file = File(
          '${downloadsDir.path}/receipt_${DateTime.now().millisecondsSinceEpoch}.pdf',
        );
        await file.writeAsBytes(await pdf.save());
        Get.snackbar('Success', 'Receipt saved to Downloads folder');
        return file;
      } else if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to save receipt: $e');
    }
    return null;
  }


  String _convertImageToBase64(Uint8List? imageBytes) {
    if (imageBytes == null) return '';
    return base64Encode(imageBytes);
  }

  // Function to make billing API call

  Future<void> submitBillingData({
    String orderNo = '',
    int? customerId = 0,
    String? customerName = '',
    String? clientId = '',
    double discount = 0,
    double gst = 0,
    String discountType = 'Flat',
    double paidAmount = 0,
    String paidAmountType = 'Cash',
    String transactionNo = '',
    String referenceNo = '',
    String paymentStatus = 'Pending',
  }) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Use existing data if in update mode
      if (updateBill.value) {
        orderNo = currentOrderNo;
        customerId = customerId ?? currentCustomerId;
        customerName = customerName ?? currentCustomerName;

        print('=== UPDATE MODE ===');
        print('Using orderNo: $orderNo');
        print('Using billingId: $currentBillingId');
      } else {
        orderNo = DateTime.now().millisecondsSinceEpoch.toString();
        print('=== CREATE MODE ===');
        print('Generated orderNo: $orderNo');
      }

      final double calculatedTotal = totalAmount;
      final double balanceAmount = calculatedTotal - double.parse(amountPaid.text);
      final DateTime now = DateTime.now();
      final String formattedDate = now.toIso8601String();
      int? clientUserId = SharedPrefs.getInt(ConstantsText.clientUserId);
      String? clientIds = SharedPrefs.getString(ConstantsText.clientId);

      // Use stored billingId for update mode
      int billingsId = updateBill.value ? currentBillingId : 0;

      // ⭐ ADD THIS DEBUG PRINT HERE - RIGHT BEFORE THE LOOP
      print('\n=== ITEMLIST INSPECTION BEFORE LOOP ===');
      for (int i = 0; i < itemList.length; i++) {
        print('Item $i BEFORE loop:');
        print('  orderDetailsId: ${itemList[i]['orderDetailsId']}');
        print('  billingId: ${itemList[i]['billingId']}');
        print('  quantity: ${itemList[i]['quantity']}');
        print('  Map identity: ${itemList[i].hashCode}'); // Check if same object
      }

      if (itemList.isNotEmpty) {
        print('First item: orderDetailsId=${itemList[0]['orderDetailsId']}, billingId=${itemList[0]['billingId']}');
      }

      // Collect details
      List<Map<String, dynamic>> orderDetails = [];

      for (int i = 0; i < itemList.length; i++) {
        final item = itemList[i];
        final double qty = double.tryParse(item['quantity'] ?? '0') ?? 0;
        final double rate = double.tryParse(item['rate'] ?? '0') ?? 0;
        final double totalPrice = qty * rate;

        // Read IDs from item
        final int orderDetailsId = item['orderDetailsId'] ?? 0;
        final int billingId = item['billingId'] ?? 0;

        print('\n=== PROCESSING ITEM $i ===');
        print('orderDetailsId: $orderDetailsId');
        print('billingId: $billingId');
        print('quantity: $qty, rate: $rate');

        String productName = '';
        if (item['particulars'] is Uint8List) {
          productName = _convertImageToBase64(item['particulars']);
        } else {
          productName = item['productName'] ?? '';
        }

        orderDetails.add({
          "orderNo": orderNo,
          "orderDetailsId": orderDetailsId,
          "billingId": billingId,
          "customerId": customerId ?? 0,
          "clientId": clientIds ?? '0000',
          "customerName": customerName ?? "Guest",
          "productName": productName,
          "quantity": qty,
          "pricePerQuantity": rate,
          "totalPrice": totalPrice,
          "productType": "",
          "isDelete": false,
          "postedOn": formattedDate,
          "modifiedOn": formattedDate,
          "clientUserId": clientUserId
        });
      }

      // Prepare billing data
      Map<String, dynamic> billingData = {
        "oBilling": {
          "billingId": billingsId,
          "orderNo": orderNo,
          "customerId": customerId ?? 0,
          "customerName": customerName ?? "Guest",
          "clientId": clientIds ?? '0000',
          "totalAmount": calculatedTotal,
          "balanceAmount": balanceAmount,
          "discount": discount,
          "gst": gst,
          "discountType": discountType,
          "paidAmount": paidAmount,
          "paidAmountType": paidAmountType,
          "transactionNo": transactionNo,
          "referenceNo": referenceNo,
          "paymentStatus": paymentStatus,
          "paymentDate": formattedDate,
          "postedOn": formattedDate,
          "modifiedOn": formattedDate,
          "isDelete": false,
          "isRefund": false,
          "refundAmount": 0,
          "refundRemark": "",
          "refundType": "",
          "refundDate": null,
          "refundTransNo": "",
          "refundStatus": "",
          "clientUserId": clientUserId
        },
        "orderDetails": orderDetails
      };

      String url = updateBill.value
          ? "https://roughbill.com/api/Order/UpdateOrder"
          : "https://roughbill.com/api/Order/addorder";

      print('\n=== FINAL PAYLOAD ===');
      print('URL: $url');
      print('oBilling.billingId: ${billingData['oBilling']['billingId']}');
      print('orderDetails count: ${orderDetails.length}');
      for (int i = 0; i < orderDetails.length; i++) {
        print('Item $i AFTER loop:');
        print('  orderDetailsId: ${itemList[i]['orderDetailsId']}');
        print('  billingId: ${itemList[i]['billingId']}');
      }

      final response = await apiService.postRequest(url: url, data: billingData);

      Get.back();

      if (response.statusCode == 200) {
        Get.snackbar(
          "Success",
          "Billing data submitted successfully",
          snackPosition: SnackPosition.BOTTOM,
        );
        itemList.clear();
        currentOrderNo = '';
        currentBillingId = 0;
        updateBill.value = false;
        update();
      } else {
        Get.snackbar(
          "Error",
          "Failed to submit billing ${response.body}",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e, stackTrace) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      print('ERROR: $e');
      print('STACKTRACE: $stackTrace');
      Get.snackbar(
        "Error",
        "Exception occurred: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }


  /*Future<void> submitBillingData({
    String orderNo = '',
    int? customerId = 0,
    String? customerName = '',
    String? clientId = '',
    double discount = 0,
    double gst = 0,
    String discountType = 'Flat',
    double paidAmount = 0,
    String paidAmountType = 'Cash',
    String transactionNo = '',
    String referenceNo = '',
    String paymentStatus = 'Pending',
  }) async {
    try {
      // Show loading indicator
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Recalculate orderNo if creating new
      if (!updateBill.value) {
        orderNo = DateTime.now().millisecondsSinceEpoch.toString();
      }

      // Calculate total amount and balance
      final double calculatedTotal = totalAmount;
      final double balanceAmount = calculatedTotal - double.parse(amountPaid.text);

      final DateTime now = DateTime.now();
      final String formattedDate = now.toIso8601String();
      int? clientUserId = SharedPrefs.getInt(ConstantsText.clientUserId);
      String? clientIds = SharedPrefs.getString(ConstantsText.clientId);

      int billingsId = 0;

      // Collect details
      List<Map<String, dynamic>> orderDetails = [];

      for (int i = 0; i < itemList.length; i++) {
        final item = itemList[i];
        final double qty = double.tryParse(item['quantity'] ?? '0') ?? 0;
        final double rate = double.tryParse(item['rate'] ?? '0') ?? 0;
        final double totalPrice = qty * rate;

        final int orderDetailsId = item['orderDetailsId'] ?? 0;
        final int billingId = item['billingId'] ?? 0;
        billingsId = billingId;

        String productName = '';
        if (item['particulars'] is Uint8List) {
          productName = _convertImageToBase64(item['particulars']);
        } else {
          productName = item['productName'] ?? '';
        }

        orderDetails.add({
          "orderNo": orderNo,
          "orderDetailsId": orderDetailsId,
          "billingId": billingId,
          "customerId": customerId ?? 0,
          "clientId": clientIds ?? 0000,
          "customerName": customerName ?? "Guest",
          "productName": productName,
          "quantity": qty,
          "pricePerQuantity": rate,
          "totalPrice": totalPrice,
          "productType": "",
          "isDelete": false,
          "postedOn": formattedDate,
          "modifiedOn": formattedDate,
          "clientUserId": clientUserId
        });
      }

      // Prepare billing data
      Map<String, dynamic> billingData = {
        "oBilling": {
          "billingId": billingsId,
          "orderNo": orderNo,
          "customerId": customerId ?? 0,
          "customerName": customerName ?? "Guest",
          "clientId": clientIds ?? 0000,
          "totalAmount": calculatedTotal,
          "balanceAmount": balanceAmount,
          "discount": discount,
          "gst": gst,
          "discountType": discountType,
          "paidAmount": paidAmount,
          "paidAmountType": paidAmountType,
          "transactionNo": transactionNo,
          "referenceNo": referenceNo,
          "paymentStatus": paymentStatus,
          "paymentDate": formattedDate,
          "postedOn": formattedDate,
          "modifiedOn": formattedDate,
          "isDelete": false,
          "isRefund": false,
          "refundAmount": 0,
          "refundRemark": "",
          "refundType": "",
          "refundDate": null,
          "refundTransNo": "",
          "refundStatus": "",
          "clientUserId": clientUserId
        },
        "orderDetails": orderDetails
      };

      String url = updateBill.value
          ? "https://roughbill.com/api/Order/UpdateOrder"
          : "https://roughbill.com/api/Order/addorder";

      final response = await apiService.postRequest(url: url, data: billingData);

      Get.back();

      if (response.statusCode == 200) {
        Get.snackbar(
          "Success",
          "Billing data submitted successfully",
          snackPosition: SnackPosition.BOTTOM,
        );
        itemList.clear();
        update();
      } else {
        Get.snackbar(
          "Error",
          "Failed to submit billing  ${response.body}",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      Get.snackbar(
        "Error",
        "Exception occurred: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }*/

  Future<void> loadBillingDetailForEdit(BillingReport billDetail) async {
    OrderDeatailsResponseModel? orderDetail = await getBillingDetail(billDetail);

    if (orderDetail != null && orderDetail.orders?.first.orderDetails != null) {
      itemList.clear();
      updateBill.value = true;

      if (orderDetail.orders!.first.oBilling != null) {
        var billing = orderDetail.orders!.first.oBilling!;
        currentBillingId = billing.billingId ?? 0;
        currentOrderNo = billing.orderNo ?? '';
        currentCustomerId = billing.customerId ?? 0;
        currentCustomerName = billing.customerName ?? '';

      }

      for (var detail in orderDetail.orders!.first.orderDetails!) {
        Uint8List? particularImage;
        if (detail.productName != null && detail.productName!.isNotEmpty) {
          try {
            String base64String = detail.productName!;
            if (base64String.contains(',')) {
              base64String = base64String.split(',').last;
            }
            particularImage = base64Decode(base64String);
          } catch (e) {
            print("Error decoding base64: $e");
            particularImage = Uint8List(0);
          }
        }

        // ⭐ STORE VALUES IN VARIABLES FIRST - DON'T LET THEM BE NULL
        final int savedOrderDetailsId = detail.orderDetailsId ?? 0;
        final int savedBillingId = detail.billingId ?? 0;
        final String savedOrderNo = detail.orderNo ?? '';
        final int savedCustomerId = detail.customerId ?? 0;
        final String savedQuantity = detail.quantity?.toString() ?? '0';
        final String savedRate = detail.pricePerQuantity?.toString() ?? '0';
        final String savedProductName = detail.productName ?? '';

        // ⭐ CREATE MAP WITH STORED VALUES
        final Map<String, dynamic> itemMap = {
          'particulars': particularImage ?? Uint8List(0),
          'productName': savedProductName,
          'quantity': savedQuantity,
          'rate': savedRate,
          'orderDetailsId': savedOrderDetailsId,
          'billingId': savedBillingId,
          'orderNo': savedOrderNo,
          'customerId': savedCustomerId,
        };

        itemList.add(itemMap);

      }


      // ⭐ IMMEDIATE VERIFICATION
      // print('\n=== IMMEDIATE VERIFICATION ===');
      // for (int i = 0; i < itemList.length; i++) {
      //   print('Item $i: orderDetailsId=${itemList[i]['orderDetailsId']}, billingId=${itemList[i]['billingId']}');
      // }

      update();
    }
  }



  Future<void> getClients() async {
    loadingClient.value = true;
    String? clientId = SharedPrefs.getString(ConstantsText.clientId);
    int? clientUserId = SharedPrefs.getInt(ConstantsText.clientUserId);
    String url = "https://roughbill.com/api/Customer/GetCustomer?clientId=$clientId&ClientUserId=$clientUserId";

    try {
      var response = await apiService.getRequest(url: url);

      if (response.statusCode == 200) {
        // Parse the response directly into the observable
        customerResponse.value = customerResponseModelFromJson(response.body);

        // Initialize filtered list with all clients
        filteredClientList.value = customerResponse.value?.data ?? [];

        loadingClient.value = false;
      } else {
        customerResponse.value = null; // Clear data on error
        filteredClientList.clear();
        Get.snackbar(
          'Error',
          'Failed to search clients',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      customerResponse.value = null; // Clear data on error
      filteredClientList.clear();
      print("Error parsing customer data: $e");
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
