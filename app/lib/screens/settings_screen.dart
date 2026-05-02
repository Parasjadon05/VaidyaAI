import 'package:flutter/material.dart';

import '../core/localization/app_language.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    required this.language,
    required this.onLanguageChanged,
    super.key,
  });

  final AppLanguage language;
  final ValueChanged<AppLanguage> onLanguageChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Language', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          SegmentedButton<AppLanguage>(
            segments: AppLanguage.values
                .map(
                  (value) =>
                      ButtonSegment(value: value, label: Text(value.label)),
                )
                .toList(),
            selected: {language},
            onSelectionChanged: (selection) {
              onLanguageChanged(selection.first);
            },
          ),
          const SizedBox(height: 24),
          Text('Model runtime', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const ListTile(
            leading: Icon(Icons.smart_toy_outlined),
            title: Text('Demo mock engine'),
            subtitle: Text('Ollama/LiteRT adapters can replace this runtime.'),
          ),
        ],
      ),
    );
  }
}
