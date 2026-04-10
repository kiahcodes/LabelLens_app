import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;

  bool get isSpeaking => _isSpeaking;

  Future init(String languageCode) async {
    await _tts.setLanguage(languageCode == 'hi' ? 'hi-IN' : 'en-US');
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _tts.setCompletionHandler(() => _isSpeaking = false);
    _tts.setCancelHandler(() => _isSpeaking = false);
  }

  Future speak(String text) async {
    if (text.isEmpty) return;
    await stop();
    _isSpeaking = true;
    await _tts.speak(text);
  }

  Future stop() async {
    _isSpeaking = false;
    await _tts.stop();
  }
}
