import 'dart:io';

import 'package:camera/camera.dart';
import 'package:enforcer/Api/api_provider.dart';
import 'package:enforcer/Screens/Parking/Dialogs/clampedDialog.dart';
import 'package:enforcer/Screens/Parking/Dialogs/exemptedDialog.dart';
import 'package:enforcer/Screens/Parking/Dialogs/inProgressDialog.dart';
import 'package:enforcer/Screens/Parking/Dialogs/paidDialog.dart';
import 'package:enforcer/Screens/Parking/clampVehicle.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../../widgets/failed_dialog.dart';
import '../Dialogs/unPaidDialog.dart';

class parkingController extends ChangeNotifier{
  final formKey = GlobalKey<FormState>();
  TextEditingController plateController = TextEditingController();
   Future<Map<String, dynamic>>? permissionsFuture;


  CameraController? cameraController;
  List<CameraDescription>? cameras;
  bool isCameraInitialized = false;
  String? recognizedText;

  File? plateImage;

  /// Initialize the camera
  Future<void> initializeCamera() async {
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

  bool isCapturing = false;

  /// Capture Image and Process with OCR
  Future<void> captureAndRecognizeText({
    required BuildContext context
}) async {
    if (!cameraController!.value.isInitialized) return;

    try {
      await cameraController!.setFlashMode(FlashMode.off);
      isCapturing = true;
      notifyListeners();
      XFile imageFile = await cameraController!.takePicture();

      File image = File(imageFile.path);

      final recognizedTextt = await extractTextFromImage(image);

      recognizedText = recognizedTextt;
      print("The Recognised text is ${recognizedText}");
      isCapturing = false;
      if(recognizedText != null && recognizedText!.isNotEmpty){
        plateImage = image;
        plateController.text = recognizedText.toString();
      }else{
        await showDialog(
          context: context,
          builder: (ctx) {
            return FailedDialog(
              buttonMessage: "Retry",
              message: "No plate number was captured during the Scan",
            );
          },
        );
      }
      notifyListeners();
    } catch (e) {
      print("Error capturing image: $e");
    }
  }

  /// Extract text from image using Google ML Kit

  Future<String> extractTextFromImage(File image) async {
    final inputImage = InputImage.fromFile(image);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();

    // Extract text from blocks and lines
    String recognizedPlateText = '';
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        recognizedPlateText += line.text + ' ';
      }
    }
    // Return the concatenated text
    return recognizedPlateText.trim();
  }

 clearPlateData(){
   plateController.clear();
   recognizedText = null;
   plateImage = null;
   permissionsFuture = null;
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