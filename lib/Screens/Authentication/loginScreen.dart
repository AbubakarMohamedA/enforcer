import 'dart:math' as math;

import 'package:enforcer/Data/userData.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';


import '../../Api/api_provider.dart';
import '../../background.dart';

import '../../widgets.dart';
import '../../widgets/failed_dialog.dart';
import '../Dashboard/dashboard.dart';
import '../appDrawer.dart';
import 'forgotPassword.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {

  final _formKey = GlobalKey<FormState>();

  bool _obscureText = true;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();


  bool isLoading = false;

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
  }

  final _kId = "id_preference";
  final _kemail = "email_preference";
  final _firstName = 'firstName_preference';
  final _lastName = 'lastName_preference';
  final _kmobile = "mobile_preference";
  final _token = 'token_preference';

  Widget topWidget(double screenWidth) {
    return Transform.rotate(
      angle: -35 * math.pi / 180,
      child: Container(
        width: 1.2 * screenWidth,
        height: 1.2 * screenWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(150),
          gradient: const LinearGradient(
            begin: Alignment(-0.2, -0.8),
            end: Alignment.bottomCenter,
            colors: [
              Color(0x007CBFCF),
              Color(0xB316BFC4),
            ],
          ),
        ),
      ),
    );
  }

  Widget bottomWidget(double screenWidth) {
    return Container(
      width: 1.5 * screenWidth,
      height: 1.5 * screenWidth,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment(0.6, -1.1),
          end: Alignment(0.7, 0.8),
          colors: [
            Color(0xDB4BE8CC),
            Color(0x005CDBCF),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final imageDimension = screenWidth / 3.3;
    final fontSize = screenWidth / 28.0;
    final height = MediaQuery.of(context).size.height;
    final isKeyboard = MediaQuery.of(context).viewInsets.bottom != 0;
    Size size = MediaQuery.of(context).size;
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: kBgColor,
      body: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Stack(
            children: [
              Container(
                height: size.height,
                width: size.width,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.2),BlendMode.lighten),
                      image: AssetImage("assets/images/bannr.png")
                  ),
                ),

              ),
              Container(
                height: screenHeight,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        height: screenHeight * 0.356,
                        child: Stack(
                          children: [
                            // _drawCircles(),
                            // Positioned(
                            //   top: 0,
                            //   right: 0,
                            //   child: Image.asset(
                            //       "assets/images/top1.png",
                            //       width: size.width
                            //   ),
                            // ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Image.asset(
                                "assets/images/top2.png",
                                width: size.width,
                                height: screenHeight * 0.3,
                                fit: BoxFit.fill,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(bottom: 15),
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Image.asset(
                                  'assets/images/mcg-logoo.png',
                                  height: screenWidth * 0.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: buildLoginForm(fontSize, context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
      ),
    );
  }

  Widget buildLoginForm(double fontSize, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 17.0),
      child: Column(
        children: [
          Text(
            'MSA County Enforcer App',
            style: GoogleFonts.manrope(
              fontSize: fontSize * 1.2,
              fontWeight: FontWeight.w700,
              color: Color(0xFF3E4095),
            ),
          ),
          const SizedBox(height: 17),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Email',
                  style: GoogleFonts.manrope(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF3E4095),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    hintStyle: GoogleFonts.manrope(fontSize: fontSize),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF46B1FD)),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.email_outlined),
                      onPressed: () {},
                    ),
                  ),
                  validator: _emailValidator,
                ),
                const SizedBox(height: 17),
                Text(
                  'Password',
                  style: GoogleFonts.manrope(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                    color:Color(0xFF3E4095),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    hintStyle: GoogleFonts.manrope(fontSize: fontSize),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF46B1FD)),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscureText ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ),
                  validator: _passwordValidator,
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      showDialog(
                        context: context,
                        builder: (ctx) {
                          return NewPassword();
                        },
                      );
                    },
                    child: Text(
                      'Forgot password?',
                      style: GoogleFonts.manrope(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF3E4095),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
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
            child:ElevatedButton(
              onPressed: () async {
                FocusScope.of(context).unfocus();
                setState(() {
                  isLoading = true;
                });
                if (_formKey.currentState!.validate()) {
                  try {
                    Map<String, dynamic> loginResult = await ApiProvider().staffLogin(
                      email: _emailController.text,
                      password: _passwordController.text,
                    );

                    if (loginResult['message'] != "Login successful!") {
                      await showDialog(
                        context: context,
                        builder: (ctx) {
                          return FailedDialog(
                            message: loginResult['message'].toString(),
                          );
                        },
                      );
                    } else {
                      // CONFIRM THE USERNAME RETURNED
                      // String fullName = loginResult['user']['full_name'];
                      // String fullName = "Abdul Jibril";
                      // List<String> nameParts = fullName!.split(' ');
                      // String firstName = nameParts[0];
                      // String lastName = nameParts[1];
                      // SharedPreferences prefs = await SharedPreferences.getInstance();
                      // await prefs.setString(_token, loginResult['token'] ?? '');
                      // await prefs.setString(_kId, loginResult['user']['staff_id'].toString() ?? '');
                      // await prefs.setString(_firstName, loginResult['user']['firstname'].toString() ?? '');
                      // await prefs.setString(_lastName,loginResult['user']['lastname'].toString() ?? '');
                      // await prefs.setString(_kemail, loginResult['user']['email'] ?? '');
                      // await prefs.setString(_kmobile, loginResult['user']['mobile'] ?? '');
                      await saveUserDataToPreferences(loginResult);
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (c) => Dashboard()),
                      // );
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AppDrawer(child:Dashboard()),),);
                    }
                  } catch (e) {
                    print('Error during login: $e');
                    await showDialog(
                      context: context,
                      builder: (ctx) {
                        return FailedDialog(
                          message: e.toString(),
                        );
                      },
                    );
                  }
                }
                setState(() {
                  isLoading = false;
                });
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
              child: isLoading
                  ? CircularProgressIndicator(
                color: Colors.white,
              )
                  : Text(
                'Log In',
                style: GoogleFonts.manrope(
                  fontSize: fontSize * 1.2,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3E4095),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }


  Future<void> saveUserDataToPreferences(Map<String, dynamic> loginResult) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString(_token, loginResult['token'] ?? '');
    await prefs.setString(_kId, loginResult['user']['staff_id'].toString() ?? '');
    await prefs.setString(_firstName, loginResult['user']['firstname'].toString() ?? '');
    await prefs.setString(_lastName,loginResult['user']['lastname'].toString() ?? '');
    await prefs.setString(_kemail, loginResult['user']['email'] ?? '');
    await prefs.setString(_kmobile, loginResult['user']['mobile'] ?? '');

    Get.snackbar(
      'Signed In',
      'Enforcer successfully Signed In!',
      backgroundColor: Colors.green.withOpacity(0.7),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 2),
      margin: EdgeInsets.only(left: 16.0, right: 16),
      borderRadius: 10.0,
    );
    /// Update the UserData class fields

    userData.token = loginResult['token'].toString() ?? '';
    userData.userId= loginResult['user']['idno'].toString() ?? '';
    userData.email = loginResult['user']['email'].toString() ?? '';
    userData.firstName = "${loginResult['user']['firstname'].toString()} ${loginResult['user']['lastname'].toString()}" ?? '';
    userData.lastName = "${loginResult['user']['lastname'].toString()} ${loginResult['user']['lastname'].toString()}" ?? '';
    userData.mobile = loginResult['user']['mobile'].toString() ?? '';


    print("User data saved and updated in UserData class.");
  }

}
