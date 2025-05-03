class Goal {
  String id;
  String desc;
  double targetAmount;
  double savedAmount;
  int day;
  int month;
  int year;
  String category;
  bool isReached;
  Goal(
      {required this.id,
      required this.desc,
      required this.targetAmount,
      required this.savedAmount,
      required this.category,
      required this.day,
      required this.month,
      required this.year,
      required this.isReached});

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
        id: json["_id"],
        desc: json["g_desc"],
        savedAmount: double.parse(json["g_saved_amount"]) * 1.0,
        targetAmount: double.parse(json["g_target_amount"]) * 1.0,
        category: json["gc_id"],
        day: json["g_day"],
        month: json["g_month"],
        year: json["g_year"],
        isReached: json["is_reached"]);
  }
}
