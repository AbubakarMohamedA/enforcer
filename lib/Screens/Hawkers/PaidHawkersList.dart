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
import '../../Models/HawkersModel/getHawkerStats.dart';
import '../../Models/HawkersModel/getLocations.dart';
import '../../Models/HawkersModel/getZones.dart';
import '../../Models/HawkersModel/paidHawkers.dart';
import '../../error_page.dart';

class paidHawkers extends StatefulWidget {
  var token;
  paidHawkers({required this.token});

  @override
  State<paidHawkers> createState() => _paidHawkersState();
}

class _paidHawkersState extends State<paidHawkers>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    paidHawkersFuture = ApiProvider().getPaidHawkers(token: widget.token);
    zonesFuture  =  ApiProvider().getZones(token: widget.token);
  }

  Future<PaidHawkers>? paidHawkersFuture;
  List<PaidHawkersDatum>? paidHawkersList;


  late Future<GetZones> zonesFuture;
  List<Datum>? zonesData;


  final _formKey = GlobalKey<FormState>();
  TextEditingController _hawkerIdController = TextEditingController();
  TextEditingController _hawkerNameController = TextEditingController();
  String? hawkerZoneId;
  bool zoneSelected = false;

  Datum? selectedZone;



  bool expandItems = false;

  bool filterAllocated = false;


  //Locations
  late Future<GetLocations> locationsFuture;
  List<LocationsDatum>? AllLocationsData;
  LocationsDatum? selectedDropdownLocation;
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




  bool _isFiltering = false;
  bool _isReseting = false;
  List<PaidHawkersDatum>? filteredPaidHawkers;


  List<String> location = [
    "Majengo",
    "Nyali",
    "Kizingo",
    "Shanzu"
  ];
  String? selectedLocation;
  TextEditingController _hawkerLocationleController = TextEditingController();


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
          "Daily Paid Hawkers",
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
        child: FutureBuilder<PaidHawkers>(
          future: paidHawkersFuture, // Replace with your future function
          builder: (context, AsyncSnapshot<PaidHawkers> snapshot) {
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
              paidHawkersList = snapshot.data!.data!;

              print("The paid hawkers list length is ${filteredPaidHawkers}");

              if (paidHawkersList!.isEmpty) {
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
                            'No paid Hawkers yet.',

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
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          expandItems = !expandItems;
                                        });
                                      },
                                      child: Container(
                                        width: context.width(),
                                        padding: const EdgeInsets.all(20.0),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(10.0),
                                            topLeft: Radius.circular(10.0),
                                          ),
                                          color: Color(0xFF414046).withOpacity(0.2),
                                        ),
                                        child:  Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons
                                                  .add_circle_outline_outlined,
                                              color: Colors.black,
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            const Text(
                                              'Filter',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const Spacer(),
                                            Icon(
                                              expandItems
                                                  ? Icons.expand_less
                                                  : Icons.expand_more,
                                              color: Colors.black,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
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
                                              controller: _hawkerNameController,
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
                                            const SizedBox(height: 15),

                                            TextFormField(
                                              controller: _hawkerIdController,
                                              keyboardType: TextInputType.number,
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
                                                            hawkerZoneId = selectedzone!.id.toString();
                                                            zoneSelected = true;
                                                            locationsFuture = loadLocations(hawkerZoneId);
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
                                                        // if(filteredPaidHawkers == null){
                                                        //
                                                        // }else{
                                                        //   resetFilter();
                                                        // }
                                                        if (_hawkerNameController.text.isNotEmpty ||
                                                            _hawkerIdController.text.isNotEmpty ||
                                                            hawkerZoneId != null ||
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
                                                        if(_hawkerNameController.text.isEmpty && _hawkerIdController.text.isEmpty && hawkerZoneId == null && selectedLocation == null){
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
                                                          filterPaidHawkers();
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
                          itemCount: (filteredPaidHawkers == null) ?  paidHawkersList!.length : filteredPaidHawkers!.length,
                          itemBuilder: (context, index) {
                            PaidHawkersDatum hawkerDetails = (filteredPaidHawkers == null) ? paidHawkersList![index]: filteredPaidHawkers![index] ;
                            String AmountPaid = formatNumb((hawkerDetails.amount ?? 0.0).toString());// Adjust this based on your `formatNumb` function
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
                                                        "Hawker Details",
                                                        textAlign: TextAlign.center,
                                                        style: GoogleFonts.manrope(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 18,
                                                          color: Color(0XFF3E4095),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 17),
                                                    buildRichText2('Name: ', hawkerDetails.hawkerName.toString(), fontSize, ),
                                                    SizedBox(height: 7),
                                                    buildRichText2('Mobile: ', hawkerDetails.hawkerMobile.toString(), fontSize, ),
                                                    SizedBox(height: 7),
                                                    buildRichText2('ID: ', hawkerDetails.hawkerId.toString(), fontSize, ),
                                                    SizedBox(height: 7),
                                                    buildRichText2('Amount: ', AmountPaid, fontSize, ),
                                                    SizedBox(height: 7),
                                                    buildRichText2('Code: ', hawkerDetails.transactionCode.toString(), fontSize, ),
                                                    SizedBox(height: 7),
                                                    buildRichText2('Zone: ', hawkerDetails.zoneName.toString(), fontSize, ),
                                                    SizedBox(height: 7),
                                                    buildRichText2('Location: ', hawkerDetails.location.toString() ?? "N/A", fontSize, ),
                                                    SizedBox(height: 7),
                                                    buildRichText2('Category: ',  hawkerDetails.categories.toString() ?? "N/A", fontSize, ),

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
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                // flex:2,
                                                  child: buildRichText('Name: ', hawkerDetails.hawkerName.toString(), fontSize)),
                                              SizedBox(width: screenWidth * 0.015),
                                              Expanded(
                                                  // flex:1,
                                                  child: buildRichText('ID: ', hawkerDetails.hawkerId.toString(), fontSize)),
                                            ],
                                          ),
                                          SizedBox(height: 15),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                  // flex:2,
                                                  child: buildRichText('Code: ', hawkerDetails.transactionCode.toString(), fontSize)),
                                              SizedBox(width: screenWidth * 0.015),
                                              Expanded(
                                                  // flex:1,
                                                  child: buildRichText('Zone: ', hawkerDetails.zoneName.toString(), fontSize)),
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
      mode: Mode.MENU,
      showSelectedItems: true,
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
      onChanged: print,
      maxHeight: 130,
      popupBackgroundColor: Colors.grey[200],
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
                  const SizedBox(height: 15),
                  Text(
                    'Hawker ID Number',
                    style: GoogleFonts.manrope(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _hawkerIdController,
                    keyboardType: TextInputType.number,
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
                  const SizedBox(height: 15),
                  Text(
                    'Hawker Zone',
                    style: GoogleFonts.manrope(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
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
                            itemAsString:
                                (Datum? zones) =>
                            zones?.name?? '',
                            dropdownSearchDecoration:
                            InputDecoration(
                              // labelText: "Zones ",
                              hintText: "Select Zone ",
                              disabledBorder:
                              OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF1366D9),
                                  width: 1.0,
                                ),
                              ),
                            ),
                            onChanged:
                                (Datum? selectedZone) {
                              if (selectedZone != null) {
                                setState(() {
                                  hawkerZoneId = selectedZone.id.toString();
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
      _hawkerIdController.clear();
      _hawkerNameController.clear();
      selectedZone = null;
      hawkerZoneId = null;
      selectedDropdownLocation = null;
      selectedLocation = null;

      filteredPaidHawkers = null;
      _isReseting = false;
    });
  }


  Future<void> filterPaidHawkers() async {
    setState(() {
      _isFiltering = true; // Set _isFiltering to true when filtering starts
    });

    // Perform filtering
    // Simulate filtering process with a delay of 1 second
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      filteredPaidHawkers = paidHawkersList?.where((hawker) {
        bool matchesHawkerName = true;
        bool matchesHawkerId = true;
        bool matchesHawkerZone = true;
        bool matchesHawkerLocation = true;

        // Check if Hawker Name matches the input
        if (_hawkerNameController.text.isNotEmpty) {
          matchesHawkerName = hawker.hawkerName!.toLowerCase().contains(_hawkerNameController.text.toLowerCase());
        }

        // Check if Hawker ID matches the input
        if (_hawkerIdController.text.isNotEmpty) {
          matchesHawkerId = hawker.hawkerId.toString().contains(_hawkerIdController.text);
        }

        // Check if Hawker Zone matches the selected zone
        if (selectedZone != null) {
          print(hawker.zoneName);
          matchesHawkerZone = hawker.zoneName == selectedZone!.name;
        }

        if (selectedLocation != null) {
          matchesHawkerLocation = hawker.location == selectedDropdownLocation!.locationName;
        }

        return matchesHawkerName && matchesHawkerId && matchesHawkerZone && matchesHawkerLocation;
      }).toList();
      print("The value is ${filteredPaidHawkers!.length}");
      _isFiltering = false;
      expandItems = !expandItems;
    });
  }

}

class Hawker {
  String hawkerName;
  String hawkerMobile;
  int hawkerId;
  int amount;
  String zoneName;
  String transactionCode;

  Hawker({
    required this.hawkerName,
    required this.hawkerMobile,
    required this.hawkerId,
    required this.amount,
    required this.zoneName,
    required this.transactionCode
  });
}

List<Hawker> hawkers = [
  Hawker(
      hawkerName: 'John Doe',
      hawkerMobile: '123-456-7890',
      hawkerId: 1001,
      amount: 500,
      zoneName: 'Zone A',
      transactionCode: "T12345"
  ),
  Hawker(
      hawkerName: 'Jane Smith',
      hawkerMobile: '234-567-8901',
      hawkerId: 1002,
      amount: 600,
      zoneName: 'Zone B',
      transactionCode: "T23456"
  ),
  Hawker(
      hawkerName: 'Alice Johnson',
      hawkerMobile: '345-678-9012',
      hawkerId: 1003,
      amount: 700,
      zoneName: 'Zone C',
      transactionCode: "T34567"
  ),
  Hawker(
      hawkerName: 'Bob Brown',
      hawkerMobile: '456-789-0123',
      hawkerId: 1004,
      amount: 800,
      zoneName: 'Zone D',
      transactionCode: "T45678"
  ),
  Hawker(
      hawkerName: 'Charlie Davis',
      hawkerMobile: '567-890-1234',
      hawkerId: 1005,
      amount: 900,
      zoneName: 'Zone E',
      transactionCode: "T56789"
  ),
  Hawker(
      hawkerName: 'Daniel Evans',
      hawkerMobile: '678-901-2345',
      hawkerId: 1006,
      amount: 550,
      zoneName: 'Zone F',
      transactionCode: "T67890"
  ),
  Hawker(
      hawkerName: 'Eve White',
      hawkerMobile: '789-012-3456',
      hawkerId: 1007,
      amount: 650,
      zoneName: 'Zone G',
      transactionCode: "T78901"
  ),
  Hawker(
      hawkerName: 'Frank Green',
      hawkerMobile: '890-123-4567',
      hawkerId: 1008,
      amount: 750,
      zoneName: 'Zone H',
      transactionCode: "T89012"
  ),
  Hawker(
      hawkerName: 'Grace Hall',
      hawkerMobile: '901-234-5678',
      hawkerId: 1009,
      amount: 850,
      zoneName: 'Zone I',
      transactionCode: "T90123"
  ),
  Hawker(
      hawkerName: 'Hank Brown',
      hawkerMobile: '012-345-6789',
      hawkerId: 1010,
      amount: 950,
      zoneName: 'Zone J',
      transactionCode: "T01234"
  ),
  Hawker(
      hawkerName: 'Ivy Black',
      hawkerMobile: '123-456-7891',
      hawkerId: 1011,
      amount: 500,
      zoneName: 'Zone K',
      transactionCode: "T11223"
  ),
  Hawker(
      hawkerName: 'Jack White',
      hawkerMobile: '234-567-8902',
      hawkerId: 1012,
      amount: 600,
      zoneName: 'Zone L',
      transactionCode: "T22334"
  ),
  Hawker(
      hawkerName: 'Karen Brown',
      hawkerMobile: '345-678-9013',
      hawkerId: 1013,
      amount: 700,
      zoneName: 'Zone M',
      transactionCode: "T33445"
  ),
  Hawker(
      hawkerName: 'Larry King',
      hawkerMobile: '456-789-0124',
      hawkerId: 1014,
      amount: 800,
      zoneName: 'Zone N',
      transactionCode: "T44556"
  ),
  Hawker(
      hawkerName: 'Mona Lisa',
      hawkerMobile: '567-890-1235',
      hawkerId: 1015,
      amount: 900,
      zoneName: 'Zone O',
      transactionCode: "T55667"
  ),
  Hawker(
      hawkerName: 'Nate Grey',
      hawkerMobile: '678-901-2346',
      hawkerId: 1016,
      amount: 550,
      zoneName: 'Zone P',
      transactionCode: "T66778"
  ),
  Hawker(
      hawkerName: 'Olivia Blue',
      hawkerMobile: '789-012-3457',
      hawkerId: 1017,
      amount: 650,
      zoneName: 'Zone Q',
      transactionCode: "T77889"
  ),
  Hawker(
      hawkerName: 'Paul Black',
      hawkerMobile: '890-123-4568',
      hawkerId: 1018,
      amount: 750,
      zoneName: 'Zone R',
      transactionCode: "T88990"
  ),
];
