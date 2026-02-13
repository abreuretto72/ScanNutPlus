import 'package:flutter/material.dart';
import 'package:scannutplus/l10n/app_localizations.dart';

class PlaceholderHealthView extends StatelessWidget {
  final String petName;
  const PlaceholderHealthView({super.key, required this.petName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.pet_health_title(petName)),
      ),
      body: Center(
        child: Container(),
      ),
    );
  }
}
