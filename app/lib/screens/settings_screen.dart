import 'package:flutter/material.dart';

import '../core/localization/app_language.dart';
import '../core/localization/app_strings.dart';

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
    final strings = AppStrings(language);
    return Scaffold(
      appBar: AppBar(title: const Text('Offline readiness')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hackathon offline path',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Base Gemma 4 runs through a local runtime, while RAG and safety stay inside the app. The current demo uses a deterministic mock engine until a quantized model file is sideloaded or bundled.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
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
          Text(
            'Offline components',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const _StatusTile(
            icon: Icons.phone_android,
            title: 'Flutter APK shell',
            subtitle:
                'Hindi/English intake, vitals, camera placeholder, triage UI.',
            complete: true,
          ),
          const _StatusTile(
            icon: Icons.storage_outlined,
            title: 'Bundled local RAG',
            subtitle:
                'Guideline JSON and SQLite knowledge base ship with the app.',
            complete: true,
          ),
          const _StatusTile(
            icon: Icons.verified_user_outlined,
            title: 'Deterministic safety layer',
            subtitle:
                'Red flags override model output and prescription dosages are stripped.',
            complete: true,
          ),
          const _StatusTile(
            icon: Icons.smart_toy_outlined,
            title: 'Base Gemma runtime adapter',
            subtitle:
                'Ollama-style local HTTP adapter exists; Android llama.cpp/LiteRT bridge is next.',
            complete: false,
          ),
          const _StatusTile(
            icon: Icons.inventory_2_outlined,
            title: 'Quantized model artifact',
            subtitle:
                'Add Gemma 4 E4B Q4 GGUF or LiteRT model via asset pack or sideload.',
            complete: false,
          ),
          const SizedBox(height: 24),
          Text('Demo proof', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            strings.modelStrategyBody,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.complete,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    final color = complete ? Colors.green.shade700 : Colors.orange.shade800;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Chip(
          label: Text(complete ? 'Ready' : 'Next'),
          avatar: Icon(
            complete ? Icons.check_circle : Icons.pending_actions,
            size: 18,
            color: color,
          ),
        ),
      ),
    );
  }
}
