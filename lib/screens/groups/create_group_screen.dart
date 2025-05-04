import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:frontend/components/custom_textform_field.dart';
import 'package:frontend/components/loader.dart';
import 'package:frontend/controllers/group_controller.dart';
import 'package:get/get.dart';

import '../../controllers/profile_controller.dart';
import '../../models/user.dart';
import '../../utils/constants.dart';
import '../../utils/errFlushbar.dart';

class CreateGroupScreen extends StatefulWidget {
  static const String routeName = '/createGroupScreen';
  final List<User>? contacts;

  const CreateGroupScreen({super.key, required this.contacts});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController groupNameController = TextEditingController();

  String dropDownVal = "FlatMates";
  List<User>? foundContacts;
  String searchString = "";
  String selectedImage = "group1.jpg";

  List<User> addedPeople = [];

  final TextEditingController _searchQuery = TextEditingController();
  final ProfileController _profileController = Get.put(ProfileController());
  final GroupController _groupController = Get.put(GroupController());

  void _runFilter(String enteredKeyword) {
    List<User> results = [];
    if (enteredKeyword.trim().isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all contacts
      results = widget.contacts!;
    } else {
      results =
          widget.contacts!.where((t) {
            if (t.userName.toLowerCase().contains(
                  enteredKeyword.toLowerCase(),
                ) ||
                t.userMobile.toLowerCase().contains(
                  enteredKeyword.toLowerCase(),
                )) {
              return true;
            }
            return false;
          }).toList();

      // we use the toLowerCase() method to make it case-insensitive
    }

    // Refresh the UI
    setState(() {
      searchString = enteredKeyword;
      foundContacts = results;
    });
  }

  @override
  void initState() {
    super.initState();
    foundContacts = widget.contacts;
    for (int i = 0; i < foundContacts!.length; i++) {
      if (foundContacts![i].userID == _profileController.user.value.userID) {
        foundContacts?.remove(foundContacts![i]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: const Text("Create Group"),
        backgroundColor: kBackColor,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () {
                        _showBottomSheet(() {
                          setState(() {});
                        });
                      },
                      child: badges.Badge(
                        badgeStyle: const badges.BadgeStyle(
                          badgeColor: Colors.white,
                        ),
                        badgeContent: const Padding(
                          padding: EdgeInsets.all(0.1),
                          child: Icon(Icons.edit, size: 20.0),
                        ),
                        showBadge: true,
                        child: Container(
                          width: 100.0,
                          height: 100.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: Colors.grey.shade300,
                          ),
                          child: Image(
                            image: AssetImage(
                              "assets/images/groups/$selectedImage",
                            ),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  CustomTextField(
                    controller: groupNameController,
                    label: "Group Name",
                    inputType: TextInputType.name,
                    focusedColor: kBackColor,
                    enabledColor: Colors.grey,
                    hintText: "Eg -Flatmates, Goa Trip",
                  ),
                  const SizedBox(height: 15.0),
                  const Padding(
                    padding: EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Text("Group Type"),
                  ),
                  const SizedBox(height: 15.0),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Column(
                      children: [
                        DropdownButtonFormField(
                          decoration: InputDecoration(
                            fillColor: Colors.grey.shade100,
                            filled: true,
                            border: InputBorder.none,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: "FlatMates",
                              child: Text("FlatMates"),
                            ),
                            DropdownMenuItem(
                              value: "Office",
                              child: Text("Office"),
                            ),
                            DropdownMenuItem(
                              value: "Trip",
                              child: Text("Trip"),
                            ),
                            DropdownMenuItem(
                              value: "Friends",
                              child: Text("Friends"),
                            ),
                            DropdownMenuItem(
                              value: "Others",
                              child: Text("Others"),
                            ),
                          ],
                          value: dropDownVal,
                          onChanged: (val) {
                            setState(() {
                              dropDownVal = val.toString();
                            });
                          },
                        ),
                        Container(height: 1.0, color: kBackColor),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(0.0),
                      title: const Text("Add People"),
                      dense: true,
                      onTap: () async {
                        addMembersBottomSheet(context, () {
                          setState(() {});
                        });
                      },
                      trailing: const Icon(Icons.add),
                    ),
                  ),
                  addedPeople.isEmpty
                      ? Container()
                      : SizedBox(
                        height: 100.0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: ListView.builder(
                            itemBuilder: (context, index) {
                              User? user = addedPeople[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12.0,
                                  horizontal: 12.0,
                                ),
                                child: SizedBox(
                                  width: 50.0,
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 50.0,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          color: Colors.grey.shade300,
                                        ),
                                        child: Image(
                                          image: AssetImage(
                                            "assets/images/avatars/${user.profilePic}",
                                          ),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      Text(
                                        user.userName,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            itemCount: addedPeople.length,
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                          ),
                        ),
                      ),
                ],
              ),
            ),
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
                  onPressed: () async {
                    showLoader(context);
                    if (groupNameController.text.isEmpty) {
                      return showErrFlushBar(
                        context,
                        "Error ",
                        "Group name can not be null",
                      );
                    } else if (addedPeople.isEmpty) {
                      return showErrFlushBar(
                        context,
                        "Error ",
                        "Please add people to group",
                      );
                    }
                    String members = "";
                    for (int i = 0; i < addedPeople.length; i++) {
                      i == addedPeople.length - 1
                          ? members = members + addedPeople[i].userID
                          : members = "$members${addedPeople[i].userID},";
                    }
                    //call api to add group
                    Map<String, dynamic> data = {
                      "group_name":
                          groupNameController.text.toLowerCase().trim(),
                      "group_imgsrc": selectedImage,
                      "group_type": dropDownVal,
                      "members": members,
                    };
                    await _groupController.addGroup(data);
                    // stopLoader();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(0, 10, 56, 1),
                  ),
                  child: const Text(
                    "CREATE",
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

  List<bool> checkBoxVal = [];

  void addMembersBottomSheet(BuildContext context, Function callback) async {
    _searchQuery.clear();
    foundContacts = widget.contacts;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets / 2,
          child: StatefulBuilder(
            builder: (context, setState) {
              return Container(
                padding: const EdgeInsets.only(
                  left: 12.0,
                  top: 12.0,
                  right: 12.0,
                ),
                decoration: BoxDecoration(
                  color: kBackColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                ),
                height: MediaQuery.of(context).size.height * 0.7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 100.0,
                        height: 4.0,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    ListTile(
                      contentPadding: const EdgeInsets.all(0.0),
                      title: const Text(
                        "Add Members",
                        style: TextStyle(color: Colors.white),
                      ),
                      leading: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      trailing: TextButton(
                        onPressed: () {
                          addedPeople.clear();
                          int i = 0;
                          for (var val in checkBoxVal) {
                            if (foundContacts?.length == i) {
                              break;
                            }
                            if (val == true) {
                              addedPeople.add(foundContacts![i]);
                            }
                            i++;
                          }
                          callback();
                          Navigator.of(context).pop();
                        },
                        child: const Text("Done"),
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    TextFormField(
                      controller: _searchQuery,
                      cursorColor: Colors.white,
                      onChanged: (value) {
                        _runFilter(value);
                        setState(() => {});
                      },
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search groups contacts or number",
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13.0,
                          overflow: TextOverflow.ellipsis,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 5.0,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: Colors.grey.shade700),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: Colors.grey.shade700),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    const Text(
                      "All contacts",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      "( People from your contact list who are using BudgetBuddy :)",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11.0,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Expanded(
                      child: Theme(
                        data: ThemeData(highlightColor: Colors.white),
                        child: RawScrollbar(
                          thumbColor: Colors.grey,
                          thickness: 4.0,
                          child:
                              foundContacts!.isEmpty
                                  ? const Center(
                                    child: Text(
                                      "No results found !",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  )
                                  : ListView.builder(
                                    itemCount: foundContacts?.length,
                                    physics: const BouncingScrollPhysics(),
                                    itemBuilder: (
                                      BuildContext context,
                                      int index,
                                    ) {
                                      User contact = foundContacts![index];
                                      checkBoxVal.add(false);
                                      return ListTile(
                                        leading: Container(
                                          height: 75.0,
                                          width: 50.0,
                                          padding: const EdgeInsets.all(0.0),
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage(
                                                "assets/images/avatars/${contact.profilePic}",
                                              ),
                                              fit: BoxFit.contain,
                                            ),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 3.0,
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          contact.userName,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        subtitle: Text(
                                          "+91 ${contact.userMobile}",
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        onTap: () {},
                                        trailing: Theme(
                                          data: ThemeData(
                                            unselectedWidgetColor: Colors.grey,
                                          ),
                                          child: Checkbox(
                                            onChanged: (bool? value) {
                                              setState(() {
                                                checkBoxVal[index] = value!;
                                              });
                                            },
                                            value: checkBoxVal[index],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
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
                                  selectedImage = "group${index + 1}.jpg";
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
                                            selectedImage ==
                                                    "group${index + 1}.jpg"
                                                ? true
                                                : false,
                                        badgeStyle: badges.BadgeStyle(
                                          badgeColor: Colors.blue.shade900,
                                        ),
                                        child: Container(
                                          width: 65.0,
                                          height: 65.0,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            color: Colors.grey.shade300,
                                          ),
                                          child: Image(
                                            image: AssetImage(
                                              "assets/images/groups/group${index + 1}.jpg",
                                            ),
                                            fit: BoxFit.contain,
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
                        itemCount: 4,
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
