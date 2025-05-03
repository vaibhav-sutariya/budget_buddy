import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void showLoader(BuildContext context){
  Loader.show(
    context,
    progressIndicator: const SpinKitSpinningLines(
      color: Colors.white,
      size: 50.0,
    ),
    overlayColor: Colors.black87,
  );
}

Widget returnLoader ({required Color color}){
  return Center(
    child: SpinKitSpinningLines(
      color: color,
      size: 45.0,
    ),
  );
}

void stopLoader(){
  Loader.hide();
}