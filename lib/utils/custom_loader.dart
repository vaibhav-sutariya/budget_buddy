import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

Widget showCustomLoader(Color color){
  return SpinKitSpinningLines(
    color: color,
    size: 50.0,
  );
}