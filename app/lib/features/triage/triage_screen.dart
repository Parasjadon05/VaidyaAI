import 'package:flutter/material.dart';

import '../../core/localization/app_language.dart';
import '../../core/localization/app_strings.dart';
import '../ai/domain/diagnosis_result.dart';
import '../ai/domain/patient_case.dart';

class TriageScreen extends StatelessWidget {
  const TriageScreen({
    required this.language,
    required this.patientCase,
    required this.result,
    super.key,
  });

  final AppLanguage language;
  final PatientCase patientCase;
  final DiagnosisResult result;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(language);
    final triageColor = _colorFor(result.triageColor);
    return Scaffold(
      appBar: AppBar(title: Text(strings.triage)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              color: triageColor.withValues(alpha: 0.12),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(backgroundColor: triageColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            result.triageColor.label,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  color: triageColor,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      result.referralRequired
                          ? (language.isHindi
                                ? 'तुरंत रेफरल की सलाह'
                                : 'Referral recommended')
                          : (language.isHindi
                                ? 'निगरानी रखें और PHC सलाह का पालन करें'
                                : 'Monitor and follow PHC guidance'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _Section(
              title: strings.likelyDiagnoses,
              child: Column(
                children: result.differentials
                    .map(
                      (diagnosis) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(diagnosis.name),
                        subtitle: Text(diagnosis.reason),
                        trailing: Text(
                          '${(diagnosis.confidence * 100).round()}%',
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            _Section(
              title: strings.firstAid,
              child: Column(
                children: result.actions
                    .map(
                      (action) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.check_circle_outline),
                        title: Text(action),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            _Section(
              title: result.redFlags.isEmpty
                  ? strings.noRedFlags
                  : strings.redFlags,
              child: result.redFlags.isEmpty
                  ? Text(strings.uncertainty)
                  : Column(
                      children: result.redFlags
                          .map(
                            (flag) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.warning_amber_rounded),
                              title: Text(flag),
                            ),
                          )
                          .toList(),
                    ),
            ),
            const SizedBox(height: 16),
            _Section(
              title: strings.guidelines,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...result.guidelineSources.map(
                    (source) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('- $source'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(result.uncertaintyNote),
                  const SizedBox(height: 8),
                  Chip(
                    avatar: const Icon(Icons.verified_user_outlined, size: 18),
                    label: Text(strings.safetyProof),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(strings.newCase),
            ),
          ],
        ),
      ),
    );
  }

  Color _colorFor(TriageColor triageColor) {
    return switch (triageColor) {
      TriageColor.green => Colors.green.shade700,
      TriageColor.yellow => Colors.orange.shade800,
      TriageColor.red => Colors.red.shade700,
    };
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const Divider(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}
