import 'package:flutter/material.dart';
import 'package:scannutplus/core/theme/app_colors.dart';

class PetAnalysisButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const PetAnalysisButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print('SCAN_NUT_TRACE: [CLIQUE] Iniciando análise para o Pet.'); // UUID not available here directly as prop? Wait, it is a reusable button.
        onTap();
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.analytics_outlined, // Icon requested in prompt
              color: AppColors.petText,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.petText,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
