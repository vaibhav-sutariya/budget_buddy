import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../services/chart_service.dart';

class CustomBalanceCard extends StatefulWidget {
  final double income;
  final double expense;
  final double balance;
  final int month;
  final int year;
  const CustomBalanceCard(
      {required this.income,
      required this.expense,
      required this.balance,
      required this.month,
      required this.year,
      Key? key})
      : super(key: key);
  @override
  _CustomBalanceCardState createState() => _CustomBalanceCardState();
}

class _CustomBalanceCardState extends State<CustomBalanceCard>
    with TickerProviderStateMixin {
  var height = 0.0, width = 0.0;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(
        milliseconds: 1000,
      ),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ScaleTransition(
        scale: _animation,
        alignment: Alignment.center,
        child: Row(
          children: [
            myCustomButton(
                click: () {
                  if (widget.income != 0.0) {
                    Navigator.of(context).pushNamed(MyChartScreen.routeName,
                        arguments: MyChartData(
                            month: widget.month,
                            year: widget.year,
                            category: "Income",
                            totalAmount: widget.income));
                  }
                },
                amt: widget.income == 0.0
                    ? "0"
                    : widget.income.toStringAsFixed(2),
                title: "Income"),
            const SizedBox(
              width: 10,
            ),
            myCustomButton(
                click: () {
                  if (widget.expense != 0.0) {
                    Navigator.of(context).pushNamed(MyChartScreen.routeName,
                        arguments: MyChartData(
                            month: widget.month,
                            year: widget.year,
                            category: "Expense",
                            totalAmount: widget.expense));
                  }
                },
                amt: widget.expense == 0.0
                    ? "0"
                    : widget.expense.toStringAsFixed(2),
                title: "Expense"),
            const SizedBox(
              width: 10,
            ),
            myCustomButton(
                click: () {},
                amt: widget.balance == 0.0
                    ? "0"
                    : widget.balance.toStringAsFixed(2),
                title: "Balance"),
          ],
        ),
      ),
    );
  }

  Widget myCustomButton(
      {required VoidCallback click,
      required String? amt,
      required String title}) {
    return Expanded(
      child: ElevatedButton(
        onPressed: click,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(0.0),
          foregroundColor: title == "Income"
              ? const Color(0xfff7fff7)
              : title == "Balance"
                  ? Colors.grey.shade100
                  : const Color(0xfffff7f7),
          elevation: 3.0,
        ),
        child: SizedBox(
          height: height * 0.13,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AutoSizeText(
                title,
                overflow: TextOverflow.visible,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(
                height: 15.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: AutoSizeText(
                  amt!,
                  overflow: TextOverflow.visible,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 19,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
