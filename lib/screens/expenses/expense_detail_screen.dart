import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/expense_model.dart';
import '../../providers/theme_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_constants.dart';
import 'add_edit_expense_screen.dart';

class ExpenseDetailScreen extends StatelessWidget {
  final Expense expense;

  const ExpenseDetailScreen({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final categoryColor =
        AppConstants.categoryColors[expense.category] ?? AppTheme.lightGreen;
    final categoryIcon =
        AppConstants.categoryIcons[expense.category] ?? Icons.category;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: Text(
          'Expense Details',
          style: GoogleFonts.poppins(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppTheme.cardDark,
        iconTheme: IconThemeData(color: AppTheme.textPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: AppTheme.lightGreen),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditExpenseScreen(expense: expense),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Hero Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: categoryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(categoryIcon, color: categoryColor, size: 34),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    expense.name,
                    style: GoogleFonts.poppins(
                      color: AppTheme.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${expense.amount.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      color: categoryColor,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Details Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.dividerColor),
              ),
              child: Column(
                children: [
                  _DetailRow(
                    icon: Icons.category_rounded,
                    label: 'Category',
                    value: expense.category,
                    valueColor: categoryColor,
                  ),
                  Divider(color: AppTheme.dividerColor, height: 24),
                  _DetailRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'Date',
                    value: DateFormat('MMMM d, yyyy').format(expense.date),
                  ),
                  Divider(color: AppTheme.dividerColor, height: 24),
                  _DetailRow(
                    icon: Icons.access_time_rounded,
                    label: 'Added On',
                    value: DateFormat(
                      'MMM d, yyyy • hh:mm a',
                    ).format(expense.createdAt),
                  ),
                  if (expense.description.isNotEmpty) ...[
                    Divider(color: AppTheme.dividerColor, height: 24),
                    _DetailRow(
                      icon: Icons.notes_rounded,
                      label: 'Note',
                      value: expense.description,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Edit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddEditExpenseScreen(expense: expense),
                    ),
                  );
                },
                icon: const Icon(Icons.edit_rounded),
                label: Text(
                  'Edit Expense',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.textHint, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                color: AppTheme.textHint,
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                color: valueColor ?? AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
