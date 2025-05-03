import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:frontend/components/loader.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/login/otp_screen.dart';
import 'package:frontend/screens/profile/create_profile_screen.dart';
import 'package:frontend/utils/constants.dart';
import 'package:frontend/utils/errFlushbar.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class LoginController extends GetxController {
  late TextEditingController mobileNumberController = TextEditingController();

  Future sendOtp(BuildContext context) async {
    var url = Uri.parse('$baseURL/users/sendOTP');

    try {
      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"user_mobile": mobileNumberController.text}),
      );

      if (response.statusCode == 200) {
        Navigator.of(context).pushNamed(OtpScreen.routeName);
      } else {
        stopLoader();
        showErrFlushBar(context, "Error", "Try again !");
        log("Error: ${response.statusCode}");
      }

      return response;
    } catch (e) {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future verifyOTP(String otp, BuildContext context) async {
    var url = Uri.parse('$baseURL/users/verifyOTP');

    try {
      var res = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          "user_mobile": mobileNumberController.text.trim(),
          "otp": otp,
        }),
      );

      if (res.statusCode == 400) {
        Loader.hide();
        showErrFlushBar(context, "Invalid OTP", "Try again !");
      } else if (res.statusCode == 200) {
        var body = jsonDecode(res.body);

        final prefs = await SharedPreferences.getInstance();
        prefs.setString("tokenOfLoggedInUser", body["token"]);
        Loader.hide();

        if (body["isRegisterdUser"] == true) {
          //user is already registered so go to home screen
          prefs.setBool("isProfileCreated", true);
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(HomeScreen.routeName, (route) => false);
        } else {
          //new user so go to create profile screen
          prefs.setBool("isProfileCreated", false);
          Navigator.of(context).pushNamedAndRemoveUntil(
            CreateProfileScreen.routeName,
            (route) => false,
          );
        }
      }
      return res;
    } catch (e) {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future logoutMe() async {
    var url = Uri.parse('$baseURL/users/logout');
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("tokenOfLoggedInUser");

    try {
      var response = await http.post(
        url,
        headers: <String, String>{
          "Authorization": "Bearer $token",
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      mobileNumberController.clear();
      return response;
    } catch (e) {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
}
