import 'package:flutter/material.dart';
import 'package:frontend/controllers/goals_controller.dart';
import 'package:frontend/screens/goals/active_goals_screen.dart';
import 'package:frontend/screens/goals/add_goal_screen.dart';
import 'package:frontend/screens/goals/reached_goals_screen.dart';
import 'package:get/get.dart';

import '../../utils/constants.dart';

class GoalsScreen extends StatelessWidget {
  static const String routeName = '/goalsScreen';
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GoalsController goalsController = Get.put(GoalsController());

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pushNamed(AddGoalScreen.routeName);
          },
          backgroundColor: kBackColor,
          child: const Icon(Icons.add),
        ),
        appBar: AppBar(
          title: const Text("Goals"),
          backgroundColor: kBackColor,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),
          bottom: const TabBar(
            tabs: [Tab(text: "ACTIVE"), Tab(text: "REACHED")],
            indicatorColor: Colors.white,
          ),
        ),
        body: TabBarView(
          physics: const BouncingScrollPhysics(),
          children: [ActiveGoalScreen(), ReachedGoalScreen()],
        ),
      ),
    );
  }
}
