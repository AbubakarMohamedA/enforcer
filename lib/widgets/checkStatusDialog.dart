
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class checkStatusDialog extends StatefulWidget {
  final String message;
  final String dialogLotti;
  const checkStatusDialog({
    Key? key,
    required this.message,
    this.dialogLotti = 'assets/lotti/error.json',
  }) : super(key: key);

  @override
  State<checkStatusDialog> createState() => _checkStatusDialogState();
}

class _checkStatusDialogState extends State<checkStatusDialog> {
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
              repeat: false,
              width: 100,
              height: 100,
            ),
            const SizedBox(
              height: 25,
            ),
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style:GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 18),
            ),
            const SizedBox(
              height: 25,
            ),

            ElevatedButton(
              onPressed: () {
                // Navigator.of(context).pop();
                Navigator.pop(context);

              },
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(8.0), // Set circular border radius
                  ),
                ),
                backgroundColor:
                MaterialStateProperty.all<Color>(Color(0xFFFFCC2A)),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                minimumSize: MaterialStateProperty.all<Size>(
                  const Size(double.infinity, 65),
                ),
              ),
              child: Text(
                'Prompt Hawker',
                style: GoogleFonts.manrope(
                  fontSize: 15,
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
