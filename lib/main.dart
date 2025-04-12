import 'package:billing/app/binding/home_binding.dart';
import 'package:billing/ui/splash_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Billing App',
      debugShowCheckedModeBanner: false,
      useInheritedMediaQuery: true,
      theme: ThemeData(useMaterial3: true),
      home: const SplashScreen(),
      getPages: AppPages.routes,
      opaqueRoute: true,
      locale: const Locale('en', 'US'),
    );
  }
}
