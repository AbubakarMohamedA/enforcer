import 'dart:convert';
import 'dart:io';
import 'package:enforcer/Data/userData.dart';
import '../../Api/api_provider.dart';

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
import '../../animation.dart';

import '../../test.dart';
import '../../widgets/under-development.dart';
import '../Cess/Cess.dart';
import '../Hawkers/hawkers.dart';
import '../OffLoading/off_loading.dart';
import '../Parking/parking.dart';
import '../MarketEntry/market_entry.dart';
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

class _DashboardState extends State<Dashboard> with SingleTickerProviderStateMixin {

  bool isDownloading = false;
  bool isDoneDownloading = false;
  double? percentage = 0;

  Future<void> _checkVersionAndLoadDetails() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = packageInfo.version;
    print("The package version is: ${currentVersion}");

    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero,
      ));

      bool updated = await remoteConfig.fetchAndActivate();
      print("Fetch and activate status: $updated");

      await remoteConfig.fetchAndActivate();

      String latestVersion = remoteConfig.getString('latest_playstore_version');
      print("The latest version from Remote Config is: ${latestVersion}");

      if (latestVersion.isNotEmpty && currentVersion != latestVersion) {
        if (mounted) {
          _showUpdatePrompt();
        }
      }
    } catch (e) {
      print('Error fetching latest version: $e');
    }
  }

  Future<void> fetchModuleVisibility() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      String raw = remoteConfig.getString('module_visibility');
      if (raw.isNotEmpty) {
        final Map<String, dynamic> decoded = jsonDecode(raw);
        setState(() {
          moduleVisibility = decoded.map((k, v) => MapEntry(k, v as bool));
        });
        print("Module visibility loaded: $moduleVisibility");
      }
    } catch (e) {
      print('Error fetching module visibility: $e');
    }
  }

  void _showUpdatePrompt() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final imageDimension = screenWidth / 3.3;
    final fontSize = screenWidth / 28.0;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          surfaceTintColor: Colors.white,
          content: Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 5),
                Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
                  child: Image.asset(
                    "assets/images/update.png",
                    width: MediaQuery.of(context).size.width,
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
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    minimumSize: MaterialStateProperty.all<Size>(const Size(double.infinity, 60)),
                  ),
                  onPressed: () {
                    _launchPlatformm();
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

  void _launchPlatformm() async {
    String url;

    if (Platform.isAndroid) {
      url = 'https://play.google.com/store/apps/details?id=com.mcp.enforcer';
    } else if (Platform.isIOS) {
      url = 'https://apps.apple.com/app/id6636477035';
    } else {
      throw UnsupportedError('Unsupported platform');
    }

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
    _checkVersionAndLoadDetails().then((_) {
      fetchModuleVisibility();
    });
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
      firstName = userData.firstName ?? '';
      lastName = userData.lastName ?? '';

      print("The first and last names are ${firstName} ${lastName}");
      mobile = prefs.getString(_kmobile) ?? '';
      token = prefs.getString(_token) ?? '';

      if (firstName != null && firstName!.isNotEmpty && lastName != null &&
          lastName!.isNotEmpty) {
        initials = '${firstName![0]}${lastName![0]}'.toUpperCase();
      } else {
        initials = 'NA';
      }
    });
    
    await _checkAllPermissions();
  }

  List imgsrc = [
    'assets/images/parking.png',
    'assets/images/PSV.png',
    'assets/images/cess.png',
    'assets/images/warning.png',
    'assets/images/meat.png',
    'assets/images/unload.png',
    'assets/images/market-entry.png',
  ];

  List title = [
    'PARKING',
    'PSV',
    'CESS',
    'TRAFFIC OFFENCE',
    'HAWKERS',
    'OFF LOADING',
    'MARKET ENTRY',
  ];

  List delay = [
    2.0,
    1.7,
    1.2,
    0.8,
    0.5,
    0.2,
    0.0,
  ];

  // Firestore — controls maintenance dialog (card shows but tapping shows dialog)
  Map<String, bool> moduleStatus = {};

  // Remote Config — controls visibility (hides card entirely when false)
  Map<String, bool> moduleVisibility = {
    'parking': true,
    'psv': true,
    'cess': true,
    'traffic offence': true,
    'hawkers': true,
    'off loading': true,
    'market entry': true,
  };

  List modules = [
    'parking',
    'psv',
    'cess',
    'traffic offence',
    'hawkers',
    'off loading',
    'market entry',
  ];

  bool isLoadingPermissions = true;
  Map<String, bool> modulePermissionsLoaded = {};

  final Map<String, String> modulePermissionKeys = {
    'parking': 'Access Parking',       
    'psv': 'Access PSV',               
    'cess': 'Access Cess',             
    'traffic offence': 'Access Traffic', 
    'hawkers': 'Access Hawkers',
    'off loading': 'Access OffLoading',
    'market entry': 'Access Toll Market',
  };

  Future<void> _checkAllPermissions() async {
    if (token == null || token!.isEmpty) {
      if (mounted) {
        setState(() { isLoadingPermissions = false; });
      }
      return;
    }
    
    if (mounted) {
      setState(() { isLoadingPermissions = true; });
    }

    Map<String, bool> localPerms = {};
    List<Future<void>> checks = [];
    
    for (String module in modules) {
       String pType = modulePermissionKeys[module] ?? 'Unknown Permission';
       checks.add(
         ApiProvider().checkPermission(permissionType: pType, token: token!).then((res) {
            localPerms[module] = res['access'] == true;
         }).catchError((e) {
            localPerms[module] = false;
         })
       );
    }
    
    await Future.wait(checks);
    
    if (mounted) {
      setState(() { 
        modulePermissionsLoaded = localPerms;
        isLoadingPermissions = false; 
      });
    }
  }

  void fetchModuleStatus() {
    FirebaseFirestore.instance.collection('demoModules').snapshots().listen((snapshot) {
      snapshot.docs.forEach((doc) {
        setState(() {
          moduleStatus[doc.id] = doc['enabled'];
          print(moduleStatus);
        });
      });
    });
  }

  DateTime nowTime = DateTime.now();
  late String todayDate;

  @override
  Widget build(BuildContext context) {

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

    // Filter indices by Remote Config and User Permissions
    List<int> visibleIndices = List.generate(title.length, (i) => i)
        .where((i) {
          String mod = modules[i].toLowerCase();
          bool isVisible = moduleVisibility[mod] != false;
          bool hasPermission = modulePermissionsLoaded[mod] == true;
          return isVisible && hasPermission;
        })
        .toList();

    return Builder(builder: (context) {
      return WillPopScope(
        onWillPop: () async {
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          return false;
        },
        child: Scaffold(
            backgroundColor: Colors.white,
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
                                bottomRight: Radius.circular(30)),
                            image: DecorationImage(
                                image: AssetImage('assets/images/msa2.jpg'), fit: BoxFit.cover)),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                  bottomRight: Radius.circular(30)),
                              gradient: LinearGradient(colors: [
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
                                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Builder(
                                            builder: (context) {
                                              return GestureDetector(
                                                onTap: () {
                                                  AppDrawer.of(context)?.toggle();
                                                },
                                                child: IconButton(
                                                  icon: SvgPicture.asset(
                                                    'assets/images/menu (3).svg',
                                                    height: 20.0,
                                                    width: 20.0,
                                                    color: Colors.white,
                                                  ),
                                                  onPressed: () {
                                                    AppDrawer.of(context)?.toggle();
                                                  },
                                                ),
                                              );
                                            }
                                        ),

                                        Container(
                                          height: screenWidth * 0.165,
                                          decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.white.withOpacity(0.5),
                                                spreadRadius: 5,
                                                blurRadius: 90,
                                                offset: Offset(0, 0),
                                              ),
                                            ],
                                          ),
                                          child: Image.asset(
                                            'assets/images/mcg-logoo.png',
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
                                                initials!,
                                                style: GoogleFonts.manrope(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
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
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Center(
                                                child: Text(
                                                  textAlign: TextAlign.center,
                                                  "County Government of Mombasa",
                                                  style: GoogleFonts.manrope(
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
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: fontSize * 1.2,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 21),
                                              Container(
                                                color: Colors.white.withOpacity(0.7),
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
                                                        "Welcome, ${firstName} 👋",
                                                        style: GoogleFonts.manrope(
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: fontSize * 1.1,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: screenWidth * 0.03,),
                                                    Expanded(
                                                      child: Row(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          Icon(
                                                            Icons.calendar_today,
                                                            color: Colors.white.withOpacity(0.5),
                                                            size: 15,
                                                          ),
                                                          const SizedBox(width: 8,),
                                                          Flexible(
                                                            child: Text(
                                                              todayDate,
                                                              style: GoogleFonts.manrope(
                                                                fontSize: fontSize * 1,
                                                                color: Colors.white,),
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ]),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 23,),
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
                            padding: EdgeInsets.only(left: 10.0, right: 10, top: screenHeight * 0.024),
                            child: isLoadingPermissions
                                ? Center(
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 50.0),
                                      child: CircularProgressIndicator(color: Color(0xFF3E4095)),
                                    ),
                                  )
                                : GridView.builder(
                                padding: EdgeInsets.zero,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 1.25,
                                  mainAxisSpacing: 7,
                                ),
                                shrinkWrap: true,
                                itemCount: visibleIndices.length,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final originalIndex = visibleIndices[index];
                                  return InkWell(
                                    onTap: () {
                                      String module = modules[originalIndex].toLowerCase();
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
                                        switch (originalIndex) {
                                          case 0:
                                            Navigator.push(context, MaterialPageRoute(builder: (c) => parking())).then((_) {
                                              _checkAllPermissions();
                                              fetchModuleVisibility();
                                            });
                                            break;
                                          case 1:
                                            Navigator.push(context, MaterialPageRoute(builder: (c) => psv())).then((_) {
                                              _checkAllPermissions();
                                              fetchModuleVisibility();
                                            });
                                            break;
                                          case 2:
                                            Navigator.push(context, MaterialPageRoute(builder: (c) => cess())).then((_) {
                                              _checkAllPermissions();
                                              fetchModuleVisibility();
                                            });
                                            break;
                                          case 3:
                                            Navigator.push(context, MaterialPageRoute(builder: (c) => traffic())).then((_) {
                                              _checkAllPermissions();
                                              fetchModuleVisibility();
                                            });
                                            break;
                                          case 4:
                                            Navigator.push(context, MaterialPageRoute(builder: (c) => hawkers(token: token))).then((_) {
                                              _checkAllPermissions();
                                              fetchModuleVisibility();
                                            });
                                            break;
                                          case 5:
                                            Navigator.push(context, MaterialPageRoute(builder: (c) => offBoarding(token: token))).then((_) {
                                              _checkAllPermissions();
                                              fetchModuleVisibility();
                                            });
                                            break;
                                          case 6:
                                            Navigator.push(context, MaterialPageRoute(builder: (c) => MarketEntry(token: token))).then((_) {
                                              _checkAllPermissions();
                                              fetchModuleVisibility();
                                            });
                                            break;
                                        }
                                      }
                                    },
                                    child: CardField(
                                      size,
                                      imgsrc[originalIndex],
                                      title[originalIndex],
                                      "assets/images/pattern.png",
                                      delay[originalIndex],
                                      fontSize,
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
              bottomRight: Radius.circular(30)),
          image: DecorationImage(
              image: AssetImage('assets/images/msa.png'), fit: BoxFit.cover)),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(30)),
            gradient: LinearGradient(colors: [
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
    String patternImg,
    double delay,
    double fontSize,
    ) {
  return FadeAnimation(
    delay: delay,
    child: Container(
      margin: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: DecorationImage(
                image: AssetImage(patternImg),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Color(0xFF3E4095).withOpacity(0.95),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 5),
                ),
              ],
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  img,
                  width: size.width * 0.14,
                ),
                SizedBox(height: 15,),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
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