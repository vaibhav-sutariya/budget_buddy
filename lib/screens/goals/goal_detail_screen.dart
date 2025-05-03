import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../controllers/goals_controller.dart';
import '../../utils/constants.dart';
import 'package:get/get.dart';
import 'edit_goal_screen.dart';

class GoalDetailScreen extends StatefulWidget {
  static const String routeName = '/goalDetailScreen';
  final String goalID;

  const GoalDetailScreen({Key? key, required this.goalID}) : super(key: key);

  @override
  _GoalDetailScreenState createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  final GoalsController _goalsController = Get.put(GoalsController());
  String goalName = "";
  String goalImg = "";

  int indexOfPassedGoal = 0;

  @override
  void initState() {
    indexOfPassedGoal =
        _goalsController.findIndexOfTheGoalWithGivenID(widget.goalID);
    goalName = _goalsController
        .getCategoryName(_goalsController.goals[indexOfPassedGoal].category);
    goalImg = _goalsController.getCategoryImagePath(
        _goalsController.goals[indexOfPassedGoal].category);
    super.initState();
  }

  TextEditingController savedAmountController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  _displayTextInputDialog(
      BuildContext context, double saved, double target) async {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: contentBox(context, saved, target),
          );
        });
  }

  contentBox(context, double saved, double target) {
    savedAmountController.text = "";
    return Stack(
      children: <Widget>[
        Container(
          padding:
              const EdgeInsets.only(left: 20.0, top: 0.0 + 20.0, right: 20.0),
          margin: const EdgeInsets.only(top: 35.0),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.0),
            boxShadow: [
              BoxShadow(
                  color: kBackColor, offset: const Offset(0, 8), blurRadius: 0),
            ],
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                TextFormField(
                  controller: savedAmountController,
                  autofocus: true,
                  cursorColor: kBackColor,
                  keyboardType: TextInputType.number,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r"^\d+\.?\d{0,2}$"),
                    ),
                  ],
                  validator: (val) {
                    if (val!.isEmpty) {
                      return "*required";
                    } else if (double.parse(val) > target - saved) {
                      return "Amount > target amount can not be added";
                    }
                    return null;
                  },
                  style: TextStyle(
                    color: kBackColor,
                  ),
                  decoration: InputDecoration(
                    labelText: "Amount",
                    hintText: "0.0",
                    prefix: Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: Text(
                        "₹",
                        style: TextStyle(color: kBackColor),
                      ),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey,
                        width: 2.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: kBackColor,
                        width: 2.0,
                      ),
                    ),
                    labelStyle: TextStyle(
                      color: kBackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 15.0, top: 15.0, bottom: 15.0),
                    child: ElevatedButton(
                      child: const Text("Add"),
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          Map<String, dynamic> data = {
                            "g_saved_amount": _goalsController
                                    .goals[indexOfPassedGoal].savedAmount +
                                double.parse(savedAmountController.text),
                          };
                          _goalsController.editGoal(data,
                              _goalsController.goals[indexOfPassedGoal].id);
                          Navigator.of(context).pop();
                          savedAmountController.text = "";
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          foregroundColor: kSuccessColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 20.0,
          right: 20.0,
          child: CircleAvatar(
            backgroundColor: kBackColor,
            radius: 35.0,
            child: const ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              child: Text(
                "₹",
                style: TextStyle(
                  fontFamily: "CircularStd",
                  fontSize: 30.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Goal detail",
          style: TextStyle(
            fontFamily: "CircularStd",
          ),
        ),
        backgroundColor: kBackColor,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(EditGoalScreen.routeName,
                  arguments: _goalsController.goals[indexOfPassedGoal]);
            },
            icon: const Icon(Icons.create),
          ),
          IconButton(
            onPressed: () {
              _goalsController.deleteGoal(
                  _goalsController.goals[indexOfPassedGoal].id, false);
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
              size: 25.0,
            ),
          ),
        ],
      ),
      body: Obx(
        () {
          try {
            return _goalsController.goals
                    .contains(_goalsController.goals[indexOfPassedGoal])
                ? Column(
                    children: [
                      Expanded(
                        child: ListView(
                          physics: const BouncingScrollPhysics(),
                          children: [
                            const SizedBox(
                              height: 8.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                title: Column(
                                  children: [
                                    Text(
                                      goalName,
                                      style: const TextStyle(
                                        fontFamily: "CircularStd",
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    Text(
                                      "Target date ${_goalsController.goals[indexOfPassedGoal].day}/${_goalsController.goals[indexOfPassedGoal].month}/${_goalsController.goals[indexOfPassedGoal].year}",
                                      style: const TextStyle(
                                        fontFamily: "CircularStd",
                                        fontWeight: FontWeight.w400,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 8.0,
                                    ),
                                  ],
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                ),
                                leading: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Image.asset(
                                    "assets/images/goals/$goalImg",
                                    height: 35.0,
                                    width: 35.0,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 14.0,
                            ),
                            CircularPercentIndicator(
                              radius: 100.0,
                              animation: true,
                              animationDuration: 800,
                              lineWidth: 11.0,
                              percent: ((_goalsController
                                              .goals[indexOfPassedGoal]
                                              .savedAmount *
                                          100) /
                                      _goalsController.goals[indexOfPassedGoal]
                                          .targetAmount) /
                                  100.0,
                              center: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AutoSizeText(
                                    "${(((_goalsController.goals[indexOfPassedGoal].savedAmount * 100) / _goalsController.goals[indexOfPassedGoal].targetAmount) / 100.0 * 100.0).toStringAsFixed(0)} %",
                                    overflow: TextOverflow.visible,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "CircularStd",
                                      fontSize: 50.0,
                                      color: kSuccessColor,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 14.0,
                                  ),
                                  Text(
                                    "${_goalsController.goals[indexOfPassedGoal].savedAmount} / ${_goalsController.goals[indexOfPassedGoal].targetAmount}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15.0,
                                        color: Colors.grey,
                                        fontFamily: "CircularStd"),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: Text(
                                      "₹",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15.0,
                                        fontFamily: "CircularStd",
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              circularStrokeCap: CircularStrokeCap.round,
                              backgroundColor: Colors.grey.shade300,
                              backgroundWidth: 5.0,
                              progressColor: kBackColor,
                            ),
                            const SizedBox(
                              height: 42.0,
                            ),
                            const Center(
                              child: Text(
                                "Description",
                                style: TextStyle(
                                  fontFamily: "CircularStd",
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 40.0, right: 40.0),
                              child: Divider(),
                            ),
                            const SizedBox(
                              height: 14.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 45.0, right: 45.0),
                              child: Center(
                                child: Text(
                                  _goalsController
                                      .goals[indexOfPassedGoal].desc,
                                  overflow: TextOverflow.visible,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: "CircularStd",
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                    fontSize: 15.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Material(
                        elevation: 8.0,
                        child: Container(
                          height: 110.0,
                          width: double.infinity,
                          color: Colors.white,
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 8.0,
                              ),
                              SizedBox(
                                child: ElevatedButton(
                                  onPressed: () {
                                    _displayTextInputDialog(
                                        context,
                                        _goalsController
                                            .goals[indexOfPassedGoal]
                                            .savedAmount,
                                        _goalsController
                                            .goals[indexOfPassedGoal]
                                            .targetAmount);
                                  },
                                  child: const Text(
                                    "ADD SAVED AMOUNT",
                                    style: TextStyle(
                                      fontFamily: "CircularStd",
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: kSuccessColor,
                                  ),
                                ),
                                width: MediaQuery.of(context).size.width * 0.7,
                              ),
                              SizedBox(
                                child: TextButton(
                                  onPressed: () async {
                                    await _goalsController.editGoal(
                                      {
                                        "is_reached": true,
                                      },
                                      _goalsController
                                          .goals[indexOfPassedGoal].id,
                                    );
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    "SET GOAL AS REACHED",
                                    style: TextStyle(
                                      fontFamily: "CircularStd",
                                      fontWeight: FontWeight.bold,
                                      color: kErrorColor,
                                    ),
                                  ),
                                  style: ButtonStyle(
                                    overlayColor:
                                        MaterialStateColor.resolveWith(
                                            (states) => Colors.red.shade50),
                                  ),
                                ),
                                width: MediaQuery.of(context).size.width * 0.7,
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  )
                : const Center(
                    child: Text("Empty"),
                  );
          } catch (e) {
            return Container();
          }
        },
      ),
    );
  }
}
