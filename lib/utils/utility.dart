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
