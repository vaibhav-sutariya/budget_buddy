import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final Color enabledColor;
  final Color focusedColor;
  final TextInputType inputType;
  final List<TextInputFormatter> formatter;
  final bool isPrefix;
  final String prefix;
  final bool autoFocus;
  final bool enforceMaxLength10;
  final String hintText;

  const CustomTextField(
      {Key? key,
      required this.controller,
      required this.label,
      required this.inputType,
      this.formatter = const [],
      required this.focusedColor,
      this.prefix = "",
        this.hintText = "",
      required this.enabledColor,
      this.autoFocus = false,
      this.isPrefix = false,this.enforceMaxLength10 = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 12.0),
      child: TextFormField(
        controller: controller,
        autofocus: autoFocus,
        cursorColor: focusedColor,
        keyboardType: inputType,
        inputFormatters: formatter,
        onFieldSubmitted: (val) {},
        maxLength: enforceMaxLength10 ? 10 : null,
        validator: (val) {
          if (val!.isEmpty) {
            return "*required";
          }
          return null;
        },
        style: TextStyle(
          color: focusedColor,
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefix: isPrefix
              ? Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Text(
                    prefix,
                    style: TextStyle(color: focusedColor),
                  ),
                )
              : null,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: enabledColor,
              width: 2.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: focusedColor,
              width: 2.0,
            ),
          ),
          labelStyle: TextStyle(
            color: focusedColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

Widget getCustomDatePicker({required VoidCallback callback, required String labelText, required Color focusedColor}) {
  return Padding(
    padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 12.0),
    child: GestureDetector(
      onTap: callback,
      child: TextFormField(
        enabled: false,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
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
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: focusedColor,
              width: 2.0,
            ),
          ),
          labelStyle: const TextStyle(
            color: Colors.black,
          ),
          labelText: labelText,
        ),
      ),
    ),
  );
}
