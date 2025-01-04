import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:camera_usage/showImagePage/shownimages.dart';
import 'package:flutter/material.dart';

class SwitchingCamera extends StatefulWidget {
  const SwitchingCamera({
    super.key,
    required this.camera,
    required this.cameras, // List of cameras
  });

  final CameraDescription camera; // The current camera
  final List<CameraDescription> cameras;

  @override
  State<SwitchingCamera> createState() => _SwitchingCameraState();
}

class _SwitchingCameraState extends State<SwitchingCamera> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late CameraDescription _currentCamera;
  List<String> images = []; // To store image paths

  @override
  void initState() {
    super.initState();
    _currentCamera = widget.camera;
    _initializeCamera();
  }

  // Initialize the camera
  void _initializeCamera() {
    _controller = CameraController(
      _currentCamera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  // Switch to the next available camera
  void _switchCamera() async {
    await _controller.dispose();
    setState(() {
      // Switch to the next camera
      _currentCamera = _currentCamera == widget.cameras[0]
          ? widget.cameras[1]
          : widget.cameras[0];
    });
    _initializeCamera(); // Reinitialize the camera
  }

  void _toggleFlash() async {
    if (_controller.value.flashMode == FlashMode.off) {
      _controller.setFlashMode(FlashMode.torch);
    } else {
      _controller.setFlashMode(FlashMode.off);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(69, 70, 29, 29),
        title: const Text('Camera'),
        actions: [
          IconButton(
            onPressed: _toggleFlash,
            icon: _controller.value.flashMode == FlashMode.torch
                ? const Icon(Icons.flashlight_on)
                : const Icon(Icons.flashlight_on_outlined),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _initializeControllerFuture;
            final image = await _controller.takePicture();
            setState(() {
              images.add(image.path); // Add the image path to the list
            });
          } catch (e) {
            print("Error capturing image: $e");
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
      body: Column(
        children: [
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return CameraPreview(_controller);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.only(top: 85, left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                    onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => MiddlePage(
                              path: images.last,
                              imagespath: images,
                            ),
                          ),
                        ),
                    child: CircleAvatar(
                      backgroundImage: images.isNotEmpty
                          ? FileImage(File(images.last))
                          : null,
                      backgroundColor: const Color.fromARGB(255, 65, 55, 55),
                      radius: 25,
                      child: images.isEmpty
                          ? const Icon(Icons.person,
                              size: 20, color: Colors.grey)
                          : null,
                    )),
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                          color: const Color.fromARGB(255, 54, 117, 244)),
                      color: const Color.fromARGB(255, 13, 19, 25)),
                  child: IconButton(
                    onPressed: _switchCamera,
                    icon: const Icon(
                      Icons.switch_camera_rounded,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class MiddlePage extends StatelessWidget {
  final String path;
  final List<String> imagespath;
  const MiddlePage({super.key, required this.path, required this.imagespath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Clicked Image"),
        backgroundColor: const Color.fromARGB(255, 28, 9, 62),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GalleryPage(imagespath: imagespath),
                ),
              );
            },
            icon: const Icon(Icons.photo_library),
          ),
        ],
      ),
      body: Image.file(
        File(path),
        height: double.infinity,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}
