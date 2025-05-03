import 'dart:collection';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/components/loader.dart';
import 'package:frontend/controllers/group_controller.dart';
import 'package:frontend/utils/constants.dart';
import 'package:frontend/utils/errFlushbar.dart';
import 'package:get/get.dart';

import '../../controllers/profile_controller.dart';
import '../../models/group.dart';
import '../../models/user.dart';

class MemberFinal {
  String id;
  double paidAmt;
  double splitAmt;
  double diffAmt;
  MemberFinal({
    required this.id,
    required this.diffAmt,
    required this.paidAmt,
    required this.splitAmt,
  });
}

class Payments {
  String? user;
  double? amount;
  Payments({required this.user, required this.amount});
}

class AddExpenseScreen extends StatefulWidget {
  static const String routeName = "/addExpenseScreen";
  final Group g;
  final VoidCallback callback;
  const AddExpenseScreen({super.key, required this.g, required this.callback});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  TextEditingController amountController = TextEditingController();
  TextEditingController splitAmountController = TextEditingController();
  TextEditingController descController = TextEditingController();

  //adjust split bottom sheet
  List<TextEditingController> equalSplitControllers = [];
  List<TextEditingController> unequalSplitControllers = [];

  //paid by bottom sheet
  List<TextEditingController> paidControllers = [];

  final formKey = GlobalKey<FormState>();
  final ProfileController _profileController = Get.put(ProfileController());
  final GroupController _groupController = Get.put(GroupController());

  double remainingAmount = 0.0;
  double remainingSplitAmount = 0.0;
  bool isPaidByDetailsAdded = false;
  bool isSplitDetailsAdded = false;

  DateTime tempDate = DateTime.now();
  DateTime finalDate = DateTime.now();
  List allMonths = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  List<String> adjustSplit = ["Equally", "Unequally"];
  int finalSplitBy = 0;

  @override
  void initState() {
    super.initState();
    for (var ele in widget.g.members) {
      paidControllers.add(TextEditingController());
      equalSplitControllers.add(TextEditingController());
      unequalSplitControllers.add(TextEditingController());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        backgroundColor: Colors.white,
        titleSpacing: 0.0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Add Expense",
              style: TextStyle(color: Colors.black, fontSize: 15.0),
            ),
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.35,
                      child: Column(
                        children: [
                          Expanded(
                            flex: 3,
                            child: CupertinoDatePicker(
                              onDateTimeChanged: (val) {
                                setState(() {
                                  tempDate = val;
                                });
                              },
                              initialDateTime: finalDate,
                              maximumDate: DateTime.now(),
                              mode: CupertinoDatePickerMode.date,
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: kErrorColor,
                                  ),
                                  icon: Icon(Icons.close, color: kErrorColor),
                                  label: Text(
                                    "CANCEL",
                                    style: TextStyle(color: kErrorColor),
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      finalDate = tempDate;
                                      Navigator.of(context).pop();
                                    });
                                  },
                                  icon: Icon(Icons.check, color: kSuccessColor),
                                  style: TextButton.styleFrom(
                                    foregroundColor: kSuccessColor,
                                  ),
                                  label: Text(
                                    "OK",
                                    style: TextStyle(color: kSuccessColor),
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
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 14.0),
                child: Container(
                  color: Colors.grey.shade100,
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(
                        "${finalDate.day} ${allMonths[finalDate.month - 1]}, ${finalDate.year}",
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      const Icon(Icons.date_range, color: Colors.black),
                    ],
                  ),
                ),
              ),
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
          Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(right: 16.0),
                          child: Text(
                            "₹",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 30.0,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.50,
                          child: TextFormField(
                            controller: amountController,
                            cursorColor: Colors.black,
                            validator: (val) {
                              if (val!.isEmpty) {
                                return "Please enter the total expense amount";
                              }
                              return null;
                            },
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r"^\d+\.?\d{0,2}$"),
                              ),
                            ],
                            onChanged: (value) {},
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 30.0,
                            ),
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              hintText: "0",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 30.0,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.70,
                      child: TextFormField(
                        controller: descController,
                        cursorColor: Colors.black,
                        validator: (val) {
                          if (val!.isEmpty) {
                            return "Please enter a valid description";
                          }
                          return null;
                        },
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          hintText: "What was this expense for?",
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "You are splitting this expense.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Text(
                          "Paid by ",
                          style: TextStyle(color: Colors.grey),
                        ),
                        InkWell(
                          onTap: () {
                            if (formKey.currentState!.validate()) {
                              paidByBottomSheet();
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(color: Colors.grey),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 5.0,
                            ),
                            child: const Row(
                              children: [
                                Text("You"),
                                Icon(Icons.keyboard_arrow_down),
                              ],
                            ),
                          ),
                        ),
                        const Text(
                          " and Split ",
                          style: TextStyle(color: Colors.grey),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: Colors.grey),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 5.0,
                          ),
                          child: Row(
                            children: [
                              finalSplitBy == 0
                                  ? const Text("Equally")
                                  : const Text("Unequally"),
                              const Icon(Icons.keyboard_arrow_down),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 15.0,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 45.0,
                child: ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      if (isPaidByDetailsAdded) {
                        showLoader(context);
                        List<double> paidAmount = [];
                        String paidBy = "";
                        //605xff5d=5800,605xff5e=2200
                        String settlements = "";

                        for (var e in paidControllers) {
                          paidAmount.add(
                            double.parse(
                              e.text.isEmpty
                                  ? "0"
                                  : e.text.toLowerCase().trim().toString(),
                            ).toPrecision(2),
                          );
                        }

                        Map<String, double> payments = {};

                        for (int i = 0; i < widget.g.members.length; i++) {
                          payments[widget.g.members[i].userID] = paidAmount[i];
                          if (i == widget.g.members.length - 1) {
                            paidBy =
                                "$paidBy${widget.g.members[i].userID}=${paidAmount[i]}";
                          } else {
                            paidBy =
                                "$paidBy${widget.g.members[i].userID}=${paidAmount[i]},";
                          }
                        }

                        var sortedKeys = payments.keys.toList(growable: false)
                          ..sort(
                            (a, b) => payments[a]!.toInt().compareTo(
                              payments[b]!.toInt(),
                            ),
                          );

                        LinkedHashMap sortedMap = LinkedHashMap.fromIterable(
                          sortedKeys,
                          key: (k) => k,
                          value: (k) => payments[k],
                        );

                        payments = Map<String, double>.from(sortedMap);

                        List sortedPeople = payments.keys.toList();
                        List valuesPaid = payments.values.toList();

                        var sumOfValues = double.parse(
                          amountController.text.toLowerCase().trim(),
                        );
                        var mean = (sumOfValues / widget.g.members.length)
                            .toPrecision(2);

                        List sortedValuesPaid = [];

                        for (int i = 0; i < sortedPeople.length; i++) {
                          sortedValuesPaid.add(valuesPaid[i] - mean);
                        }

                        var i = 0;
                        var j = sortedPeople.length - 1;
                        double debt;

                        while (i < j) {
                          debt = min<double>(
                            -sortedValuesPaid[i],
                            sortedValuesPaid[j],
                          );
                          sortedValuesPaid[i] += debt;
                          sortedValuesPaid[j] -= debt;

                          //sender owes receiver

                          if (i == j - 1) {
                            settlements =
                                "$settlements${sortedPeople[i]}:${sortedPeople[j]}=${debt.toPrecision(2)}";
                          } else {
                            settlements =
                                "$settlements${sortedPeople[i]}:${sortedPeople[j]}=${debt.toPrecision(2)},";
                          }

                          if (sortedValuesPaid[i] == 0) {
                            i++;
                          }

                          if (sortedValuesPaid[j] == 0) {
                            j--;
                          }
                        }

                        Map<String, dynamic> data = {
                          "expense_desc": descController.text.trim(),
                          "total_expense": double.parse(
                            amountController.text.toLowerCase().trim(),
                          ),
                          "split_amount": mean,
                          "t_day": finalDate.day,
                          "t_month": finalDate.month,
                          "t_year": finalDate.year,
                          "group_id": widget.g.id,
                          "paid_by": paidBy,
                          "settlement": settlements,
                        };

                        await _groupController.addGroupExpense(data);
                        widget.callback();
                        stopLoader();
                        Navigator.of(context).pop();
                      } else {
                        showErrFlushBar(
                          context,
                          "Warning",
                          "Add valid paid by amount",
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(0, 10, 56, 1),
                  ),
                  child: const Text(
                    "SAVE EXPENSE",
                    style: TextStyle(
                      fontFamily: "CircularStd",
                      fontSize: 18.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  paidByBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: StatefulBuilder(
            builder: (context, StateSetter setState) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.45,
                decoration: BoxDecoration(
                  color: kBackColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                ),
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Column(
                      children: [
                        Center(
                          child: Container(
                            width: 50.0,
                            height: 4.0,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        ListTile(
                          contentPadding: const EdgeInsets.all(0.0),
                          title: const Text(
                            "Paid By",
                            style: TextStyle(color: Colors.white),
                          ),
                          leading: IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                            ),
                          ),
                          onTap: () {},
                          trailing: TextButton(
                            onPressed: () {
                              double total = 0.0;

                              for (var e in paidControllers) {
                                total =
                                    total +
                                    double.parse(
                                      e.text.isEmpty
                                          ? "0"
                                          : e.text
                                              .toLowerCase()
                                              .trim()
                                              .toString(),
                                    );
                              }

                              double expAmount = double.parse(
                                amountController.text
                                    .toLowerCase()
                                    .trim()
                                    .toString(),
                              );

                              if (total == expAmount) {
                                setState(() {
                                  remainingAmount = expAmount - total;
                                  isPaidByDetailsAdded = true;
                                });
                                Navigator.of(context).pop();
                              } else {
                                setState(() {
                                  remainingAmount = expAmount - total;
                                });
                              }
                            },
                            child: const Text("Done"),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            User? u = widget.g.members[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.all(0.0),
                              horizontalTitleGap: 0.0,
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundImage: AssetImage(
                                      "assets/images/avatars/${u.profilePic}",
                                    ),
                                  ),
                                  const SizedBox(width: 12.00),
                                  Text(
                                    u.userID ==
                                            _profileController.user.value.userID
                                        ? "You"
                                        : u.userName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.0,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              trailing: Container(
                                width: 110.0,
                                height: 35.0,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6.0),
                                  border: Border.all(color: Colors.grey),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 5.0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Center(
                                      child: Text(
                                        "₹",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.0,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5.0),
                                    Expanded(
                                      child: Center(
                                        child: TextFormField(
                                          controller: paidControllers[index],
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                              RegExp(r"^\d+\.?\d{0,2}$"),
                                            ),
                                          ],
                                          keyboardType: TextInputType.number,
                                          cursorColor: Colors.black,
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            hintText: "Amount",
                                            hintStyle: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          itemCount: widget.g.members.length,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                      child: Center(
                        child:
                            remainingAmount < 0
                                ? Text(
                                  "₹ $remainingAmount exceeding",
                                  style: TextStyle(
                                    color:
                                        remainingAmount == 0
                                            ? kSuccessColor
                                            : kErrorColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                                : Text(
                                  "₹ $remainingAmount remaining",
                                  style: TextStyle(
                                    color:
                                        remainingAmount == 0
                                            ? kSuccessColor
                                            : kErrorColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  int selectedValue = 0;

  adjustSplitBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: StatefulBuilder(
            builder: (context, StateSetter setState) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.50,
                decoration: BoxDecoration(
                  color: kBackColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                ),
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Column(
                      children: [
                        Center(
                          child: Container(
                            width: 50.0,
                            height: 4.0,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        ListTile(
                          contentPadding: const EdgeInsets.all(0.0),
                          title: const Text(
                            "Adjust Split",
                            style: TextStyle(color: Colors.white),
                          ),
                          leading: IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                            ),
                          ),
                          onTap: () {},
                          trailing: TextButton(
                            onPressed: () {
                              if (selectedValue == 1) {
                                double total = 0.0;

                                for (var e in unequalSplitControllers) {
                                  total =
                                      total +
                                      double.parse(
                                        e.text.isEmpty
                                            ? "0"
                                            : e.text
                                                .toLowerCase()
                                                .trim()
                                                .toString(),
                                      );
                                }

                                double expAmount = double.parse(
                                  amountController.text
                                      .toLowerCase()
                                      .trim()
                                      .toString(),
                                );

                                if (total == expAmount) {
                                  setState(() {
                                    finalSplitBy = selectedValue;
                                    remainingSplitAmount = expAmount - total;
                                  });
                                  Navigator.of(context).pop();
                                } else {
                                  setState(() {
                                    remainingSplitAmount = expAmount - total;
                                  });
                                }
                              } else {
                                Navigator.of(context).pop();
                              }
                            },
                            child: const Text("Done"),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 50.0,
                          child: Row(
                            children: [
                              Expanded(
                                child: CupertinoSegmentedControl(
                                  borderColor: kBackColor,
                                  children: {
                                    0: Container(
                                      decoration: BoxDecoration(
                                        color:
                                            selectedValue == 0
                                                ? kBackColor.withOpacity(0.8)
                                                : kBackColor,
                                      ),
                                      child: const Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(12.0),
                                          child: Text(
                                            "Equally",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    1: Container(
                                      decoration: BoxDecoration(
                                        color:
                                            selectedValue == 1
                                                ? kBackColor.withOpacity(0.8)
                                                : kBackColor,
                                      ),
                                      child: const Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(12.0),
                                          child: Text(
                                            "Unequally",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  },
                                  onValueChanged: (int val) {
                                    setState(() {
                                      selectedValue = val;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    selectedValue == 0
                        ? Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                User? u = widget.g.members[index];
                                equalSplitControllers[index].text =
                                    (double.parse(amountController.text) /
                                            widget.g.members.length.toDouble())
                                        .toPrecision(2)
                                        .toString();
                                return ListTile(
                                  contentPadding: const EdgeInsets.all(0.0),
                                  horizontalTitleGap: 0.0,
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: AssetImage(
                                          "assets/images/avatars/${u.profilePic}",
                                        ),
                                      ),
                                      const SizedBox(width: 12.00),
                                      Text(
                                        u.userName,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Container(
                                    width: 110.0,
                                    height: 35.0,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6.0),
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0,
                                      vertical: 5.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const Center(
                                          child: Text(
                                            "₹",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12.0,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 5.0),
                                        Expanded(
                                          child: Center(
                                            child: TextFormField(
                                              inputFormatters: [
                                                FilteringTextInputFormatter.allow(
                                                  RegExp(r"^\d+\.?\d{0,2}$"),
                                                ),
                                              ],
                                              keyboardType:
                                                  TextInputType.number,
                                              controller:
                                                  equalSplitControllers[index],
                                              enabled: false,
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              cursorColor: Colors.black,
                                              decoration: const InputDecoration(
                                                border: InputBorder.none,
                                                hintText: "Amount",
                                                hintStyle: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              itemCount: widget.g.members.length,
                            ),
                          ),
                        )
                        : Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                User? u = widget.g.members[index];
                                return ListTile(
                                  contentPadding: const EdgeInsets.all(0.0),
                                  horizontalTitleGap: 0.0,
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: AssetImage(
                                          "assets/images/avatars/${u.profilePic}",
                                        ),
                                      ),
                                      const SizedBox(width: 12.00),
                                      Text(
                                        u.userName,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Container(
                                    width: 110.0,
                                    height: 35.0,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6.0),
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0,
                                      vertical: 5.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const Center(
                                          child: Text(
                                            "₹",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12.0,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 5.0),
                                        Expanded(
                                          child: Center(
                                            child: TextFormField(
                                              inputFormatters: [
                                                FilteringTextInputFormatter.allow(
                                                  RegExp(r"^\d+\.?\d{0,2}$"),
                                                ),
                                              ],
                                              keyboardType:
                                                  TextInputType.number,
                                              controller:
                                                  unequalSplitControllers[index],
                                              enabled: true,
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              cursorColor: Colors.black,
                                              decoration: const InputDecoration(
                                                border: InputBorder.none,
                                                hintText: "Amount",
                                                hintStyle: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              itemCount: widget.g.members.length,
                            ),
                          ),
                        ),
                    selectedValue == 0
                        ? Container()
                        : Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child:
                                remainingSplitAmount < 0
                                    ? Text(
                                      "₹ $remainingSplitAmount exceeding",
                                      style: TextStyle(
                                        color:
                                            remainingSplitAmount == 0
                                                ? kSuccessColor
                                                : kErrorColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                    : Text(
                                      "₹ $remainingSplitAmount remaining",
                                      style: TextStyle(
                                        color:
                                            remainingSplitAmount == 0
                                                ? kSuccessColor
                                                : kErrorColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                          ),
                        ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
