class PaymentMode {
  String id;
  String name;
  String imgSrc;
  PaymentMode({required this.id, required this.name, required this.imgSrc});

  factory PaymentMode.fromJson(Map<String, dynamic> json) {
    return PaymentMode(
      id: json["_id"],
      name: json["p_name"],
      imgSrc: json["p_imgsrc"],
    );
  }
}
