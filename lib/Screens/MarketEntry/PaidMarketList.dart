import 'dart:ui';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../Api/api_provider.dart';
import '../../Models/MarketEntryModel/getMarketStats.dart';
import '../../Models/HawkersModel/getLocations.dart';
import '../../Models/HawkersModel/getZones.dart';
import '../../Models/MarketEntryModel/paidMarket.dart';
import '../../error_page.dart';

class paidMarket extends StatefulWidget {
  var token;
  paidMarket({required this.token});

  @override
  State<paidMarket> createState() => _paidMarketState();
}

class _paidMarketState extends State<paidMarket>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    paidMarketFuture = ApiProvider().getPaidMarket(token: widget.token);
    zonesFuture  =  ApiProvider().getZones(token: widget.token);
  }

  Future<PaidMarket>? paidMarketFuture;
  List<PaidMarketDatum>? paidMarketList;


  late Future<GetZones> zonesFuture;
  List<Datum>? zonesData;


  final _formKey = GlobalKey<FormState>();
  TextEditingController _marketIdController = TextEditingController();
  TextEditingController _marketNameController = TextEditingController();
  String? marketZoneId;
  bool zoneSelected = false;

  Datum? selectedZone;



  bool expandItems = false;

  bool filterAllocated = false;


  //Locations
  late Future<GetLocations> locationsFuture;
  List<LocationsDatum>? AllLocationsData;
  LocationsDatum? selectedDropdownLocation;
  List<LocationsDatum>? speicifcLocationsData;
  Future<GetLocations> loadLocations(marketZoneId) async {
    try {
      locationsFuture =  ApiProvider()
          .getLocations(token: widget.token, zoneId: marketZoneId);
      // Sort the list in descending order based on the apply date
      return locationsFuture;
    } catch (e) {
      // Handle error
      print('Error loading leave applications: $e');
      throw e; // Re-throw the error to propagate it to the FutureBuilder
    }
  }




  bool _isFiltering = false;
  bool _isReseting = false;
  List<PaidMarketDatum>? filteredPaidMarket;


  List<String> location = [
    "Majengo",
    "Nyali",
    "Kizingo",
    "Shanzu"
  ];
  String? selectedLocation;
  TextEditingController _marketLocationleController = TextEditingController();


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
        automaticallyImplyLeading: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        toolbarHeight: 80,
        title: Text(
          "Daily Paid Markets",
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
        child: FutureBuilder<PaidMarket>(
          future: paidMarketFuture, // Replace with your future function
          builder: (context, AsyncSnapshot<PaidMarket> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child:
                      CircularProgressIndicator(color: Color(0XFF3E4095)));
            } else if (!snapshot.hasData || snapshot.hasError) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: ErrorFetching(
                        message: "${snapshot.error}", onPressed: () {}),
                  ),
                ],
              );
            } else {
              paidMarketList = snapshot.data!.data!;

              print("The paid markets list length is ${filteredPaidMarket}");

              if (paidMarketList!.isEmpty) {
                return ScrollConfiguration(
                  behavior: ScrollBehavior().copyWith(overscroll: false),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'assets/lotti/no-data.json',
                        // width: context.width() * 0.7,
                        // height: context.height() * 0.15,
                        width: ContextExtensions(context).width() * 0.9,
                        height: ContextExtensions(context).height() * 0.2,
                      ),
                      Column(
                        children: [
                          Text(
                            'No paid Markets yet.',

                            style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w600,
                                fontSize: fontSize * 1.2),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Kindly prompt one to view.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w500,
                                fontSize: fontSize * 1.3
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              } else {
                return ScrollConfiguration(
                  behavior: ScrollBehavior().copyWith(overscroll: false),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                          child: Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(top: 10, ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Column(
                              children: [
                                Column(
                                  children: [
                                    // InkWell(
                                    //   onTap: () {
                                    //     setState(() {
                                    //       expandItems = !expandItems;
                                    //     });
                                    //   },
                                    //   child: Container(
                                    //     width: context.width(),
                                    //     padding: const EdgeInsets.all(20.0),
                                    //     decoration: BoxDecoration(
                                    //       borderRadius: BorderRadius.only(
                                    //         topRight: Radius.circular(10.0),
                                    //         topLeft: Radius.circular(10.0),
                                    //       ),
                                    //       color: Color(0xFF414046).withOpacity(0.2),
                                    //     ),
                                    //     child:  Row(
                                    //       crossAxisAlignment:
                                    //       CrossAxisAlignment.center,
                                    //       children: [
                                    //         const Icon(
                                    //           Icons
                                    //               .add_circle_outline_outlined,
                                    //           color: Colors.black,
                                    //         ),
                                    //         const SizedBox(
                                    //           width: 5,
                                    //         ),
                                    //         const Text(
                                    //           'Filter',
                                    //           style: TextStyle(
                                    //             fontWeight: FontWeight.bold,
                                    //           ),
                                    //         ),
                                    //         const Spacer(),
                                    //         Icon(
                                    //           expandItems
                                    //               ? Icons.expand_less
                                    //               : Icons.expand_more,
                                    //           color: Colors.black,
                                    //         ),
                                    //       ],
                                    //     ),
                                    //   ),
                                    // ),
                                  ],
                                ),
                                if (expandItems)
                                  AnimatedContainer(
                                    duration:
                                    const Duration(milliseconds: 500),
                                    curve: Curves.easeInOut,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border(
                                          left: BorderSide(
                                            color: Colors.grey.withOpacity(0.5),
                                            width: 1.0,
                                          ),
                                          right: BorderSide(
                                            color: Colors.grey.withOpacity(0.5),
                                            width: 1.0,
                                          ),
                                          bottom: BorderSide(
                                            color: Colors.grey.withOpacity(0.5),
                                            width: 1.0,
                                          ),
                                        ),
                                      ),
                                      child:   Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                        child: Column(
                                          crossAxisAlignment:CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 15,),

                                            TextFormField(
                                              controller: _marketNameController,
                                              keyboardType: TextInputType.emailAddress,
                                              textInputAction: TextInputAction.next,
                                              decoration: InputDecoration(
                                                hintText: 'Enter Market Name',
                                                hintStyle: GoogleFonts.manrope(fontSize: fontSize),
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(14),
                                                  borderSide: const BorderSide(color: Color(0xFF46B1FD)),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 15),

                                            TextFormField(
                                              controller: _marketIdController,
                                              keyboardType: TextInputType.number,
                                              textInputAction: TextInputAction.next,
                                              decoration: InputDecoration(
                                                hintText: 'Enter Market ID',
                                                hintStyle: GoogleFonts.manrope(fontSize: fontSize),
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(14),
                                                  borderSide: const BorderSide(color: Color(0xFF46B1FD)),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 15),

                                            FutureBuilder<GetZones>(
                                              future: zonesFuture!,
                                              builder: (context,
                                                  AsyncSnapshot<GetZones>
                                                  snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return createDisabledDropdownSearch(
                                                      "Fetching Zones.....");
                                                } else if (snapshot.hasError) {
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
                                                      itemAsString: (Datum? zones) =>
                                                      zones?.name?? '',
                                                      selectedItem: selectedZone,
                                                      dropdownSearchDecoration:
                                                      InputDecoration(
                                                        // labelText: "Zones ",
                                                        hintText: "Select Zone ",
                                                        hintStyle: GoogleFonts.manrope(fontSize: fontSize),
                                                        disabledBorder:
                                                        OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                            color: Color(0xFF1366D9),
                                                            width: 1.0,
                                                          ),
                                                        ),
                                                      ),
                                                      onChanged: (Datum? selectedzone) {
                                                        if (selectedzone != null) {
                                                          setState(() {
                                                            selectedZone = selectedzone;
                                                            marketZoneId = selectedzone!.id.toString();
                                                            zoneSelected = true;
                                                            locationsFuture = loadLocations(marketZoneId);
                                                            selectedDropdownLocation = null;
                                                            selectedLocation = null;
                                                          });
                                                        }
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
                                            const SizedBox(height: 10),
                                            zoneSelected ?

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
                                                  // speicifcLocationsData = AllLocationsData!.where((element) => element.zoneId == marketZoneId).toList();

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
                                              controller: _marketLocationleController,
                                              keyboardType: TextInputType.emailAddress,
                                              textInputAction: TextInputAction.next,
                                              decoration: InputDecoration(
                                                hintText: 'Location',
                                                hintStyle: GoogleFonts.manrope(fontSize: fontSize),
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(14),
                                                  borderSide: BorderSide(
                                                    color: Color(0xFF46B1FD),
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
                                            const SizedBox(height: 10),
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
                                                        // if(filteredPaidMarket == null){
                                                        //
                                                        // }else{
                                                        //   resetFilter();
                                                        // }
                                                        if (_marketNameController.text.isNotEmpty ||
                                                            _marketIdController.text.isNotEmpty ||
                                                            marketZoneId != null ||
                                                            selectedLocation != null) {
                                                          resetFilter();
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
                                                        MaterialStateProperty.all<Color>( Color(0XFF3E4095),),
                                                        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                                        minimumSize: MaterialStateProperty.all<Size>(
                                                          const Size(double.infinity, 65),
                                                        ),
                                                      ),
                                                      child: _isReseting // Display loading indicator if filtering is ongoing
                                                          ? CircularProgressIndicator(
                                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                      )
                                                          : Text(
                                                        'Reset',
                                                        style: GoogleFonts.manrope(
                                                          fontSize: fontSize * 1.2,
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
                                                        if(_marketNameController.text.isEmpty && _marketIdController.text.isEmpty && marketZoneId == null && selectedLocation == null){
                                                          Get.snackbar(
                                                                'Cannot Filter',
                                                                'Please Select a parameter first',
                                                                  backgroundColor: Colors.redAccent.withOpacity(0.8),
                                                                  colorText: Colors.white,
                                                                  snackPosition: SnackPosition.TOP, // Adjust position if needed
                                                                  duration: Duration(seconds: 2), // Adjust duration if needed
                                                                  margin: EdgeInsets.only(left: 16.0,right: 16), // Adjust margin if needed
                                                                  borderRadius: 10.0, // Adjust border radius if needed
                                                                );
                                                        } else{
                                                          filterPaidMarket();
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
                                                          const Size(double.infinity, 65),
                                                        ),
                                                      ),
                                                      child:_isFiltering // Display loading indicator if filtering is ongoing
                                                          ? CircularProgressIndicator(
                                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                           )
                                                          :  Text(
                                                        'Apply Filter',
                                                        style: GoogleFonts.manrope(
                                                          fontSize: fontSize * 1.2,
                                                          fontWeight: FontWeight.w500,
                                                          color: Color(0xFF3E4095),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 15,),

                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                      ),
                      ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: (filteredPaidMarket == null) ?  paidMarketList!.length : filteredPaidMarket!.length,
                          itemBuilder: (context, index) {
                            PaidMarketDatum marketDetails = (filteredPaidMarket == null) ? paidMarketList![index]: filteredPaidMarket![index] ;
                            Color backgroundColor = index % 2 == 0
                                ? Colors.lightBlueAccent.withOpacity(0.1)
                                : Colors.white;
                              return InkWell(
                                  onTap: () {
                                    FocusScope.of(context).unfocus();
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20.0),
                                          ),
                                          child: Container(
                                            width: MediaQuery.of(context).size.width * 0.8,
                                            //height: MediaQuery.of(context).size.height * 0.56,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(20.0),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(0.5),
                                                  spreadRadius: 5,
                                                  blurRadius: 7,
                                                  offset: Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: SingleChildScrollView(
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(height: 20),
                                                    Center(
                                                      child: Text(
                                                        "Market Details",
                                                        textAlign: TextAlign.center,
                                                        style: GoogleFonts.manrope(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 18,
                                                          color: Color(0XFF3E4095),
                                                        ),
                                                      ),
                                                    ),
                                                    // SizedBox(height: 17),
                                                    // buildRichText2('Plate/ID: ', marketDetails.marketName.toString(), fontSize, ),
                                                    SizedBox(height: 7),
                                                    buildRichText2('Mobile: ', marketDetails.marketMobile.toString(), fontSize, ),
                                                    SizedBox(height: 7),
                                                    buildRichText2('Code: ', marketDetails.transactionCode.toString(), fontSize, ),
                                                    SizedBox(height: 7),
                                                    buildRichText2('Amount: ',  marketDetails.categories.toString(), fontSize, ),

                                                    SizedBox(height: 5),
                                                    Align(
                                                      alignment: Alignment.centerRight,
                                                      child: TextButton(
                                                        onPressed: () => Navigator.of(context).pop(false),
                                                        style: TextButton.styleFrom(
                                                          backgroundColor: Colors.red,
                                                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                                        ),
                                                        child: Text('Close',style: GoogleFonts.montserrat(color: Colors.white),),
                                                      ),
                                                    ),

                                                    SizedBox(height: 20),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    color: backgroundColor,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 20.0, horizontal: 15),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          // Row(
                                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          //   crossAxisAlignment: CrossAxisAlignment.start,
                                          //   children: [
                                          //     // Expanded(
                                          //     //     child: buildRichText('Plate/ID: ', marketDetails.marketName.toString(), fontSize)),
                                          //     // SizedBox(width: screenWidth * 0.015),
                                          //     Expanded(
                                          //         child: buildRichText('Mobile: ', marketDetails.marketMobile.toString(), fontSize)),
                                          //   ],
                                          // ),
                                          // SizedBox(height: 15),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                  child: buildRichText('Mobile: ', marketDetails.marketMobile.toString(), fontSize)),
                                              SizedBox(width: screenWidth * 0.015),
                                              Expanded(
                                                  child: buildRichText('Code: ', marketDetails.transactionCode.toString(), fontSize)),
                                              SizedBox(width: screenWidth * 0.015),
                                              Expanded(
                                                  child: buildRichText('Amount: ', marketDetails.categories.toString(), fontSize)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );

                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return Divider(height: 0); // Set the height of the divider to 0
                          },
                        )
                      ],
                    ),
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }


  Widget buildRichText(String firstText, String secondText, double fontSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(TextSpan(children: [
          TextSpan(
            text: firstText,
            style: GoogleFonts.montserrat(
              fontSize: fontSize * 1,
              fontWeight: FontWeight.w500,
              color: Color(0XFF3E4095),
            ),
          ),
          TextSpan(
            text: secondText,
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w400,
              color: Colors.black.withOpacity(0.9),
              fontSize: fontSize * 0.9,
            ),
          )
        ])),
      ],
    );
  }
  Widget buildRichText2(String firstText, String secondText, double fontSize,) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Row(
          children: [
            Expanded(
              flex: 1,
              child: Text(
                firstText,
                style: GoogleFonts.montserrat(
                  fontSize: fontSize * 1,
                  fontWeight: FontWeight.w500,
                  color: Color(0XFF3E4095),
                ),
              ),
            ),
            SizedBox(width: 20,),
            Expanded(
              flex: 2,
              child: Text(
                secondText ?? "N/A",
              style: GoogleFonts.montserrat(
              color: Colors.black.withOpacity(0.8),
              fontSize: fontSize * 0.9,
            ),
              ),
            ),
          ],
        ),
        // Row(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: [
        //     Expanded(
        //       flex: 1,
        //       child: Text(
        //         firstText,
        //         style: GoogleFonts.montserrat(
        //           fontSize: fontSize * 1,
        //           fontWeight: FontWeight.w500,
        //           color: Color(0XFF3E4095),
        //         ),
        //       ),
        //     ),
        //    SizedBox(width: 20,),
        //     Expanded(
        //       flex: 1,
        //       child: Text(
        //         secondText,
        //         style: GoogleFonts.montserrat(
        //           color: Colors.black.withOpacity(0.8),
        //           fontSize: fontSize * 0.9,
        //         ),
        //       ),
        //     )
        //   ],
        // ),
        SizedBox(
          height: 11,
        )
      ],
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



  void _showBottomSheet(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final imageDimension = screenWidth / 3.3;
    final fontSize = screenWidth / 28.0;
    double numberr = 0.0;



    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // to make it full screen
      backgroundColor: Colors.grey[200],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Container(
          height: screenHeight * 0.55,
          padding: const EdgeInsets.all(17.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: ListView(
            children: <Widget>[
              Center(
                child: Container(
                  height: 3,
                  width: 60,
                  color: Colors.grey[300],
                  margin: EdgeInsets.only(bottom: 20),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Market Name',
                    style: GoogleFonts.manrope(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _marketNameController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      hintText: 'Enter Market Name',
                      hintStyle: GoogleFonts.manrope(fontSize: fontSize),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFF46B1FD)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Simplified filter: Only by Name (Plate/ID)
                  const SizedBox(height: 10),

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
                      onPressed: () async{

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
                      child:Text(
                        'Apply Filter',
                        style: GoogleFonts.manrope(
                          fontSize: fontSize * 1.2,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF3E4095),
                        ),
                      ),
                    ),
                  ),


                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> resetFilter()async {
    setState(() {
      _isReseting = true; // Set _isFiltering to true when filtering starts
    });

    // Perform filtering
    // Simulate filtering process with a delay of 1 second
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _marketIdController.clear();
      _marketNameController.clear();
      selectedZone = null;
      marketZoneId = null;
      selectedDropdownLocation = null;
      selectedLocation = null;

      filteredPaidMarket = null;
      _isReseting = false;
    });
  }


  Future<void> filterPaidMarket() async {
    setState(() {
      _isFiltering = true; // Set _isFiltering to true when filtering starts
    });

    // Perform filtering
    // Simulate filtering process with a delay of 1 second
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      filteredPaidMarket = paidMarketList?.where((market) {
        bool matchesMarketName = true;

        if (_marketNameController.text.isNotEmpty) {
          matchesMarketName = market.marketName!.toLowerCase().contains(_marketNameController.text.toLowerCase());
        }

        return matchesMarketName;
      }).toList();
      print("The value is ${filteredPaidMarket!.length}");
      _isFiltering = false;
      expandItems = !expandItems;
    });
  }

}

class Market {
  String marketName;
  String marketMobile;
  int marketId;
  int amount;
  String zoneName;
  String transactionCode;

  Market({
    required this.marketName,
    required this.marketMobile,
    required this.marketId,
    required this.amount,
    required this.zoneName,
    required this.transactionCode
  });
}

List<Market> markets = [
  Market(
      marketName: 'John Doe',
      marketMobile: '123-456-7890',
      marketId: 1001,
      amount: 500,
      zoneName: 'Zone A',
      transactionCode: "T12345"
  ),
  Market(
      marketName: 'Jane Smith',
      marketMobile: '234-567-8901',
      marketId: 1002,
      amount: 600,
      zoneName: 'Zone B',
      transactionCode: "T23456"
  ),
  Market(
      marketName: 'Alice Johnson',
      marketMobile: '345-678-9012',
      marketId: 1003,
      amount: 700,
      zoneName: 'Zone C',
      transactionCode: "T34567"
  ),
  Market(
      marketName: 'Bob Brown',
      marketMobile: '456-789-0123',
      marketId: 1004,
      amount: 800,
      zoneName: 'Zone D',
      transactionCode: "T45678"
  ),
  Market(
      marketName: 'Charlie Davis',
      marketMobile: '567-890-1234',
      marketId: 1005,
      amount: 900,
      zoneName: 'Zone E',
      transactionCode: "T56789"
  ),
  Market(
      marketName: 'Daniel Evans',
      marketMobile: '678-901-2345',
      marketId: 1006,
      amount: 550,
      zoneName: 'Zone F',
      transactionCode: "T67890"
  ),
  Market(
      marketName: 'Eve White',
      marketMobile: '789-012-3456',
      marketId: 1007,
      amount: 650,
      zoneName: 'Zone G',
      transactionCode: "T78901"
  ),
  Market(
      marketName: 'Frank Green',
      marketMobile: '890-123-4567',
      marketId: 1008,
      amount: 750,
      zoneName: 'Zone H',
      transactionCode: "T89012"
  ),
  Market(
      marketName: 'Grace Hall',
      marketMobile: '901-234-5678',
      marketId: 1009,
      amount: 850,
      zoneName: 'Zone I',
      transactionCode: "T90123"
  ),
  Market(
      marketName: 'Hank Brown',
      marketMobile: '012-345-6789',
      marketId: 1010,
      amount: 950,
      zoneName: 'Zone J',
      transactionCode: "T01234"
  ),
  Market(
      marketName: 'Ivy Black',
      marketMobile: '123-456-7891',
      marketId: 1011,
      amount: 500,
      zoneName: 'Zone K',
      transactionCode: "T11223"
  ),
  Market(
      marketName: 'Jack White',
      marketMobile: '234-567-8902',
      marketId: 1012,
      amount: 600,
      zoneName: 'Zone L',
      transactionCode: "T22334"
  ),
  Market(
      marketName: 'Karen Brown',
      marketMobile: '345-678-9013',
      marketId: 1013,
      amount: 700,
      zoneName: 'Zone M',
      transactionCode: "T33445"
  ),
  Market(
      marketName: 'Larry King',
      marketMobile: '456-789-0124',
      marketId: 1014,
      amount: 800,
      zoneName: 'Zone N',
      transactionCode: "T44556"
  ),
  Market(
      marketName: 'Mona Lisa',
      marketMobile: '567-890-1235',
      marketId: 1015,
      amount: 900,
      zoneName: 'Zone O',
      transactionCode: "T55667"
  ),
  Market(
      marketName: 'Nate Grey',
      marketMobile: '678-901-2346',
      marketId: 1016,
      amount: 550,
      zoneName: 'Zone P',
      transactionCode: "T66778"
  ),
  Market(
      marketName: 'Olivia Blue',
      marketMobile: '789-012-3457',
      marketId: 1017,
      amount: 650,
      zoneName: 'Zone Q',
      transactionCode: "T77889"
  ),
  Market(
      marketName: 'Paul Black',
      marketMobile: '890-123-4568',
      marketId: 1018,
      amount: 750,
      zoneName: 'Zone R',
      transactionCode: "T88990"
  ),
];
