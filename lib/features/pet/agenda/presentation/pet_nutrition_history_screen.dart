import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scannutplus/core/theme/app_colors.dart';
import 'package:scannutplus/features/pet/data/pet_health_service.dart';
import 'package:scannutplus/features/pet/data/models/pet_history_entry.dart';
import 'package:scannutplus/features/pet/presentation/universal_pdf_preview_screen.dart';
import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';

class PetNutritionHistoryScreen extends StatefulWidget {
  final String petUuid;
  final String petName;

  const PetNutritionHistoryScreen({
    super.key,
    required this.petUuid,
    required this.petName,
  });

  @override
  State<PetNutritionHistoryScreen> createState() => _PetNutritionHistoryScreenState();
}

class _PetNutritionHistoryScreenState extends State<PetNutritionHistoryScreen> {
  final PetHealthService _healthService = PetHealthService();
  List<PetHistoryEntry> _historyEntries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final entries = await _healthService.getAllNutritionPlans(widget.petUuid);
    if (mounted) {
      setState(() {
        _historyEntries = entries;
        _isLoading = false;
      });
    }
  }

  void _openPlanPreview(PetHistoryEntry entry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UniversalPdfPreviewScreen(
          title: "Plano Nutricional Arquivado",
          analysisResult: entry.rawJson,
          petDetails: {
            PetConstants.fieldName: widget.petName,
            PetConstants.keyPageTitle: "Plano Nutricional",
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = l10n?.pet_nutrition_history_title ?? "Histórico Nutricional";

    return Scaffold(
      backgroundColor: AppColors.petBackgroundDark,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.petPrimary))
          : _historyEntries.isEmpty
              ? _buildEmptyState(l10n)
              : _buildList(),
    );
  }

  Widget _buildEmptyState(AppLocalizations? l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.restaurant_menu, size: 80, color: Colors.white24),
          const SizedBox(height: 16),
          Text(
            l10n?.pet_nutrition_empty_history ?? "Nenhum plano gerado ainda.",
            style: const TextStyle(color: Colors.white54, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 120),
      itemCount: _historyEntries.length,
      itemBuilder: (context, index) {
        final entry = _historyEntries[index];
        final formattedDate = DateFormat('dd/MM/yyyy • HH:mm').format(entry.timestamp);

        // Identifica se foi Alimentação Natural, Mix, ou Kibble baseado num snippet do texto gerado se possível, ou usa genérico.
        // O Gemini fala na string o objetivo, mas o histórico básico não salva essa string indexada, então extraímos.
        String subtitle = "Criado em: $formattedDate";

        return Card(
          color: const Color(0xFF1C1C1E),
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.white12),
          ),
          child: InkWell(
            onTap: () => _openPlanPreview(entry),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.petPrimary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.restaurant, color: AppColors.petPrimary, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Plano Nutricional",
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
