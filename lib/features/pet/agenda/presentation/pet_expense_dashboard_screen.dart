import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:scannutplus/core/theme/app_colors.dart';
import 'package:scannutplus/l10n/app_localizations.dart';

class PetExpenseDashboardScreen extends StatefulWidget {
  final String petId;
  final String petName;

  const PetExpenseDashboardScreen({
    super.key,
    required this.petId,
    required this.petName,
  });

  @override
  State<PetExpenseDashboardScreen> createState() => _PetExpenseDashboardScreenState();
}

class _PetExpenseDashboardScreenState extends State<PetExpenseDashboardScreen> {
  // Chart Spacing Constants
  static const double _chartHeight = 250.0;
  static const double _sectionSpacing = 32.0;
  
  // Pastel Palette 
  static const Color _pastelPink = Color(0xFFFFD1DC);
  static const Color _pastelGreen = Color(0xFFB5EAD7);
  static const Color _pastelPurple = Color(0xFFC7CEEA);
  static const Color _pastelOrange = Color(0xFFFFDAC1);
  static const Color _pastelYellow = Color(0xFFE2F0CB);
  static const Color _pastelBlue = Color(0xFFAEC6CF);

  String _selectedMonth = '';
  String _selectedYear = '2026'; // Defaults to 2026 for now, or could add 'Todos'
  String _selectedCategory = '';

  final bool _hasExpenses = true; // Simulating state. Switch to false to simulate empty state.

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_selectedMonth.isEmpty) {
      _selectedMonth = AppLocalizations.of(context)!.pet_expense_filter_all;
    }
    if (_selectedCategory.isEmpty) {
      _selectedCategory = AppLocalizations.of(context)!.pet_expense_filter_all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.petBackgroundDark,
      appBar: AppBar(
        title: Text(l10n.pet_expense_dashboard_title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blue),
      ),
      body: SingleChildScrollView(
        // Padding bottom prevents invasion of the SM A256E footer (Protocol Ergonomics constraint)
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 100.0), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFilters(l10n),
            const SizedBox(height: _sectionSpacing),
            _hasExpenses ? _buildCharts(l10n) : _buildEmptyState(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 80, color: Colors.blue.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text(
              l10n.pet_expense_dashboard_empty,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharts(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildPieChart(l10n),
        const SizedBox(height: _sectionSpacing),
        _buildLineChart(l10n),
        const SizedBox(height: _sectionSpacing),
        _buildStackedAreaChart(l10n),
      ],
    );
  }

  Widget _buildFilters(AppLocalizations l10n) {
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

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 1,
              child: _buildDropdown(
                label: l10n.pet_expense_filter_month,
                value: _selectedMonth,
                items: [l10n.pet_expense_filter_all, '01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12'],
                onChanged: (v) => setState(() => _selectedMonth = v!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: _buildDropdown(
                label: l10n.pet_expense_filter_year,
                value: _selectedYear,
                items: [l10n.pet_expense_filter_all, '2026', '2025', '2024'],
                onChanged: (v) => setState(() => _selectedYear = v!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildDropdown(
          label: l10n.pet_field_category,
          value: _selectedCategory,
          items: filterCategories,
          onChanged: (v) => setState(() => _selectedCategory = v!),
        ),
      ],
    );
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

  // 1. Gráfico de Pizza (Distribuição)
  Widget _buildPieChart(AppLocalizations l10n) {
    return _ChartSection(
      title: l10n.pet_expense_chart_pie_title,
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: [
                  PieChartSectionData(color: _pastelPink, value: 30, title: '30%', radius: 45, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                  PieChartSectionData(color: _pastelGreen, value: 25, title: '25%', radius: 45, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                  PieChartSectionData(color: _pastelPurple, value: 15, title: '15%', radius: 45, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                  PieChartSectionData(color: _pastelBlue, value: 12, title: '12%', radius: 45, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                  PieChartSectionData(color: _pastelOrange, value: 10, title: '10%', radius: 45, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                  PieChartSectionData(color: _pastelYellow, value: 8, title: '8%', radius: 45, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildPieLegend(l10n),
        ],
      ),
    );
  }

  Widget _buildPieLegend(AppLocalizations l10n) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _LegendItem(color: _pastelPink, label: l10n.pet_expense_cat_food),
        _LegendItem(color: _pastelGreen, label: l10n.pet_expense_cat_health),
        _LegendItem(color: _pastelPurple, label: l10n.pet_expense_cat_hygiene),
        _LegendItem(color: _pastelBlue, label: l10n.pet_expense_cat_meds),
        _LegendItem(color: _pastelOrange, label: l10n.pet_expense_cat_treats),
        _LegendItem(color: _pastelYellow, label: l10n.pet_expense_cat_services),
      ],
    );
  }

  // 2. Gráfico de Linha (Evolução)
  Widget _buildLineChart(AppLocalizations l10n) {
    return _ChartSection(
      title: l10n.pet_expense_chart_line_title,
      child: SizedBox(
        height: _chartHeight,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) => FlLine(color: Colors.white.withValues(alpha: 0.1), strokeWidth: 1),
            ),
            titlesData: FlTitlesData(
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10)),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 22,
                  getTitlesWidget: (value, meta) {
                    const months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun'];
                    if (value.toInt() >= 0 && value.toInt() < months.length) {
                      return Text(months[value.toInt()], style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10));
                    }
                    return const Text('');
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: const [
                  FlSpot(0, 150),
                  FlSpot(1, 420), // Peak Vacinas
                  FlSpot(2, 120),
                  FlSpot(3, 140),
                  FlSpot(4, 300), // Peak Banho extra
                  FlSpot(5, 130),
                ],
                isCurved: true,
                color: _pastelPink,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(radius: 4, color: Colors.white, strokeWidth: 2, strokeColor: _pastelPink);
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: _pastelPink.withValues(alpha: 0.2), // Simple alpha area
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 3. Gráfico de Área Empilhada (Acúmulo)
  Widget _buildStackedAreaChart(AppLocalizations l10n) {
    return _ChartSection(
      title: l10n.pet_expense_chart_area_title,
      child: SizedBox(
        height: _chartHeight,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              getDrawingHorizontalLine: (value) => FlLine(color: Colors.white.withValues(alpha: 0.05), strokeWidth: 1),
              getDrawingVerticalLine: (value) => FlLine(color: Colors.white.withValues(alpha: 0.05), strokeWidth: 1),
            ),
            titlesData: FlTitlesData(
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 10)),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 22,
                  getTitlesWidget: (value, meta) {
                    const months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun'];
                    if (value.toInt() >= 0 && value.toInt() < months.length) {
                      return Text(months[value.toInt()], style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 10));
                    }
                    return const Text('');
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              // Categoria Menor (Saúde)
              LineChartBarData(
                spots: const [
                  FlSpot(0, 50),
                  FlSpot(1, 80),
                  FlSpot(2, 60),
                  FlSpot(3, 90),
                  FlSpot(4, 70),
                  FlSpot(5, 60),
                ],
                isCurved: true,
                color: _pastelGreen,
                barWidth: 0,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(show: true, color: _pastelGreen.withValues(alpha: 0.6)),
              ),
              // Categoria Maior Impacto (Alimentação acumulada no topo)
              LineChartBarData(
                spots: const [
                  FlSpot(0, 150),
                  FlSpot(1, 180),
                  FlSpot(2, 160),
                  FlSpot(3, 190),
                  FlSpot(4, 170),
                  FlSpot(5, 160),
                ],
                isCurved: true,
                color: _pastelPink,
                barWidth: 0,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(show: true, color: _pastelPink.withValues(alpha: 0.8)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Containers auxiliares
class _ChartSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _ChartSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.petCardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
