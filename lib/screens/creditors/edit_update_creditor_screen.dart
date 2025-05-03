import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/components/loader.dart';
import 'package:frontend/controllers/creditors_controller.dart';
import 'package:frontend/models/creditor.dart';
import 'package:frontend/utils/constants.dart';
import 'package:get/get.dart';

import '../../components/custom_textform_field.dart';
import '../../utils/errFlushbar.dart';

class UpdateDeleteCreditorScreen extends StatefulWidget {
  static const String routeName = '/UpdateDeleteCreditorScreen';
  final Creditor creditor;

  const UpdateDeleteCreditorScreen({super.key, required this.creditor});

  @override
  _UpdateDeleteCreditorScreenState createState() =>
      _UpdateDeleteCreditorScreenState();
}

class _UpdateDeleteCreditorScreenState
    extends State<UpdateDeleteCreditorScreen> {
  final TextEditingController _creditorNameController = TextEditingController();
  final TextEditingController _creditorAmountController =
      TextEditingController();
  final TextEditingController _creditorMobileController =
      TextEditingController();
  final TextEditingController _creditorDescController = TextEditingController();
  DateTime tempDate = DateTime.now();
  DateTime finalDate = DateTime.now();

  List allMonths = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  final formKey = GlobalKey<FormState>();
  final CreditorsController _creditorsController = Get.put(
    CreditorsController(),
  );

  @override
  void initState() {
    _creditorNameController.text = widget.creditor.name;
    _creditorAmountController.text = widget.creditor.amount.toString();
    _creditorMobileController.text = widget.creditor.mobile;
    _creditorDescController.text = widget.creditor.desc;
    finalDate = DateTime(
      widget.creditor.year,
      widget.creditor.month,
      widget.creditor.day,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (formKey.currentState!.validate()) {
            if (_creditorMobileController.text.length == 10) {
              Map<String, dynamic> updatedCreditor = {
                "cre_name": _creditorNameController.text,
                "cre_mobile": _creditorMobileController.text,
                "cre_amount": _creditorAmountController.text,
                "cre_desc": _creditorDescController.text,
                "cre_day": finalDate.day,
                "cre_month": finalDate.month,
                "cre_year": finalDate.year,
              };
              showLoader(context);
              await _creditorsController.editCreditor(
                updatedCreditor,
                widget.creditor.id,
              );
              stopLoader();
              Navigator.of(context).pop();
            } else {
              showErrFlushBar(context, "Warning", "Enter valid mobile number");
            }
          }
        },
        backgroundColor: kSuccessColor,
        child: const Icon(Icons.save, color: Colors.white),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.35,
              color: kBackColor,
              child: Column(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50.0,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 25.0,
                                  ),
                                ),
                                const SizedBox(width: 12.0),
                                const Text(
                                  "Edit creditor",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: "CircularStd",
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: IconButton(
                                onPressed: () async {
                                  showLoader(context);
                                  await _creditorsController.deleteCreditor(
                                    widget.creditor.id,
                                  );
                                  stopLoader();
                                  Navigator.of(context).pop();
                                },
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 25.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 45.0),
                  Expanded(
                    flex: 2,
                    child: CustomTextField(
                      controller: _creditorNameController,
                      label: "Name",
                      enabledColor: Colors.grey,
                      focusedColor: Colors.white,
                      autoFocus: true,
                      inputType: TextInputType.name,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: CustomTextField(
                      controller: _creditorAmountController,
                      label: "Amount",
                      enabledColor: Colors.grey,
                      focusedColor: Colors.white,
                      inputType: TextInputType.number,
                      prefix: "₹",
                      formatter: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r"^\d+\.?\d{0,2}$"),
                        ),
                      ],
                      isPrefix: true,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.65,
              color: Colors.white,
              child: Column(
                children: [
                  const SizedBox(height: 45.0),
                  CustomTextField(
                    controller: _creditorMobileController,
                    label: "Mobile number",
                    enabledColor: Colors.grey,
                    focusedColor: kBackColor,
                    autoFocus: true,
                    inputType: TextInputType.phone,
                    formatter: [FilteringTextInputFormatter.digitsOnly],
                    isPrefix: true,
                    prefix: "+91",
                    enforceMaxLength10: true,
                  ),
                  CustomTextField(
                    controller: _creditorDescController,
                    label: "Description",
                    enabledColor: Colors.grey,
                    focusedColor: kBackColor,
                    inputType: TextInputType.text,
                  ),
                  getCustomDatePicker(
                    callback: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return SizedBox(
                            height: MediaQuery.of(context).size.height * 0.35,
                            child: Column(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: CupertinoDatePicker(
                                    onDateTimeChanged: (val) {
                                      setState(() {
                                        tempDate = val;
                                      });
                                    },
                                    initialDateTime: finalDate,
                                    mode: CupertinoDatePickerMode.date,
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextButton.icon(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.red,
                                        ),
                                        label: const Text(
                                          "CANCEL",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                      TextButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            finalDate = tempDate;
                                            Navigator.of(context).pop();
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.check,
                                          color: Colors.green,
                                        ),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.green,
                                        ),
                                        label: const Text(
                                          "OK",
                                          style: TextStyle(color: Colors.green),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    labelText:
                        "${finalDate.day} ${allMonths[finalDate.month - 1]}, ${finalDate.year}",
                    focusedColor: kBackColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
