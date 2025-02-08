import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import 'Screens/Authentication/loginScreen.dart';
import 'Screens/Dashboard/dashboard.dart';
import 'Screens/appDrawer.dart';
import 'Data/userData.dart';



class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});


  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    _navigateToHomePage();
    super.initState();
  }
  // This widget is the root of your application.

  final _token = 'token_preference';
  String? token;
  void _navigateToHomePage() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String? token = prefs.getString(_token);

    await userData.loadFromPreferences();

    Timer(
      const Duration(seconds: 2),
        (){
          if (token != null) {
            // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Dashboard(),),);
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AppDrawer(child:Dashboard()),),);
          }else{
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => LoginScreen(

                ),
              ),
            );
          }
        }

    );
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      // backgroundColor: Color(0xFF20A567), // Use the color code
      body: Stack(
        children: [
          Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Image.asset("assets/images/splash.png", fit: BoxFit.cover,)),
          Positioned(
            bottom: 70,
            child: Container(
              width: size.width,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 50,),
                    // Center(child: Image.asset("assets/Logo.png")),
                    // SizedBox(height: 20,),
                    // Center(child: Image.asset("assets/Logo.png", height: 50,)),

                    Center(
                      child: SizedBox(
                          height: size.height * 0.15,
                          child: Image.asset('assets/images/mcg-logoo.png', width: 100,height: 70,)
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.01,
                    ),
                    Center(
                      child: Text(
                        'Mombasa County eServices',
                        textAlign: TextAlign.end,
                        style: TextStyle(

                            fontSize: size.width * 0.050,
                            color: Colors.white,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.01,
                    ),
                    Center(
                      child: Text(
                        'Gateway to smart public services in mombasa',
                        // textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: size.width * 0.035,
                            color: Colors.white,
                            fontWeight: FontWeight.w500),
                      ),
                    ),

                    SizedBox(
                      height: size.height * 0.04,
                    ),
                    SpinKitSpinningLines(
                      // color: Colors.white,
                      color: Color(0xFF3E4095).withOpacity(0.95),
                      size: 50,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
