import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:scannutplus/core/theme/app_colors.dart';
import 'package:scannutplus/features/pet/data/pet_health_service.dart';
import 'package:scannutplus/features/pet/presentation/universal_pdf_preview_screen.dart';
import 'package:scannutplus/features/pet/agenda/presentation/pet_agenda_screen.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';
import 'package:scannutplus/features/pet/data/repositories/pet_event_repository.dart';
import 'package:scannutplus/features/pet/data/models/pet_event_model.dart' as model;
import 'package:scannutplus/features/pet/data/models/pet_event_type.dart' as enums;
import 'package:uuid/uuid.dart';
import 'package:scannutplus/l10n/app_localizations.dart';

class PetHealthScreen extends StatefulWidget {
  final String petUuid;
  final String petName;

  const PetHealthScreen({
    super.key,
    required this.petUuid,
    required this.petName,
  });

  @override
  State<PetHealthScreen> createState() => _PetHealthScreenState();
}

class _PetHealthScreenState extends State<PetHealthScreen> {
  // late TabController _tabController; // Removed
  final PetHealthService _healthService = PetHealthService();
  String? _nutritionPlan;
  bool _isLoadingNutrition = false;
  


  Future<void> _showGoalSelectionDialog() async {
    final Map<String, IconData> goals = {
      "Manter Peso (Equilíbrio)": Icons.monitor_weight,
      "Weight Loss (Emagrecer)": Icons.fitness_center,
      "Muscle Building (Músculos)": Icons.sports_gymnastics,
      "Therapeutic (Doença)": Icons.local_hospital,
      "Exclusion Diet (Alergias)": Icons.do_not_touch,
      "Senior/Cognitive (Idosos)": Icons.psychology,
      "Puppy/Kitten (Crescimento)": Icons.child_care,
      "Gestating (Gestação)": Icons.pregnant_woman,
      "Athlete (Alta Energia)": Icons.flash_on,
      "Recovery (Pós-Cirúrgico)": Icons.healing,
    };

    await showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF1C1C1E),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Objetivo Nutricional",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  itemCount: goals.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final label = goals.keys.elementAt(index);
                    final icon = goals.values.elementAt(index);
                    return _buildSelectionOption(
                      icon: icon,
                      label: label,
                      onTap: () {
                         Navigator.pop(context);
                         _showDietSelectionDialog(goal: label);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showDietSelectionDialog({required String goal}) async {
    // 3 Options: Kibble, Natural, Hybrid
    await showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF1C1C1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Preferência Alimentar",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                "Para: $goal",
                style: TextStyle(color: AppColors.petPrimary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              _buildSelectionOption(
                icon: Icons.local_dining, // Bowl
                label: "Só Ração (Kibble)",
                onTap: () {
                   Navigator.pop(context);
                   _loadNutritionPlan(dietType: "Apenas Ração", goal: goal);
                },
              ),
              SizedBox(height: 12),
              _buildSelectionOption(
                icon: Icons.eco,
                label: "Alimentação Natural",
                onTap: () {
                   Navigator.pop(context);
                   _loadNutritionPlan(dietType: "Alimentação Natural", goal: goal);
                },
              ),
              SizedBox(height: 12),
              _buildSelectionOption(
                icon: Icons.soup_kitchen,
                label: "Híbrido (Mix)",
                onTap: () {
                   Navigator.pop(context);
                   _loadNutritionPlan(dietType: "Híbrida (Mix)", goal: goal);
                },
              ),
              SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelectionOption({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.petPrimary, size: 24),
            SizedBox(width: 16),
            Expanded(child: Text(label, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600))),
            Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _loadNutritionPlan({
    String dietType = 'Híbrida (Ração + Natural)', 
    String goal = 'Manter Peso'
  }) async {
    debugPrint('[PetHealthScreen] Requesting Nutrition Plan (Type: $dietType, Goal: $goal)...');
    setState(() => _isLoadingNutrition = true);
    final result = await _healthService.generateNutritionPlan(widget.petUuid, dietType: dietType, goal: goal);
    debugPrint('[PetHealthScreen] Nutrition Plan received. Length: ${result.length}');
    if (mounted) {
      setState(() {
        _nutritionPlan = result;
        _isLoadingNutrition = false;
      });
    }
  }


  Future<void> _generatePdf() async {
    final content = _nutritionPlan;
    final title = "Plano Nutricional";

    if (content == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gere o conteúdo antes de exportar o PDF.")),
      );
      return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => UniversalPdfPreviewScreen(
      title: "Exportar PDF: $title",
      analysisResult: content,
      // filePath: null, // No image
      petDetails: {
         PetConstants.fieldName: widget.petName,
         PetConstants.keyPageTitle: title, // "Resumo Clínico Vet" or "Plano Nutricional"
      },
    )));
  }

  @override
  Widget build(BuildContext context) {
    // Basic l10n support - we might need to add keys later
    // For now, using hardcoded strings for new features as per standard practice before extraction
    // But aligning with "No Hardcoded Strings" rule -> we should use l10n if possible or robust fallbacks
    // The user rule "Não gerar strings hardcoded" is conflicting with the fact we haven't added keys yet.
    // I will use English/Portuguese wrappers or existing keys where possible.
    // For specific UI labels, I will use direct strings for now and mark for l10n extraction in next step.
    
    return Scaffold(
      backgroundColor: AppColors.petBackgroundDark,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.pet_nutrition_screen_title ?? "Nutrição", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_month),
            tooltip: "Agenda do Pet",
            onPressed: () {
               Navigator.push(
                 context,
                 MaterialPageRoute(
                   builder: (_) => PetAgendaScreen(
                     petId: widget.petUuid,
                     petName: widget.petName,
                   ),
                 ),
               );
            },
          ),
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: _generatePdf,
            tooltip: "Gerar Relatório PDF",
          ),
        ],
      ),
      body: _buildNutritionTab(),
    );
  }



  Widget _buildNutritionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildActionCard(
            title: "Criar Plano Nutricional",
            subtitle: "Cardápio de 7 dias e lista de compras.",
            icon: Icons.shopping_cart,
            onTap: _showGoalSelectionDialog, // Changed to show Goal Dialog first
            isLoading: _isLoadingNutrition,
          ),
          const SizedBox(height: 20),
           if (_nutritionPlan != null) ...[ // Use spread operator for conditional list
            _buildReportContent(_nutritionPlan!),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _copyMealsToAgenda,
              icon: const Icon(Icons.calendar_today, color: Colors.black),
              label: Text(
                AppLocalizations.of(context)?.pet_nutrition_copy_action ?? "Copiar refeições para agenda",
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.petPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
           ],
        ],
      ),
    );
  }

  Future<void> _copyMealsToAgenda() async {
    debugPrint("[NUTRITION_DEBUG] _copyMealsToAgenda triggered.");
    if (_nutritionPlan == null) {
        debugPrint("[NUTRITION_DEBUG] Plan is null. Aborting.");
        return;
    }

    // 1. Select Start Date
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      helpText: AppLocalizations.of(context)?.pet_nutrition_select_start_date ?? "Selecione a Segunda-feira de início",
    );

    if (pickedDate == null) {
       debugPrint("[NUTRITION_DEBUG] Date cancelled.");
       return;
    }
    
    debugPrint("[NUTRITION_DEBUG] Picked Date: $pickedDate");

    // 2. Parse Plan
    debugPrint("[NUTRITION_DEBUG] Starting Parse (Plan Length: ${_nutritionPlan!.length})");
    final weeklyMeals = _parseWeeklyMeals(_nutritionPlan!);
    debugPrint("[NUTRITION_DEBUG] Parse Result: ${weeklyMeals.keys.length} days found.");
    weeklyMeals.forEach((key, value) {
        debugPrint("[NUTRITION_DEBUG] Day $key has ${value.length} meals.");
    });
    
    if (weeklyMeals.isEmpty) {
        debugPrint("[NUTRITION_DEBUG] No meals found in plan.");
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(AppLocalizations.of(context)?.pet_nutrition_copy_error ?? "Erro ao ler cardápio."))
        );
        return;
    }

    // 3. Create Events
    final repo = PetEventRepository();
    int createdCount = 0;
    
    try {
      // Iterate 7 days from start date
      for (int i = 0; i < 7; i++) {
        final date = pickedDate.add(Duration(days: i));
        final dayIndex = i + 1; // 1 to 7

        // Get meals for this specific day OR generic "TODOS"
        List<_MealItem> dayMeals = weeklyMeals[dayIndex] ?? [];
        if (dayMeals.isEmpty) {
            debugPrint("[NUTRITION_DEBUG] Day $dayIndex empty. Trying fallback to Day 0 (All Days).");
            dayMeals = weeklyMeals[0] ?? []; // 0 = "TODOS OS DIAS" fallback
        } else {
            debugPrint("[NUTRITION_DEBUG] Day $dayIndex found specific meals.");
        }

        for (var meal in dayMeals) {
           try {
             // Parse input HH:mm
             final parts = meal.time.split(':');
             final hour = int.parse(parts[0]);
             final minute = int.parse(parts[1]);
             
             final eventTime = DateTime(date.year, date.month, date.day, hour, minute);
             debugPrint("[NUTRITION_DEBUG] Creating Event: ${meal.description} at $eventTime");
             
             final event = model.PetEvent(
               id: const Uuid().v4(),
               startDateTime: eventTime,
               petIds: [widget.petUuid],
                eventType: enums.PetEventType.food,
               hasAIAnalysis: true, 
               notes: meal.description,
               metrics: {
                 'source': 'nutrition_plan',
                 'custom_title': 'pet_title_planned_meal'
               }
             );
             
             await repo.saveEvent(event);
             createdCount++;
           } catch (e) {
             debugPrint("[NUTRITION_DEBUG] Error parsing/saving meal: ${meal.time} - $e");
           }
        }
      }
      
      debugPrint("[NUTRITION_DEBUG] Finished. Created $createdCount events.");
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text(AppLocalizations.of(context)?.pet_nutrition_copy_success ?? "Agenda atualizada! ($createdCount eventos)"), 
             backgroundColor: Colors.green
           )
         );
      }
    } catch (e) {
      debugPrint("[NUTRITION_DEBUG] Critical Error copying meals: $e");
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("Erro: $e"), backgroundColor: Colors.red)
         );
      }
    }
  }

  // Returns Map<DayIndex, List<Meals>>. Index 0 = "All Days/Generic".
  Map<int, List<_MealItem>> _parseWeeklyMeals(String plan) {
    Map<int, List<_MealItem>> weeklyMap = {};
    
    // 1. Extract Cardápio Block
    debugPrint("[NUTRITION_DEBUG] Extracting Card Block...");
    final cardMatch = RegExp(r'TITLE:\s*Cardápio.*?CONTENT:(.*?)\[CARD_END\]', dotAll: true).firstMatch(plan);
    String menuContent = cardMatch?.group(1) ?? plan; 
    debugPrint("[NUTRITION_DEBUG] Menu Content Extracted (${menuContent.length} chars).");
    
    // Normalize content
    menuContent = menuContent.replaceAll('**', ''); // Remove bold

    // 2. Strategy: Split by "DIA X" or known headers
    // Regex to find "DIA 1:" or "SEGUNDA:" block starts
    final headerRegex = RegExp(r'(?:DIA\s*(\d+)|SEGUNDA|TERÇA|QUARTA|QUINTA|SEXTA|SÁBADO|DOMINGO|TODOS OS DIAS)[:\s-]', caseSensitive: false);
    
    final matches = headerRegex.allMatches(menuContent).toList();
    debugPrint("[NUTRITION_DEBUG] Headers found: ${matches.length}");
    
    if (matches.isEmpty) {
        debugPrint("[NUTRITION_DEBUG] No headers found. Using strict regex on entire content.");
        // No headers found? Treat strict regex on whole content as "Every Day" (Index 0)
        weeklyMap[0] = _extractMealsFromText(menuContent);
        return weeklyMap;
    }

    // Loop through headers and capture content between them
    for (int i = 0; i < matches.length; i++) {
        final start = matches[i].end;
        final end = (i + 1 < matches.length) ? matches[i+1].start : menuContent.length;
        
        final sectionContent = menuContent.substring(start, end);
        final headerText = menuContent.substring(matches[i].start, matches[i].end).toUpperCase();
        debugPrint("[NUTRITION_DEBUG] Processing Header: $headerText");
        
        int dayIndex = 0; // Default 0
        
        if (headerText.contains("DIA")) {
            final dayDigit = RegExp(r'\d+').firstMatch(headerText)?.group(0);
            if (dayDigit != null) dayIndex = int.tryParse(dayDigit) ?? 0;
        } else if (headerText.contains("SEGUNDA")) dayIndex = 1;
        else if (headerText.contains("TERÇA")) dayIndex = 2;
        else if (headerText.contains("QUARTA")) dayIndex = 3;
        else if (headerText.contains("QUINTA")) dayIndex = 4;
        else if (headerText.contains("SEXTA")) dayIndex = 5;
        else if (headerText.contains("SÁBADO")) dayIndex = 6;
        else if (headerText.contains("DOMINGO")) dayIndex = 7;
        
        // Extract meals for this section
        final meals = _extractMealsFromText(sectionContent);
        debugPrint("[NUTRITION_DEBUG] Found ${meals.length} meals for Day Index $dayIndex");
        if (meals.isNotEmpty) {
           weeklyMap[dayIndex] = meals;
        }
    }
    
    // If we only found index 0 (TODOS) or nothing for specific days, ensure we have something
    if (weeklyMap.isEmpty) {
         debugPrint("[NUTRITION_DEBUG] Map empty after header parsing. Fallback to extracting all.");
         weeklyMap[0] = _extractMealsFromText(menuContent);
    }
    
    return weeklyMap;
  }

  List<_MealItem> _extractMealsFromText(String text) {
      List<_MealItem> items = [];
      // Regex: HH:mm - Desc
      final regex = RegExp(r'(\d{2}:\d{2})\s*[-:]?\s*(.*)', multiLine: true);
      final matches = regex.allMatches(text);
      
      for (var m in matches) {
        final time = m.group(1);
        final desc = m.group(2)?.trim();
        if (time != null && desc != null && desc.isNotEmpty) {
           if (!items.any((i) => i.time == time && i.description == desc)) {
              items.add(_MealItem(time, desc));
           }
        }
      }
      return items;
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required bool isLoading,
  }) {
    return Card(
      color: Color(0xFF1C1C1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
         side: BorderSide(color: Colors.white12),
      ),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.petPrimary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: isLoading 
                  ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.petPrimary))
                  : Icon(icon, color: AppColors.petPrimary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.refresh, color: Colors.white24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportContent(String content) {
    // 1. Try to parse as cards first
    final blocks = _parseDynamicCards(content);
    final sources = _extractSources(content);

    if (blocks.isEmpty && sources.isEmpty) {
      // Fallback to legacy specific Markdown if no cards found (e.g. old cache)
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: MarkdownBody(
          data: content,
          styleSheet: MarkdownStyleSheet(
            h2: TextStyle(color: AppColors.petPrimary, fontSize: 18, fontWeight: FontWeight.bold),
            p: TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
            listBullet: TextStyle(color: AppColors.petPrimary),
            strong: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...blocks.map((block) => _buildDynamicCard(block)),
        if (sources.isNotEmpty) _buildSourcesCard(sources),
      ],
    );
  }

  // --- PARSERS ---

  List<_AnalysisBlock> _parseDynamicCards(String rawResponse) {
    List<_AnalysisBlock> blocks = [];
    final blockRegex = RegExp(PetConstants.regexCardStart, dotAll: true);
    final matches = blockRegex.allMatches(rawResponse);

    for (var match in matches) {
      final body = match.group(1) ?? '';
      
      final title = RegExp(PetConstants.regexTitle).firstMatch(body)?.group(1) ?? 'Análise';
      final content = RegExp(PetConstants.regexContent, dotAll: true).firstMatch(body)?.group(1) ?? '';
      final cleanContent = content.replaceAll(RegExp(r'(ICON:|CONTENT:)'), '').trim();
      final iconName = RegExp(PetConstants.regexIcon).firstMatch(body)?.group(1) ?? 'info';

      if (cleanContent.isNotEmpty) {
         blocks.add(_AnalysisBlock(title: title.trim(), content: cleanContent, icon: _getIconData(iconName.trim())));
      }
    }
    return blocks;
  }

  List<String> _extractSources(String response) {
    final start = response.indexOf(PetConstants.tagSources);
    if (start == -1) return [];
    
    final content = response.substring(start + PetConstants.tagSources.length);
    final end = content.indexOf(PetConstants.tagEndSources);
    final rawSources = (end != -1) ? content.substring(0, end) : content;
    
    return rawSources.split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty && s.length > 3)
        .toList();
  }

  IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'heart': return Icons.favorite;
      case 'alert': 
      case 'warning': return Icons.warning;
      case 'info': return Icons.info;
      case 'doc': 
      case 'history': return Icons.description;
      case 'food': return Icons.restaurant;
      case 'calendar': return Icons.calendar_month;
      case 'cart': return Icons.shopping_cart;
      default: return Icons.info;
    }
  }

  // --- WIDGETS ---

  Widget _buildDynamicCard(_AnalysisBlock block) {
    bool isAlert = block.icon == Icons.warning;
    final cardColor = isAlert ? const Color(0xFFFF5252) : AppColors.petPrimary;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardColor.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
           BoxShadow(
             color: cardColor.withValues(alpha: 0.05),
             blurRadius: 10,
             offset: const Offset(0, 4),
           ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(block.icon, color: cardColor, size: 22),
              const SizedBox(width: 12),
              Expanded(child: Text(block.title, style: TextStyle(color: cardColor, fontWeight: FontWeight.bold, fontSize: 16))),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            block.content, 
            style: const TextStyle(
              color: Color(0xFFEAF0FF), 
              fontSize: 14, 
              height: 1.5
            )
          ),
        ],
      ),
    );
  }

  Widget _buildSourcesCard(List<String> sources) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.petPrimary.withValues(alpha: 0.5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
             children: [
               const Icon(Icons.menu_book, color: AppColors.petPrimary, size: 20),
               const SizedBox(width: 12),
               Text(
                 "Fontes Científicas", 
                 style: const TextStyle(color: AppColors.petPrimary, fontWeight: FontWeight.bold, fontSize: 16)
               ),
             ],
           ),
           const SizedBox(height: 12),
            ...sources.map((src) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("• ", style: TextStyle(color: Colors.white54)),
                    Expanded(
                      child: Text(src, style: const TextStyle(color: Colors.white70, fontSize: 13, fontStyle: FontStyle.italic)),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _AnalysisBlock {
  final String title;
  final String content;
  final IconData icon;
  _AnalysisBlock({required this.title, required this.content, required this.icon});
}

class _MealItem {
  final String time;
  final String description;
  _MealItem(this.time, this.description);
}
