import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceCommandService {
  late stt.SpeechToText _speech; // Use late for lazy initialization

  VoiceCommandService() {
    _speech = stt.SpeechToText();
  }

  void startListening(Function(String) onCommandRecognized) async {
    bool available = await _speech.initialize();
    if (available) {
      _speech.listen(onResult: (result) {
        if (result.recognizedWords.contains("describe")) {
          onCommandRecognized(result.recognizedWords);
        }else if (result.recognizedWords.contains("give direction")) {
          onCommandRecognized(result.recognizedWords);
        }else if (result.recognizedWords.contains("stop direction")) {
          onCommandRecognized(result.recognizedWords);
        }
        else if (result.recognizedWords.contains("offline direction")) {
          onCommandRecognized(result.recognizedWords);
        }
        else if (result.recognizedWords.contains("go to homepage")) {
          onCommandRecognized(result.recognizedWords);
        }

      });
    }
  }

  void stopListening() {
    _speech.stop();
  }
}
