import 'dart:io';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:camera/camera.dart';
import 'package:enforcer/Api/api_provider.dart';
import 'package:enforcer/Screens/Parking/Dialogs/clampedDialog.dart';
import 'package:enforcer/Screens/Parking/Dialogs/exemptedDialog.dart';
import 'package:enforcer/Screens/Parking/Dialogs/inProgressDialog.dart';
import 'package:enforcer/Screens/Parking/Dialogs/paidDialog.dart';
import 'package:enforcer/Screens/Parking/clampVehicle.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:enforcer/Data/userData.dart';
import '../../../widgets/failed_dialog.dart';
import '../Dialogs/unPaidDialog.dart';

class parkingController extends ChangeNotifier{
  final formKey = GlobalKey<FormState>();
  TextEditingController plateController = TextEditingController();
   Future<Map<String, dynamic>>? permissionsFuture;



   Future<void> checkPermission() async{
     try{
      permissionsFuture = ApiProvider().checkPermission(permissionType: 'Access Hawkers', token: userData.token.toString(), url: "Prod");
     }catch(e){
       notifyListeners();
     }finally{
       notifyListeners();
     }
   }



  CameraController? cameraController;
  List<CameraDescription>? cameras;
  bool isCameraInitialized = false;
  String? recognizedText;

  File? plateImage;

  bool isCapturing = false;

  /// Initialize the camera
  Future<void> initializeCamera() async {

    notifyListeners();
    cameras = await availableCameras();
    if (cameras!.isNotEmpty) {
      print("allowed");
      cameraController = CameraController(cameras![0], ResolutionPreset.medium);
      await cameraController!.initialize();
      isCameraInitialized = true;
      notifyListeners();
    }else{

    }

  }
//
//   bool isCapturing = false;
//
//   /// Capture Image and Process with OCR
//   Future<void> captureAndRecognizeText({
//     required BuildContext context
// }) async {
//     if (!cameraController!.value.isInitialized) return;
//     try {
//       await cameraController!.setFlashMode(FlashMode.off);
//       isCapturing = true;
//       notifyListeners();
//       XFile imageFile = await cameraController!.takePicture();
//
//       File image = File(imageFile.path);
//
//       final recognizedTextt = await extractTextFromImage(image);
//       recognizedText = recognizedTextt;
//       print("The Recognised text is ${recognizedText}");
//       isCapturing = false;
//       if(recognizedText != null && recognizedText!.isNotEmpty){
//         plateImage = image;
//         plateController.text = recognizedText.toString();
//         print("The Recognised text is not null");
//         notifyListeners();
//         Navigator.of(context).pop();
//       }else{
//         print("The Recognised text is null");
//         await showDialog(
//           context: context,
//           builder: (ctx) {
//             return FailedDialog(
//               buttonMessage: "Retry",
//               message: "No plate number was captured during the Scan",
//             );
//           },
//         );
//       }
//       notifyListeners();
//     } catch (e) {
//       print("Error capturing image: $e");
//     }
//   }
//
//   /// Extract text from image using Google ML Kit
//
//   Future<String> extractTextFromImage(File image) async {
//     final inputImage = InputImage.fromFile(image);
//     final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
//
//     final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
//     await textRecognizer.close();
//
//     // Extract text from blocks and lines
//     String recognizedPlateText = '';
//     for (TextBlock block in recognizedText.blocks) {
//       for (TextLine line in block.lines) {
//         recognizedPlateText += line.text + ' ';
//       }
//     }
//     // Return the concatenated text
//     return recognizedPlateText.trim();
//   }
  Future<void> captureAndRecognizePlate(BuildContext context) async {
    if (!cameraController!.value.isInitialized) return;

    try {
      await cameraController!.setFlashMode(FlashMode.off);
      isCapturing = true;
      notifyListeners();

      XFile imageFile = await cameraController!.takePicture();
      File image = File(imageFile.path);

      // Step 1: Detect the license plate first
      Rect? plateRegion = await detectPlateRegion(image);

      if (plateRegion == null) {
        isCapturing = false;
        notifyListeners();
        _showErrorDialog(context, "No plate detected. Try again.");
        return;
      }

      // Step 2: Crop the detected plate region and run OCR
      String? extractedText = await extractPlateNumber(image, plateRegion);

      if (extractedText != null && extractedText.isNotEmpty) {
        plateImage = image;
        plateController.text = extractedText;
        isCapturing = false;
        notifyListeners();
        Navigator.of(context).pop();
      } else {
        isCapturing = false;
        notifyListeners();
        _showErrorDialog(context, "No plate number was captured. ${extractedText}");
      }

    } catch (e) {
      print("Error capturing image: $e");
    }
  }
  Future<Rect?> detectPlateRegion(File image) async {
    final inputImage = InputImage.fromFile(image);
    final objectDetector = ObjectDetector(
      options: ObjectDetectorOptions(
        mode: DetectionMode.stream,
        classifyObjects: false,
        multipleObjects: false,
      ),
    );

    final detectedObjects = await objectDetector.processImage(inputImage);
    await objectDetector.close();

    for (DetectedObject object in detectedObjects) {
      // Assuming the license plate is the only detected object
      return object.boundingBox;
    }

    return null; // No plate detected
  }
  Future<String?> extractPlateNumber(File image, Rect plateRegion) async {
    final inputImage = InputImage.fromFile(image);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();

    String extractedText = '';

    for (TextBlock block in recognizedText.blocks) {
      if (plateRegion.overlaps(block.boundingBox)) {
        // Only consider text inside detected plate region
        for (TextLine line in block.lines) {
          extractedText += line.text + ' ';
        }
      }
    }

    // Filter only valid plate numbers using Regex (Example: ABC 1234)
    RegExp platePattern = RegExp(r"[A-Z]{3}\s?[0-9]{3,4}");
    Match? match = platePattern.firstMatch(extractedText);

    return match?.group(0); // Return only the valid plate number
  }
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) {
        return FailedDialog(
          buttonMessage: "Retry",
          message: message,
        );
      },
    );
  }


  clearPlateData(){
   plateController.clear();
   recognizedText = null;
   plateImage = null;
   permissionsFuture = null;
   isCameraInitialized = false;
   // notifyListeners();
 }

 notify(){
   notifyListeners();
 }

 bool isVerifyingStatus = false;

 Future<void> checkStatus({
    required BuildContext context
}) async{
    try{
      isVerifyingStatus = true;
      notifyListeners();
      final Map<String, dynamic> result = await ApiProvider().checkParkingStatus(plateNum: plateController.text);
      isVerifyingStatus = false;
      notifyListeners();
      if(result['id'] == "Not Paid"){
        showDialog(
            context: context,
            builder: (ctx) {
              return unPaidDialog(
                onbackPress: (){
                  clearPlateData();
                  Navigator.pop(context);
                },
                onClamp: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>clampVehicle(plate: plateController.text)));
                },
                plate: plateController.text, dialogLotti: 'assets/lotti/error.json',);
            });
        // clearPlateData();
      }
      else if(result['id'] == "Paid"){
        showDialog(
            context: context,
            builder: (ctx) {
              return paidDialog(
                result: result,
                onPress: (){
                  clearPlateData();
                  Navigator.pop(context);
                },
                  plate: plateController.text, dialogLotti: 'assets/lotti/success.json',);
            });
        // clearPlateData();
      }
      else if(result['id'] == "Exempted"){
        showDialog(
            context: context,
            builder: (ctx) {
              return exemptedDialog(
                onPress: (){
                  clearPlateData();
                  Navigator.pop(context);
                },
                plate: plateController.text, dialogLotti: 'assets/lotti/success.json',);
            });
        // clearPlateData();
      }
      else if(result['id'] == "Clamped"){
        showDialog(
            context: context,
            builder: (ctx) {
              return clampedDialog(
                result: result,
                onPress: (){
                  clearPlateData();
                  Navigator.pop(context);
                },
                plate: plateController.text, dialogLotti: 'assets/lotti/error.json',);
            });
      }
      else if(result['id'] == "Payment in progress"){
        showDialog(
            context: context,
            builder: (ctx) {
              return inProgressDialog(
                onPress: (){
                  clearPlateData();
                  Navigator.pop(context);
                },
                plate: plateController.text, dialogLotti: 'assets/lotti/success.json',);
            });
        // clearPlateData();
      }
    }catch (e){
      isVerifyingStatus = false;
      notifyListeners();
    }finally{
      isVerifyingStatus = false;
      notifyListeners();
    }
 }

}