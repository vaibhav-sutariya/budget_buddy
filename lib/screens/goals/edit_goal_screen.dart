import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/controllers/goals_controller.dart';
import 'package:frontend/utils/constants.dart';
import 'package:frontend/utils/errFlushbar.dart';
import 'package:get/get.dart';

import '../../components/custom_textform_field.dart';
import '../../models/goal.dart';

class EditGoalScreen extends StatefulWidget {
  static const String routeName = '/editGoalScreen';
  final Goal goal;

  const EditGoalScreen({super.key, required this.goal});

  @override
  _EditGoalScreenState createState() => _EditGoalScreenState();
}

class _EditGoalScreenState extends State<EditGoalScreen> {
  TextEditingController targetAmountController = TextEditingController();
  TextEditingController savedAmountController = TextEditingController();
  TextEditingController descController = TextEditingController();
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
  final GoalsController _goalsController = Get.put(GoalsController());

  @override
  void initState() {
    targetAmountController.text = widget.goal.targetAmount.toString();
    savedAmountController.text = widget.goal.savedAmount.toString();
    descController.text = widget.goal.desc;
    tempDate = DateTime(widget.goal.year, widget.goal.month, widget.goal.day);
    finalDate = DateTime(widget.goal.year, widget.goal.month, widget.goal.day);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (formKey.currentState!.validate()) {
            double ta = double.parse(targetAmountController.text);
            double sa = double.parse(savedAmountController.text);
            if (ta < sa) {
              return showErrFlushBar(
                context,
                "Warning",
                "Target amount must be >= saved amount",
              );
            }
            Map<String, dynamic> updatedGoal = {
              "g_desc": descController.text,
              "g_target_amount": ta,
              "g_saved_amount": sa,
              "g_day": finalDate.day,
              "g_month": finalDate.month,
              "g_year": finalDate.year,
            };
            _goalsController.editGoal(updatedGoal, widget.goal.id);
            Navigator.of(context).pop();
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
                                  "Edit goal",
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
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 45.0),
                  Expanded(
                    flex: 2,
                    child: CustomTextField(
                      controller: targetAmountController,
                      label: "Target amount",
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
                  Expanded(
                    flex: 2,
                    child: CustomTextField(
                      controller: savedAmountController,
                      label: "Saved already",
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
                    controller: descController,
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
                                    minimumDate: DateTime.now(),
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
