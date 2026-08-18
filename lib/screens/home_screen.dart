import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../providers/expense_provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_constants.dart';
import 'expenses/expense_list_screen.dart';
import 'expenses/expense_detail_screen.dart';
import 'expenses/add_edit_expense_screen.dart';
import 'budget/budget_screen.dart';
import 'analytics/analytics_screen.dart';
import '../widgets/expense_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _DashboardTab(),
    const ExpenseListScreen(),
    const BudgetScreen(),
    const AnalyticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          border: Border(
            top: BorderSide(color: AppTheme.dividerColor, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.transparent,
          selectedItemColor: AppTheme.lightGreen,
          unselectedItemColor: AppTheme.textHint,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_rounded),
              label: 'Expenses',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_rounded),
              label: 'Budget',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded),
              label: 'Analytics',
            ),
          ],
        ),
      ),
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddEditExpenseScreen(),
                  ),
                );
              },
              backgroundColor: AppTheme.lightGreen,
              child: const Icon(Icons.add_rounded, color: Colors.white),
            )
          : null,
    );
  }
}

// ─────────────────────────────────────────────
// DASHBOARD TAB
// ─────────────────────────────────────────────
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  void _confirmDelete(
    BuildContext context,
    ExpenseProvider provider,
    String id,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Expense',
          style: GoogleFonts.poppins(color: AppTheme.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete this expense?',
          style: GoogleFonts.poppins(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.deleteExpense(id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Expense deleted')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final budgetProvider = context.watch<BudgetProvider>();

    final now = DateTime.now();
    final currentMonth = AppConstants.months[now.month - 1];
    final currentYear = now.year;
    final monthlySpent = expenseProvider.totalForMonth(
      currentMonth,
      currentYear,
    );
    final currentBudget = budgetProvider.getBudgetForMonth(
      currentMonth,
      currentYear,
    );

    final recentExpenses = expenseProvider.allExpenses.take(5).toList();

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expense Calculator',
              style: GoogleFonts.poppins(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              DateFormat('MMMM yyyy').format(now),
              style: GoogleFonts.poppins(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.cardDark,
        actions: [
          IconButton(
            onPressed: () {
              context.read<ThemeProvider>().toggleTheme();
            },
            icon: Icon(
              context.watch<ThemeProvider>().isDarkMode
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              color: AppTheme.textPrimary,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddEditExpenseScreen()),
              );
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.lightGreen,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: 'Total Expenses',
                    value:
                        '\$${expenseProvider.totalAllExpenses.toStringAsFixed(2)}',
                    icon: Icons.account_balance_wallet_rounded,
                    color: AppTheme.lightGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    title: 'This Month',
                    value: '\$${monthlySpent.toStringAsFixed(2)}',
                    icon: Icons.calendar_month_rounded,
                    color: const Color(0xFF2196F3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: 'Transactions',
                    value: expenseProvider.totalExpenseCount.toString(),
                    icon: Icons.receipt_rounded,
                    color: const Color(0xFF9C27B0),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    title: 'Budget Left',
                    value: currentBudget != null
                        ? '\$${(currentBudget.amount - monthlySpent).toStringAsFixed(2)}'
                        : 'Not Set',
                    icon: Icons.savings_rounded,
                    color: currentBudget != null
                        ? (monthlySpent > currentBudget.amount
                              ? AppTheme.errorRed
                              : AppTheme.warningOrange)
                        : AppTheme.textHint,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Budget Status (if set)
            if (currentBudget != null) ...[
              Text(
                'Budget Status',
                style: GoogleFonts.poppins(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _DashboardBudgetCard(
                budget: currentBudget.amount,
                spent: monthlySpent,
                month: '$currentMonth $currentYear',
              ),
              const SizedBox(height: 24),
            ],

            // Recent Expenses
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Expenses',
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (expenseProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (recentExpenses.isEmpty)
              _EmptyState()
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentExpenses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) {
                  final e = recentExpenses[i];
                  return ExpenseCard(
                    expense: e,
                    padding: EdgeInsets.zero,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ExpenseDetailScreen(expense: e),
                        ),
                      );
                    },
                    onEdit: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddEditExpenseScreen(expense: e),
                        ),
                      );
                    },
                    onDelete: () {
                      _confirmDelete(context, expenseProvider, e.id);
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.dividerColor, width: 1),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: AppTheme.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardBudgetCard extends StatelessWidget {
  final double budget;
  final double spent;
  final String month;

  const _DashboardBudgetCard({
    required this.budget,
    required this.spent,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = budget - spent;
    final isOver = spent > budget;
    final pct = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isOver
              ? AppTheme.errorRed.withOpacity(0.4)
              : AppTheme.dividerColor,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                month,
                style: GoogleFonts.poppins(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
              Text(
                isOver ? 'Over Budget!' : 'On Track',
                style: GoogleFonts.poppins(
                  color: isOver ? AppTheme.errorRed : AppTheme.lightGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: AppTheme.surfaceDark,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOver ? AppTheme.errorRed : AppTheme.lightGreen,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statItem(
                'Budget',
                '\$${budget.toStringAsFixed(2)}',
                AppTheme.textSecondary,
              ),
              _statItem(
                'Spent',
                '\$${spent.toStringAsFixed(2)}',
                AppTheme.lightGreen,
              ),
              _statItem(
                isOver ? 'Over' : 'Left',
                '\$${remaining.abs().toStringAsFixed(2)}',
                isOver ? AppTheme.errorRed : AppTheme.accentGreen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(color: AppTheme.textHint, fontSize: 11),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppTheme.textHint,
            ),
            const SizedBox(height: 12),
            Text(
              'No expenses yet',
              style: GoogleFonts.poppins(
                color: AppTheme.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Tap + to add your first expense',
              style: GoogleFonts.poppins(
                color: AppTheme.textHint,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
