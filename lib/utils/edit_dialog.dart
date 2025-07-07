import 'package:billing/controllers/search_add_client_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../model/customer_response_model.dart';

class EditCustomerDialog extends StatefulWidget {
  final Datum customer;
  final void Function(Datum updatedCustomer) onSave;

  EditCustomerDialog({required this.customer, required this.onSave});

  @override
  _EditCustomerDialogState createState() => _EditCustomerDialogState();
}

class _EditCustomerDialogState extends State<EditCustomerDialog> {

  SearchAddClientController searchAddClientController = Get.find<SearchAddClientController>();

  late TextEditingController nameCtrl;
  late TextEditingController mobileCtrl;
  late TextEditingController gstCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController addressCtrl;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.customer.name);
    mobileCtrl = TextEditingController(text: widget.customer.mobileNo);
    gstCtrl = TextEditingController(text: widget.customer.gstNo ?? '');
    emailCtrl = TextEditingController(text: widget.customer.emailId ?? '');
    addressCtrl = TextEditingController(text: widget.customer.address);
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
            TextField(controller: nameCtrl, decoration: InputDecoration(labelText: "Name")),
            TextField(controller: mobileCtrl, decoration: InputDecoration(labelText: "Mobile")),
            TextField(controller: gstCtrl, decoration: InputDecoration(labelText: "GST")),
            TextField(controller: emailCtrl, decoration: InputDecoration(labelText: "Email")),
            TextField(controller: addressCtrl, decoration: InputDecoration(labelText: "Address")),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text("Cancel")),
        ElevatedButton(
          onPressed: () {
            searchAddClientController.updateClientPostApi(
              custId: widget.customer.custId,
              name: nameCtrl.text,
              mobileNo: mobileCtrl.text,
              gstNo: gstCtrl.text,
              emailId: emailCtrl.text,
              address: addressCtrl.text,
            );
            Datum updated = Datum(
              custId: widget.customer.custId,
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
