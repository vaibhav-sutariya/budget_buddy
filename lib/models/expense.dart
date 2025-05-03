class Expense {
  String id;
  String name;
  String img;
  String userid="";
  bool isDefault;
  Expense(
      {required this.img,
        required this.name,
        required this.id,
        required this.userid,
        required this.isDefault});

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      img: json["image_src"],
      name: json["expense_name"],
      id: json["_id"],
      isDefault: json["isDefault"],
      userid: json["userid"] ?? "",
    );
  }
}
