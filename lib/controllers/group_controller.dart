import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/controllers/profile_controller.dart';
import 'package:frontend/models/group_expense.dart';
import 'package:frontend/utils/constants.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../models/group.dart';
import '../models/user.dart';

final ProfileController _profileController = Get.put(ProfileController());

class GroupController extends GetxController {
  List<Group> groups = List<Group>.empty().obs;

  var loading = true.obs;

  @override
  void onInit() {
    fetchMyGroups();
    super.onInit();
  }

  Future fetchMyGroups() async {
    try {
      loading.value = true;
      groups.clear();

      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("tokenOfLoggedInUser");
      var url = Uri.parse('$baseURL/groups');

      var response = await http.get(
        url,
        headers: <String, String>{"Authorization": "Bearer $token"},
      );

      var groupsMap = jsonDecode(response.body);

      if (response.statusCode == 200) {
        for (int i = 0; i < groupsMap.length; i++) {
          List<User> members = [];

          for (var j = 0; j < groupsMap[i]["group_members"].length; j++) {
            User user = await _profileController.fetchThisUser(
              groupsMap[i]["group_members"][j]["member"],
            );
            members.add(user);
          }

          groups.add(Group.fromJson(groupsMap[i], members));
        }
        loading.value = false;
      } else {
        throw Exception('Failed to load groups');
      }
    } catch (e) {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<List<GroupExpense>> fetchMyGroupExpenses(String groupID) async {
    try {
      List<GroupExpense> groupExpenses = [];

      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("tokenOfLoggedInUser");
      var url = Uri.parse('$baseURL/groupExpenses?groupID=$groupID');

      var response = await http.get(
        url,
        headers: <String, String>{"Authorization": "Bearer $token"},
      );

      var groupExpensesMap = jsonDecode(response.body);

      if (response.statusCode == 200) {
        for (int i = 0; i < groupExpensesMap.length; i++) {
          List<Settlement> settlements = [];
          List<PaidBy> paidBys = [];

          for (var j = 0; j < groupExpensesMap[i]["settlement"].length; j++) {
            Settlement s = Settlement(
              who: groupExpensesMap[i]["settlement"][j]["who"],
              whom: groupExpensesMap[i]["settlement"][j]["whom"],
              amount:
                  double.parse(groupExpensesMap[i]["settlement"][j]["amount"]) *
                  1.0,
            );
            settlements.add(s);
          }
          for (var j = 0; j < groupExpensesMap[i]["paid_by"].length; j++) {
            PaidBy p = PaidBy(
              who: groupExpensesMap[i]["paid_by"][j]["who"],
              amount:
                  double.parse(groupExpensesMap[i]["paid_by"][j]["amount"]) *
                  1.0,
            );
            paidBys.add(p);
          }

          groupExpenses.add(
            GroupExpense.fromJson(groupExpensesMap[i], settlements, paidBys),
          );
        }
        return groupExpenses;
      } else {
        throw Exception('Failed to load group expenses');
      }
    } catch (e) {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
      return [];
    }
  }

  Future addGroup(Map<String, dynamic> data) async {
    try {
      var url = Uri.parse('$baseURL/groups');
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

      if (response.statusCode == 200) {
        var groupsMap = jsonDecode(response.body);

        List<User> members = [];

        for (var j = 0; j < groupsMap["group_members"].length; j++) {
          User user = await _profileController.fetchThisUser(
            groupsMap["group_members"][j]["member"],
          );
          members.add(user);
        }

        groups.add(Group.fromJson(groupsMap, members));
      } else {
        throw Exception('Failed to add groups');
      }
    } catch (e) {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future addGroupExpense(Map<String, dynamic> data) async {
    try {
      var url = Uri.parse('$baseURL/groupExpenses');
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

      if (response.statusCode == 200) {
      } else {
        throw Exception('Failed to add group expense');
      }
    } catch (e) {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  // Future deleteDebtor(String debtorID) async {
  //   try {
  //     var url = Uri.parse(baseURL + '/debtors/$debtorID');
  //
  //     final prefs = await SharedPreferences.getInstance();
  //     String? token = prefs.getString("tokenOfLoggedInUser");
  //
  //     var response = await http.delete(
  //       url,
  //       headers: <String, String>{
  //         "Authorization": "Bearer $token",
  //         'Content-Type': 'application/json; charset=UTF-8',
  //       },
  //     );
  //
  //     var deletedDebtor = Debtor.fromJson(jsonDecode(response.body));
  //     totalDebtorsAmount.value =
  //         totalDebtorsAmount.value - deletedDebtor.amount;
  //     debtors.removeWhere((element) => element.id == deletedDebtor.id);
  //   } catch (e) {
  //     rootScaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
  //       content: Text(e.toString()),
  //     ));
  //   }
  // }

  // Future editDebtor(Map<String, dynamic> data, String debtorID) async {
  //   try {
  //     var url = Uri.parse(baseURL + '/debtors/$debtorID');
  //     final prefs = await SharedPreferences.getInstance();
  //     String? token = prefs.getString("tokenOfLoggedInUser");
  //
  //     var response = await http.put(
  //       url,
  //       headers: <String, String>{
  //         "Authorization": "Bearer $token",
  //         'Content-Type': 'application/json; charset=UTF-8',
  //       },
  //       body: jsonEncode(data),
  //     );
  //
  //     int index = debtors.indexWhere((element) => element.id == debtorID);
  //
  //     var updatedDebtor = Debtor.fromJson(jsonDecode(response.body));
  //     totalDebtorsAmount.value =
  //         totalDebtorsAmount.value - debtors[index].amount;
  //     totalDebtorsAmount.value =
  //         totalDebtorsAmount.value + updatedDebtor.amount;
  //     debtors[index] = updatedDebtor;
  //   } catch (e) {
  //     rootScaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
  //       content: Text(e.toString()),
  //     ));
  //   }
  // }
}
