import 'package:flutter/material.dart';
import 'package:scannutplus/core/theme/app_colors.dart';
import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:scannutplus/features/pet/agenda/presentation/pet_record_form_screen.dart';
import 'package:scannutplus/features/pet/agenda/presentation/pet_metrics_screen.dart';

class PetRecordsTab extends StatelessWidget {
  final String petId;
  final String petName;
  final VoidCallback onRecordSaved;

  const PetRecordsTab({
    super.key,
    required this.petId,
    required this.petName,
    required this.onRecordSaved,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // Grid Items Data
    final items = [
      _RecordItem(
        type: PetRecordType.medication,
        label: l10n.pet_record_medication, // "Medicação"
        icon: Icons.medication,
      ),
      _RecordItem(
        type: PetRecordType.weight,
        label: l10n.pet_metric_title, // "Métricas Clínicas"
        icon: Icons.query_stats,
      ),
      _RecordItem(
        type: PetRecordType.energy,
        label: l10n.pet_record_energy, // "Energia"
        icon: Icons.bolt,
      ),
      _RecordItem(
        type: PetRecordType.appetite,
        label: l10n.pet_record_appetite, // "Apetite"
        icon: Icons.restaurant,
      ),
      _RecordItem(
        type: PetRecordType.incident,
        label: l10n.pet_record_incident, // "Incidentes"
        icon: Icons.warning_amber,
      ),
      _RecordItem(
        type: PetRecordType.other,
        label: l10n.pet_record_other, // "Outros"
        icon: Icons.more_horiz,
      ),
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildCard(context, item);
      },
    );
  }

  Widget _buildCard(BuildContext context, _RecordItem item) {
    return Card(
      elevation: 4,
      color: AppColors.petCardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          if (item.type == PetRecordType.weight) {
             Navigator.push(
               context,
               MaterialPageRoute(
                 builder: (_) => PetMetricsScreen(
                   petId: petId,
                   petName: petName,
                 ),
               ),
             ).then((saved) {
                if (saved == true) onRecordSaved();
             });
          } else {
             Navigator.push(
               context,
               MaterialPageRoute(
                 builder: (_) => PetRecordFormScreen(
                   petId: petId,
                   petName: petName,
                   recordType: item.type,
                 ),
               ),
             ).then((saved) {
                if (saved == true) {
                  onRecordSaved();
                }
             });
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.petPrimary,
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, size: 40, color: Colors.black),
            ),
            const SizedBox(height: 12),
            Text(
              item.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordItem {
  final PetRecordType type;
  final String label;
  final IconData icon;

  _RecordItem({
    required this.type,
    required this.label,
    required this.icon,
  });
}
