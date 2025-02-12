import 'package:camera/camera.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:enforcer/Data/userData.dart';
import 'package:enforcer/Screens/Parking/Controllers/parkingController.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:qr_scanner_overlay/qr_scanner_overlay.dart';
import '../../Api/api_provider.dart';
import '../../widgets/failed_dialog.dart';

class vehicleScanPage extends StatefulWidget {
  const vehicleScanPage({super.key});

  @override
  State<vehicleScanPage> createState() => _vehicleScanPageState();
}

class _vehicleScanPageState extends State<vehicleScanPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initialize();
    });
  }

  var provider;

  initialize() {
    provider = Provider.of<parkingController>(context, listen: false);
    provider.initializeCamera();
  }

  @override
  void dispose() {
    provider.cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final imageDimension = screenWidth / 3.3;
    final fontSize = screenWidth / 28.0;
    return Consumer<parkingController>(
      builder: (context, parkingProvider, child) {
        return WillPopScope(
          onWillPop: () async {
            // parkingProvider.clearPlateData();
            provider.cameraController?.dispose();
            provider.isCameraInitialized = false;
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
                "Scan Vehicle",
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
                    borderRadius: BorderRadius.only(
                        // bottomLeft: Radius.circular(20),
                        //   bottomRight: Radius.circular(30)
                        ),
                    gradient: LinearGradient(
                        colors: [Color(0XFF3E4095), Color(0XFF3E4095)],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter)),
              ),
            ),
            body: SingleChildScrollView(
              child: Form(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // SizedBox(height: screenWidth * 0.03,),
                    Container(
                      height: screenHeight * 0.45,
                      width: screenWidth,
                      child: parkingProvider.isCameraInitialized
                          ? GestureDetector(
                              onTap: () {
                                if (!parkingProvider.isCapturing) {
                                  parkingProvider.captureAndRecognizePlate(context);
                                }
                              },
                              child: CameraPreview(
                                parkingProvider.cameraController!,
                                child: Stack(
                                  children: [
                                    QRScannerOverlay(
                                      overlayColor: Colors.black26,
                                      scanAreaWidth: screenWidth * 0.65,
                                      scanAreaHeight: screenWidth * 0.6,
                                    ),
                                    if (parkingProvider.isCapturing)
                                      Align(
                                        alignment: Alignment.center,
                                        child: CircularProgressIndicator(
                                            color: Color(0xFFFFCC2A)),
                                      ),
                                  ],
                                ),
                              ),
                            )
                          : Stack(
                              children: [
                                QRScannerOverlay(
                                  overlayColor: Colors.black26,
                                  scanAreaWidth: screenWidth * 0.65,
                                  scanAreaHeight: screenWidth * 0.6,
                                ),
                                Center(
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 25.0),
                                      child: IntrinsicWidth(
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            FocusScope.of(context).unfocus();
                                            parkingProvider.initializeCamera();
                                          },
                                          style: ButtonStyle(
                                            shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                            ),
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                        Color>(
                                                    Color(0XFF3E4095)
                                                        .withOpacity(0.6)),
                                            foregroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.white),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10.0,
                                                vertical: 15.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              // Ensures the Row takes up only needed space
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
                                      )),
                                ),
                              ],
                            ),
                    ),
                    SizedBox(
                      height: screenWidth * 0.05,
                    ),
                    if (parkingProvider.plateImage != null)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: screenWidth * 0.37,
                                  child: Text(
                                    'Plate  Image: ',
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
                                  child: Container(
                                    height: 70,
                                    width: 70,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.black54, width: 4),
                                        shape: BoxShape.rectangle,
                                        image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: FileImage(
                                                parkingProvider.plateImage!))),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: screenWidth * 0.05,
                            ),
                            SizedBox(
                              height: screenWidth * 0.05,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: screenWidth * 0.37,
                                  child: Text(
                                    'Plate :',
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
                                  child: Text(
                                    "${parkingProvider.plateController.text}",
                                    style: GoogleFonts.manrope(
                                      fontSize: fontSize * 1,
                                      // fontWeight: FontWeight.w500,
                                      color: Colors.black.withOpacity(0.7),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: screenWidth * 0.37,
                                  child: Text(
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
                                  child: Text(
                                    "${DateTime.now()}",
                                    style: GoogleFonts.manrope(
                                      fontSize: fontSize * 1,
                                      // fontWeight: FontWeight.w500,
                                      color: Colors.black.withOpacity(0.7),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    SizedBox(
                      height: 50,
                    ),
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
                            if (!parkingProvider.isCapturing) {
                              parkingProvider.captureAndRecognizePlate( context);
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    8.0), // Set circular border radius
                              ),
                            ),
                            backgroundColor: MaterialStateProperty.all<Color>(
                              Color(0XFF3E4095),
                            ),
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                            minimumSize: MaterialStateProperty.all<Size>(
                              Size(double.infinity, 65),
                            ),
                          ),
                          child: parkingProvider.isCapturing
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      "assets/images/camera.svg",
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: screenWidth * 0.03,
                                    ),
                                    Text(
                                      'Scan',
                                      style: GoogleFonts.manrope(
                                        fontSize: fontSize * 1.2,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
