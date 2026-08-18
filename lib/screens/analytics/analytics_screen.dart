import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/expense_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_constants.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedMonth = AppConstants.months[DateTime.now().month - 1];
  int _selectedYear = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final provider = context.watch<ExpenseProvider>();
    final monthlyTotal = provider.totalForMonth(_selectedMonth, _selectedYear);
    final categoryTotals = provider.categoryTotalsForMonth(
      _selectedMonth,
      _selectedYear,
    );
    final highestCategory = provider.highestSpendingCategory(
      _selectedMonth,
      _selectedYear,
    );
    final monthlyCount = provider.expenseCountForMonth(
      _selectedMonth,
      _selectedYear,
    );

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: Text(
          'Analytics',
          style: GoogleFonts.poppins(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppTheme.cardDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month/Year Selector
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.dividerColor),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                    color: AppTheme.lightGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _selectedMonth,
                      dropdownColor: AppTheme.cardDarker,
                      style: GoogleFonts.poppins(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      items: AppConstants.months
                          .map(
                            (m) => DropdownMenuItem(value: m, child: Text(m)),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedMonth = val);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedYear,
                      dropdownColor: AppTheme.cardDarker,
                      style: GoogleFonts.poppins(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
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
                          setState(() => _selectedYear = val);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Summary Stats Row
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Total Expense',
                    value: '\$${monthlyTotal.toStringAsFixed(2)}',
                    icon: Icons.account_balance_wallet_rounded,
                    color: AppTheme.lightGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: '# of Expenses',
                    value: monthlyCount.toString(),
                    icon: Icons.receipt_rounded,
                    color: const Color(0xFF2196F3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'All-Time Total',
                    value: '\$${provider.totalAllExpenses.toStringAsFixed(2)}',
                    icon: Icons.bar_chart_rounded,
                    color: const Color(0xFF9C27B0),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Top Category',
                    value: highestCategory,
                    icon:
                        AppConstants.categoryIcons[highestCategory] ??
                        Icons.category,
                    color:
                        AppConstants.categoryColors[highestCategory] ??
                        AppTheme.textHint,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Pie Chart
            if (categoryTotals.isNotEmpty) ...[
              Text(
                'Spending Breakdown',
                style: GoogleFonts.poppins(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.dividerColor),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: _buildPieSections(
                            categoryTotals,
                            monthlyTotal,
                          ),
                          centerSpaceRadius: 50,
                          sectionsSpace: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Legend
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: categoryTotals.entries.map((entry) {
                        final color =
                            AppConstants.categoryColors[entry.key] ??
                            AppTheme.lightGreen;
                        final pct = (entry.value / monthlyTotal * 100)
                            .toStringAsFixed(1);
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${entry.key} ($pct%)',
                              style: GoogleFonts.poppins(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Category Totals List
            Text(
              'Category Breakdown',
              style: GoogleFonts.poppins(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            if (categoryTotals.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.dividerColor),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.bar_chart_rounded,
                      size: 48,
                      color: AppTheme.textHint,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No expenses for $_selectedMonth $_selectedYear',
                      style: GoogleFonts.poppins(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.dividerColor),
                ),
                child: Column(
                  children: categoryTotals.entries.toList().asMap().entries.map((
                    entry,
                  ) {
                    final index = entry.key;
                    final cat = entry.value.key;
                    final amount = entry.value.value;
                    final color =
                        AppConstants.categoryColors[cat] ?? AppTheme.lightGreen;
                    final icon =
                        AppConstants.categoryIcons[cat] ?? Icons.category;
                    final pct = monthlyTotal > 0 ? amount / monthlyTotal : 0.0;
                    final isLast = index == categoryTotals.length - 1;

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(icon, color: color, size: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              cat,
                                              style: GoogleFonts.poppins(
                                                color: AppTheme.textPrimary,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              '\$${amount.toStringAsFixed(2)}',
                                              style: GoogleFonts.poppins(
                                                color: color,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          child: LinearProgressIndicator(
                                            value: pct,
                                            minHeight: 5,
                                            backgroundColor:
                                                AppTheme.surfaceDark,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  color,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (!isLast)
                          Divider(color: AppTheme.dividerColor, height: 1),
                      ],
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(
    Map<String, double> totals,
    double total,
  ) {
    return totals.entries.map((entry) {
      final color =
          AppConstants.categoryColors[entry.key] ?? AppTheme.lightGreen;
      final pct = total > 0 ? entry.value / total * 100 : 0.0;
      return PieChartSectionData(
        value: entry.value,
        color: color,
        title: '${pct.toStringAsFixed(0)}%',
        radius: 60,
        titleStyle: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
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
