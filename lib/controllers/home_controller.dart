import 'package:flutter/material.dart' hide Ink;
import 'package:get/get.dart';

import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';

import '../utils/activity_indicator.dart';

class HomeController extends GetxController {
  //TODO: Implement HomeController

  final DigitalInkRecognizerModelManager modelManager =
  DigitalInkRecognizerModelManager();
  final String language = 'en-US';
  late final DigitalInkRecognizer digitalInkRecognizer =
  DigitalInkRecognizer(languageCode: language);
  final Ink ink = Ink();
  List<StrokePoint> points = [];
  String recognizedText = '';
  @override
  void onInit() async {
    super.onInit();
    // bool downloadedModel = await isModelDownloaded();
    // if (downloadedModel) {
    //   return;
    // } else {
    //   downloadModel();
    // }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    digitalInkRecognizer.close();
    super.onClose();
  }
  /// mehrods
  void clearPad() {

    ink.strokes.clear();
    points.clear();
    recognizedText = '';
    update();
  }

  Future<bool> isModelDownloaded() async {
    // Check if the model is downloaded
    bool isDownloaded = await modelManager.isModelDownloaded(language);

    // Return the appropriate string based on the download status
    return isDownloaded;
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

}