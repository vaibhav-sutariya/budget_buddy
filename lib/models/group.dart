import 'package:frontend/models/user.dart';

class Group {
  final String id;
  final String groupName;
  final String groupImgSrc;
  final String groupType;
  final List<User> members;

  Group({
    required this.id,
    required this.groupName,
    required this.groupImgSrc,
    required this.groupType,
    required this.members,
  });

  factory Group.fromJson(Map<String, dynamic> json, List<User> members) {
    return Group(
      id: json['_id'],
      groupName: json["group_name"],
      groupImgSrc: json["group_imgsrc"],
      groupType: json["group_type"],
      members: members,
    );
  }
}

//json["group_members"][0]["member"]
//json["group_members"][1]["member"]
//json["group_members"][2]["member"]
