import 'package:billing/app/config/color_constants.dart';
import 'package:billing/app/config/design_constants.dart';
import 'package:billing/ui/clients/billing_options.dart';
import 'package:billing/ui/settings/about_us_settings.dart';
import 'package:billing/ui/settings/backup_settings.dart';
import 'package:billing/ui/settings/contact_us_settings.dart';
import 'package:billing/ui/settings/notification_settings.dart';
import 'package:billing/ui/settings/printer_settings.dart';
import 'package:billing/ui/settings/profile_settings.dart';
import 'package:billing/ui/settings/purchase_settings.dart';
import 'package:billing/ui/settings/subscription_detail_settings.dart';
import 'package:billing/ui/settings/terms_and_condition_settings.dart';
import 'package:billing/utils/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class SettingOptions extends StatelessWidget {
  const SettingOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: InkWell(
            onTap: (){
              Get.back();
            },
            child: const Icon(Icons.arrow_back_ios_new,color: Colors.grey,)),
      ),
      body: Container(
        height: Get.height,
        padding: const EdgeInsets.symmetric(horizontal: DesignConstants.padding20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            shadowText(text: 'Settings',textcolor: Colors.black),
            const SizedBox(
              height: DesignConstants.padding10,
            ),
            Flexible(
              child: Container(
                height: Get.height,
                padding: const EdgeInsets.symmetric(horizontal: DesignConstants.padding20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: DesignConstants.padding10,
                    ),
                    Card(
                      elevation: 20,
                      child: Container(
                        padding: const EdgeInsets.all(DesignConstants.padding20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(DesignConstants.padding20),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.lightPurpleGradient,
                              Colors.white,
                            ],
                          ),
                        ),
                        child: Column(
                          children: [
                            ListView.builder(
                              shrinkWrap: true, // This will make the ListView adjust its height based on content
                              physics: const NeverScrollableScrollPhysics(), // Prevent ListView from scrolling inside another scrollable widget
                              itemCount: 10, // Number of list items you have
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    settingsListTile(
                                      index : index,
                                      leadingIcon: _getIconForIndex(index), // Use a function to get icons dynamically
                                      text: _getTextForIndex(index), // Use a function to get text dynamically
                                      context: context,
                                    ),
                                    if (index != 9) // Add divider only between items, not after the last one
                                      const Divider(
                                        color: Colors.grey,
                                        thickness: 0.5,
                                      ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )

          ],
        ),
      ),
    );
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.person_search;
      case 1:
        return Icons.print_outlined;
      case 2:
        return Icons.backup_sharp;
      case 3:
        return Icons.notifications;
      case 4:
        return Icons.shopping_basket;
      case 5:
        return Icons.notifications_paused_rounded;
      case 6:
        return Icons.info;
      case 7:
        return Icons.phone;
      case 8:
        return Icons.branding_watermark_sharp;
      case 9:
        return Icons.logout;
      default:
        return Icons.info;
    }
  }


  String _getTextForIndex(int index) {
    switch (index) {
      case 0:
        return 'Profile Settings';
      case 1:
        return 'Printer Setup';
      case 2:
        return 'Backup';
      case 3:
        return 'Notification';
      case 4:
        return 'Purchase';
      case 5:
        return 'Subscription Detail';
      case 6:
        return 'About Us';
      case 7:
        return 'Contact Us';
      case 8:
        return 'Terms and Conditions';
      case 9:
        return 'Logout';
      default:
        return '';
    }
  }


  InkWell settingsListTile({required IconData leadingIcon,required String text,required BuildContext context,required int index}){
    return InkWell(
      onTap: (){
        switch (index) {
          case 0:
            Get.to(() => ProfileSettings());
          case 1:
            Get.to(() =>  PrinterSettings());
          case 2:
            Get.to(() =>  const BackupSettings());
          case 3:
            Get.to(() =>  const NotificationSettings());
          case 4:
            Get.to(() =>  const PurchaseSettings());
          case 5:
            Get.to(() =>  const SubscriptionDetailSettings());
          case 6:
            Get.to(() =>  const AboutUsSettings());
          case 7:
            Get.to(() =>  const ContactUsSettings());
          case 8:
            Get.to(() =>  const TermsAndConditionSettings());
          case 9:
            showLogoutDialog();
          default:
            Get.toNamed('/billing_options');
        }
      },
      child: ListTile(
            leading: Icon(leadingIcon,color: AppColors.blueGradient,),
            trailing: const Icon(Icons.arrow_forward_ios,color: Colors.grey,),
            title: shadowText(text: text,fontsize: DesignConstants.fontSize18),
          ),
    );
  }
}