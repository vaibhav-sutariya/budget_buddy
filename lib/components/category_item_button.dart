import 'package:flutter/material.dart';

class CategoryItemButton extends StatelessWidget {
  final VoidCallback click;
  final VoidCallback longClick;
  final String item;
  final String image;
  final Color btnColor;

  const CategoryItemButton(
      {required this.click,
      required this.longClick,
      required this.item,
      required this.image,
      this.btnColor = Colors.white,Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.all(0.0),
      ),
      onLongPress: longClick,
      onPressed: click,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
            width: 0.6,
            color: const Color(0xffe8eae6),
          ),
          color: btnColor,
        ),
        child: Container(
          padding: const EdgeInsets.all(10.0),
          child: Center(
            child: Column(
              children: [
                Expanded(
                    flex: 2,
                    child: Center(
                        child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(image)))),
                Expanded(
                    child: Center(
                        child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    item,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
