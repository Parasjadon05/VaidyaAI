import 'package:flutter/material.dart';

import '../../core/localization/app_language.dart';
import '../../core/localization/app_strings.dart';
import '../ai/data/vaidya_ai_service.dart';
import '../ai/domain/patient_case.dart';
import '../triage/triage_screen.dart';

class IntakeScreen extends StatefulWidget {
  const IntakeScreen({
    required this.language,
    required this.onLanguageChanged,
    required this.service,
    super.key,
  });

  final AppLanguage language;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final VaidyaAIService service;

  @override
  State<IntakeScreen> createState() => _IntakeScreenState();
}

class _IntakeScreenState extends State<IntakeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _symptomsController = TextEditingController();
  final _ageController = TextEditingController(text: '34');
  final _temperatureController = TextEditingController(text: '38.2');
  final _heartRateController = TextEditingController(text: '96');
  final _weightController = TextEditingController(text: '58');
  final _durationController = TextEditingController(text: '3');

  bool _hasPhoto = false;
  bool _isAnalyzing = false;

  @override
  void dispose() {
    _symptomsController.dispose();
    _ageController.dispose();
    _temperatureController.dispose();
    _heartRateController.dispose();
    _weightController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(widget.language);
    return Scaffold(
      appBar: AppBar(
        title: const Text('VaidyaAI'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SegmentedButton<AppLanguage>(
              segments: AppLanguage.values
                  .map(
                    (language) => ButtonSegment(
                      value: language,
                      label: Text(language.label),
                    ),
                  )
                  .toList(),
              selected: {widget.language},
              onSelectionChanged: (selection) {
                widget.onLanguageChanged(selection.first);
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _HeroHeader(strings: strings),
              const SizedBox(height: 20),
              TextFormField(
                controller: _symptomsController,
                minLines: 4,
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: strings.symptomsLabel,
                  hintText: strings.symptomsHint,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return strings.requiredSymptoms;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      _symptomsController.text = widget.language.isHindi
                          ? '3 दिन से बुखार, खांसी, हाथ पर दाने'
                          : 'Fever for 3 days, cough, rash on arm';
                    },
                    icon: const Icon(Icons.auto_fix_high),
                    label: Text(
                      widget.language.isHindi ? 'डेमो केस' : 'Demo case',
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.mic_none),
                    label: Text(strings.voicePlaceholder),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => setState(() => _hasPhoto = !_hasPhoto),
                    icon: Icon(
                      _hasPhoto
                          ? Icons.check_circle
                          : Icons.camera_alt_outlined,
                    ),
                    label: Text(
                      _hasPhoto
                          ? strings.photoAttached
                          : strings.photoPlaceholder,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _VitalsCard(
                strings: strings,
                ageController: _ageController,
                temperatureController: _temperatureController,
                heartRateController: _heartRateController,
                weightController: _weightController,
                durationController: _durationController,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _isAnalyzing ? null : _analyze,
                icon: _isAnalyzing
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.health_and_safety_outlined),
                label: Text(_isAnalyzing ? 'Analyzing...' : strings.analyze),
              ),
              const SizedBox(height: 12),
              Text(
                strings.uncertainty,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _analyze() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isAnalyzing = true);
    final patientCase = PatientCase(
      symptoms: _symptomsController.text.trim(),
      language: widget.language,
      age: int.tryParse(_ageController.text) ?? 0,
      temperatureC: double.tryParse(_temperatureController.text) ?? 37.0,
      heartRateBpm: int.tryParse(_heartRateController.text) ?? 80,
      weightKg: double.tryParse(_weightController.text),
      durationDays: int.tryParse(_durationController.text) ?? 1,
      hasPhoto: _hasPhoto,
      photoNote: _hasPhoto ? 'Demo photo placeholder' : null,
    );
    final result = await widget.service.analyze(patientCase);
    if (!mounted) {
      return;
    }
    setState(() => _isAnalyzing = false);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TriageScreen(
          language: widget.language,
          patientCase: patientCase,
          result: result,
        ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.subtitle,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Chip(
              avatar: const Icon(Icons.signal_wifi_off, size: 18),
              label: Text(strings.offlineBadge),
            ),
          ],
        ),
      ),
    );
  }
}

class _VitalsCard extends StatelessWidget {
  const _VitalsCard({
    required this.strings,
    required this.ageController,
    required this.temperatureController,
    required this.heartRateController,
    required this.weightController,
    required this.durationController,
  });

  final AppStrings strings;
  final TextEditingController ageController;
  final TextEditingController temperatureController;
  final TextEditingController heartRateController;
  final TextEditingController weightController;
  final TextEditingController durationController;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.vitalsTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = (constraints.maxWidth - 12) / 2;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _NumberField(
                      width: width,
                      label: strings.age,
                      controller: ageController,
                    ),
                    _NumberField(
                      width: width,
                      label: strings.temperature,
                      controller: temperatureController,
                    ),
                    _NumberField(
                      width: width,
                      label: strings.heartRate,
                      controller: heartRateController,
                    ),
                    _NumberField(
                      width: width,
                      label: strings.weight,
                      controller: weightController,
                    ),
                    _NumberField(
                      width: width,
                      label: strings.duration,
                      controller: durationController,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.width,
    required this.label,
    required this.controller,
  });

  final double width;
  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width < 160 ? double.infinity : width,
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
