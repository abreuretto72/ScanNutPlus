import 'package:flutter/material.dart';
import 'package:scannutplus/l10n/app_localizations.dart';

class PetManagementScreen extends StatefulWidget {
  const PetManagementScreen({super.key});

  @override
  State<PetManagementScreen> createState() => _PetManagementScreenState();
}

class _PetManagementScreenState extends State<PetManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.pet_dashboard_title)), // Using existing "Pet Dashboard" title which is "Painel do Pet"
      body: Center(child: Text(l10n.pet_no_pets_registered)), // Using "No pets registered" as placeholder or similar
    );
  }
}
