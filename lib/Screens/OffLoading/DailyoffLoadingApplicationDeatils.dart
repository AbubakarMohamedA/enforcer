import 'package:enforcer/Screens/OffLoading/penalizePromptPayment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import '../../Api/api_provider.dart';
import '../../Models/Offloading/getDailyOffloadingApplications.dart';

import '../../Models/Offloading/getDailyOffloadingApplications.dart';
import '../../widgets/failed_dialog.dart';


class DailyoffLoadingDetails extends StatefulWidget {
  GetDailyOffloadingApplicationDatum offLoadingItem;
  var token;
  final Function? CheckPaymentDialogCallback;

  DailyoffLoadingDetails({
    required this.offLoadingItem,
    required this.token,
    required this.CheckPaymentDialogCallback
  });

  @override
  State<DailyoffLoadingDetails> createState() => _DailyoffLoadingDetailsState();
}

class _DailyoffLoadingDetailsState extends State<DailyoffLoadingDetails> {

  bool isChecked = true;
  bool isLoading = false;


  bool _isValidNumber = false;
  String _fullPhoneNumber = '';
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final imageDimension = screenWidth / 3.3;
    final fontSize = screenWidth / 28.0;

    String formatNumb(String numb) {
      final NumberFormat formatter = NumberFormat("#,##0.00", "en_US");
      double numberr = double.parse(numb);
      return formatter.format(numberr);
    }

    // Calculate the grand total
    double grandTotal = widget.offLoadingItem.items!.fold(0.0, (total, item) {
      // Parse total_amount to double and add it to the total
      return total + double.parse(item.totalAmount ?? '0') ?? 0.0;
    });

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        toolbarHeight: 80,
        title: Text(
          "Application Details",
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
                  end: Alignment.topCenter)
          ),
        ),
      ),
      floatingActionButton: (widget.offLoadingItem.status == "Unpaid") ? FloatingActionButton(
        onPressed: () async {

          bool confirmPrompt = await showDialog(
            context: context,
            builder: (BuildContext context) {
              // Controller for the phone number input inside the dialog
              TextEditingController phoneNumberController = TextEditingController(
                text: widget.offLoadingItem.phoneNumber, // Pre-fill with clientPhone
              );
              PhoneNumber _initialPhoneNumber = PhoneNumber(
                phoneNumber: widget.offLoadingItem.phoneNumber,
                isoCode: 'KE',
              );
              return  AlertDialog(
                 content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(child: Text("Confirm Phone Number",style: GoogleFonts.manrope(fontSize: fontSize*1.2,fontWeight: FontWeight.w600),)),
                    SizedBox(height: 12,),
                    Center(child: Text(
                      "Please confirm or edit the client's phone number:",
                      style: GoogleFonts.manrope(fontSize: fontSize*1),
                      // textAlign: TextAlign.center
                      )),
                    SizedBox(height: 15),
                    InternationalPhoneNumberInput(
                      countries: ["KE"],
                      onInputChanged: (PhoneNumber number) {
                        if (mounted) {
                          setState(() {
                            _fullPhoneNumber = number.phoneNumber ?? '';
                          });
                        }
                        print(number.phoneNumber);
                        print(_fullPhoneNumber);
                      },
                      onInputValidated: (isValid) {
                        if (mounted) {
                          setState(() {
                            _isValidNumber = isValid;
                          });
                        }
                        print(isValid);
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
                      selectorTextStyle:  GoogleFonts.manrope(),
                      initialValue: _initialPhoneNumber,
                      textFieldController: phoneNumberController,
                      formatInput: true,
                      errorMessage: 'Please enter a valid phone number',
                      inputDecoration: InputDecoration(
                        prefixIconColor: Colors.black38,
                        hintStyle: GoogleFonts.manrope(
                          fontSize: fontSize,
                        ),
                        hintText: '712-256-408',
                        alignLabelWithHint: false,
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Color(0xFF46B1FD)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Color(0xFF46B1FD)),
                        ),
                      ),
                      keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
                      inputBorder: OutlineInputBorder(),
                      onSaved: (PhoneNumber number) {
                        print('On Saved:');
                        print(number.phoneNumber);
                      },
                    ),
                  ],
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
                    onPressed: () {
                      if (_isValidNumber ){
                        Navigator.of(context).pop(true);
                      }
                      else {
                        // Handle invalid phone number
                        Get.snackbar(
                          'Oops',
                          'Invalid Phone Number ',
                          backgroundColor: Colors.redAccent.withOpacity(0.7),
                          colorText: Colors.white,
                          snackPosition: SnackPosition.TOP, // Adjust position if needed
                          duration: Duration(seconds: 2), // Adjust duration if needed
                          margin: EdgeInsets.only(left: 16.0,right: 16), // Adjust margin if needed
                          borderRadius: 10.0, // Adjust border radius if needed
                        );
                      }

                      },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    ),
                    child: Text("Prompt",
                      style: GoogleFonts.montserrat(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                ],
              );
            }
          );
          // Step 2: Check user's choice and proceed with deletion if confirmed
          if (confirmPrompt == true) {
            if (_isValidNumber ) {
              // Navigator.of(context).pop(); // Close the dialog

                setState(() {
                  isLoading = true;
                });

              // Initiate the payment process after confirmation
              await ApiProvider()
                  .promptPaymentOfSavedApplications(
                token: widget.token,
                applicationId: widget.offLoadingItem.id,
                clientPhone: _fullPhoneNumber, // Use the confirmed number
              )
                  .then((value) async {

                  setState(() {
                    isLoading = false;
                  });

                if (value['status'] == "success") {
                    // Navigator.of(context).pop();
                    Navigator.pop(context);
                    Navigator.pop(context);
                    widget.CheckPaymentDialogCallback!(trackingId: value['tracking_id'].toString());

                } else {
                  showDialog(
                    context: context,
                    builder: (ctx) {
                      return FailedDialog(
                          message: value['message']
                              .toString()
                              .replaceAll("[", "")
                              .replaceAll("]", ""));
                    },
                  );
                }
              }).catchError((onError) {
                if (mounted) {
                  setState(() {
                    isLoading = false;
                  });
                }
                debugPrint('Error: ${onError.toString()}');
                showDialog(
                  context: context,
                  builder: (ctx) {
                    return FailedDialog(
                        message: onError.toString()
                            .replaceAll("[", "")
                            .replaceAll("]", ""));
                  },
                );
              });
            }
          }
        },
        backgroundColor: Colors.green,
        child: isLoading
            ? CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        )
            : Padding(
          padding: EdgeInsets.all(14.0),
          child: Image.asset("assets/images/promptPayment.png"),
        ),
      )
          : null,
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: ScrollConfiguration(
          behavior: ScrollBehavior().copyWith(overscroll: false),
          child: SingleChildScrollView(
            child: Padding(
              padding:  EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                          Icons.person,
                          color: Color(0XFF3E4095)
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        'Customer Details',
                        style: GoogleFonts.manrope(
                            fontWeight: FontWeight.bold,
                            fontSize: fontSize *1.1,
                            color: Color(0XFF3E4095)
                        ),
                      ),
                    ],
                  ),
                  Divider(thickness: 0.2, color: Color(0XFF3E4095),),
                  Row(
                    children: [
                      SizedBox(
                        width: screenWidth * 0.37,
                        child:Text(
                          'Name:',
                          style: GoogleFonts.manrope(
                            fontSize: fontSize * 1,
                            // fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: size.width * 0.04,
                      ),
                      Flexible(
                        child:  Text(
                          widget.offLoadingItem.fullName.toString(),
                          style: GoogleFonts.manrope(
                            fontSize: fontSize * 1,
                            // fontWeight: FontWeight.w500,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),)
                    ],
                  ),
                  SizedBox(height: size.height * 0.011,),
                  Row(
                    children: [
                      SizedBox(
                        width: screenWidth * 0.37,
                        child:Text(
                          'Application Date:',
                          style: GoogleFonts.manrope(
                            fontSize: fontSize * 1,
                            // fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: size.width * 0.04,
                      ),
                      Flexible(
                        child:  Text(
                          // DateFormat('yyyy-MM-dd').format( widget.offLoadingItem.createdDate!),
                          widget.offLoadingItem.createdDate!.toString(),
                          style: GoogleFonts.manrope(
                            fontSize: fontSize * 1,
                            // fontWeight: FontWeight.w500,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),)
                    ],
                  ),
                  SizedBox(height: size.height * 0.011,),
                  Row(
                    children: [
                      SizedBox(
                        width: screenWidth * 0.37,
                        child:Text(
                          'Mobile:',
                          style: GoogleFonts.manrope(
                            fontSize: fontSize * 1,
                            // fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: size.width * 0.04,
                      ),
                      Flexible(
                        child:  Text(
                          widget.offLoadingItem.phoneNumber.toString(),
                          style: GoogleFonts.manrope(
                            fontSize: fontSize * 1,
                            // fontWeight: FontWeight.w500,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),)
                    ],
                  ),
                  SizedBox(height: size.height * 0.011,),
                  Row(
                    children: [
                      SizedBox(
                        width: screenWidth * 0.37,
                        child:Text(
                          'Status:',
                          style: GoogleFonts.manrope(
                            fontSize: fontSize * 1,
                            // fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: size.width * 0.04,
                      ),
                      Flexible(
                        child:  Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color:  widget.offLoadingItem.status == "Unpaid" ? Color(0xFFFF8919) : Colors.green,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Text(
                              widget.offLoadingItem.status.toString(),
                              style: GoogleFonts.manrope(
                                  color: Colors.white,
                                  fontSize: fontSize * 0.85
                              ),
                            ),
                          ),
                        ),)
                    ],
                  ),
                  SizedBox(height: 20,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                          Icons.info,
                          color: Color(0XFF3E4095)
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        'Application Details',
                        style: GoogleFonts.manrope(
                            fontWeight: FontWeight.bold,
                            fontSize: fontSize *1.1,
                            color: Color(0XFF3E4095)
                        ),
                      ),
                    ],
                  ),
                  Divider(thickness: 0.2, color: Color(0XFF3E4095),),
                  Row(
                    children: [
                      SizedBox(
                        width: screenWidth * 0.37,
                        child:Text(
                          'Application No:',
                          style: GoogleFonts.manrope(
                            fontSize: fontSize * 1,
                            // fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: size.width * 0.04,
                      ),
                      Flexible(
                        child:  Text(
                          "#${ widget.offLoadingItem.id.toString()}",
                          style: GoogleFonts.manrope(
                            fontSize: fontSize * 1,
                            // fontWeight: FontWeight.w500,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),)
                    ],
                  ),
                  SizedBox(height: size.height * 0.011,),
                  Row(
                    children: [
                      SizedBox(
                        width: screenWidth * 0.37,
                        child:Text(
                          'Vehicle Type:',
                          style: GoogleFonts.manrope(
                            fontSize: fontSize * 1,
                            // fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: size.width * 0.04,
                      ),
                      Flexible(
                        child:  Text(
                          widget.offLoadingItem.vehicleTypeName.toString(),
                          style: GoogleFonts.manrope(
                            fontSize: fontSize * 1,
                            // fontWeight: FontWeight.w500,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),)
                    ],
                  ),
                  SizedBox(height: size.height * 0.011,),
                  Row(
                    children: [
                      SizedBox(
                        width: screenWidth * 0.37,
                        child:Text(
                          'Plate Number:',
                          style: GoogleFonts.manrope(
                            fontSize: fontSize * 1,
                            // fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: size.width * 0.04,
                      ),
                      Flexible(
                        child:  Text(
                          widget.offLoadingItem.plateNo.toString(),
                          style: GoogleFonts.manrope(
                            fontSize: fontSize * 1,
                            // fontWeight: FontWeight.w500,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),)
                    ],
                  ),
                  SizedBox(height: size.height * 0.011,),
                  Row(
                    children: [
                      SizedBox(
                        width: screenWidth * 0.37,
                        child:Text(
                          'Penalty:',
                          style: GoogleFonts.manrope(
                            fontSize: fontSize * 1,
                            // fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: size.width * 0.04,
                      ),
                      Flexible(
                        child:  Text(
                          formatNumb(widget.offLoadingItem.penalty.toString()),
                          style: GoogleFonts.manrope(
                            fontSize: fontSize * 1,
                            // fontWeight: FontWeight.w500,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),)
                    ],
                  ),
                  SizedBox(height: size.height * 0.011,),
                  Row(
                    children: [
                      SizedBox(
                        width: screenWidth * 0.37,
                        child:Text(
                          'Zone:',
                          style: GoogleFonts.manrope(
                            fontSize: fontSize * 1,
                            // fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: size.width * 0.04,
                      ),
                      Flexible(
                        child:  Text(
                          widget.offLoadingItem.zoneName.toString(),
                          style: GoogleFonts.manrope(
                            fontSize: fontSize * 1,
                            // fontWeight: FontWeight.w500,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),)
                    ],
                  ),
                  SizedBox(height: size.height * 0.011,),
                  Row(
                    children: [
                      SizedBox(
                        width: screenWidth * 0.37,
                        child:Text(
                          'Origin:',
                          style: GoogleFonts.manrope(
                            fontSize: fontSize * 1,
                            // fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: size.width * 0.04,
                      ),
                      Flexible(
                        child:   Row(
                          children: [
                            Container(
                              height: 20,
                              width: 20,
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                              child: SvgPicture.asset('assets/images/redpointer.svg'),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              widget.offLoadingItem.origin.toString(),
                              style: GoogleFonts.manrope(
                                fontSize: fontSize * 1,
                                // fontWeight: FontWeight.w500,
                                color: Colors.black.withOpacity(0.7),),
                            ),

                          ],
                        ),)
                    ],
                  ),
                  SizedBox(
                    height: size.height * 0.011,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: screenWidth * 0.37,
                      ),
                      SizedBox(
                        width: size.width * 0.04,
                      ),
                      Flexible(
                        child:Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              height: 25,
                              child: SvgPicture.asset('assets/images/threedots.svg'),
                            ),
                          ),
                        ),)
                    ],
                  ),
                  SizedBox(height: size.height * 0.011,),
                  Row(
                    children: [
                      SizedBox(
                        width: screenWidth * 0.37,
                        child:Text(
                          'Destination:',
                          style: GoogleFonts.manrope(
                            fontSize: fontSize * 1,
                            // fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: size.width * 0.04,
                      ),
                      Flexible(
                        child: Row(
                          children: [
                            Container(
                              height: 20,
                              width: 20,
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.green),
                              child: SvgPicture.asset('assets/images/greenpointer.svg'),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              widget.offLoadingItem.destination.toString(),
                              style: GoogleFonts.manrope(
                                fontSize: fontSize * 1,
                                // fontWeight: FontWeight.w500,
                                color: Colors.black.withOpacity(0.7),),
                            ),

                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: size.height * 0.011,
                  ),
                  SizedBox(height: 20,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                          Icons.shopping_basket,
                          color: Color(0XFF3E4095)
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        'Good Details',
                        style: GoogleFonts.manrope(
                            fontWeight: FontWeight.bold,
                            fontSize: fontSize *1.1,
                            color: Color(0XFF3E4095)
                        ),
                      ),
                    ],
                  ),
                  Divider(thickness: 0.2, color: Color(0XFF3E4095),),
                  ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: widget.offLoadingItem.items!.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index){
                        Item CurrentItem = widget.offLoadingItem.items![index];
                        return PaidGoodsItem(
                          items: CurrentItem,
                        );
                      }),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      'Grand Total (KES): ${formatNumb(widget.offLoadingItem.totalAmount.toString())}',
                      style: GoogleFonts.manrope(
                        fontSize: fontSize * 1,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                       Icon(
                          Icons.receipt,
                          color: Color(0XFF3E4095)
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        'Receipt Details',
                        style: GoogleFonts.manrope(
                            fontWeight: FontWeight.bold,
                            fontSize: fontSize *1.1,
                            color: Color(0XFF3E4095)
                        ),
                      ),
                    ],
                  ),
                  Divider(thickness: 0.2, color: Color(0XFF3E4095),),
                  Row(
                    children: [
                      SizedBox(
                        width: screenWidth * 0.37,
                        child:Text(
                          'Receipt No:',
                          style: GoogleFonts.manrope(
                            fontSize: fontSize * 1,
                            // fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: size.width * 0.04,
                      ),
                      Flexible(
                        child:  Text(
                          widget.offLoadingItem.receiptId == null ? "N/A" :  "#${widget.offLoadingItem.receiptId.toString()}",
                          style: GoogleFonts.manrope(
                            fontSize: fontSize * 1,
                            // fontWeight: FontWeight.w500,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),)
                    ],
                  ),
                  SizedBox(
                    height: size.height * 0.011,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: screenWidth * 0.37,
                        child:Text(
                          'Receipt Date:',
                          style: GoogleFonts.manrope(
                            fontSize: fontSize * 1,
                            // fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: size.width * 0.04,
                      ),
                      Flexible(
                        child:  Text(
                            // widget.offLoadingItem.receiptDate == null ? "N/A" :   DateFormat('yyyy-MM-dd').format(widget.offLoadingItem.updatedDate!),
                          widget.offLoadingItem.receiptDate == null ? "N/A" :  widget.offLoadingItem.receiptDate!.toString(),

                          style: GoogleFonts.manrope(
                            fontSize: fontSize * 1,
                            // fontWeight: FontWeight.w500,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),)
                    ],
                  ),
                  SizedBox(
                    height: size.height * 0.011,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: screenWidth * 0.37,
                        child:Text(
                          'Receipt Amount:',
                          style: GoogleFonts.manrope(
                            fontSize: fontSize * 1,
                            // fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: size.width * 0.04,
                      ),
                      Flexible(
                        child:  Text(
                        formatNumb(  widget.offLoadingItem.totalAmount!),
                          style: GoogleFonts.manrope(
                            fontSize: fontSize * 1,
                            // fontWeight: FontWeight.w500,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),)
                    ],
                  ),
                  SizedBox(
                    height: size.height * 0.011,
                  ),
                  SizedBox(height: 20,),
                  // Row(
                  //   crossAxisAlignment: CrossAxisAlignment.center,
                  //   children: [
                  //     Icon(
                  //       Icons.list,
                  //       color: Color(0XFF3E4095),
                  //       size: fontSize* 2,
                  //     ),
                  //     SizedBox(
                  //       width: 5,
                  //     ),
                  //     Flexible(
                  //       child: Text(
                  //         'Verification Details at Mombasa County',
                  //         style: GoogleFonts.manrope(
                  //             fontWeight: FontWeight.bold,
                  //             fontSize: fontSize *1.1,
                  //             color: Color(0XFF3E4095)
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // Divider(thickness: 0.2, color: Color(0XFF3E4095),),
                  // SizedBox(height: 10,),
                  // Row(
                  //     children: [
                  //       SizedBox(
                  //         width: screenWidth * 0.35,
                  //         child: Column(
                  //           crossAxisAlignment:
                  //           CrossAxisAlignment.start,
                  //           children: [
                  //             Text(
                  //               'Approval Date:',
                  //               style: GoogleFonts.manrope(
                  //                 fontSize: fontSize * 1,
                  //                 // fontWeight: FontWeight.w500,
                  //                 color: Colors.black,
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //       SizedBox(
                  //         width: size.width * 0.04,
                  //       ),
                  //       Flexible(
                  //         child: Column(
                  //           crossAxisAlignment:
                  //           CrossAxisAlignment.start,
                  //           children: [
                  //             Text(
                  //               widget.offLoadingItem.updatedDate.toString(),
                  //               style: GoogleFonts.manrope(
                  //                 fontSize: fontSize * 1,
                  //                 // fontWeight: FontWeight.w500,
                  //                 color: Colors.black.withOpacity(0.7),
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //     ]),
                  // SizedBox(
                  //   height: size.height * 0.011,
                  // ),
                  // Row(
                  //     children: [
                  //       SizedBox(
                  //         width: screenWidth * 0.35,
                  //         child: Column(
                  //           crossAxisAlignment:
                  //           CrossAxisAlignment.start,
                  //           children: [
                  //             Text(
                  //               'Enforcer Name:',
                  //               style: GoogleFonts.manrope(
                  //                 fontSize: fontSize * 1,
                  //                 // fontWeight: FontWeight.w500,
                  //                 color: Colors.black,
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //       SizedBox(
                  //         width: size.width * 0.04,
                  //       ),
                  //       Flexible(
                  //         child: Column(
                  //           crossAxisAlignment:
                  //           CrossAxisAlignment.start,
                  //           children: [
                  //             Text(
                  //               widget.offLoadingItem.enforcerName.toString(),
                  //               style: GoogleFonts.manrope(
                  //                 fontSize: fontSize * 1,
                  //                 // fontWeight: FontWeight.w500,
                  //                 color: Colors.black.withOpacity(0.7),
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //     ]),
                  // SizedBox(
                  //   height: size.height * 0.011,
                  // ),
                  // SizedBox(height: 30,),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PaidGoodsItem extends StatefulWidget {
  Item items;
  PaidGoodsItem({
    required this.items
  });

  @override
  State<PaidGoodsItem> createState() => _PaidGoodsItemState();
}

class _PaidGoodsItemState extends State<PaidGoodsItem> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final imageDimension = screenWidth / 3.3;
    final fontSize = screenWidth / 28.0;

    String formatNumb(String numb) {
      final NumberFormat formatter = NumberFormat("#,##0.00", "en_US");
      double numberr = double.parse(numb);
      return formatter.format(numberr);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width:screenWidth*0.4,
              child: Row(
                children: [
                  Text('Item:',  style: GoogleFonts.manrope(
                    fontSize: fontSize * 1,
                    // fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),),
                  SizedBox(
                    width: size.width * 0.01,
                  ),
                  Flexible(
                    child: Text(widget.items.itemName.toString(),
                        style: GoogleFonts.manrope(
                          fontSize: fontSize * 1,
                          // fontWeight: FontWeight.w500,
                          color: Colors.black.withOpacity(0.7),
                        )),
                  )
                ],
              ),
            ),

            Flexible(
              child: Row(
                children: [
                  Text('U.O.M:',  style: GoogleFonts.manrope(
                    fontSize: fontSize * 1,
                    // fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),),
                  SizedBox(
                    width: size.width * 0.01,
                  ),
                  Expanded(
                    child: Text(widget.items.uom.toString(),
                        style: GoogleFonts.manrope(
                          fontSize: fontSize * 1,
                          // fontWeight: FontWeight.w500,
                          color: Colors.black.withOpacity(0.7),
                        )),
                  )
                ],
              ),
            )
          ],
        ),
        SizedBox(
          height: size.height * 0.009,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width:screenWidth*0.4,
              child: Row(
                children: [
                  Text('Quantity:',  style: GoogleFonts.manrope(
                    fontSize: fontSize * 1,
                    // fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),),
                  SizedBox(
                    width: size.width * 0.013,
                  ),
                  Text(widget.items.quantity.toString(),
                    style: GoogleFonts.manrope(
                      fontSize: fontSize * 1,
                      // fontWeight: FontWeight.w500,
                      color: Colors.black.withOpacity(0.7),
                    ),)
                ],
              ),
            ),
            Flexible(
              child: Row(
                children: [
                  Text('Rate:',  style: GoogleFonts.manrope(
                    fontSize: fontSize * 1,
                    // fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),),
                  SizedBox(
                    width: size.width * 0.01,
                  ),
                  Expanded(
                    child: Text((formatNumb(widget.items.amount.toString())),
                        style: GoogleFonts.manrope(
                          fontSize: fontSize * 1,
                          // fontWeight: FontWeight.w500,
                          color: Colors.black.withOpacity(0.7),
                        )),
                  )
                ],
              ),
            )
          ],
        ),
        SizedBox(
          height: size.height * 0.009,
        ),
        Row(
          children: [
            Text('Amount:',  style: GoogleFonts.manrope(
              fontSize: fontSize * 1,
              // fontWeight: FontWeight.w500,
              color: Colors.black,
            ),),
            SizedBox(
              width: size.width * 0.01,
            ),
            Flexible(
              child: Text(formatNumb(widget.items.totalAmount.toString() ) ,
                  style: GoogleFonts.manrope(
                    fontSize: fontSize * 1,
                    // fontWeight: FontWeight.w500,
                    color: Colors.black.withOpacity(0.7),
                  )),
            )
          ],
        ),
        Divider(),
      ],
    );
  }
}

