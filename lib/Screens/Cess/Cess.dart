import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:nb_utils/nb_utils.dart';


class cess extends StatefulWidget {
  const cess({super.key});

  @override
  State<cess> createState() => _cessState();
}

class _cessState extends State<cess> with SingleTickerProviderStateMixin {
  TabController? tabController;
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    tabController!.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final imageDimension = screenWidth / 3.3;
    final fontSize = screenWidth / 28.0;
    return Scaffold(
      // appBar: AppBar(
      //   automaticallyImplyLeading: false,
      //   backgroundColor: Colors.transparent,
      //   elevation: 0.0,
      //   toolbarHeight: 80,
      //   title: Text(
      //     "Cess",
      //     style: GoogleFonts.manrope(
      //       // fontFamily: "Mulish",
      //       fontWeight: FontWeight.w600,
      //       fontSize: 19,
      //       color: Colors.white,
      //     ),
      //   ),
      //   centerTitle: true,
      //   flexibleSpace: Container(
      //     decoration: BoxDecoration(
      //         borderRadius: BorderRadius.only(
      //             // bottomLeft: Radius.circular(20),
      //             bottomRight: Radius.circular(30)),
      //         gradient: LinearGradient(
      //             colors: [Color(0XFF3E4095), Color(0XFF3E4095)],
      //             begin: Alignment.bottomCenter,
      //             end: Alignment.topCenter)),
      //   ),
      // ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Color(0XFF3E4095).withOpacity(0.7),
            // color: Colors.redAccent,
            height: screenHeight * 0.45,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/lotti/under-devt.json',
                  // width: context.width() * 0.7,
                  // height: context.height() * 0.15,
                  width: ContextExtensions(context).width() ,
                  height: ContextExtensions(context).height() * 0.3,
                ),
              ],
            ),
          ),
          Container(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    '503',
                    style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w700,
                        fontSize: fontSize * 2.4),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    'Service Unavailable',
                    style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.1,
                        fontSize: fontSize * 1.35),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    'Our team is currently performing an extensive upgrade to enhance this module\'s functionality and user experience. During this period, you might experience some downtime or limited access.',
                    style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1.1,
                        fontSize: fontSize * 1.1),

                  ),
                  SizedBox(
                    height: 25,
                  ),
                  // Text(
                  //   'Thank you for your support!',
                  //   style: GoogleFonts.montserrat(
                  //       fontWeight: FontWeight.w600,
                  //       fontSize: fontSize * 1.1),
                  //
                  // ),
                  Container(
                    width: screenWidth * 0.4,
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
                        Navigator.of(context).pop();
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
                      child:  Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_back, size: fontSize * 1.5,color: Color(0xFF3E4095),),
                          SizedBox(width: screenWidth * 0.03,),
                          Text(
                            'Back',
                            style: GoogleFonts.manrope(
                              fontSize: fontSize * 1.2,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3E4095),
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
        ],
      ),
    );
  }

  Widget buildLoginForm(double fontSize, BuildContext context) {
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
              const SizedBox(height: 12),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: 'Enter Hawker Name',
                  hintStyle: GoogleFonts.manrope(fontSize: fontSize),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF46B1FD)),
                  ),
                ),
              ),
              const SizedBox(height: 17),
              Text(
                'Hawker ID Number',
                style: GoogleFonts.manrope(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: 'Enter Hawker ID',
                  hintStyle: GoogleFonts.manrope(fontSize: fontSize),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF46B1FD)),
                  ),
                ),
              ),
              const SizedBox(height: 17),
              Text(
                'Hawker Mobile',
                style: GoogleFonts.manrope(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: 'Enter Hawker Mobile',
                  hintStyle: GoogleFonts.manrope(fontSize: fontSize),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF46B1FD)),
                  ),
                ),
              ),
              const SizedBox(height: 17),
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
          child: ElevatedButton(
            onPressed: () async {
              // Your onPressed code here
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
              'Initiate Hawking Fees Payment',
              style: GoogleFonts.manrope(
                fontSize: fontSize * 1.2,
                fontWeight: FontWeight.w500,
                color: Color(0xFF3E4095),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget buildLoginForm2(double fontSize, BuildContext context) {
    return Column(
      children: [
        Form(
          key: _formKey2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hawker ID Number',
                style: GoogleFonts.manrope(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: 'Enter Hawker ID Number',
                  hintStyle: GoogleFonts.manrope(fontSize: fontSize),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF46B1FD)),
                  ),

                ),
              ),
              const SizedBox(height: 17),
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
          child: ElevatedButton(
            onPressed: () async {
              // Your onPressed code here
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
              'Check Hawker Status',
              style: GoogleFonts.manrope(
                fontSize: fontSize * 1.2,
                fontWeight: FontWeight.w500,
                color: Color(0xFF3E4095),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
