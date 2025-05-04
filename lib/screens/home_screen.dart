import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:frontend/components/custom_drawer.dart' as my_drawer;
import 'package:frontend/components/no_transactions_msg.dart';
import 'package:frontend/controllers/category_controller.dart';
import 'package:frontend/controllers/creditors_controller.dart';
import 'package:frontend/controllers/debtors_controller.dart';
import 'package:frontend/controllers/goals_controller.dart';
import 'package:frontend/controllers/group_controller.dart';
import 'package:frontend/controllers/login_controller.dart';
import 'package:frontend/controllers/profile_controller.dart';
import 'package:frontend/screens/categories_screen.dart';
import 'package:frontend/screens/creditors/creditors_screen.dart';
import 'package:frontend/screens/debtors/debtors_screen.dart';
import 'package:frontend/screens/goals/goals_screen.dart';
import 'package:frontend/screens/groups/groups_screen.dart';
import 'package:frontend/screens/profile/profile_screen.dart';
import 'package:frontend/screens/settings_screen.dart';
import 'package:frontend/screens/transactions/new_transaction_screen.dart';
import 'package:frontend/screens/transactions/transaction_detail_screen.dart';
import 'package:frontend/screens/transactions/update_transaction_screen.dart';
import 'package:frontend/services/notification_service.dart';
import 'package:frontend/services/transaction_filtering_service.dart';
import 'package:frontend/utils/constants.dart';
import 'package:frontend/utils/custom_loader.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';

import '../components/custom_balance_card.dart';
import '../components/loader.dart';
import '../models/transaction.dart';
import '../utils/errFlushbar.dart';
import 'login/mobile_number_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/homescreen';
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<my_drawer.SwipeDrawerState> drawerKey =
      GlobalKey<my_drawer.SwipeDrawerState>();

  //load all the data first
  final ProfileController _profileController = Get.put(ProfileController());
  final CategoryController _categoryController = Get.put(CategoryController());
  final DebtorsController _debtorsController = Get.put(DebtorsController());
  final CreditorsController _creditorsScreen = Get.put(CreditorsController());
  final GroupController _groupController = Get.put(GroupController());
  final GoalsController _goalsController = Get.put(GoalsController());

  late AnimationController _animationController;
  bool _isPlaying = false;
  bool areTransactionsBeingFetched = false;

  _onHorizontalSwipe(SwipeDirection direction) {
    setState(() {
      if (direction == SwipeDirection.right) {
        if (drawerKey.currentState?.isOpened() == false) {
          drawerKey.currentState?.openDrawer();
          _animationController.forward();
          _isPlaying = true;
        }
      } else {
        if (drawerKey.currentState!.isOpened()) {
          drawerKey.currentState?.closeDrawer();
          _animationController.reverse();
          _isPlaying = false;
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  var _isVisible = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _hideButtonController = ScrollController();
    _hideButtonController.addListener(() {
      if (_hideButtonController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_isVisible == true) {
          setState(() {
            _isVisible = false;
          });
        }
      } else {
        if (_hideButtonController.position.userScrollDirection ==
            ScrollDirection.forward) {
          if (_isVisible == false) {
            setState(() {
              _isVisible = true;
            });
          }
        }
      }
    });
  }

  bool pickerIsExpanded = false;
  int _pickerYear = DateTime.now().year;

  late ScrollController _hideButtonController;

  dynamic _pickerOpen = false;

  void switchPicker() {
    setState(() {
      _pickerOpen = !_pickerOpen;
    });
  }

  List<Widget> generateRowOfMonths(from, to) {
    List<Widget> months = [];
    for (int i = from; i <= to; i++) {
      DateTime dateTime = DateTime(_pickerYear, i, 1);
      final backgroundColor =
          dateTime.isAtSameMomentAs(_profileController.selectedDate.value)
              ? kBackColor.withOpacity(0.15)
              : Colors.transparent;
      months.add(
        Expanded(
          child: AnimatedSwitcher(
            duration: kThemeChangeDuration,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: TextButton(
              key: ValueKey(backgroundColor),
              onPressed: () {
                setState(() {
                  _profileController.selectedDate.value = dateTime;
                });
                switchPicker();
                _profileController.fetchMyTransactions(
                  _profileController.selectedDate.value.month,
                  _profileController.selectedDate.value.year,
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: backgroundColor,
                shape: const CircleBorder(),
              ),
              child: Text(
                DateFormat('MMM').format(dateTime),
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontFamily: "CircularStd",
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ),
        ),
      );
    }
    return months;
  }

  List<Widget> generateMonths() {
    return [
      Row(children: generateRowOfMonths(1, 6)),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: generateRowOfMonths(7, 12),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: my_drawer.SwipeDrawer(
        drawer: buildDrawer(),
        key: drawerKey,
        handleCloseAnimation: () {
          setState(() {
            _isPlaying = false;
            _animationController.reverse();
          });
        },
        radius: 20,
        backgroundColor: kBackColor,
        bodyBackgroundPeekSize: 50,
        hasClone: false,
        bodySize: 120.0,
        child: SimpleGestureDetector(
          onHorizontalSwipe: _onHorizontalSwipe,
          child: SafeArea(
            child: Container(
              color: Colors.white,
              child: Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _isPlaying = !_isPlaying;
                                          _isPlaying
                                              ? _animationController.forward()
                                              : _animationController.reverse();
                                        });
                                        if (drawerKey.currentState!
                                            .isOpened()) {
                                          drawerKey.currentState?.closeDrawer();
                                        } else {
                                          drawerKey.currentState?.openDrawer();
                                        }
                                      },
                                      icon: AnimatedIcon(
                                        icon: AnimatedIcons.menu_close,
                                        progress: _animationController,
                                        color: kBackColor,
                                      ),
                                    ),
                                  ),
                                  const Text(
                                    "BudgetBuddy",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 22.0,
                                      fontFamily: "CircularStd",
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: Obx(
                                  () => TextButton(
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.grey.shade600,
                                    ),
                                    onPressed: switchPicker,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          DateFormat.yMMMM().format(
                                            _profileController
                                                .selectedDate
                                                .value,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "CircularStd",
                                            fontSize: 15.0,
                                          ),
                                        ),
                                        _pickerOpen
                                            ? const Icon(
                                              Icons.arrow_drop_up_sharp,
                                              color: Colors.black,
                                            )
                                            : const Icon(
                                              Icons.arrow_drop_down_sharp,
                                              color: Colors.black,
                                            ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                setState(() {
                                  areTransactionsBeingFetched = true;
                                });
                                List<Transaction> transactions =
                                    await _profileController
                                        .fetchMyAllTransactions();
                                setState(() {
                                  areTransactionsBeingFetched = false;
                                });
                                Navigator.of(context).pushNamed(
                                  TransactionFilteringScreen.routeName,
                                  arguments: transactions,
                                );
                              },
                              icon:
                                  areTransactionsBeingFetched
                                      ? showCustomLoader(Colors.black)
                                      : const Icon(
                                        Icons.search,
                                        color: Colors.black,
                                      ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Obx(
                            () =>
                                _profileController.loading.value == true
                                    ? returnLoader(color: kBackColor)
                                    : Stack(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0,
                                          ),
                                          child: Column(
                                            children: [
                                              CustomBalanceCard(
                                                income:
                                                    _profileController
                                                        .income
                                                        .value,
                                                expense:
                                                    _profileController
                                                        .expense
                                                        .value,
                                                balance:
                                                    _profileController
                                                        .balance
                                                        .value,
                                                month:
                                                    _profileController
                                                        .selectedDate
                                                        .value
                                                        .month,
                                                year:
                                                    _profileController
                                                        .selectedDate
                                                        .value
                                                        .year,
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 8.0,
                                                      ),
                                                  child:
                                                      _profileController
                                                              .transactions
                                                              .isEmpty
                                                          ? const EmptyMsgContainer()
                                                          : Center(
                                                            child: ListView.builder(
                                                              controller:
                                                                  _hideButtonController,
                                                              physics:
                                                                  const BouncingScrollPhysics(),
                                                              itemBuilder: (
                                                                context,
                                                                i,
                                                              ) {
                                                                List<DateTime>
                                                                dates =
                                                                    _profileController
                                                                        .uniqueDates;

                                                                var list = _profileController.transactions.where(
                                                                  (element) =>
                                                                      DateTime(
                                                                        element
                                                                            .year,
                                                                        element
                                                                            .month,
                                                                        element
                                                                            .day,
                                                                      ) ==
                                                                      dates[i],
                                                                );

                                                                List<
                                                                  Transaction
                                                                >
                                                                finalList =
                                                                    List.from(
                                                                      list,
                                                                    );

                                                                var finalMIncome =
                                                                        0.0,
                                                                    finalMExpense =
                                                                        0.0;

                                                                for (
                                                                  int i = 0;
                                                                  i <
                                                                      finalList
                                                                          .length;
                                                                  i++
                                                                ) {
                                                                  finalList[i].category ==
                                                                          "Income"
                                                                      ? finalMIncome =
                                                                          finalMIncome +
                                                                          finalList[i]
                                                                              .amount
                                                                      : finalMExpense =
                                                                          finalMExpense +
                                                                          finalList[i]
                                                                              .amount;
                                                                }
                                                                return Theme(
                                                                  data: ThemeData(
                                                                    dividerColor:
                                                                        Colors
                                                                            .transparent,
                                                                  ),
                                                                  child: ExpansionTile(
                                                                    //closed icon color
                                                                    collapsedIconColor:
                                                                        Colors
                                                                            .grey,
                                                                    backgroundColor:
                                                                        Colors
                                                                            .transparent,
                                                                    //open icon color
                                                                    iconColor:
                                                                        Colors
                                                                            .grey,
                                                                    tilePadding:
                                                                        const EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              20.0,
                                                                        ),
                                                                    initiallyExpanded:
                                                                        true,
                                                                    childrenPadding: const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          15.0,
                                                                      vertical:
                                                                          0.0,
                                                                    ),
                                                                    title: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Expanded(
                                                                          child: AutoSizeText(
                                                                            "${dates[i].day}/${dates[i].month} \t\t ${DateFormat('EEEE').format(DateTime(dates[i].year, dates[i].month, dates[i].day))}",
                                                                            overflow:
                                                                                TextOverflow.visible,
                                                                            style: const TextStyle(
                                                                              color:
                                                                                  Colors.grey,
                                                                              fontWeight:
                                                                                  FontWeight.w500,
                                                                              fontSize:
                                                                                  10.0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          child: Row(
                                                                            children: [
                                                                              finalMIncome ==
                                                                                      0.0
                                                                                  ? Container()
                                                                                  : Expanded(
                                                                                    child: Align(
                                                                                      alignment:
                                                                                          Alignment.centerRight,
                                                                                      child: AutoSizeText(
                                                                                        '+ $finalMIncome',
                                                                                        overflow:
                                                                                            TextOverflow.visible,
                                                                                        style: const TextStyle(
                                                                                          color:
                                                                                              Colors.grey,
                                                                                          fontSize:
                                                                                              8.0,
                                                                                          fontWeight:
                                                                                              FontWeight.w500,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                              finalMExpense ==
                                                                                      0.0
                                                                                  ? Container()
                                                                                  : const SizedBox(
                                                                                    width:
                                                                                        16.0,
                                                                                  ),
                                                                              finalMExpense ==
                                                                                      0.0
                                                                                  ? Container()
                                                                                  : Expanded(
                                                                                    child: Align(
                                                                                      alignment:
                                                                                          Alignment.centerRight,
                                                                                      child: AutoSizeText(
                                                                                        '- $finalMExpense',
                                                                                        overflow:
                                                                                            TextOverflow.visible,
                                                                                        style: const TextStyle(
                                                                                          color:
                                                                                              Colors.grey,
                                                                                          fontSize:
                                                                                              8.0,
                                                                                          fontWeight:
                                                                                              FontWeight.w500,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    children: List.generate(
                                                                      finalList
                                                                          .length,
                                                                      (i) {
                                                                        return Column(
                                                                          children: [
                                                                            Card(
                                                                              elevation:
                                                                                  0.4,
                                                                              child: ListTile(
                                                                                onTap: () {
                                                                                  Navigator.of(
                                                                                    context,
                                                                                  ).pushNamed(
                                                                                    TransactionDetailScreen.routeName,
                                                                                    arguments: [
                                                                                      finalList[i],
                                                                                      false,
                                                                                    ],
                                                                                  );
                                                                                },
                                                                                onLongPress: () {
                                                                                  showOperationBottomSheet(
                                                                                    finalList[i],
                                                                                  );
                                                                                },
                                                                                dense:
                                                                                    true,
                                                                                title: Text(
                                                                                  finalList[i].name,
                                                                                  style: const TextStyle(
                                                                                    color:
                                                                                        Colors.black,
                                                                                    fontWeight:
                                                                                        FontWeight.w600,
                                                                                    fontSize:
                                                                                        15.5,
                                                                                  ),
                                                                                ),
                                                                                // With this:
                                                                                leading: Image.asset(
                                                                                  "assets/images/custom/${finalList[i].imgSrc}",
                                                                                  height:
                                                                                      26.0,
                                                                                  width:
                                                                                      26.0,
                                                                                  errorBuilder: (
                                                                                    context,
                                                                                    error,
                                                                                    stackTrace,
                                                                                  ) {
                                                                                    // Fallback to the non-custom path if custom fails
                                                                                    return Image.asset(
                                                                                      "assets/images/${finalList[i].imgSrc}",
                                                                                      height:
                                                                                          26.0,
                                                                                      width:
                                                                                          26.0,
                                                                                      errorBuilder: (
                                                                                        context,
                                                                                        error,
                                                                                        stackTrace,
                                                                                      ) {
                                                                                        // If both fail, show a placeholder
                                                                                        return Icon(
                                                                                          Icons.image_not_supported,
                                                                                          size:
                                                                                              26.0,
                                                                                        );
                                                                                      },
                                                                                    );
                                                                                  },
                                                                                ),
                                                                                subtitle:
                                                                                    finalList[i].description ==
                                                                                            finalList[i].name
                                                                                        ? const Text(
                                                                                          "",
                                                                                        )
                                                                                        : Padding(
                                                                                          padding: const EdgeInsets.only(
                                                                                            right:
                                                                                                8.0,
                                                                                          ),
                                                                                          child: AutoSizeText(
                                                                                            finalList[i].description,
                                                                                            overflow:
                                                                                                TextOverflow.ellipsis,
                                                                                            style: const TextStyle(
                                                                                              color:
                                                                                                  Colors.grey,
                                                                                              fontSize:
                                                                                                  11.0,
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                trailing: Text(
                                                                                  finalList[i].category ==
                                                                                          "Income"
                                                                                      ? "${finalList[i].amount}"
                                                                                      : "- ${finalList[i].amount}",
                                                                                  style: TextStyle(
                                                                                    color:
                                                                                        finalList[i].category ==
                                                                                                "Income"
                                                                                            ? Colors.green
                                                                                            : Colors.red,
                                                                                    fontSize:
                                                                                        16.0,
                                                                                    fontWeight:
                                                                                        FontWeight.w600,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        );
                                                                      },
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              itemCount:
                                                                  _profileController
                                                                      .uniqueDates
                                                                      .length,
                                                            ),
                                                          ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Material(
                                          elevation: 100.0,
                                          shadowColor: Colors.grey.shade300,
                                          color: Theme.of(context).cardColor,
                                          child: AnimatedSize(
                                            curve: Curves.easeInOut,
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            child: SizedBox(
                                              height:
                                                  _pickerOpen
                                                      ? double.infinity
                                                      : 0.0,
                                              child: SizedBox(
                                                height: 200.0,
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        IconButton(
                                                          onPressed: () {
                                                            setState(() {
                                                              _pickerYear =
                                                                  _pickerYear -
                                                                  1;
                                                            });
                                                          },
                                                          icon: const Icon(
                                                            Icons
                                                                .navigate_before_rounded,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Center(
                                                            child: Text(
                                                              _pickerYear
                                                                  .toString(),
                                                              style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        IconButton(
                                                          onPressed: () {
                                                            setState(() {
                                                              _pickerYear =
                                                                  _pickerYear +
                                                                  1;
                                                            });
                                                          },
                                                          icon: const Icon(
                                                            Icons
                                                                .navigate_next_rounded,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    ...generateMonths(),
                                                    const SizedBox(
                                                      height: 10.0,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 25.0),
                      child: FloatingActionButton(
                        heroTag: 'addNew',
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).pushNamed(NewTransactionScreen.routeName);
                        },
                        backgroundColor: kBackColor,
                        child: const Icon(Icons.add, size: 35.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  showOperationBottomSheet(Transaction t) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, StateSetter setState) {
            return Container(
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
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "What do you want to do with this transaction?",
                      style: TextStyle(color: Colors.white, fontSize: 15.0),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 1,
                      child: ListTile(
                        tileColor: kBackColor.withOpacity(0.9),
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
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15.5,
                          ),
                        ),
                        dense: true,
                        leading: Image.asset(
                          // "assets/images/custom/${t.imgSrc}",
                          "assets/images/${t.imgSrc}",
                          height: 26.0,
                          width: 26.0,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback to the non-custom path if custom fails
                            return Image.asset(
                              "assets/images/${t.imgSrc}",
                              height: 26.0,
                              width: 26.0,
                              errorBuilder: (context, error, stackTrace) {
                                // If both fail, show a placeholder
                                return Icon(
                                  Icons.image_not_supported,
                                  size: 26.0,
                                );
                              },
                            );
                          },
                        ),
                        subtitle:
                            t.description == t.name
                                ? const Text("")
                                : Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: AutoSizeText(
                                    t.description,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 11.0,
                                    ),
                                  ),
                                ),
                      ),
                    ),
                  ),
                  bottomSheetTile(
                    onClick: () async {
                      showLoader(context);
                      Map<String, dynamic> data = {
                        "t_name": t.name,
                        "t_desc": t.description,
                        "t_day": t.day,
                        "t_month": t.month,
                        "t_year": t.year,
                        "t_amount": t.amount,
                        "t_imgsrc": t.imgSrc,
                        "t_category": t.category,
                        "t_billsrc": t.billSrc,
                        "p_id": t.paymentID,
                      };

                      await _profileController.addTransaction(data, "");
                      stopLoader();

                      Navigator.of(context).pop();
                    },
                    title: "Duplicate",
                    iconData: Icons.copy,
                  ),
                  bottomSheetTile(
                    onClick: () {
                      Navigator.of(context).pop();
                      showDeleteConfirmationBottomSheet(t);
                    },
                    title: "Delete",
                    iconData: Icons.delete,
                  ),
                  bottomSheetTile(
                    onClick: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamed(
                        UpdateTransactionScreen.routeName,
                        arguments: t,
                      );
                    },
                    title: "Edit",
                    iconData: Icons.edit,
                  ),
                  bottomSheetTile(
                    onClick: () {
                      Navigator.of(context).pop();
                    },
                    title: "Cancel",
                    iconData: Icons.close,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  showDeleteConfirmationBottomSheet(Transaction t) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, StateSetter setState) {
            return Container(
              decoration: BoxDecoration(
                color: kBackColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  topRight: Radius.circular(16.0),
                ),
              ),
              height: 200.0,
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "Are you sure you want to delete this transaction?",
                      style: TextStyle(color: Colors.white, fontSize: 15.0),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          textStyle: TextStyle(color: kSuccessColor),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          "No, Cancel",
                          style: TextStyle(color: Colors.white, fontSize: 17.0),
                        ),
                      ),
                      ElevatedButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          showLoader(context);

                          await _profileController.deleteTransaction(
                            t.id,
                            t.billSrc,
                          );

                          stopLoader();
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          "Yes, Delete",
                          style: TextStyle(color: Colors.black, fontSize: 17.0),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  bottomSheetTile({
    required VoidCallback onClick,
    required String title,
    required IconData iconData,
  }) {
    return Card(
      elevation: 0,
      child: ListTile(
        tileColor: kBackColor.withOpacity(1),
        onTap: onClick,
        dense: true,
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 15.0),
        ),
        leading: Icon(iconData, color: Colors.white),
      ),
    );
  }

  Widget buildDrawer() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            userInfo(),
            customTile(
              iconData: Icons.category_rounded,
              string: 'Categories',
              onClick: () {
                drawerKey.currentState?.closeDrawer();
                Navigator.of(context).pushNamed(CategoriesScreen.routeName);
              },
            ),
            myDivider(),
            customTile(
              iconData: Icons.check_circle_outline,
              string: 'Goals',
              onClick: () {
                drawerKey.currentState?.closeDrawer();
                Navigator.of(context).pushNamed(GoalsScreen.routeName);
              },
            ),
            myDivider(),
            customTile(
              iconData: Icons.person,
              string: 'Debtors',
              onClick: () {
                drawerKey.currentState?.closeDrawer();
                Navigator.of(context).pushNamed(DebtorsScreen.routeName);
              },
            ),
            myDivider(),
            customTile(
              iconData: Icons.person_outline_sharp,
              string: 'Creditors',
              onClick: () {
                drawerKey.currentState?.closeDrawer();
                Navigator.of(context).pushNamed(CreditorsScreen.routeName);
              },
            ),
            myDivider(),
            customTile(
              iconData: Icons.group,
              string: 'Groups',
              onClick: () {
                drawerKey.currentState?.closeDrawer();
                Navigator.of(context).pushNamed(GroupsScreen.routeName);
              },
            ),
            myDivider(),
            customTile(
              iconData: Icons.settings,
              string: 'Settings',
              onClick: () {
                drawerKey.currentState?.closeDrawer();
                Navigator.of(context).pushNamed(SettingScreen.routeName);
              },
            ),
            myDivider(),
            customTile(
              iconData: Icons.logout,
              string: 'Log out',
              onClick: () {
                drawerKey.currentState?.closeDrawer();
                showLogoutDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            "Are you sure you want to logout ?",
            style: TextStyle(color: kBackColor, fontWeight: FontWeight.w600),
          ),
          content: const Text(
            "Your data will not be deleted after signing out. You can recover your data with the same account.",
          ),
          contentTextStyle: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w400,
            fontSize: 16.0,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("NO", style: TextStyle(color: kBackColor)),
            ),
            TextButton(
              onPressed: () async {
                showLoader(context);
                var res = await LoginController().logoutMe();

                if (res.statusCode != 200) {
                  stopLoader();
                  showErrFlushBar(context, "Logout Failed", "Try again !");
                } else {
                  final prefs = await SharedPreferences.getInstance();
                  bool success = await prefs.remove("tokenOfLoggedInUser");

                  if (success) {
                    stopLoader();
                    //notification will not be sent after user logs out
                    NotificationService().cancelNotification();

                    Navigator.of(context).pushNamedAndRemoveUntil(
                      MobileNumberScreen.routeName,
                      (route) => false,
                    );
                    showSuccessFlushBar(
                      context,
                      "Success !",
                      "Logged out successfully...",
                    );
                  }
                }
              },
              child: Text("YES", style: TextStyle(color: kBackColor)),
            ),
          ],
        );
      },
    );
  }

  Widget customTile({
    required IconData iconData,
    required String string,
    required VoidCallback onClick,
  }) {
    return ListTile(
      dense: true,
      //visualDensity: VisualDensity.compact,
      horizontalTitleGap: 3.0,
      leading: Icon(iconData, color: Colors.white),
      onTap: onClick,
      title: Text(
        string,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w400,
          fontSize: 14.0,
          fontFamily: "CircularStd",
        ),
      ),
    );
  }

  myDivider() {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Divider(
        color: Colors.grey.withOpacity(0.35),
        indent: 15,
        endIndent: 50,
      ),
    );
  }

  String greeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    }
    if (hour < 17) {
      return 'Good Afternoon';
    }
    return 'Good Evening';
  }

  userInfo() {
    return Obx(
      () => GestureDetector(
        onTap: () {
          drawerKey.currentState?.closeDrawer();
          Navigator.of(context).pushNamed(ProfilePage.routeName);
        },
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  width: 55.0,
                  height: 55.0,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        "assets/images/avatars/${_profileController.user.value.profilePic}",
                      ),
                      fit: BoxFit.contain,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                    shape: BoxShape.rectangle,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                      fontSize: 13.0,
                      fontFamily: "CircularStd",
                    ),
                  ),
                  Text(
                    _profileController.user.value.userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontFamily: "CircularStd",
                      fontSize: 15.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
