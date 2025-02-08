
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class unPaidDialog extends StatelessWidget {
  final String plate;
  final Function? onbackPress;
  final Function? onClamp;
  final String dialogLotti;

  unPaidDialog({
    Key? key,
    required this.plate,
    required this.onbackPress,
    required this.onClamp,
    required this.dialogLotti,
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
              height: 23,
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
                    "UNPAID",
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
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(

                    onPressed:(){
                      onbackPress!();
                    },

                    style: ButtonStyle(

                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: BorderSide(color: Colors.lightBlueAccent, width: 1.0), // Black border
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.manrope(
                        fontSize: fontSize * 1,
                        fontWeight: FontWeight.w500,
                        color:Colors.lightBlueAccent,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 5,),
                Expanded(
                  child: ElevatedButton(

                    onPressed:(){
                      onClamp!();
                    },

                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    ),
                    child: Text(
                      'Clamp',
                      style: GoogleFonts.manrope(
                        fontSize: fontSize * 1,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
