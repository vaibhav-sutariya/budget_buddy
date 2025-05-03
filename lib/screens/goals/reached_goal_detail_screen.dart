import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'package:get/get.dart';

import '../../controllers/goals_controller.dart';
import '../../models/goal.dart';
import '../../utils/constants.dart';

class ReachedGoalDetailScreen extends StatefulWidget {
  static const String routeName = '/reachedGoalDetailScreen';
  final Goal goal;

  const ReachedGoalDetailScreen(
      {Key? key, required this.goal})
      : super(key: key);

  @override
  _ReachedGoalDetailScreenState createState() =>
      _ReachedGoalDetailScreenState();
}

class _ReachedGoalDetailScreenState extends State<ReachedGoalDetailScreen> {
  final GoalsController _goalsController = Get.put(GoalsController());
  String goalName = "";
  String goalImg = "";

  int indexOfPassedGoal = 0;

  @override
  void initState() {
    goalName = _goalsController.getCategoryName(widget.goal.category);
    goalImg = _goalsController.getCategoryImagePath(widget.goal.category);
    super.initState();
  }

  TextEditingController savedAmountController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Reached goal detail",
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
                _goalsController.deleteGoal(widget.goal.id, true);
                Navigator.of(context).pop();
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              )),
        ],
      ),
      body: Column(
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
                          "Target date ${widget.goal.day}/${widget.goal.month}/${widget.goal.year}",
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  percent: ((widget.goal.savedAmount *
                      100) /
                      widget.goal.targetAmount) /
                      100.0,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AutoSizeText(
                        "${(((widget.goal.savedAmount * 100) / widget.goal.targetAmount) / 100.0 * 100.0).toStringAsFixed(0)} %",
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
                        "${widget.goal.savedAmount} / ${widget.goal.targetAmount}",
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
                  padding: const EdgeInsets.only(left: 45.0, right: 45.0),
                  child: Center(
                    child: Text(
                      widget.goal.desc,
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
        ],
      ),
    );
  }
}
