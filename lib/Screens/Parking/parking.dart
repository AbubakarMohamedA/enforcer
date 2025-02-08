import 'package:camera/camera.dart';
import 'package:enforcer/Data/userData.dart';
import 'package:enforcer/Screens/Parking/Controllers/parkingController.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:qr_scanner_overlay/qr_scanner_overlay.dart';
import '../../Api/api_provider.dart';
import '../../widgets/failed_dialog.dart';

class parking extends StatefulWidget {
  const parking({super.key});

  @override
  State<parking> createState() => _parkingState();
}

class _parkingState extends State<parking> with SingleTickerProviderStateMixin {


  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      initialize();
    });
  }

  var provider;

  initialize(){
    provider = Provider.of<parkingController>(context,listen: false);
    provider.permissionsFuture = ApiProvider().checkPermission(permissionType: 'Access Hawkers', token: userData.token.toString(), url: "Prod");
    provider.initializeCamera();
  }

  @override
  void dispose() {
    disposeFunction();
    provider.cameraController?.dispose();
    super.dispose();
  }
  disposeFunction(){
    // var provider = Provider.of<parkingController>(context,listen: false);
    provider.cameraController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final imageDimension = screenWidth / 3.3;
    final fontSize = screenWidth / 28.0;
    return Consumer<parkingController>(
     builder: (context, parkingProvider, child){
       return WillPopScope(
         onWillPop: () async{
           parkingProvider.clearPlateData();
           return true;
         },
         child: Scaffold(
           resizeToAvoidBottomInset: true,
           appBar: AppBar(
             // automaticallyImplyLeading: false,
             backgroundColor: Colors.transparent,
             elevation: 0.0,
             toolbarHeight: 80,
             title: Text(
               "Parking",
               style: GoogleFonts.manrope(
                 // fontFamily: "Mulish",
                 fontWeight: FontWeight.w600,
                 fontSize: fontSize * 1.4,
                 color: Colors.white,
               ),
             ),
             centerTitle: true,
             flexibleSpace: Container(
               decoration: BoxDecoration(
                 // borderRadius: BorderRadius.only(
                 // bottomLeft: Radius.circular(20),
                 //   bottomRight: Radius.circular(30)),
                   gradient: LinearGradient(
                       colors: [Color(0XFF3E4095), Color(0XFF3E4095)],
                       begin: Alignment.bottomCenter,
                       end: Alignment.topCenter)),
             ),
           ),
           body: FutureBuilder(
               future: parkingProvider.permissionsFuture,
               builder: (context, snapshot) {
                 if (snapshot.hasError) {
                   print(snapshot.error);
                   return Center(
                       child: FailedDialog(
                         message: snapshot.error.toString(),)
                   );
                 }
                 else if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
                   print("Its null for now ");
                   return Center(
                     child: Column(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         Text(
                           'Verifying Permission',
                           style: GoogleFonts.manrope(
                               fontSize: fontSize * 1.2,
                               color: Color(0XFF3E4095),
                               fontWeight: FontWeight.bold
                           ),
                         ),
                         SizedBox(height: screenHeight * 0.05),
                         CircularProgressIndicator(color: Color(0XFF3E4095)),
                       ],
                     ),
                   );

                 }
                 else {
                   print("Its not null for now ");
                   Map<String, dynamic>? permissionResult = snapshot.data;
                   if(permissionResult!['access'] == true){
                     return  SingleChildScrollView(
                       child: Form(
                         key: parkingProvider.formKey,
                         child: Column(
                           children: [
                             // SizedBox(height: screenWidth * 0.03,),
                             Container(
                               height: screenHeight * 0.45,
                               width: screenWidth,
                               child: parkingProvider.isCameraInitialized
                                   ? GestureDetector(
                                 onTap: (){
                                   if(!parkingProvider.isCapturing){
                                     parkingProvider.captureAndRecognizeText(context: context);
                                   }
                                 },
                                 child: CameraPreview(
                                   parkingProvider.cameraController!,
                                   child: Stack(
                                     children: [
                                       QRScannerOverlay(overlayColor: Colors.black26,scanAreaWidth: screenWidth * 0.65,scanAreaHeight: screenWidth * 0.6,),
                                       if (parkingProvider.isCapturing)
                                         Align(
                                           alignment: Alignment.center,
                                           child: CircularProgressIndicator(
                                               color: Color(0xFFFFCC2A)
                                           ),
                                         ),
                                     ],
                                   ),
                                 ),
                               ) :
                               Stack(
                                 children: [
                                   QRScannerOverlay(overlayColor: Colors.black26,scanAreaWidth: screenWidth * 0.65,scanAreaHeight: screenWidth * 0.6,),
                                   Center(
                                     child: Padding(
                                         padding: const EdgeInsets.symmetric(horizontal: 25.0),
                                         child:IntrinsicWidth(
                                           child: ElevatedButton(
                                             onPressed: () async {
                                               FocusScope.of(context).unfocus();
                                               parkingProvider.initializeCamera();
                                             },
                                             style: ButtonStyle(
                                               shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                 RoundedRectangleBorder(
                                                   borderRadius: BorderRadius.circular(8.0),
                                                 ),
                                               ),
                                               backgroundColor: MaterialStateProperty.all<Color>(Color(0XFF3E4095).withOpacity(0.6)),
                                               foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                             ),
                                             child: Padding(
                                               padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
                                               child: Row(
                                                 mainAxisSize: MainAxisSize.min, // Ensures the Row takes up only needed space
                                                 children: [
                                                   Text(
                                                     'Allow',
                                                     style: GoogleFonts.manrope(
                                                       fontSize: fontSize * 1.1,
                                                       fontWeight: FontWeight.w600,
                                                       color: Colors.white,
                                                     ),
                                                   ),
                                                 ],
                                               ),
                                             ),
                                           ),
                                         )
                                     ),
                                   ),
                                 ],
                               ),
                             ),
                             SizedBox(height: screenWidth * 0.05,),
                             Padding(
                               padding: EdgeInsets.symmetric(horizontal: 15.0),
                               child: Column(
                                 children: [
                                   SizedBox(height: screenWidth * 0.05,),
                                   Container(
                                     width: screenWidth,
                                     child: Row(
                                       children: [
                                         Expanded(child: Divider(color: Color(0XFF3E4095))),
                                         Text(" Or "),
                                         Expanded(child: Divider(color: Color(0XFF3E4095))),
                                       ],
                                     ),
                                   ),
                                   SizedBox(height: screenWidth * 0.05,),
                                   Column(
                                     mainAxisAlignment:
                                     MainAxisAlignment.spaceBetween,
                                     children: [
                                       Row(
                                         crossAxisAlignment: CrossAxisAlignment.start,
                                         mainAxisAlignment: MainAxisAlignment.start,
                                         children: [
                                           RedoPlateButton(
                                               onPressed: () {
                                                 FocusScope.of(context).unfocus();
                                                 parkingProvider.clearPlateData();
                                               }),
                                           SizedBox(width: 20,),
                                           Expanded(
                                             child: TextFormField(
                                               controller: parkingProvider.plateController,
                                               decoration: const InputDecoration(
                                                 hintText: 'Vehicle Number Plate',
                                                 hintStyle: TextStyle(),
                                                 contentPadding: EdgeInsets.only(bottom: -10),
                                                 enabledBorder: UnderlineInputBorder(
                                                   borderSide:
                                                   BorderSide(color:Color(0XFF3E4095)),
                                                 ),
                                                 focusedBorder: UnderlineInputBorder(
                                                   borderSide: BorderSide(
                                                       color: Color(0XFF3E4095), width: 1),
                                                 ),
                                                 errorBorder: UnderlineInputBorder(
                                                   borderSide: BorderSide(
                                                       color: Colors.red, width: 1),
                                                 ),
                                                 focusedErrorBorder:
                                                 UnderlineInputBorder(
                                                   borderSide: BorderSide(
                                                       color: Colors.red, width: 1),
                                                 ),
                                               ),
                                               cursorColor: Color(0XFF3E4095), // Set the cursor color
                                               // Other properties...
                                               validator: (value) {
                                                 const pattern = r'^[a-zA-Z]{3}\d{3}[a-zA-Z]$';
                                                 final regExp = RegExp(pattern);
                                                 final trimmedValue = value!.replaceAll(RegExp(r'\s+'), ''); // Remove all whitespace

                                                 if (trimmedValue.isEmpty) {
                                                   return 'Enter Number Plate';
                                                 }
                                                 // if (!regExp.hasMatch(trimmedValue)) {
                                                 //   return 'Enter Valid Number Plate';
                                                 // }
                                                 return null;
                                               },
                                             ),
                                           ),
                                         ],
                                       ),
                                       SizedBox(
                                         height:20,
                                       ),

                                     ],
                                   ),
                                 ],),
                             ),

                             if(parkingProvider.plateImage != null)
                               Padding(
                                 padding: EdgeInsets.symmetric(horizontal: 15.0),
                                 child: Column(
                                   children: [
                                     Row(
                                       children: [
                                         SizedBox(
                                           width: screenWidth * 0.37,
                                           child:Text(
                                             'Plate Number : ',
                                             style: GoogleFonts.manrope(
                                               fontSize: fontSize * 1,
                                               // fontWeight: FontWeight.w500,
                                               color: Colors.black,
                                             ),
                                           ),
                                         ),
                                         SizedBox(
                                           width: size.width * 0.04,
                                         ),
                                         Flexible(
                                           child:   Container(
                                             height: 70,
                                             width: 70,
                                             decoration: BoxDecoration(
                                                 border: Border.all(
                                                     color: Colors.black54, width: 4),
                                                 shape: BoxShape.rectangle,
                                                 image: DecorationImage(
                                                     fit: BoxFit.cover,
                                                     image: FileImage(parkingProvider.plateImage!))),
                                           ),)
                                       ],
                                     ),
                                     SizedBox(height: screenWidth * 0.05,),
                                     Row(
                                       children: [
                                         SizedBox(
                                           width: screenWidth * 0.37,
                                           child:Text(
                                             'Captured :',
                                             style: GoogleFonts.manrope(
                                               fontSize: fontSize * 1,
                                               // fontWeight: FontWeight.w500,
                                               color: Colors.black,
                                             ),
                                           ),
                                         ),
                                         SizedBox(
                                           width: size.width * 0.04,
                                         ),
                                         Flexible(
                                           child:  Text(
                                             "${ DateTime.now()}",
                                             style: GoogleFonts.manrope(
                                               fontSize: fontSize * 1,
                                               // fontWeight: FontWeight.w500,
                                               color: Colors.black.withOpacity(0.7),
                                             ),
                                           ),)
                                       ],
                                     ),

                                   ],
                                 ),
                               ),
                             SizedBox(height: 50,),
                             Align(
                               alignment: Alignment.bottomCenter,
                               child: Container(
                                 margin: EdgeInsets.all(20),
                                 decoration: BoxDecoration(
                                   boxShadow: [
                                     BoxShadow(
                                       color: Colors.black.withOpacity(0.2),
                                       spreadRadius: 1,
                                       blurRadius: 5,
                                       offset: Offset(0, 5), // changes position of shadow
                                     ),
                                   ],
                                   borderRadius: BorderRadius.circular(8.0),
                                 ),
                                 child: ElevatedButton(
                                   onPressed: () async {
                                     // Your onPressed code here
                                     FocusScope.of(context).unfocus();
                                     if(parkingProvider.formKey.currentState!.validate()){
                                       parkingProvider.checkStatus(context: context);
                                     }
                                   },
                                   // style: ButtonStyle(
                                   //   shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                   //     RoundedRectangleBorder(
                                   //       borderRadius: BorderRadius.circular(8.0),
                                   //     ),
                                   //   ),
                                   //   backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFFFCC2A)),
                                   //   foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                   //   minimumSize: MaterialStateProperty.all<Size>(
                                   //     const Size(double.infinity, 60),
                                   //   ),
                                   // ),
                                   style: ButtonStyle(
                                     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                       RoundedRectangleBorder(
                                         borderRadius:
                                         BorderRadius.circular(8.0), // Set circular border radius
                                       ),
                                     ),
                                     backgroundColor:
                                     MaterialStateProperty.all<Color>( Color(0XFF3E4095),),
                                     foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                     minimumSize: MaterialStateProperty.all<Size>(
                                       const Size(double.infinity, 65),
                                     ),
                                   ),
                                   child: parkingProvider.isVerifyingStatus
                                       ? const Center(
                                     child: CircularProgressIndicator(
                                       color: Colors.white,
                                     ),
                                   )
                                       :Text(
                                     'Check Status',
                                     style: GoogleFonts.manrope(
                                       fontSize: fontSize * 1.2,
                                       fontWeight: FontWeight.w500,
                                       color: Colors.white,
                                     ),
                                   ),
                                 ),
                               ),
                             )
                           ],
                         ),
                       ),
                     );
                   }else{
                     return FailedDialog(
                       message: permissionResult!['message'].toString(),
                     );
                   }
                 }
               }),
         // body: SingleChildScrollView(
         //   child: Form(
         //     key: parkingProvider.formKey,
         //     child: Column(
         //       children: [
         //         // SizedBox(height: screenWidth * 0.03,),
         //         Container(
         //           height: screenHeight * 0.45,
         //           width: screenWidth,
         //           child: parkingProvider.isCameraInitialized
         //               ? GestureDetector(
         //             onTap: (){
         //               if(!parkingProvider.isCapturing){
         //                 parkingProvider.captureAndRecognizeText(context: context);
         //               }
         //             },
         //             child: CameraPreview(
         //               parkingProvider.cameraController!,
         //               child: Stack(
         //                 children: [
         //                   QRScannerOverlay(overlayColor: Colors.black26,scanAreaWidth: screenWidth * 0.65,scanAreaHeight: screenWidth * 0.6,),
         //                   if (parkingProvider.isCapturing)
         //                     Align(
         //                       alignment: Alignment.center,
         //                       child: CircularProgressIndicator(
         //                           color: Color(0xFFFFCC2A)
         //                       ),
         //                     ),
         //                 ],
         //               ),
         //             ),
         //           ) :
         //           Stack(
         //             children: [
         //               QRScannerOverlay(overlayColor: Colors.black26,scanAreaWidth: screenWidth * 0.65,scanAreaHeight: screenWidth * 0.6,),
         //               Center(
         //                 child: Padding(
         //                     padding: const EdgeInsets.symmetric(horizontal: 25.0),
         //                     child:IntrinsicWidth(
         //                       child: ElevatedButton(
         //                         onPressed: () async {
         //                           FocusScope.of(context).unfocus();
         //                           parkingProvider.initializeCamera();
         //                         },
         //                         style: ButtonStyle(
         //                           shape: MaterialStateProperty.all<RoundedRectangleBorder>(
         //                             RoundedRectangleBorder(
         //                               borderRadius: BorderRadius.circular(8.0),
         //                             ),
         //                           ),
         //                           backgroundColor: MaterialStateProperty.all<Color>(Color(0XFF3E4095).withOpacity(0.6)),
         //                           foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
         //                         ),
         //                         child: Padding(
         //                           padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
         //                           child: Row(
         //                             mainAxisSize: MainAxisSize.min, // Ensures the Row takes up only needed space
         //                             children: [
         //                               Text(
         //                                 'Allow',
         //                                 style: GoogleFonts.manrope(
         //                                   fontSize: fontSize * 1.1,
         //                                   fontWeight: FontWeight.w600,
         //                                   color: Colors.white,
         //                                 ),
         //                               ),
         //                             ],
         //                           ),
         //                         ),
         //                       ),
         //                     )
         //                 ),
         //               ),
         //             ],
         //           ),
         //         ),
         //         SizedBox(height: screenWidth * 0.05,),
         //         Padding(
         //           padding: EdgeInsets.symmetric(horizontal: 15.0),
         //           child: Column(
         //             children: [
         //               SizedBox(height: screenWidth * 0.05,),
         //               Container(
         //                 width: screenWidth,
         //                 child: Row(
         //                   children: [
         //                     Expanded(child: Divider(color: Color(0XFF3E4095))),
         //                     Text(" Or "),
         //                     Expanded(child: Divider(color: Color(0XFF3E4095))),
         //                   ],
         //                 ),
         //               ),
         //               SizedBox(height: screenWidth * 0.05,),
         //               Column(
         //                 mainAxisAlignment:
         //                 MainAxisAlignment.spaceBetween,
         //                 children: [
         //                   Row(
         //                     crossAxisAlignment: CrossAxisAlignment.start,
         //                     mainAxisAlignment: MainAxisAlignment.start,
         //                     children: [
         //                       RedoPlateButton(
         //                           onPressed: () {
         //                             FocusScope.of(context).unfocus();
         //                             parkingProvider.clearPlateData();
         //                           }),
         //                       SizedBox(width: 20,),
         //                       Expanded(
         //                         child: TextFormField(
         //                           controller: parkingProvider.plateController,
         //                           decoration: const InputDecoration(
         //                             hintText: 'Vehicle Number Plate',
         //                             hintStyle: TextStyle(),
         //                             contentPadding: EdgeInsets.only(bottom: -10),
         //                             enabledBorder: UnderlineInputBorder(
         //                               borderSide:
         //                               BorderSide(color:Color(0XFF3E4095)),
         //                             ),
         //                             focusedBorder: UnderlineInputBorder(
         //                               borderSide: BorderSide(
         //                                   color: Color(0XFF3E4095), width: 1),
         //                             ),
         //                             errorBorder: UnderlineInputBorder(
         //                               borderSide: BorderSide(
         //                                   color: Colors.red, width: 1),
         //                             ),
         //                             focusedErrorBorder:
         //                             UnderlineInputBorder(
         //                               borderSide: BorderSide(
         //                                   color: Colors.red, width: 1),
         //                             ),
         //                           ),
         //                           cursorColor: Color(0XFF3E4095), // Set the cursor color
         //                           // Other properties...
         //                           validator: (value) {
         //                             const pattern = r'^[a-zA-Z]{3}\d{3}[a-zA-Z]$';
         //                             final regExp = RegExp(pattern);
         //                             final trimmedValue = value!.replaceAll(RegExp(r'\s+'), ''); // Remove all whitespace
         //
         //                             if (trimmedValue.isEmpty) {
         //                               return 'Enter Number Plate';
         //                             }
         //                             // if (!regExp.hasMatch(trimmedValue)) {
         //                             //   return 'Enter Valid Number Plate';
         //                             // }
         //                             return null;
         //                           },
         //                         ),
         //                       ),
         //                     ],
         //                   ),
         //                   SizedBox(
         //                     height:20,
         //                   ),
         //
         //                 ],
         //               ),
         //             ],),
         //         ),
         //
         //         if(parkingProvider.plateImage != null)
         //           Padding(
         //             padding: EdgeInsets.symmetric(horizontal: 15.0),
         //             child: Column(
         //               children: [
         //                 Row(
         //                   children: [
         //                     SizedBox(
         //                       width: screenWidth * 0.37,
         //                       child:Text(
         //                         'Plate Number : ',
         //                         style: GoogleFonts.manrope(
         //                           fontSize: fontSize * 1,
         //                           // fontWeight: FontWeight.w500,
         //                           color: Colors.black,
         //                         ),
         //                       ),
         //                     ),
         //                     SizedBox(
         //                       width: size.width * 0.04,
         //                     ),
         //                     Flexible(
         //                       child:   Container(
         //                         height: 70,
         //                         width: 70,
         //                         decoration: BoxDecoration(
         //                             border: Border.all(
         //                                 color: Colors.black54, width: 4),
         //                             shape: BoxShape.rectangle,
         //                             image: DecorationImage(
         //                                 fit: BoxFit.cover,
         //                                 image: FileImage(parkingProvider.plateImage!))),
         //                       ),)
         //                   ],
         //                 ),
         //                 SizedBox(height: screenWidth * 0.05,),
         //                 Row(
         //                   children: [
         //                     SizedBox(
         //                       width: screenWidth * 0.37,
         //                       child:Text(
         //                         'Captured :',
         //                         style: GoogleFonts.manrope(
         //                           fontSize: fontSize * 1,
         //                           // fontWeight: FontWeight.w500,
         //                           color: Colors.black,
         //                         ),
         //                       ),
         //                     ),
         //                     SizedBox(
         //                       width: size.width * 0.04,
         //                     ),
         //                     Flexible(
         //                       child:  Text(
         //                         "${ DateTime.now()}",
         //                         style: GoogleFonts.manrope(
         //                           fontSize: fontSize * 1,
         //                           // fontWeight: FontWeight.w500,
         //                           color: Colors.black.withOpacity(0.7),
         //                         ),
         //                       ),)
         //                   ],
         //                 ),
         //
         //               ],
         //             ),
         //           ),
         //         SizedBox(height: 50,),
         //         Align(
         //           alignment: Alignment.bottomCenter,
         //           child: Container(
         //             margin: EdgeInsets.all(20),
         //             decoration: BoxDecoration(
         //               boxShadow: [
         //                 BoxShadow(
         //                   color: Colors.black.withOpacity(0.2),
         //                   spreadRadius: 1,
         //                   blurRadius: 5,
         //                   offset: Offset(0, 5), // changes position of shadow
         //                 ),
         //               ],
         //               borderRadius: BorderRadius.circular(8.0),
         //             ),
         //             child: ElevatedButton(
         //               onPressed: () async {
         //                 // Your onPressed code here
         //                 FocusScope.of(context).unfocus();
         //                 if(parkingProvider.formKey.currentState!.validate()){
         //                   parkingProvider.checkStatus(context: context);
         //                 }
         //               },
         //               // style: ButtonStyle(
         //               //   shape: MaterialStateProperty.all<RoundedRectangleBorder>(
         //               //     RoundedRectangleBorder(
         //               //       borderRadius: BorderRadius.circular(8.0),
         //               //     ),
         //               //   ),
         //               //   backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFFFCC2A)),
         //               //   foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
         //               //   minimumSize: MaterialStateProperty.all<Size>(
         //               //     const Size(double.infinity, 60),
         //               //   ),
         //               // ),
         //               style: ButtonStyle(
         //                 shape: MaterialStateProperty.all<RoundedRectangleBorder>(
         //                   RoundedRectangleBorder(
         //                     borderRadius:
         //                     BorderRadius.circular(8.0), // Set circular border radius
         //                   ),
         //                 ),
         //                 backgroundColor:
         //                 MaterialStateProperty.all<Color>( Color(0XFF3E4095),),
         //                 foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
         //                 minimumSize: MaterialStateProperty.all<Size>(
         //                   const Size(double.infinity, 65),
         //                 ),
         //               ),
         //               child: parkingProvider.isVerifyingStatus
         //                   ? const Center(
         //                 child: CircularProgressIndicator(
         //                   color: Colors.white,
         //                 ),
         //               )
         //                   :Text(
         //                 'Check Status',
         //                 style: GoogleFonts.manrope(
         //                   fontSize: fontSize * 1.2,
         //                   fontWeight: FontWeight.w500,
         //                   color: Colors.white,
         //                 ),
         //               ),
         //             ),
         //           ),
         //         )
         //       ],
         //     ),
         //   ),
         // ),

         ),
       );
     },
    );
  }
}




class RedoPlateButton extends StatelessWidget {
  final VoidCallback onPressed;

  const RedoPlateButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Card(
        elevation: 4,
        child: Container(
          // width: MediaQuery.of(context).size.width * 0.15,
          // height: MediaQuery.of(context).size.width * 0.1,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0), // Set the border radius
          ),
          child:  Padding(
            padding: const EdgeInsets.all(15.0),
            child: Icon(
              Icons.refresh,
              // color: Colors.redAccent,
              color: Color(0XFF3E4095),
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
