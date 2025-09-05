import 'package:billing/controllers/search_add_client_controller.dart';
import 'package:billing/model/purchaser_response_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../model/customer_response_model.dart';

class EditCustomerDialog extends StatefulWidget {
  final Datum? customer;
  final PurchaserData? purchaser;
  final void Function(dynamic updatedCustomer) onSave;

  EditCustomerDialog({this.customer, required this.onSave, this.purchaser});

  @override
  _EditCustomerDialogState createState() => _EditCustomerDialogState();
}

class _EditCustomerDialogState extends State<EditCustomerDialog> {
  SearchAddClientController searchAddClientController =
      Get.find<SearchAddClientController>();

  late TextEditingController nameCtrl;
  late TextEditingController mobileCtrl;
  late TextEditingController gstCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController addressCtrl;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: searchAddClientController.addPurchaser.value? widget.purchaser?.purchaserName :widget.customer?.name);
    mobileCtrl = TextEditingController(text: searchAddClientController.addPurchaser.value? widget.purchaser?.mobileNo :widget.customer?.mobileNo);
    gstCtrl = TextEditingController(text: searchAddClientController.addPurchaser.value? widget.purchaser?.gstNo :widget.customer?.gstNo ?? '');
    emailCtrl = TextEditingController(text: searchAddClientController.addPurchaser.value? widget.purchaser?.emailId :widget.customer?.emailId ?? '');
    addressCtrl = TextEditingController(text: searchAddClientController.addPurchaser.value? widget.purchaser?.address :widget.customer?.address);
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    mobileCtrl.dispose();
    gstCtrl.dispose();
    emailCtrl.dispose();
    addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Edit Client"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
                controller: nameCtrl,
                decoration: InputDecoration(labelText: "Name")),
            TextField(
                controller: mobileCtrl,
                decoration: InputDecoration(labelText: "Mobile")),
            TextField(
                controller: gstCtrl,
                decoration: InputDecoration(labelText: "GST")),
            TextField(
                controller: emailCtrl,
                decoration: InputDecoration(labelText: "Email")),
            TextField(
                controller: addressCtrl,
                decoration: InputDecoration(labelText: "Address")),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel")),
        ElevatedButton(
          onPressed: () {
            // Call appropriate API
            if (searchAddClientController.addPurchaser.value) {
              searchAddClientController.updatePurchaserPostApi(
                purId: widget.purchaser?.purchaserId,
                name: nameCtrl.text,
                mobileNo: mobileCtrl.text,
                gstNo: gstCtrl.text,
                emailId: emailCtrl.text,
                address: addressCtrl.text,
              );
            } else {
              searchAddClientController.updateClientPostApi(
                custId: widget.customer?.custId,
                name: nameCtrl.text,
                mobileNo: mobileCtrl.text,
                gstNo: gstCtrl.text,
                emailId: emailCtrl.text,
                address: addressCtrl.text,
              );
            }

            // Build data based on condition
            final updated = searchAddClientController.addPurchaser.value
                ? PurchaserData(
                    purchaserId: widget.purchaser?.purchaserId,
                    purchaserName: nameCtrl.text,
                    mobileNo: mobileCtrl.text,
                    gstNo: gstCtrl.text,
                    emailId: emailCtrl.text,
                    address: addressCtrl.text,
                  )
                : Datum(
                    custId: widget.customer?.custId,
                    name: nameCtrl.text,
                    mobileNo: mobileCtrl.text,
                    gstNo: gstCtrl.text,
                    emailId: emailCtrl.text,
                    address: addressCtrl.text,
                  );

            widget.onSave(updated);
            // Navigator.of(context).pop();
          },
          child: Text("Save"),
        ),
      ],
    );
  }
}
