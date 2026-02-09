import 'package:flutter/material.dart';
import 'package:scannutplus/l10n/app_localizations.dart';

class PetProfileScreen extends StatefulWidget {
  final String uuid;
  final String name;

  const PetProfileScreen({super.key, required this.uuid, required this.name});

  @override
  State<PetProfileScreen> createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends State<PetProfileScreen> {
  final List<dynamic> _fullHistory = [];
  final bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(l10n),
            const SizedBox(height: 20),
            Text(l10n.pet_history_title, 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_fullHistory.isEmpty)
              Center(child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(l10n.pet_history_empty),
              ))
            else
              ..._fullHistory.map((item) => Card(child: ListTile(title: Text(item.toString())))),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(AppLocalizations l10n) {
    return Card(
      color: const Color(0xFFFFD1DC), // Rosa Pastel
      child: ListTile(
        leading: const Icon(Icons.pets, size: 40),
        title: Text(widget.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(l10n.pet_id_format(widget.uuid)),
      ),
    );
  }
}
