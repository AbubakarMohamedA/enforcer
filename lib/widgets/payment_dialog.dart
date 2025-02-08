
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class paymentDialog extends StatefulWidget {
  final String message;
  final String dialogLotti;
  const paymentDialog({
    Key? key,
    required this.message,
    this.dialogLotti = 'assets/lotti/loadingPayment1.json',
  }) : super(key: key);

  @override
  State<paymentDialog> createState() => _paymentDialogState();
}

class _paymentDialogState extends State<paymentDialog> {
  @override
  Widget build(BuildContext context) {
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
              width: 100,
              height: 100,
            ),
            const SizedBox(
              height: 25,
            ),
            // Text(
            //   widget.message,
            //   textAlign: TextAlign.center,
            //   style:GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 18),
            // ),
            // const SizedBox(
            //   height: 25,
            // ),
            AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  widget.message,
                  textAlign: TextAlign.center,
                  textStyle: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                  speed: Duration(milliseconds: 100),
                ),
              ],
              totalRepeatCount: 3,
            ),

            const SizedBox(
              height: 25,
            ),

          ],
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
