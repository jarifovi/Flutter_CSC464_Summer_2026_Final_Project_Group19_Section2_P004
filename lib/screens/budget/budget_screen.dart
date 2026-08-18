import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/budget_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/budget_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_constants.dart';
import '../../widgets/budget_status_card.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final budgetProvider = context.watch<BudgetProvider>();
    final expenseProvider = context.watch<ExpenseProvider>();

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: Text(
          'Monthly Budget',
          style: GoogleFonts.poppins(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppTheme.cardDark,
        actions: [
          IconButton(
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
            onPressed: () => _showAddBudgetDialog(context, budgetProvider),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: budgetProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : budgetProvider.budgets.isEmpty
          ? _buildEmpty(context, budgetProvider)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: budgetProvider.budgets.length,
              itemBuilder: (ctx, i) {
                final budget = budgetProvider.budgets[i];
                final spent = expenseProvider.totalForMonth(
                  budget.month,
                  budget.year,
                );
                return Column(
                  children: [
                    _BudgetItemCard(
                      budget: budget,
                      spent: spent,
                      budgetProvider: budgetProvider,
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildEmpty(BuildContext context, BudgetProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: AppTheme.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            'No budgets set',
            style: GoogleFonts.poppins(
              color: AppTheme.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set a monthly budget to track\nyour spending goals',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: AppTheme.textHint, fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddBudgetDialog(context, provider),
            icon: const Icon(Icons.add_rounded),
            label: Text(
              'Set Budget',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddBudgetDialog(BuildContext context, BudgetProvider provider) {
    final amountController = TextEditingController();
    String selectedMonth = AppConstants.months[DateTime.now().month - 1];
    int selectedYear = DateTime.now().year;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.dividerColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Set Monthly Budget',
                    style: GoogleFonts.poppins(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Month & Year Row
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          value: selectedMonth,
                          dropdownColor: AppTheme.cardDarker,
                          style: GoogleFonts.poppins(
                            color: AppTheme.textPrimary,
                            fontSize: 13,
                          ),
                          decoration: const InputDecoration(labelText: 'Month'),
                          items: AppConstants.months
                              .map(
                                (m) =>
                                    DropdownMenuItem(value: m, child: Text(m)),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() => selectedMonth = val);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: selectedYear,
                          dropdownColor: AppTheme.cardDarker,
                          style: GoogleFonts.poppins(
                            color: AppTheme.textPrimary,
                            fontSize: 13,
                          ),
                          decoration: const InputDecoration(labelText: 'Year'),
                          items:
                              [
                                    DateTime.now().year - 1,
                                    DateTime.now().year,
                                    DateTime.now().year + 1,
                                  ]
                                  .map(
                                    (y) => DropdownMenuItem(
                                      value: y,
                                      child: Text(y.toString()),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() => selectedYear = val);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Amount
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: GoogleFonts.poppins(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Budget Amount (\$)',
                      prefixIcon: Icon(
                        Icons.attach_money_rounded,
                        color: AppTheme.textHint,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        final amount = double.tryParse(amountController.text);
                        if (amount == null || amount <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Enter a valid amount'),
                            ),
                          );
                          return;
                        }
                        final success = await provider.createBudget(
                          month: selectedMonth,
                          year: selectedYear,
                          amount: amount,
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (!success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(provider.errorMessage)),
                          );
                        }
                      },
                      child: Text(
                        'Save Budget',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// BUDGET ITEM CARD WITH EDIT/DELETE
// ─────────────────────────────────────────────
class _BudgetItemCard extends StatelessWidget {
  final Budget budget;
  final double spent;
  final BudgetProvider budgetProvider;

  const _BudgetItemCard({
    required this.budget,
    required this.spent,
    required this.budgetProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BudgetStatusCard(
          budgetAmount: budget.amount,
          spent: spent,
          monthYear: '${budget.month} ${budget.year}',
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Edit
            TextButton.icon(
              onPressed: () => _showEditDialog(context, budget, budgetProvider),
              icon: const Icon(
                Icons.edit_rounded,
                size: 16,
                color: AppTheme.lightGreen,
              ),
              label: Text(
                'Edit',
                style: GoogleFonts.poppins(
                  color: AppTheme.lightGreen,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Delete
            TextButton.icon(
              onPressed: () => _confirmDelete(context, budget, budgetProvider),
              icon: const Icon(
                Icons.delete_rounded,
                size: 16,
                color: AppTheme.errorRed,
              ),
              label: Text(
                'Delete',
                style: GoogleFonts.poppins(
                  color: AppTheme.errorRed,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showEditDialog(
    BuildContext context,
    Budget budget,
    BudgetProvider provider,
  ) {
    final controller = TextEditingController(
      text: budget.amount.toStringAsFixed(2),
    );
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Edit Budget — ${budget.month} ${budget.year}',
          style: GoogleFonts.poppins(color: AppTheme.textPrimary, fontSize: 16),
        ),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          style: GoogleFonts.poppins(color: AppTheme.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            labelText: 'New Amount (\$)',
            prefixIcon: Icon(
              Icons.attach_money_rounded,
              color: AppTheme.textHint,
              size: 20,
            ),
          ),
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
              final amount = double.tryParse(controller.text);
              if (amount == null || amount <= 0) return;
              await provider.editBudget(budget, amount);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(
              'Save',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    Budget budget,
    BudgetProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Budget',
          style: GoogleFonts.poppins(color: AppTheme.textPrimary),
        ),
        content: Text(
          'Delete budget for ${budget.month} ${budget.year}?',
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
              await provider.deleteBudget(budget.id);
              if (context.mounted) Navigator.pop(context);
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
}
