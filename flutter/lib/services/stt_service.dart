import 'package:speech_to_text/speech_to_text.dart';

class SttService {
  final SpeechToText _stt = SpeechToText();
  bool _available = false;

  bool get isListening => _stt.isListening;
  bool get isAvailable => _available;

  Future init() async {
    _available = await _stt.initialize(
      onError: (e) => print('STT error: ${e.errorMsg}'),
    );
    return _available;
  }

  Future listen({
    required Function(String text) onResult,
    String localeId = 'en_US',
  }) async {
    if (!_available) return;
    await _stt.listen(
      onResult: (result) {
        if (result.finalResult && result.recognizedWords.isNotEmpty) {
          onResult(result.recognizedWords);
        }
      },
      localeId: localeId,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
    );
  }

  Future stop() async {
    await _stt.stop();
  }
}
