import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../services/firebase_service.dart';
import '../utils/app_constants.dart';

class ExpenseProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  List<Expense> _allExpenses = [];
  List<Expense> _filteredExpenses = [];

  // Filter state
  String _searchQuery = '';
  String _selectedCategory = '';
  DateTime? _selectedDate;
  String? _selectedMonth;
  int? _selectedYear;
  String _sortOption = AppConstants.sortOptions[0]; // Default: newest first

  bool _isLoading = false;
  String _errorMessage = '';

  // ─────────────────────────────────────────────
  // GETTERS
  // ─────────────────────────────────────────────

  List<Expense> get expenses => _filteredExpenses;
  List<Expense> get allExpenses => _allExpenses;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  DateTime? get selectedDate => _selectedDate;
  String? get selectedMonth => _selectedMonth;
  int? get selectedYear => _selectedYear;
  String get sortOption => _sortOption;

  bool get hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _selectedCategory.isNotEmpty ||
      _selectedDate != null ||
      _selectedMonth != null;

  // ─────────────────────────────────────────────
  // LOAD EXPENSES (Real-time stream)
  // ─────────────────────────────────────────────

  void loadExpenses() {
    _isLoading = true;
    notifyListeners();

    _firebaseService.getExpensesStream().listen(
      (expenses) {
        _allExpenses = expenses;
        _applyFiltersAndSort();
        _isLoading = false;
        _errorMessage = '';
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _errorMessage = 'Failed to load expenses: $error';
        notifyListeners();
      },
    );
  }

  // ─────────────────────────────────────────────
  // ADD EXPENSE
  // ─────────────────────────────────────────────

  Future<bool> addExpense(Expense expense) async {
    try {
      await _firebaseService.addExpense(expense);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add expense: $e';
      notifyListeners();
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // EDIT EXPENSE
  // ─────────────────────────────────────────────

  Future<bool> editExpense(Expense expense) async {
    try {
      await _firebaseService.updateExpense(expense);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update expense: $e';
      notifyListeners();
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // DELETE EXPENSE
  // ─────────────────────────────────────────────

  Future<bool> deleteExpense(String expenseId) async {
    try {
      await _firebaseService.deleteExpense(expenseId);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete expense: $e';
      notifyListeners();
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // SEARCH & FILTER
  // ─────────────────────────────────────────────

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void setDate(DateTime? date) {
    _selectedDate = date;
    if (date != null) {
      _selectedMonth = null;
      _selectedYear = null;
    }
    _applyFiltersAndSort();
    notifyListeners();
  }

  void setMonthYear(String? month, int? year) {
    _selectedMonth = month;
    _selectedYear = year;
    if (month != null) _selectedDate = null;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = '';
    _selectedDate = null;
    _selectedMonth = null;
    _selectedYear = null;
    _applyFiltersAndSort();
    notifyListeners();
  }

  // ─────────────────────────────────────────────
  // SORT
  // ─────────────────────────────────────────────

  void setSortOption(String option) {
    _sortOption = option;
    _applyFiltersAndSort();
    notifyListeners();
  }

  // ─────────────────────────────────────────────
  // APPLY FILTERS & SORT (internal)
  // ─────────────────────────────────────────────

  void _applyFiltersAndSort() {
    List<Expense> result = List.from(_allExpenses);

    // Search filter
    if (_searchQuery.isNotEmpty) {
      result = result
          .where(
            (e) => e.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    // Category filter
    if (_selectedCategory.isNotEmpty) {
      result = result.where((e) => e.category == _selectedCategory).toList();
    }

    // Date filter
    if (_selectedDate != null) {
      result = result.where((e) {
        return e.date.year == _selectedDate!.year &&
            e.date.month == _selectedDate!.month &&
            e.date.day == _selectedDate!.day;
      }).toList();
    }

    // Month/Year filter
    if (_selectedMonth != null && _selectedYear != null) {
      final monthIndex = AppConstants.months.indexOf(_selectedMonth!) + 1;
      result = result.where((e) {
        return e.date.month == monthIndex && e.date.year == _selectedYear;
      }).toList();
    }

    // Sort
    switch (_sortOption) {
      case 'Date: Newest First':
        result.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'Date: Oldest First':
        result.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'Amount: Highest First':
        result.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case 'Amount: Lowest First':
        result.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }

    _filteredExpenses = result;
  }

  // ─────────────────────────────────────────────
  // ANALYTICS CALCULATIONS
  // ─────────────────────────────────────────────

  /// Total of ALL expenses
  double get totalAllExpenses =>
      _allExpenses.fold(0, (sum, e) => sum + e.amount);

  /// Total expenses for a given month and year
  double totalForMonth(String month, int year) {
    final monthIndex = AppConstants.months.indexOf(month) + 1;
    return _allExpenses
        .where((e) => e.date.month == monthIndex && e.date.year == year)
        .fold(0, (sum, e) => sum + e.amount);
  }

  /// Category-wise totals for a given month and year
  Map<String, double> categoryTotalsForMonth(String month, int year) {
    final monthIndex = AppConstants.months.indexOf(month) + 1;
    final monthExpenses = _allExpenses
        .where((e) => e.date.month == monthIndex && e.date.year == year)
        .toList();

    final Map<String, double> totals = {};
    for (final category in AppConstants.categories) {
      final total = monthExpenses
          .where((e) => e.category == category)
          .fold(0.0, (sum, e) => sum + e.amount);
      if (total > 0) totals[category] = total;
    }
    return totals;
  }

  /// Highest spending category for a month
  String highestSpendingCategory(String month, int year) {
    final totals = categoryTotalsForMonth(month, year);
    if (totals.isEmpty) return 'None';
    return totals.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Total expense count
  int get totalExpenseCount => _allExpenses.length;

  /// Expense count for a month
  int expenseCountForMonth(String month, int year) {
    final monthIndex = AppConstants.months.indexOf(month) + 1;
    return _allExpenses
        .where((e) => e.date.month == monthIndex && e.date.year == year)
        .length;
  }
}
