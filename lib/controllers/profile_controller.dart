import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:frontend/controllers/category_controller.dart';
import 'package:frontend/utils/constants.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

import '../main.dart';
import '../models/transaction.dart';
import '../models/user.dart';

class ProfileController extends GetxController {
  var loading = true.obs;
  Rx<User> user =
      User(
        isPremium: false,
        profilePic: "avatar1.jpg",
        userName: "",
        userMobile: "",
        userID: "",
      ).obs;

  List<Transaction> transactions = List<Transaction>.empty().obs;
  List<DateTime> uniqueDates = List<DateTime>.empty().obs;
  List<User>? contacts = List<User>.empty().obs;

  Rx<DateTime> selectedDate =
      DateTime(DateTime.now().year, DateTime.now().month).obs;

  RxDouble income = 0.0.obs;
  RxDouble expense = 0.0.obs;
  RxDouble balance = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyTransactions(DateTime.now().month, DateTime.now().year);
    fetchMyProfile();
    fetchMyContacts();
  }

  Future uploadProfile(Map<String, String> data) async {
    var url = Uri.parse('$baseURL/users/uploadProfileData');
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("tokenOfLoggedInUser");

    try {
      var response = await http.post(
        url,
        headers: <String, String>{
          "Authorization": "Bearer $token",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );

      return response;
    } catch (e) {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> fetchMyProfile() async {
    var url = Uri.parse('$baseURL/users/me');
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("tokenOfLoggedInUser");

    try {
      var response = await http.get(
        url,
        headers: <String, String>{"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        user.value = User.fromJson(jsonDecode(response.body));
      } else {
        // If the server did not return a 200 OK response,
        throw Exception('Failed to load profile');
      }
    } catch (e) {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<User> fetchThisUser(String userID) async {
    var url = Uri.parse('$baseURL/users/$userID');
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("tokenOfLoggedInUser");

    try {
      var response = await http.get(
        url,
        headers: <String, String>{"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        return User.fromJson(jsonDecode(response.body));
      } else {
        // If the server did not return a 200 OK response,
        throw Exception('Failed to load profile');
      }
    } catch (e) {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
      return User(
        userMobile: "userMobile",
        profilePic: "profilePic",
        userName: "userName",
        isPremium: false,
        userID: "",
      );
    }
  }

  Future<void> updateMyProfile(Map<String, dynamic> data) async {
    var url = Uri.parse('$baseURL/users/me');
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

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        user.value = User.fromJson(jsonDecode(response.body));
      } else {
        // If the server did not return a 200 OK response,
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> fetchMyTransactions(int month, int year) async {
    income.value = 0.0;
    expense.value = 0.0;
    balance.value = 0.0;
    transactions.clear();

    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("tokenOfLoggedInUser");

    var url = Uri.parse('$baseURL/transactions?month=$month&year=$year');

    try {
      var response = await http.get(
        url,
        headers: <String, String>{"Authorization": "Bearer $token"},
      );

      var transactionsMap = jsonDecode(response.body);

      if (response.statusCode == 200) {
        for (int i = 0; i < transactionsMap.length; i++) {
          Transaction t = Transaction.fromJson(transactionsMap[i]);
          if (t.category == "Income") {
            income.value = income.value + t.amount;
          } else if (t.category == "Expense") {
            expense.value = expense.value + t.amount;
          }
          transactions.add(t);
        }

        balance.value = income.value - expense.value;

        Set fetchedDates = {};

        for (int i = 0; i < transactions.length; i++) {
          fetchedDates.add(
            DateTime(
              transactions[i].year,
              transactions[i].month,
              transactions[i].day,
            ),
          );
        }
        uniqueDates = List.from(fetchedDates);
        uniqueDates.sort((b, a) => a.compareTo(b));
      } else {
        throw Exception('Failed to load transactions');
      }
    } catch (e) {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  List<Transaction> allTransactions = [];

  Future<List<Transaction>> fetchMyAllTransactions() async {
    allTransactions.clear();
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("tokenOfLoggedInUser");
    var url = Uri.parse('$baseURL/transactions');

    try {
      var response = await http.get(
        url,
        headers: <String, String>{"Authorization": "Bearer $token"},
      );

      var transactionsMap = jsonDecode(response.body);

      if (response.statusCode == 200) {
        for (int i = 0; i < transactionsMap.length; i++) {
          allTransactions.add(Transaction.fromJson(transactionsMap[i]));
        }

        List<DateTime>? dateTimes = [];

        for (var transaction in allTransactions) {
          dateTimes.add(
            DateTime(transaction.year, transaction.month, transaction.day),
          );
        }

        Set<DateTime> dates = dateTimes.toSet();
        dateTimes = dates.toList();

        dateTimes.sort((b, a) => a.compareTo(b));

        List<Transaction> temp = [];

        for (var date in dateTimes) {
          for (var element in allTransactions) {
            if (element.day == date.day &&
                element.month == date.month &&
                element.year == date.year) {
              temp.add(element);
            }
          }
        }
        allTransactions = temp;
        return allTransactions;
      } else {
        throw Exception('Failed to load transactions');
      }
    } catch (e) {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
      return [];
    }
  }

  Map<String, double> getMapDataOfGivenCategory(int m, int y, String cat) {
    List t = transactions.where((t) => t.category == cat).toList();

    List data = t.cast<Transaction>();
    Transaction temp;

    for (int i = 0; i < data.length; i++) {
      for (int j = i + 1; j < data.length; j++) {
        if (data[i].amount < data[j].amount) {
          temp = data[j];
          data[j] = data[i];
          data[i] = temp;
        }
      }
    }

    Map<String, double> dataMap = {};
    double totalAmt = 0.0;
    List<double> chartPercentages = <double>[];

    if (data.isNotEmpty) {
      for (int i = 0; i < data.length; i++) {
        if (dataMap.containsKey(data[i].name)) {
          dataMap[data[i].name] = data[i].amount + dataMap[data[i].name];
        } else {
          dataMap[data[i].name] = data[i].amount;
        }
      }

      var sortedKeys = dataMap.keys.toList(growable: false)
        ..sort((b, a) => dataMap[a]!.toInt().compareTo(dataMap[b]!.toInt()));

      LinkedHashMap sortedMap = LinkedHashMap.fromIterable(
        sortedKeys,
        key: (k) => k,
        value: (k) => dataMap[k],
      );

      for (double value in sortedMap.values) {
        totalAmt = totalAmt + value;
      }
      for (double values in sortedMap.values) {
        double per = (values * 100) / totalAmt;
        chartPercentages.add(double.parse(per.toStringAsFixed(1)));
      }
      dataMap = Map<String, double>.from(sortedMap);
      double newAmt = 0.0;
      if (dataMap.length > 5) {
        for (int j = 4; j < dataMap.length; j++) {
          newAmt = newAmt + dataMap.values.elementAt(j);
        }

        var keysToBeDeleted = [];
        for (int i = 4; i < dataMap.length; i++) {
          keysToBeDeleted.add(dataMap.keys.elementAt(i));
        }
        for (int k = 0; k < keysToBeDeleted.length; k++) {
          dataMap.remove(keysToBeDeleted[k]);
        }
        dataMap['Others...'] = newAmt;
      }
    }
    //return data.cast<Transaction>();
    return dataMap;
  }

  List finalData = [];
  List finalAmount = [];
  List<double> listPercentages = <double>[];

  Map<String, double> getTransactionsByGivenCategory(String category) {
    finalData.clear();
    finalAmount.clear();
    listPercentages.clear();

    List t = transactions.where((t) => t.category == category).toList();
    List data = t.cast<Transaction>();

    double totalAmt = 0.0;

    Map<String, double> dataMap2 = {};

    Transaction temp;

    if (data.isNotEmpty) {
      //sort transactions
      for (int i = 0; i < data.length; i++) {
        for (int j = i + 1; j < data.length; j++) {
          if (data[i].amount < data[j].amount) {
            temp = data[j];
            data[j] = data[i];
            data[i] = temp;
          }
        }
      }

      for (int i = 0; i < data.length; i++) {
        if (dataMap2.containsKey(data[i].name)) {
          dataMap2[data[i].name] = data[i].amount + dataMap2[data[i].name];
        } else {
          dataMap2[data[i].name] = data[i].amount;
        }
      }

      var sortedKeys = dataMap2.keys.toList(growable: false)
        ..sort((b, a) => dataMap2[a]!.toInt().compareTo(dataMap2[b]!.toInt()));

      LinkedHashMap sortedMap = LinkedHashMap.fromIterable(
        sortedKeys,
        key: (k) => k,
        value: (k) => dataMap2[k],
      );

      for (String key in sortedMap.keys) {
        for (int j = 0; j < data.length; j++) {
          if (key == data[j].name) {
            finalAmount.add(sortedMap[key]);
            totalAmt = totalAmt + sortedMap[key];
            finalData.add(data[j]);
            break;
          }
        }
      }

      for (double values in sortedMap.values) {
        double per = (values * 100) / totalAmt;
        listPercentages.add(double.parse(per.toStringAsFixed(1)));
      }

      finalAmount.sort((b, a) => a.compareTo(b));
      listPercentages.sort((b, a) => a.compareTo(b));
    }

    return dataMap2;
  }

  Future addTransaction(Map<String, dynamic> data, String path) async {
    var url = Uri.parse('$baseURL/transactions');
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("tokenOfLoggedInUser");

    try {
      var response = await http.post(
        url,
        headers: <String, String>{
          "Authorization": "Bearer $token",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );

      Transaction t = Transaction.fromJson(jsonDecode(response.body));

      if (path == "") {
        transactions.add(t);
      } else {
        var res = await uploadMyTransactionBill(tID: t.id, billPath: path);
        transactions.add(Transaction.fromJson(jsonDecode(res)));
      }

      if (t.category == "Income") {
        income.value = income.value + t.amount;
      } else if (t.category == "Expense") {
        expense.value = expense.value + t.amount;
      }
      balance.value = income.value - expense.value;

      Set fetchedDates = {};

      for (int i = 0; i < transactions.length; i++) {
        fetchedDates.add(
          DateTime(
            transactions[i].year,
            transactions[i].month,
            transactions[i].day,
          ),
        );
      }

      uniqueDates = List.from(fetchedDates);
      uniqueDates.sort((b, a) => a.compareTo(b));
    } catch (e) {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future uploadMyTransactionBill({var tID, var billPath}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("tokenOfLoggedInUser");

      var url = Uri.parse("$baseURL/transactions/$tID/billsrc");

      var request = http.MultipartRequest("POST", url);
      Map<String, String> headers = {
        "Content-type": "multipart/form-data",
        "Authorization": "Bearer $token",
      };
      request.headers.addAll(headers);
      request.files.add(await http.MultipartFile.fromPath('bill', billPath));

      var response = await request.send();
      return await response.stream.bytesToString();
    } catch (e) {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future deleteMyTransactionBill({var tID, var billPath}) async {
    Map<String, dynamic> data = {"billSrc": billPath};

    try {
      int i = 0;
      if (billPath.isNotEmpty) {
        for (var t in transactions) {
          if (t.billSrc == billPath) {
            i++;
          }
        }
        if (i == 1) {
          //last transaction with same billsrc
          final prefs = await SharedPreferences.getInstance();
          String? token = prefs.getString("tokenOfLoggedInUser");

          var url = Uri.parse("$baseURL/transactions/$tID/billsrc");

          var response = await http.delete(
            url,
            headers: <String, String>{
              "Authorization": "Bearer $token",
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(data),
          );

          if (response.statusCode != 200) {
            throw Exception("Image is not deleted");
          }
        }
      }
    } catch (e) {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future deleteTransaction(String transactionID, String billSrc) async {
    var url = Uri.parse('$baseURL/transactions/$transactionID');

    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("tokenOfLoggedInUser");

    try {
      if (billSrc.isNotEmpty) {
        await deleteMyTransactionBill(tID: transactionID, billPath: billSrc);
      }

      var response = await http.delete(
        url,
        headers: <String, String>{
          "Authorization": "Bearer $token",
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      var deletedTransaction = Transaction.fromJson(jsonDecode(response.body));
      if (deletedTransaction.category == "Income") {
        income.value = income.value - deletedTransaction.amount;
      } else if (deletedTransaction.category == "Expense") {
        expense.value = expense.value - deletedTransaction.amount;
      }
      balance.value = income.value - expense.value;
      transactions.removeWhere(
        (element) => element.id == deletedTransaction.id,
      );
    } catch (e) {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future editImageTransaction(
    Map<String, dynamic> data,
    String transactionID,
    String billPath,
    String billImage,
  ) async {
    var url = Uri.parse('$baseURL/transactions/$transactionID');

    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("tokenOfLoggedInUser");

    try {
      if (billPath != "" && billImage == "") {
        //upload the image provided
        await http.put(
          url,
          headers: <String, String>{
            "Authorization": "Bearer $token",
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(data),
        );

        await uploadMyTransactionBill(tID: transactionID, billPath: billPath);
      } else if (billPath == "" && billImage != "") {
        //delete the image provided

        //delete bill from folder
        await deleteMyTransactionBill(tID: transactionID, billPath: billImage);

        //delete billpath from database
        await http.put(
          url,
          headers: <String, String>{
            "Authorization": "Bearer $token",
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(data),
        );
      } else if (billPath != "" && billImage != "") {
        //delete old bill from folder
        await deleteMyTransactionBill(tID: transactionID, billPath: billImage);

        await http.put(
          url,
          headers: <String, String>{
            "Authorization": "Bearer $token",
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(data),
        );

        await uploadMyTransactionBill(tID: transactionID, billPath: billPath);
      } else {
        await http.put(
          url,
          headers: <String, String>{
            "Authorization": "Bearer $token",
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(data),
        );
      }
    } catch (e) {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future editTransaction(
    Map<String, dynamic> data,
    String transactionID,
    String billPath,
    String billImage,
  ) async {
    var url = Uri.parse('$baseURL/transactions/$transactionID');

    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("tokenOfLoggedInUser");

    try {
      if (billPath != "" && billImage == "") {
        //upload the image provided
        await http.put(
          url,
          headers: <String, String>{
            "Authorization": "Bearer $token",
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(data),
        );

        var res = await uploadMyTransactionBill(
          tID: transactionID,
          billPath: billPath,
        );

        int index = transactions.indexWhere(
          (element) => element.id == transactionID,
        );

        var updatedTransaction = Transaction.fromJson(jsonDecode(res));
        transactions[index] = updatedTransaction;
      } else if (billPath == "" && billImage != "") {
        //delete the image provided

        //delete bill from folder
        await deleteMyTransactionBill(tID: transactionID, billPath: billImage);

        //delete billpath from database
        var response = await http.put(
          url,
          headers: <String, String>{
            "Authorization": "Bearer $token",
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(data),
        );

        int index = transactions.indexWhere(
          (element) => element.id == transactionID,
        );

        var updatedTransaction = Transaction.fromJson(
          jsonDecode(response.body),
        );
        transactions[index] = updatedTransaction;
      } else if (billPath != "" && billImage != "") {
        //delete old bill from folder
        await deleteMyTransactionBill(tID: transactionID, billPath: billImage);

        await http.put(
          url,
          headers: <String, String>{
            "Authorization": "Bearer $token",
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(data),
        );

        var res = await uploadMyTransactionBill(
          tID: transactionID,
          billPath: billPath,
        );

        int index = transactions.indexWhere(
          (element) => element.id == transactionID,
        );

        var updatedTransaction = Transaction.fromJson(jsonDecode(res));
        transactions[index] = updatedTransaction;
      } else {
        var response = await http.put(
          url,
          headers: <String, String>{
            "Authorization": "Bearer $token",
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(data),
        );

        int index = transactions.indexWhere(
          (element) => element.id == transactionID,
        );

        var updatedTransaction = Transaction.fromJson(
          jsonDecode(response.body),
        );

        transactions[index] = updatedTransaction;
      }
    } catch (e) {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  final CategoryController categoryController = Get.put(CategoryController());

  void exportTransactions(DateTime start, DateTime end) async {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];

    Style headGlobalStyle = workbook.styles.add('style');
    headGlobalStyle.bold = true;

    sheet.getRangeByName('A1').setText('Date');
    sheet.getRangeByName('A1').cellStyle = headGlobalStyle;
    sheet.getRangeByName('B1').setText('Transaction');
    sheet.getRangeByName('B1').cellStyle = headGlobalStyle;
    sheet.getRangeByName('C1').setText('Amount');
    sheet.getRangeByName('C1').cellStyle = headGlobalStyle;
    sheet.getRangeByName('D1').setText('Note');
    sheet.getRangeByName('D1').cellStyle = headGlobalStyle;
    sheet.getRangeByName('E1').setText('Category');
    sheet.getRangeByName('E1').cellStyle = headGlobalStyle;
    sheet.getRangeByName('F1').setText('Payment mode');
    sheet.getRangeByName('F1').cellStyle = headGlobalStyle;

    int i = 2;
    for (var t in allTransactions) {
      DateTime dt = DateTime(t.year, t.month, t.day);
      if (dt.compareTo(start) >= 0 && dt.compareTo(end) <= 0) {
        sheet.getRangeByName('A$i').setText(dt.toString());
        sheet.getRangeByName('B$i').setText(t.name);
        sheet.getRangeByName('C$i').setNumber(t.amount);
        sheet.getRangeByName('D$i').setText(t.description);
        sheet.getRangeByName('E$i').setText(t.category);
        sheet
            .getRangeByName('F$i')
            .setText(categoryController.getPaymentModeByID(t.paymentID).name);
        i++;
      }
    }

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final String path = (await getApplicationSupportDirectory()).path;

    final String finalFile =
        "${start.year}-${start.month}-${start.day}-${end.year}-${end.month}-${end.day}";

    final String fileName = '$path/$finalFile.xlsx';

    final File file = File(fileName);
    await file.writeAsBytes(bytes, flush: true);

    loading.value = false;

    Share.shareXFiles([XFile(file.path)]);
  }

  void fetchMyContacts() async {
    List<User> allFetchedUser = [];
    List<String> allContacts = [];

    if (await FlutterContacts.requestPermission()) {
      List<Contact>? phoneContacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );

      for (var contact in phoneContacts) {
        if (contact.phones.isNotEmpty) {
          allContacts.add(
            contact.phones.first.number.removeAllWhitespace.trim(),
          );
        }
      }
    }

    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("tokenOfLoggedInUser");
    var url = Uri.parse('$baseURL/users');

    try {
      var response = await http.get(
        url,
        headers: <String, String>{"Authorization": "Bearer $token"},
      );

      var usersMap = jsonDecode(response.body);

      if (response.statusCode == 200) {
        for (int i = 0; i < usersMap.length; i++) {
          allFetchedUser.add(User.fromJson(usersMap[i]));
        }
      } else {
        throw Exception('Failed to load users');
      }
      loading.value = false;
    } catch (e) {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    for (var fetchedUser in allFetchedUser) {
      if (allContacts.contains(
        fetchedUser.userMobile.removeAllWhitespace.trim(),
      )) {
        contacts?.add(fetchedUser);
      }
    }
    //filter contacts
  }
}
