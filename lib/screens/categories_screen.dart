import 'package:flutter/material.dart';
import 'package:frontend/utils/errFlushbar.dart';
import 'package:get/get.dart';

import '../components/category_item_button.dart';
import '../controllers/category_controller.dart';
import '../utils/constants.dart';
import '../utils/custom_loader.dart';

class CategoriesScreen extends StatefulWidget {
  static const String routeName = '/categoriesScreen';
  const CategoriesScreen({super.key});

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  List customCategoryItems = [
    'custom_blue.png',
    'custom_indigo.png',
    'custom_orange.png',
    'custom_purple.png',
    'custom_red.png',
    'custom_teal.png',
    'custom_yellow.png',
  ];

  bool isIncomeCatSelected = false;
  late int selectedCatIndex1 = 0;
  late int selectedCatIndex2 = 0;
  GlobalKey<FormState> addNewIncomeFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> addNewExpenseFormKey = GlobalKey<FormState>();
  TextEditingController newIncomeController = TextEditingController();
  TextEditingController newExpenseController = TextEditingController();

  late BuildContext buildContext1;
  late BuildContext buildContext2;

  late TabController _tabController;
  final CategoryController _categoryController = Get.put(CategoryController());

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    buildContext1 = context;
    buildContext2 = context;
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: kBackColor,
        onPressed: () {
          if (_tabController.indexIsChanging != true) {
            _tabController.index == 0
                ? showAddCategoryBottomSheet(
                  buildContext1,
                  addNewIncomeFormKey,
                  "Add New Income Category",
                  selectedCatIndex1,
                  newIncomeController,
                )
                : showAddCategoryBottomSheet(
                  buildContext2,
                  addNewExpenseFormKey,
                  "Add New Expense Category",
                  selectedCatIndex2,
                  newExpenseController,
                );
          }
        },
        child: const Icon(Icons.add, size: 35.0),
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: const Text("Categories", style: TextStyle(color: Colors.black)),
        bottom: TabBar(
          indicatorColor: Colors.black,
          controller: _tabController,
          tabs: const [
            Tab(child: Text("Income", style: TextStyle(color: Colors.black))),
            Tab(child: Text("Expense", style: TextStyle(color: Colors.black))),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Obx(
            () =>
                _categoryController.loading.value
                    ? showCustomLoader(kBackColor)
                    : GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: _categoryController.incomes.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                          ),
                      itemBuilder:
                          (context, index) => CategoryItemButton(
                            click: () {},
                            longClick: () {},
                            item: _categoryController.incomes[index].name,
                            image:
                                _categoryController.incomes[index].img.contains(
                                      "custom",
                                    )
                                    ? "assets/images/custom/${_categoryController.incomes[index].img}"
                                    : "assets/images/incomes/${_categoryController.incomes[index].img}",
                          ),
                    ),
          ),
          Obx(
            () =>
                _categoryController.loading.value
                    ? showCustomLoader(kBackColor)
                    : GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: _categoryController.expenses.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                          ),
                      itemBuilder:
                          (context, index) => CategoryItemButton(
                            click: () {},
                            longClick: () {},
                            item: _categoryController.expenses[index].name,
                            image:
                                _categoryController.expenses[index].img
                                        .contains("custom")
                                    ? "assets/images/custom/${_categoryController.expenses[index].img}"
                                    : "assets/images/expenses/${_categoryController.expenses[index].img}",
                          ),
                    ),
          ),
        ],
      ),
    );
  }

  showAddCategoryBottomSheet(
    BuildContext context,
    Key key,
    String title,
    int selected,
    var controller,
  ) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: StatefulBuilder(
            builder: (context, StateSetter setState) {
              return Form(
                key: key,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: ListView(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: List.generate(
                            customCategoryItems.length,
                            (index) => Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                      selected == index
                                          ? kBackColor.withOpacity(0.20)
                                          : Colors.transparent,
                                ),
                                onPressed: () {
                                  setState(() {
                                    selected = index;
                                  });
                                },
                                child: Image.asset(
                                  "assets/images/custom/${customCategoryItems[index]}",
                                  height: 50.0,
                                  width: 50.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: TextFormField(
                          controller: controller,
                          autofocus: true,
                          decoration: const InputDecoration(
                            labelText: 'Category name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              controller.clear();
                              Navigator.of(context).pop();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            icon: Icon(Icons.close, color: kErrorColor),
                            label: Text(
                              "CANCEL",
                              style: TextStyle(color: kErrorColor),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () async {
                              if (controller.text != "") {
                                //it means category icon and name is selected
                                if (title.contains("Income")) {
                                  //it means it is income category
                                  Map<String, dynamic> data = {
                                    "income_name": controller.text,
                                    "image_src": customCategoryItems[selected],
                                    "isDefault": false,
                                  };
                                  await _categoryController.addIncome(data);
                                  Navigator.of(context).pop();
                                } else {
                                  Map<String, dynamic> data = {
                                    "expense_name": controller.text,
                                    "image_src": customCategoryItems[selected],
                                    "isDefault": false,
                                  };
                                  await _categoryController.addExpense(data);
                                  Navigator.of(context).pop();
                                }
                              } else {
                                showErrFlushBar(
                                  context,
                                  "Warning",
                                  "Category name can not be empty",
                                );
                              }
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.green,
                            ),
                            icon: const Icon(Icons.check, color: Colors.green),
                            label: const Text(
                              "ADD",
                              style: TextStyle(color: Colors.green),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
