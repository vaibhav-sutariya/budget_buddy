import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class SettingScreen extends StatefulWidget {
  static const String routeName = '/settingScreen';
  const SettingScreen({Key? key}) : super(key: key);

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {

  var _chosenValue = colors[0];

  @override
  void initState() {
    selectInitialValue();
    super.initState();
  }

  selectInitialValue() async {
    final prefs = await SharedPreferences.getInstance();
    int i = prefs.getInt('selectedColorIndex') ?? 0;
    _chosenValue = colors[i];
    setState(() {});
  }

  setColor(var val) async {
    final prefs = await SharedPreferences.getInstance();
    var index = colors.indexOf(val);
    prefs.setInt('selectedColorIndex', index);
    setState(() {
      kBackColor = colors[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Settings",style: TextStyle(fontFamily: "CircularStd"),),
          backgroundColor: kBackColor,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),
        ),
        body: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(8.0),
          children: [
            ListTile(
              leading: Icon(
                Icons.color_lens,
                color: kBackColor,
              ),
              title: const Text(
                "Accent Color",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: DropdownButton(
                value: _chosenValue,
                onChanged: (val) {
                  setState(() {
                    _chosenValue = val;
                    setColor(val);
                  });
                },
                items: List.generate(
                  colors.length,
                  (index) => DropdownMenuItem(
                    value: colors[index],
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: colors[index],
                              shape: BoxShape.circle,
                            ),
                            height: 20.0,
                            width: 20.0,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
