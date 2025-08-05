import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/config/color_constants.dart';
import '../../app/config/constants_text.dart';
import '../../app/config/design_constants.dart';
import '../../utils/shared_pref.dart';
import '../../utils/utility.dart';
import 'controller/profile_setting_controller.dart';

class ProfileSettings extends StatefulWidget {
  ProfileSettings({super.key});


  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  ProfileSettingController profileSettingsController = Get.put(ProfileSettingController());


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    profileSettingsController.companyName.text =  SharedPrefs.getString(ConstantsText.companyName) ?? "";
    profileSettingsController.personName.text =   SharedPrefs.getString(ConstantsText.personName) ?? "";
    profileSettingsController.mobileNumber.text =  SharedPrefs.getString(ConstantsText.mobileNumber) ?? "";
    profileSettingsController.address.text =  SharedPrefs.getString(ConstantsText.addresss) ?? "";
    profileSettingsController.gstNumber.text =  SharedPrefs.getString(ConstantsText.gstNumber) ?? "";
    profileSettingsController.emailId.text =  SharedPrefs.getString(ConstantsText.emailId) ?? "";
  }

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
                            profileForm(profileSettingsController.edit),
                            Obx(() => profileSettingsController.loading.value ?
                                const Center(child: CircularProgressIndicator(),):
                              Center(
                                child: InkWell(
                                  onTap: () async {
                                    profileSettingsController.edit.value = !profileSettingsController.edit.value;
                                    if(!profileSettingsController.edit.value){
                                      await profileSettingsController.profileUpdate();
                                    }
                                  },
                                  child: Container(
                                    width: 120,
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: AppColors.blueGradient,
                                      borderRadius: BorderRadius.circular(100)
                                    ),
                                      child: Text(profileSettingsController.edit.value ? "Update" : "Edit",style: const TextStyle(color: Colors.white),)),
                                )
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget profileForm (RxBool isEdit){
    return Obx( () =>
       Column(
        children: [
          Row(
            children: [
              const Icon(Icons.person_search,size: 40,color: AppColors.blueGradient,),
              const SizedBox(width: DesignConstants.padding20,),
              shadowText(text: 'Profile Setting'),
            ],
          ),
          const SizedBox(
            height: DesignConstants.padding10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                shadowText(text: 'Company Name',fontsize: DesignConstants.fontSize24,fontWeight: FontWeight.w400),
                const Spacer(),
                SizedBox(
                  width: 200,
                  child: TextFormField(
                    controller: profileSettingsController.companyName,
                    keyboardType: TextInputType.text,
                    onChanged: (value){},
                    readOnly: !isEdit.value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,fontSize: DesignConstants.fontSize24,fontStyle: FontStyle.italic,
                    ),
                    decoration:const InputDecoration(
                      fillColor: Colors.white,
                      hintText: 'Biling',
                      hintStyle: TextStyle(fontWeight: FontWeight.w400,color: Colors.grey,fontSize: DesignConstants.fontSize24,fontStyle: FontStyle.italic),
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                    ),
                  ),
                ),
                // const Spacer(),
                // const Icon(Icons.edit,size: 25,),
              ],
            ),
          ),
          const SizedBox(
            height: DesignConstants.padding10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                shadowText(text: 'Person Name',fontsize: DesignConstants.fontSize24,fontWeight: FontWeight.w400),
                const Spacer(),
                SizedBox(
                  width: 200,
                  child: TextFormField(
                    controller: profileSettingsController.personName,
                    keyboardType: TextInputType.text,
                    onChanged: (value){},
                    readOnly: !isEdit.value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,fontSize: DesignConstants.fontSize24,fontStyle: FontStyle.italic,
                    ),
                    decoration:const InputDecoration(
                      fillColor: Colors.white,
                      hintText: 'Biling',
                      hintStyle: TextStyle(fontWeight: FontWeight.w400,color: Colors.grey,fontSize: DesignConstants.fontSize24,fontStyle: FontStyle.italic),
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                    ),
                  ),
                ),
                //const Spacer(),
                //const Icon(Icons.edit,size: 25,),
              ],
            ),
          ),
          const SizedBox(
            height: DesignConstants.padding10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: [
                shadowText(text: 'Mobile Number',fontsize: DesignConstants.fontSize24,fontWeight: FontWeight.w400),
                const Spacer(),
                SizedBox(
                  width: 200,
                  child: TextFormField(
                    controller: profileSettingsController.mobileNumber,
                    keyboardType: TextInputType.number,
                    onChanged: (value){},
                    readOnly: true,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,fontSize: DesignConstants.fontSize24,fontStyle: FontStyle.italic,
                    ),
                    decoration:const InputDecoration(
                      fillColor: Colors.white,
                      hintText: '8736846384',
                      hintStyle: TextStyle(fontWeight: FontWeight.w400,color: Colors.grey,fontSize: DesignConstants.fontSize24,fontStyle: FontStyle.italic),
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                    ),
                  ),
                ),
                //const Spacer(),
                //const Icon(Icons.edit,size: 25,),
              ],
            ),
          ),
          const SizedBox(
            height: DesignConstants.padding10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                shadowText(text: 'Address',fontsize: DesignConstants.fontSize24,fontWeight: FontWeight.w400),
                const Spacer(),
                SizedBox(
                  width: 200,
                  child: TextFormField(
                    controller: profileSettingsController.address,
                    keyboardType: TextInputType.text,
                    onChanged: (value){},
                    readOnly: !isEdit.value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,fontSize: DesignConstants.fontSize24,fontStyle: FontStyle.italic,
                    ),
                    decoration:const InputDecoration(
                      fillColor: Colors.white,
                      hintText: 'Andheri',
                      hintStyle: TextStyle(fontWeight: FontWeight.w400,color: Colors.grey,fontSize: DesignConstants.fontSize24,fontStyle: FontStyle.italic),
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                    ),
                  ),
                ),
                //const Spacer(),
                //const Icon(Icons.edit,size: 25,),
              ],
            ),
          ),
          const SizedBox(
            height: DesignConstants.padding10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                shadowText(text: 'GST Number',fontsize: DesignConstants.fontSize24,fontWeight: FontWeight.w400),
                const Spacer(),
                SizedBox(
                  width: 200,
                  child: TextFormField(
                    controller: profileSettingsController.gstNumber,
                    keyboardType: TextInputType.text,
                    onChanged: (value){},
                    readOnly: !isEdit.value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,fontSize: DesignConstants.fontSize24,fontStyle: FontStyle.italic,
                    ),
                    decoration:const InputDecoration(
                      fillColor: Colors.white,
                      hintText: '27AC2565986565O',
                      hintStyle: TextStyle(fontWeight: FontWeight.w400,color: Colors.grey,fontSize: DesignConstants.fontSize24,fontStyle: FontStyle.italic),
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                    ),
                  ),
                ),
                //const Spacer(),
                //const Icon(Icons.edit,size: 25,),
              ],
            ),
          ),
          const SizedBox(
            height: DesignConstants.padding10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                shadowText(text: 'Email Id',fontsize: DesignConstants.fontSize24,fontWeight: FontWeight.w400),
                const Spacer(),
                SizedBox(
                  width: 200,
                  child: TextFormField(
                    controller: profileSettingsController.emailId,
                    keyboardType: TextInputType.text,
                    onChanged: (value){},
                    readOnly: !isEdit.value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,fontSize: DesignConstants.fontSize24,fontStyle: FontStyle.italic,
                    ),
                    decoration:const InputDecoration(
                      fillColor: Colors.white,
                      hintText: 'billing89@gmail.com',
                      hintStyle: TextStyle(fontWeight: FontWeight.w400,color: Colors.grey,fontSize: DesignConstants.fontSize24,fontStyle: FontStyle.italic),
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                    ),
                  ),
                ),
                //const Spacer(),
                //const Icon(Icons.edit,size: 25,),
              ],
            ),
          ),
          const SizedBox(
            height: DesignConstants.padding10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                shadowText(text: 'Password',fontsize: DesignConstants.fontSize24,fontWeight: FontWeight.w400),
                const Spacer(),
                SizedBox(
                  width: 200,
                  child: TextFormField(
                    controller: profileSettingsController.password,
                    keyboardType: TextInputType.text,
                    onChanged: (value){},
                    readOnly: !isEdit.value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,fontSize: DesignConstants.fontSize24,fontStyle: FontStyle.italic,
                    ),
                    decoration:const InputDecoration(
                      fillColor: Colors.white,
                      hintText: 'Password',
                      hintStyle: TextStyle(fontWeight: FontWeight.w400,color: Colors.grey,fontSize: DesignConstants.fontSize24,fontStyle: FontStyle.italic),
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: DesignConstants.padding10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                shadowText(text: 'Sign Upload',fontsize: DesignConstants.fontSize24,fontWeight: FontWeight.w400),
                const Spacer(),
                SizedBox(
                  width: 150,
                  height: 50,
                  child: Card(
                    elevation: 20,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        color: Colors.white,
                      ),
                      borderRadius: BorderRadius.circular(15),

                    ),
                  ),
                ),
                const Spacer(),
                IconButton(icon: const Icon(Icons.upload,size: 25),onPressed: () {

                },),
              ],
            ),
          ),
          const SizedBox(
            height: DesignConstants.padding10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                shadowText(text: 'Profile Upload',fontsize: DesignConstants.fontSize24,fontWeight: FontWeight.w400),
                const Spacer(),
                const SizedBox(
                  width: 150,
                  height: 100,
                  child: Card(
                    elevation: 20,
                    color: Colors.white,
                    shape: CircleBorder(
                      side: BorderSide(
                        color: Colors.white,
                      ),

                    ),
                  ),
                ),
                const Spacer(),
                IconButton(icon: const Icon(Icons.upload,size: 25),onPressed: () {

                },),
              ],
            ),
          ),
          const SizedBox(
            height: DesignConstants.padding20,
          ),
        ],
      ),
    );
  }
}
