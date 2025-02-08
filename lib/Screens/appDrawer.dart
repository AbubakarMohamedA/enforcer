
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';

import '../privacy-policy.dart';
import 'Authentication/changePassword.dart';
import 'Authentication/loginScreen.dart';
import 'Dashboard/dashboard.dart';
import 'Profile/profile.dart';


class AppDrawer extends StatefulWidget {
  final Widget child;
  AppDrawer({key, required this.child}) : super(key: key);

  static _AppDrawerState? of(BuildContext context) => context.findAncestorStateOfType<_AppDrawerState>();

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> with SingleTickerProviderStateMixin {
  static Duration duration = Duration(milliseconds: 300);
  late AnimationController _controller;
  late double maxSlide;
  late double dragRightStartVal;
  late double dragLeftStartVal;
  // static const double maxSlide = 255;
  // static const dragRightStartVal = 60;
  // static const dragLeftStartVal = maxSlide - 20;
  static bool shouldDrag = false;

  @override
  void initState() {
    super.initState();
    // Initialize values based on screen width

    _controller = AnimationController(vsync: this, duration: _AppDrawerState.duration);
  }

  void close() => _controller.reverse();

  void open () => _controller.forward();

  void toggle () {
    if (_controller.isCompleted) {
      close();
    } else {
      open();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDragStart(DragStartDetails startDetails) {
    bool isDraggingFromLeft = _controller.isDismissed && startDetails.globalPosition.dx < dragRightStartVal;
    bool isDraggingFromRight = _controller.isCompleted && startDetails.globalPosition.dx > dragLeftStartVal;
    shouldDrag = isDraggingFromLeft || isDraggingFromRight;
  }

  void _onDragUpdate(DragUpdateDetails updateDetails) {
    if (shouldDrag == false) {
      return;
    }
    double delta = updateDetails.primaryDelta! / maxSlide;
    _controller.value += delta;
  }

  void _onDragEnd(DragEndDetails dragEndDetails) {
    if (_controller.isDismissed || _controller.isCompleted) {
      return;
    }
    double _kMinFlingVelocity = 365.0;
    double dragVelocity = dragEndDetails.velocity.pixelsPerSecond.dx.abs();

    if (dragVelocity >= _kMinFlingVelocity) {
      double visualVelocityInPx = dragEndDetails.velocity.pixelsPerSecond.dx / MediaQuery.of(context).size.width;
      _controller.fling(velocity: visualVelocityInPx);
    } else if (_controller.value < 0.5) {
      close();
    } else {
      open();
    }
  }

  @override
  Widget build(BuildContext context) {
    maxSlide = MediaQuery.of(context).size.width * 0.7; // 70% of the screen width
    dragRightStartVal = MediaQuery.of(context).size.width * 0.15; // 15% of the screen width
    dragLeftStartVal = maxSlide - 20;

    return WillPopScope(
      // onWillPop: () async {
      //   // Handle back button press
      //   Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(builder: (context) => AppDrawer(child:Dashboard())), // Navigate to BottomNavBarPage
      //   );
      //   return true;
      // },
      onWillPop: () async {
        if (_controller.isCompleted) {
          close();
          return false; // Prevents default back action
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Dashboard()), // Navigate to Dashboard
          );
          return true;
        }
      },
      child: GestureDetector(
        onHorizontalDragStart: _onDragStart,
        onHorizontalDragUpdate: _onDragUpdate,
        onHorizontalDragEnd: _onDragEnd,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, _) {
            double animationVal = _controller.value;
            double translateVal = animationVal * maxSlide;
            double scaleVal = 1 - (animationVal *  0.3);
            return Stack(
              children: <Widget>[
                CustomDrawer(),
                Transform(
                  alignment: Alignment.centerLeft,
                  transform: Matrix4.identity()
                    ..translate(translateVal)
                    ..scale(scaleVal),
                  child: GestureDetector(
                      onTap: () {
                        if (_controller.isCompleted) {
                          close();
                        }
                      },
                      child: widget.child
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

}

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final imageDimension = screenWidth / 3.3;
    final fontSize = screenWidth / 28.0;
    double containerWidth = MediaQuery.of(context).size.width * 0.95;
    return  Material(
      // color: Color(0xff5956E9),
      // color:  Color(0xff416d6d),
      color:  Color(0xfff5f7fa),
      // color:  Color(0xff969443),
      // color:  Color(0xff000F40).withOpacity(0.7),
      child: SafeArea(
        child: Theme(
          data: ThemeData(
            brightness: Brightness.dark,
          ),
          child: InkWell(
            onTap: (){
              AppDrawer.of(context)?.toggle();
            },
            child: Container(
              height: screenHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  Container(height: screenHeight*0.08,),
                  Container(
                    width: screenWidth * 0.6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0,),
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
                         Padding(
                          padding: EdgeInsets.only(left: 10, right: 0),
                          child: Divider(
                            // color: Color(0xfff4f4f8),
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),

                  buildCustomListTile(
                    context,
                    leadingIcon: Icons.dashboard,
                    iconColor: Color(0xFFE15858),
                    fontSize: fontSize,
                    titleText: 'Dashboard',
                    onTap: () {
                      AppDrawer.of(context)?.toggle();
                    },
                  ),
                  // SizedBox(height: screenHeight*0.004),

                  buildCustomListTile(
                    context,
                    leadingIcon: Icons.account_circle_outlined,
                    iconColor:  Color(0xFFFFA117),
                    fontSize: fontSize,
                    titleText: 'Profile',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => profile()), // Replace with your actual screen
                      );
                    },
                  ),

                  // DrawerMenuWidget(
                  //   onbtnTap: (){
                  //     Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //             builder: (c) => ChangePassword()));
                  //   },
                  //   iconImg: Icons.password,
                  //   text: "Change Password",
                  //   iconColor:  Color(0xFFFFA117),
                  //
                  // ),
                  buildCustomListTile(
                    context,
                    leadingIcon: Icons.password,
                    iconColor: Color(0xFFFFA117),
                    fontSize: fontSize,
                    titleText: "Change Password",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChangePassword()), // Replace with your actual screen
                      );
                    },
                  ),
                  SizedBox(height: 22,),
                  Container(
                    width: screenWidth * 0.6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0,),
                          child:   Text(
                            "About App",
                            style: GoogleFonts.manrope(
                              // fontSize: 18,
                              fontSize: fontSize * 1.3,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 10, right: 0),
                          child: Divider(
                            // color: Color(0xfff4f4f8),
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // SizedBox(height: screenHeight*0.01),
                  // DrawerMenuWidget(
                  //     onbtnTap: () {
                  //       toast('Module to be Implemented');
                  //     },
                  //     iconImg: Icons.note_alt_outlined,
                  //     text: "Terms and Conditions",
                  //     iconColor: Color(0xFF9367B4)
                  // ),
                  SizedBox(height: 7,),
                  buildCustomListTile(
                    context,
                    leadingIcon: Icons.note_alt_outlined,
                    iconColor: Color(0xFF9367B4),
                    fontSize: fontSize,
                    titleText: "Terms and Conditions",
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => ChangePassword()), // Replace with your actual screen
                      // );
                      toast('Module coming soon');
                    },
                  ),
                  // SizedBox(height: screenHeight*0.01),

                  // DrawerMenuWidget(
                  //     onbtnTap: () {
                  //       // toast('Module to be Implemented');
                  //     },
                  //     iconImg: Icons.privacy_tip_outlined,
                  //     text: "Privacy Policy",
                  //     iconColor: Color(0xFFE25985)
                  // ),
                  buildCustomListTile(
                    context,
                    leadingIcon: Icons.privacy_tip_outlined,
                    iconColor: Color(0xFFE25985),
                    fontSize: fontSize,
                    titleText: "Privacy Policy",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => privacyPolicy()), // Replace with your actual screen
                      );
                      // toast('Module coming soon');
                    },
                  ),
                  // SizedBox(height: screenHeight*0.01),
                  // DrawerMenuWidget(
                  //   onbtnTap: () {
                  //     toast('Module to be Implemented');
                  //   },
                  //   iconImg: Icons.contacts_outlined,
                  //   text: "Contact Us",
                  //   iconColor:  Color(0xFF003087),
                  // ),
                  buildCustomListTile(
                    context,
                    leadingIcon: Icons.contacts_outlined,
                    iconColor: Color(0xFF003087),
                    fontSize: fontSize,
                    titleText: "Contact Us",
                    onTap: () {
                      // showContactDialog(context);
                      toast('Module coming soon');
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => ChangePassword()), // Replace with your actual screen
                      // );
                    },
                  ),

                  Spacer(),
                  buildCustomListTile(
                    context,
                    leadingIcon: Icons.logout,
                    iconColor:Color(0xFF5CB65F),
                    fontSize: fontSize,
                    titleText: "Log Out",
                    onTap: () async {
                      // Step 1: Show a confirmation dialog

                      bool confirmDelete = await showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          insetPadding: EdgeInsets.zero,
                          child:  Container(
                            width: screenWidth*0.85,
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(height: 10,),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              "Log Out",
                                              style: GoogleFonts.manrope(
                                                fontWeight: FontWeight.w900,
                                                fontSize: 15,
                                                letterSpacing: 1,
                                                color: Colors.blueGrey,
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: GestureDetector(
                                              onTap: () => Navigator.of(context).pop(false),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: Colors.black54, width: 0.5),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Icon(Icons.close),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20,),
                                  Text(
                                    "Do you want Log Out?",
                                    style: GoogleFonts.manrope(
                                      // fontFamily: "Mulish",
                                        fontWeight: FontWeight.w600,
                                        fontSize: fontSize * 1.1,
                                        letterSpacing: 1,
                                        color: Colors.blueGrey
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 25,),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
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
                                            onPressed: () => Navigator.of(context).pop(false),
                                            style: ButtonStyle(
                                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(5.0), // Set circular border radius
                                                    side: BorderSide(color: Colors.black)
                                                ),
                                              ),
                                              backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                              minimumSize: MaterialStateProperty.all<Size>(
                                                const Size(double.infinity, 53),
                                              ),
                                            ),
                                            child:  Text(
                                              'Cancel',
                                              style: GoogleFonts.manrope(
                                                fontSize: fontSize * 1.1,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10,),
                                      Expanded(
                                        child: Container(
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
                                            onPressed: () => Navigator.of(context).pop(true),
                                            style: ButtonStyle(
                                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(5.0), // Set circular border radius
                                                ),
                                              ),
                                              // backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFFFCC2A)),

                                              backgroundColor: MaterialStateProperty.all<Color>(Colors.redAccent,),
                                              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                              minimumSize: MaterialStateProperty.all<Size>(
                                                const Size(double.infinity, 53),
                                              ),
                                            ),
                                            child: Text(
                                              'Continue',
                                              style: GoogleFonts.manrope(
                                                fontSize: fontSize * 1.1,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10,),
                                ],
                              ),
                            ),
                          ),

                        ),
                      );

                      // Step 2: Check user's choice and proceed with deletion if confirmed
                      if (confirmDelete == true) {
                        await clearAllData().then((value) {
                          Navigator.pushAndRemoveUntil(context,
                              MaterialPageRoute(builder: (c) => LoginScreen()), (route) => false);
                          Get.snackbar(
                            'Signed Out',
                            'Enforcer successfully Signed Out!',
                            backgroundColor: Colors.red.withOpacity(0.7),
                            colorText: Colors.white,
                            snackPosition: SnackPosition.TOP, // Adjust position if needed
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
                  ),

                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0, bottom: 15.0,left: 25),
                    child: RichText(
                      text: TextSpan(
                        text: 'App Version: ',
                        style: GoogleFonts.manrope(
                          fontSize: fontSize * 0.9,
                          color: Colors.black,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: '1.0.1',
                            style: GoogleFonts.manrope(
                              fontSize: fontSize * 0.9,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    // await prefs.clear();
    prefs.clear();
  }

  Widget buildCustomListTile(
      BuildContext context, {
        required IconData leadingIcon,
        required String titleText,
        required double fontSize,
        required VoidCallback onTap,
        required Color iconColor,
        double iconSize = 24.0,
        FontWeight titleFontWeight = FontWeight.w300,
      }) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.6,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        visualDensity:  VisualDensity(horizontal: 0, vertical: -4),
        horizontalTitleGap: 0,
        leading: Icon(
          leadingIcon,
          size: iconSize,
          color: iconColor,
        ),
        title: Text(
          titleText,
          style: GoogleFonts.manrope(
            fontSize: fontSize * 1,
            color: Colors.black,
          ),
        ),
        onTap: onTap,
      ),
    );
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
                  fontSize: fontSize * 1,
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