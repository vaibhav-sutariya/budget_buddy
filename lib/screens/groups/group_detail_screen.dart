import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frontend/controllers/profile_controller.dart';
import 'package:frontend/models/group_expense.dart';
import 'package:frontend/screens/groups/add_expense_screen.dart';
import 'package:frontend/screens/groups/groupExpense_detail_screen.dart';
import 'package:frontend/utils/constants.dart';
import 'package:frontend/utils/custom_loader.dart';
import 'package:get/get.dart';

import '../../controllers/group_controller.dart';
import '../../models/group.dart';
import '../../models/user.dart';

class DetailScreenArgument {
  GroupExpense ge;
  List<User> members;
  double amount;
  DetailScreenArgument({
    required this.ge,
    required this.members,
    required this.amount,
  });
}

class GroupDetailScreen extends StatefulWidget {
  static const String routeName = "/groupDetailScreen";
  final Group group;
  const GroupDetailScreen({super.key, required this.group});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final random = Random();
  final GroupController _groupController = Get.put(GroupController());
  final ProfileController _profileController = Get.put(ProfileController());

  late Future<List<GroupExpense>> groupExpenses;

  @override
  void initState() {
    groupExpenses = fetchGroupExpenses();
    super.initState();
  }

  Future<List<GroupExpense>> fetchGroupExpenses() async {
    return await _groupController.fetchMyGroupExpenses(widget.group.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        titleSpacing: 0.0,
        elevation: 2.0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(
                "assets/images/groups/${widget.group.groupImgSrc}",
              ),
            ),
            const SizedBox(width: 16.0),
            Text(
              widget.group.groupName,
              style: const TextStyle(color: Colors.black, fontSize: 15.0),
            ),
          ],
        ),
        leading: IconButton(
          padding: const EdgeInsets.all(0.0),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  "assets/images/groups/doodle${1 + random.nextInt(2)}.png",
                ),
                opacity: 0.072,
                fit: BoxFit.cover,
                // colorFilter: ColorFilter.mode(Colors.grey, BlendMode.overlay ),
              ),
            ),
            padding: const EdgeInsets.only(
              left: 16.0,
              top: 16.0,
              right: 16.0,
              bottom: 100,
            ),
            child: FutureBuilder<List<GroupExpense>>(
              future: groupExpenses,
              builder: (context, ss) {
                if (ss.hasData) {
                  var data = ss.data;
                  if (data!.isEmpty) {
                    return Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 5.0,
                        ),
                        child: const Text(
                          "No expenses",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 12.0,
                          ),
                        ),
                      ),
                    );
                  }
                  return _groupController.loading.value == true
                      ? showCustomLoader(kBackColor)
                      : RawScrollbar(
                        thumbColor: Colors.grey,
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            String settlementMsg = "";
                            double payAmount = 0.0;
                            double getAmount = 0.0;
                            for (
                              int i = 0;
                              i < data[index].settlements.length;
                              i++
                            ) {
                              Settlement st = data[index].settlements[i];
                              if (st.who ==
                                  _profileController.user.value.userID) {
                                payAmount = payAmount + st.amount;
                                settlementMsg = "You'll pay for";
                              } else if (st.whom ==
                                  _profileController.user.value.userID) {
                                getAmount = getAmount + st.amount;
                                settlementMsg = "You'll get for";
                              }
                            }
                            return Padding(
                              padding:
                                  settlementMsg == "You'll pay for"
                                      ? EdgeInsets.only(
                                        right:
                                            MediaQuery.of(context).size.width *
                                            0.35,
                                        top: 8.0,
                                      )
                                      : EdgeInsets.only(
                                        left:
                                            MediaQuery.of(context).size.width *
                                            0.35,
                                        top: 8.0,
                                      ),
                              child: GestureDetector(
                                onTap: () {
                                  settlementMsg == "You'll pay for"
                                      ? Navigator.of(context).pushNamed(
                                        GroupExpenseDetailScreen.routeName,
                                        arguments: DetailScreenArgument(
                                          ge: data[index],
                                          members: widget.group.members,
                                          amount: payAmount,
                                        ),
                                      )
                                      : Navigator.of(context).pushNamed(
                                        GroupExpenseDetailScreen.routeName,
                                        arguments: DetailScreenArgument(
                                          ge: data[index],
                                          members: widget.group.members,
                                          amount: getAmount,
                                        ),
                                      );
                                },
                                child: Container(
                                  height: 160.0,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    borderRadius:
                                        settlementMsg == "You'll pay for"
                                            ? const BorderRadius.only(
                                              topRight: Radius.circular(24.0),
                                              bottomLeft: Radius.circular(24.0),
                                              bottomRight: Radius.circular(
                                                24.0,
                                              ),
                                            )
                                            : const BorderRadius.only(
                                              topLeft: Radius.circular(24.0),
                                              bottomLeft: Radius.circular(24.0),
                                              bottomRight: Radius.circular(
                                                24.0,
                                              ),
                                            ),
                                  ),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade50,
                                            ),
                                            padding: const EdgeInsets.all(3.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.date_range,
                                                  color: Colors.grey,
                                                  size: 15.0,
                                                ),
                                                const SizedBox(width: 5.0),
                                                Text(
                                                  "${data[index].day} ${allMonths[data[index].month - 1]}",
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 11.0,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 8.0,
                                          ),
                                          child: Text(
                                            settlementMsg == "You'll pay for"
                                                ? "₹ $payAmount"
                                                : "₹ $getAmount",
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color:
                                                  settlementMsg ==
                                                          "You'll pay for"
                                                      ? kErrorColor
                                                      : kSuccessColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 28.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 5.0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                        ),
                                        width: double.infinity,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              settlementMsg,
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 11.0,
                                              ),
                                            ),
                                            const SizedBox(height: 5.0),
                                            Text(
                                              data[index].expenseDesc,
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 13.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Align(
                                        alignment: Alignment.centerRight,
                                        child: Padding(
                                          padding: EdgeInsets.only(right: 8.0),
                                          child: Icon(
                                            Icons.keyboard_arrow_right_outlined,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          itemCount: data.length,
                        ),
                      );
                } else if (ss.hasError) {
                  return Center(child: Text(ss.error.toString()));
                }
                return showCustomLoader(kBackColor);
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Material(
              elevation: 30.0,
              borderOnForeground: true,
              child: Container(
                height: 70.0,
                decoration: const BoxDecoration(color: Colors.white),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          AddExpenseScreen.routeName,
                          arguments: [
                            widget.group,
                            () {
                              fetchAgain();
                            },
                          ],
                        );
                      },
                      child: Container(
                        height: 40.0,
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        decoration: BoxDecoration(
                          color: kBackColor,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Center(
                          child: Text(
                            "+ Expense",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void fetchAgain() async {
    groupExpenses = fetchGroupExpenses();
    setState(() {});
  }
}
