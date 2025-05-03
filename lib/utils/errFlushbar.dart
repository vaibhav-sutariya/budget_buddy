import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:frontend/utils/constants.dart';

void showErrFlushBar(BuildContext context, String title, String msg) {
  Flushbar(
    title: title,
    duration: const Duration(seconds: 2),
    backgroundColor: Colors.red,
    message: msg,
    flushbarPosition: FlushbarPosition.TOP,
  ).show(context);
}

void showSuccessFlushBar(BuildContext context, String title, String msg) {
  Flushbar(
    title: title,
    duration: const Duration(seconds: 2),
    backgroundColor: kSuccessColor,
    message: msg,
    flushbarPosition: FlushbarPosition.TOP,
  ).show(context);
}
