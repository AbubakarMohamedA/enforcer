import 'package:enforcer/Screens/OffLoading/penalizePromptPayment.dart';
import 'package:enforcer/Screens/OffLoading/promptPayment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../Models/Offloading/getLastCessMadeApplication.dart';


class offBoardingDetails extends StatefulWidget {
  GetVehicleLastPaymentCess? lastApplication;
  var token;
  final Function? offLoadingCallback;
  final Function? CheckPaymentDialogCallback;

  offBoardingDetails({
    this.lastApplication,
    required this.token,
    required this.offLoadingCallback,
    required this.CheckPaymentDialogCallback
  });

  @override
  State<offBoardingDetails> createState() => _offBoardingDetailsState();
}

class _offBoardingDetailsState extends State<offBoardingDetails> {

  bool isChecked = true;


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



    final items = widget.lastApplication!.data!.items;

// Calculate the grand total
    double grandTotal = items!.fold(0.0, (total, item) {
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
          "Last Application Made",
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
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        backgroundColor: const Color(0xFF2E6BC4),
        spacing: 12,
        overlayColor: Colors.black12,
        overlayOpacity: 0.5,
        spaceBetweenChildren: 2,
        childMargin: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        children: [
          SpeedDialChild(
            child:
            Center(
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Image.asset("assets/images/penalty.png"),
              ),
            ),
            // Icon(Icons.payment, color: Colors.white),
            labelBackgroundColor: Colors.white,
            label: "Initiate Penalty",
            backgroundColor: Colors.redAccent,
            onTap: () {
              // Add your onTap logic here
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (c) =>
                          PenalizepromptOffLoadingPayment(
                            token: widget.token,
                            CheckPaymentDialogCallback: widget.CheckPaymentDialogCallback,
                            navigateBackAgain: 'Thrice',
                            capturedOrigin: widget.lastApplication?.data?.goodsOrigin,
                            capturedVehicleType: widget.lastApplication?.data?.vehicleType,
                            capturedVehicleId: widget.lastApplication?.data?.vehicleId,
                            capturedPlate: widget.lastApplication?.data?.plateNo,
                            capturedClientName: widget.lastApplication?.data?.citizenName,
                            capturedPhone: widget.lastApplication?.data?.citizenMobile,
                          )));
            },
          ),
          // if(widget.lastApplication.status == "Unpaid")
          SpeedDialChild(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image.asset("assets/images/promptPayment.png"),
            ),
            // Icon(Icons.payment, color: Colors.white),
            labelBackgroundColor: Colors.white,
            label: "Prompt Payment",
            backgroundColor: Colors.green,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (c) =>
                          promptOffLoadingPayment(
                            token: widget.token,
                            capturedOrigin: widget.lastApplication?.data?.goodsOrigin,
                            CheckPaymentDialogCallback: widget.CheckPaymentDialogCallback,
                            navigateBackAgain: "Thrice",
                            capturedPlate: widget.lastApplication?.data?.plateNo,
                            capturedVehicleId: widget.lastApplication?.data?.vehicleId,
                            capturedClientName: widget.lastApplication?.data?.citizenName,
                            capturedPhone: widget.lastApplication?.data?.citizenMobile,
                          )));
              // Add your onTap logic here
            },
          ),
        ],
      ),

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
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                  Divider(thickness: 0.2, color: Color(0XFF3E4095),
                  ),
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
                          widget.lastApplication!.data!.citizenName.toString(),
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
                          // DateFormat('yyyy-MM-dd').format(widget.lastApplication!.data!.createdDate!),
                          widget.lastApplication!.data!.createdDate!.toString(),
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
                          'Account Type:',
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
                          widget.lastApplication!.data!.accountType.toString(),
                          style: GoogleFonts.manrope(
                            fontSize: fontSize * 1,
                            // fontWeight: FontWeight.w500,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),),
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
                          widget.lastApplication!.data!.citizenMobile.toString(),
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
                            // color: widget.lastApplication!.data!.status == "Closed" ? Colors.black : Colors.green,
                            color: widget.lastApplication!.data!.status == "Closed" ? Colors.black : widget.lastApplication!.data!.status == "Open" ? Colors.green : Color(0xFFFF8919),
                          ),
                          child: Padding(
                            padding:  EdgeInsets.all(6.0),
                            child: Text(
                              widget.lastApplication!.data!.status.toString(),
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
                  Divider(thickness: 0.2, color: Color(0XFF3E4095),
                  ),
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
                          "#${widget.lastApplication!.data!.applicationId.toString()}",
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
                          'Application Type:',
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
                          (widget.lastApplication!.data!.applicationType!),
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
                          widget.lastApplication!.data!.vehicleType.toString(),
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
                          widget.lastApplication!.data!.plateNo.toString(),
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
                          'Entry Station:',
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
                          widget.lastApplication!.data!.station.toString(),
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
                              widget.lastApplication!.data!.goodsOrigin.toString(),
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
                  SizedBox(
                    height: size.height * 0.011,
                  ),
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
                              widget.lastApplication!.data!.goodsDestination.toString(),
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
                  Divider(thickness: 0.2, color: Color(0XFF3E4095),
                  ),
                  ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: widget.lastApplication!.data!.items!.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index){
                        Item items =  widget.lastApplication!.data!.items![index];
                        return PaidGoodsItem(
                          items: items,
                        );

                      }),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      'Grand Total (KES): ${formatNumb(grandTotal.toString())}',
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
                      const Icon(
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
                  Divider(thickness: 0.2, color: Color(0XFF3E4095),
                  ),
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
                          "#${widget.lastApplication!.data!.id.toString()}",
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
                          DateFormat('yyyy-MM-dd').format(widget.lastApplication!.data!.createdDate!),
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
                          'Payment Mode:',
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
                          widget.lastApplication!.data!.paymentMode!,
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
                          'Ref Number:',
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
                          widget.lastApplication!.data!.transactionCode!,
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
                          'Ref Bank:',
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
                          widget.lastApplication!.data!.paymentBank!,
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
                          'Amount Paid:',
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
                          formatNumb(widget.lastApplication!.data!.receiptTotal.toString())!,
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.list,
                        color: Color(0XFF3E4095),
                        size: fontSize* 2,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Flexible(
                        child: Text(
                          'Verification Details at Mombasa County Entry',
                          style: GoogleFonts.manrope(
                              fontWeight: FontWeight.bold,
                              fontSize: fontSize *1.1,
                              color: Color(0XFF3E4095)
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(thickness: 0.2, color: Color(0XFF3E4095),
                  ),
                  SizedBox(height: 10,),
                  Row(
                      children: [
                        SizedBox(
                          width: screenWidth * 0.35,
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Approval Date:',
                                style: GoogleFonts.manrope(
                                  fontSize: fontSize * 1,
                                  // fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: size.width * 0.04,
                        ),
                        Flexible(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.lastApplication!.data!.createdDate.toString(),
                                style: GoogleFonts.manrope(
                                  fontSize: fontSize * 1,
                                  // fontWeight: FontWeight.w500,
                                  color: Colors.black.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]),
                  SizedBox(
                    height: size.height * 0.011,
                  ),
                  Row(
                      children: [
                        SizedBox(
                          width: screenWidth * 0.35,
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Approving Officer:',
                                style: GoogleFonts.manrope(
                                  fontSize: fontSize * 1,
                                  // fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: size.width * 0.04,
                        ),
                        Flexible(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.lastApplication!.data!.createdByStaffName.toString(),
                                style: GoogleFonts.manrope(
                                  fontSize: fontSize * 1,
                                  // fontWeight: FontWeight.w500,
                                  color: Colors.black.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]),
                  SizedBox(
                    height: size.height * 0.011,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: screenWidth * 0.35,
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [

                            Text(
                              'Status:',
                              style: GoogleFonts.manrope(
                                fontSize: fontSize * 1,
                                // fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),


                          ],
                        ),
                      ),
                      SizedBox(
                        width: size.width * 0.04,
                      ),
                      Flexible(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                // color: Colors.green,
                                color: widget.lastApplication!.data!.status == "Closed" ? Colors.black : widget.lastApplication!.data!.status == "Open" ? Colors.green : Color(0xFFFF8919),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Text(
                                  // "APPROVED",
                                  widget.lastApplication!.data!.status.toString(),
                                  style: GoogleFonts.manrope(
                                      color: Colors.white,
                                      fontSize: fontSize * 0.85
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: size.height * 0.011,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30,),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class PaidGoodsItem extends StatelessWidget {
  Item items;
  PaidGoodsItem({
    required this.items

  });



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
                    child: Text((items.item.toString()),
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
                    child: Text((items.uom.toString()),
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
                  Text(items.totalQuantity.toString(),
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
                    child: Text((formatNumb(items.rate.toString())),
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
              child: Text((formatNumb(items.totalAmount.toString())),
                  style: GoogleFonts.manrope(
                    fontSize: fontSize * 1,
                    // fontWeight: FontWeight.w500,
                    color: Colors.black.withOpacity(0.7),
                  )),
            )
          ],
        ),
        const Divider(),
      ],
    );
  }
}

