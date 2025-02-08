import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

OutlineInputBorder defaultOutlineInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.circular(14),
  borderSide: const BorderSide(color: Color(0xFFF3F3F3)),
);



// list of colors that we use in our app
const kBackgroundColor = Color(0xFFF1EFF1);
const kPrimaryColor = Color(0xFF035AA6);
const kSecondaryColor = Color(0xFFFFA41B);
const kTextColor = Color(0xFF000839);
const kTextLightColor = Color(0xFF747474);
const kBlueColor = Color(0xFF40BAD5);
const kGreyTextColor = Color(0xFF9090AD);
const kDarkWhite = Color(0xFFF1F7F7);
const kTitleColor = Color(0xFF22215B);
const kAlertColor = Color(0xFFFF8919);
const kBgColor = Color(0xFFFAFAFA);

bool isTab(BuildContext context) => MediaQuery.of(context).size.aspectRatio >= 0.74 && MediaQuery.of(context).size.aspectRatio < 1.5;


Color setStatusColor(String status) {
  switch (status) {
    case "Pending":
      return kAlertColor;
    case "Approved":
      return Colors.green;
    case "Rejected":
      return Colors.red;
    default:
      return Color(0xFF1366D9);
  }
}

const kDefaultPadding = 20.0;


final kTextStyle = GoogleFonts.manrope();

final kTitleTextStyle = GoogleFonts.poppins();



// our default Shadow
const kDefaultShadow = BoxShadow(
  offset: Offset(0, 15),
  blurRadius: 27,
  color: Colors.black12, // Black color with 12% opacity
);

class Constants {
  //Primary color
  static var primaryColor = const Color(0xff296e48);
  static var blackColor = Colors.black54;

  //Onboarding texts
  static var titleOne = "Streamline your sales process.";
  static var descriptionOne = "Effortlessly convert quotations to sales orders and streamline your sales process.";
  static var titleTwo = "Unlock Sales Insights with Reports";
  static var descriptionTwo = "Gain valuable insights into your sales performance with our advanced reporting features.";
  static var titleThree = "Plant a tree, green the Earth";
  static var descriptionThree = "Onboard Farmers easily on the system using simple ui";

}

