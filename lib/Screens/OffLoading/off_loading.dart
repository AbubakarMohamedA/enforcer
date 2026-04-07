import 'package:enforcer/Api/api_provider.dart';
import 'package:enforcer/Screens/OffLoading/promptPayment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import 'package:shimmer/shimmer.dart';

import '../../Models/Offloading/getLastCessMadeApplication.dart';
import '../../Models/Offloading/getOffloadingStatsModel.dart';
import '../../Models/Offloading/getDailyOffloadingApplications.dart';
import '../../widgets/failed_dialog.dart';
import '../../widgets/payment_dialog.dart';
import 'off-loading-list.dart';
import 'offLoadingDetails.dart';

class offBoarding extends StatefulWidget {
  var token;
   offBoarding({
     required this.token
    });
  @override
  State<offBoarding> createState() => _offBoardingState();
}

class _offBoardingState extends State<offBoarding> {
  late Future<GetOffLoadingStats> offLoadingStatsFuture;
  String? dailyCollections;
  String? monthlyCollections;
  String? dailyOffloads;


  late Future<Map<String, dynamic>> permissionsFuture;

  @override
  void initState() {
    super.initState();
    permissionsFuture = ApiProvider().checkPermission(permissionType: 'Access OffLoading', token: widget.token);
    offLoadingStatsFuture =  ApiProvider().getOffLoadingStats(token: widget.token);
  }

  final _formKey = GlobalKey<FormState>();
  TextEditingController _plateController = TextEditingController();
  bool  showcarPaid= false;
  bool isLoading = false;
  bool hasNoRecords = false;


  GetVehicleLastPaymentCess? lastApplication;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final imageDimension = screenWidth / 3.3;
    final fontSize = screenWidth / 28.0;

    DateTime? createdat;
    String formattedDate = '';

    String formatNumb(String numb) {
      final NumberFormat formatter = NumberFormat("#,##0.00", "en_US");
      double numberr = double.parse(numb);
      return formatter.format(numberr);
    }

    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        toolbarHeight: 80,
        title: Text(
          "Offloading",
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
      body:
      FutureBuilder(future: permissionsFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print(snapshot.error);
              return Center(
                  child: FailedDialog(
                    message: snapshot.error.toString(),)
              );
            } else if (!snapshot.hasData ||
                snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Verifying Permission',
                      style: GoogleFonts.manrope(
                          fontSize: fontSize * 1.2,
                          color: Color(0XFF3E4095),
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    CircularProgressIndicator(color: Color(0XFF3E4095)),
                  ],
                ),
              );

            } else {
              Map<String, dynamic>? permissionResult = snapshot.data;
              if(permissionResult!['access'] == true){
                return  Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: ScrollConfiguration(
                    behavior: ScrollBehavior().copyWith(overscroll: false),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(height: screenHeight * 0.03,),
                              Text(
                                "My statistics",
                                style: GoogleFonts.manrope(
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w800,
                                    fontSize: fontSize * 1.2,
                                    color: Color(0XFF3E4095)),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              FutureBuilder(
                                  future: offLoadingStatsFuture,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError) {
                                      print(snapshot.error);
                                      return IntrinsicHeight(
                                        // height: 150,
                                        // height: screenHeight * 0.19,
                                        // color: Colors.green,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: screenWidth * 0.34,
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 10.0),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Column(
                                                      children: [
                                                        Container(
                                                          decoration: BoxDecoration(
                                                            shape: BoxShape.circle,
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors.black.withOpacity(0.5),
                                                                spreadRadius: 1,
                                                                blurRadius: 3,
                                                                offset: Offset(0, 3), // changes position of shadow
                                                              ),
                                                            ],
                                                          ),
                                                          child: Center(
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                shape: BoxShape.circle,
                                                                border: Border.all(
                                                                  color: Color(0XFF3E4095), // Purple color for the border
                                                                  width: 1.6, // Border width
                                                                ),
                                                              ),
                                                              child: Center(
                                                                child: CircleAvatar(
                                                                  radius: 38, // Adjust the radius as needed
                                                                  backgroundColor: Colors.white,
                                                                  child: Image.asset(
                                                                    'assets/images/unload.png', // Your SVG asset path
                                                                    width: screenWidth * 0.12, // Adjust the width and height as needed
                                                                    height: screenWidth * 0.12,
                                                                    // width: 45;
                                                                    color: Color(0XFF3E4095), // Purple color for the border

                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(height: 9,),
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text("Daily Offloads",
                                                              style: GoogleFonts.manrope(
                                                                  fontWeight: FontWeight.w500,
                                                                  // fontSize: 14,
                                                                  fontSize: fontSize *1,
                                                                  color: Color(0XFF3E4095)),
                                                            ),
                                                            SizedBox(height: screenHeight* 0.007,),
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                  color: Colors.redAccent,
                                                                  borderRadius: BorderRadius.circular(10)
                                                              ),
                                                              child:  Padding(
                                                                padding: const EdgeInsets.all(8.0),
                                                                child: Text("An Error Occured",
                                                                  style: GoogleFonts.manrope(
                                                                      fontWeight: FontWeight.w500,
                                                                      fontSize: fontSize * 0.7,
                                                                      // color: Color(0XFF3E4095)),
                                                                      color: Colors.white),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              child: VerticalDivider(

                                                color: Color(
                                                    0XFF3E4095), // You can change the color to match your design
                                                thickness: 2.6, // You can adjust the thickness of the line
                                                width: 20, // This is the width of the space the divider takes
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Row(
                                                    children: [
                                                      SvgPicture.asset("assets/images/money.svg",
                                                        width:screenWidth*0.09,
                                                        // height:35,
                                                        height:screenWidth*0.09,
                                                        color:  Color(0XFF3E4095),
                                                      ),
                                                      SizedBox(width: 5,),
                                                      Flexible(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text("Daily Offloading Collection",
                                                              style: GoogleFonts.manrope(
                                                                  fontWeight: FontWeight.w500,
                                                                  // fontSize: 12,
                                                                  fontSize: fontSize *0.9,
                                                                  color: Color(0XFF3E4095)),
                                                            ),
                                                            SizedBox(height: screenHeight* 0.006,),
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                  color: Colors.redAccent,
                                                                  borderRadius: BorderRadius.circular(10)
                                                              ),
                                                              child:  Padding(
                                                                padding: const EdgeInsets.all(8.0),
                                                                child: Text("An Error Occured",
                                                                  style: GoogleFonts.manrope(
                                                                      fontWeight: FontWeight.w500,
                                                                      fontSize: fontSize * 0.7,
                                                                      // color: Color(0XFF3E4095)),
                                                                      color: Colors.white),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  // Spacer(),
                                                  SizedBox(height: screenHeight* 0.01,),

                                                  Divider(
                                                    color: Color(
                                                        0XFF3E4095), // You can change the color to match your design
                                                    thickness:
                                                    2.6, // You can adjust the thickness of the line
                                                  ),
                                                  // Spacer(),
                                                  SizedBox(height: screenHeight* 0.01,),
                                                  Row(
                                                    children: [
                                                      SvgPicture.asset("assets/images/money.svg",
                                                        width:screenWidth*0.09,
                                                        // height:35,
                                                        height:screenWidth*0.09,
                                                        color:  Color(0XFF3E4095),
                                                      ),
                                                      SizedBox(width: 5,),
                                                      Flexible(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text("Monthly Offloading Collection",
                                                              style: GoogleFonts.manrope(
                                                                  fontWeight: FontWeight.w500,
                                                                  // fontSize: 12,
                                                                  fontSize: fontSize *0.9,
                                                                  color: Color(0XFF3E4095)),
                                                            ),
                                                            SizedBox(height: screenHeight* 0.006,),
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                  color: Colors.redAccent,
                                                                  borderRadius: BorderRadius.circular(10)
                                                              ),
                                                              child:  Padding(
                                                                padding: const EdgeInsets.all(8.0),
                                                                child: Text("An Error Occured",
                                                                  style: GoogleFonts.manrope(
                                                                      fontWeight: FontWeight.w500,
                                                                      fontSize: fontSize * 0.7,
                                                                      // color: Color(0XFF3E4095)),
                                                                      color: Colors.white),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    } else if (!snapshot.hasData ||
                                        snapshot.connectionState == ConnectionState.waiting) {
                                      return IntrinsicHeight(
                                        // height: 150,
                                        // height: screenHeight * 0.19,
                                        // color: Colors.green,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: screenWidth * 0.34,
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 10.0),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Column(
                                                      children: [
                                                        Container(
                                                          decoration: BoxDecoration(
                                                            shape: BoxShape.circle,
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors.black.withOpacity(0.5),
                                                                spreadRadius: 1,
                                                                blurRadius: 3,
                                                                offset: Offset(0, 3), // changes position of shadow
                                                              ),
                                                            ],
                                                          ),
                                                          child: Center(
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                shape: BoxShape.circle,
                                                                border: Border.all(
                                                                  color: Color(0XFF3E4095), // Purple color for the border
                                                                  width: 1.6, // Border width
                                                                ),
                                                              ),
                                                              child: Center(
                                                                child: CircleAvatar(
                                                                  radius: 38, // Adjust the radius as needed
                                                                  backgroundColor: Colors.white,
                                                                  child: Image.asset(
                                                                    'assets/images/unload.png', // Your SVG asset path
                                                                    width: screenWidth * 0.12, // Adjust the width and height as needed
                                                                    height: screenWidth * 0.12,
                                                                    // width: 45;
                                                                    color: Color(0XFF3E4095), // Purple color for the border

                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(height: 9,),
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text("Daily Offloads",
                                                              style: GoogleFonts.manrope(
                                                                  fontWeight: FontWeight.w500,
                                                                  // fontSize: 14,
                                                                  fontSize: fontSize *1,
                                                                  color: Color(0XFF3E4095)),
                                                            ),
                                                            SizedBox(height: screenHeight* 0.007,),
                                                            Container(
                                                              // margin: EdgeInsets.only(top: 20,left: 10,right: 10),
                                                              height: 20,
                                                              width: screenWidth,
                                                              child: Shimmer.fromColors(
                                                                baseColor: const Color(0xFF2E6BC4).withOpacity(0.3),
                                                                highlightColor: const Color(0xFF2E6BC4).withOpacity(0.1),
                                                                child: Container(
                                                                  // width: double.infinity,
                                                                  height: 10,
                                                                  decoration: BoxDecoration(
                                                                      color: const Color(0xFF2E6BC4).withOpacity(0.5),
                                                                      borderRadius: BorderRadius.circular(10)),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              child: VerticalDivider(

                                                color: Color(
                                                    0XFF3E4095), // You can change the color to match your design
                                                thickness: 2.6, // You can adjust the thickness of the line
                                                width: 20, // This is the width of the space the divider takes
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Row(
                                                    children: [
                                                      SvgPicture.asset("assets/images/money.svg",
                                                        width:screenWidth*0.09,
                                                        // height:35,
                                                        height:screenWidth*0.09,
                                                        color:  Color(0XFF3E4095),
                                                      ),
                                                      SizedBox(width: 5,),
                                                      Flexible(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text("Daily Offloading Collection",
                                                              style: GoogleFonts.manrope(
                                                                  fontWeight: FontWeight.w500,
                                                                  // fontSize: 12,
                                                                  fontSize: fontSize *0.9,
                                                                  color: Color(0XFF3E4095)),
                                                            ),
                                                            SizedBox(height: screenHeight* 0.006,),
                                                            Container(
                                                              // margin: EdgeInsets.only(top: 20,left: 10,right: 10),
                                                              height: 20,
                                                              width: screenWidth,
                                                              child: Shimmer.fromColors(
                                                                baseColor: const Color(0xFF2E6BC4).withOpacity(0.3),
                                                                highlightColor: const Color(0xFF2E6BC4).withOpacity(0.1),
                                                                child: Container(
                                                                  // width: double.infinity,
                                                                  height: 10,
                                                                  decoration: BoxDecoration(
                                                                      color: const Color(0xFF2E6BC4).withOpacity(0.5),
                                                                      borderRadius: BorderRadius.circular(10)),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  // Spacer(),
                                                  SizedBox(height: screenHeight* 0.01,),

                                                  Divider(
                                                    color: Color(
                                                        0XFF3E4095), // You can change the color to match your design
                                                    thickness:
                                                    2.6, // You can adjust the thickness of the line
                                                  ),
                                                  // Spacer(),
                                                  SizedBox(height: screenHeight* 0.01,),
                                                  Row(
                                                    children: [
                                                      SvgPicture.asset("assets/images/money.svg",
                                                        width:screenWidth*0.09,
                                                        // height:35,
                                                        height:screenWidth*0.09,
                                                        color:  Color(0XFF3E4095),
                                                      ),
                                                      SizedBox(width: 5,),
                                                      Flexible(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text("Monthly Offloading Collection",
                                                              style: GoogleFonts.manrope(
                                                                  fontWeight: FontWeight.w500,
                                                                  // fontSize: 12,
                                                                  fontSize: fontSize *0.9,
                                                                  color: Color(0XFF3E4095)),
                                                            ),
                                                            SizedBox(height: screenHeight* 0.006,),
                                                            Container(
                                                              // margin: EdgeInsets.only(top: 20,left: 10,right: 10),
                                                              height: 20,
                                                              width: screenWidth,
                                                              child: Shimmer.fromColors(
                                                                baseColor: const Color(0xFF2E6BC4).withOpacity(0.3),
                                                                highlightColor: const Color(0xFF2E6BC4).withOpacity(0.1),
                                                                child: Container(
                                                                  // width: double.infinity,
                                                                  height: 10,
                                                                  decoration: BoxDecoration(
                                                                      color: const Color(0xFF2E6BC4).withOpacity(0.5),
                                                                      borderRadius: BorderRadius.circular(10)),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    } else {
                                      dailyOffloads = snapshot.data!.data!.dailyOffloadingCount.toString();
                                      dailyCollections = snapshot.data!.data!.dailyCollection.toString();
                                      monthlyCollections = snapshot.data!.data!.monthlyCollection.toString();

                                      String dailyAmountPaid = formatNumb((dailyCollections ?? 0.0).toString());
                                      String monthlyAmountPaid = formatNumb((monthlyCollections ?? 0.0).toString());
                                      return IntrinsicHeight(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: screenWidth * 0.34,
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 10.0),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Column(
                                                      children: [
                                                        GestureDetector(
                                                          onTap: (){
                                                            FocusScope.of(context).unfocus();
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (c) => offLoadingList(
                                                                      token: widget.token,
                                                                      CheckPaymentDialogCallback: CheckPaymentDialog,
                                                                    )));
                                                          },
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                              shape: BoxShape.circle,
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Colors.black.withOpacity(0.5),
                                                                  spreadRadius: 1,
                                                                  blurRadius: 3,
                                                                  offset: Offset(0, 3), // changes position of shadow
                                                                ),
                                                              ],
                                                            ),
                                                            child: Center(
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                  shape: BoxShape.circle,
                                                                  border: Border.all(
                                                                    color: Color(0XFF3E4095), // Purple color for the border
                                                                    width: 1.6, // Border width
                                                                  ),
                                                                ),
                                                                child: Center(
                                                                  child: CircleAvatar(
                                                                    radius: 38, // Adjust the radius as needed
                                                                    backgroundColor: Colors.white,
                                                                    child: Image.asset(
                                                                      'assets/images/unload.png', // Your SVG asset path
                                                                      width: screenWidth * 0.12, // Adjust the width and height as needed
                                                                      height: screenWidth * 0.12,
                                                                      // width: 45;
                                                                      color: Color(0XFF3E4095), // Purple color for the border

                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(height: 9,),
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text("Daily Offloads",
                                                              style: GoogleFonts.manrope(
                                                                  fontWeight: FontWeight.w500,
                                                                  // fontSize: 14,
                                                                  fontSize: fontSize *1,
                                                                  color: Color(0XFF3E4095)),
                                                            ),
                                                            SizedBox(height: screenHeight* 0.007,),
                                                            Text("${dailyOffloads}",
                                                              style: GoogleFonts.manrope(
                                                                  fontWeight: FontWeight.w600,
                                                                  // fontSize: 16,
                                                                  fontSize: fontSize *1.1,
                                                                  color: Color(0XFF3E4095)),
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              child: VerticalDivider(

                                                color: Color(
                                                    0XFF3E4095), // You can change the color to match your design
                                                thickness: 2.6, // You can adjust the thickness of the line
                                                width: 20, // This is the width of the space the divider takes
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Row(
                                                    children: [
                                                      SvgPicture.asset("assets/images/money.svg",
                                                        width:screenWidth*0.09,
                                                        // height:35,
                                                        height:screenWidth*0.09,
                                                        color:  Color(0XFF3E4095),
                                                      ),
                                                      SizedBox(width: 5,),
                                                      Flexible(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text("Daily Offloading Collection",
                                                              style: GoogleFonts.manrope(
                                                                  fontWeight: FontWeight.w500,
                                                                  // fontSize: 12,
                                                                  fontSize: fontSize *0.9,
                                                                  color: Color(0XFF3E4095)),
                                                            ),
                                                            SizedBox(height: screenHeight* 0.006,),
                                                            Text('Kes: ${dailyAmountPaid}',
                                                              textAlign: TextAlign.center,
                                                              style: GoogleFonts.manrope(
                                                                  fontWeight: FontWeight.w700,
                                                                  // fontSize: 13,
                                                                  fontSize: fontSize *0.9,
                                                                  color: Color(0XFF3E4095)),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  // Spacer(),
                                                  SizedBox(height: screenHeight* 0.01,),

                                                  Divider(
                                                    color: Color(
                                                        0XFF3E4095), // You can change the color to match your design
                                                    thickness:
                                                    2.6, // You can adjust the thickness of the line
                                                  ),
                                                  // Spacer(),
                                                  SizedBox(height: screenHeight* 0.01,),
                                                  Row(
                                                    children: [
                                                      SvgPicture.asset("assets/images/money.svg",
                                                        width:screenWidth*0.09,
                                                        // height:35,
                                                        height:screenWidth*0.09,
                                                        color:  Color(0XFF3E4095),
                                                      ),
                                                      SizedBox(width: 5,),
                                                      Flexible(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text("Monthly Offloading Collection",
                                                              style: GoogleFonts.manrope(
                                                                  fontWeight: FontWeight.w500,
                                                                  // fontSize: 12,
                                                                  fontSize: fontSize *0.9,
                                                                  color: Color(0XFF3E4095)),
                                                            ),
                                                            SizedBox(height: screenHeight* 0.006,),
                                                            Text('Kes: ${monthlyAmountPaid}',
                                                              textAlign: TextAlign.center,
                                                              style: GoogleFonts.manrope(
                                                                  fontWeight: FontWeight.w700,
                                                                  // fontSize: 13,
                                                                  fontSize: fontSize *0.9,
                                                                  color: Color(0XFF3E4095)),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    }
                                  }),
                              SizedBox(
                                height: 30,
                              ),
                              Row(
                                children: [
                                  Icon(Icons.search_off_outlined,color: Color(0XFF3E4095),),
                                  Flexible(
                                    child: Text(
                                      "Check if Vehicle has paid Off Loading Fees",
                                      style: GoogleFonts.manrope(
                                          decoration: TextDecoration.underline,
                                          fontWeight: FontWeight.w700,
                                          fontSize: fontSize * 1.1,
                                          color: Color(0XFF3E4095)),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [

                                  TextFormField(
                                    controller: _plateController,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    decoration: InputDecoration(
                                      hintText: 'Enter Car Plate Number',
                                      hintStyle: GoogleFonts.manrope(fontSize: fontSize),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: const BorderSide(color: Color(0xFF46B1FD)),
                                      ),

                                    ),
                                    validator: (value){
                                      const pattern = r'^[a-zA-Z]{3}\d{3}[a-zA-Z]$';
                                      final regExp = RegExp(pattern);
                                      if (value!.isEmpty) {
                                        return 'Enter Number Plate';
                                      }
                                      if (!regExp.hasMatch(value)) {
                                        return 'Enter Valid Number Plate';
                                      } else {
                                        return null;
                                      }
                                    },
                                  ),
                                  showcarPaid ? Container()
                                      :   const SizedBox(height: 17),
                                  showcarPaid ? Container()
                                      : hasNoRecords ? Container() :
                                  Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          spreadRadius: 0.5,
                                          blurRadius: 5,
                                          offset: Offset(0, 5), // changes position of shadow
                                        ),
                                      ],
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child:ElevatedButton(
                                      onPressed: () async {
                                        FocusScope.of(context).unfocus();
                                        if(_formKey.currentState!.validate()){
                                          setState(() {
                                            // showcarPaid = true;
                                            isLoading = true;
                                          });

                                          try{
                                            lastApplication = await ApiProvider().getLastpaymentCess(token: widget.token, plateNumber: _plateController.text);

                                            if(lastApplication!.status == "success"){
                                              if(lastApplication?.data == null){
                                                setState(() {
                                                  isLoading = false;
                                                  hasNoRecords = true;
                                                });
                                                // await showDialog(
                                                //   context: context,
                                                //   builder: (ctx) {
                                                //     return FailedDialog(
                                                //       message: lastApplication!.message.toString(),
                                                //     );
                                                //   },
                                                // );
                                              }else{
                                                setState(() {
                                                  showcarPaid = true;
                                                  isLoading = false;
                                                  try {
                                                    formattedDate = DateFormat('yyyy-MM-dd').format(lastApplication!.data!.createdDate!);
                                                    print(formattedDate);
                                                  } catch (e) {
                                                    print('Error parsing date: $e');
                                                  }
                                                });
                                              }
                                            }else{
                                              setState(() {
                                                isLoading = false;
                                              });
                                              await showDialog(
                                                context: context,
                                                builder: (ctx) {
                                                  return FailedDialog(
                                                    message: lastApplication!.message.toString(),
                                                  );
                                                },
                                              );
                                            }
                                          }catch(e){
                                            setState(() {
                                              isLoading = false;
                                            });
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
                                        'Check Status',
                                        style: GoogleFonts.manrope(
                                          fontSize: fontSize * 1.2,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF3E4095),
                                        ),
                                      ),
                                    ),

                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),

                              // IF CAR HAS MADE A CESS APPLICATION BEFORE
                              showcarPaid ?
                              Text("Last Application Made: ",
                                style: GoogleFonts.manrope(
                                    fontWeight: FontWeight.w500,
                                    // fontSize: 14,
                                    fontSize: fontSize *1,
                                    color: Color(0XFF3E4095)),
                              ) :Container(),
                              showcarPaid ?
                              SizedBox(height: 15,)
                                  :Container(),
                              showcarPaid ?
                              InkWell(
                                onTap: (){
                                  FocusScope.of(context).unfocus();
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (c) =>
                                              offBoardingDetails(
                                                lastApplication: lastApplication,
                                                token: widget.token,
                                                offLoadingCallback: OffloadingCallback,
                                                CheckPaymentDialogCallback: CheckPaymentDialog,
                                              )));
                                },
                                child: Card(
                                  elevation: 7,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Column(
                                                // crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Application No:',
                                                    style: GoogleFonts.manrope(
                                                        color:Colors.grey.withOpacity(0.7),
                                                        fontSize: fontSize * 1.05
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                      "#${lastApplication!.data!.applicationId.toString()}",
                                                      style: GoogleFonts.manrope(
                                                          fontSize: fontSize * 1
                                                      )
                                                  )
                                                ],
                                              ),

                                              Spacer(),
                                              Container(height: 30, width: 1, color: Colors.black54),

                                              Spacer(),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                // mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Application date',
                                                    style: GoogleFonts.manrope(
                                                        color:Colors.grey.withOpacity(0.7),
                                                        fontSize: fontSize * 1.05
                                                    ),
                                                  ),
                                                  SizedBox(height: 5,),
                                                  Text(
                                                      DateFormat('yyyy-MM-dd').format(lastApplication!.data!.createdDate!),
                                                      textAlign: TextAlign.end,
                                                      // style: TextStyle(fontSize: 12),
                                                      style: GoogleFonts.manrope(
                                                          fontSize: fontSize * 1
                                                      )
                                                  ),
                                                  SizedBox(
                                                    height: 13,
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        // height: 15,
                                                        // width: 15,
                                                        // padding: const EdgeInsets.all(3),
                                                        height:fontSize * 1.3,
                                                        width: fontSize * 1.3,
                                                        padding: const EdgeInsets.all(4),
                                                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                                                        child: SvgPicture.asset('assets/images/redpointer.svg'),
                                                      ),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text(
                                                        lastApplication!.data!.goodsOrigin.toString(),
                                                        style: GoogleFonts.manrope(
                                                            fontSize: fontSize * 1
                                                        ),
                                                      ),
                                                    ],
                                                  ),

                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 8),
                                                    child: Align(
                                                      alignment: Alignment.centerLeft,
                                                      child: SizedBox(
                                                        height: 25,
                                                        child: SvgPicture.asset('assets/images/threedots.svg'),
                                                      ),
                                                    ),
                                                  ),

                                                  Row(
                                                    children: [
                                                      Container(
                                                        height:fontSize * 1.3,
                                                        width: fontSize * 1.3,
                                                        padding: const EdgeInsets.all(4),
                                                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.green),
                                                        child: SvgPicture.asset('assets/images/greenpointer.svg'),
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      SizedBox(
                                                        width: size.width * 0.4,
                                                        child: Text(
                                                          lastApplication!.data!.goodsDestination.toString(),
                                                          style: GoogleFonts.manrope(

                                                              fontSize: fontSize * 1
                                                          ),
                                                        ),
                                                      ),

                                                    ],
                                                  ),
                                                ],
                                              ),
                                              Spacer(),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    'Plate No:',
                                                    style: GoogleFonts.manrope(
                                                        color:Colors.grey.withOpacity(0.7),
                                                        fontSize: fontSize * 1.05
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                      lastApplication!.data!.plateNo.toString(),
                                                      style: GoogleFonts.manrope(
                                                          fontSize: fontSize * 1
                                                      )
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 15),
                                          Row(
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Amount:',
                                                    style: GoogleFonts.manrope(
                                                        color:Colors.grey.withOpacity(0.7),
                                                        fontSize: fontSize * 1.05
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    'Kes ${lastApplication!.data!.receiptTotal}',
                                                    style: GoogleFonts.manrope(
                                                        fontSize: fontSize * 1
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Spacer(),
                                              Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(8),
                                                  // color: Colors.green,
                                                  color: lastApplication!.data!.status == "Closed" ? Colors.black : lastApplication!.data!.status == "Open" ? Colors.green : Color(0xFFFF8919),
                                                ),
                                                child: Padding(
                                                  padding:  EdgeInsets.only(top: 6.0,bottom: 6.0,right: 10,left: 10),
                                                  child: Text(
                                                    // "APPROVED",
                                                    lastApplication!.data!.status.toString(),
                                                    style: GoogleFonts.manrope(
                                                        color: Colors.white,
                                                        fontSize: fontSize * 0.85
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // Icon(Icons.remove_red_eye,color: Colors.lightBlue.withOpacity(0.6),size: fontSize* 2,),
                                            ],
                                          ),
                                          SizedBox(height: 20),
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
                                                    onPressed: () async{
                                                      FocusScope.of(context).unfocus();
                                                      setState(() {
                                                        showcarPaid = false;
                                                        _plateController.clear();
                                                        lastApplication = null;
                                                        hasNoRecords = false;
                                                      });
                                                    },
                                                    style: ButtonStyle(
                                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                        RoundedRectangleBorder(
                                                          borderRadius:
                                                          BorderRadius.circular(8.0), // Set circular border radius
                                                        ),
                                                      ),
                                                      backgroundColor:
                                                      MaterialStateProperty.all<Color>( Color(0XFF3E4095),),
                                                      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                                      minimumSize: MaterialStateProperty.all<Size>(
                                                        const Size(double.infinity, 65),
                                                      ),
                                                    ),
                                                    child:  Text(
                                                      'Check Other Vehicle',
                                                      textAlign: TextAlign.center,
                                                      style: GoogleFonts.manrope(
                                                        fontSize: fontSize * 1,
                                                        fontWeight: FontWeight.w500,
                                                        color: Color(0xFFFFCC2A),
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
                                                    onPressed: () async{
                                                      FocusScope.of(context).unfocus();
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (c) =>
                                                                  promptOffLoadingPayment(
                                                                    token: widget.token,
                                                                    CheckPaymentDialogCallback: CheckPaymentDialog,
                                                                    capturedPlate: _plateController.text,
                                                                    capturedOrigin: lastApplication?.data?.goodsOrigin,
                                                                    capturedClientName: lastApplication?.data?.citizenName,
                                                                    capturedVehicleId: lastApplication?.data?.vehicleId,
                                                                    capturedPhone: lastApplication?.data?.citizenMobile,
                                                                    capturedApplicationId: lastApplication?.data?.applicationId,
                                                                  )));
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
                                                        const Size(double.infinity, 65),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      'Prompt Payment',
                                                      textAlign: TextAlign.center,
                                                      style: GoogleFonts.manrope(
                                                        fontSize: fontSize * 1,
                                                        fontWeight: FontWeight.w500,
                                                        color: Color(0xFF3E4095),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 15),
                                        ],
                                      )),
                                ),
                              ):
                              Container(),

                              //  IF A CAR HAS NEVER MADE A CESS APPLICATION

                              hasNoRecords ?
                              Card(
                                elevation: 7,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child:Column(
                                      // crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Lottie.asset(
                                          'assets/lotti/error.json',
                                          repeat: false,
                                          width: 100,
                                          height: 100,
                                        ),
                                        const SizedBox(
                                          height: 25,
                                        ),
                                        Text(
                                          "This Vehicle has no Current Cess Application.",
                                          textAlign: TextAlign.center,
                                          style:GoogleFonts.montserrat(
                                              fontWeight: FontWeight.w600,
                                              // fontSize: 18
                                              fontSize: fontSize * 1.2
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 25,
                                        ),
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
                                                  onPressed: () async{
                                                    FocusScope.of(context).unfocus();
                                                    setState(() {
                                                      showcarPaid = false;
                                                      _plateController.clear();
                                                      lastApplication = null;
                                                      hasNoRecords = false;
                                                    });
                                                  },
                                                  style: ButtonStyle(
                                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                      RoundedRectangleBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(8.0), // Set circular border radius
                                                      ),
                                                    ),
                                                    backgroundColor:
                                                    MaterialStateProperty.all<Color>( Color(0XFF3E4095),),
                                                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                                    minimumSize: MaterialStateProperty.all<Size>(
                                                      const Size(double.infinity, 65),
                                                    ),
                                                  ),
                                                  child:Text(
                                                    'Check Other Vehicle',
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.manrope(
                                                      fontSize: fontSize * 1,
                                                      fontWeight: FontWeight.w500,
                                                      color: Color(0xFFFFCC2A),
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
                                                  onPressed: () async{
                                                    FocusScope.of(context).unfocus();
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (c) =>
                                                                promptOffLoadingPayment(
                                                                  token: widget.token,
                                                                  CheckPaymentDialogCallback: CheckPaymentDialog,
                                                                  capturedPlate: _plateController.text,
                                                                  capturedClientName: null,
                                                                  capturedPhone: null,
                                                                  capturedVehicleId: null,
                                                                  capturedOrigin: null,
                                                                  capturedApplicationId: null,
                                                                )));
                                                  },
                                                  style: ButtonStyle(
                                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0), // Set circular border radius
                                                      ),
                                                    ),
                                                    backgroundColor:
                                                    MaterialStateProperty.all<Color>(Color(0xFFFFCC2A)),
                                                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                                    minimumSize: MaterialStateProperty.all<Size>(
                                                      const Size(double.infinity, 65),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    'Prompt Payment',
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.manrope(
                                                      fontSize: fontSize * 1,
                                                      fontWeight: FontWeight.w500,
                                                      color: Color(0xFF3E4095),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                      ],
                                    )),
                              ):
                              Container()
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }else{
                return FailedDialog(
                  message: permissionResult!['message'].toString(),
                );
              }

            }
          }),

    );
  }

  void OffloadingCallback() {
    setState(() {
      offLoadingStatsFuture =
          ApiProvider().getOffLoadingStats(token: widget.token);
    });
  }

  Future<void> CheckPaymentDialog({
    trackingId,
    applicationId,
    clientPhone,
    String? plateNumber,
    int promptCount = 1,
    Function(String newPhone)? resubmitCallback,
  }) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) {
        return WillPopScope(
          onWillPop: () async => false,
          child: paymentDialog(
            message: "Payment Initiated. Please wait....",
          ),
        );
      },
    );
    await _checkOffLoaidngPaymentStatusRepeatedly(
      trackingId: trackingId,
      applicationId: applicationId,
      clientPhone: clientPhone,
      plateNumber: plateNumber,
      promptCount: promptCount,
      resubmitCallback: resubmitCallback,
    );
  }

  Future<String?> _recoverApplicationId(String? plateNumber) async {
    try {
      if (plateNumber == null || plateNumber.isEmpty) return null;
      print('DEBUG: Attempting to recover applicationId for plate: $plateNumber');

      // Tier 1: Try the direct "last record" API
      try {
        GetVehicleLastPaymentCess lastApp = await ApiProvider().getLastpaymentCess(
          token: widget.token,
          plateNumber: plateNumber,
        );
        if (lastApp.status == "success" && lastApp.data != null) {
          String? recoveredId = lastApp.data?.applicationId?.toString();
          if (recoveredId != null && recoveredId != 'null' && recoveredId.isNotEmpty) {
            print('DEBUG: Recovered applicationId from last record (Tier 1): $recoveredId');
            return recoveredId;
          }
        }
      } catch (e) {
        print('DEBUG: Tier 1 recovery failed or no records: $e');
      }

      // Tier 2: Fallback to scanning the full daily applications list (Highest reliability)
      print('DEBUG: Attempting Tier 2 recovery (List scan) for plate: $plateNumber');
      GetDailyOffloadingApplications dailyApps = await ApiProvider().getDailyOffloadingApplications(
        token: widget.token,
      );

      if (dailyApps.status == "success" && dailyApps.data != null) {
        // Sort by ID descending to get the newest one first
        dailyApps.data.sort((a, b) => b.id.compareTo(a.id));

        // Find the first matching plate
        final match = dailyApps.data.firstWhereOrNull(
                (app) => app.plateNo?.toUpperCase() == plateNumber.toUpperCase()
        );

        if (match != null) {
          String recoveredId = match.id.toString();
          print('DEBUG: Recovered applicationId from list scan (Tier 2): $recoveredId');
          return recoveredId;
        }
      }
    } catch (e) {
      print('DEBUG: All recovery tiers failed: $e');
    }
    return null;
  }

  Future<void> _checkOffLoaidngPaymentStatusRepeatedly(
      {required String trackingId, String? applicationId, String? clientPhone, String? plateNumber, int promptCount = 1, Function(String newPhone)? resubmitCallback}
      ) async {
    final startTime = DateTime.now();
    const timeout = Duration(seconds: 30);
    while (DateTime.now().difference(startTime) < timeout) {
      try {
        Map<String, dynamic> checkstatus = await ApiProvider().checkOffLoadingPaymentStatus(
          token: widget.token,
          trackingId: trackingId,
        );

        if(checkstatus['status'] == "success"){
          // Attempt to recover applicationId if it was missing
          if ((applicationId == null || applicationId.toString() == 'null' || applicationId.toString().isEmpty)) {
            String? recoveredId = checkstatus['application_id']?.toString()
                ?? checkstatus['id']?.toString()
                ?? checkstatus['applicationId']?.toString();
            if (recoveredId != null && recoveredId != 'null' && recoveredId.isNotEmpty) {
              applicationId = recoveredId;
              print('DEBUG: Recovered applicationId from status check: $applicationId');
            }
          }

          if (checkstatus['data'] == "Completed") {
            setState(() {
              showcarPaid= false;
              hasNoRecords = false;
              offLoadingStatsFuture =  ApiProvider().getOffLoadingStats(token: widget.token);
            });
            Navigator.of(context).pop();
            _showSuccessDialog("Fee Payment Successfully Received");
            return;
          }

          // If status is "Failed", handle retry
          if (checkstatus['data'] == "Failed") {
            setState(()  {
              showcarPaid= false;
              hasNoRecords = false;
              offLoadingStatsFuture =  ApiProvider().getOffLoadingStats(token: widget.token);
            });
            Navigator.of(context).pop();

            // Final attempt to recover ID from latest record if still missing
            if (applicationId == null || applicationId.toString() == 'null' || applicationId.toString().isEmpty) {
              applicationId = await _recoverApplicationId(plateNumber);
            }

            print('DEBUG retry: promptCount=$promptCount applicationId=$applicationId clientPhone=$clientPhone');
            if (promptCount < 3 && clientPhone != null) {
              _showRetryPhoneDialog(applicationId?.toString() ?? '', clientPhone, promptCount, resubmitCallback: resubmitCallback);
            } else {
              _showErrorDialog(checkstatus['message'] ?? "Payment Failed");
            }
            return;
          }

          await Future.delayed(Duration(seconds: 5));
        }else{
          setState(()  {
            showcarPaid= false;
            hasNoRecords = false;
            offLoadingStatsFuture =  ApiProvider().getOffLoadingStats(token: widget.token);
          });
          Navigator.of(context).pop();

          // Final attempt to recover ID from latest record if still missing
          if (applicationId == null || applicationId.toString() == 'null' || applicationId.toString().isEmpty) {
            applicationId = await _recoverApplicationId(plateNumber);
          }

          print('DEBUG error status retry: promptCount=$promptCount applicationId=$applicationId clientPhone=$clientPhone');
          if (promptCount < 3 && clientPhone != null) {
            _showRetryPhoneDialog(applicationId?.toString() ?? '', clientPhone, promptCount, resubmitCallback: resubmitCallback);
          } else {
            _showErrorDialog(checkstatus['message']);
          }
          return;
        }
      } catch (e) {
        print('Error during status check: $e');
        Navigator.of(context).pop();

        // Final attempt to recover ID from latest record if still missing
        if (applicationId == null || applicationId.toString() == 'null' || applicationId.toString().isEmpty) {
          applicationId = await _recoverApplicationId(plateNumber);
        }

        print('DEBUG catch retry: promptCount=$promptCount applicationId=$applicationId clientPhone=$clientPhone');
        if (promptCount < 3 && clientPhone != null) {
          _showRetryPhoneDialog(applicationId?.toString() ?? '', clientPhone, promptCount, resubmitCallback: resubmitCallback);
        } else {
          _showErrorDialog(e.toString());
        }
        return;
      }
    }
    setState(() {
      showcarPaid= false;
      hasNoRecords = false;
      offLoadingStatsFuture =  ApiProvider().getOffLoadingStats(token: widget.token);
    });
    Navigator.of(context).pop();

    // Final attempt to recover ID from latest record if still missing
    if (applicationId == null || applicationId.toString() == 'null' || applicationId.toString().isEmpty) {
      applicationId = await _recoverApplicationId(plateNumber);
    }

    print('DEBUG timeout retry: promptCount=$promptCount applicationId=$applicationId clientPhone=$clientPhone');
    if (promptCount < 3 && clientPhone != null) {
      _showRetryPhoneDialog(applicationId?.toString() ?? '', clientPhone, promptCount, resubmitCallback: resubmitCallback);
    } else {
      _showErrorDialog("Connection Timed Out Without payment Confirmation");
    }
  }

  Future<void> _showRetryPhoneDialog(String applicationId, String clientPhone, int promptCount, {Function(String newPhone)? resubmitCallback}) async {
    bool _isValidNumber = true; // assume true initially or let user correct it
    String _fullPhoneNumber = clientPhone;

    bool? confirmPrompt = await showDialog<bool>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        TextEditingController phoneNumberController = TextEditingController(text: clientPhone);
        PhoneNumber _initialPhoneNumber = PhoneNumber(phoneNumber: clientPhone, isoCode: 'KE');
        double fontSize = MediaQuery.of(context).size.width / 28.0;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(child: Text("Confirm Phone Number", style: GoogleFonts.manrope(fontSize: fontSize * 1.2, fontWeight: FontWeight.w600))),
                  SizedBox(height: 12),
                  Center(child: Text("Please confirm or edit the client's phone number:", style: GoogleFonts.manrope(fontSize: fontSize * 1))),
                  SizedBox(height: 15),
                  InternationalPhoneNumberInput(
                    countries: ["KE"],
                    onInputChanged: (PhoneNumber number) {
                      _fullPhoneNumber = number.phoneNumber ?? '';
                    },
                    onInputValidated: (isValid) {
                      setStateDialog(() {
                        _isValidNumber = isValid;
                      });
                    },
                    textStyle: GoogleFonts.manrope(),
                    selectorButtonOnErrorPadding: 2,
                    selectorConfig: SelectorConfig(
                      selectorType: PhoneInputSelectorType.DROPDOWN,
                      setSelectorButtonAsPrefixIcon: true,
                      trailingSpace: true,
                      useEmoji: true,
                      leadingPadding: 20,
                    ),
                    ignoreBlank: false,
                    autoValidateMode: AutovalidateMode.onUserInteraction,
                    spaceBetweenSelectorAndTextField: 25,
                    selectorTextStyle: GoogleFonts.manrope(),
                    initialValue: _initialPhoneNumber,
                    textFieldController: phoneNumberController,
                    formatInput: true,
                    errorMessage: 'Please enter a valid phone number',
                    inputDecoration: InputDecoration(
                      prefixIconColor: Colors.black38,
                      hintStyle: GoogleFonts.manrope(fontSize: fontSize),
                      hintText: '712-256-408',
                      alignLabelWithHint: false,
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Color(0xFF46B1FD))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Color(0xFF46B1FD))),
                    ),
                    keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
                    inputBorder: OutlineInputBorder(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: TextButton.styleFrom(backgroundColor: Colors.red, padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0)),
                  child: Text("Cancel", style: GoogleFonts.montserrat(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w400)),
                ),
                TextButton(
                  onPressed: () {
                    if (_isValidNumber) {
                      Navigator.of(context).pop(true);
                    } else {
                       Get.snackbar('Oops', 'Invalid Phone Number', backgroundColor: Colors.redAccent.withOpacity(0.7), colorText: Colors.white, snackPosition: SnackPosition.TOP, duration: Duration(seconds: 2), margin: EdgeInsets.only(left: 16.0, right: 16), borderRadius: 10.0);
                    }
                  },
                  style: TextButton.styleFrom(backgroundColor: Colors.green, padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0)),
                  child: Text("Prompt", style: GoogleFonts.montserrat(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w400)),
                ),
              ],
            );
          }
        );
      }
    );

    if (confirmPrompt == true) {
      // If we have no applicationId (new application flow), use the resubmitCallback
      // to re-create the application with the corrected phone number
      if ((applicationId == null || applicationId.toString().isEmpty || applicationId.toString() == 'null') && resubmitCallback != null) {
        resubmitCallback(_fullPhoneNumber);
        return;
      }

      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (ctx) => WillPopScope(
          onWillPop: () async => false,
          child: paymentDialog(message: "Initiating Payment..."),
        ),
      );
      try {
        var value = await ApiProvider().promptPaymentOfSavedApplications(
          token: widget.token,
          applicationId: int.tryParse(applicationId.toString()) ?? 0,
          clientPhone: _fullPhoneNumber,
        );
        Navigator.of(context).pop(); // pop the "Initiating Payment..." dialog
        if (value['status'] == "success") {
          CheckPaymentDialog(
            trackingId: value['tracking_id'].toString(),
            applicationId: applicationId,
            clientPhone: _fullPhoneNumber,
            promptCount: promptCount + 1,
            resubmitCallback: resubmitCallback,
          );
        } else {
          _showErrorDialog(value['message'].toString().replaceAll("[", "").replaceAll("]", ""));
        }
      } catch (e) {
        Navigator.of(context).pop();
        _showErrorDialog(e.toString().replaceAll("[", "").replaceAll("]", ""));
      }
    } else {
       _showErrorDialog("Connection Timed Out Without payment Confirmation");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) {
        return FailedDialog(
          message: message,
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) {
        return FailedDialog(
          dialogLotti: 'assets/lotti/success.json',
          message: message,
        );
      },
    );
  }
}
