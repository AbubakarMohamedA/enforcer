// import 'dart:io';
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// import 'package:path_provider/path_provider.dart';
//
// class PlateScannerPage extends StatefulWidget {
//   @override
//   _PlateScannerPageState createState() => _PlateScannerPageState();
// }
//
// class _PlateScannerPageState extends State<PlateScannerPage> {
//   CameraController? _cameraController;
//   List<CameraDescription>? cameras;
//   bool _isCameraInitialized = false;
//   String? _recognizedText;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//   }
//
//   /// Initialize the camera
//   Future<void> _initializeCamera() async {
//     cameras = await availableCameras();
//     if (cameras!.isNotEmpty) {
//       _cameraController = CameraController(cameras![0], ResolutionPreset.medium);
//       await _cameraController!.initialize();
//       if (mounted) {
//         setState(() {
//           _isCameraInitialized = true;
//         });
//       }
//     }
//   }
//
//   /// Capture Image and Process with OCR
//   Future<void> _captureAndRecognizeText() async {
//     if (!_cameraController!.value.isInitialized) return;
//
//     try {
//       XFile imageFile = await _cameraController!.takePicture();
//
//       File image = File(imageFile.path);
//       final recognizedText = await _extractTextFromImage(image);
//
//       setState(() {
//         _recognizedText = recognizedText;
//       });
//     } catch (e) {
//       print("Error capturing image: $e");
//     }
//   }
//
//   /// Extract text from image using Google ML Kit
//   Future<String> _extractTextFromImage(File image) async {
//     final inputImage = InputImage.fromFile(image);
//     final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
//
//     final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
//     await textRecognizer.close();
//
//     return recognizedText.text; // Return extracted text
//   }
//
//   @override
//   void dispose() {
//     _cameraController?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Scan License Plate")),
//       body: Column(
//         children: [
//           _isCameraInitialized
//               ? CameraPreview(_cameraController!)
//               : CircularProgressIndicator(),
//
//           SizedBox(height: 10),
//
//           ElevatedButton(
//             onPressed: _captureAndRecognizeText,
//             child: Text("Capture & Recognize"),
//           ),
//
//           SizedBox(height: 10),
//
//           _recognizedText != null
//               ? Text("Extracted Text: $_recognizedText")
//               : Text("No text recognized"),
//         ],
//       ),
//     );
//   }
// }
