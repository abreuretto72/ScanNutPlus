import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scannutplus/core/theme/app_colors.dart';
import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:scannutplus/pet/agenda/pet_event.dart';
import 'package:scannutplus/pet/agenda/pet_event_repository.dart';
import 'package:scannutplus/features/pet/agenda/presentation/pet_event_detail_screen.dart';

class PetExpenseHistoryScreen extends StatefulWidget {
  final String petId;
  final String petName;

  const PetExpenseHistoryScreen({
    super.key,
    required this.petId,
    required this.petName,
  });

  @override
  State<PetExpenseHistoryScreen> createState() => _PetExpenseHistoryScreenState();
}

class _PetExpenseHistoryScreenState extends State<PetExpenseHistoryScreen> {
  final PetEventRepository _repository = PetEventRepository();
  late Future<List<PetEvent>> _futureEvents;
  
  String _selectedCategory = ''; 
  String _selectedMonth = '';
  String _selectedYear = '2026';

  @override
  void initState() {
    super.initState();
    refresh();
  }

  void refresh() {
    setState(() {
      _futureEvents = _loadExpenses();
    });
  }

  Future<List<PetEvent>> _loadExpenses() async {
    final result = await _repository.getByPetId(widget.petId);
    if (result.isSuccess && result.data != null) {
      // Filtrar apenas despesas 
      var expenses = result.data!
          .where((e) => e.metrics?['subtype'] == 'expense')
          .toList()
        ..sort((a, b) => b.startDateTime.compareTo(a.startDateTime));
        
      // Filter by category if one is selected and it's not "Todos/All"
      if (_selectedCategory.isNotEmpty) {
        if (_selectedCategory != 'Todos' && _selectedCategory != 'All' && _selectedCategory != 'Todos/All') {
            expenses = expenses.where((e) {
                final cat = e.metrics?['category']?.toString() ?? '';
                return cat == _selectedCategory;
            }).toList();
        }
      }

      // Filter by Year
      if (_selectedYear.isNotEmpty && _selectedYear != 'Todos' && _selectedYear != 'All' && _selectedYear != 'Todos/All') {
         expenses = expenses.where((e) {
            final year = e.startDateTime.year.toString();
            return year == _selectedYear;
         }).toList();
      }

      // Filter by Month
      if (_selectedMonth.isNotEmpty && _selectedMonth != 'Todos' && _selectedMonth != 'All' && _selectedMonth != 'Todos/All') {
         expenses = expenses.where((e) {
            final month = e.startDateTime.month.toString().padLeft(2, '0');
            return month == _selectedMonth;
         }).toList();
      }
      return expenses;
    }
    return [];
  }

  Future<void> _deleteExpense(BuildContext context, PetEvent event) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.petCardBackground,
        title: Text(l10n.common_confirm_exit, style: const TextStyle(color: Colors.white)),
        content: const Text("Deseja realmente excluir esta despesa?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.login_no_account, style: const TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Excluir", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _repository.delete(event.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.pet_expense_history_item_deleted),
          backgroundColor: Colors.green,
        ));
      }
      refresh();
    }
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: const TextStyle(color: Colors.blue, fontSize: 14)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.petCardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              dropdownColor: AppColors.petCardBackground,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
              isExpanded: true,
              style: const TextStyle(color: Colors.blue, fontSize: 16),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    if (_selectedCategory.isEmpty) {
        _selectedCategory = l10n.pet_expense_filter_all;
    }
    if (_selectedMonth.isEmpty) {
        _selectedMonth = l10n.pet_expense_filter_all;
    }

    // List of categories for the dropdown
    final List<String> filterCategories = [
       l10n.pet_expense_filter_all,
       l10n.pet_expense_cat_food,
       l10n.pet_expense_cat_health,
       l10n.pet_expense_cat_hygiene,
       l10n.pet_expense_cat_meds,
       l10n.pet_expense_cat_treats,
       l10n.pet_expense_cat_services,
    ];

    return Scaffold(
      backgroundColor: AppColors.petBackgroundDark,
      appBar: AppBar(
        title: Text(l10n.pet_expense_history_title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.blue),
      ),
      body: Column(
        children: [
          // Filter Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: _buildDropdown(
                        label: l10n.pet_expense_filter_month,
                        value: _selectedMonth,
                        items: [l10n.pet_expense_filter_all, '01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12'],
                        onChanged: (v) {
                          if (v != null) setState(() { _selectedMonth = v; refresh(); });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: _buildDropdown(
                        label: l10n.pet_expense_filter_year,
                        value: _selectedYear,
                        items: [l10n.pet_expense_filter_all, '2026', '2025', '2024'],
                        onChanged: (v) {
                          if (v != null) setState(() { _selectedYear = v; refresh(); });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDropdown(
                  label: l10n.pet_field_category,
                  value: _selectedCategory,
                  items: filterCategories,
                  onChanged: (v) {
                    if (v != null) setState(() { _selectedCategory = v; refresh(); });
                  },
                ),
              ],
            ),
          ),
          
          Expanded(
            child: FutureBuilder<List<PetEvent>>(
        future: _futureEvents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.petPrimary));
          }

          final events = snapshot.data ?? [];

          if (events.isEmpty) {
            return Center(
              child: Text(
                l10n.pet_expense_history_empty,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                final metrics = event.metrics ?? {};
                
                final amount = metrics['amount']?.toString() ?? '0.0';
                final currency = metrics['currency']?.toString() ?? '';
                final category = metrics['category']?.toString() ?? l10n.pet_record_expense;
                final description = metrics['description']?.toString() ?? '';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.petPrimary, // Rosa Pastel
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black, width: 3),
                    boxShadow: const [
                      BoxShadow(color: Colors.black, offset: Offset(5, 5))
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PetEventDetailScreen(
                              event: event,
                              petName: widget.petName,
                            ),
                          ),
                        ).then((_) => refresh());
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icon Box
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.black, width: 2),
                              ),
                              child: (event.mediaPaths != null && event.mediaPaths!.isNotEmpty)
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Image.file(
                                        File(event.mediaPaths!.first),
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(Icons.monetization_on_outlined, size: 32, color: Colors.black),
                                      ),
                                    )
                                  : const Icon(Icons.monetization_on_outlined, size: 32, color: Colors.black),
                            ),
                            const SizedBox(width: 16),

                            // Content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "$currency $amount",
                                    style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 18, letterSpacing: -0.3),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    category,
                                    style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  if (description.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      description,
                                      style: const TextStyle(color: Colors.black87, fontSize: 13),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Text(
                                    DateFormat.yMd(l10n.localeName).add_Hm().format(event.startDateTime),
                                    style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),

                            // Delete Action
                            IconButton(
                              icon: const Icon(Icons.delete_rounded, color: Colors.redAccent),
                              onPressed: () => _deleteExpense(context, event),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
          ),
        ],
      ),
    );
  }
}

