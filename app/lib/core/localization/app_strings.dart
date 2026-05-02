import 'app_language.dart';

class AppStrings {
  const AppStrings(this.language);

  final AppLanguage language;

  String t(String english, String hindi) => language.isHindi ? hindi : english;

  String get appTitle => 'VaidyaAI';
  String get subtitle =>
      t('Offline rural health triage aide', 'ऑफलाइन ग्रामीण स्वास्थ्य सहायता');
  String get offlineBadge => t('Offline mode', 'ऑफलाइन मोड');
  String get symptomsLabel => t('Patient symptoms', 'मरीज के लक्षण');
  String get symptomsHint => t(
    'Example: fever for 3 days, cough, rash on arm',
    'उदाहरण: 3 दिन से बुखार, खांसी, हाथ पर दाने',
  );
  String get vitalsTitle => t('Vitals', 'वाइटल्स');
  String get age => t('Age', 'उम्र');
  String get temperature => t('Temperature C', 'तापमान C');
  String get heartRate => t('Heart rate', 'हृदय गति');
  String get weight => t('Weight kg', 'वजन kg');
  String get duration => t('Duration days', 'दिनों की अवधि');
  String get voicePlaceholder =>
      t('Voice capture placeholder', 'वॉइस इनपुट प्लेसहोल्डर');
  String get photoPlaceholder =>
      t('Attach photo placeholder', 'फोटो जोड़ें प्लेसहोल्डर');
  String get photoAttached => t('Photo attached', 'फोटो जुड़ गई');
  String get analyze => t('Analyze offline', 'ऑफलाइन विश्लेषण करें');
  String get requiredSymptoms =>
      t('Enter symptoms before analysis.', 'विश्लेषण से पहले लक्षण दर्ज करें.');
  String get triage => t('Triage', 'ट्रायाज');
  String get likelyDiagnoses => t('Top differentials', 'मुख्य संभावित निदान');
  String get firstAid => t('Immediate actions', 'तत्काल कदम');
  String get referral => t('Referral', 'रेफरल');
  String get guidelines => t('Guideline grounding', 'गाइडलाइन आधार');
  String get newCase => t('New case', 'नया केस');
  String get redFlags => t('Red flags detected', 'खतरे के संकेत मिले');
  String get noRedFlags =>
      t('No red flags detected', 'खतरे के संकेत नहीं मिले');
  String get uncertainty => t(
    'This is decision support for a health worker, not a doctor diagnosis.',
    'यह स्वास्थ्य कार्यकर्ता के लिए सहायता है; डॉक्टर का निदान नहीं.',
  );
}
