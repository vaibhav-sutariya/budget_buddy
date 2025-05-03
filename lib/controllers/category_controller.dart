import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:frontend/models/paymentmode.dart';
import 'package:frontend/utils/constants.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/expense.dart';
import '../models/income.dart';

class CategoryController extends GetxController {
  List<Income> incomes = <Income>[].obs;
  List<Expense> expenses = <Expense>[].obs;
  RxList<PaymentMode> paymentModes = <PaymentMode>[].obs;

  var loading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyIncomes();
    fetchMyExpenses();
    fetchPaymentModes();
  }

  PaymentMode getPaymentModeByID(String pID) {
    return paymentModes.firstWhere((element) => element.id == pID);
  }

  Future fetchMyIncomes() async {
    try {
      incomes.clear();
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("tokenOfLoggedInUser");
      log('Token: $token');
      var url = Uri.parse('$baseURL/incomes');

      var response = await http.get(
        url,
        headers: <String, String>{"Authorization": "Bearer $token"},
      );

      var incomesMap = jsonDecode(response.body);
      log('Incomes Map: $incomesMap');

      if (response.statusCode == 200) {
        for (int i = 0; i < incomesMap.length; i++) {
          incomes.add(Income.fromJson(incomesMap[i]));
        }
      } else {
        throw Exception('Failed to load incomes');
      }
    } catch (e) {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future addIncome(Map<String, dynamic> data) async {
    try {
      var url = Uri.parse('$baseURL/incomes');
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

      Income d = Income.fromJson(jsonDecode(response.body));
      incomes.add(d);
    } catch (e) {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future fetchMyExpenses() async {
    try {
      expenses.clear();
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("tokenOfLoggedInUser");
      log('Token: $token');
      var url = Uri.parse('$baseURL/expenses');

      var response = await http.get(
        url,
        headers: <String, String>{"Authorization": "Bearer $token"},
      );

      var expensesMap = jsonDecode(response.body);
      log('Expenses Map: $expensesMap');

      if (response.statusCode == 200) {
        for (int i = 0; i < expensesMap.length; i++) {
          expenses.add(Expense.fromJson(expensesMap[i]));
        }
      } else {
        throw Exception('Failed to load expenses');
      }
    } catch (e) {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future addExpense(Map<String, dynamic> data) async {
    try {
      var url = Uri.parse('$baseURL/expenses');
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

      Expense e = Expense.fromJson(jsonDecode(response.body));
      expenses.add(e);
    } catch (e) {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future fetchPaymentModes() async {
    try {
      paymentModes.clear();
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("tokenOfLoggedInUser");
      var url = Uri.parse('$baseURL/paymentModes');

      var response = await http.get(
        url,
        headers: <String, String>{"Authorization": "Bearer $token"},
      );

      var paymentModesMap = jsonDecode(response.body);
      loading.value = false;

      if (response.statusCode == 200) {
        for (int i = 0; i < paymentModesMap.length; i++) {
          paymentModes.add(PaymentMode.fromJson(paymentModesMap[i]));
        }
      } else {
        throw Exception('Failed to load payment modes');
      }
    } catch (e) {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
}
