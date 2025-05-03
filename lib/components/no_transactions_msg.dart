import 'package:flutter/material.dart';

class EmptyMsgContainer extends StatelessWidget {
  const EmptyMsgContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.60,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          const SizedBox(height: 15.0,),
          Image.asset(
            'assets/images/other/money_man.png',
            height: 100.0,
            width: 100.0,
          ),
          const SizedBox(height: 30.0,),
          const Text(
            "This list is looking a little bit empty...",
            overflow: TextOverflow.visible,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 18.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(
            height: 12.0,
          ),
          const Text(
            "Tap on the + button below to add a new income/expense",
            overflow: TextOverflow.visible,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    );
  }
}
