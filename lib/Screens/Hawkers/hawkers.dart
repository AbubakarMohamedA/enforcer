import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:lottie/lottie.dart';

import 'package:shimmer/shimmer.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../Api/api_provider.dart';
import '../../Models/HawkersModel/checkHawkerStatus.dart';
import '../../Models/HawkersModel/getCategoriesModel.dart';
import '../../Models/HawkersModel/getHawkerStats.dart';
import '../../Models/HawkersModel/getLocations.dart';
import '../../Models/HawkersModel/getZones.dart';
import '../../widgets/checkStatusDialog.dart';
import '../../widgets/failed_dialog.dart';
import '../../widgets/payment_dialog.dart';
import 'PaidHawkersList.dart';

class hawkers extends StatefulWidget {
  var token;
  hawkers({
    required this.token
  });

  @override
  State<hawkers> createState() => _hawkersState();
}

class _hawkersState extends State<hawkers> with SingleTickerProviderStateMixin {
  TabController? tabController;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _hawkerIdController = TextEditingController();
  TextEditingController _hawkerNameController = TextEditingController();
  TextEditingController _hawkerZoneController = TextEditingController();
  TextEditingController _hawkerLocationleController = TextEditingController();
  TextEditingController _hawkerCategoryController = TextEditingController();
  TextEditingController _hawkerMobileController = TextEditingController();

  String? hawkerZoneId;
  Datum? selectedDropdownZone;



  /*  SECOND FORM DATA */
  final _formKey2 = GlobalKey<FormState>();

  TextEditingController _2hawkerIdController = TextEditingController();
  bool checkHawkerStatus = false;
  bool promptHawkerPayment = false;

  late Future<GetHawkerStats> hawkerStatsFuture;

  late Future<Map<String, dynamic>> permissionsFuture;
  DailyStats? dailyStats;
  MonthlyStats? monthlyStats;

  //ZONES
  late Future<GetZones> zonesFuture;
  List<Datum>? zonesData;

  //Locations
  late Future<GetLocations> locationsFuture;
  List<LocationsDatum>? AllLocationsData;
  List<LocationsDatum>? speicifcLocationsData;

  Future<GetLocations> loadLocations(hawkerZoneId) async {
    try {
      locationsFuture =  ApiProvider()
          .getLocations(token: widget.token, zoneId: hawkerZoneId);
      // Sort the list in descending order based on the apply date
      return locationsFuture;
    } catch (e) {
      // Handle error
      print('Error loading leave applications: $e');
      throw e; // Re-throw the error to propagate it to the FutureBuilder
    }
  }


  //Categories
  late Future<GetCategories> categoriesFuture;
  List<CategoriesDatum>? categoriesData;

  String? phoneSelected;
  bool showProgress = false;
  bool zoneSelected = false;

  Future loadList() async {
    try {
      setState(() {
        hawkerStatsFuture =  ApiProvider().getHawkerStats(token: widget.token);
      });
    } catch (e) {
      debugPrint('Error fetching token: $e');
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //     content: Text('Encountered an Error please contact Support')));
    }
  }

  Future<void> _checkHawkerPaymentStatusRepeatedly(
      {required String hawkerId}
      ) async {
    final startTime = DateTime.now();
    const timeout = Duration(minutes: 1);

    while (DateTime.now().difference(startTime) < timeout) {
      try {
        Map<String, dynamic> checkstatus = await ApiProvider().checkHawkerStatus(
          token: widget.token,
          hawkerId: hawkerId,
        );

        if (checkstatus['payment_status'] == 1) {
          setState(() {
            hawkerStatsFuture =  ApiProvider().getHawkerStats(token: widget.token);
            _hawkerNameController.clear();
            _hawkerIdController.clear();
            _hawkerZoneController.clear();
            zoneSelected = false;
            hawkerZoneId = null;
            selectedCategory = null;
            _fullPhoneNumber = '';
            _phoneController.clear();
            selectedDropdownCategory = null;
            selectedCategory = null;
            selectedLocation = null;
            selectedDropdownLocation = null;
            selectedDropdownZone = null;
          });
          Navigator.of(context).pop();
          _showSuccessDialog("Fee Payment Successfully Received");
          return;
        }

        await Future.delayed(Duration(seconds: 5));
      } catch (e) {
        print('Error during status check: $e');
        Navigator.of(context).pop();
        _showErrorDialog(e.toString());
        return;
      }
    }
    Navigator.of(context).pop();
    _showErrorDialog("Connection Timed Out Without payment Confirmation");
  }


  void _showLoadingPayment(String message) {
    showDialog(
      context: context,
      builder: (ctx) {
        return paymentDialog(
          message: message,
        );
      },
    );
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

  @override
  void initState() {
    super.initState();
    permissionsFuture = ApiProvider().checkPermission(permissionType: 'Access Hawkers', token: widget.token);
    hawkerStatsFuture =  ApiProvider().getHawkerStats(token: widget.token);
    zonesFuture  =  ApiProvider().getZones(token: widget.token);

    categoriesFuture  =  ApiProvider().getCategories(token: widget.token);
    tabController = TabController(length: 2, vsync: this);
    tabController!.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _hawkerIdController.dispose();
    _hawkerNameController.dispose();
    super.dispose();
  }


  String? selectedCategory;
  CategoriesDatum? selectedDropdownCategory;
  LocationsDatum? selectedDropdownLocation;
  String? selectedLocation;

  bool nameTextFieldBorder = false;
  bool idTextFieldBorder  = false;
  bool zoneTextFieldBorder  = false;
  bool locationTextFieldBorder  = false;
  bool categoryTextFieldBorder  = false;
  bool mobileTextFieldBorder  = false;


  //Intl
  TextEditingController _phoneController = TextEditingController();
  PhoneNumber _initialPhoneNumber = PhoneNumber(isoCode: 'KE');
  bool _isValidNumber = false;
  String _fullPhoneNumber = '';


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
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboard = MediaQuery.of(context).viewInsets.bottom != 0;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        toolbarHeight: 80,
        title: Text(
          "Hawking Fees",
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
      body: FutureBuilder(
          future: permissionsFuture,
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
                return RefreshIndicator(
                  onRefresh: () => loadList(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    child: ScrollConfiguration(
                      behavior: ScrollBehavior().copyWith(overscroll: false),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isKeyboard)  SizedBox(
                            height: screenHeight * 0.03,
                          ),
                          if (!isKeyboard)  Text(
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
                          if (!isKeyboard) FutureBuilder(
                              future: hawkerStatsFuture,
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  print(snapshot.error);
                                  return  IntrinsicHeight(
                                    // height: 150,
                                    // height: screenHeight * 0.19,
                                    // color: Colors.green,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: screenWidth * 0.37,
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
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                              shape: BoxShape.circle,
                                                              color: Colors.white,
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets.all(15.0),
                                                              child: Center(
                                                                child: SvgPicture.asset(
                                                                  'assets/images/userIcon.svg', // Your SVG asset path
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
                                                        Text("Daily Hawkers Paid",
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
                                                        Text("Daily Fees Collection",
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
                                                        Text("Monthly Fees Collection",
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
                                          width: screenWidth * 0.37,
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
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                              shape: BoxShape.circle,
                                                              color: Colors.white,
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets.all(15.0),
                                                              child: Center(
                                                                child: SvgPicture.asset(
                                                                  'assets/images/userIcon.svg', // Your SVG asset path
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
                                                        Text("Daily Hawkers Paid",
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
                                                        Text("Daily Fees Collection",
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
                                                        Text("Monthly Fees Collection",
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
                                  dailyStats = snapshot.data!.dailyStats;
                                  monthlyStats = snapshot.data!.monthlyStats;
                                  String dailyAmountPaid = formatNumb((dailyStats!.totalAmount ?? 0.0).toString());
                                  String monthlyAmountPaid = formatNumb((monthlyStats!.totalAmount ?? 0.0).toString());
                                  return  IntrinsicHeight(
                                    // height: 150,
                                    // height: screenHeight * 0.19,
                                    // color: Colors.green,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: screenWidth * 0.37,
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
                                                                builder: (c) => paidHawkers(
                                                                  token: widget.token,
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
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                shape: BoxShape.circle,
                                                                color: Colors.white,
                                                              ),
                                                              child: Padding(
                                                                padding: const EdgeInsets.all(15.0),
                                                                child: Center(
                                                                  child: SvgPicture.asset(
                                                                    'assets/images/userIcon.svg', // Your SVG asset path
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
                                                    ),
                                                    SizedBox(height: 9,),
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text("Daily Hawkers Paid",
                                                          style: GoogleFonts.manrope(
                                                              fontWeight: FontWeight.w500,
                                                              // fontSize: 14,
                                                              fontSize: fontSize *1,
                                                              color: Color(0XFF3E4095)),
                                                        ),
                                                        SizedBox(height: screenHeight* 0.007,),
                                                        Text("${dailyStats!.paidHawkers.toString()}",
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
                                                        Text("Daily Fees Collection",
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
                                                        Text("Monthly Fees Collection",
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
                            height: 10,
                          ),
                          Container(
                            // padding: const EdgeInsets.all(8),
                            // height: 50,
                            decoration: BoxDecoration(
                              color: Color(0xFF3E4095),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: TabBar(

                                controller: tabController,
                                labelColor: Color(0xFF3E4095),
                                unselectedLabelColor: Colors.white,
                                labelStyle: GoogleFonts.manrope(
                                    fontSize: fontSize * 0.9
                                ),
                                indicator: BoxDecoration(
                                  color: Color(0xFFFFCC2A),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                tabs: [
                                  Tab(text: 'Prompt Hawker', ),
                                  Tab(text: 'Check Hawker Status'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          // (!isKeyboard) ? Container(
                          //   height:  screenHeight * 0.5, // Specify the height for the TabBarView
                          //   child: TabBarView(
                          //     physics: NeverScrollableScrollPhysics(),
                          //     controller: tabController,
                          //     children: [
                          //       ScrollConfiguration(
                          //         behavior: ScrollBehavior().copyWith(overscroll: false),
                          //         child: SingleChildScrollView(
                          //           // physics: (isKeyboard) ? NeverScrollableScrollPhysics() : ScrollPhysics(),
                          //           child: Padding(
                          //             padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          //             child: promptHawkerForm(fontSize, context),
                          //           ),
                          //         ),
                          //       ),
                          //       Padding(
                          //             padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          //             child: checkHawkerStatusForm(fontSize, context),
                          //           ),
                          //         ],
                          //       ),
                          //     ) :
                          Expanded(
                            // height: screenHeight * 0.5 ,
                              child: TabBarView(
                                physics: NeverScrollableScrollPhysics(),
                                controller: tabController,
                                children: [
                                  ScrollConfiguration(
                                    behavior: ScrollBehavior().copyWith(overscroll: false),
                                    child: SingleChildScrollView(
                                      // physics: (isKeyboard) ? NeverScrollableScrollPhysics() : ScrollPhysics(),
                                      child: Padding(
                                        padding:  EdgeInsets.symmetric(horizontal: 2.0),
                                        child: promptHawkerForm(fontSize, context),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                    child: checkHawkerStatusForm(fontSize, context),
                                  ),
                                ],
                              )  )
                        ],
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
  Widget promptHawkerForm(double fontSize, BuildContext context) {
    return Column(
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hawker Name',
                style: GoogleFonts.manrope(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _hawkerNameController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: 'Enter Hawker Name',
                  hintStyle: GoogleFonts.manrope(fontSize: fontSize),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Color(0xFF46B1FD)),
                  ),
                ),
                onChanged: (value) {
                  // Your onChanged logic
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a Hawker Name';
                  } else if (value.length <= 3) {
                    return 'Hawker Name must be greater than 3 characters';
                  } else if (RegExp(r'[0-9]').hasMatch(value)) {
                    return 'Hawker Name should not contain numbers';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'ID Number',
                      style: GoogleFonts.manrope(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Hawker Zone',
                      style: GoogleFonts.manrope(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _hawkerIdController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: 'Enter Hawker ID',
                        hintStyle: GoogleFonts.manrope(fontSize: fontSize),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:  BorderSide( color: Color(0xFF46B1FD)),
                        ),
                      ),
                      onChanged: (value){
                        setState(() {

                        });
                      },

                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'ID is required';
                        }
                        if (!RegExp(r'^\d{8}$').hasMatch(value)) {
                          return 'Enter a valid 8-digit ID';
                        }
                        return null; // Return null if the input is valid
                      },
                    ),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    child: FutureBuilder<GetZones>(
                      future: zonesFuture!,
                      builder: (context,
                          AsyncSnapshot<GetZones>
                          snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return createDisabledDropdownSearch("Fetching Zones.....");
                        } else if (snapshot.hasError) {
                          print(snapshot.error);
                          return createDisabledDropdownSearch(
                              "Error Fetching Zones.....");
                        } else if (!snapshot.hasData ||
                            snapshot
                                .data!.data!.isEmpty) {
                          return createDisabledDropdownSearch(
                              "No Zones Found.....");
                        } else {
                          zonesData = snapshot.data!.data;
                          return DropdownSearch<Datum>(
                              mode: Mode.DIALOG,
                              items: zonesData,
                              selectedItem: selectedDropdownZone,
                              itemAsString:
                                  (Datum? zones) => zones?.name?? '',
                              dropdownSearchDecoration:
                              InputDecoration(
                                // labelText: "Zones ",
                                hintText: "Select Zone ",
                                hintStyle: GoogleFonts.manrope(fontSize: fontSize),
                                disabledBorder:
                                OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color:  Color(0xFF1366D9),
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              onChanged: (Datum? selectedZone) {
                                if (selectedZone != null) {
                                  setState(() {
                                    hawkerZoneId = selectedZone.id.toString();
                                    zoneSelected = true;
                                    selectedDropdownZone = selectedZone;
                                    selectedLocation = null;
                                    selectedDropdownLocation = null;
                                    locationsFuture = loadLocations(hawkerZoneId);
                                  });
                                }
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a zone';
                                }
                                return null;
                              },
                              showSearchBox: true,
                              isFilteredOnline: true,
                              searchFieldProps: TextFieldProps(
                                cursorColor: Colors.blue,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText:
                                  'Search My Zone',
                                ),
                                // controller: searchController,
                              ));
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Location',
                      style: GoogleFonts.manrope(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Category',
                      style: GoogleFonts.manrope(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child:  zoneSelected ?
                    // DropdownSearch<String>(
                    //     mode: Mode.DIALOG,
                    //     items: location,
                    //     selectedItem: selectedLocation,
                    //     itemAsString: (value) => value?? '',
                    //     dropdownSearchDecoration:
                    //     InputDecoration(
                    //       // labelText: "Zones ",
                    //       hintText: "Location ",
                    //       disabledBorder:
                    //       OutlineInputBorder(
                    //         borderSide: BorderSide(
                    //           color: Color(0xFF1366D9),
                    //           width: 1.0,
                    //         ),
                    //       ),
                    //     ),
                    //     onChanged: (value) {
                    //       setState(() {
                    //         selectedLocation = value;
                    //       });
                    //     },
                    //     validator: (value) {
                    //       if (value == null) {
                    //         return 'Please select a Location';
                    //       }
                    //       return null;
                    //     },
                    //     showSearchBox: true,
                    //     isFilteredOnline: true,
                    //     searchFieldProps: TextFieldProps(
                    //       cursorColor: Colors.blue,
                    //       decoration: InputDecoration(
                    //         border: OutlineInputBorder(),
                    //         hintText:
                    //         'Search My Locations',
                    //       ),
                    //       // controller: searchController,
                    //     )) :
                    FutureBuilder<GetLocations>(
                      future: locationsFuture!,
                      builder: (context,
                          AsyncSnapshot<GetLocations>
                          snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return createDisabledDropdownSearch("Fetching Locations.....");
                        } else if (snapshot.hasError) {
                          return createDisabledDropdownSearch(
                              "Error Fetching Locations.....");
                        } else if (!snapshot.hasData ||
                            snapshot
                                .data!.data!.isEmpty) {
                          return createDisabledDropdownSearch(
                              "No Locations Found.....");
                        } else {
                          AllLocationsData = snapshot.data!.data;
                          // speicifcLocationsData = AllLocationsData!.where((element) => element.zoneId == hawkerZoneId).toList();

                          return DropdownSearch<LocationsDatum>(
                              mode: Mode.DIALOG,
                              items: AllLocationsData,
                              selectedItem: selectedDropdownLocation,
                              itemAsString:
                                  (LocationsDatum? location) => location?.locationName?? '',
                              dropdownSearchDecoration:
                              InputDecoration(
                                // labelText: "Zones ",
                                hintText: "Select Location ",
                                hintStyle: GoogleFonts.manrope(fontSize: fontSize),
                                disabledBorder:
                                OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color:  Color(0xFF1366D9),
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              onChanged: (LocationsDatum? selcetdLocation) {
                                if (selcetdLocation != null) {
                                  setState(() {
                                    selectedLocation = selcetdLocation.locationId.toString();
                                    selectedDropdownLocation = selcetdLocation;
                                  });
                                }
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a Locations';
                                }
                                return null;
                              },
                              showSearchBox: true,
                              isFilteredOnline: true,
                              searchFieldProps: TextFieldProps(
                                cursorColor: Colors.blue,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText:
                                  'Search My Locations',
                                ),
                                // controller: searchController,
                              ));
                        }
                      },
                    ):
                    TextFormField(
                      readOnly: true,
                      controller: _hawkerLocationleController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: 'Location',
                        hintStyle: GoogleFonts.manrope(fontSize: fontSize),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: nameTextFieldBorder
                                ? Colors.redAccent.withOpacity(0.7)
                                : Color(0xFF46B1FD),
                          ),
                        ),
                      ),
                      onTap: () {
                        Get.snackbar(
                          'Error',
                          'Please select a zone first',
                          backgroundColor: Colors.red.withOpacity(0.7),
                          colorText: Colors.white,
                          snackPosition: SnackPosition.TOP, // Adjust position if needed
                          duration: Duration(seconds: 2), // Adjust duration if needed
                          margin: EdgeInsets.only(left: 16.0,right: 16), // Adjust margin if needed
                          borderRadius: 10.0, // Adjust border radius if needed
                        );
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a Location';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    child: FutureBuilder<GetCategories>(
                      future: categoriesFuture!,
                      builder: (context,
                          AsyncSnapshot<GetCategories>
                          snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return createDisabledDropdownSearch("Fetching Categories.....");
                        } else if (snapshot.hasError) {
                          return createDisabledDropdownSearch(
                              "Error Fetching Categories.....");
                        } else if (!snapshot.hasData ||
                            snapshot
                                .data!.data!.isEmpty) {
                          return createDisabledDropdownSearch(
                              "No Categories Found.....");
                        } else {
                          categoriesData = snapshot.data!.data;
                          return DropdownSearch<CategoriesDatum>(
                              mode: Mode.DIALOG,
                              items: categoriesData,
                              selectedItem: selectedDropdownCategory,
                              itemAsString: (CategoriesDatum? category) => category?.name?? '',
                              dropdownSearchDecoration:
                              InputDecoration(
                                // labelText: "Zones ",
                                hintText: "Select Category ",
                                hintStyle: GoogleFonts.manrope(fontSize: fontSize),
                                disabledBorder:
                                OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color:  Color(0xFF1366D9),
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              onChanged:
                                  (CategoriesDatum? selectedZone) {
                                if (selectedZone != null) {
                                  setState(() {
                                    selectedCategory = selectedZone.id.toString();
                                    selectedDropdownCategory = selectedZone;
                                  });
                                }
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a Category';
                                }
                                return null;
                              },
                              showSearchBox: true,
                              isFilteredOnline: true,
                              searchFieldProps: TextFieldProps(
                                cursorColor: Colors.blue,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText:
                                  'Search My Category',
                                ),
                                // controller: searchController,
                              ));
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Hawker Mobile',
                style: GoogleFonts.manrope(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              InternationalPhoneNumberInput(
                countries: ["KE"],
                onInputChanged: (PhoneNumber number) {
                  setState(() {
                    _fullPhoneNumber = number.phoneNumber ?? '';
                  });
                  print(number.phoneNumber);
                  print(_fullPhoneNumber);
                },
                onInputValidated: (isValid) {
                  setState(() {
                    _isValidNumber = isValid;
                  });
                  print(isValid);
                },

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
                selectorTextStyle: TextStyle(color: Colors.black),
                initialValue: _initialPhoneNumber,
                textFieldController: _phoneController,
                formatInput: true,
                errorMessage: 'Please enter a valid phone number',
                inputDecoration: InputDecoration(
                  prefixIconColor: Colors.black38,
                  hintStyle: GoogleFonts.manrope(
                      fontSize: fontSize
                  ),
                  hintText: '712-256-408',
                  alignLabelWithHint: false,
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:  BorderSide(color:Color(0xFF46B1FD)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:  BorderSide(color:Color(0xFF46B1FD)),
                  ),
                ),
                keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
                inputBorder: OutlineInputBorder(),
                onSaved: (PhoneNumber number) {
                  print('On Saved:');
                  print(number.phoneNumber);
                },
              ),
              const SizedBox(height: 15),
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
                  onPressed: () async {
                    // Your onPressed code here
                    FocusScope.of(context).unfocus();
                    // if(phoneSelected == null ){
                    //   setState(() {
                    //     mobileTextFieldBorder = true;
                    //   });
                    //   Get.snackbar(
                    //     'Oops!',
                    //     'Please Select Mobile Number',
                    //     backgroundColor: Colors.redAccent.withOpacity(0.8),
                    //     colorText: Colors.white,
                    //     snackPosition: SnackPosition.TOP, // Adjust position if needed
                    //     duration: Duration(seconds: 2), // Adjust duration if needed
                    //     margin: EdgeInsets.only(left: 16.0,right: 16), // Adjust margin if needed
                    //     borderRadius: 10.0, // Adjust border radius if needed
                    //   );
                    // } else
                    if((_formKey.currentState?.validate() ?? false) && _isValidNumber){
                      setState(() {
                        promptHawkerPayment = true;
                      });
                      try {
                        Map<String, dynamic> checkstatus = await ApiProvider().promptHawker(
                            token: widget.token,
                            hawkerId: _hawkerIdController.text,
                            hawkerName: _hawkerNameController.text,
                            hawkerMobile: _fullPhoneNumber,
                            hawkerZoneId: hawkerZoneId,
                            hawkerCategoryId: selectedCategory,
                            hawkerLocationId: selectedLocation
                        );


                        if (checkstatus['status'] != "success") {
                          setState(() {
                            promptHawkerPayment = false;
                          });

                          await showDialog(
                            context: context,
                            builder: (ctx) {
                              return FailedDialog(
                                message: checkstatus['message'],
                              );
                            },
                          );
                        } else {
                          setState(() {
                            promptHawkerPayment = false;
                          });
                          // showDialog(
                          //     context: context,
                          //     builder: (ctx) {
                          //       return FailedDialog(
                          //           dialogLotti:
                          //           'assets/lotti/success.json',
                          //           message:"Payment Successfully  initiated"
                          //               .replaceAll("[", "")
                          //               .replaceAll("]", ""));
                          //     });
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
                          // _showLoadingPayment("Initiated Payment. Please wait...............");
                          await _checkHawkerPaymentStatusRepeatedly(hawkerId:_hawkerIdController.text, );
                          // Navigator.of(context).pop();
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

                      setState(() {
                        promptHawkerPayment = false;
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
                  child: promptHawkerPayment
                      ? CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : Text(
                    'Initiate Hawking Fees Payment',
                    style: GoogleFonts.manrope(
                      fontSize: fontSize * 1.2,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF3E4095),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
        // const SizedBox(height: 2),
      ],
    );
  }
  Widget checkHawkerStatusForm(double fontSize, BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            Lottie.asset(
              repeat : false,
              'assets/lotti/error.json',
              // width: context.width() * 0.7,
              // height: context.height() * 0.15,
              width: ContextExtensions(context).width() ,
              height: ContextExtensions(context).height() * 0.2,
            ),
            SizedBox(height: 15),
            Column(
              children: [
                Text(
                  'You have no permission to Access this.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                      fontSize: fontSize * 1.2
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Kindly contact your Administrator.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w500,
                      fontSize: fontSize * 1.3),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }
  Widget createDisabledDropdownSearch(String hintText) {
    return DropdownSearch<String>(
      items: [],
      dropdownSearchDecoration: InputDecoration(
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFF46B1FD),
            width: 1.0,
          ),
        ),
        hintText: hintText,
      ),
      enabled: false,
    );
  }
}
