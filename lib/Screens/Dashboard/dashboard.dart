
import 'dart:io';
import 'package:enforcer/Data/userData.dart';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:url_launcher/url_launcher.dart';
import '../../animation.dart';

import '../../test.dart';
import '../../widgets/under-development.dart';
import '../Cess/Cess.dart';
import '../Hawkers/hawkers.dart';
import '../OffLoading/off_loading.dart';
import '../Parking/parking.dart';
import '../Profile/profile.dart';
import '../Psv/psv.dart';
import '../Traffic_Offense/traffic.dart';
import '../appDrawer.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';




class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>   with SingleTickerProviderStateMixin {

  bool isDownloading = false;
  bool isDoneDownloading = false;
  double? percentage = 0;

  Future<void> _checkVersionAndLoadDetails() async {
    // Retrieve current app version dynamically
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = packageInfo.version;
    print("The package version is: ${currentVersion}");

    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero, // Set to zero for testing to always fetch latest
      ));

      // Fetch and activate remote config
      bool updated = await remoteConfig.fetchAndActivate();
      print("Fetch and activate status: $updated");

      // Fetch and activate remote config
      await remoteConfig.fetchAndActivate();

      // Get latest version from Remote Config
      String latestVersion = remoteConfig.getString('latest_playstore_version'); // ANDROID VERSION
      print("The latest version from Remote Config is: ${latestVersion}");

      // Compare versions
      if (latestVersion.isNotEmpty && currentVersion != latestVersion) {
        // Prompt user to update app
        if (mounted) {
          _showUpdatePrompt();
        }
      }
    } catch (e) {
      print('Error fetching latest version: $e');
    }
  }

  void _showUpdatePrompt() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final imageDimension = screenWidth / 3.3;
    final fontSize = screenWidth / 28.0;
    showDialog(
      context: context,
      barrierDismissible: false, // Dialog cannot be dismissed by tapping outside
      builder: (context) => WillPopScope(
        onWillPop: () async => false, // Prevent dialog from closing when back button is pressed
        child: AlertDialog(
          surfaceTintColor: Colors.white,
          content: Container(
            width: MediaQuery.of(context).size.width, // Adjust the width as needed
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 5),
                Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
                  child: Image.asset(
                    "assets/images/update.png",
                    width: MediaQuery.of(context).size.width,
                    // height: 300,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  "Update Required!!!",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(fontWeight: FontWeight.w600, fontSize: fontSize * 1.4),
                ),
                const SizedBox(height: 13),
                Text(
                  "Kindly download the latest version of the app released.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(fontWeight: FontWeight.w600, fontSize: fontSize * 1.1, color: Color(0xFF9090AD)),
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0), // Set circular border radius
                      ),
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    minimumSize: MaterialStateProperty.all<Size>(const Size(double.infinity, 60)),
                  ),
                  onPressed: () {
                    _launchPlatformm();
                    // downloadAndInstallApk();
                  },
                  child: Text(
                    'Continue',
                    style: GoogleFonts.manrope(fontWeight: FontWeight.w400, letterSpacing: 1),
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  // void _launchPlatform() async {
  //   String url;
  //
  //   if (Platform.isAndroid) {
  //     // url = 'market://details?id=com.mcp.enforcer';
  //     url = 'https://play.google.com/store/apps/details?id=com.mcp.enforcer'; // Use the HTTPS URL for Play Store
  //
  //   } else if (Platform.isIOS) {
  //     url = 'https://apps.apple.com/app/id6636477035'; // Use HTTPS for the App Store
  //
  //   } else {
  //     throw 'Unsupported platform';
  //   }
  //
  //   try {
  //     await launchUrl(
  //      Uri.parse(url),
  //       customTabsOptions: CustomTabsOptions(
  //         colorSchemes: CustomTabsColorSchemes.defaults(
  //           toolbarColor: Colors.amberAccent,
  //           navigationBarColor: Colors.brown,
  //         ),
  //         urlBarHidingEnabled: true,
  //         showTitle: true,
  //         browser: const CustomTabsBrowserConfiguration(
  //           prefersDefaultBrowser: true,
  //         ),
  //       ),
  //
  //     );
  //   } catch (e) {
  //     print('Could not launch $url: $e');
  //   }
  // }

  void _launchPlatformm() async {
    String url;

    if (Platform.isAndroid) {
      url = 'https://play.google.com/store/apps/details?id=com.mcp.enforcer'; // HTTPS URL for Play Store
    } else if (Platform.isIOS) {
      url = 'https://apps.apple.com/app/id6636477035'; // HTTPS URL for the App Store
    } else {
      throw UnsupportedError('Unsupported platform');
    }

    // Attempt to launch the URL
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }



  int innerCurrentPage = 0;
  int outerCurrentPage = 0;

  @override
  void initState() {
    fetchModuleStatus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
    _checkVersionAndLoadDetails();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  final _kId = "id_preference";
  final _kemail = "email_preference";
  final _firstName = 'firstName_preference';
  final _lastName = 'lastName_preference';
  final _kmobile = "mobile_preference";
  final _token = 'token_preference';


  late SharedPreferences prefs;
  String? id;
  String? email;
  String? firstName;
  String? lastName;
  String? mobile;
  String? token;


  String? initials = "AM";

  Future<void> _loadUserData() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      id = prefs.getString(_kId) ?? '';
      email = prefs.getString(_kemail) ?? '';
      // firstName = prefs.getString(_firstName) ?? '';
      // lastName = prefs.getString(_lastName) ?? '';
      firstName = userData.firstName ?? '';
      lastName = userData.lastName ?? '';

      print("The first and last names are ${firstName} ${lastName}");
      mobile = prefs.getString(_kmobile) ?? '';
      token = prefs.getString(_token) ?? '';
      // List<String> nameParts = fullName!.split(' ');
      // firstName = nameParts[0];
      // lastName = nameParts[1];

      if (firstName != null && firstName!.isNotEmpty && lastName != null &&
          lastName!.isNotEmpty) {
        initials = '${firstName![0]}${lastName![0]}'.toUpperCase();
      } else {
        // Handle the case where fullName is null or empty
        initials = 'NA';
      }
    });
  }

  List imgsrc = [
    'assets/images/parking.png',
    'assets/images/PSV.png',
    'assets/images/cess.png',
    'assets/images/warning.png', /*road */

    'assets/images/meat.png',  /* Food */  /* street */
    'assets/images/unload.png',
  ];

  List title = [
    'PARKING',
    'PSV',
    'CESS',
    'TRAFFIC OFFENCE',
    'HAWKERS',
    'OFF LOADING',

  ];



  List delay = [
    2.0,
    1.7,
    1.2,
    0.8,
    0.5,
    0.2,
  ];

  Map<String, bool> moduleStatus = {

  };

  List modules = [
    'parking',
    'psv',
    'cess',
    'traffic offence',
    'hawkers',
    'off loading',
  ];

  void fetchModuleStatus() {
    FirebaseFirestore.instance.collection('demoModules').snapshots().listen((snapshot) {
      snapshot.docs.forEach((doc) {
        setState(() {
          moduleStatus [doc.id] = doc['enabled'];
          print(moduleStatus);
        });
      });
    });
  }

  DateTime nowTime = DateTime.now();
  late String todayDate;

  @override
  Widget build(BuildContext context) {

// Convert double delays to Duration
    List<Duration> delayDurations = delay.map((d) => Duration(milliseconds: (d * 1000).toInt())).toList();

    Size size = MediaQuery.of(context).size;
    double height, width;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final imageDimension = screenWidth / 3.3;
    final fontSize = screenWidth / 28.0;
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;
    todayDate = DateFormat("EEE, MMM d, yyyy").format(nowTime).toString();
    DateTime? _lastBackPressTime;
    // DateTime nowTime = DateTime.now();
    // DateFormat dateFormat = DateFormat("EEE, MMM d, yyyy");
    // String todayDate = dateFormat.format(nowTime).toString();
    return Builder(builder: (context) {
      return WillPopScope(
        onWillPop: () async {
          // Close the app immediately without showing a dialog
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          return false; // Return false to indicate that the back navigation should not be handled by default
        },
        child: Scaffold(
            backgroundColor: Colors.white,
            // drawer:  drawer(),
            body: ScrollConfiguration(
              behavior: ScrollBehavior().copyWith(overscroll: false),
              child: SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Container(
                        width: size.width,
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              // bottomLeft: Radius.circular(30),
                                bottomRight: Radius.circular(30)),
                            image: DecorationImage(
                                image: AssetImage('assets/images/msa2.jpg'), fit: BoxFit.cover)),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                // bottomLeft: Radius.circular(30),
                                  bottomRight: Radius.circular(30)),
                              gradient: LinearGradient(colors: [
                                // Color(0xFF3E4095).withOpacity(0.95),
                                // Color(0xFF3E4095).withOpacity(0.9)
                                Color(0xFF3E4095).withOpacity(0.95),
                                Color(0xFF3E4095).withOpacity(0.95)
                              ])),
                          child: SafeArea(
                            child: Column(
                              children: [
                                SizedBox(height: 12,),
                                Container(
                                  width: size.width,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Builder(
                                            builder: (context) {
                                              return GestureDetector(
                                                onTap: () {
                                                  // Scaffold.of(context).openDrawer();
                                                  AppDrawer.of(context)?.toggle();
                                                },
                                                child: IconButton(
                                                  icon: SvgPicture.asset(
                                                    'assets/images/menu (3).svg',
                                                    // Make sure to add your SVG file to the assets directory
                                                    height: 20.0,
                                                    width: 20.0,
                                                    color: Colors.white,
                                                  ),
                                                  onPressed: () {
                                                    // Scaffold.of(context).openDrawer();
                                                    AppDrawer.of(context)?.toggle();
                                                  },
                                                ),
                                              );
                                            }
                                        ),

                                        Container(
                                          // height: screenWidth * 0.26,
                                          height: screenWidth * 0.165,
                                          decoration: BoxDecoration(
                                            // color: Colors.greenAccent,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.white.withOpacity(0.5),
                                                // Adjust opacity to control shadow intensity
                                                spreadRadius: 5,
                                                // Spread the shadow
                                                blurRadius: 90,
                                                // Blur the shadow
                                                offset: Offset(
                                                    0, 0), // Offset the shadow (x, y)
                                              ),
                                            ],
                                          ),
                                          child: Image.asset(
                                            'assets/images/mcg-logoo.png',
                                            // height: screenWidth * 0.165,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (c) => profile()));
                                          },
                                          child: Container(
                                            width: 45,
                                            height: 45,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 2.0,
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                // 'SW',
                                                initials!,
                                                style: GoogleFonts.manrope(
                                                  // fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Container()
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.015,),
                                Container(
                                  width: size.width,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        child: Column(
                                          // crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment
                                                .center,
                                            children: [
                                              Center(
                                                child: Text(
                                                  // "Welcome Swaleh,",
                                                  textAlign: TextAlign.center,
                                                  "County Government of Mombasa",
                                                  style: GoogleFonts.manrope(
                                                    // fontFamily: "Mulish",
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: fontSize * 1.4,
                                                    color: Colors.white,
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
                                                    fontSize: fontSize * 1.2,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height:21),
                                              // _innerBannerSlider(size.height,size.width),
                                              Container(
                                                color: Colors.white.withOpacity(
                                                    0.7),
                                                height: 1,
                                                width: width * 0.9,
                                              ),
                                              SizedBox(height: 23,),
                                              Container(
                                                width: width * 0.9,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      width: screenWidth * 0.5,
                                                      child: Text(
                                                        // "Welcome Swaleh,",
                                                        "Welcome, ${firstName} 👋",
                                                        style: GoogleFonts.manrope(
                                                          // fontFamily: "Mulish",
                                                          fontWeight: FontWeight
                                                              .w600,
                                                          fontSize: fontSize * 1.1,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: screenWidth * 0.03,),
                                                    // Spacer(),
                                                    Expanded(
                                                      child: Row(
                                                        crossAxisAlignment: CrossAxisAlignment
                                                            .center,
                                                        children: [
                                                          Icon(
                                                            Icons.calendar_today,
                                                            color: Colors.white
                                                                .withOpacity(0.5),
                                                            size: 15,
                                                          ),
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
                                                          Flexible(
                                                            child: Text(
                                                              todayDate,
                                                              style: GoogleFonts
                                                                  .manrope(
                                                                // fontFamily: "Mulish",
                                                                fontSize: fontSize * 1,
                                                                color: Colors.white,),
                                                              overflow: TextOverflow
                                                                  .ellipsis,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              //  Comment for ios
                                              // SizedBox(height: 30,),
                                            ]),
                                      ),

                                    ],
                                  ),
                                ),
                                SizedBox(height:23,),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.032,),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                Text(
                                  "Select A Service",
                                  textAlign: TextAlign.left,
                                  style: GoogleFonts.manrope(
                                    // fontFamily: "Mulish",
                                    fontWeight: FontWeight.w600,
                                    fontSize: fontSize * 1.3,
                                    color: Colors.black,
                                  ),
                                ),
                                Spacer(),

                              ],
                            ),
                          ),
                          Padding(
                            padding:  EdgeInsets.only(left: 10.0, right: 10,top: screenHeight * 0.024),
                            child: GridView.builder(
                                padding: EdgeInsets.zero,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 1.25,
                                  mainAxisSpacing: 7,
                                ),
                                shrinkWrap: true,
                                itemCount: title.length,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () {
                                      // Navigate to the corresponding page when a container is tapped
                                      String module = modules[index].toLowerCase();
                                      if (moduleStatus[module] == false) {
                                        showDialog(
                                          context: context,
                                          builder: (ctx) {
                                            return underDevelopment(
                                              message: 'Our team is currently performing maintenance on this module. We apologize for any inconvenience and appreciate your understanding. Please check back later.',
                                            );
                                          },
                                        );
                                      } else {
                                        switch (index) {
                                          case 0:
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (c) =>
                                                        parking(

                                                        )));
                                            //   showDialog(
                                            //       context: context,
                                            //       builder: (ctx) {
                                            //         return underDevelopment(
                                            //           message: 'Our team is currently performing maintenance on this module. We apologize for any inconvenience and appreciate your understanding. Please check back later.',
                                            //         );});
                                            break;
                                          case 1:
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (c) =>
                                                        psv(
                                                        )));
                                            // showDialog(
                                            //     context: context,
                                            //     builder: (ctx) {
                                            //       return underDevelopment(
                                            //         message: 'Our team is currently performing maintenance on this module. We apologize for any inconvenience and appreciate your understanding. Please check back later.',
                                            //       );});
                                            break;
                                          case 2:
                                            Navigator.push(context, MaterialPageRoute(builder: (c) => cess()));
                                            // showDialog(
                                            //     context: context,
                                            //     builder: (ctx) {
                                            //       return underDevelopment(
                                            //         message: 'Our team is currently performing maintenance on this module. We apologize for any inconvenience and appreciate your understanding. Please check back later.',
                                            //       );});
                                            break;
                                          case 3:
                                            Navigator.push(context, MaterialPageRoute(builder: (c) => traffic()));
                                            // showDialog(
                                            //     context: context,
                                            //     builder: (ctx) {
                                            //       return underDevelopment(
                                            //         message: 'Our team is currently performing maintenance on this module. We apologize for any inconvenience and appreciate your understanding. Please check back later.',
                                            //       );});
                                            break;
                                          case 4:
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (c) =>
                                                        hawkers(
                                                          token: token,
                                                        )));
                                            break;
                                          case 5:
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (c) =>
                                                        offBoarding(
                                                          token: token,
                                                        )));
                                            break;
                                        }
                                      }



                                    },
                                    child: CardField(
                                      size,
                                      imgsrc[index],
                                      title[index],
                                      "assets/images/pattern.png",
                                      delay[index],
                                      fontSize
                                    ),
                                  );
                                }
                            ),
                          ),
                        ],
                      ),



                      SizedBox(height: 10,),
                    ]),
              ),
            )),
      );
    });
  }


  Container GradientContainer(Size size) {
    return Container(
      height: size.height * .33,
      width: size.width,
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            // bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30)),
          image: DecorationImage(
              image: AssetImage('assets/images/msa.png'), fit: BoxFit.cover)),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              // bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30)),
            gradient: LinearGradient(colors: [
              // Color(0xFF3E4095).withOpacity(0.95),
              // Color(0xFF3E4095).withOpacity(0.9)
              Color(0xFF3E4095).withOpacity(0.95),
              Color(0xFF3E4095).withOpacity(0.95)
            ])),
      ),
    );
  }

}


CardField(
    Size size,
    String img,
    String title,
    String patternImg, // Add pattern image parameter
    double delay,
    double fontSize,
    ) {
  return FadeAnimation(
    delay: delay,
    child: Container(
      margin: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
      child: Stack(
        children: [
          // Pattern image
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: DecorationImage(
                image: AssetImage(patternImg),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Color overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Color(0xFF3E4095).withOpacity(0.95),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 5), // changes position of shadow
                ),
              ],
            ),
          ),
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  img,
                  // width: 50,
                  width: size.width * 0.14,
                ),
                SizedBox(height: 15,),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    // fontSize: 14,
                    fontSize: fontSize,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}