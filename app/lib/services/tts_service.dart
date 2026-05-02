class TtsService {
  const TtsService();

  Future<void> speakHindi(String text) async {
    // Mobile TTS plugin integration belongs here once device permissions are wired.
    if (text.trim().isEmpty) {
      return;
    }
  }
}
