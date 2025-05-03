import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/controllers/profile_controller.dart';
import 'package:frontend/utils/constants.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../components/loader.dart';
import '../../controllers/category_controller.dart';

DateTime selectedDate1 = DateTime.now();

class NewTransactionScreen extends StatefulWidget {
  static const String routeName = '/newTransactionScreen';
  const NewTransactionScreen({super.key});
  @override
  _NewTransactionScreenState createState() => _NewTransactionScreenState();
}

class _NewTransactionScreenState extends State<NewTransactionScreen> {
  int selectedValue = 0; //0 for income and 1 for expense
  int imgIndexForCalculator1 = 0;
  int imgIndexForCalculator2 = 0;
  int imgIndexForPaymentMode = 0;

  final CategoryController _categoryController = Get.put(CategoryController());
  final ProfileController _profileController = Get.put(ProfileController());

  TextEditingController memoController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  GlobalKey<FormState> newTransactionFormKey = GlobalKey<FormState>();

  String memo = "";
  double amount = 0.0;

  DateTime tempDate = DateTime.now();
  DateTime finalDate = DateTime.now();

  final ImagePicker _picker = ImagePicker();
  File? _image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Add New Transaction",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        elevation: 0.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Obx(
            () =>
                _categoryController.loading.value == true
                    ? Center(child: returnLoader(color: kBackColor))
                    : Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 70.0,
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
                                                ? kBackColor
                                                : Colors.white,
                                        border: Border.all(
                                          color: kBackColor,
                                          width: 2.0,
                                        ),
                                      ),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Text(
                                            "INCOME",
                                            style: TextStyle(
                                              color:
                                                  selectedValue == 0
                                                      ? Colors.white
                                                      : kBackColor,
                                              fontSize: 17.0,
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
                                                ? kBackColor
                                                : Colors.white,
                                        border: Border.all(
                                          color: kBackColor,
                                          width: 2.0,
                                        ),
                                      ),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Text(
                                            "EXPENSE",
                                            style: TextStyle(
                                              color:
                                                  selectedValue == 1
                                                      ? Colors.white
                                                      : kBackColor,
                                              fontSize: 17.0,
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
                        selectedValue == 0
                            ? Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Container(
                                height: 90.0,
                                alignment: Alignment.center,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  itemBuilder: (context, i) {
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          imgIndexForCalculator1 = i;
                                        });
                                      },
                                      child: Container(
                                        width: 90.0,
                                        decoration: BoxDecoration(
                                          color:
                                              imgIndexForCalculator1 == i
                                                  ? kBackColor.withOpacity(0.1)
                                                  : Colors.transparent,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              _categoryController.incomes[i].img
                                                      .contains("custom")
                                                  ? "assets/images/custom/${_categoryController.incomes[i].img}"
                                                  : "assets/images/incomes/${_categoryController.incomes[i].img}",
                                              height: 30.0,
                                              width: 30.0,
                                              errorBuilder: (
                                                context,
                                                error,
                                                stackTrace,
                                              ) {
                                                // Show a fallback icon if image fails to load
                                                return const Icon(
                                                  Icons.monetization_on,
                                                  size: 30.0,
                                                  color: Colors.blue,
                                                );
                                              },
                                            ),
                                            const SizedBox(height: 12.0),
                                            AutoSizeText(
                                              _categoryController
                                                  .incomes[i]
                                                  .name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  itemCount: _categoryController.incomes.length,
                                ),
                              ),
                            )
                            : Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Container(
                                height: 90.0,
                                alignment: Alignment.center,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  itemBuilder: (context, i) {
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          imgIndexForCalculator2 = i;
                                        });
                                      },
                                      child: Container(
                                        width: 90.0,
                                        decoration: BoxDecoration(
                                          color:
                                              imgIndexForCalculator2 == i
                                                  ? kBackColor.withOpacity(0.1)
                                                  : Colors.transparent,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              _categoryController
                                                      .expenses[i]
                                                      .img
                                                      .contains("custom")
                                                  ? "assets/images/custom/${_categoryController.expenses[i].img}"
                                                  : "assets/images/expenses/${_categoryController.expenses[i].img}",
                                              height: 30.0,
                                              width: 30.0,
                                            ),
                                            const SizedBox(height: 12.0),
                                            AutoSizeText(
                                              _categoryController
                                                  .expenses[i]
                                                  .name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  itemCount:
                                      _categoryController.expenses.length,
                                ),
                              ),
                            ),
                        Form(
                          key: newTransactionFormKey,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                  vertical: 15.0,
                                ),
                                child: TextFormField(
                                  controller: amountController,
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return "* Amount is required";
                                    }
                                    try {
                                      double amount = double.parse(val);
                                      if (amount <= 0) {
                                        return "* Amount must be greater than zero";
                                      }
                                    } catch (e) {
                                      return "* Please enter a valid number";
                                    }
                                    return null;
                                  },
                                  inputFormatters: [
                                    //FilteringTextInputFormatter.allow((RegExp("[.0-9]"))),
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r"^\d+\.?\d{0,2}$"),
                                    ),
                                  ],
                                  onSaved: (val) {
                                    setState(() {
                                      amount = double.parse(val!.trim());
                                    });
                                  },
                                  cursorColor: kBackColor,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: const OutlineInputBorder(),
                                    labelText: "Amount",
                                    labelStyle: const TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    enabledBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey,
                                        width: 2.0,
                                      ),
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey,
                                        width: 2.0,
                                      ),
                                    ),
                                    prefixIcon: Icon(
                                      selectedValue == 0
                                          ? Icons.add
                                          : Icons.remove,
                                      color: kBackColor,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15.0,
                                  horizontal: 20.0,
                                ),
                                child: GestureDetector(
                                  onTap: showMyDatePicker,
                                  child: TextFormField(
                                    enabled: false,
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      suffixIcon: const Icon(
                                        Icons.calendar_today,
                                      ),
                                      enabledBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey,
                                          width: 2.0,
                                        ),
                                      ),
                                      disabledBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey,
                                          width: 2.0,
                                        ),
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey,
                                          width: 2.0,
                                        ),
                                      ),
                                      labelStyle: const TextStyle(
                                        color: Colors.black,
                                      ),
                                      labelText:
                                          "${allMonths[finalDate.month - 1]} ${finalDate.day}, ${finalDate.year}",
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15.0,
                                  horizontal: 20.0,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: memoController,
                                        cursorColor: kBackColor,
                                        onSaved: (val) {
                                          setState(() {
                                            memo = val!;
                                          });
                                        },
                                        decoration: const InputDecoration(
                                          labelText: "Description (optional)",
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.grey,
                                              width: 2.0,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.grey,
                                              width: 2.0,
                                            ),
                                          ),
                                          labelStyle: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: _selectSource,
                                      tooltip: "Attach Bill Image",
                                      icon: const Icon(
                                        Icons.image,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _image != null
                                  ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0,
                                      vertical: 15.0,
                                    ),
                                    child: Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              8.0,
                                            ),
                                            image: DecorationImage(
                                              image: FileImage(_image!),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          height: 120.0,
                                          width: double.infinity,
                                        ),
                                        Align(
                                          alignment: Alignment.topRight,
                                          child: Container(
                                            height: 30.0,
                                            width: 30.0,
                                            decoration: BoxDecoration(
                                              color: Colors.black26,
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            child: Center(
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _image = null;
                                                  });
                                                },
                                                child: const Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                  size: 24.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                  : const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20.0,
                                        vertical: 15.0,
                                      ),
                                      child: Text("No Bill selected..."),
                                    ),
                                  ),
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20.0,
                                    vertical: 8.0,
                                  ),
                                  child: Text("Select Payment mode : "),
                                ),
                              ),

                              const SizedBox(height: 10.0),
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Container(
                                  height: 90.0,
                                  alignment: Alignment.center,
                                  child: Obx(
                                    () => ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      itemBuilder: (context, i) {
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              imgIndexForPaymentMode = i;
                                            });
                                          },
                                          child: Container(
                                            width: 90.0,
                                            decoration: BoxDecoration(
                                              color:
                                                  imgIndexForPaymentMode == i
                                                      ? kBackColor.withOpacity(
                                                        0.1,
                                                      )
                                                      : Colors.transparent,
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Image.asset(
                                                  "assets/images/paymodes/${_categoryController.paymentModes[i].imgSrc}",
                                                  // "assets/images/paymodes/upi.png",
                                                  height: 30.0,
                                                  width: 30.0,
                                                  errorBuilder: (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) {
                                                    // Show a fallback icon if image fails to load
                                                    return const Icon(
                                                      Icons.shopping_cart,
                                                      size: 30.0,
                                                      color: Colors.red,
                                                    );
                                                  },
                                                ),

                                                const SizedBox(height: 12.0),
                                                AutoSizeText(
                                                  _categoryController
                                                      .paymentModes[i]
                                                      .name,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                      itemCount:
                                          _categoryController
                                              .paymentModes
                                              .length,
                                    ),
                                  ),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                  vertical: 15.0,
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (newTransactionFormKey.currentState!
                                        .validate()) {
                                      allOk();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kBackColor,
                                    padding: const EdgeInsets.all(0.0),
                                  ),
                                  child: const SizedBox(
                                    height: 50.0,
                                    width: double.infinity,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 30.0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "ADD",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20.0,
                                            ),
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
                      ],
                    ),
          ),
        ),
      ),
    );
  }

  _selectSource() {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: 145.0,
          padding: const EdgeInsets.all(12.0),
          color: Colors.white,
          child: Column(
            children: [
              SizedBox(
                height: 60.0,
                child: ListTile(
                  onTap: () async {
                    final XFile? pickedImage = await _picker.pickImage(
                      source: ImageSource.camera,
                    );
                    if (pickedImage != null) {
                      Navigator.of(context).pop();
                      setState(() {
                        _image = File(pickedImage.path);
                      });
                    }
                  },
                  title: const Text(
                    "Choose from camera",
                    style: TextStyle(color: Colors.black),
                  ),
                  leading: Icon(Icons.camera, color: kBackColor),
                ),
              ),
              SizedBox(
                height: 60.0,
                child: ListTile(
                  onTap: () async {
                    final XFile? pickedImage = await _picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (pickedImage != null) {
                      Navigator.of(context).pop();
                      setState(() {
                        _image = File(pickedImage.path);
                      });
                    }
                  },
                  title: const Text(
                    "Choose from Gallery",
                    style: TextStyle(color: Colors.black),
                  ),
                  leading: Icon(Icons.image, color: kBackColor),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  showMyDatePicker() {
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
                          finalDate = tempDate;
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

  void allOk() async {
    showLoader(context);

    Map<String, dynamic> transaction = {};

    transaction["t_name"] =
        selectedValue == 0
            ? _categoryController.incomes[imgIndexForCalculator1].name
            : _categoryController.expenses[imgIndexForCalculator2].name;

    if (memoController.text.isNotEmpty) {
      transaction["t_desc"] = memoController.text.trim();
    }

    // Fix image path construction
    String finalImgSrc = "";
    if (selectedValue == 0) {
      // Income category
      finalImgSrc = _categoryController.incomes[imgIndexForCalculator1].img;
    } else {
      // Expense category
      finalImgSrc = _categoryController.expenses[imgIndexForCalculator2].img;
    }

    transaction["t_imgsrc"] = finalImgSrc;
    transaction["t_day"] = finalDate.day;
    transaction["t_month"] = finalDate.month;
    transaction["t_year"] = finalDate.year;
    transaction["t_amount"] = double.parse(amountController.text.trim());
    transaction["t_category"] = selectedValue == 0 ? "Income" : "Expense";
    transaction["p_id"] =
        _categoryController.paymentModes[imgIndexForPaymentMode].id;

    try {
      // Load existing transactions first
      await _profileController.fetchMyTransactions(
        finalDate.month,
        finalDate.year,
      );

      // Add the new transaction
      if (_image != null) {
        await _profileController.addTransaction(transaction, _image!.path);
      } else {
        await _profileController.addTransaction(transaction, "");
      }

      selectedDate1 = finalDate;

      _profileController.selectedDate.value = DateTime(
        finalDate.year,
        finalDate.month,
      );

      stopLoader();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Transaction added successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      stopLoader();
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error adding transaction: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
