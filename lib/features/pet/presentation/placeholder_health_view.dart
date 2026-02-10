import 'package:flutter/material.dart';
import 'package:scannutplus/l10n/app_localizations.dart';

class PlaceholderHealthView extends StatelessWidget {
  const PlaceholderHealthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.pet_action_health),
      ),
      body: Center(
        child: Container(),
      ),
    );
  }
}
