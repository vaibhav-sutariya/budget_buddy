import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/components/loader.dart';
import 'package:frontend/utils/constants.dart';
import 'package:frontend/utils/errFlushbar.dart';
import 'package:get/get.dart';

import '../../components/custom_textform_field.dart';
import '../../controllers/debtors_controller.dart';

class AddDebtorScreen extends StatefulWidget {
  static const String routeName = '/addDebtorScreen';
  const AddDebtorScreen({super.key});

  @override
  _AddDebtorScreenState createState() => _AddDebtorScreenState();
}

class _AddDebtorScreenState extends State<AddDebtorScreen> {
  final TextEditingController _debtorNameController = TextEditingController();
  final TextEditingController _debtorAmountController = TextEditingController();
  final TextEditingController _debtorMobileController = TextEditingController();
  final TextEditingController _debtorDescController = TextEditingController();
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

  final DebtorsController _debtorsController = Get.put(DebtorsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (formKey.currentState!.validate()) {
            if (_debtorMobileController.text.length == 10) {
              Map<String, dynamic> debtor = {
                "deb_name": _debtorNameController.text,
                "deb_mobile": _debtorMobileController.text,
                "deb_amount": _debtorAmountController.text.trim(),
                "deb_desc": _debtorDescController.text,
                "deb_day": finalDate.day,
                "deb_month": finalDate.month,
                "deb_year": finalDate.year,
              };
              showLoader(context);
              await _debtorsController.addDebtor(debtor);
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
                            "Add debtor",
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
                      controller: _debtorNameController,
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
                      controller: _debtorAmountController,
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
                    controller: _debtorMobileController,
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
                    controller: _debtorDescController,
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
