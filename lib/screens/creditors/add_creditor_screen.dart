import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/components/loader.dart';
import 'package:frontend/controllers/creditors_controller.dart';
import 'package:frontend/utils/constants.dart';
import 'package:get/get.dart';

import '../../components/custom_textform_field.dart';
import '../../utils/errFlushbar.dart';

class AddCreditorScreen extends StatefulWidget {
  static const String routeName = '/addCreditorScreen';
  const AddCreditorScreen({super.key});

  @override
  _AddCreditorScreenState createState() => _AddCreditorScreenState();
}

class _AddCreditorScreenState extends State<AddCreditorScreen> {
  final TextEditingController _creditorNameController = TextEditingController();
  final TextEditingController _creditorAmountController =
      TextEditingController();
  final TextEditingController _creditorMobileController =
      TextEditingController();
  final TextEditingController _creditorDescController = TextEditingController();
  DateTime tempDate = DateTime.now();
  DateTime finalDate = DateTime.now();

  final formKey = GlobalKey<FormState>();

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

  final CreditorsController _creditorsController = Get.put(
    CreditorsController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (formKey.currentState!.validate()) {
            if (_creditorMobileController.text.length == 10) {
              Map<String, dynamic> creditor = {
                "cre_name": _creditorNameController.text,
                "cre_mobile": _creditorMobileController.text,
                "cre_amount": _creditorAmountController.text.trim(),
                "cre_desc": _creditorDescController.text,
                "cre_day": finalDate.day,
                "cre_month": finalDate.month,
                "cre_year": finalDate.year,
              };
              showLoader(context);
              await _creditorsController.addCreditor(creditor);
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
                            "Add creditor",
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
                      formatter: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r"^\d+\.?\d{0,2}$"),
                        ),
                      ],
                      isPrefix: true,
                      prefix: "₹",
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
                    focusedColor: Colors.black,
                    autoFocus: true,
                    inputType: TextInputType.number,
                    formatter: [FilteringTextInputFormatter.digitsOnly],
                    isPrefix: true,
                    prefix: "+91",
                    enforceMaxLength10: true,
                  ),
                  CustomTextField(
                    controller: _creditorDescController,
                    label: "Description",
                    enabledColor: Colors.grey,
                    focusedColor: Colors.black,
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
                                    //maximumDate: DateTime.now(),
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
                                          foregroundColor: kErrorColor,
                                        ),
                                        icon: Icon(
                                          Icons.close,
                                          color: kErrorColor,
                                        ),
                                        label: Text(
                                          "CANCEL",
                                          style: TextStyle(color: kErrorColor),
                                        ),
                                      ),
                                      TextButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            finalDate = tempDate;
                                            Navigator.of(context).pop();
                                          });
                                        },
                                        icon: Icon(
                                          Icons.check,
                                          color: kSuccessColor,
                                        ),
                                        style: TextButton.styleFrom(
                                          foregroundColor: kSuccessColor,
                                        ),
                                        label: Text(
                                          "OK",
                                          style: TextStyle(
                                            color: kSuccessColor,
                                          ),
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
                    focusedColor: Colors.black,
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
