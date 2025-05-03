import 'package:auto_size_text/auto_size_text.dart';
import 'package:frontend/controllers/debtors_controller.dart';
import 'package:frontend/screens/debtors/update_delete_debtor_screen.dart';
import 'package:frontend/utils/constants.dart';
import 'package:frontend/utils/custom_loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'add_debtor_screen.dart';

class DebtorsScreen extends StatelessWidget {
  static const String routeName = '/debtorsScreen';
  const DebtorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DebtorsController debtorsController = Get.put(DebtorsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Debtors"),
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
                debtorsController.exportDebtors();
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
          Navigator.of(context).pushNamed(AddDebtorScreen.routeName);
        },
        child: const Icon(Icons.add),
      ),
      body: Obx(
        () =>
            debtorsController.loading.value
                ? showCustomLoader(kBackColor)
                : debtorsController.debtors.isEmpty
                ? Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "No debtors found",
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
                            " + ${debtorsController.totalDebtorsAmount}",
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
                          int d = debtorsController.debtors[index].day;
                          int m = debtorsController.debtors[index].month;
                          int y = debtorsController.debtors[index].year;
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
                                  UpdateDeleteDebtorScreen.routeName,
                                  arguments: debtorsController.debtors[index],
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
                                            "₹ ${debtorsController.debtors[index].amount}",
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
                                            debtorsController
                                                .debtors[index]
                                                .name,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontFamily: "CircularStd",
                                              fontWeight: FontWeight.w700,
                                              fontSize: 17.0,
                                            ),
                                          ),
                                          AutoSizeText(
                                            debtorsController
                                                .debtors[index]
                                                .desc,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: kBackColor,
                                              fontFamily: "CircularStd",
                                              fontSize: 14.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.bottomLeft,
                                        child: Text(
                                          "+91 ${debtorsController.debtors[index].mobile}",
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
                        itemCount: debtorsController.debtors.length,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
