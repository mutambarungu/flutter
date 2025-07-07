class Transaction {
  String id;
  String userId;
  String type; 
  String category;
  double amount;
  DateTime date;
  String description;

  Transaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
    };
  }

  static Transaction fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      userId: map['user_id'],
      type: map['type'],
      category: map['category'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      description: map['description'],
    );
  }
} 