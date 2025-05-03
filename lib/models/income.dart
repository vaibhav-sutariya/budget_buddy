class Income {
  String id;
  String name;
  String img;
  String userid="";
  bool isDefault;
  Income(
      {required this.img,
      required this.name,
      required this.id,
      required this.userid,
      required this.isDefault});

  factory Income.fromJson(Map<String, dynamic> json) {
    return Income(
        img: json["image_src"],
        name: json["income_name"],
        id: json["_id"],
        isDefault: json["isDefault"],
        userid: json["userid"] ?? "",
    ) ;
  }
}
