import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:frontend/components/custom_textform_field.dart';
import 'package:frontend/controllers/goals_controller.dart';
import 'package:get/get.dart';

import '../../utils/constants.dart';
import '../../utils/errFlushbar.dart';

class AddGoalScreen extends StatefulWidget {
  static const String routeName = '/addGoalScreen';
  const AddGoalScreen({super.key});

  @override
  _AddGoalScreenState createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  int selected = 0;
  String selectedCategoryID = "";

  TextEditingController goalDescController = TextEditingController();
  TextEditingController goalTargetAmtController = TextEditingController();
  TextEditingController goalSavedAmtController = TextEditingController();
  TextEditingController goalDateController = TextEditingController();

  DateTime tempDate = DateTime.now();
  DateTime finalDate = DateTime.now();
  final descFormKey = GlobalKey<FormState>();

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

  final GoalsController _goalsController = Get.put(GoalsController());

  @override
  void initState() {
    selectedCategoryID = _goalsController.goalCategories[0].id;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (descFormKey.currentState!.validate()) {
            double ta = double.parse(goalTargetAmtController.text);
            double sa = double.parse(goalSavedAmtController.text);
            if (ta < sa) {
              return showErrFlushBar(
                context,
                "Warning",
                "Target amount must be >= saved amount",
              );
            }
            Map<String, dynamic> goal = {
              "g_target_amount": ta,
              "g_saved_amount": sa,
              "g_desc": goalDescController.text.trim(),
              "g_day": finalDate.day,
              "g_month": finalDate.month,
              "g_year": finalDate.year,
              "gc_id": selectedCategoryID,
            };
            _goalsController.addGoal(goal);
            Navigator.of(context).pop();
          }
        },
        backgroundColor: kBackColor,
        child: const Icon(Icons.arrow_forward),
      ),
      appBar: AppBar(
        title: const Text("Create Goal"),
        backgroundColor: kBackColor,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.close),
        ),
      ),
      body: Obx(
        () => Container(
          color: Colors.white10,
          child: Form(
            key: descFormKey,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    "What are you saving for ?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                      fontFamily: "CircularStd",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                CustomTextField(
                  controller: goalDescController,
                  label: "Goal Description",
                  inputType: TextInputType.text,
                  focusedColor: Colors.grey.shade600,
                  enabledColor: Colors.grey.shade300,
                ),
                CustomTextField(
                  controller: goalTargetAmtController,
                  label: "Target amount",
                  formatter: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r"^\d+\.?\d{0,2}$"),
                    ),
                  ],
                  isPrefix: true,
                  prefix: "₹",
                  inputType: TextInputType.number,
                  focusedColor: Colors.grey.shade600,
                  enabledColor: Colors.grey.shade300,
                ),
                CustomTextField(
                  controller: goalSavedAmtController,
                  label: "Saved already",
                  isPrefix: true,
                  prefix: "₹",
                  inputType: TextInputType.number,
                  formatter: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r"^\d+\.?\d{0,2}$"),
                    ),
                  ],
                  focusedColor: Colors.grey.shade600,
                  enabledColor: Colors.grey.shade300,
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
                                        style: TextStyle(color: kSuccessColor),
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
                  focusedColor: Colors.grey.shade300,
                ),
                Expanded(
                  child: MasonryGridView.count(
                    physics: const BouncingScrollPhysics(),
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    padding: const EdgeInsets.all(6.0),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            selected = index;
                            selectedCategoryID =
                                _goalsController.goalCategories[index].id;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                selected == index
                                    ? kBackColor.withOpacity(0.15)
                                    : Colors.grey.shade100,
                          ),
                          height: 140.0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/images/goals/${_goalsController.goalCategories[index].imgSrc}",
                                height: 45.0,
                              ),
                              const SizedBox(height: 20.0),
                              Text(
                                _goalsController.goalCategories[index].name,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontFamily: "CircularStd",
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    itemCount: _goalsController.goalCategories.length,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
