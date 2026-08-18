import 'package:flutter/material.dart';

class AppConstants {
  // Categories
  static const List<String> categories = [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Entertainment',
    'Health',
    'Other',
  ];

  // Category Icons
  static const Map<String, IconData> categoryIcons = {
    'Food': Icons.restaurant,
    'Transport': Icons.directions_bus,
    'Shopping': Icons.shopping_bag,
    'Bills': Icons.receipt_long,
    'Entertainment': Icons.movie,
    'Health': Icons.favorite,
    'Other': Icons.category,
  };

  // Category Colors
  static const Map<String, Color> categoryColors = {
    'Food': Color(0xFF4CAF50),
    'Transport': Color(0xFF2196F3),
    'Shopping': Color(0xFFFF9800),
    'Bills': Color(0xFFF44336),
    'Entertainment': Color(0xFF9C27B0),
    'Health': Color(0xFFE91E63),
    'Other': Color(0xFF607D8B),
  };

  // Sort Options
  static const List<String> sortOptions = [
    'Date: Newest First',
    'Date: Oldest First',
    'Amount: Highest First',
    'Amount: Lowest First',
  ];

  // Month Names
  static const List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
}
