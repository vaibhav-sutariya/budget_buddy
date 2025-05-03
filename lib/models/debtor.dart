class Debtor {
  final String id;
  final String userid;
  final String name;
  final String mobile;
  final String desc;
  final double amount;
  final int day;
  final int month;
  final int year;

  Debtor(
      {required this.id,
      required this.userid,
      required this.mobile,
      required this.desc,
      required this.day,
      required this.month,
      required this.year,
      required this.name,
      required this.amount});

  factory Debtor.fromJson(Map<String, dynamic> json) {
    return Debtor(
      id: json['_id'],
      userid: json["userid"],
      mobile: json["deb_mobile"],
      desc: json["deb_desc"],
      day: json["deb_day"],
      month:json["deb_month"],
      year: json["deb_year"],
      name: json["deb_name"],
      amount: double.parse(json["deb_amount"]) * 1.0,
    );
  }
}
