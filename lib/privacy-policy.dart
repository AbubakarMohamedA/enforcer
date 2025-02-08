import 'dart:ui';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../Api/api_provider.dart';
import '../../Models/HawkersModel/getHawkerStats.dart';
import '../../Models/HawkersModel/getLocations.dart';
import '../../Models/HawkersModel/getZones.dart';
import '../../Models/HawkersModel/paidHawkers.dart';
import '../../error_page.dart';

class privacyPolicy extends StatefulWidget {


  @override
  State<privacyPolicy> createState() => privacyPolicyState();
}

class privacyPolicyState extends State<privacyPolicy> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    _controller = WebViewController.fromPlatformCreationParams(
        const PlatformWebViewControllerCreationParams())
      ..setNavigationDelegate(NavigationDelegate(
          onPageFinished: (_) => setState(() {
            _loading = false;
          })))
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white) // Set the WebView background color to white
      ..loadRequest(Uri.parse("https://eportal.mombasa.go.ke/policy.html"));
    super.initState();
  }




  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final imageDimension = screenWidth / 3.3;
    final fontSize = screenWidth / 28.0;

    String formatNumb(String numb) {
      final NumberFormat formatter = NumberFormat("#,##0.00", "en_US");
      double numberr = double.parse(numb);
      return formatter.format(numberr);
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        toolbarHeight: 80,
        title: Text(
          "Privacy Policy",
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
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        // padding: EdgeInsets.only(
        //     bottom: MediaQuery.of(context).viewInsets.bottom),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: SafeArea(
          child: Stack(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 20),
              child: WebViewWidget(controller: _controller),
            ),
            if (_loading) Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(child:  SpinKitSpinningLines(
                  color:Color(0XFF3E4095),
                  size: 50,
                ),),
                SizedBox(height: 30,),
                Text(
                  'Loading...',
                  style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                      fontSize: 17),
                ),
              ],
            )
          ]),
        ),
      ),
    );
  }


}

