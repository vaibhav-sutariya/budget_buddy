import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:frontend/components/loader.dart';
import 'package:frontend/controllers/profile_controller.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/errFlushbar.dart';

class CreateProfileScreen extends StatefulWidget {
  static const String routeName = '/createProfileScreen';
  const CreateProfileScreen({super.key});

  @override
  _CreateProfileScreenState createState() => _CreateProfileScreenState();
}

int selectedImageIndex = 0;

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBackColor,
        title: const Text(
          "Create Profile",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontFamily: "CircularStd",
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  String imgSrc = "avatar${selectedImageIndex + 1}.jpg";
                  Map<String, String> data = {
                    "user_name": nameController.text.trim(),
                    "profile_pic": imgSrc,
                  };

                  showLoader(context);

                  var res = await ProfileController().uploadProfile(data);

                  if (res.statusCode == 400) {
                    stopLoader();
                    showErrFlushBar(context, "Error", "Try again !");
                  } else if (res.statusCode == 200) {
                    stopLoader();
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool("isProfileCreated", true);
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      HomeScreen.routeName,
                      (route) => false,
                    );
                  }
                }
              },
              child: const Row(
                children: [
                  Text(
                    "SAVE",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "CircularStd",
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Icon(Icons.arrow_forward_ios, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        _showBottomSheet(() {
                          setState(() {});
                        });
                      },
                      child: badges.Badge(
                        badgeContent: const Padding(
                          padding: EdgeInsets.all(0.1),
                          child: Icon(
                            Icons.edit,
                            size: 20.0,
                            color: Colors.white,
                          ),
                        ),
                        showBadge: true,
                        badgeStyle: badges.BadgeStyle(badgeColor: kBackColor),
                        child: Container(
                          width: 100.0,
                          height: 90.0,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                "assets/images/avatars/avatar${selectedImageIndex + 1}.jpg",
                              ),
                              fit: BoxFit.contain,
                            ),
                            shape: BoxShape.rectangle,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text("Name"),
                  ),
                  TextFormField(
                    autofocus: true,
                    cursorColor: const Color.fromRGBO(0, 10, 56, 1),
                    controller: nameController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    textInputAction: TextInputAction.next,
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "*required";
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      hintText: "Enter your name",
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
                  const SizedBox(height: 30.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBottomSheet(Function callback) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder:
              ((context, setState) => SizedBox(
                height: 300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const SizedBox(height: 12.0),
                    Center(
                      child: Container(
                        width: 45.0,
                        height: 5.0,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.arrow_back_ios),
                          ),
                        ),
                        const Expanded(
                          flex: 4,
                          child: Text(
                            "Set Profile Picture",
                            style: TextStyle(
                              fontFamily: "CircularStd",
                              fontWeight: FontWeight.w400,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    SizedBox(
                      height: 90.0,
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 12.0,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedImageIndex = index;
                                });
                              },
                              child: Column(
                                children: [
                                  Column(
                                    children: [
                                      badges.Badge(
                                        badgeContent: const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 15.0,
                                        ),
                                        showBadge:
                                            selectedImageIndex == index
                                                ? true
                                                : false,
                                        child: Container(
                                          width: 60.0,
                                          height: 60.0,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage(
                                                "assets/images/avatars/avatar${index + 1}.jpg",
                                              ),
                                              fit: BoxFit.contain,
                                            ),
                                            shape: BoxShape.rectangle,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        itemCount: 6,
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    Center(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kBackColor,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          callback();
                        },
                        child: const Text(
                          "Done",
                          style: TextStyle(
                            fontFamily: "CircularStd",
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        );
      },
    );
  }
}
