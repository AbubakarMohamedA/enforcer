import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../../Api/api_provider.dart';
// import '../../Models/Offloading/getDailyOffloadingApplications.dart';
import '../../Models/Offloading/getOffLoadingVehicleType.dart';
import '../../Models/Offloading/getOffLoadingZones.dart';
import '../../Models/Offloading/getPenaltyRates.dart';
import 'PenalizedEnterGoodDetails.dart';
import 'enterGoodDetails.dart';


class PenalizepromptOffLoadingPayment extends StatefulWidget {
  var token;
  final Function? CheckPaymentDialogCallback;
  final String navigateBackAgain;

  // Already Captured VALUES FROM THE DETAILS PAGE

  var capturedOrigin;
  var capturedVehicleType;
  var capturedVehicleId;
  var capturedPlate;
  var capturedClientName;
  var capturedPhone;


  PenalizepromptOffLoadingPayment({
    required this.token,
    required this.CheckPaymentDialogCallback,
    this.navigateBackAgain = 'Once',
    required this.capturedVehicleId,
    required this.capturedOrigin,
    required this.capturedVehicleType,
    required this.capturedPlate,
    required this.capturedClientName,
    required this.capturedPhone

  });

  @override
  State<PenalizepromptOffLoadingPayment> createState() => _PenalizepromptOffLoadingPaymentState();
}

class _PenalizepromptOffLoadingPaymentState extends State<PenalizepromptOffLoadingPayment> {

  final _formKey = GlobalKey<FormState>();
  List<String> origin = [
    "Bomet",
    "Bungoma",
    "Busia",
    "Elgeyo Marakwet",
    "Embu",
    "Garissa",
    "Homa Bay",
    "Isiolo",
    "Kajiado",
    "Kakamega",
    "Kericho",
    "Kisii",
    "Kisumu",
    "Kitui",
    "Kwale",
    "Laikipia",
    "Lamu",
    "Machakos",
    "Makueni",
    "Mandera",
    "Marsabit",
    "Meru",
    "Migori",
    "Mombasa",
    "Murang'a",
    "Nairobi",
    "Nakuru",
    "Narok",
    "Nairobi",
    "Nandi",
    "Narok",
    "Nyamira",
    "Nyandarua",
    "Nyeri",
    "Samburu",
    "Siaya",
    "Taita Taveta",
    "Tana River",
    "Tharaka Nithi",
    "Trans Nzoia",
    "Turkana",
    "Uasin Gishu",
    "Vihiga",
    "Wajir",
    "West Pokot",
    "Wote"
  ];




  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    zonesFuture =  ApiProvider().getOffLoadingZones(token: widget.token);
    vehicleTypeFuture =  ApiProvider().getOffLoadingVehicleTypes(token: widget.token);

    destinationSelected = "Mombasa";
    initializeData();
    vetchPenalty();
  }


// Assuming the name contains two parts (first name and last name)
  String? firstName ;
  String? lastName ;

  void initializeData(){
    setState(() {
      // originSelected = widget.capturedOrigin;
      _plateController.text = widget.capturedPlate;
      plateSelected = widget.capturedPlate;

      _clientNameController.text = widget.capturedClientName;
      clientName = widget.capturedClientName;


      if(widget.capturedClientName != null){
        List<String> nameParts = widget.capturedClientName.split(' ');
        // Assuming the name contains two parts (first name and last name)
        String firstName = nameParts.isNotEmpty ? nameParts[0] : '';
        // String lastName = nameParts.length > 1 ? nameParts[1] : '';
        String lastName = nameParts.length > 1 ? nameParts[1] == '' ? nameParts[2] : nameParts[1] : '';
        _clientFirstName.text = firstName;
        _clientLastName.text = lastName;
      }

      _phoneController = TextEditingController();
      _initialPhoneNumber = PhoneNumber(isoCode: 'KE'); // Default ISO code for Kenya

      // If you need to set an initial value for the phone controller:
      if (widget.capturedPhone != null) {
        _phoneController.text = widget.capturedPhone;
        _initialPhoneNumber = PhoneNumber(
          phoneNumber: widget.capturedPhone,
          isoCode: 'KE',
        );
      }

    });
  }

  vetchPenalty(){
    // if(widget.capturedVehicleType == "Pick up"){
    //   widget.capturedVehicleType = 'Pickup';
    // }
    penaltyFuture  =  ApiProvider().getOffLoadingPenatyRates(token: widget.token,vehicleType: widget.capturedVehicleType);
  }


  String? originSelected;
  String? destinationSelected;
  String? vehicleSelected;
  String? vehicleNameSelected;
  String? plateSelected;
  String? clientName;
  String? zoneSelected;
  String? zoneName;


  //DROPDOWNPLACEHOLDERS
  OffLoadingZonesDatum? holdingZone;
  OffLoadingVehcleDatum? holdingVehicleType;

  //Intl
  // TextEditingController _phoneController = TextEditingController();
  // PhoneNumber _initialPhoneNumber = PhoneNumber(isoCode: 'KE');
  late TextEditingController _phoneController;
  late PhoneNumber _initialPhoneNumber;
  bool _isValidNumber = false;
  String _fullPhoneNumber = '';

  //vehicle Types
  late Future<GetOffloadingVehicleType> vehicleTypeFuture;
  List<OffLoadingVehcleDatum>? vehicleTypesData;


  //Zones Types
  late Future<GetOffloadingZones> zonesFuture;
  List<OffLoadingZonesDatum>? zonesData;

  late Future<GetPenaltyRates> penaltyFuture;



  //Controllers
  TextEditingController _plateController = TextEditingController();
  TextEditingController _clientNameController = TextEditingController();
  TextEditingController _clientFirstName = TextEditingController();
  TextEditingController _clientLastName = TextEditingController();
  TextEditingController _penaltyController = TextEditingController();


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

    // if(widget.capturedVehicleType != null){
    //   TextEditingController phoneNumberController = TextEditingController(
    //     text: widget.offLoadingItem.phoneNumber, // Pre-fill with clientPhone
    //   );
    //   PhoneNumber _initialPhoneNumber = PhoneNumber(
    //     phoneNumber: widget.offLoadingItem.phoneNumber,
    //     isoCode: 'KE',
    //   );
    // }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        toolbarHeight: 80,
        title: Text(
          "Prompt Payment",
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
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: ScrollConfiguration(
            behavior: ScrollBehavior().copyWith(overscroll:false),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Card(
                    elevation: 5,
                    margin: const EdgeInsets.only(top: 20, bottom: 15),
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
                                  Icons.info,
                                  color: Colors.black,
                                ),
                                SizedBox(
                                  width: size.width * 0.01,
                                ),
                                Text(
                                  'Penalty Charge',
                                  style: GoogleFonts.manrope(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                      fontSize: fontSize * 1.2),
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


                                FutureBuilder<GetPenaltyRates>(
                                  future: penaltyFuture!,
                                  builder: (context, AsyncSnapshot<GetPenaltyRates>snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return createDisabledDropdownSearch("Fetching Penalty Rate...", fontSize);
                                    } else if (snapshot.hasError) {
                                      print(snapshot.error);
                                      return createDisabledDropdownSearch(
                                          "Error Fetching Penalty Rate", fontSize);
                                    } else if (!snapshot.hasData ||
                                        snapshot
                                            .data!.data == null) {
                                      return createDisabledDropdownSearch(
                                          "No Vehicle Rate Found .....", fontSize);
                                    } else {

                                      _penaltyController.text = formatNumb(snapshot.data!.data.toString());

                                      return TextFormField(
                                        readOnly: true,
                                        keyboardType: TextInputType.text,
                                        textInputAction: TextInputAction.next,
                                        decoration: InputDecoration(
                                          hintStyle: GoogleFonts.manrope(fontSize: fontSize),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(14),
                                            borderSide: const BorderSide(color: Color(0xFF46B1FD)),
                                          ),
                                        ),
                                        controller: _penaltyController,
                                      );
                                    }
                                  },
                                ),


                              ],
                            )
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 0,),
                  Card(
                    elevation: 5,
                    margin: const EdgeInsets.only(top: 20, bottom: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Form(
                      key: _formKey,
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
                                    Icons.info,
                                    color: Colors.black,
                                  ),
                                  SizedBox(
                                    width: size.width * 0.01,
                                  ),
                                  Text(
                                    'Type - Normal',
                                    style: GoogleFonts.manrope(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                        fontSize: fontSize * 1.2),
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

                                DropdownSearch<String>(
                                  mode: Mode.DIALOG,
                                  items: origin, // List of Strings
                                  selectedItem: originSelected,
                                  dropdownSearchDecoration: InputDecoration(
                                    hintText: "Select Origin",
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
                                        originSelected = value; // Update selected origin
                                      });
                                    }
                                  },
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Please select an Origin';
                                    }
                                    return null;
                                  },
                                  showSearchBox: true, // Allows searching within the list
                                  isFilteredOnline: true,
                                  searchFieldProps: TextFieldProps(
                                    cursorColor: Colors.blue,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: 'Search Origins',
                                    ),
                                  ),
                                ),

                                SizedBox(
                                  height: size.height * 0.015,
                                ),
                                TextFormField(
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                    hintText: 'Destination - Mombasa',
                                    hintStyle: GoogleFonts.manrope(fontSize: fontSize),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(color: Color(0xFF46B1FD)),
                                    ),

                                  ),
                                  onChanged: (value){
                                    setState(() {

                                    });
                                  },
                                  readOnly: true,
                                  onTap: (){
                                    Get.snackbar(
                                      'Oops',
                                      'Destination is Unselectable',
                                      backgroundColor: Colors.redAccent.withOpacity(0.7),
                                      colorText: Colors.white,
                                      snackPosition: SnackPosition.TOP, // Adjust position if needed
                                      duration: Duration(seconds: 2), // Adjust duration if needed
                                      margin: EdgeInsets.only(left: 16.0,right: 16), // Adjust margin if needed
                                      borderRadius: 10.0, // Adjust border radius if needed
                                    );
                                  },
                                ),
                                SizedBox(
                                  height: size.height * 0.015,
                                ),
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
                                                zoneSelected = zonesType.id.toString();
                                                zoneName = zonesType.name.toString();
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

                                SizedBox(
                                  height: size.height * 0.015,
                                ),
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


                                      if (widget.capturedVehicleId != null) {
                                        // Check if a vehicle with the given ID exists
                                        bool vehicleExists = vehicleTypesData?.any((vehicle) => vehicle.id == widget.capturedVehicleId) ?? false;

                                        if (vehicleExists) {
                                          // If a vehicle exists with the given ID, get the first matching vehicle
                                          holdingVehicleType = vehicleTypesData?.firstWhere(
                                                (vehicle) => vehicle.id == widget.capturedVehicleId,
                                          );
                                          vehicleSelected = holdingVehicleType?.id.toString();
                                          vehicleNameSelected = holdingVehicleType?.name.toString();
                                        } else {
                                          // Handle the case when the vehicle with the given ID does not exist

                                        }
                                      }
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
                                                vehicleSelected = vehicleType.id.toString();
                                                vehicleNameSelected = vehicleType.name.toString();
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
                                              'Search Vehicles',
                                            ),
                                            // controller: searchController,
                                          ));
                                    }
                                  },
                                ),
                                SizedBox(
                                  height: size.height * 0.015,
                                ),

                                TextFormField(
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                    hintText: 'Enter Car Plate Number',
                                    hintStyle: GoogleFonts.manrope(fontSize: fontSize),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(color: Color(0xFF46B1FD)),
                                    ),

                                  ),
                                  onChanged: (value){
                                    setState(() {
                                      plateSelected = value;
                                    });
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
                                  controller:_plateController,
                                ),
                                SizedBox(
                                  height: size.height * 0.015,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        keyboardType: TextInputType.name,
                                        textInputAction: TextInputAction.next,
                                        decoration: InputDecoration(
                                          hintText: 'Client First Name',
                                          hintStyle: GoogleFonts.manrope(fontSize: fontSize),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(14),
                                            borderSide: const BorderSide(color: Color(0xFF46B1FD)),
                                          ),

                                        ),
                                        onChanged: (value){
                                          setState(() {
                                            // clientName = value;
                                          });
                                        },
                                        validator: (value){
                                          if (value == null || value.trim().isEmpty) {
                                            return 'Enter a valid First name';
                                          }
                                          if (RegExp(r'[0-9]').hasMatch(value)) {
                                            return 'Should be characters Only';
                                          }
                                          return null;
                                        },
                                        controller: _clientFirstName,
                                      ),
                                    ),
                                    SizedBox(width: screenWidth * 0.01,),
                                    Expanded(
                                      child: TextFormField(
                                        keyboardType: TextInputType.name,
                                        textInputAction: TextInputAction.next,
                                        decoration: InputDecoration(
                                          hintText: 'Client Last Name',
                                          hintStyle: GoogleFonts.manrope(fontSize: fontSize),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(14),
                                            borderSide: const BorderSide(color: Color(0xFF46B1FD)),
                                          ),

                                        ),
                                        onChanged: (value){
                                          setState(() {
                                            // clientName = value;
                                          });
                                        },
                                        validator: (value){
                                          if (value == null || value.trim().isEmpty) {
                                            return 'Enter a valid Last name';
                                          }
                                          if (RegExp(r'[0-9]').hasMatch(value)) {
                                            return 'Should be characters Only';
                                          }
                                          return null;
                                        },
                                        controller: _clientLastName,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: size.height * 0.015,
                                ),
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
                                SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                      onPressed: () async{
                        FocusScope.of(context).unfocus();
                        if(originSelected == null){
                          Get.snackbar(
                            'Oops',
                            'Please select Origin !',
                            backgroundColor: Colors.redAccent.withOpacity(0.7),
                            colorText: Colors.white,
                            snackPosition: SnackPosition.TOP, // Adjust position if needed
                            duration: Duration(seconds: 2), // Adjust duration if needed
                            margin: EdgeInsets.only(left: 16.0,right: 16), // Adjust margin if needed
                            borderRadius: 10.0, // Adjust border radius if needed
                          );
                        }else if(destinationSelected == null){
                          Get.snackbar(
                            'Oops',
                            'Please select Destination !',
                            backgroundColor: Colors.redAccent.withOpacity(0.7),
                            colorText: Colors.white,
                            snackPosition: SnackPosition.TOP, // Adjust position if needed
                            duration: Duration(seconds: 2), // Adjust duration if needed
                            margin: EdgeInsets.only(left: 16.0,right: 16), // Adjust margin if needed
                            borderRadius: 10.0, // Adjust border radius if needed
                          );
                        }else if(zoneSelected == null){
                          Get.snackbar(
                            'Oops',
                            'Please select a Zone !',
                            backgroundColor: Colors.redAccent.withOpacity(0.7),
                            colorText: Colors.white,
                            snackPosition: SnackPosition.TOP, // Adjust position if needed
                            duration: Duration(seconds: 2), // Adjust duration if needed
                            margin: EdgeInsets.only(left: 16.0,right: 16), // Adjust margin if needed
                            borderRadius: 10.0, // Adjust border radius if needed
                          );
                        }
                        else if(vehicleSelected == null){
                          Get.snackbar(
                            'Oops',
                            'Please select Vehicle type !',
                            backgroundColor: Colors.redAccent.withOpacity(0.7),
                            colorText: Colors.white,
                            snackPosition: SnackPosition.TOP, // Adjust position if needed
                            duration: Duration(seconds: 2), // Adjust duration if needed
                            margin: EdgeInsets.only(left: 16.0,right: 16), // Adjust margin if needed
                            borderRadius: 10.0, // Adjust border radius if needed
                          );
                        }else if(plateSelected == null){
                          Get.snackbar(
                            'Oops',
                            'Please select Plate Number !',
                            backgroundColor: Colors.redAccent.withOpacity(0.7),
                            colorText: Colors.white,
                            snackPosition: SnackPosition.TOP, // Adjust position if needed
                            duration: Duration(seconds: 2), // Adjust duration if needed
                            margin: EdgeInsets.only(left: 16.0,right: 16), // Adjust margin if needed
                            borderRadius: 10.0, // Adjust border radius if needed
                          );
                        }else if(_clientFirstName.text.isEmpty){
                          Get.snackbar(
                            'Oops',
                            'Please select Client First Name !',
                            backgroundColor: Colors.redAccent.withOpacity(0.7),
                            colorText: Colors.white,
                            snackPosition: SnackPosition.TOP, // Adjust position if needed
                            duration: Duration(seconds: 2), // Adjust duration if needed
                            margin: EdgeInsets.only(left: 16.0,right: 16), // Adjust margin if needed
                            borderRadius: 10.0, // Adjust border radius if needed
                          );
                        }else if(_clientLastName.text.isEmpty){
                          Get.snackbar(
                            'Oops',
                            'Please select Client Last Name !',
                            backgroundColor: Colors.redAccent.withOpacity(0.7),
                            colorText: Colors.white,
                            snackPosition: SnackPosition.TOP, // Adjust position if needed
                            duration: Duration(seconds: 2), // Adjust duration if needed
                            margin: EdgeInsets.only(left: 16.0,right: 16), // Adjust margin if needed
                            borderRadius: 10.0, // Adjust border radius if needed
                          );
                        }else if(_fullPhoneNumber == ''){
                          Get.snackbar(
                            'Oops',
                            'Please select Client Contact !',
                            backgroundColor: Colors.redAccent.withOpacity(0.7),
                            colorText: Colors.white,
                            snackPosition: SnackPosition.TOP, // Adjust position if needed
                            duration: Duration(seconds: 2), // Adjust duration if needed
                            margin: EdgeInsets.only(left: 16.0,right: 16), // Adjust margin if needed
                            borderRadius: 10.0, // Adjust border radius if needed
                          );
                        }else if(_penaltyController.text.isEmpty){
                          Get.snackbar(
                            'Oops',
                            'No Penaty Selected !',
                            backgroundColor: Colors.redAccent.withOpacity(0.7),
                            colorText: Colors.white,
                            snackPosition: SnackPosition.TOP, // Adjust position if needed
                            duration: Duration(seconds: 2), // Adjust duration if needed
                            margin: EdgeInsets.only(left: 16.0,right: 16), // Adjust margin if needed
                            borderRadius: 10.0, // Adjust border radius if needed
                          );
                        }
                        else if(_formKey.currentState!.validate()){
                          setState(() {
                            clientName = '${_clientFirstName.text} ${_clientLastName.text}';
                          });
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (c) =>
                                      PenalizedgoodDetailsAdd(
                                        goodsOrigin: originSelected,
                                        destination: destinationSelected,
                                        vehicleType: vehicleSelected,
                                        plateNumber: plateSelected,
                                        zoneId: zoneSelected,
                                        clientName: clientName,
                                        vehicleTypeName: vehicleNameSelected,
                                        clientPhone: _fullPhoneNumber,
                                        token: widget.token,
                                        penalty: _penaltyController.text,


                                        clearPromptPageCallback: clearPromptPageData,
                                        CheckPaymentDialogCallback: widget.CheckPaymentDialogCallback,
                                        navigateBackAgain: widget.navigateBackAgain,
                                      )));
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
                      child:  Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Enter Good Details',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.manrope(
                              fontSize: fontSize * 1.1,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFFFCC2A),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.03,),
                          Icon(
                            Icons.send,
                            size: fontSize * 1.6,
                            color: Color(0xFFFFCC2A),
                          ),
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
    );
  }
  Widget createDisabledDropdownSearch(String hintText, double fontSize) {
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
        hintStyle: GoogleFonts.manrope(fontSize: fontSize),
      ),
      onChanged: print,
      maxHeight: 130,
      popupBackgroundColor: Colors.grey[200],
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

  void clearPromptPageData(){
    setState(() {
      originSelected = null;

      //Clear Zones data
      zonesData = null;
      zoneSelected = null;
      zoneName = null;
      holdingZone = null;

      //  Clear Vehicle Type data
      vehicleTypesData = null;
      holdingVehicleType = null;
      vehicleSelected = null;
      vehicleNameSelected = null;

      plateSelected = null;
      clientName = null;
      _fullPhoneNumber = '';

      _plateController.text = '';
      _clientNameController.text = '';

    });
  }
}
