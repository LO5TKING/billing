import 'package:billing/ui/splash_screen.dart';
import 'package:get/get.dart';
import '../binding/home_binding.dart';

class AppPages {

  static const String splash = "/splash";

  static List<GetPage> routes = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
    ),
  ];
}