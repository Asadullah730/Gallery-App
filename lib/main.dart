import 'dart:async';
import 'package:camera/camera.dart';
import 'package:camera_usage/switchingCamera.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Obtain a list of available cameras.
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
      home: SwitchingCamera(camera: camera, cameras: cameras,) // Pass cameras list here
    );
  }
}
