import 'package:billing/ui/order/order.dart';
import 'package:billing/ui/order/order_new.dart';
import 'package:billing/ui/splash_screen.dart';
import 'package:billing/ui/billing/billing.dart';
import 'package:billing/ui/billing/billing_new.dart';
import 'package:billing/ui/clients/billing_options.dart';
import 'package:get/get.dart';
import '../binding/home_binding.dart';

class AppPages {

  static const String splash = "/splash";
  static const String billing = "/billing";
  static const String billingNew = "/billing_new";
  static const String billingOptions = "/billing_options";
  static const String order = "/order";
  static const String orderNew = "/orderNew";

  static List<GetPage> routes = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: billing,
      page: () => Billing(customer: Get.arguments?['customer']),
    ),
    GetPage(
      name: billingNew,
      page: () => BillingNew(customer: Get.arguments?['customer'],),
    ),
    GetPage(
      name: billingOptions,
      page: () => BillingOptions(),
    ),
    GetPage(
      name: order,
      page: () => Order(customer: Get.arguments?['customer']),
    ),
    GetPage(
      name: orderNew,
      page: () => OrderNew(customer: Get.arguments?['customer']),
    ),
  ];
}