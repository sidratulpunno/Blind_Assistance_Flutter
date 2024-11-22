import 'package:google_ml_kit_example/vision_detector_views/camera_view.dart';
import 'package:google_ml_kit_example/vision_detector_views/object_detector_view.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit_example/voice_command_service.dart';
import 'package:google_ml_kit_example/camera_service.dart';
import 'package:google_ml_kit_example/google_generative_ai_service.dart';
import 'package:google_ml_kit_example/tts_service.dart';
import 'dart:async';
import 'dart:io';
import 'package:google_ml_kit_example/app_state.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late VoiceCommandService _voiceCommandService;
  late CameraService _cameraService;
  late GoogleGenerativeAIService _aiService;
  late TTSService _ttsService;
  Timer? _photoTimer;

  String _responseText = "Please tap Start Listening and say 'Give direction' to get directions or 'Describe' for a description.";

  @override
  void initState() {
    super.initState();

    const apiKey = 'AIzaSyAE4T5hgpNDpb_5GeXph7AbVzgmJ4_S9Bg';
    _voiceCommandService = VoiceCommandService();
    _cameraService = CameraService();
    _aiService = GoogleGenerativeAIService(apiKey: apiKey);
    _ttsService = TTSService();

    _ttsService.speak(_responseText);
    _voiceCommandService.startListening(_onVoiceCommand);
    _cameraService.initializeCamera();
  }
  void _object_detector() {
    Navigator.pushNamed(context, '/objectDetector');
  }
  void _onVoiceCommand(String command) async {
    if (command.toLowerCase().contains("give direction")) {
      AppState.prompt = 1;
      _startContinuousCapture();
    } else if (command.toLowerCase().contains("describe")) {
      AppState.prompt = 2;
      _captureAndProcessPhoto();
    } else if (command.toLowerCase().contains("stop direction")) {
      _stopContinuousCapture();
    }
    else if (command.toLowerCase().contains("offline direction")) {
      _object_detector();
    }

  }

  void _startContinuousCapture() {
    // Cancel any existing timer before starting a new one
    _stopContinuousCapture();

    _photoTimer = Timer.periodic(Duration(seconds: 3), (timer) async {
      await _captureAndProcessPhoto();
    });

    setState(() {
      _responseText = "Continuous capture started.";
    });
  }

  void _stopContinuousCapture() {
    if (_photoTimer != null && _photoTimer!.isActive) {
      _photoTimer!.cancel();
      _photoTimer = null;

      setState(() {
        _responseText = "Continuous capture stopped.";
      });
    }
  }

  Future<void> _captureAndProcessPhoto() async {
    try {
      XFile image = await _cameraService.capturePhoto();

      // Analyze image and get response
      String response = await _aiService.analyzeImage(image);

      setState(() {
        _responseText = response;
      });

      await _ttsService.speak(response);
    } catch (e) {
      print("Error capturing or processing photo: $e");
    }
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed to avoid memory leaks
    _stopContinuousCapture();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "Blind Assistance App",
            style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    _responseText,
                    style: TextStyle(fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _object_detector,
              child: Text("Offline direction"),
            ),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                AppState.prompt = 1;
                _startContinuousCapture();
              },
              child: Text("Start Continuous Capture"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _stopContinuousCapture,
              child: Text("Stop Continuous Capture"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                AppState.prompt = 2;
                _captureAndProcessPhoto();
              },
              child: Text("Describe"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _voiceCommandService.startListening(_onVoiceCommand),
              style: ElevatedButton.styleFrom(

                padding: EdgeInsets.symmetric(horizontal: 90.0, vertical: 130.0), // Increase padding
                textStyle: TextStyle(fontSize: 20),
                // Increase font size
              ),
              child: Text("Start Listening"),
            ),

          ],
        ),
      ),
    );
  }
}
