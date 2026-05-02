import 'package:flutter/material.dart';

import 'core/localization/app_language.dart';
import 'features/ai/data/local_asset_rag_retriever.dart';
import 'features/ai/data/mock_inference_engine.dart';
import 'features/ai/data/prompt_builder.dart';
import 'features/ai/data/safety_service.dart';
import 'features/ai/data/vaidya_ai_service.dart';
import 'features/intake/intake_screen.dart';

void main() {
  runApp(const VaidyaAIApp());
}

class VaidyaAIApp extends StatefulWidget {
  const VaidyaAIApp({super.key});

  @override
  State<VaidyaAIApp> createState() => _VaidyaAIAppState();
}

class _VaidyaAIAppState extends State<VaidyaAIApp> {
  AppLanguage _language = AppLanguage.hindi;

  late final VaidyaAIService _service = VaidyaAIService(
    ragRetriever: LocalAssetRagRetriever(),
    promptBuilder: const ClinicalPromptBuilder(),
    inferenceEngine: const MockInferenceEngine(),
    safetyService: const SafetyService(),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VaidyaAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF006B5F),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: const CardThemeData(elevation: 0, margin: EdgeInsets.zero),
      ),
      home: IntakeScreen(
        language: _language,
        service: _service,
        onLanguageChanged: (language) {
          setState(() => _language = language);
        },
      ),
    );
  }
}
