class Creditor {
  final String id;
  final String userid;
  final String name;
  final String mobile;
  final String desc;
  final double amount;
  final int day;
  final int month;
  final int year;

  Creditor(
      {required this.id,
        required this.userid,
        required this.mobile,
        required this.desc,
        required this.day,
        required this.month,
        required this.year,
        required this.name,
        required this.amount});

  factory Creditor.fromJson(Map<String, dynamic> json) {
    return Creditor(
      id: json['_id'],
      userid: json["userid"],
      mobile: json["cre_mobile"],
      desc: json["cre_desc"],
      day: json["cre_day"],
      month:json["cre_month"],
      year: json["cre_year"],
      name: json["cre_name"],
      amount: double.parse(json["cre_amount"]) * 1.0,
    );
  }
}
