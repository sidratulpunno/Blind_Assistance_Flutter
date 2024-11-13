import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'vision_detector_views/object_detector_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
      routes: {
        "/objectDetector": (context) => ObjectDetectorView(),
        "/home": (context) => HomeScreen(),

      },// Set ObjectDetectorView as the main page
    );
  }
}
