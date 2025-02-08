
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class SucessDialog extends StatelessWidget {
  final String message;
  final String dialogLotti;
  const SucessDialog({
    Key? key,
    required this.message,
    this.dialogLotti = 'assets/lotti/success.json',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
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
              repeat: false,
              width: 100,
              height: 100,
            ),
            const SizedBox(
              height: 25,
            ),
            Text(
              message,
              textAlign: TextAlign.center,
              style:GoogleFonts.montserrat(fontWeight: FontWeight.w600,
                  fontSize: fontSize * 1.2
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            // TextButton(
            //   onPressed: () {
            //     Navigator.of(context).pop();
            //   },
            //   child: Text(
            //     'OK',
            //     style: GoogleFonts.montserrat(
            //         fontWeight: FontWeight.w500, fontSize: 15, color:Color(0xFF567DF4)),
            //   ),
            // )
            ElevatedButton(
              onPressed: () {
                // Navigator.of(context).pop();
                Navigator.pop(context);

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
                'Ok',
                style: GoogleFonts.manrope(
                  fontSize: fontSize * 1.2,
                  fontWeight: FontWeight.w700,
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
