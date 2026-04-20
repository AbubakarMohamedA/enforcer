import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:lottie/lottie.dart';

import 'package:shimmer/shimmer.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../Api/api_provider.dart';
import '../../Models/MarketEntryModel/getMarketStats.dart';
import '../../widgets/failed_dialog.dart';
import '../../widgets/payment_dialog.dart';
import '../../Models/MarketEntryModel/getMarketTollTypes.dart';
import '../../Models/MarketEntryModel/getMarketTollCategories.dart';
import 'PaidMarketList.dart';


class MarketEntry extends StatefulWidget {
  var token;
  MarketEntry({
    required this.token
  });

  @override
  State<MarketEntry> createState() => _MarketEntryState();
}

class _MarketEntryState extends State<MarketEntry> with SingleTickerProviderStateMixin {
  TabController? tabController;
  final _formKey = GlobalKey<FormState>();

  TextEditingController _plateIdController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  String? selectedTollTypeId;
  MarketTollTypeDatum? selectedDropdownTollType;

  String? selectedCategoryId;
  MarketTollCategoryDatum? selectedDropdownCategory;

  bool promptPayment = false;

  late Future<GetMarketStats> statsFuture;
  late Future<Map<String, dynamic>> permissionsFuture;

  DailyStats? dailyStats;
  MonthlyStats? monthlyStats;

  late Future<GetMarketTollTypes> tollTypesFuture;
  List<MarketTollTypeDatum>? tollTypesData;

  late Future<GetMarketTollCategories> tollCategoriesFuture;
  List<MarketTollCategoryDatum>? categoriesData;

  bool typeSelected = false;
  bool categorySelected = false;

  String _fullPhoneNumber = '';
  PhoneNumber _initialPhoneNumber = PhoneNumber(isoCode: 'KE');
  bool _isValidNumber = false;

  Future loadList() async {
    try {
      setState(() {
        statsFuture = ApiProvider().getMarketStats(token: widget.token);
      });
    } catch (e) {
      debugPrint('Error fetching token: $e');
    }
  }

  void _showLoadingPayment(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
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
    permissionsFuture = ApiProvider().checkPermission(permissionType: 'Access Toll Market', token: widget.token);
    // permissionsFuture = Future.value({'access': true, 'message': 'Granted'});

    statsFuture = ApiProvider().getMarketStats(token: widget.token);
    tollTypesFuture = loadTollTypes();

    tabController = TabController(length: 2, vsync: this);
    tabController!.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _plateIdController.dispose();
    _phoneController.dispose();
    super.dispose();
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

  Future<GetMarketTollTypes> loadTollTypes() async {
    try {
      return await ApiProvider().getMarketTollTypes(token: widget.token);
    } catch (e) {
      List<String> tollTypes = ['Advertising', 'Empty Vehicle', 'Entry Fee'];
      List<MarketTollTypeDatum> data = tollTypes.asMap().entries
          .map((e) => MarketTollTypeDatum(id: e.key + 1, name: e.value))
          .toList();
      return GetMarketTollTypes(status: 'success', data: data);
    }
  }

  String _getFeeForCategory(String? category) {
    const Map<String, String> fees = {
      'Canter and above': '1000',
      'Saloon Car': '500',
      'Above 7 tonnes': '800',
      '3-7 tonnes': '600',
      'Mini-lorry 3 tonnes': '400',
      'Pick-up': '250',
      'Hand-carts': '50',
      'Tuktuk': '50',
      'Saloon Cars': '100',
      'Vehicles with goods': '100',
    };
    return fees[category] ?? '0';
  }

  Future<GetMarketTollCategories> loadCategories(String typeId) async {
    try {
      return await ApiProvider().getMarketTollCategories(token: widget.token, typeId: typeId);
    } catch (e) {
      if (selectedDropdownTollType == null) throw e;
      String typeName = selectedDropdownTollType!.name ?? '';

      Map<String, List<String>> tollCategories = {
        'Advertising': ['Canter and above', 'Saloon Car'],
        'Empty Vehicle': ['Above 7 tonnes', '3-7 tonnes', 'Mini-lorry 3 tonnes', 'Pick-up', 'Hand-carts', 'Tuktuk'],
        'Entry Fee': ['Saloon Cars', 'Vehicles with goods'],
      };

      List<String> categoryNames = tollCategories[typeName] ?? [];

      List<MarketTollCategoryDatum> data = categoryNames.asMap().entries.map((e) => MarketTollCategoryDatum(
        id: e.key + 1,
        name: e.value,
        amount: double.tryParse(_getFeeForCategory(e.value)) ?? 0.0,
      )).toList();

      return GetMarketTollCategories(status: 'success', data: data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final fontSize = screenWidth / 28.0;

    String formatNumb(String numb) {
      final NumberFormat formatter = NumberFormat("#,##0.00", "en_US");
      double numberr = double.parse(numb);
      return formatter.format(numberr);
    }

    final isKeyboard = MediaQuery.of(context).viewInsets.bottom != 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        toolbarHeight: 80,
        title: Text(
          "Market Entry",
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w600,
            fontSize: fontSize * 1.4,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(bottomRight: Radius.circular(30)),
            gradient: LinearGradient(
              colors: [Color(0XFF3E4095), Color(0XFF3E4095)],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ),
      ),
      body: FutureBuilder(
        future: permissionsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: FailedDialog(message: "Failed to verify permissions"));
          } else if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Color(0XFF3E4095)));
          } else {
            Map<String, dynamic>? permissionResult = snapshot.data;
            if (permissionResult!['access'] == true) {
              return RefreshIndicator(
                onRefresh: () => loadList(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: ScrollConfiguration(
                    behavior: ScrollBehavior().copyWith(overscroll: false),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isKeyboard) SizedBox(height: screenHeight * 0.03),
                        if (!isKeyboard)
                          Text(
                            "My statistics",
                            style: GoogleFonts.manrope(
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w800,
                              fontSize: fontSize * 1.2,
                              color: Color(0XFF3E4095),
                            ),
                          ),
                        SizedBox(height: 10),
                        if (!isKeyboard)
                          FutureBuilder(
                            future: statsFuture,
                            builder: (context, snapshot) {
                              if (snapshot.hasError || !snapshot.hasData) {
                                return Container();
                              } else {
                                dailyStats = snapshot.data!.dailyStats;
                                monthlyStats = snapshot.data!.monthlyStats;
                                String dailyAmountPaid = formatNumb((dailyStats!.totalAmount ?? 0.0).toString());
                                String monthlyAmountPaid = formatNumb((monthlyStats!.totalAmount ?? 0.0).toString());
                                return IntrinsicHeight(
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
                                                    onTap: () {
                                                      FocusScope.of(context).unfocus();
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (c) => paidMarket(token: widget.token),
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black.withOpacity(0.5),
                                                            spreadRadius: 1,
                                                            blurRadius: 3,
                                                            offset: Offset(0, 3),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Center(
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            shape: BoxShape.circle,
                                                            border: Border.all(
                                                              color: Color(0XFF3E4095),
                                                              width: 1.6,
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
                                                                child: Image.asset(
                                                                  'assets/images/market-entry.png',
                                                                  width: screenWidth * 0.12,
                                                                  height: screenWidth * 0.12,
                                                                  color: Color(0XFF3E4095),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 9),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        "Daily Market Paid",
                                                        style: GoogleFonts.manrope(
                                                          fontWeight: FontWeight.w500,
                                                          fontSize: fontSize * 1,
                                                          color: Color(0XFF3E4095),
                                                        ),
                                                      ),
                                                      SizedBox(height: 8),
                                                      Text(
                                                        dailyStats!.paidMarket ?? '0',
                                                        style: GoogleFonts.manrope(
                                                          fontWeight: FontWeight.w500,
                                                          fontSize: fontSize * 1.2,
                                                          color: Color(0XFF3E4095),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        child: VerticalDivider(
                                          color: Color(0XFF3E4095),
                                          thickness: 2.6,
                                          width: 20,
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Row(
                                              children: [
                                                SvgPicture.asset(
                                                  "assets/images/money.svg",
                                                  width: screenWidth * 0.09,
                                                  height: screenWidth * 0.09,
                                                  color: Color(0XFF3E4095),
                                                ),
                                                SizedBox(width: 5),
                                                Flexible(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        "Daily Collection",
                                                        style: GoogleFonts.manrope(
                                                          fontWeight: FontWeight.w500,
                                                          fontSize: fontSize * 0.9,
                                                          color: Color(0XFF3E4095),
                                                        ),
                                                      ),
                                                      SizedBox(height: 5),
                                                      Text(
                                                        'Kes: $dailyAmountPaid',
                                                        style: GoogleFonts.manrope(
                                                          fontWeight: FontWeight.w700,
                                                          fontSize: fontSize * 0.9,
                                                          color: Color(0XFF3E4095),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 10),
                                            Divider(color: Color(0XFF3E4095), thickness: 2.6),
                                            SizedBox(height: 10),
                                            Row(
                                              children: [
                                                SvgPicture.asset(
                                                  "assets/images/money.svg",
                                                  width: screenWidth * 0.09,
                                                  height: screenWidth * 0.09,
                                                  color: Color(0XFF3E4095),
                                                ),
                                                SizedBox(width: 5),
                                                Flexible(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        "Monthly Collection",
                                                        style: GoogleFonts.manrope(
                                                          fontWeight: FontWeight.w500,
                                                          fontSize: fontSize * 0.9,
                                                          color: Color(0XFF3E4095),
                                                        ),
                                                      ),
                                                      SizedBox(height: 5),
                                                      Text(
                                                        'Kes: $monthlyAmountPaid',
                                                        style: GoogleFonts.manrope(
                                                          fontWeight: FontWeight.w700,
                                                          fontSize: fontSize * 0.9,
                                                          color: Color(0XFF3E4095),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                        SizedBox(height: 10),
                        Container(
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
                              labelStyle: GoogleFonts.manrope(fontSize: fontSize * 0.9),
                              indicator: BoxDecoration(
                                color: Color(0xFFFFCC2A),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              tabs: [
                                Tab(text: 'Prompt Payment'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Expanded(
                          child: TabBarView(
                            physics: NeverScrollableScrollPhysics(),
                            controller: tabController,
                            children: [
                              ScrollConfiguration(
                                behavior: ScrollBehavior().copyWith(overscroll: false),
                                child: SingleChildScrollView(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 2.0),
                                    child: promptPaymentForm(fontSize, context),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                child: checkStatusForm(fontSize, context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return FailedDialog(
                message: permissionResult['message'].toString(),
              );
            }
          }
        },
      ),
    );
  }

  Widget promptPaymentForm(double fontSize, BuildContext context) {
    return Column(
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Field 1: Toll Type
              Text(
                'Market Toll Type',
                style: GoogleFonts.manrope(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              FutureBuilder<GetMarketTollTypes>(
                future: tollTypesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return createDisabledDropdownSearch("Fetching Toll Types...");
                  } else if (snapshot.hasError) {
                    return createDisabledDropdownSearch("Error Fetching Toll Types");
                  } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
                    return createDisabledDropdownSearch("No Toll Types Found");
                  } else {
                    tollTypesData = snapshot.data!.data;
                    return DropdownSearch<MarketTollTypeDatum>(
                      mode: Mode.DIALOG,
                      items: tollTypesData,
                      selectedItem: selectedDropdownTollType,
                      itemAsString: (MarketTollTypeDatum? type) => type?.name ?? '',
                      dropdownSearchDecoration: InputDecoration(
                        hintText: "Select Toll Type",
                        hintStyle: GoogleFonts.manrope(fontSize: fontSize),
                        disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF1366D9), width: 1.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Color(0xFF46B1FD)),
                        ),
                      ),
                      onChanged: (MarketTollTypeDatum? selected) {
                        if (selected != null) {
                          setState(() {
                            selectedTollTypeId = selected.id.toString();
                            typeSelected = true;
                            selectedDropdownTollType = selected;
                            selectedCategoryId = null;
                            selectedDropdownCategory = null;
                            categorySelected = false;
                            tollCategoriesFuture = loadCategories(selectedTollTypeId!);
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null) return 'Please select a toll type';
                        return null;
                      },
                      showSearchBox: true,
                    );
                  }
                },
              ),
              const SizedBox(height: 15),

              // Field 2: Toll Category
              if (typeSelected) ...[
                Text(
                  'Market Toll Category',
                  style: GoogleFonts.manrope(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                FutureBuilder<GetMarketTollCategories>(
                  future: tollCategoriesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return createDisabledDropdownSearch("Fetching Categories...");
                    } else if (snapshot.hasError) {
                      return createDisabledDropdownSearch("Error Fetching Categories");
                    } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
                      return createDisabledDropdownSearch("No Categories Found");
                    } else {
                      categoriesData = snapshot.data!.data;
                      return DropdownSearch<MarketTollCategoryDatum>(
                        mode: Mode.DIALOG,
                        items: categoriesData,
                        selectedItem: selectedDropdownCategory,
                        itemAsString: (MarketTollCategoryDatum? category) => category?.name ?? '',
                        dropdownSearchDecoration: InputDecoration(
                          hintText: "Select Category",
                          hintStyle: GoogleFonts.manrope(fontSize: fontSize),
                          disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF1366D9), width: 1.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Color(0xFF46B1FD)),
                          ),
                        ),
                        onChanged: (MarketTollCategoryDatum? selected) {
                          if (selected != null) {
                            setState(() {
                              selectedCategoryId = selected.id.toString();
                              selectedDropdownCategory = selected;
                              categorySelected = true;
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null) return 'Please select a category';
                          return null;
                        },
                        showSearchBox: true,
                      );
                    }
                  },
                ),
                const SizedBox(height: 15),
              ],

              // Field 3 & 4: ID/Plate + Phone
              if (categorySelected) ...[
                Text(
                  (selectedDropdownCategory?.name == 'Hand-carts') ? 'ID Number' : 'Plate Number',
                  style: GoogleFonts.manrope(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _plateIdController,
                  keyboardType: (selectedDropdownCategory?.name == 'Hand-carts')
                      ? TextInputType.number
                      : TextInputType.text,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: (selectedDropdownCategory?.name == 'Hand-carts')
                        ? 'Enter ID Number'
                        : 'Enter Plate Number',
                    hintStyle: GoogleFonts.manrope(fontSize: fontSize),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Color(0xFF46B1FD)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'This field is required';
                    String categoryName = selectedDropdownCategory?.name ?? '';
                    String trimmedValue = value.replaceAll(' ', '');
                    if (categoryName == 'Hand-carts') {
                      bool isDigitsOnly = RegExp(r'^[0-9]+$').hasMatch(trimmedValue);
                      if (!isDigitsOnly || trimmedValue.length != 8) {
                        return 'Hand-carts require a valid 8-digit ID number';
                      }
                    } else {
                      bool isAlphanumeric = RegExp(r'^[a-zA-Z0-9]+$').hasMatch(trimmedValue);
                      if (!isAlphanumeric || (trimmedValue.length != 7 && trimmedValue.length != 8)) {
                        return 'Enter a valid Plate Number (7 or 8 alphanumeric characters)';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                Text(
                  'Phone Number',
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
                  },
                  onInputValidated: (isValid) {
                    setState(() {
                      _isValidNumber = isValid;
                    });
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
                    hintStyle: GoogleFonts.manrope(fontSize: fontSize),
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
                const SizedBox(height: 25),

                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 5),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
                      if ((_formKey.currentState?.validate() ?? false) && _isValidNumber) {
                        setState(() {
                          promptPayment = true;
                        });
                        try {
                          // Step 1: Create the order
                          Map<String, dynamic> response = await ApiProvider().promptMarketEntry(
                            token: widget.token,
                            plateId: _plateIdController.text,
                            phone: _fullPhoneNumber,
                            typeId: selectedTollTypeId,
                            categoryId: selectedCategoryId,
                            amount: selectedDropdownCategory?.amount,
                          );

                          if (response['status'] != "success" && response['status'] != 200) {
                            setState(() {
                              promptPayment = false;
                            });
                            _showErrorDialog(response['message'] ?? 'Payment Request Failed');
                          } else {
                            // Step 2: Extract orderId from createOrder response
                            // Response: { "status": "success", "orderId": "MKTE-000042", "pgwResponse": {...} }
                            final String? orderId = response['orderId'] as String?; // 👈 "MKTE-000042"

                            if (orderId == null) {
                              setState(() { promptPayment = false; });
                              _showErrorDialog('Failed to retrieve Order ID. Please try again.');
                              return;
                            }

                            setState(() {
                              promptPayment = false;
                            });

                            // Show waiting dialog
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (ctx) {
                                return WillPopScope(
                                  onWillPop: () async => false,
                                  child: paymentDialog(
                                    message: "Payment Initiated. Waiting for confirmation....",
                                  ),
                                );
                              },
                            );

                            // Step 3: Poll for payment status using orderId
                            bool paymentConfirmed = false;
                            bool isTimeout = false;

                            final startTime = DateTime.now();
                            const timeout = Duration(seconds: 30);

                            while (DateTime.now().difference(startTime) < timeout) {
                              try {
                                Map<String, dynamic> checkStatus = await ApiProvider().checkMarketPaymentStatus(
                                  token: widget.token,
                                  orderId: orderId, // 👈 was phone: _fullPhoneNumber
                                );

                                if (checkStatus['status'] == "success") {
                                  if (checkStatus['data'] == "Completed") {
                                    paymentConfirmed = true;
                                    break;
                                  } else if (checkStatus['data'] == "Failed") {
                                    break;
                                  }
                                }
                              } catch (e) {
                                // Ignore intermittent polling errors
                              }
                              await Future.delayed(Duration(seconds: 5));
                            }

                            if (!paymentConfirmed) {
                              isTimeout = true;
                            }

                            Navigator.of(context).pop(); // Pop the waiting dialog

                            if (paymentConfirmed) {
                              setState(() {
                                _plateIdController.clear();
                                _phoneController.clear();
                                typeSelected = false;
                                categorySelected = false;
                                selectedDropdownTollType = null;
                                selectedDropdownCategory = null;
                                statsFuture = ApiProvider().getMarketStats(token: widget.token);
                              });
                              _showSuccessDialog("Payment Successfully Received");
                            } else if (isTimeout) {
                              _showErrorDialog(
                                "Connection Timed Out Without Payment Confirmation. Please tap Initiate Payment to try again.",
                              );
                            }
                          }
                        } catch (e) {
                          _showErrorDialog(e.toString());
                        }

                        setState(() {
                          promptPayment = false;
                        });
                      }
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      ),
                      backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFFFCC2A)),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                      minimumSize: MaterialStateProperty.all<Size>(const Size(double.infinity, 60)),
                    ),
                    child: promptPayment
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Initiate Payment',
                            style: GoogleFonts.manrope(
                              fontSize: fontSize * 1.2,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF3E4095),
                            ),
                          ),
                  ),
                ),
              ],
              SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget checkStatusForm(double fontSize, BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Lottie.asset(
              repeat: false,
              'assets/lotti/error.json',
              width: ContextExtensions(context).width(),
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
                    fontSize: fontSize * 1.2,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Kindly contact your Administrator.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w500,
                    fontSize: fontSize * 1.3,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}