
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../Api/api_provider.dart';
import '../../widgets/failed_dialog.dart';
import '../../widgets/sucess-dialog.dart';

import '../Dashboard/dashboard.dart';
import '../Profile/profile.dart';
import '../appDrawer.dart';
import 'loginScreen.dart';


class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}




class _ChangePasswordState extends State<ChangePassword> {


  final _changePasswordFormKey = GlobalKey<FormState>();
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confrimNewPasswordController = TextEditingController();

  bool isLoading = false;

// Validates and saves the form if valid
  bool validateFields() {
    if (_changePasswordFormKey.currentState!.validate()) {
      _changePasswordFormKey.currentState!.save();
      return true;
    }
    return false;
  }

  String? fullName;
  String? email;
  String? userId;

  late SharedPreferences prefs;

  final String _kEmail = 'email_preference';
  final _kId = "id_preference";
  final _kfirstName = 'firstname_preference';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  Future<void> _loadUserData() async {
    prefs = await SharedPreferences.getInstance();

    // Fetch user data from SharedPreferences
    setState(() {
      email = prefs.getString(_kEmail) ?? '';
      userId = prefs.getString(_kId) ?? '';

    });


    print("The token is: ${_kEmail}");


    // Use the fetched data as needed, e.g., set it to state
    // setState(() {
    //   // Set state variables or use the data directly in your widgets
    // });

    print('User Data Loaded - Full Name: $fullName');
  }





  @override
  void dispose() {
    super.dispose();
    disposeControllers();
  }


  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    Size size = MediaQuery.of(context).size;
    final isKeyboard = MediaQuery.of(context).viewInsets.bottom != 0;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final imageDimension = screenWidth / 3.3;
    final fontSize = screenWidth / 28.0;
    return Scaffold(
        resizeToAvoidBottomInset: false,

        appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          toolbarHeight: 80,
          title: Text(
            "Change Password",
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
                    bottomRight: Radius.circular(30)),
                gradient: LinearGradient(
                    colors: [Color(0XFF3E4095), Color(0XFF3E4095)],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter)),
          ),

        ),
        body:  Container(
          width: double.infinity,
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom
          ),
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20))),
          child: ScrollConfiguration(
            behavior: ScrollBehavior().copyWith(overscroll: false),
            child: SingleChildScrollView(
              child:Padding(
                padding: const EdgeInsets.only(top: 15.0, left: 20, right: 20),
                child: Form(
                  key: _changePasswordFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // if (!isKeyboard)
                        SizedBox(
                        height: 15.0,
                      ),
                      if (!isKeyboard)
                        Center(
                          child: Image.asset(
                            'assets/images/mcg-logoo.png',
                            // height: screenHeight * 0.13,
                            width: size.width * 0.3,
                          ),
                        ),
                      // if (isKeyboard)
                      SizedBox(height: screenHeight * 0.01),
                      if (!isKeyboard)
                        SizedBox(height: screenHeight * 0.03),
                      // Text(
                      //   'Current Password',
                      //   style: GoogleFonts.manrope(
                      //     fontSize: fontSize,
                      //     fontWeight: FontWeight.w500,
                      //     color: Colors.black,
                      //   ),
                      // ),

                      Text(
                        "Insert Your New Password to Update",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.manrope(
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w800,
                            fontSize: fontSize * 1.2,
                            color: Color(0XFF3E4095)),
                      ),
                      const SizedBox(height: 20),
                      // TextFormField(
                      //   controller: currentPasswordController,
                      //   keyboardType: TextInputType.emailAddress,
                      //   textInputAction: TextInputAction.next,
                      //   decoration: InputDecoration(
                      //     hintText: 'Enter Current Password',
                      //     hintStyle: GoogleFonts.manrope(fontSize: fontSize),
                      //     enabledBorder: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(14),
                      //       borderSide: const BorderSide(color: Color(0xFF46B1FD)),
                      //     ),
                      //   ),
                      //   validator: (value) {
                      //     String newPassword = newPasswordController.text;
                      //     if (value == null || value.isEmpty) {
                      //       return 'Please enter your current password';
                      //     }
                      //     if (value == newPassword) {
                      //       return 'Current and new passwords cannot be the same';
                      //     }
                      //     return null;
                      //   },
                      // ),
                      //
                      // const SizedBox(height: 13),
                      // const SizedBox(height: 4),
                      Text(
                        'New Password',
                        style: GoogleFonts.manrope(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      TextFormField(
                        controller: newPasswordController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: 'Enter New Password',
                          hintStyle: GoogleFonts.manrope(fontSize: fontSize),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Color(0xFF46B1FD)),
                          ),
                        ),
                        validator: (value) {
                          String newPassword = newPasswordController.text;
                          if (value!.isEmpty || value.length < 8) {
                            return 'A valid password is required (at least 8 characters)';
                          }
                          if (value == currentPasswordController.text) {
                            return 'Current and new passwords cannot be the same';
                          }

                          return null;
                        },
                      ),
                       SizedBox(height: screenHeight * 0.03),
                      Text(
                        'Confirm Password',
                        style: GoogleFonts.manrope(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      TextFormField(
                        controller: confrimNewPasswordController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: 'Re-Enter New Password',
                          hintStyle: GoogleFonts.manrope(fontSize: fontSize),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Color(0xFF46B1FD)),
                          ),
                        ),
                        validator: (value) {
                          String newPassword = newPasswordController.text;
                          if (value!.isEmpty || value.length < 8) {
                            return 'A valid password is required (at least 8 characters)';
                          }

                          if (value != newPassword) {
                            return 'New Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20,),
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
                          onPressed: () {
                            if (_changePasswordFormKey.currentState!.validate()){
                              FocusScope.of(context).unfocus();
                              setState(() {
                                isLoading = true;
                              });

                                ApiProvider().changePassword(
                                    userId: userId.toString(),
                                    email : email.toString(),
                                    newPass: newPasswordController.text,

                                ).then((postValue) async {
                                  if (postValue['error'] == false) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                    //navigate to home
                                    // await clearAllData();
                                    navigateToHomePage(context);
                                  } else {
                                    //if there is an error message from post request
                                    setState(() {
                                      isLoading = false;
                                    });
                                    showDialog(
                                        context: context,
                                        builder: (ctx) {
                                          return FailedDialog(
                                              message: postValue['message']
                                                  .toString()
                                                  .replaceAll("[", "")
                                                  .replaceAll("]", ""));
                                        });
                                  }
                                }).catchError((onError) async {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  debugPrint(
                                      'Error POST changePassword: $onError');
                                  await showDialog(
                                      context: context,
                                      builder: (ctx) {
                                        return FailedDialog(
                                            message: "$onError".toString().replaceAll("[", "").replaceAll("]", ""));
                                      });
                                });

                            }
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
                              const Size(double.infinity, 60),
                            ),
                          ),
                          child:  isLoading ?
                          CircularProgressIndicator(
                            color: Colors.white,
                          )
                              : Text(
                            'Change Password',
                            style: GoogleFonts.manrope(
                              fontSize: fontSize * 1.2,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF3E4095),
                        // /      color: Colors.white
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

    );

  }

  void clearFields() {
    currentPasswordController.clear();
    newPasswordController.clear();
    confrimNewPasswordController.clear();
  }

  void disposeControllers() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confrimNewPasswordController.dispose();
  }
  Future<void> navigateToHomePage(BuildContext context) async {
    await clearAllData().then((value) {
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (c) => LoginScreen()), (route) => false);
      showDialog(
          context: context,
          builder: (ctx) {
            return SucessDialog(
                message: "Sucessfully Changed Password. Please Re Login"
                    .toString()
                    .replaceAll("[", "")
                    .replaceAll("]", ""));
          });
    });

  }
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
