class Transaction {
  final String id;
  final String name;
  final String category;
  final double amount;
  final String description;
  final int day;
  final int month;
  final int year;
  late final String billSrc;
  final String imgSrc;
  final String paymentID;
  Transaction(
      {required this.description,
      required this.month,
      required this.year,
      required this.name,
      required this.day,
      required this.id,
      required this.amount,
      required this.category,
      required this.billSrc,
      required this.imgSrc,
      required this.paymentID});

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      description: json["t_desc"] ?? "",
      month: json["t_month"],
      year: json["t_year"],
      name: json["t_name"],
      day: json["t_day"],
      id: json["_id"],
      amount: double.parse(json["t_amount"])  * (1.0),
      category: json["t_category"],
      billSrc: json["t_billsrc"] ?? "",
      imgSrc: json["t_imgsrc"],
      paymentID: json["p_id"],
    );
  }
}
