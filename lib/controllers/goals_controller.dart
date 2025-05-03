import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:frontend/utils/constants.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../models/goal.dart';
import '../models/goalcategory.dart';

class GoalsController extends GetxController {
  List<Goal> goals = <Goal>[].obs;
  List<Goal> reachedGoals = <Goal>[].obs;
  RxList<GoalCategory> goalCategories = <GoalCategory>[].obs;

  var loading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchGoalCategories();
    fetchMyGoals();
    fetchMyReachedGoals();
  }

  int findIndexOfTheGoalWithGivenID(String goalID) {
    Goal goal = goals.firstWhere((element) => element.id == goalID);
    return goals.indexOf(goal);
  }

  int findIndexOfTheReachedGoalWithGivenID(String goalID) {
    Goal goal = reachedGoals.firstWhere((element) => element.id == goalID);
    return reachedGoals.indexOf(goal);
  }

  String getCategoryImagePath(String catID) {
    GoalCategory gc = goalCategories.firstWhere(
      (element) => element.id == catID,
    );
    return gc.imgSrc;
  }

  String getCategoryName(String catID) {
    GoalCategory gc = goalCategories.firstWhere(
      (element) => element.id == catID,
    );
    return gc.name;
  }

  Future fetchGoalCategories() async {
    try {
      goalCategories.clear();
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("tokenOfLoggedInUser");
      var url = Uri.parse('$baseURL/goals/categories');

      var response = await http.get(
        url,
        headers: <String, String>{"Authorization": "Bearer $token"},
      );
      log('Goal Categories Map: ${response.body}');

      var goalCategoriesMap = jsonDecode(response.body);
      if (response.statusCode == 200) {
        for (int i = 0; i < goalCategoriesMap.length; i++) {
          goalCategories.add(GoalCategory.fromJson(goalCategoriesMap[i]));
        }
      } else {
        throw Exception('Failed to load goal categories');
      }
    } catch (e) {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future fetchMyReachedGoals() async {
    try {
      reachedGoals.clear();
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("tokenOfLoggedInUser");
      var url = Uri.parse('$baseURL/goals/reached');

      var response = await http.get(
        url,
        headers: <String, String>{"Authorization": "Bearer $token"},
      );

      var goalsMap = jsonDecode(response.body);
      loading.value = false;
      if (response.statusCode == 200) {
        for (int i = 0; i < goalsMap.length; i++) {
          reachedGoals.add(Goal.fromJson(goalsMap[i]));
        }
      } else {
        throw Exception('Failed to load reached goals');
      }
    } catch (e) {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future fetchMyGoals() async {
    try {
      goals.clear();
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("tokenOfLoggedInUser");
      var url = Uri.parse('$baseURL/goals');

      var response = await http.get(
        url,
        headers: <String, String>{"Authorization": "Bearer $token"},
      );

      var goalsMap = jsonDecode(response.body);
      if (response.statusCode == 200) {
        for (int i = 0; i < goalsMap.length; i++) {
          goals.add(Goal.fromJson(goalsMap[i]));
        }
      } else {
        throw Exception('Failed to load goals');
      }
    } catch (e) {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future addGoal(Map<String, dynamic> data) async {
    try {
      loading.value = true;
      var url = Uri.parse('$baseURL/goals');
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("tokenOfLoggedInUser");

      var response = await http.post(
        url,
        headers: <String, String>{
          "Authorization": "Bearer $token",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );

      loading.value = false;
      goals.add(Goal.fromJson(jsonDecode(response.body)));
    } catch (e) {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future deleteGoal(String goalID, bool isReachedGoal) async {
    loading.value = true;
    var url = Uri.parse('$baseURL/goals/$goalID');

    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("tokenOfLoggedInUser");

    try {
      var response = await http.delete(
        url,
        headers: <String, String>{
          "Authorization": "Bearer $token",
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      var deletedGoal = Goal.fromJson(jsonDecode(response.body));

      if (isReachedGoal == true) {
        reachedGoals.removeWhere((element) => element.id == deletedGoal.id);
      } else {
        goals.removeWhere((element) => element.id == deletedGoal.id);
      }
      loading.value = false;
    } catch (e) {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future editGoal(Map<String, dynamic> data, String goalID) async {
    loading.value = true;
    var url = Uri.parse('$baseURL/goals/$goalID');

    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("tokenOfLoggedInUser");

    try {
      var response = await http.put(
        url,
        headers: <String, String>{
          "Authorization": "Bearer $token",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );

      int index = goals.indexWhere((element) => element.id == goalID);

      var updatedGoal = Goal.fromJson(jsonDecode(response.body));

      if (updatedGoal.isReached == true) {
        reachedGoals.add(updatedGoal);
        goals.removeWhere((element) => element.id == updatedGoal.id);
      } else {
        //working
        goals[index] = updatedGoal;
      }
      loading.value = false;
      //update();
    } catch (e) {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
}
