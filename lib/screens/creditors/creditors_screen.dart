import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:frontend/controllers/creditors_controller.dart';
import 'package:frontend/screens/creditors/edit_update_creditor_screen.dart';
import 'package:frontend/utils/constants.dart';
import 'package:frontend/utils/custom_loader.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'add_creditor_screen.dart';

class CreditorsScreen extends StatefulWidget {
  static const String routeName = '/creditorsScreen';
  const CreditorsScreen({super.key});

  @override
  _CreditorsScreenState createState() => _CreditorsScreenState();
}

class _CreditorsScreenState extends State<CreditorsScreen> {
  final CreditorsController _creditorsController = Get.put(
    CreditorsController(),
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Creditors"),
        backgroundColor: kBackColor,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        actions: [
          PopupMenuButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            onSelected: (value) {
              if (value == 1) {
                _creditorsController.exportCreditors();
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Export Data',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: "CircularStd",
                          ),
                        ),
                        Icon(Icons.arrow_upward, color: Colors.black),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      backgroundColor: Colors.grey.shade100,
      floatingActionButton: FloatingActionButton(
        backgroundColor: kBackColor,
        onPressed: () {
          Navigator.of(context).pushNamed(AddCreditorScreen.routeName);
        },
        child: const Icon(Icons.add),
      ),
      body: Obx(
        () =>
            _creditorsController.loading.value
                ? showCustomLoader(kBackColor)
                : _creditorsController.creditors.isEmpty
                ? Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "No creditors found",
                          style: TextStyle(
                            color: kErrorColor,
                            fontFamily: "CircularStd",
                            fontWeight: FontWeight.w600,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                      Opacity(
                        opacity: 0.3,
                        child: Image.asset(
                          "assets/images/other/nothing_found.png",
                          height: 80.0,
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
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        20.0,
                        20.0,
                        20.0,
                        12.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total Amount ",
                            style: TextStyle(color: Colors.black),
                          ),
                          Text(
                            " - ${_creditorsController.totalCreditorsAmount}",
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          int d = _creditorsController.creditors[index].day;
                          int m = _creditorsController.creditors[index].month;
                          int y = _creditorsController.creditors[index].year;
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(
                              12.0,
                              6.0,
                              12.0,
                              6.0,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  UpdateDeleteCreditorScreen.routeName,
                                  arguments:
                                      _creditorsController.creditors[index],
                                );
                              },
                              child: Container(
                                height: 135.0,
                                padding: const EdgeInsets.all(15.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18.0),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "$d/$m/$y",
                                            style: const TextStyle(
                                              color: Colors.red,
                                            ),
                                          ),
                                          Text(
                                            DateFormat(
                                              'EEEE',
                                            ).format(DateTime(y, m, d)),
                                            style: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            "₹ ${_creditorsController.creditors[index].amount}",
                                            style: const TextStyle(
                                              color: Color(0xff0ABB79),
                                              fontWeight: FontWeight.bold,
                                              fontFamily: "CircularStd",
                                              fontSize: 20.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _creditorsController
                                                .creditors[index]
                                                .name,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontFamily: "CircularStd",
                                              fontWeight: FontWeight.w700,
                                              fontSize: 17.0,
                                            ),
                                          ),
                                          AutoSizeText(
                                            _creditorsController
                                                .creditors[index]
                                                .desc,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: kBackColor,
                                              fontFamily: "CircularStd",
                                              fontSize: 13.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.bottomLeft,
                                        child: Text(
                                          "+91 ${_creditorsController.creditors[index].mobile}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontFamily: "CircularStd",
                                            color: Colors.grey,
                                            fontSize: 15.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        itemCount: _creditorsController.creditors.length,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
