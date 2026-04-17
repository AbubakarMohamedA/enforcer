import 'package:enforcer/Screens/OffLoading/DailyoffLoadingApplicationDeatils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../Api/api_provider.dart';
import '../../Models/Offloading/getDailyOffloadingApplications.dart';
import '../../Models/Offloading/getOffLoadingVehicleType.dart';
import '../../Models/Offloading/getOffLoadingZones.dart';
import '../../error_page.dart';
import 'offLoadingDetails.dart';
import 'package:dropdown_search/dropdown_search.dart';

class offLoadingList extends StatefulWidget {
  var token;
  final Function? CheckPaymentDialogCallback;
  offLoadingList({
    required this.token,
    required this.CheckPaymentDialogCallback
  });

  @override
  State<offLoadingList> createState() => _offLoadingListState();
}

class _offLoadingListState extends State<offLoadingList> {

  bool expandItems = false;
  bool filterAllocated = false;

  Future<GetDailyOffloadingApplications>? dailyOffloadingFuture;
  List<GetDailyOffloadingApplicationDatum>? dailyOffloadingList;

  List<GetDailyOffloadingApplicationDatum>? filteredOffLoadingList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dailyOffloadingFuture = ApiProvider().getDailyOffloadingApplications(token: widget.token);
    zonesFuture =  ApiProvider().getOffLoadingZones(token: widget.token);
    vehicleTypeFuture =  ApiProvider().getOffLoadingVehicleTypes(token: widget.token);

  }


  //Zones Types
  late Future<GetOffloadingZones> zonesFuture;
  List<OffLoadingZonesDatum>? zonesData;
  OffLoadingZonesDatum? holdingZone;

  //vehicle type variables
  late Future<GetOffloadingVehicleType> vehicleTypeFuture;
  List<OffLoadingVehcleDatum>? vehicleTypesData;
  OffLoadingVehcleDatum? holdingVehicleType;

  //plate controller variable
  TextEditingController _plateController = TextEditingController();

  bool _isReseting = false;
  bool _isFiltering = false;

  List<String> statusList = [
    'Unpaid',
    'Paid'
  ];

  String? statusSelected;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final imageDimension = screenWidth / 3.3;
    final fontSize = screenWidth / 28.0;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        toolbarHeight: 80,
        title: Text(
          "Offloading Applications",
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
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: FutureBuilder<GetDailyOffloadingApplications>(
          future: dailyOffloadingFuture, // Replace with your future function
          builder: (context, AsyncSnapshot<GetDailyOffloadingApplications> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child:
                  CircularProgressIndicator(color: Color(0XFF3E4095)));
            } else if (!snapshot.hasData || snapshot.hasError) {
              print(snapshot.error);
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
              dailyOffloadingList = snapshot.data!.data!;
              dailyOffloadingList!.sort((a, b) => b.id.compareTo(a.id));

              if (dailyOffloadingList!.isEmpty) {
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
                            'No Applications made yet.',

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
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 13.0),
                      child: Column(
                        children: [
                          Card(
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
                                            Icon(
                                              Icons
                                                  .add_circle_outline_outlined,
                                              color: Colors.black,
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
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
                                            Text(
                                              'Zone',
                                              style: GoogleFonts.manrope(
                                                fontSize: fontSize,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            FutureBuilder<GetOffloadingZones>(
                                              future: zonesFuture!,
                                              builder: (context,
                                                  AsyncSnapshot<GetOffloadingZones>
                                                  snapshot) {
                                                if (snapshot.connectionState == ConnectionState.waiting) {
                                                  return createDisabledDropdownSearch("Fetching Zones.....", fontSize);
                                                } else if (snapshot.hasError) {
                                                  return createDisabledDropdownSearch(
                                                      "Error Fetching Zones.....", fontSize);
                                                } else if (!snapshot.hasData ||
                                                    snapshot
                                                        .data!.data!.isEmpty) {
                                                  return createDisabledDropdownSearch(
                                                      "No Zones Found.....", fontSize);
                                                } else {
                                                  zonesData = snapshot.data!.data;

                                                  return DropdownSearch<OffLoadingZonesDatum>(
                                                      mode: Mode.DIALOG,
                                                      items: zonesData,
                                                      selectedItem: holdingZone,
                                                      itemAsString:
                                                          (OffLoadingZonesDatum? zonesType) => zonesType?.name?? '',
                                                      dropdownSearchDecoration:
                                                      InputDecoration(
                                                        // labelText: "Zones ",
                                                        hintText: "Select Zone",
                                                        hintStyle: GoogleFonts.manrope(fontSize: fontSize),
                                                        disabledBorder:
                                                        OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                            color:  Color(0xFF1366D9),
                                                            width: 1.0,
                                                          ),
                                                        ),
                                                      ),
                                                      onChanged: (OffLoadingZonesDatum? zonesType) {
                                                        if (zonesType != null) {
                                                          setState(() {
                                                            holdingZone = zonesType;
                                                          });
                                                        }
                                                      },
                                                      validator: (value) {
                                                        if (value == null) {
                                                          return 'Please select a Zone';
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
                                                          'Search Zones',
                                                        ),
                                                        // controller: searchController,
                                                      ));
                                                }
                                              },
                                            ),
                                            const SizedBox(height: 15),
                                            Text(
                                              'Vehicle Type',
                                              style: GoogleFonts.manrope(
                                                fontSize: fontSize,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            FutureBuilder<GetOffloadingVehicleType>(
                                              future: vehicleTypeFuture!,
                                              builder: (context,
                                                  AsyncSnapshot<GetOffloadingVehicleType>
                                                  snapshot) {
                                                if (snapshot.connectionState == ConnectionState.waiting) {
                                                  return createDisabledDropdownSearch("Fetching Vehicle Types.....", fontSize);
                                                } else if (snapshot.hasError) {
                                                  return createDisabledDropdownSearch(
                                                      "Error Fetching Vehicle Types.....", fontSize);
                                                } else if (!snapshot.hasData ||
                                                    snapshot
                                                        .data!.data!.isEmpty) {
                                                  return createDisabledDropdownSearch(
                                                      "No Vehicle Types Found.....", fontSize);
                                                } else {
                                                  vehicleTypesData = snapshot.data!.data;
                                                  // speicifcLocationsData = AllLocationsData!.where((element) => element.zoneId == hawkerZoneId).toList();

                                                  return DropdownSearch<OffLoadingVehcleDatum>(
                                                      mode: Mode.DIALOG,
                                                      items: vehicleTypesData,
                                                      selectedItem: holdingVehicleType,
                                                      itemAsString:
                                                          (OffLoadingVehcleDatum? vehicleType) => vehicleType?.name?? '',
                                                      dropdownSearchDecoration:
                                                      InputDecoration(
                                                        // labelText: "Zones ",
                                                        hintText: "Select Vehicle Type ",
                                                        hintStyle: GoogleFonts.manrope(fontSize: fontSize),
                                                        disabledBorder:
                                                        OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                            color:  Color(0xFF1366D9),
                                                            width: 1.0,
                                                          ),
                                                        ),
                                                      ),
                                                      onChanged: (OffLoadingVehcleDatum? vehicleType) {
                                                        if (vehicleType != null) {
                                                          setState(() {
                                                            holdingVehicleType = vehicleType;
                                                          });
                                                        }
                                                      },
                                                      validator: (value) {
                                                        if (value == null) {
                                                          return 'Please select a Vehicle Type';
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
                                                          'Search My Vehicle Type',
                                                        ),
                                                        // controller: searchController,
                                                      ));
                                                }
                                              },
                                            ),
                                            const SizedBox(height: 15),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'Plate No:',
                                                        style: GoogleFonts.manrope(
                                                          fontSize: fontSize,
                                                          fontWeight: FontWeight.w500,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 10),
                                                      TextFormField(
                                                        keyboardType: TextInputType.text,
                                                        textInputAction: TextInputAction.next,
                                                        decoration: InputDecoration(
                                                          hintText: 'Enter Plate Number',
                                                          hintStyle: GoogleFonts.manrope(fontSize: fontSize),
                                                          enabledBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(14),
                                                            borderSide: const BorderSide(color: Color(0xFF46B1FD)),
                                                          ),
                                                        ),
                                                        controller: _plateController,
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
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(width: screenWidth * 0.01,),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'Status:',
                                                        style: GoogleFonts.manrope(
                                                          fontSize: fontSize,
                                                          fontWeight: FontWeight.w500,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 10),
                                                      DropdownSearch<String>(
                                                        items: statusList, // List of Strings
                                                        selectedItem: statusSelected,
                                                        dropdownSearchDecoration: InputDecoration(
                                                          hintText: "Status",
                                                          hintStyle: GoogleFonts.manrope(fontSize: fontSize),
                                                          disabledBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                              color: Color(0xFF1366D9),
                                                              width: 1.0,
                                                            ),
                                                          ),
                                                        ),
                                                        onChanged: (value) {
                                                          if (value != null) {
                                                            setState(() {
                                                              statusSelected = value; // Update selected origin
                                                            });
                                                          }
                                                        },
                                                        validator: (value) {
                                                          if (value == null) {
                                                            return 'Please select a Status';
                                                          }
                                                          return null;
                                                        },
                                                        showSearchBox: true, // Allows searching within the list
                                                        isFilteredOnline: true,
                                                        searchFieldProps: TextFieldProps(
                                                          cursorColor: Colors.blue,
                                                          decoration: InputDecoration(
                                                            border: OutlineInputBorder(),
                                                            hintText: 'Search Status',
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
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
                                                        // resetFilter();
                                                        if (_plateController.text.isNotEmpty ||
                                                            holdingZone != null ||
                                                            holdingVehicleType != null || statusSelected != null) {
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
                                                      child:  _isReseting // Display loading indicator if filtering is ongoing
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
                                                        if(_plateController.text.isEmpty &&  holdingZone == null && holdingVehicleType == null && statusSelected == null){
                                                          Get.snackbar(
                                                            'Cannot Filter',
                                                            'Please Select a parameter first !',
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
                                                      ) :   Text(
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
                          SizedBox(height: 20,),
                          ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount:  (filteredOffLoadingList == null) ? dailyOffloadingList!.length : filteredOffLoadingList!.length,
                              itemBuilder: (context, index) {
                                GetDailyOffloadingApplicationDatum offLoadingItem = (filteredOffLoadingList == null) ? dailyOffloadingList![index] : filteredOffLoadingList![index];
                                return InkWell(
                                  onTap: (){
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (c) =>
                                                DailyoffLoadingDetails(
                                                  offLoadingItem:offLoadingItem,
                                                  token: widget.token,
                                                  CheckPaymentDialogCallback: widget.CheckPaymentDialogCallback,
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
                                                  children: [
                                                    Text(
                                                      'Application No:',
                                                      style: GoogleFonts.manrope(color:Colors.grey.withOpacity(0.7), ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Text(
                                                        '#${offLoadingItem.id.toString()}',
                                                        style: GoogleFonts.manrope(
                                                        )
                                                    )
                                                  ],
                                                ),
                                                // SizedBox(
                                                //   width: 10,
                                                // ),
                                                const Spacer(),
                                                Container(height: 30, width: 1, color: Colors.black54),
                                                // SizedBox(
                                                //   width: 5,
                                                // ),
                                                const Spacer(),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      'Plate No:',
                                                      style: GoogleFonts.manrope(color:Colors.grey.withOpacity(0.7), ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Text(
                                                        offLoadingItem.plateNo.toString(),
                                                        style: GoogleFonts.manrope(
                                                        )
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.center,
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
                                                          offLoadingItem.origin.toString(),
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
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        SizedBox(
                                                          width: size.width * 0.4,
                                                          child: Text(
                                                            offLoadingItem.destination.toString(),
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
                                                Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(8),
                                                    color:  offLoadingItem.status.toString() == "Unpaid" ?  Color(0xFFFF8919) :  Colors.green,

                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(top: 7.0,bottom: 7.0,left: 12.0,right: 12.0),
                                                    child: Text(
                                                      offLoadingItem.status.toString() ,
                                                      style: GoogleFonts.manrope(
                                                          color: Colors.white,
                                                          fontSize: fontSize * 0.85
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 10),
                                            Row(
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Application zone :',
                                                      style: GoogleFonts.manrope(color:Colors.grey.withOpacity(0.7), ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Text(
                                                        offLoadingItem.zoneName.toString(),
                                                        style: GoogleFonts.manrope(
                                                        )
                                                    ),
                                                  ],
                                                ),
                                                Spacer(),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      'Vehicle Type :',
                                                      style: GoogleFonts.manrope(color:Colors.grey.withOpacity(0.7), ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Text(
                                                        offLoadingItem.vehicleTypeName.toString(),
                                                        style: GoogleFonts.manrope(
                                                        )
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 15),
                                          ],
                                        )
                                    ),
                                  ),
                                );
                              })
                        ],
                      ),
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
  Widget createDisabledDropdownSearch(String hintText, double fontSize) {
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
        hintStyle: GoogleFonts.manrope(fontSize: fontSize),
      ),
      enabled: false,
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
      _plateController.clear();
      holdingZone = null;
      holdingVehicleType = null;
      filteredOffLoadingList = null;
      statusSelected = null;
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
      filteredOffLoadingList = dailyOffloadingList?.where((offload) {
        bool matchedPlateNumber = true;
        bool matchesZone = true;
        bool matchesVehicleType= true;
        bool matchesStatus = true;

        // Check if Hawker Name matches the input
        if (_plateController.text.isNotEmpty) {
          matchedPlateNumber = offload.plateNo!.toLowerCase().contains(_plateController.text.toLowerCase());
        }

        // Check if Hawker ID matches the input
        if (holdingZone?.id != null) {
          matchesZone = offload.zone == holdingZone!.id;
        }
        // Check if Hawker Zone matches the selected zone
        if (holdingVehicleType?.id != null) {
          matchesVehicleType = offload.vehicleType.toString() == holdingVehicleType!.id.toString();
        }

        if (statusSelected != null) {
          print("The status selected is ${statusSelected}");
          matchesStatus = offload.status!.toLowerCase() == statusSelected!.toLowerCase().toString();
        }

        return matchedPlateNumber && matchesZone && matchesVehicleType && matchesStatus ;
      }).toList();

      _isFiltering = false;
      expandItems = !expandItems;
    });
  }

}
