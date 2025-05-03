class GoalCategory {
  String id;
  String name;
  String imgSrc;
  GoalCategory({required this.id, required this.name, required this.imgSrc});

  factory GoalCategory.fromJson(Map<String, dynamic> json) {
    return GoalCategory(
      id: json["_id"],
      name: json["gc_name"],
      imgSrc: json["gc_imgsrc"],
    );
  }
}
