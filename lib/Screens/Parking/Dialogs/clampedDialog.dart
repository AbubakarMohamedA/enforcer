
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class clampedDialog extends StatelessWidget {
  final String plate;
  final Function? onPress;
  final String dialogLotti;
  final Map<String, dynamic> result;

  clampedDialog({
    Key? key,
    required this.plate,
    required this.onPress,
    required this.dialogLotti,
    required this.result
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final size =  MediaQuery.of(context).size;
    final screenHeight = MediaQuery.of(context).size.height;
    final imageDimension = screenWidth / 3.3;
    final fontSize = screenWidth / 28.0;
    return AlertDialog(
      content: SingleChildScrollView(
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              dialogLotti,
              repeat: true,
              width: 100,
              height: 100,
            ),
            const SizedBox(
              height: 25,
            ),

            Row(
              children: [
                SizedBox(
                  width: screenWidth * 0.3,
                  child:Text(
                    'Plate Number:',
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
                    plate,
                    style: GoogleFonts.manrope(
                      fontSize: fontSize * 1,
                      // fontWeight: FontWeight.w500,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),)
              ],
            ),
            SizedBox(height: screenHeight * 0.015,),
            Row(
              children: [
                SizedBox(
                  width: screenWidth * 0.3,
                  child:Text(
                    'Status:',
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
                    "CLAMPED",
                    style: GoogleFonts.manrope(
                      fontSize: fontSize * 1,
                      // fontWeight: FontWeight.w500,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),)
              ],
            ),
            SizedBox(height: screenHeight * 0.015,),
            Row(
              children: [
                SizedBox(
                  width: screenWidth * 0.3,
                  child:Text(
                    'Category:',
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
                    "Pick Up",
                    style: GoogleFonts.manrope(
                      fontSize: fontSize * 1,
                      // fontWeight: FontWeight.w500,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),)
              ],
            ),
            SizedBox(height: screenHeight * 0.015,),
            Row(
              children: [
                SizedBox(
                  width: screenWidth * 0.3,
                  child:Text(
                    'Zone:',
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
                    "Makupa",
                    style: GoogleFonts.manrope(
                      fontSize: fontSize * 1,
                      // fontWeight: FontWeight.w500,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),)
              ],
            ),
            SizedBox(height: screenHeight * 0.015,),
            Row(
              children: [
                SizedBox(
                  width: screenWidth * 0.3,
                  child:Text(
                    'Date:',
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
                    result['time'],
                    style: GoogleFonts.manrope(
                      fontSize: fontSize * 1,
                      // fontWeight: FontWeight.w500,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),)
              ],
            ),
            SizedBox(height: screenHeight * 0.02,),
            Divider(),
            SizedBox(height: screenHeight * 0.02,),
            ElevatedButton(
              onPressed:(){
                onPress!();
              },
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0), // Set circular border radius
                  ),
                ),
                backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFFFCC2A)),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                minimumSize: MaterialStateProperty.all<Size>(
                  const Size(double.infinity, 65),
                ),
              ),
              child: Text(
                'Cancel',
                style: GoogleFonts.manrope(
                  fontSize: fontSize * 1,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF3E4095),
                ),
              ),
            ),
          ],
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
