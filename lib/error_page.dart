import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:nb_utils/nb_utils.dart';


class ErrorFetching extends StatelessWidget {
  final String message;
  final  VoidCallback onPressed;
  const ErrorFetching({super.key, required this.message, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset(
            'assets/lotti/error.json',
            repeat: false,
            width: 100,
            height: 100,
          ),
          const SizedBox(
            height: 25,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 15)

              ),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          TextButton(
            onPressed: onPressed,
            child: Text(
                'Retry',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w500, fontSize: 15, color:Colors.lightBlue)

            ),
          )
        ],
      ),
    );
  }
}
