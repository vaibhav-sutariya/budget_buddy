import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../controllers/goals_controller.dart';
import '../../utils/constants.dart';
import '../../utils/custom_loader.dart';
import 'goal_detail_screen.dart';

class ActiveGoalScreen extends StatelessWidget {
  static const String routeName = '/activeGoalScreen';
  ActiveGoalScreen({Key? key}) : super(key: key);

  final GoalsController _goalsController = Get.put(GoalsController());
  @override
  Widget build(BuildContext context) {

    return Obx(
          () => _goalsController.loading.value
          ? showCustomLoader(kBackColor)
          : _goalsController.goals.isEmpty
          ? Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "No goals found",
                style: TextStyle(
                  color: Colors.red.shade300,
                  fontFamily: "CircularStd",
                  fontWeight: FontWeight.w600,
                  fontSize: 18.0,
                ),
              ),
            ),
            const Text(
              "Tap + to add one",
              style: TextStyle(
                  color: Colors.grey, fontFamily: "CircularStd"),
            ),
          ],
        ),
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12.0,right: 12.0,top: 24.0,bottom: 8.0),
            child: Text(
              "How much I already saved ?",
              style: TextStyle(
                fontFamily: "CircularStd",
                fontSize: 16.0,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Material(
                elevation: 2.0,
                child: Container(
                  color: Colors.white,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, i) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 2, vertical: 6),
                            child: ListTile(
                              title: Column(
                                children: [
                                  Text(
                                    _goalsController
                                        .getCategoryName(
                                        _goalsController
                                            .goals[i].category),
                                    style: const TextStyle(
                                      fontFamily: "CircularStd",
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "₹ ${_goalsController.goals[i].savedAmount}",
                                        style: TextStyle(
                                          color: kSuccessColor,
                                          fontSize: 12.0,
                                        ),
                                      ),
                                      Text(
                                        "${((_goalsController.goals[i].savedAmount * 100) / _goalsController.goals[i].targetAmount).toStringAsFixed(0)} %",
                                        style: TextStyle(
                                          color: kSuccessColor,
                                          fontWeight:
                                          FontWeight.bold,
                                          fontSize: 12.0,
                                        ),
                                      ),
                                    ],
                                    mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                  ),
                                  const SizedBox(
                                    height: 8.0,
                                  ),
                                  LinearPercentIndicator(
                                    padding:
                                    const EdgeInsets.all(2.0),
                                    backgroundColor: Colors.grey
                                        .withOpacity(0.3),
                                    lineHeight: 10.0,
                                    percent: double.parse(
                                        ((_goalsController
                                            .goals[
                                        i]
                                            .savedAmount *
                                            100) /
                                            _goalsController
                                                .goals[i]
                                                .targetAmount)
                                            .toStringAsFixed(
                                            0)) /
                                        100.0,
                                    progressColor: kBackColor,
                                  ),
                                ],
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                              ),
                              leading: Image.asset(
                                "assets/images/goals/${_goalsController.getCategoryImagePath(_goalsController.goals[i].category)}",
                                height: 35.0,
                                width: 35.0,
                              ),
                              trailing: Container(
                                color: kBackColor
                                    .withOpacity(0.1),
                                padding: const EdgeInsets.all(3.0),
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  color: kBackColor,
                                  size: 18.0,
                                ),
                              ),
                              onTap: () {
                                Navigator.of(context).pushNamed(GoalDetailScreen.routeName,arguments: _goalsController
                                    .goals[i].id);
                              },
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 2.0, horizontal: 18.0),
                            child: Divider(),
                          ),
                        ],
                      );
                    },
                    itemCount: _goalsController.goals.length,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
