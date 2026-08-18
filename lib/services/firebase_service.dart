import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense_model.dart';
import '../models/budget_model.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─────────────────────────────────────────────
  // EXPENSE COLLECTION
  // ─────────────────────────────────────────────

  CollectionReference get _expensesRef => _db.collection('expenses');
  CollectionReference get _budgetsRef => _db.collection('budgets');

  /// Stream of all expenses (real-time)
  Stream<List<Expense>> getExpensesStream() {
    return _expensesRef
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList(),
        );
  }

  /// Add a new expense
  Future<void> addExpense(Expense expense) async {
    await _expensesRef.add(expense.toFirestore());
  }

  /// Update an existing expense
  Future<void> updateExpense(Expense expense) async {
    await _expensesRef.doc(expense.id).update(expense.toFirestore());
  }

  /// Delete an expense
  Future<void> deleteExpense(String expenseId) async {
    await _expensesRef.doc(expenseId).delete();
  }

  // ─────────────────────────────────────────────
  // BUDGET COLLECTION
  // ─────────────────────────────────────────────

  /// Stream of all budgets (real-time)
  Stream<List<Budget>> getBudgetsStream() {
    return _budgetsRef
        .orderBy('year', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Budget.fromFirestore(doc)).toList(),
        );
  }

  /// Add a new budget
  Future<void> addBudget(Budget budget) async {
    await _budgetsRef.add(budget.toFirestore());
  }

  /// Update an existing budget
  Future<void> updateBudget(Budget budget) async {
    await _budgetsRef.doc(budget.id).update({
      'amount': budget.amount,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Delete a budget
  Future<void> deleteBudget(String budgetId) async {
    await _budgetsRef.doc(budgetId).delete();
  }
}
