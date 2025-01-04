import 'dart:io';
import 'package:flutter/material.dart';

class GalleryPage extends StatelessWidget {
  final List<String> imagespath; // List contains the paths of images

  const GalleryPage({super.key, required this.imagespath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photos'),
        backgroundColor: const Color.fromARGB(255, 45, 36, 72),
      ),
      backgroundColor: Colors.white,
      body: imagespath.isNotEmpty
          ? GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1,
                crossAxisSpacing: 2,
              ),
              itemCount: imagespath.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            OnClickShowPicture(imagepath: imagespath[index]),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Image.file(
                      File(imagespath[index]), // Display each image from file
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            )
          : const Center(
              child: Text("Gallery is Empty"),
            ),
    );
  }
}

class OnClickShowPicture extends StatelessWidget {
  final String imagepath; // List contains the paths of images
  const OnClickShowPicture({
    super.key,
    required this.imagepath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Clicked Picture'),
        backgroundColor: const Color.fromARGB(255, 45, 36, 72),
      ),
      backgroundColor: Colors.white,
      body: Material(
        elevation: 10,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Image.file(
            File(imagepath),
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
