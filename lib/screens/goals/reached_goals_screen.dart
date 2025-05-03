import 'package:flutter/material.dart';
import 'package:frontend/screens/goals/reached_goal_detail_screen.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../controllers/goals_controller.dart';
import '../../utils/constants.dart';
import '../../utils/custom_loader.dart';

class ReachedGoalScreen extends StatelessWidget {
  ReachedGoalScreen({super.key});
  final GoalsController _goalsController = Get.put(GoalsController());
  @override
  Widget build(BuildContext context) {
    return Obx(
      () =>
          _goalsController.loading.value
              ? showCustomLoader(kBackColor)
              : _goalsController.reachedGoals.isEmpty
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
                        color: Colors.grey,
                        fontFamily: "CircularStd",
                      ),
                    ),
                  ],
                ),
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                                      horizontal: 2,
                                      vertical: 6,
                                    ),
                                    child: ListTile(
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _goalsController.getCategoryName(
                                              _goalsController
                                                  .reachedGoals[i]
                                                  .category,
                                            ),
                                            style: const TextStyle(
                                              fontFamily: "CircularStd",
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "₹ ${_goalsController.reachedGoals[i].savedAmount}",
                                                style: TextStyle(
                                                  color: kSuccessColor,
                                                  fontSize: 12.0,
                                                ),
                                              ),
                                              Text(
                                                "${((_goalsController.reachedGoals[i].savedAmount * 100) / _goalsController.reachedGoals[i].targetAmount).toStringAsFixed(0)} %",
                                                style: TextStyle(
                                                  color: kSuccessColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8.0),
                                          LinearPercentIndicator(
                                            padding: const EdgeInsets.all(2.0),
                                            backgroundColor: Colors.grey
                                                .withOpacity(0.3),
                                            lineHeight: 10.0,
                                            percent:
                                                double.parse(
                                                  ((_goalsController
                                                                  .reachedGoals[i]
                                                                  .savedAmount *
                                                              100) /
                                                          _goalsController
                                                              .reachedGoals[i]
                                                              .targetAmount)
                                                      .toStringAsFixed(0),
                                                ) /
                                                100.0,
                                            progressColor: kBackColor,
                                          ),
                                        ],
                                      ),
                                      leading: Image.asset(
                                        "assets/images/goals/${_goalsController.getCategoryImagePath(_goalsController.reachedGoals[i].category)}",
                                        height: 35.0,
                                        width: 35.0,
                                      ),
                                      trailing: Container(
                                        color: kBackColor.withOpacity(0.15),
                                        padding: const EdgeInsets.all(3.0),
                                        child: Icon(
                                          Icons.arrow_forward_ios,
                                          color: kBackColor,
                                          size: 18.0,
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.of(context).pushNamed(
                                          ReachedGoalDetailScreen.routeName,
                                          arguments:
                                              _goalsController.reachedGoals[i],
                                        );
                                      },
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 2.0,
                                      horizontal: 18.0,
                                    ),
                                    child: Divider(),
                                  ),
                                ],
                              );
                            },
                            itemCount: _goalsController.reachedGoals.length,
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
