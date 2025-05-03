import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/controllers/profile_controller.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:pie_chart/pie_chart.dart';

import '../models/transaction.dart';
import '../utils/constants.dart';

class MyChartData {
  final int month;
  final int year;
  final String category;
  final double totalAmount;
  MyChartData({
    required this.month,
    required this.year,
    required this.category,
    required this.totalAmount,
  });
}

class MyChartScreen extends StatefulWidget {
  static const routeName = "/chartScreen";
  final MyChartData chartData;
  const MyChartScreen({super.key, required this.chartData});

  @override
  _MyChartScreenState createState() => _MyChartScreenState();
}

class _MyChartScreenState extends State<MyChartScreen> {
  //Future fetchedData;
  List finalData = [];
  List finalAmount = [];

  List<double> listPercentages = <double>[];

  final ProfileController _profileController = Get.put(ProfileController());

  @override
  void initState() {
    currMonthIndex = widget.chartData.month;
    currYear = widget.chartData.year;
    tempYear = widget.chartData.year;
    tempMonthIndex = widget.chartData.month;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Scaffold(
        backgroundColor: kBackColor,
        appBar: AppBar(
          backgroundColor: kBackColor,
          elevation: 0.0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Total",
                    style: TextStyle(color: Colors.white, fontSize: 10.0),
                  ),
                  Text(
                    widget.chartData.totalAmount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 18.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
          centerTitle: true,
          title: Text(
            months[currMonthIndex - 1],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18.0,
            ),
          ),
        ),
        body: Obx(
          () => Column(
            children: [
              Expanded(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 10.0,
                      right: 10.0,
                      top: 10.0,
                      bottom: 10.0,
                    ),
                    child: Container(
                      height: double.infinity,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(color: kBackColor),
                        color: Colors.white,
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: PieChart(
                          dataMap: _profileController.getMapDataOfGivenCategory(
                            widget.chartData.month,
                            widget.chartData.year,
                            widget.chartData.category,
                          ),
                          chartLegendSpacing: 60,
                          chartRadius: MediaQuery.of(context).size.width / 4.5,
                          colorList: [
                            const Color(0xFF1B54A9),
                            Colors.amber.shade500,
                            Colors.green.shade500,
                            Colors.red.shade500,
                            Colors.tealAccent.shade400,
                          ],
                          initialAngleInDegree: 0,
                          chartType: ChartType.ring,
                          ringStrokeWidth: 15,
                          centerText: widget.chartData.category,
                          emptyColor: Colors.grey,
                          legendOptions: const LegendOptions(
                            showLegendsInRow: false,
                            legendPosition: LegendPosition.right,
                            showLegends: true,
                            legendShape: BoxShape.circle,
                            legendTextStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          chartValuesOptions: const ChartValuesOptions(
                            showChartValueBackground: false,
                            showChartValues: true,
                            showChartValuesInPercentage: true,
                            showChartValuesOutside: true,
                            decimalPlaces: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 10.0,
                      right: 10.0,
                      bottom: 10.0,
                    ),
                    child: Container(
                      height: double.infinity,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(color: kBackColor),
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 18.0,
                              right: 18.0,
                              top: 18.0,
                              bottom: 18.0,
                            ),
                            child: Text(
                              widget.chartData.category == "Income"
                                  ? "Income List"
                                  : "Expense List",
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          Expanded(
                            child: CupertinoScrollbar(
                              child: ListView(
                                physics: const BouncingScrollPhysics(),
                                children: List.generate(
                                  _profileController
                                      .getTransactionsByGivenCategory(
                                        widget.chartData.category,
                                      )
                                      .length,
                                  (i) {
                                    return getCustomTile(
                                      _profileController.finalData[i],
                                      _profileController.listPercentages[i],
                                      _profileController.finalAmount[i],
                                    );
                                  },
                                ),
                              ),
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
      ),
    );
  }

  Widget getCustomTile(Transaction t, double per, double amt) {
    return Column(
      children: [
        SizedBox(
          height: 40.0,
          child: Row(
            children: [
              Expanded(
                child: Image.asset(
                  "assets/images/custom/${t.imgSrc}",
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
                        return Icon(Icons.image_not_supported, size: 26.0);
                      },
                    );
                  },
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                                text: t.name,
                              ),
                              TextSpan(
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.0,
                                ),
                                text: '    $per %',
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 40.0),
                          child: Text(
                            '$amt',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: LinearPercentIndicator(
                        padding: const EdgeInsets.only(right: 26),
                        backgroundColor: Colors.grey.withOpacity(0.3),
                        //width: MediaQuery.of(context).size.width * 0.90,
                        lineHeight: 6.0,
                        percent: per / 100.0,
                        progressColor: kBackColor,
                        animation: true,
                        animationDuration: 800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(6.0),
          child: Divider(indent: 15.0, endIndent: 15.0),
        ),
      ],
    );
  }

  late int currMonthIndex;
  late int currYear;
  late int tempYear;
  late int tempMonthIndex;
}
