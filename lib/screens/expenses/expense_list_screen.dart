import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/expense_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_constants.dart';
import '../../widgets/expense_card.dart';
import 'add_edit_expense_screen.dart';
import 'expense_detail_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final provider = context.watch<ExpenseProvider>();

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: Text(
          'Expenses',
          style: GoogleFonts.poppins(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppTheme.cardDark,
        actions: [
          // Filter toggle
          IconButton(
            icon: Badge(
              isLabelVisible: provider.hasActiveFilters,
              backgroundColor: AppTheme.lightGreen,
              child: Icon(
                Icons.tune_rounded,
                color: provider.hasActiveFilters
                    ? AppTheme.lightGreen
                    : AppTheme.textSecondary,
              ),
            ),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
          // Sort
          PopupMenuButton<String>(
            icon: Icon(Icons.sort_rounded, color: AppTheme.textSecondary),
            color: AppTheme.cardDarker,
            onSelected: (val) => provider.setSortOption(val),
            itemBuilder: (_) => AppConstants.sortOptions.map((opt) {
              return PopupMenuItem(
                value: opt,
                child: Row(
                  children: [
                    if (provider.sortOption == opt)
                      const Icon(
                        Icons.check_rounded,
                        color: AppTheme.lightGreen,
                        size: 16,
                      )
                    else
                      const SizedBox(width: 16),
                    const SizedBox(width: 8),
                    Text(
                      opt,
                      style: GoogleFonts.poppins(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchController,
              onChanged: provider.setSearchQuery,
              style: GoogleFonts.poppins(
                color: AppTheme.textPrimary,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Search expenses...',
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppTheme.textHint,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          color: AppTheme.textHint,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          provider.setSearchQuery('');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Filter Panel
          if (_showFilters) _buildFilterPanel(context, provider),

          // Active filter chips
          if (provider.hasActiveFilters)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      children: [
                        if (provider.selectedCategory.isNotEmpty)
                          _FilterChip(
                            label: provider.selectedCategory,
                            onRemove: () => provider.setCategory(''),
                          ),
                        if (provider.selectedMonth != null)
                          _FilterChip(
                            label:
                                '${provider.selectedMonth} ${provider.selectedYear}',
                            onRemove: () => provider.setMonthYear(null, null),
                          ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _searchController.clear();
                      provider.clearFilters();
                    },
                    child: Text(
                      'Clear All',
                      style: GoogleFonts.poppins(
                        color: AppTheme.errorRed,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // Expense List
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.expenses.isEmpty
                ? _buildEmpty()
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: provider.expenses.length,
                    itemBuilder: (ctx, i) {
                      final expense = provider.expenses[i];
                      return ExpenseCard(
                        expense: expense,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ExpenseDetailScreen(expense: expense),
                          ),
                        ),
                        onEdit: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AddEditExpenseScreen(expense: expense),
                          ),
                        ),
                        onDelete: () =>
                            _confirmDelete(context, provider, expense.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel(BuildContext context, ExpenseProvider provider) {
    String? tempMonth = provider.selectedMonth;
    int? tempYear = provider.selectedYear ?? DateTime.now().year;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardDarker,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter by Category',
            style: GoogleFonts.poppins(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _CategoryChip(
                label: 'All',
                isSelected: provider.selectedCategory.isEmpty,
                onTap: () => provider.setCategory(''),
              ),
              ...AppConstants.categories.map((cat) {
                return _CategoryChip(
                  label: cat,
                  isSelected: provider.selectedCategory == cat,
                  color: AppConstants.categoryColors[cat],
                  onTap: () => provider.setCategory(cat),
                );
              }),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Filter by Month',
            style: GoogleFonts.poppins(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  value: tempMonth,
                  dropdownColor: AppTheme.cardDarker,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Month',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(
                        'All Months',
                        style: GoogleFonts.poppins(
                          color: AppTheme.textHint,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    ...AppConstants.months.map(
                      (m) => DropdownMenuItem(value: m, child: Text(m)),
                    ),
                  ],
                  onChanged: (val) {
                    provider.setMonthYear(val, tempYear);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: tempYear,
                  dropdownColor: AppTheme.cardDarker,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Year',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
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
                    provider.setMonthYear(provider.selectedMonth, val);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 72, color: AppTheme.textHint),
          const SizedBox(height: 16),
          Text(
            'No expenses found',
            style: GoogleFonts.poppins(
              color: AppTheme.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            'Try adjusting your filters',
            style: GoogleFonts.poppins(color: AppTheme.textHint, fontSize: 13),
          ),
        ],
      ),
    );
  }

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
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _FilterChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.lightGreen.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.lightGreen.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: AppTheme.lightGreen,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close_rounded,
              color: AppTheme.lightGreen,
              size: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppTheme.lightGreen;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? chipColor.withOpacity(0.2) : AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? chipColor : AppTheme.dividerColor,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: isSelected ? chipColor : AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
