import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:billing/controllers/report_controller.dart';
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
import 'package:flutter/services.dart'; 
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
  String currentOrderNo = '';
  int currentBillingId = 0;
  int currentCustomerId = 0;
  String currentCustomerName = '';
  Rx<BillingReport?> ourReport = Rx<BillingReport?>(null);
  ApiService apiService = ApiService();
  RxBool isModelLoading = false.obs;
  RxString downloadStatus = ''.obs;
  late PrintController printController;
  final RxBool isPrinting = false.obs;
  final RxString formattedDateTime = ''.obs;
  Timer? _dateTimeTimer;
  final Ink editRateInk = Ink();
  final Ink editQuantityInk = Ink();
  String recognizedEditRate = '';
  String recognizedEditQuantity = '';
  TextEditingController amountPaid = TextEditingController();
  TextEditingController discountAmountText = TextEditingController();
  Future<bool> _downloadModelWithTimeout() async {
    try {
      final timeout = Future.delayed(const Duration(seconds: 30), () {
        throw TimeoutException('Model download took too long');
      });
      final download = modelManager.downloadModel(language);
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
    await requestStoragePermissionOnStart();
    if (!Get.isRegistered<PrintController>()) {
      Get.lazyPut(() => PrintController(), fenix: true);
    }
    printController = Get.find<PrintController>();
    _updateDateTime();
    _dateTimeTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => _updateDateTime());
    try {
      clearPadAndSignature();
      bool downloadedModel = await isModelDownloaded();
      if (downloadedModel) {
        return;
      }
      isModelLoading(true);
      downloadStatus('Downloading recognition model...');
      try {
        bool success = await _downloadModelWithTimeout();
        if (success) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('model_downloaded_$language', true);
        } else {
          throw 'Failed to download model';
        }
      } catch (e) {
        print('Model download error: $e');
        
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
                  onInit(); 
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
                onInit(); 
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
    discountAmountText.clear();
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
      
      final prefs = await SharedPreferences.getInstance();
      bool previouslyDownloaded =
          prefs.getBool('model_downloaded_$language') ?? false;
      if (previouslyDownloaded) {
        try {
          
          bool isDownloaded = await modelManager.isModelDownloaded(language);
          return isDownloaded;
        } catch (e) {
          print(
              'Error checking if model is downloaded, but we know it was previously downloaded: $e');
          return true; 
        }
      }
      bool isDownloaded = await modelManager.isModelDownloaded(language);
      if (isDownloaded) {
        await prefs.setBool('model_downloaded_$language', true);
      }

      return isDownloaded;
    } catch (e) {
      print('Error checking if model is downloaded: $e');
      
      
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
      recognizedRate = '';

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

        recognizedRate = text.replaceAll(RegExp(r'[^0-9.]'), '');

        
        if (recognizedRate.isEmpty) {
          rateInk.strokes.clear();
          ratePoints.clear();
          Get.snackbar("Error", "Rate Not Recognized");

          
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

      recognizedQuantity = ''; 

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

        recognizedQuantity = text.replaceAll(RegExp(r'[^0-9.]'), '');

        
        if (recognizedQuantity.isEmpty) {
          
          quantityInk.strokes.clear();
          quantityPoints.clear();
          Get.snackbar("Error", "Quantity Not Recognized");
        }
      } else {
        recognizedQuantity = 'No candidates recognized';
      }

      update();
    } catch (e) {
      
    }
  }

  Future<Uint8List?> convertToPngBytes(double width, double height) async {
    
    width = width * 1.5;
    height = height * 1.5;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromPoints(Offset.zero, Offset(width, height)),
    );
    final Paint bgPaint = Paint()..color = AppColors.peachColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), bgPaint);

    
    for (final stroke in descriptionInk.strokes) {
      final paint = Paint()
        ..color = AppColors.stainedGlass
        ..strokeWidth = 6.0 
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      if (stroke.points.length == 1) {
        canvas.drawCircle(
          Offset(stroke.points[0].x * 1.5,
              stroke.points[0].y * 1.5), 
          3.0, 
          paint,
        );
      } else {
        
        final path = Path();
        path.moveTo(stroke.points[0].x * 1.5,
            stroke.points[0].y * 1.5); 

        for (int i = 0; i < stroke.points.length - 1; i++) {
          final p0 = stroke.points[i];
          final p1 = stroke.points[i + 1];

          path.quadraticBezierTo(
            p0.x * 1.5, 
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
    
    for (int i = 0; i < itemList.length; i++) {
      print('Item $i: orderDetailsId=${itemList[i]['orderDetailsId']}, billingId=${itemList[i]['billingId']}');
    }
    await recogniseRateText();
    for (int i = 0; i < itemList.length; i++) {
      print('Item $i: orderDetailsId=${itemList[i]['orderDetailsId']}, billingId=${itemList[i]['billingId']}');
    }
    await recogniseQuantityText();
    print('\n=== AFTER recogniseQuantityText() ===');
    for (int i = 0; i < itemList.length; i++) {
      print('Item $i: orderDetailsId=${itemList[i]['orderDetailsId']}, billingId=${itemList[i]['billingId']}');
    }
    Uint8List? particularImage = await convertToPngBytes(
      Get.width * 0.8,
      85,
    );

    print('\n=== AFTER convertToPngBytes() ===');
    for (int i = 0; i < itemList.length; i++) {
      print('Item $i: orderDetailsId=${itemList[i]['orderDetailsId']}, billingId=${itemList[i]['billingId']}');
    }

    if (particularImage != null &&
        recognizedQuantity.isNotEmpty &&
        recognizedRate.isNotEmpty) {

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

      
      print('\n=== AFTER ADDING TO LIST ===');
      for (int i = 0; i < itemList.length; i++) {
        print('Item $i: orderDetailsId=${itemList[i]['orderDetailsId']}, billingId=${itemList[i]['billingId']}');
      }

      clearPadAndSignature();

      
      print('\n=== AFTER clearPadAndSignature() ===');
      for (int i = 0; i < itemList.length; i++) {
        print('Item $i: orderDetailsId=${itemList[i]['orderDetailsId']}, billingId=${itemList[i]['billingId']}');
      }

      itemList.refresh();

      
      print('\n=== AFTER itemList.refresh() ===');
      for (int i = 0; i < itemList.length; i++) {
        print('Item $i: orderDetailsId=${itemList[i]['orderDetailsId']}, billingId=${itemList[i]['billingId']}');
      }

      update();

      
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
                      child: Builder(  
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
                              final RenderObject? object = quantityContext.findRenderObject();  
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
                      child: Builder(  
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
                              final RenderObject? object = rateContext.findRenderObject();  
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
        // Get.back();
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

  Future<void> printPdfReceipt(Datum? customer) async {
    if (isPrinting.value) return;

    if (itemList.isEmpty) {
      Get.snackbar('Error', 'No items to print');
      return;
    }

    double discountAmount = 0;
    String discountType = 'Flat';
    double? paidAmount = (ourReport.value?.totalAmount ?? 0) - (ourReport.value?.balanceAmount ?? 0);

    double amountToBePaid = showPaymentDialog.value ? paidAmount : totalAmount;

    amountPaid.text = showPaymentDialog.value
        ? (paidAmount != 0 ? paidAmount.toString() : "0")
        : totalAmount.toString();

    String? errorMessage;

    Get.defaultDialog(
      title: 'Payment Details',
      barrierDismissible: false,
      content: StatefulBuilder(
        builder: (context, setState) {
          // Calculate total amount
          double calculatedTotal = totalAmount;
          double finalAmount = calculatedTotal;

          // Apply discount
          if (discountType == 'Percentage' && discountAmount > 0) {
            finalAmount = calculatedTotal - (calculatedTotal * discountAmount / 100);
          } else if (discountType == 'Flat') {
            finalAmount = calculatedTotal - discountAmount;
          }

          finalAmount = finalAmount < 0 ? 0 : finalAmount;

          // FIXED: Re-validate amount paid whenever finalAmount changes
          if (amountToBePaid > finalAmount) {
            errorMessage = 'Amount paid cannot exceed final amount of ₹${finalAmount.toStringAsFixed(2)}';
          } else {
            errorMessage = null;
          }

          double balanceAmount = showPaymentDialog.value
              ? (ourReport.value?.balanceAmount ?? 0) - (amountToBePaid - paidAmount)
              : finalAmount - amountToBePaid;
          balanceAmount = balanceAmount < 0 ? 0 : balanceAmount;

          return Container(
            width: Get.width * 0.8,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                Container(
                  width: Get.width * 0.8,
                  padding: const EdgeInsets.all(20),
                  child: Table(
                    columnWidths: const {
                      0: FixedColumnWidth(150),
                      1: FixedColumnWidth(150),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
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

                      TableRow(children: [
                        Text(
                          discountType == 'Percentage' ? 'Discount %:' : 'Discount Amount:',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 100,
                          height: 40,
                          child: TextField(
                            controller: discountAmountText,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              prefixText: discountType == 'Percentage' ? '% ' : '₹ ',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                            ),
                            onChanged: (value) {
                              setState(() {
                                discountAmount = double.tryParse(value) ?? 0;
                                // Validation will automatically run in the next build
                              });
                            },
                          ),
                        ),
                      ]),

                      const TableRow(children: [SizedBox(height: 12), SizedBox(height: 12)]),

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

                      TableRow(children: [
                        const Text('Amount Paid:', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(
                          width: 100,
                          height: 40,
                          child: TextField(
                            controller: amountPaid,
                            textAlign: TextAlign.center,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: errorMessage != null ? Colors.red : Colors.grey,
                                ),
                              ),
                              prefixText: '₹ ',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                            ),
                            onChanged: (value) {
                              setState(() {
                                amountToBePaid = double.tryParse(value) ?? 0;
                                // Validation will automatically run in the next build
                              });
                            },
                          ),
                        )
                      ]),

                      const TableRow(children: [SizedBox(height: 12), SizedBox(height: 12)]),

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
                ),
              ],
            ),
          );
        },
      ),
      actions: [
        GestureDetector(
          onTap: () async {
            double finalAmount = totalAmount;
            if (discountType == 'Percentage' && discountAmount > 0) {
              finalAmount = totalAmount - (totalAmount * discountAmount / 100);
            } else if (discountType == 'Flat') {
              finalAmount = totalAmount - discountAmount;
            }
            finalAmount = finalAmount < 0 ? 0 : finalAmount;

            double paidAmt = double.tryParse(amountPaid.text) ?? 0;

            if (paidAmt > finalAmount) {
              Get.snackbar(
                'Error',
                'Amount paid cannot exceed final amount of ₹${finalAmount.toStringAsFixed(2)}',
                backgroundColor: Colors.red.shade100,
              );
              return;
            }

            await submitBillingData(
                customerId: customer?.custId,
                customerName: customer?.name,
                clientId: customer?.clientId,
                paidAmount: paidAmt
            );
            itemList.clear();
            // ReportController().getReports();
            SharedPrefs.remove(ConstantsText.selectedCustomerBill1);
            SharedPrefs.remove(ConstantsText.selectedCustMobBill1);
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(100)
            ),
            child: const Text(
              "Save Reciept",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
        GestureDetector(
          onTap: () async {
            try {
              double finalAmount = totalAmount;
              if (discountType == 'Percentage' && discountAmount > 0) {
                finalAmount = totalAmount - (totalAmount * discountAmount / 100);
              } else if (discountType == 'Flat') {
                finalAmount = totalAmount - discountAmount;
              }
              finalAmount = finalAmount < 0 ? 0 : finalAmount;

              double paidAmt = double.tryParse(amountPaid.text) ?? 0;

              if (paidAmt > finalAmount) {
                Get.snackbar(
                  'Error',
                  'Amount paid cannot exceed final amount of ₹${finalAmount.toStringAsFixed(2)}',
                  backgroundColor: Colors.red.shade100,
                );
                return;
              }

              Get.back();
              isPrinting.value = true;

              double actualDiscountAmount = discountType == 'Percentage'
                  ? (totalAmount * discountAmount / 100)
                  : discountAmount;

              await submitBillingData(
                  customerId: customer?.custId,
                  customerName: customer?.name,
                  clientId: customer?.clientId,
                  paidAmount: paidAmt
              );

              print('=== RIGHT BEFORE PRINT ===');
              print('itemList length: ${itemList.length}');
              for (int i = 0; i < itemList.length; i++) {
                print('Item $i exists: ${itemList[i]}');
              }

              await printController.printPdfReceipt(
                  itemList,
                  discountAmount: actualDiscountAmount,
                  amountPaid: paidAmt
              );
              itemList.clear();
              SharedPrefs.remove(ConstantsText.selectedCustomerBill1);
              SharedPrefs.remove(ConstantsText.selectedCustMobBill1);
              Get.snackbar('Success', 'Receipt sent to printer');
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
                borderRadius: BorderRadius.circular(100)
            ),
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
                borderRadius: BorderRadius.circular(100)
            ),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }





/*  Future<void> printPdfReceipt(Datum? customer) async {
    if (isPrinting.value) return;

    if (itemList.isEmpty) {
      Get.snackbar('Error', 'No items to print');
      return;
    }

    double discountAmount = 0;
    double amountToBePaid = showPaymentDialog.value ? ourReport.value?.paidAmount ?? 0 : totalAmount;
    double balanceAmount = showPaymentDialog.value ? ourReport.value?.balanceAmount ?? 0 : 0;
    String discountType = 'Flat'; 
    double? paidAmount = (ourReport.value?.totalAmount ?? 0) - (ourReport.value?.balanceAmount ?? 0);

    amountPaid.text = showPaymentDialog.value ? (paidAmount != 0 ? paidAmount.toString() : "0") : totalAmount.toString();
    Get.defaultDialog(
      title: 'Payment Details',
      barrierDismissible: false,
      content: StatefulBuilder(
        builder: (context, setState) {
          
          double calculatedTotal = totalAmount;
          double finalAmount = calculatedTotal;

          
          if (discountType == 'Percentage' && discountAmount > 0) {
            finalAmount = calculatedTotal - (calculatedTotal * discountAmount / 100);
          } else if (discountType == 'Flat') {
            finalAmount = calculatedTotal - discountAmount;
          }

          
          finalAmount = finalAmount < 0 ? 0 : finalAmount;

          
          balanceAmount = showPaymentDialog.value ? ourReport.value?.balanceAmount ?? 0 : finalAmount - amountToBePaid;
          balanceAmount = balanceAmount < 0 ? 0 : balanceAmount;
          return Container(
            width: Get.width * 0.8,
            padding: const EdgeInsets.all(20),
            child: Table(
              columnWidths: const {
                0: FixedColumnWidth(150),   
                1: FixedColumnWidth(150),      
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [

                
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
              paidAmount: double.parse(amountPaid.text)
            );
            itemList.clear();
            Get.back();
            SharedPrefs.remove(ConstantsText.selectedCustomer);
            SharedPrefs.remove(ConstantsText.selectedCustMob);
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
              Get.back(); 
              isPrinting.value = true;
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
                  clientId: customer?.clientId,
                  paidAmount: double.parse(amountPaid.text)
              );

              print('=== RIGHT BEFORE PRINT ===');
              print('itemList length: ${itemList.length}');
              for (int i = 0; i < itemList.length; i++) {
                print('Item $i exists: ${itemList[i]}');
              }

              await printController.printPdfReceipt(
                  itemList,
                  discountAmount: actualDiscountAmount,
                  amountPaid: amountToBePaid
              );
              itemList.clear();
              SharedPrefs.remove(ConstantsText.selectedCustomer);
              SharedPrefs.remove(ConstantsText.selectedCustMob);
              Get.snackbar('Success', 'Receipt sent to printer');
              
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
  }*/

  void _updateDateTime() {
    final now = DateTime.now();
    formattedDateTime.value =
        "Date:- ${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year} "
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }

  Future<File?> saveReceiptAsPdf() async {
    try {
      final pdf = pw.Document();

      final ByteData logoData = await rootBundle.load('assets/ganpati.png');
      final Uint8List logoBytes = logoData.buffer.asUint8List();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                
                pw.Image(pw.MemoryImage(logoBytes), width: 50, height: 50),
                pw.SizedBox(height: 8),
                
                pw.Text(SharedPrefs.getString(ConstantsText.companyName) ?? "",
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 18)),
                pw.Text('${SharedPrefs.getString(ConstantsText.addresss) ?? ""}\n'),
                pw.Text('${SharedPrefs.getString(ConstantsText.mobileNumber) ?? ""}'),
                pw.SizedBox(height: 8),
                
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Date: ${DateTime.now().toString().split(' ')[0]}'),
                    pw.Text(
                        'Time: ${DateTime.now().toString().split(' ')[1].split('.').first}'),
                  ],
                ),
                pw.Divider(),
                
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
                
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text('TOTAL: ${totalAmount.toStringAsFixed(0)}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 16),
                
                pw.Text('Thank you for your business!'),
                pw.Text('Please visit again'),
              ],
            );
          },
        ),
      );

      
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

      // Get discount value from text field
      discount = double.tryParse(discountAmountText.text) ?? 0.0;

      if (updateBill.value) {
        orderNo = currentOrderNo;
        customerId = customerId ?? currentCustomerId;
        customerName = customerName ?? currentCustomerName;
      } else {
        orderNo = DateTime.now().millisecondsSinceEpoch.toString();
      }

      // Step 1: Get the base total amount
      final double baseTotal = totalAmount;

      // Step 2: Apply discount to get the final total
      final double discountAmount = discount;
      final double totalAfterDiscount = baseTotal - discountAmount;

      // Step 3: Add GST if applicable (assuming GST is a percentage)
      final double gstAmount = (totalAfterDiscount * gst) / 100;
      final double finalTotal = totalAfterDiscount + gstAmount;

      // Step 4: Calculate balance amount (final total - paid amount)
      final double paidAmountValue = double.tryParse(amountPaid.text) ?? 0.0;
      final double balanceAmount = finalTotal - paidAmountValue;

      final DateTime now = DateTime.now();
      final String formattedDate = now.toIso8601String();
      int? clientUserId = SharedPrefs.getInt(ConstantsText.clientUserId);
      String? clientIds = SharedPrefs.getString(ConstantsText.clientId);

      int billingsId = updateBill.value ? currentBillingId : 0;

      List<Map<String, dynamic>> orderDetails = [];

      for (int i = 0; i < itemList.length; i++) {
        final item = itemList[i];
        final double qty = double.tryParse(item['quantity'] ?? '0') ?? 0;
        final double rate = double.tryParse(item['rate'] ?? '0') ?? 0;
        final double totalPrice = qty * rate;

        final int orderDetailsId = item['orderDetailsId'] ?? 0;
        final int billingId = item['billingId'] ?? 0;

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

      Map<String, dynamic> billingData = {
        "oBilling": {
          "billingId": billingsId,
          "orderNo": orderNo,
          "customerId": customerId ?? 0,
          "customerName": customerName ?? "Guest",
          "clientId": clientIds ?? '0000',
          "totalAmount": finalTotal, // Use calculated final total
          "balanceAmount": balanceAmount, // Use calculated balance
          "discount": discountAmount,
          "gst": gst,
          "discountType": discountType,
          "paidAmount": paidAmountValue, // Use parsed paid amount
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

      // Close loading dialog first
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (response.statusCode == 200) {
        Get.back(result: true); // Return true for success

        Get.snackbar(
          "Success",
          "Billing data submitted successfully",
          snackPosition: SnackPosition.BOTTOM,
        );

        // Reset values
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
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      discount = double.tryParse(discountAmountText.text) ?? 0.0;
      
      if (updateBill.value) {
        orderNo = currentOrderNo;
        customerId = customerId ?? currentCustomerId;
        customerName = customerName ?? currentCustomerName;

        // print('=== UPDATE MODE ===');
        // print('Using orderNo: $orderNo');
        // print('Using billingId: $currentBillingId');
      } else {
        orderNo = DateTime.now().millisecondsSinceEpoch.toString();

      }

      final double calculatedTotal = totalAmount;
      final double balanceAmount = calculatedTotal - double.parse(amountPaid.text);
      final DateTime now = DateTime.now();
      final String formattedDate = now.toIso8601String();
      int? clientUserId = SharedPrefs.getInt(ConstantsText.clientUserId);
      String? clientIds = SharedPrefs.getString(ConstantsText.clientId);

      
      int billingsId = updateBill.value ? currentBillingId : 0;
      
      List<Map<String, dynamic>> orderDetails = [];

      for (int i = 0; i < itemList.length; i++) {
        final item = itemList[i];
        final double qty = double.tryParse(item['quantity'] ?? '0') ?? 0;
        final double rate = double.tryParse(item['rate'] ?? '0') ?? 0;
        final double totalPrice = qty * rate;

        
        final int orderDetailsId = item['orderDetailsId'] ?? 0;
        final int billingId = item['billingId'] ?? 0;

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

      
      Map<String, dynamic> billingData = {
        "oBilling": {
          "billingId": billingsId,
          "orderNo": orderNo,
          "customerId": customerId ?? 0,
          "customerName": customerName ?? "Guest",
          "clientId": clientIds ?? '0000',
          "totalAmount": calculatedTotal,
          "balanceAmount": balanceAmount,
          "discount": double.tryParse(discountAmountText.text ?? "0.0") ?? discount,
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

      if (response.statusCode == 200) {
        Get.back(canPop: true,closeOverlays: true,result: true);
        // ReportController().getReports();
        Get.snackbar(
          "Success",
          "Billing data submitted successfully",
          snackPosition: SnackPosition.BOTTOM,
        );
        /// commented so that i can print the bill successfully
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

        
        final int savedOrderDetailsId = detail.orderDetailsId ?? 0;
        final int savedBillingId = detail.billingId ?? 0;
        final String savedOrderNo = detail.orderNo ?? '';
        final int savedCustomerId = detail.customerId ?? 0;
        final String savedQuantity = detail.quantity?.toString() ?? '0';
        final String savedRate = detail.pricePerQuantity?.toString() ?? '0';
        final String savedProductName = detail.productName ?? '';

        
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
        
        customerResponse.value = customerResponseModelFromJson(response.body);
        filteredClientList.value = customerResponse.value?.data ?? [];

        loadingClient.value = false;
      } else {
        customerResponse.value = null; 
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
      customerResponse.value = null; 
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
