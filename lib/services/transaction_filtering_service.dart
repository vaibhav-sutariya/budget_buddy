import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/controllers/category_controller.dart';
import 'package:frontend/controllers/profile_controller.dart';
import 'package:frontend/screens/transactions/transaction_detail_screen.dart';
import 'package:frontend/utils/constants.dart';
import 'package:get/get.dart';

import '../models/transaction.dart';

class TransactionFilteringScreen extends StatefulWidget {
  static const String routeName = "/transactionFiltering";
  final List<Transaction> transactions;
  const TransactionFilteringScreen({super.key, required this.transactions});

  @override
  _TransactionFilteringScreenState createState() =>
      _TransactionFilteringScreenState();
}

class _TransactionFilteringScreenState
    extends State<TransactionFilteringScreen> {
  final TextEditingController _searchQuery = TextEditingController();
  int selectedSortBy = 0;
  String searchString = "";

  final CategoryController _categoryController = Get.put(CategoryController());
  final ProfileController _profileController = Get.put(ProfileController());

  List<Transaction> foundTransactions = [];

  @override
  void initState() {
    foundTransactions = widget.transactions;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _runFilter(String enteredKeyword) {
    List<Transaction> results = [];
    if (enteredKeyword.trim().isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = widget.transactions;
    } else {
      results =
          widget.transactions
              .where(
                (t) =>
                    t.description.toLowerCase().contains(
                      enteredKeyword.toLowerCase(),
                    ) ||
                    t.amount.toString().contains(
                      enteredKeyword.toLowerCase(),
                    ) ||
                    t.name.toLowerCase().contains(enteredKeyword.toLowerCase()),
              )
              .toList();

      // we use the toLowerCase() method to make it case-insensitive
    }

    // Refresh the UI
    setState(() {
      searchString = enteredKeyword;
      foundTransactions = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: kBackColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          _searchQuery.text.isNotEmpty
              ? IconButton(
                onPressed: () {
                  setState(() {
                    _searchQuery.clear();
                    foundTransactions = widget.transactions;
                  });
                },
                icon: const Icon(Icons.close, color: Colors.grey),
              )
              : Container(),
          Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: IconButton(
              onPressed: () {
                showExportDialog();
              },
              icon: const Icon(Icons.open_in_new_sharp),
            ),
          ),
        ],
        title: TextFormField(
          controller: _searchQuery,
          cursorColor: Colors.white,
          autofocus: true,
          onChanged: (value) {
            _runFilter(value);
          },
          style: const TextStyle(color: Colors.white, fontSize: 18.0),
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: "Search by name, desc, amount",
            hintStyle: TextStyle(
              color: Colors.grey,
              fontSize: 17.0,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
      body:
          foundTransactions.isEmpty
              ? const Center(
                child: Text(
                  "No results found !",
                  style: TextStyle(color: Colors.grey),
                ),
              )
              : CupertinoScrollbar(
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      Transaction t = foundTransactions[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 5.0),
                        child: Card(
                          elevation: 1,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 8.0,
                              right: 8.0,
                            ),
                            child: ListTile(
                              tileColor: Colors.white,
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  TransactionDetailScreen.routeName,
                                  arguments: [t, true],
                                );
                              },
                              contentPadding: const EdgeInsets.all(8.0),
                              trailing: Column(
                                children: [
                                  Expanded(
                                    child: Text(
                                      t.category == "Income"
                                          ? "${t.amount}"
                                          : "- ${t.amount}",
                                      style: TextStyle(
                                        color:
                                            t.category == "Income"
                                                ? Colors.green
                                                : Colors.red,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Image.asset(
                                      "assets/images/paymodes/${_categoryController.getPaymentModeByID(t.paymentID).imgSrc}",
                                      height: 25.0,
                                      width: 25.0,
                                    ),
                                  ),
                                ],
                              ),
                              title: Text(
                                t.name,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15.5,
                                ),
                              ),
                              leading: Image.asset(
                                "assets/images/${t.imgSrc}",
                                height: 26.0,
                                width: 26.0,
                              ),
                              subtitle:
                                  t.description == t.name
                                      ? const Text("")
                                      : Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8.0,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 0,
                                                    vertical: 3.0,
                                                  ),
                                              child: AutoSizeText(
                                                t.description,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 11.0,
                                                ),
                                              ),
                                            ),
                                            AutoSizeText(
                                              "${t.day}/${t.month}/${t.year}",
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 8.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: foundTransactions.length,
                  ),
                ),
              ),
    );
  }

  showExportDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder:
              (context, setState) => AlertDialog(
                backgroundColor: Colors.white,
                title: Text(
                  "Export from",
                  style: TextStyle(
                    color: kBackColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 15.0),
                        child: Text(
                          "Start",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          showMyStartDatePicker(() {
                            setState(() => {});
                          });
                        },
                        child: TextFormField(
                          readOnly: true,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText:
                                "${startDate.day}-${startDate.month}-${startDate.year}",
                            enabled: false,
                            disabledBorder: const UnderlineInputBorder(),
                            hintStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 17.0,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 25.0),
                        child: Text(
                          "End",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          showMyEndDatePicker(() {
                            setState(() => {});
                          });
                        },
                        child: TextFormField(
                          readOnly: true,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText:
                                "${endDate.day}-${endDate.month}-${endDate.year}",
                            enabled: false,
                            disabledBorder: const UnderlineInputBorder(),
                            hintStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 17.0,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25.0),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("CANCEL", style: TextStyle(color: kBackColor)),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      _profileController.exportTransactions(startDate, endDate);
                    },
                    child: Text("OK", style: TextStyle(color: kBackColor)),
                  ),
                ],
              ),
        );
      },
    );
  }

  DateTime tempDate1 = DateTime.now();
  DateTime tempDate2 = DateTime.now();
  DateTime startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime endDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);

  showMyStartDatePicker(VoidCallback callback) {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.40,
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: CupertinoDatePicker(
                  onDateTimeChanged: (val) {
                    setState(() {
                      tempDate1 = val;
                    });
                  },
                  initialDateTime: startDate,
                  mode: CupertinoDatePickerMode.date,
                ),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      icon: const Icon(Icons.close, color: Colors.red),
                      label: const Text(
                        "CANCEL",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          startDate = tempDate1;
                          callback();
                          Navigator.of(context).pop();
                        });
                      },
                      icon: const Icon(Icons.check, color: Colors.green),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.green,
                      ),
                      label: const Text(
                        "OK",
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  showMyEndDatePicker(VoidCallback callback) {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.40,
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: CupertinoDatePicker(
                  onDateTimeChanged: (val) {
                    setState(() {
                      tempDate2 = val;
                    });
                  },
                  initialDateTime: endDate,
                  mode: CupertinoDatePickerMode.date,
                ),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      icon: const Icon(Icons.close, color: Colors.red),
                      label: const Text(
                        "CANCEL",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          endDate = tempDate2;
                          callback();
                          Navigator.of(context).pop();
                        });
                      },
                      icon: const Icon(Icons.check, color: Colors.green),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.green,
                      ),
                      label: const Text(
                        "OK",
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
