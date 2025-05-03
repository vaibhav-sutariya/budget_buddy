import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/models/creditor.dart';
import 'package:frontend/utils/constants.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

import '../main.dart';

class CreditorsController extends GetxController {
  var creditors = List<Creditor>.empty().obs;
  var loading = true.obs;
  var totalCreditorsAmount = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyCreditors();
  }

  Future fetchMyCreditors() async {
    try {
      creditors.clear();
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("tokenOfLoggedInUser");
      var url = Uri.parse('$baseURL/creditors');

      var response = await http.get(
        url,
        headers: <String, String>{"Authorization": "Bearer $token"},
      );

      var creditorsMap = jsonDecode(response.body);
      loading.value = false;
      if (response.statusCode == 200) {
        for (int i = 0; i < creditorsMap.length; i++) {
          creditors.add(Creditor.fromJson(creditorsMap[i]));
          totalCreditorsAmount.value =
              totalCreditorsAmount.value + creditors[i].amount;
        }
      } else {
        throw Exception('Failed to load creditor');
      }
    } catch (e) {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future addCreditor(Map<String, dynamic> data) async {
    try {
      var url = Uri.parse('$baseURL/creditors');
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

      Creditor c = Creditor.fromJson(jsonDecode(response.body));
      totalCreditorsAmount.value = totalCreditorsAmount.value + c.amount;
      creditors.add(c);
    } catch (e) {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future deleteCreditor(String creditorID) async {
    try {
      var url = Uri.parse('$baseURL/creditors/$creditorID');
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("tokenOfLoggedInUser");

      var response = await http.delete(
        url,
        headers: <String, String>{
          "Authorization": "Bearer $token",
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      var deletedCreditor = Creditor.fromJson(jsonDecode(response.body));
      totalCreditorsAmount.value =
          totalCreditorsAmount.value - deletedCreditor.amount;
      creditors.removeWhere((element) => element.id == deletedCreditor.id);
    } catch (e) {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future editCreditor(Map<String, dynamic> data, String creditorID) async {
    try {
      var url = Uri.parse('$baseURL/creditors/$creditorID');
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

      int index = creditors.indexWhere((element) => element.id == creditorID);

      var updatedCreditor = Creditor.fromJson(jsonDecode(response.body));
      totalCreditorsAmount.value =
          totalCreditorsAmount.value - creditors[index].amount;
      totalCreditorsAmount.value =
          totalCreditorsAmount.value + updatedCreditor.amount;
      creditors[index] = updatedCreditor;
    } catch (e) {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void exportCreditors() async {
    try {
      loading.value = true;
      final Workbook workbook = Workbook();
      final Worksheet sheet = workbook.worksheets[0];

      Style headGlobalStyle = workbook.styles.add('style');
      headGlobalStyle.bold = true;

      sheet.getRangeByName('A1').setText('creditor name');
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
      for (var creditor in creditors) {
        sheet.getRangeByName('A$i').setText(creditor.name);
        sheet.getRangeByName('B$i').setText(creditor.mobile);
        sheet.getRangeByName('C$i').setNumber(creditor.amount);
        sheet.getRangeByName('D$i').setText(creditor.desc);
        var date = DateTime(creditor.year, creditor.month, creditor.day);
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
