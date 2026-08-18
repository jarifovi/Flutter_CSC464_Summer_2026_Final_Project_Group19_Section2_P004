import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';

class BudgetStatusCard extends StatelessWidget {
  final double budgetAmount;
  final double spent;
  final String monthYear;

  const BudgetStatusCard({
    super.key,
    required this.budgetAmount,
    required this.spent,
    required this.monthYear,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = budgetAmount - spent;
    final isOverBudget = spent > budgetAmount;
    final usagePct = budgetAmount > 0 ? (spent / budgetAmount) * 100 : 0.0;
    final progressValue = budgetAmount > 0
        ? (spent / budgetAmount).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOverBudget
              ? AppTheme.errorRed.withOpacity(0.5)
              : AppTheme.dividerColor,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                monthYear,
                style: GoogleFonts.poppins(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isOverBudget
                      ? AppTheme.errorRed.withOpacity(0.15)
                      : AppTheme.lightGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${usagePct.toStringAsFixed(0)}%',
                  style: GoogleFonts.poppins(
                    color: isOverBudget
                        ? AppTheme.errorRed
                        : AppTheme.lightGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: 8,
              backgroundColor: AppTheme.surfaceDark,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverBudget ? AppTheme.errorRed : AppTheme.lightGreen,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Budget / Spent / Remaining rows
          _buildRow(
            'Budget',
            '\$${budgetAmount.toStringAsFixed(2)}',
            AppTheme.textSecondary,
          ),
          const SizedBox(height: 8),
          _buildRow(
            'Spent',
            '\$${spent.toStringAsFixed(2)}',
            AppTheme.lightGreen,
          ),
          const SizedBox(height: 8),
          if (isOverBudget)
            _buildRow(
              'Over Budget',
              '\$${(-remaining).toStringAsFixed(2)}',
              AppTheme.errorRed,
            )
          else
            _buildRow(
              'Remaining',
              '\$${remaining.toStringAsFixed(2)}',
              AppTheme.accentGreen,
            ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: AppTheme.textSecondary,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: valueColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
