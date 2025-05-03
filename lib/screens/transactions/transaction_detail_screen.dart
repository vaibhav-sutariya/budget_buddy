import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/components/loader.dart';
import 'package:frontend/controllers/profile_controller.dart';
import 'package:frontend/models/paymentmode.dart';
import 'package:frontend/utils/constants.dart';
import 'package:get/get.dart';

import '../../controllers/category_controller.dart';
import '../../models/transaction.dart';

class TransactionDetailScreen extends StatefulWidget {
  static const String routeName = '/transactionDetailScreen';
  final Transaction t;
  final bool isFromFilterScreen;
  const TransactionDetailScreen({
    super.key,
    required this.t,
    required this.isFromFilterScreen,
  });
  @override
  _TransactionDetailScreenState createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  late PaymentMode payMode;
  final CategoryController _categoryController = Get.put(CategoryController());
  final ProfileController _profileController = Get.put(ProfileController());

  @override
  void initState() {
    imgUrl = "$baseURL/transactions/${widget.t.id}/billsrc";

    payMode = _categoryController.getPaymentModeByID(widget.t.paymentID);
    super.initState();
  }

  String imgUrl = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: kBackColor,
        elevation: 0.0,
        actions: [
          widget.isFromFilterScreen == true
              ? Container()
              : IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.white,
                ),
                onPressed: () {
                  showDeleteDialog();
                },
              ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        title: const Text(
          "Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
      ),
      body: CupertinoScrollbar(
        thickness: 12.0,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 10.0,
                right: 10.0,
                top: 10.0,
                bottom: 10.0,
              ),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(color: kBackColor.withOpacity(0.4)),
                  color: Colors.white,
                ),
                child: Center(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 75.0,
                        child: Row(
                          children: [
                            Expanded(
                              child: Center(
                                child: Container(
                                  height: 35.0,
                                  width: 35.0,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                        "assets/images/${widget.t.imgSrc}",
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                widget.t.name,
                                style: TextStyle(
                                  color: kBackColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      myDetailRow(
                        title: "Category :",
                        value: widget.t.category,
                        height: 50.0,
                      ),
                      SizedBox(
                        height: 60.0,
                        child: Row(
                          children: [
                            Expanded(child: myTitle("Amount :")),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 20.0),
                                child: AutoSizeText(
                                  widget.t.amount.toString(),
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.visible,
                                  style: TextStyle(
                                    color:
                                        widget.t.category == "Income"
                                            ? kSuccessColor
                                            : kErrorColor,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      myDetailRow(
                        title: "Date :",
                        value:
                            "${widget.t.day}/${widget.t.month}/${widget.t.year}",
                        height: 50.0,
                      ),
                      if (widget.t.description.isEmpty)
                        Container()
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: myTitle("Description :")),
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 20.0),
                                  child: AutoSizeText(
                                    widget.t.description,
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.visible,
                                    style: TextStyle(
                                      color: kBackColor.withOpacity(0.9),
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(
                        height: 60.0,
                        child: Row(
                          children: [
                            Expanded(child: myTitle("Payment \nmode :")),
                            Expanded(
                              flex: 2,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 25.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        payMode.name,
                                        style: TextStyle(
                                          color: kBackColor.withOpacity(0.9),
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Image.asset(
                                        "assets/images/paymodes/${payMode.imgSrc}",
                                        height: 40.0,
                                        width: 40.0,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      widget.t.billSrc == ""
                          ? Container()
                          : GestureDetector(
                            onTap: () {
                              showImageViewer(
                                context,
                                Image.network(imgUrl).image,
                                useSafeArea: true,
                                immersive: false,
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                height: 130.0,
                                width: double.infinity,
                                child: FadeInImage(
                                  image: NetworkImage(imgUrl),
                                  fit: BoxFit.cover,
                                  placeholder: const AssetImage(
                                    "assets/images/other/loader.gif",
                                  ),
                                  placeholderFit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                      const SizedBox(height: 20.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget myDetailRow({
    required String title,
    required String value,
    required double height,
  }) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(child: myTitle(title)),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: AutoSizeText(
                value,
                textAlign: TextAlign.start,
                overflow: TextOverflow.visible,
                style: TextStyle(
                  color: kBackColor.withOpacity(0.9),
                  fontSize: 15.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget myTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: AutoSizeText(
        title,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.grey.shade700.withOpacity(0.6),
          fontWeight: FontWeight.w600,
          fontSize: 14.0,
        ),
      ),
    );
  }

  showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            "Delete",
            style: TextStyle(color: kBackColor, fontWeight: FontWeight.w600),
          ),
          content: const Text("Are you sure you want to delete this one ?"),
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

                await _profileController.deleteTransaction(
                  widget.t.id,
                  widget.t.billSrc,
                );

                stopLoader();

                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text("YES", style: TextStyle(color: kBackColor)),
            ),
          ],
        );
      },
    );
  }
}
