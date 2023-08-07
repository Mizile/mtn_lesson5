import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Obtain the list of available cameras on the device.
  final cameras = await availableCameras();
  // Get the first available camera
  final firstCamera = cameras.first;

  runApp(CameraApp(camera: firstCamera));
}

class CameraApp extends StatefulWidget {
  final CameraDescription camera;

  CameraApp({required this.camera});

  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      // Use the appropriate camera
      widget.camera,
      // Define the resolution to be used
      ResolutionPreset.medium,
    );

    // Initialize the camera controller
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the camera controller when the widget is removed from the widget tree
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('MTN Hardware API Assignment'),
        ),
        body: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // If the Future is complete, display the preview
              return CameraPreview(_controller);
            } else {
              // Otherwise, display a loading indicator
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            try {
              // Ensure that the camera is initialized before attempting to take a picture
              await _initializeControllerFuture;

              // Take the picture using the camera controller
              final image = await _controller.takePicture();

              // Process the image (you can save it, display it, or send it to a server)
              print('Image saved to: ${image.path}');
            } catch (e) {
              print('Error taking picture: $e');
            }
          },
          child: Icon(Icons.camera_alt),
        ),
      ),
    );
  }
}
