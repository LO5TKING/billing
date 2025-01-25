import 'dart:async';

import 'package:billing/ui/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';
import '../ui/billing/billing.dart';

class SplashController extends GetxController {
  final DigitalInkRecognizerModelManager modelManager = DigitalInkRecognizerModelManager();
  final String language = 'en-US';
  RxBool isLoading = true.obs;
  RxString loadingStatus = 'Initializing...'.obs;

  @override
  void onInit() {
    super.onInit();
    initializeApp();
  }

  Future<void> initializeApp() async {
    try {
      loadingStatus('Checking model status...');

      // Check if model is already downloaded
      bool modelDownloaded = await modelManager.isModelDownloaded(language);

      if (!modelDownloaded) {
        loadingStatus('Downloading recognition model...');
        bool success = await _downloadModelWithTimeout();

        if (!success) {
          throw 'Failed to download model';
        }

        // Verify download
        loadingStatus('Verifying download...');
        bool verified = await modelManager.isModelDownloaded(language);
        if (!verified) {
          throw 'Model verification failed';
        }
      }

      loadingStatus('Initialization complete');
      isLoading(false);

      // Navigate to billing page
      Get.off(() => SplashScreen());
    } catch (e) {
      loadingStatus('Error: $e');
      // Show error dialog
      Get.dialog(
        AlertDialog(
          title: const Text('Initialization Error'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              child: const Text('Retry'),
              onPressed: () {
                Get.back();
                initializeApp();
              },
            ),
            TextButton(
              child: const Text('Close App'),
              onPressed: () => Get.back(),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    }
  }

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
    } catch (e) {
      print('Download error: $e');
      return false;
    }
  }
}