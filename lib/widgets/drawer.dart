import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:nb_utils/nb_utils.dart';

import '../Screens/Authentication/loginScreen.dart';




class drawer extends StatefulWidget {
  const drawer({Key? key}) : super(key: key);

  @override
  State<drawer> createState() => _drawerState();
}

class _drawerState extends State<drawer> {



  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final imageDimension = screenWidth / 3.3;
    final fontSize = screenWidth / 28.0;
    return Container(
      width: screenWidth*0.7,
      child: Drawer(
          // backgroundColor:Colors.lightBlue[300],
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('assets/images/msa.png'), fit: BoxFit.cover)),
                      child: Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              Color(0xFF3E4095).withOpacity(0.99),
                              Color(0xFF3E4095).withOpacity(0.95)
                            ])),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 55.0, bottom: 35),
                          child: Column(
                            children: [
                              Center(
                                child: Container(
                                  // width: 170,
                                  height: screenWidth * 0.26,
                                  decoration: BoxDecoration(
                                    // color: Colors.blue,
                                    // color: Colors.white,
                                      image: DecorationImage(
                                          image: AssetImage("assets/images/mcg-logoo.png",
                                          ),
                                          fit: BoxFit.contain)
                                  ),
                                ),
                              ),
                              SizedBox(height: 17,),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                child: Column(
                                  // crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Center(
                                        child: Text(
                                          // "Welcome Swaleh,",
                                          textAlign: TextAlign.center,
                                          "County Government Of Mombasa",
                                          style: GoogleFonts.manrope(
                                            // fontFamily: "Mulish",
                                            fontWeight: FontWeight.w600,
                                            fontSize: fontSize * 1 ,
                                            // color:Color(0xFF3E4095)
                                              color: Colors.white
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10,),
                                      Center(
                                        child: Text(
                                          textAlign: TextAlign.center,
                                          "Enforcer Mobile Application",
                                          style: GoogleFonts.manrope(
                                            // fontFamily: "Mulish",
                                            fontWeight: FontWeight.w600,
                                            fontSize: fontSize * 0.8,
                                            // color:Color(0xFF3E4095)
                                            color: Colors.white
                                          ),
                                        ),
                                      ),

                                      // SizedBox(height: 30,),
                                    ]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Divider(
                    //   color: Colors.black,
                    //   thickness: .2,
                    // ),
                    SizedBox(height: 10,),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0,top: 10),
                      child:   Text(
                        "Account",
                        style: GoogleFonts.manrope(
                          // fontSize: 18,
                          fontSize: fontSize * 1.3,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    // SizedBox(height: 10,),
                    SizedBox(height: screenHeight*0.01),
                    DrawerMenuWidget(
                      onbtnTap: (){
                        Navigator.pop(context);
                      },
                      iconImg: Icons.dashboard,
                      text: "Dashboard",
                      iconColor: Color(0xFFE15858),
                    ),
                    SizedBox(height: screenHeight*0.01),
                    DrawerMenuWidget(
                      onbtnTap: (){

                      },
                      iconImg: Icons.account_circle_outlined,
                      text: "User Profile",
                      iconColor:  Color(0xFFFFA117),

                    ),
                    SizedBox(height: screenHeight*0.01),
                    DrawerMenuWidget(
                      onbtnTap: () async {
                        // Step 1: Show a confirmation dialog
                        bool confirmDelete = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title:   Text(
                              "Sign Out",

                              style: GoogleFonts.montserrat(
                                  // fontFamily: "Mulish",
                                  fontWeight: FontWeight.w900,
                                  fontSize:  15 ,
                                  letterSpacing: 1
                              ),
                            ),
                            content: Text(
                              "Are you sure you want to Sign Out?",

                              style: GoogleFonts.montserrat(

                                  fontWeight: FontWeight.w600,
                                  fontSize:  13 ,
                                  letterSpacing: 1
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                ),
                                child: Text("Cancel",
                                  style: GoogleFonts.montserrat(
                                      fontSize: 13,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                ),
                                child: Text("Yes",
                                  style: GoogleFonts.montserrat(
                                      fontSize: 13,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            ],
                          ),
                        );

                        // Step 2: Check user's choice and proceed with deletion if confirmed
                        if (confirmDelete == true) {
                          await clearAllData().then((value) {
                            Navigator.pushAndRemoveUntil(context,
                                MaterialPageRoute(builder: (c) => LoginScreen()), (route) => false);
                            Get.snackbar(
                              'Signed Out',
                              'User successfully Signed Out !!!',
                              backgroundColor: Colors.black.withOpacity(0.7),
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM, // Adjust position if needed
                              duration: Duration(seconds: 2), // Adjust duration if needed
                              margin: EdgeInsets.only(left: 16.0,right: 16), // Adjust margin if needed
                              borderRadius: 10.0, // Adjust border radius if needed
                            );
                            // ScaffoldMessenger.of(context).showSnackBar(
                            //   SnackBar(
                            //     content: Text(
                            //       'Sales Agent Signed Out',
                            //       style: TextStyle(color: Colors.white),
                            //     ),
                            //     backgroundColor: Colors.green,
                            //     duration: Duration(seconds: 2),
                            //   ),
                            // );
                          }).catchError((onError) {
                            SnackBar(
                              content: Text(
                                  'Error Logging Out'), // Replace with your desired message
                              duration: Duration(seconds: 2),
                              backgroundColor: Colors.green,
                              // Adjust the duration as needed
                            );
                          });
                        }
                      },
                      iconImg: Icons.door_back_door_outlined,
                      text: "Log Out",
                      iconColor: Color(0xFF5CB65F),
                    ),
                    // SizedBox(height: 17,),
                    SizedBox(height: screenHeight*0.009),
                    Divider(
                      color: Colors.black,
                      thickness: .2,
                    ),
                    SizedBox(height: screenHeight*0.01),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0,top: 10),
                      child: Text(
                        "About Appp",
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight*0.01),
                    DrawerMenuWidget(
                        onbtnTap: () {
                          toast('Module to be Implemented');
                        },
                        iconImg: Icons.note_alt_outlined,
                        text: "Terms and Conditions",
                        iconColor: Color(0xFF9367B4)
                    ),
                    SizedBox(height: screenHeight*0.01),
                    DrawerMenuWidget(
                        onbtnTap: () {
                          // toast('Module to be Implemented');

                        },
                        iconImg: Icons.privacy_tip_outlined,
                        text: "Privacy Policy",
                        iconColor: Color(0xFFE25985)
                    ),
                    SizedBox(height: screenHeight*0.01),
                    DrawerMenuWidget(
                      onbtnTap: () {
                        toast('Module to be Implemented');
                      },
                      iconImg: Icons.contacts_outlined,
                      text: "Contact Us",
                      iconColor: null,
                    ),
                    SizedBox(height: screenHeight*0.02),
                    Divider(
                      color: Colors.white,
                      thickness: .2,
                    ),
                  ],
                ),
                // SizedBox(height: screenHeight*0.01),
                Align(
                  alignment: Alignment.topRight,
                  child: DrawerMenuWidget(
                    onbtnTap: (){
                    },
                    iconImg: Icons.verified_user_outlined,
                    text: "Version 1.0.0",
                    iconColor: Color(0xFF567DF4),
                  ),
                ),
              ],
            ),
          ) //////,
      ),
    );
  }

  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();

    // await prefs.clear();
   prefs.clear();
  }
}








class DrawerMenuWidget extends StatelessWidget {
  final IconData iconImg;
  final iconColor;
// final Text text;
  final Function() onbtnTap;

  DrawerMenuWidget({
    Key? key,
    required this.iconImg,
    required this.iconColor,
    required this.text,
    required this.onbtnTap,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final imageDimension = screenWidth / 3.3;
    final fontSize = screenWidth / 28.0;
    return GestureDetector(
      onTap: () {
        onbtnTap();
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 15.0,left: 25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon( iconImg,size: fontSize * 1.5, color: iconColor,),
            SizedBox(width: screenWidth*0.035,),

            Expanded(
              child:  Text(
                text,
                textAlign: TextAlign.left,
                style: GoogleFonts.manrope(
                  fontSize: fontSize * 0.99,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
