import 'package:cloud_firestore/cloud_firestore.dart';

class Budget {
  final String id;
  final String month; // e.g., "July"
  final int year; // e.g., 2026
  final double amount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Budget({
    required this.id,
    required this.month,
    required this.year,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
  });

  // Unique key for month+year
  String get monthYearKey => '$month $year';

  // Convert from Firestore document
  factory Budget.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Budget(
      id: doc.id,
      month: data['month'] ?? '',
      year: data['year'] ?? DateTime.now().year,
      amount: (data['amount'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'month': month,
      'year': year,
      'amount': amount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Copy with
  Budget copyWith({
    String? id,
    String? month,
    int? year,
    double? amount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id ?? this.id,
      month: month ?? this.month,
      year: year ?? this.year,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
