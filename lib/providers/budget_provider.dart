import 'package:flutter/material.dart';
import '../models/budget_model.dart';
import '../services/firebase_service.dart';
import '../utils/app_constants.dart';

class BudgetProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  List<Budget> _budgets = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // ─────────────────────────────────────────────
  // GETTERS
  // ─────────────────────────────────────────────

  List<Budget> get budgets => _budgets;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  /// Get budget for a specific month and year
  Budget? getBudgetForMonth(String month, int year) {
    try {
      return _budgets.firstWhere((b) => b.month == month && b.year == year);
    } catch (_) {
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // LOAD BUDGETS (Real-time stream)
  // ─────────────────────────────────────────────

  void loadBudgets() {
    _isLoading = true;
    notifyListeners();

    _firebaseService.getBudgetsStream().listen(
      (budgets) {
        _budgets = budgets;
        _isLoading = false;
        _errorMessage = '';
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _errorMessage = 'Failed to load budgets: $error';
        notifyListeners();
      },
    );
  }

  // ─────────────────────────────────────────────
  // CREATE BUDGET
  // ─────────────────────────────────────────────

  Future<bool> createBudget({
    required String month,
    required int year,
    required double amount,
  }) async {
    // Check if budget already exists for that month/year
    final existing = getBudgetForMonth(month, year);
    if (existing != null) {
      _errorMessage =
          'Budget for $month $year already exists. Use edit instead.';
      notifyListeners();
      return false;
    }

    try {
      final now = DateTime.now();
      final budget = Budget(
        id: '',
        month: month,
        year: year,
        amount: amount,
        createdAt: now,
        updatedAt: now,
      );
      await _firebaseService.addBudget(budget);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create budget: $e';
      notifyListeners();
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // EDIT BUDGET
  // ─────────────────────────────────────────────

  Future<bool> editBudget(Budget budget, double newAmount) async {
    try {
      final updated = budget.copyWith(
        amount: newAmount,
        updatedAt: DateTime.now(),
      );
      await _firebaseService.updateBudget(updated);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update budget: $e';
      notifyListeners();
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // DELETE BUDGET
  // ─────────────────────────────────────────────

  Future<bool> deleteBudget(String budgetId) async {
    try {
      await _firebaseService.deleteBudget(budgetId);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete budget: $e';
      notifyListeners();
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // CALCULATE REMAINING & USAGE
  // ─────────────────────────────────────────────

  /// Remaining budget = budget - spent
  double calculateRemaining(double budgetAmount, double spent) {
    return budgetAmount - spent;
  }

  /// Usage percentage = (spent / budget) * 100
  double calculateUsagePercentage(double budgetAmount, double spent) {
    if (budgetAmount <= 0) return 0;
    return (spent / budgetAmount) * 100;
  }

  /// Check if over budget
  bool isOverBudget(double budgetAmount, double spent) {
    return spent > budgetAmount;
  }

  // ─────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────

  /// Get list of available months with budgets set
  List<String> get budgetMonthYears =>
      _budgets.map((b) => '${b.month} ${b.year}').toList();

  /// Check if budget exists for month/year
  bool hasBudget(String month, int year) {
    return getBudgetForMonth(month, year) != null;
  }

  /// All months list for dropdown
  static List<String> get allMonths => AppConstants.months;
}
