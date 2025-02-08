
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class underDevelopment extends StatefulWidget {
  final String message;
  final String dialogLotti;
  const underDevelopment({
    Key? key,
    required this.message,
    this.dialogLotti = 'assets/lotti/under-devt.json',
  }) : super(key: key);

  @override
  State<underDevelopment> createState() => _underDevelopmentState();
}

class _underDevelopmentState extends State<underDevelopment> {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
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
              widget.dialogLotti,
              repeat: true,
              width: 150,
              height: 150,
            ),
            const SizedBox(
              height: 25,
            ),
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style:GoogleFonts.manrope(fontWeight: FontWeight.w500, fontSize: fontSize),
            ),
            const SizedBox(
              height: 25,
            ),
            Container(
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
                onPressed: () => Navigator.of(context).pop(),
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(5.0), // Set circular border radius
                    ),
                  ),
                  // backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFFFCC2A)),

                  backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFFFCC2A),),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  minimumSize: MaterialStateProperty.all<Size>(
                    const Size(double.infinity, 53),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_back_ios_new_sharp,
                      color: Color(0xFF3E4095),
                      size: fontSize * 1.3,
                    ),
                    SizedBox(width: 10,),
                    Text(
                      'Back',
                      style: GoogleFonts.manrope(
                          color: Color(0xFF3E4095),
                          fontSize: fontSize * 1.2,
                          fontWeight: FontWeight.w600),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
