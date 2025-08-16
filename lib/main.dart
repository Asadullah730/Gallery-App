import 'dart:async';
import 'package:camera/camera.dart';
import 'package:camera_usage/Screens/profilescreen.dart';
import 'package:camera_usage/switchingCamera.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
      url: 'https://qnmjmhyxyyhuiyobdebk.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFubWptaHl4eXlodWl5b2JkZWJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUwNzU4NjAsImV4cCI6MjA3MDY1MTg2MH0.YTNoraJyuxGOzhGvcratUWBfgK5sSKMQqmxTD_Hw7FE');
  final cameras = await availableCameras();

  // Get the first camera from the list of available cameras.
  final firstCamera = cameras.first;
  runApp(MyApp(cameras: cameras, camera: firstCamera));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  final CameraDescription camera;

  const MyApp({super.key, required this.cameras, required this.camera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      // home: SwitchingCamera(camera: camera, cameras: cameras,) // Pass cameras list here
      home: ProfileFormPage(), // Use ProfileFormPage as the home widget
    );
  }
}
