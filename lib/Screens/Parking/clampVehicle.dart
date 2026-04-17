import 'package:enforcer/Screens/Parking/Controllers/clampingController.dart';
import 'package:flutter/material.dart';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'Models/vehicleCategoriesModel.dart';
import 'Models/zonesModel.dart';



class clampVehicle extends StatefulWidget {
  final String? plate;

  clampVehicle({
   required this.plate
  });

  @override
  State<clampVehicle> createState() => _clampVehicleState();
}

class _clampVehicleState extends State<clampVehicle> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // zonesFuture =  ApiProvider().getOffLoadingZones(token: widget.token);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchData();
    });
  }

  void fetchData() {
    var provider = Provider.of<clampingController>(context, listen: false);
    provider.fetchZones();
    provider.plateController.text = widget.plate.toString();
    provider.fetchVehicleCategories();
  }

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

    return Consumer<clampingController>(
      builder: (context, clampController, child){
        return WillPopScope(
          onWillPop: () async{
            clampController.clearClampData();
            return true;
          },
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              toolbarHeight: 80,
              title: Text(
                "Clamp Vehicle",
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
              child: Padding(
                padding:  EdgeInsets.symmetric(horizontal: 15.0),
                child: ScrollConfiguration(
                  behavior: ScrollBehavior().copyWith(overscroll:false),
                  child: SingleChildScrollView(
                    child: Form(
                      key: clampController.formKey,
                      child: Column(
                        children: [
                          Card(
                            elevation: 5,
                            margin:  EdgeInsets.only(top: 20, bottom: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: size.width,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEFEFEF),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(7),
                                      topRight: Radius.circular(7),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      children: [

                                        Icon(
                                          Iconsax.info_circle,
                                          color: Colors.black,
                                        ),
                                        SizedBox(
                                          width: size.width * 0.01,
                                        ),
                                        Text(
                                          'Vehicle Details',
                                          style: GoogleFonts.manrope(
                                            fontWeight: FontWeight.w500,fontSize: fontSize * 1,),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                    child: Column(
                                      children: [
                                        SizedBox(height: 10,),
                                        TextFormField(
                                          readOnly: true,
                                          keyboardType: TextInputType.text,
                                          textInputAction: TextInputAction.next,
                                          decoration: InputDecoration(
                                            labelText: 'Enter Car Plate Number',
                                            prefixIcon:Icon(
                                              Iconsax.car,
                                              color: Colors.black,
                                              size: fontSize * 1.3,
                                              // size: 16,
                                            ),
                                            labelStyle: GoogleFonts.manrope(fontSize: fontSize),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(14),
                                              borderSide: const BorderSide(color: Color(0xFF46B1FD)),
                                            ),

                                          ),
                                          onChanged: (value){

                                          },
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
                                          controller: clampController.plateController,
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        FutureBuilder<List<GetVehicleCategoriesModel>>(
                                          future: clampController.vehicleCategoriesFuture,
                                          builder: (context, AsyncSnapshot<List<GetVehicleCategoriesModel>>snapshot) {
                                            // Your existing code for the second dropdown
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return createDisabledDropdownSearch(
                                                  "Fetching Vehicle Categories.....", fontSize);
                                            } else if (snapshot.hasError) {
                                              return createDisabledDropdownSearch(
                                                  "Error Vehicle Categories.....", fontSize);
                                            } else if (!snapshot.hasData ||
                                                snapshot.data!.isEmpty) {
                                              return createDisabledDropdownSearch(
                                                  "No Vehicle Categories Found.....", fontSize);
                                            } else {
                                              clampController.vehicleCategories = snapshot.data!;
                                              return Column(
                                                children: [
                                                  DropdownSearch<GetVehicleCategoriesModel>(
                                                      items: clampController.vehicleCategories,
                                                      // Pass the list directly
                                                      itemAsString:
                                                          (category) =>
                                                      category?.title ??
                                                          '',
                                                      // Adjust the field to display
                                                      dropdownSearchDecoration: InputDecoration(

                                                        prefixIcon:Icon(
                                                          // Icons.local_shipping_outlined,
                                                          Iconsax.car,
                                                          color: Colors.black,
                                                          size: fontSize * 1.3,
                                                          // size: 16,
                                                        ),
                                                        labelText: "Select Vehicle Category",
                                                        // Add padding for proper alignment
                                                        contentPadding: EdgeInsets.symmetric(
                                                            vertical: 20.0,
                                                            horizontal: 25.0),
                                                        // Adjust this value
                                                        border:
                                                        OutlineInputBorder(
                                                          borderSide:
                                                          BorderSide(
                                                              color: Colors
                                                                  .grey,
                                                              width: 1.0),
                                                        ),
                                                        focusedBorder:
                                                        OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color:
                                                              Colors.blue,
                                                              width:
                                                              1.0), // When focused
                                                        ),
                                                      ),
                                                      onChanged: (category) {
                                                        // Handle the selected vehicle category
                                                        clampController.selectedCategory = category;
                                                      },
                                                      validator: (category) {
                                                        if (category == null) {
                                                          return 'Please select a Vehicle Category';
                                                        }
                                                        return null;
                                                      },
                                                      showSearchBox: true,
                                                      isFilteredOnline: true,
                                                      searchFieldProps: TextFieldProps(
                                                        cursorColor: Colors.blue,
                                                        decoration: InputDecoration(
                                                          border: const OutlineInputBorder().copyWith(
                                                            borderRadius: BorderRadius.circular(8),
                                                            borderSide: const BorderSide(width: 1, color: Colors.black38),
                                                          ),
                                                          enabledBorder: const OutlineInputBorder().copyWith(
                                                            borderRadius: BorderRadius.circular(8),
                                                            borderSide: const BorderSide(width: 1, color: Colors.black38),
                                                          ),
                                                          //  hintText:
                                                          // 'Search Vehicle Categories',
                                                          label:  Row(
                                                            children: [
                                                              Icon(
                                                                Iconsax.search_normal,
                                                                color: Colors.black,
                                                                size: fontSize * 1.3,
                                                                // size: 16,
                                                              ),
                                                              SizedBox(
                                                                width: 12,
                                                              ),
                                                              Text('Search Vehicle Categories',style: TextStyle().copyWith(fontSize: 15, color: Colors.black),),
                                                            ],
                                                          ),
                                                        ),
                                                        // controller: searchController,
                                                      )),
                                                ],
                                              );
                                            }
                                          },
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        FutureBuilder<Map<String, GetMyZones>>(
                                          future: clampController.zonesFuture,
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return createDisabledDropdownSearch(
                                                  "Fetching Customers.....",fontSize);
                                            }

                                            if (snapshot.hasError) {
                                              return createDisabledDropdownSearch(
                                                  "Error Fetching Zones.....",fontSize);
                                            }

                                            if (!snapshot.hasData ||
                                                snapshot.data!.isEmpty) {
                                              return createDisabledDropdownSearch(
                                                  "No Zones Found.....",fontSize);
                                            }

                                            // Get the zones from the provider
                                            clampController.myZones = snapshot.data!;

                                            return Column(
                                              children: [
                                                // Zone Dropdown
                                                DropdownSearch<GetMyZones>(
                                                    items: clampController
                                                        .myZones!.values
                                                        .map((zone) => zone)
                                                        .toList(),
                                                    itemAsString: (zone) =>
                                                    zone?.zoneName ?? '',
                                                    // Adjust the field to display
                                                    dropdownSearchDecoration:
                                                    InputDecoration(
                                                      // labelText: 'Select Zone',

                                                      hintText: "Select Zone",
                                                      prefixIcon:  Icon(
                                                        Iconsax.location,
                                                        color: Colors.black,
                                                        size: fontSize * 1.3,
                                                      ),
                                                      border:
                                                      OutlineInputBorder(),
                                                    ),
                                                    onChanged: (zoneName) {
                                                      if (zoneName != null) {
                                                        // Find the zone by name
                                                        clampController.selectedLocation = null;
                                                        // provider.selectedZone = zoneName;
                                                        clampController.toggleZones(zoneName);
                                                      }
                                                    },
                                                    validator: (value) {
                                                      if (value == null)
                                                        return 'Please select a Zone';
                                                      return null;
                                                    },
                                                    showSearchBox: true,
                                                    isFilteredOnline: true,
                                                    searchFieldProps: TextFieldProps(
                                                      cursorColor: Colors.blue,
                                                      decoration: InputDecoration(
                                                        border: const OutlineInputBorder().copyWith(
                                                          borderRadius: BorderRadius.circular(8),
                                                          borderSide: const BorderSide(width: 1, color: Colors.black38),
                                                        ),
                                                        enabledBorder: const OutlineInputBorder().copyWith(
                                                          borderRadius: BorderRadius.circular(8),
                                                          borderSide: const BorderSide(width: 1, color: Colors.black38),
                                                        ),
                                                        //  hintText:
                                                        // 'Search Vehicle Categories',
                                                        label:  Row(
                                                          children: [
                                                            Icon(
                                                              Iconsax.search_normal,
                                                              color: Colors.black,
                                                              size: fontSize * 1.3,
                                                              // size: 16,
                                                            ),
                                                            SizedBox(
                                                              width: 12,
                                                            ),
                                                            Text('Search Zones',style: TextStyle().copyWith(fontSize: 15, color: Colors.black),),
                                                          ],
                                                        ),
                                                      ),
                                                      // controller: searchController,
                                                    )
                                                ),
                                                SizedBox(height: 20),
                                                // Location Dropdown (enabled only when a zone is selected)
                                                if (clampController.locations != null)
                                                  DropdownSearch<Location>(
                                                      items: clampController.locations,
                                                      selectedItem : clampController.selectedLocation,
                                                      itemAsString: (location) => location?.locationName ?? '',
                                                      // Adjust the field to display
                                                      dropdownSearchDecoration: InputDecoration(
                                                          border: OutlineInputBorder(),
                                                          prefixIcon:   Icon(
                                                            Iconsax.location,
                                                            color: Colors.black,
                                                            size: fontSize * 1.3,
                                                          ),
                                                          labelText: "Select Location"
                                                      ),
                                                      onChanged: (location) {
                                                        if (location != null) {
                                                          // Find the selected location
                                                          clampController.selectedLocation = location;
                                                        }
                                                      },
                                                      validator: (value) {
                                                        if (value == null)
                                                          return 'Please select a Location';
                                                        return null;
                                                      },
                                                      enabled: clampController.selectedZone != null,
                                                      // Disable until a zone is selected
                                                      showSearchBox: true,
                                                      isFilteredOnline: true,
                                                      searchFieldProps: TextFieldProps(
                                                        cursorColor: Colors.blue,
                                                        decoration: InputDecoration(
                                                          border: const OutlineInputBorder().copyWith(
                                                            borderRadius: BorderRadius.circular(8),
                                                            borderSide: const BorderSide(width: 1, color: Colors.black38),
                                                          ),
                                                          enabledBorder: const OutlineInputBorder().copyWith(
                                                            borderRadius: BorderRadius.circular(8),
                                                            borderSide: const BorderSide(width: 1, color: Colors.black38),
                                                          ),
                                                          //  hintText:
                                                          // 'Search Vehicle Categories',
                                                          label:  Row(
                                                            children: [
                                                              Icon(
                                                                Iconsax.search_normal,
                                                                color: Colors.black,
                                                                size: fontSize * 1.3,
                                                                // size: 16,
                                                              ),
                                                              SizedBox(
                                                                width: 12,
                                                              ),
                                                              Text('Search Locations',style: TextStyle().copyWith(fontSize: 15, color: Colors.black),),
                                                            ],
                                                          ),
                                                        ),
                                                        // controller: searchController,
                                                      )
                                                  ),
                                              ],
                                            );
                                          },
                                        ),

                                      ],
                                    )
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 0,),
                          SizedBox(height: 20),
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
                              onPressed: () {
                                if(clampController.formKey.currentState!.validate()){
                                  clampController.clampVehicle(context: context);
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
                              child: clampController.isClamping
                                  ? CircularProgressIndicator(
                                color: Colors.white,
                              )
                                  :   Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Proceed to Clamp',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.manrope(
                                      fontSize: fontSize * 1.1,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFFFFCC2A),
                                    ),
                                  ),
                                  // SizedBox(width: screenWidth * 0.03,),
                                  // Icon(
                                  //   Icons.send,
                                  //   size: fontSize * 1.6,
                                  //   color: Color(0xFFFFCC2A),
                                  // ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
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

  Widget createTextFormField(String hintText, double fontSize){
    return  TextFormField(
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.manrope(fontSize: fontSize),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF46B1FD)),
        ),

      ),


    );
  }


}
