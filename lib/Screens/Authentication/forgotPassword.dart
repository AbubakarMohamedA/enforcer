import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import '../../Api/api_provider.dart';
import '../../widgets/failed_dialog.dart';
import 'loginScreen.dart';


class NewPassword extends StatefulWidget {
  NewPassword({
    super.key,
  });


  @override
  State<NewPassword> createState() => _NewPasswordState();
}

class _NewPasswordState extends State<NewPassword> {
  final GlobalKey<FormState> _passFormKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  bool isLoading = false;



  Future<void> _validateInputs() async {
    if (_passFormKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      _passFormKey.currentState!.save();
      setState(() {
        isLoading = true;
      });
      try {
        Map<String, dynamic> forgotPassResult = await ApiProvider()
            .forgotPassword(
          emailAddress: _emailController.text,
        );
        if(forgotPassResult['error'] == true) {
          setState(() {
            isLoading = false;
          });
          showDialog(
              context: context,
              builder: (ctx) {
                return FailedDialog(
                  message: forgotPassResult['message']
                      .toString()
                      .replaceAll("[", "")
                      .replaceAll("]", ""),
                );
              });
        }else if(forgotPassResult['error'] == false) {
          setState(() {
            isLoading = false;
          });
          showDialog(
              context: context,
              builder: (ctx) {
                return FailedDialog(
                  dialogLotti: "assets/lotti/success.json",
                  message: "Kindly check your email for a link to reset your password."
                      .toString()
                      .replaceAll("[", "")
                      .replaceAll("]", ""),
                );
              });
        }

      } catch (e) {
        // Handle exceptions
        print('Error: $e');
        setState(() {
          isLoading = false;
        });
        showDialog(
            context: context,
            builder: (ctx) {
              return FailedDialog(
                  message:
                  e
                      .toString()
                      .replaceAll("[", "")
                      .replaceAll("]", ""));
            });
      }
    }
  }

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
        .hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final imageDimension = screenWidth / 3.3;
    final fontSize = screenWidth / 28.0;
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      icon: Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Icon(Icons.cancel_outlined))),
      title: Text(
        'Forgot your Password?',
        style:GoogleFonts.manrope(
            fontSize: fontSize * 1.3,
            fontWeight: FontWeight.bold
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Enter your email address and we will share a link to create a new password.',
              style:GoogleFonts.manrope(
                fontSize: fontSize * 0.9,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Form(
              key: _passFormKey,
              child:  TextFormField(
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration:
                InputDecoration(
                  hintText: 'Enter your email',
                  hintStyle: GoogleFonts.manrope(
                    fontSize: fontSize * 1,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color:Color(0xFF46B1FD)),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.email_outlined),
                    onPressed: () {
                    },
                  ),
                ),

                controller: _emailController,
                validator: _emailValidator,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Center(
              child: GestureDetector(
                onTap: () => _validateInputs(),
                child: Container(
                  height: 60,
                  width: size.width * 0.7,
                  decoration: BoxDecoration(
                      color:Color(0xFFFFCC2A),
                      borderRadius: BorderRadius.circular(8)),
                  child: isLoading
                      ? Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.send,
                        color: Color(0xFF3E4095),
                      ),
                      SizedBox(width: 10,),
                      Text(
                        'Send',
                        style: TextStyle(
                            color: Color(0xFF3E4095),
                            fontSize: 20,
                            fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }

  void navigateToHomePage(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) =>
          const LoginScreen()), // Replace with your HomePage widget
          (route) => false, // Remove all routes except for the new homepage route
    );
  }


}
