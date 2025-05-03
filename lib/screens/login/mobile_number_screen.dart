import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/components/loader.dart';
import 'package:get/get.dart';

import '../../controllers/login_controller.dart';

class MobileNumberScreen extends StatefulWidget {
  static const String routeName = '/mobileNumberScreen';
  const MobileNumberScreen({super.key});

  @override
  _MobileNumberScreenState createState() => _MobileNumberScreenState();
}

class _MobileNumberScreenState extends State<MobileNumberScreen> {
  int? mobileNumberSize;
  final LoginController _loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ListView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Align(
                child: Container(
                  alignment: Alignment.bottomLeft,
                  height: MediaQuery.of(context).size.height * 0.20,
                  width: double.infinity,
                  color: const Color.fromRGBO(0, 10, 56, 1),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 15.0, bottom: 30.0),
                    child: Text(
                      "Enter Mobile Number",
                      style: TextStyle(
                        fontSize: 22.0,
                        fontFamily: "CircularStd",
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.80,
                width: double.infinity,
                decoration: const BoxDecoration(color: Colors.white),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      const Text(
                        "We'll send an OTP to verify that it's you.",
                        style: TextStyle(
                          fontSize: 15.0,
                          fontFamily: "CircularStd",
                        ),
                      ),
                      const SizedBox(height: 15.0),
                      TextField(
                        autofocus: true,
                        cursorColor: const Color.fromRGBO(0, 10, 56, 1),
                        controller: _loginController.mobileNumberController,
                        onChanged: (val) {
                          setState(() {
                            mobileNumberSize = val.length;
                          });
                        },
                        maxLength: 10,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          prefix: Padding(
                            padding: EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Text("+91"),
                          ),
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromRGBO(0, 10, 56, 1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromRGBO(0, 10, 56, 1),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 15.0,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 45.0,
                child: ElevatedButton(
                  onPressed:
                      mobileNumberSize == 10
                          ? () async {
                            showLoader(context);
                            await _loginController.sendOtp(context);
                            stopLoader();

                            // Navigator.of(
                            //   context,
                            // ).pushNamed(OtpScreen.routeName);
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(0, 10, 56, 1),
                  ),
                  child: const Text(
                    "SEND OTP",
                    style: TextStyle(
                      fontFamily: "CircularStd",
                      fontSize: 18.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
