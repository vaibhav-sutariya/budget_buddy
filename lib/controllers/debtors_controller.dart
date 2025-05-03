import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/models/debtor.dart';
import 'package:frontend/utils/constants.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

import '../main.dart';

class DebtorsController extends GetxController {
  List<Debtor> debtors = List<Debtor>.empty().obs;
  var loading = true.obs;
  var totalDebtorsAmount = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyDebtors();
  }

  Future fetchMyDebtors() async {
    try {
      debtors.clear();
      totalDebtorsAmount.value = 0.0;

      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("tokenOfLoggedInUser");
      var url = Uri.parse('$baseURL/debtors');

      var response = await http.get(
        url,
        headers: <String, String>{"Authorization": "Bearer $token"},
      );

      var debtorsMap = jsonDecode(response.body);
      loading.value = false;
      if (response.statusCode == 200) {
        for (int i = 0; i < debtorsMap.length; i++) {
          debtors.add(Debtor.fromJson(debtorsMap[i]));
          totalDebtorsAmount.value =
              totalDebtorsAmount.value + debtors[i].amount;
        }
      } else {
        throw Exception('Failed to load debtor');
      }
    } catch (e) {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future addDebtor(Map<String, dynamic> data) async {
    try {
      var url = Uri.parse('$baseURL/debtors');
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

      Debtor d = Debtor.fromJson(jsonDecode(response.body));
      totalDebtorsAmount.value = totalDebtorsAmount.value + d.amount;
      debtors.add(d);
    } catch (e) {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future deleteDebtor(String debtorID) async {
    try {
      var url = Uri.parse('$baseURL/debtors/$debtorID');

      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("tokenOfLoggedInUser");

      var response = await http.delete(
        url,
        headers: <String, String>{
          "Authorization": "Bearer $token",
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      var deletedDebtor = Debtor.fromJson(jsonDecode(response.body));
      totalDebtorsAmount.value =
          totalDebtorsAmount.value - deletedDebtor.amount;
      debtors.removeWhere((element) => element.id == deletedDebtor.id);
    } catch (e) {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future editDebtor(Map<String, dynamic> data, String debtorID) async {
    try {
      var url = Uri.parse('$baseURL/debtors/$debtorID');
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("tokenOfLoggedInUser");

      var response = await http.put(
        url,
        headers: <String, String>{
          "Authorization": "Bearer $token",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );

      int index = debtors.indexWhere((element) => element.id == debtorID);

      var updatedDebtor = Debtor.fromJson(jsonDecode(response.body));
      totalDebtorsAmount.value =
          totalDebtorsAmount.value - debtors[index].amount;
      totalDebtorsAmount.value =
          totalDebtorsAmount.value + updatedDebtor.amount;
      debtors[index] = updatedDebtor;
    } catch (e) {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void exportDebtors() async {
    try {
      loading.value = true;
      final Workbook workbook = Workbook();
      final Worksheet sheet = workbook.worksheets[0];

      Style headGlobalStyle = workbook.styles.add('style');
      headGlobalStyle.bold = true;

      sheet.getRangeByName('A1').setText('Debtor name');
      sheet.getRangeByName('A1').cellStyle = headGlobalStyle;
      sheet.getRangeByName('B1').setText('Mobile');
      sheet.getRangeByName('B1').cellStyle = headGlobalStyle;
      sheet.getRangeByName('C1').setText('Amount');
      sheet.getRangeByName('C1').cellStyle = headGlobalStyle;
      sheet.getRangeByName('D1').setText('Description');
      sheet.getRangeByName('D1').cellStyle = headGlobalStyle;
      sheet.getRangeByName('E1').setText('Date');
      sheet.getRangeByName('E1').cellStyle = headGlobalStyle;

      int i = 2;
      for (var debtor in debtors) {
        sheet.getRangeByName('A$i').setText(debtor.name);
        sheet.getRangeByName('B$i').setText(debtor.mobile);
        sheet.getRangeByName('C$i').setNumber(debtor.amount);
        sheet.getRangeByName('D$i').setText(debtor.desc);
        var date = DateTime(debtor.year, debtor.month, debtor.day);
        sheet.getRangeByName('E$i').setText(date.toString());
        i++;
      }

      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      final String path = (await getApplicationSupportDirectory()).path;

      final String finalFile =
          "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";
      final String fileName = '$path/$finalFile.xlsx';
      final File file = File(fileName);
      await file.writeAsBytes(bytes, flush: true);

      loading.value = false;

      Share.shareXFiles([XFile(file.path)]);
    } catch (e) {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
}
