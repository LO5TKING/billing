
import 'package:billing/ui/auth/login_screen.dart';
import 'package:billing/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget shadowText({required String text, double? fontsize, Color? textcolor, FontWeight? fontWeight}) {
  return Text(
    text,
    style: TextStyle(
      fontSize: fontsize ?? 24,
      color: textcolor ?? Colors.black,
      fontWeight: fontWeight ?? FontWeight.bold,
      shadows: [
        Shadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 0.4,
            offset: const Offset(3, 4)
        ),
      ],
    ),
  );
}

RxString getCurrentDateTime() {
  final DateTime now = DateTime.now();
  final RxString formattedDateTime = "Date:- ${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year} "
      "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}".obs;
  return formattedDateTime;
}

Widget noShadowText({required String text, double? fontsize, Color? textcolor, FontWeight? fontWeight}) {
  return Text(
    text,
    style: TextStyle(
      fontSize: fontsize ?? 24,
      color: textcolor ?? Colors.black,
      fontWeight: fontWeight ?? FontWeight.bold,
    ),
  );
}

void showLogoutDialog() {
  Get.dialog(
    AlertDialog(
      title: Text('Logout'),
      content: Text('Are you sure you want to logout?'),
      actions: [
        TextButton(
          onPressed: () {
            Get.back(); // Close the dialog
          },
          child: Text('No'),
        ),
        TextButton(
          onPressed: () {
            Get.back(); // Close the dialog
            // Perform your logout logic here
            SharedPrefs.clear();
            Get.off(() => LoginScreen());
          },
          child: Text('Yes'),
        ),
      ],
    ),
    barrierDismissible: false,
  );
}

// Future<void> shareReceipt() async {
//   File? pdfFile = await saveReceiptAsPdf(); // Save and get the PDF file
//
//   if (pdfFile != null && await pdfFile.exists()) {
//     final XFile xfile = XFile(pdfFile.path);
//     await Share.shareXFiles([xfile], text: 'Here is your receipt!');
//   } else {
//     Get.snackbar('Error', 'Unable to share receipt');
//   }
// }