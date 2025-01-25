import 'package:billing/ui/splash_screen.dart';
import 'package:get/get.dart';
import '../binding/home_binding.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => SplashScreen(),
      binding: HomeBinding(),
    ),
  ];
}