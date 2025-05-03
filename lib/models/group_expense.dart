class Settlement {
  final String who;
  final String whom;
  final double amount;

  Settlement({required this.who, required this.whom, required this.amount});
}

class PaidBy {
  final String who;
  final double amount;

  PaidBy({required this.who, required this.amount});
}

class GroupExpense {
  final String id;
  final String groupId;
  final String expenseDesc;
  final double totalExpense;
  final double splitAmount;
  final int day;
  final int month;
  final int year;
  final List<Settlement> settlements;
  final List<PaidBy> paidBys;

  GroupExpense({
    required this.id,
    required this.groupId,
    required this.expenseDesc,
    required this.totalExpense,
    required this.splitAmount,
    required this.day,
    required this.month,
    required this.year,
    required this.settlements,
    required this.paidBys,
  });

  factory GroupExpense.fromJson(
      Map<String, dynamic> json, List<Settlement> settlements, List<PaidBy> paidBys) {
    return GroupExpense(
      id: json['_id'],
      groupId: json['group_id'],
      expenseDesc: json['expense_desc'],
      totalExpense:double.parse( json['total_expense']) * 1.0,
      splitAmount: double.parse(json['split_amount']) * 1.0,
      day: json['t_day'],
      month: json['t_month'],
      year: json['t_year'],
      settlements: settlements,
      paidBys: paidBys,
    );
  }
}