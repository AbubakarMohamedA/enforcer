import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../../Api/api_provider.dart';
import '../../Models/Offloading/getOffloadingItems.dart';
import '../../widgets/failed_dialog.dart';


class goodDetailsAdd extends StatefulWidget {
  var goodsOrigin;
  var destination;
  var vehicleType;
  var plateNumber;
  var zoneId;
  var vehicleTypeName;
  var clientName;
  var clientPhone;
  var token;
  var capturedApplicationId;

  final Function? clearPromptPageCallback;
  final Function? CheckPaymentDialogCallback;
  final String navigateBackAgain;
   goodDetailsAdd({
     required this.goodsOrigin,
     required this.vehicleType,
     required this.destination,
     required this.plateNumber,
     required this.zoneId,
     required this.vehicleTypeName,
     required this.clientName,
     required this.clientPhone,
     required this.token,
     required this.capturedApplicationId,

     required this.clearPromptPageCallback,
     required this.CheckPaymentDialogCallback,
     required this.navigateBackAgain
});

  @override
  State<goodDetailsAdd> createState() => _goodDetailsAddState();
}

class _goodDetailsAddState extends State<goodDetailsAdd> {
  final _formKey = GlobalKey<FormState>();


  bool isChecked = false;


  List<selectedProduct> selectedProductsList = [];


  String? individualTotal = '0.00';

  double? grandTotal = 0.00;

  bool expandItems = false;
  bool isLoading = false;
  bool quantityReadyOnly = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    itemsFuture =  ApiProvider().getOffLoadingItems(token: widget.token);
  }


  //Offloading Items
  late Future<GetOffloadingItems> itemsFuture;
  List<OffLoadingItemsDatum>? itemsData;

  //DROPDOWNPLACEHOLDERS
  OffLoadingItemsDatum? holdingItem;
  List<OffLoadingItemsDatum>? selectedItems;
  OffLoadingItemsDatum? selectedUomItem;


  TextEditingController _uomController = TextEditingController();
  TextEditingController _quantityController = TextEditingController();

  GlobalKey<DropdownSearchState<String>> _ItemDropdownKey = GlobalKey();
  GlobalKey<DropdownSearchState<String>> _UomDropdownKey = GlobalKey();


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final imageDimension = screenWidth / 3.3;
    final fontSize = screenWidth / 27.0;


    String formatNumb(String numb) {
      final NumberFormat formatter = NumberFormat("#,##0.00", "en_US");
      double numberr = double.parse(numb);
      return formatter.format(numberr);
    }
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        toolbarHeight: 80,
        title: Text(
          "Enter Good Details",
          style: GoogleFonts.manrope(
            // fontFamily: "Mulish",
            fontWeight: FontWeight.w600,
            fontSize: 19,
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: ScrollConfiguration(
            behavior: ScrollBehavior().copyWith(overscroll:false),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 5,),
                  Card(
                    elevation: 2,
                    margin: EdgeInsets.only(
                        top: size.height * 0.01,
                        bottom: size.height * 0.01),
                    shape: RoundedRectangleBorder(
                      // side: BorderSide(
                      //   // color: Colors.black54.withOpacity(0.1)
                      // ),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEFEFEF),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(7),
                              topRight: Radius.circular(7),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 15,
                                right: 15,
                                top: 15,
                                bottom: 20),
                            child: Row(
                              crossAxisAlignment:
                              CrossAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.info,
                                  color: Colors.black,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'Type - Normal',
                                  style: GoogleFonts.manrope(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: size.width * 0.35,
                                    child: Text('Goods Origin:',
                                      style: GoogleFonts.manrope(
                                        fontSize: fontSize,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black.withOpacity(0.7),
                                      ),),
                                  ),
                                  SizedBox(
                                    width: size.width * 0.01,
                                  ),
                                  Flexible(
                                    child: Text(widget.goodsOrigin,
                                      style: GoogleFonts.manrope(
                                        fontSize: fontSize,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: size.height * 0.009,
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: size.width * 0.35,
                                    child: Text('Goods Destination:',
                                      style: GoogleFonts.manrope(
                                        fontSize: fontSize,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black.withOpacity(0.7),
                                      ),),
                                  ),
                                  SizedBox(
                                    width: size.width * 0.01,
                                  ),
                                  Flexible(
                                    child: Text(widget.destination,
                                      style: GoogleFonts.manrope(
                                        fontSize: fontSize,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: size.height * 0.009,
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: size.width * 0.35,
                                    child: Text('Vehicle Type:',
                                      style: GoogleFonts.manrope(
                                        fontSize: fontSize,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black.withOpacity(0.7),
                                      ),),
                                  ),
                                  SizedBox(
                                    width: size.width * 0.01,
                                  ),
                                  Flexible(
                                    child: Text(widget.vehicleTypeName,
                                      style: GoogleFonts.manrope(
                                        fontSize: fontSize,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: size.height * 0.009,
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: size.width * 0.35,
                                    child: Text('Plate Number:',
                                      style: GoogleFonts.manrope(
                                        fontSize: fontSize,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black.withOpacity(0.7),
                                      ),),
                                  ),
                                  SizedBox(
                                    width: size.width * 0.01,
                                  ),
                                  Flexible(
                                    child: Text(widget.plateNumber,
                                      style: GoogleFonts.manrope(
                                        fontSize: fontSize,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: size.height * 0.009,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEFEFEF),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(7),
                                topRight: Radius.circular(7),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 15,
                                  right: 15,
                                  top: 15,
                                  bottom: 20),
                              child: Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.shopping_cart,
                                    color: Colors.black,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    'Enter Good Details',
                                    style: GoogleFonts.manrope(
                                      fontWeight: FontWeight.bold,
                                    ),
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


                                FutureBuilder<GetOffloadingItems>(
                              future: itemsFuture,
                              builder: (context, AsyncSnapshot<GetOffloadingItems> snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return createDisabledDropdownSearch("Fetching Items.....", fontSize);
                                } else if (snapshot.hasError) {
                                  return createDisabledDropdownSearch("Error Fetching Items.....", fontSize);
                                } else if (!snapshot.hasData || snapshot.data!.data!.isEmpty) {
                                  return createDisabledDropdownSearch("No Items Found.....", fontSize);
                                } else {
                                  // Extracting the item names from the map keys
                                  final Map<String, List<OffLoadingItemsDatum>> itemsMap = snapshot.data!.data!;
                                  final List<String> itemNames = itemsMap.keys.toList();

                                  return DropdownSearch<String>(
                                    key: _ItemDropdownKey,
                                    items: itemNames, // Use item names for dropdown
                                    // selectedItem: holdingItem?.itemName, // Selected item
                                    itemAsString: (String? itemName) => itemName ?? '',
                                    dropdownSearchDecoration: InputDecoration(
                                      hintText: "Select Item",
                                      hintStyle: GoogleFonts.manrope(fontSize: fontSize),
                                      disabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0xFF1366D9),
                                          width: 1.0,
                                        ),
                                      ),
                                    ),
                                    onChanged: (String? itemName) {
                                      if (itemName != null) {
                                        setState(() {
                                          // Set the selected item based on item name
                                         selectedItems = itemsMap[itemName]!;
                                          print(selectedItems?.length);

                                         // RESET THE UOM
                                         selectedUomItem = null;
                                         _UomDropdownKey = GlobalKey();

                                          // holdingItem = selectedItems[0]; // Select the first item from the list
                                          // _uomController.text = holdingItem!.uom;

                                          //CLEAR PRICE AND QUANTITY CONTROLLER
                                          individualTotal = "0.00";
                                          _quantityController.clear();
                                        });
                                      }
                                    },
                                    validator: (value) {
                                      if (value == null) {
                                        return 'Please select an Item';
                                      }
                                      return null;
                                    },
                                    showSearchBox: true,
                                    isFilteredOnline: true,
                                    searchFieldProps: TextFieldProps(
                                      cursorColor: Colors.blue,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText: 'Search Items',
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                                SizedBox(
                                  height: size.height * 0.015,
                                ),
                                selectedItems == null ?
                                TextFormField(
                                  readOnly: true,
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                    hintText: "Select UOM",
                                    hintStyle: GoogleFonts.manrope(fontSize: fontSize),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(color: Color(0xFF46B1FD)),
                                    ),
                                  ),
                                  onTap: (){
                                    Get.snackbar(
                                      'Oops',
                                      'Please Select Item First',
                                      backgroundColor: Colors.redAccent.withOpacity(0.7),
                                      colorText: Colors.white,
                                      snackPosition: SnackPosition.TOP, // Adjust position if needed
                                      duration: Duration(seconds: 2), // Adjust duration if needed
                                      margin: EdgeInsets.only(left: 16.0,right: 16), // Adjust margin if needed
                                      borderRadius: 10.0, // Adjust border radius if needed
                                    );
                                  },

                                ):
                                DropdownSearch<OffLoadingItemsDatum>(
                                  key: _UomDropdownKey,
                                  mode: Mode.DIALOG,
                                  items: selectedItems, // Use item names for dropdown
                                  // selectedItem: selectedUomItem, // Selected item
                                  itemAsString: (OffLoadingItemsDatum? item) => item?.uom ?? '',
                                  dropdownSearchDecoration: InputDecoration(
                                    hintText: "Select UOM",
                                    hintStyle: GoogleFonts.manrope(fontSize: fontSize),
                                    disabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0xFF1366D9),
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                  onChanged: (OffLoadingItemsDatum? item) {
                                    if (item != null) {
                                      if(item!.uom!.contains("Flat Rate")){
                                        if(widget.vehicleTypeName == "Over 7 tonnes" && (!(item.uom!.contains('Over 7') || item.uom!.contains('Above 7') || item.uom!.contains('Above 14') ))){
                                          showFlatRateErrorAndResetFields();
                                        }else if(widget.vehicleTypeName == "Pick up" && (!(item.uom!.contains('Pick')))){
                                          showFlatRateErrorAndResetFields();
                                        }else if(widget.vehicleTypeName == "Handcart" && (!(item.uom!.contains('Hand')))){
                                          showFlatRateErrorAndResetFields();
                                        }else if(widget.vehicleTypeName == "20ft container and over" && (!(item.uom!.contains('20ft Container') || item.uom!.contains('Over 7') || item.uom!.contains('Above 7')  || item.uom!.contains('Above 14') ))){
                                          showFlatRateErrorAndResetFields();
                                        }else if(widget.vehicleTypeName == "Canter/Lorry below 7 tonnes" && (!(item.uom!.contains('Upto 7') || item.uom!.contains('Canter') || item.uom!.contains('Below 7') ))){
                                          showFlatRateErrorAndResetFields();
                                        }else{
                                          setState(() {
                                              quantityReadyOnly = true;
                                              _quantityController.text = '1';
                                              individualTotal = item.rate.toString();
                                              selectedUomItem = item;
                                            });
                                        }
                                      } else {
                                        setState(() {
                                          selectedUomItem = item;
                                          individualTotal = '0.00';
                                          quantityReadyOnly = false;
                                          _quantityController.clear();
                                        });
                                      }

                                    }
                                  },
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Please select an Item Uom';
                                    }
                                    return null;
                                  },
                                  showSearchBox: true,
                                  isFilteredOnline: true,
                                  searchFieldProps: TextFieldProps(
                                    cursorColor: Colors.blue,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: 'Search Uoms',
                                    ),
                                  ),
                                ),

                                SizedBox(
                                  height: size.height * 0.015,
                                ),
                                selectedUomItem == null ?
                                TextFormField(
                                  readOnly: true,
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                    hintText: "Select Quantity",
                                    hintStyle: GoogleFonts.manrope(fontSize: fontSize),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(color: Color(0xFF46B1FD)),
                                    ),
                                  ),
                                  onTap: (){
                                    Get.snackbar(
                                      'Oops',
                                      'Please Select Uom First',
                                      backgroundColor: Colors.redAccent.withOpacity(0.7),
                                      colorText: Colors.white,
                                      snackPosition: SnackPosition.TOP, // Adjust position if needed
                                      duration: Duration(seconds: 2), // Adjust duration if needed
                                      margin: EdgeInsets.only(left: 16.0,right: 16), // Adjust margin if needed
                                      borderRadius: 10.0, // Adjust border radius if needed
                                    );
                                  },

                                ):
                                TextFormField(
                                  readOnly: quantityReadyOnly ? true : false,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                    hintText: 'Enter quantity',
                                    hintStyle: GoogleFonts.manrope(fontSize: fontSize),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(color: Color(0xFF46B1FD)),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(Icons.production_quantity_limits),
                                      onPressed: () {},
                                    ),
                                  ),
                                  validator: (value){
                                    if (value!.isEmpty) {
                                      return 'Enter Quantity';
                                    }
                                  },
                                  onChanged: (value) {
                                    if(value != null){
                                      setState(() {
                                        // quantitySelected = double.tryParse(value);
                                        calcTotalIndividual(double.tryParse(value)!,selectedUomItem);
                                      });
                                    }
                                  },
                                  controller: _quantityController,
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: screenWidth * 0.45,
                                      child: Row(
                                        children: [
                                           Text(
                                            'Total: ',
                                            style: GoogleFonts.manrope(
                                                color: Colors.black,
                                                fontSize: fontSize*1.1,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Flexible(
                                            child: Text(
                                              'Ksh ${formatNumb(individualTotal.toString())}',
                                              style: GoogleFonts.manrope(
                                                  color: Colors.black,
                                                  fontSize: fontSize*1.1,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Spacer(),
                                    Container(
                                      width: screenWidth*0.4,
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
                                         if(selectedItems == null)
                                          {
                                            Get.snackbar(
                                              'Oops',
                                              'Please select Product First!',
                                              backgroundColor: Colors.redAccent.withOpacity(0.7),
                                              colorText: Colors.white,
                                              snackPosition: SnackPosition.TOP, // Adjust position if needed
                                              duration: Duration(seconds: 2), // Adjust duration if needed
                                              margin: EdgeInsets.only(left: 16.0,right: 16), // Adjust margin if needed
                                              borderRadius: 10.0, // Adjust border radius if needed
                                            );
                                          }else if(selectedUomItem == null){
                                           Get.snackbar(
                                             'Oops',
                                             'Please select UOM!',
                                             backgroundColor: Colors.redAccent.withOpacity(0.7),
                                             colorText: Colors.white,
                                             snackPosition: SnackPosition.TOP, // Adjust position if needed
                                             duration: Duration(seconds: 2), // Adjust duration if needed
                                             margin: EdgeInsets.only(left: 16.0,right: 16), // Adjust margin if needed
                                             borderRadius: 10.0, // Adjust border radius if needed
                                           );
                                         }
                                         else if(_quantityController.text.isEmpty){
                                            Get.snackbar(
                                              'Oops',
                                              'Please select Quantity!',
                                              backgroundColor: Colors.redAccent.withOpacity(0.7),
                                              colorText: Colors.white,
                                              snackPosition: SnackPosition.TOP, // Adjust position if needed
                                              duration: Duration(seconds: 2), // Adjust duration if needed
                                              margin: EdgeInsets.only(left: 16.0,right: 16), // Adjust margin if needed
                                              borderRadius: 10.0, // Adjust border radius if needed
                                            );
                                          }
                                          else{

                                           bool isExistingProducts = selectedProductsList.any((product) =>
                                           product.itemChosen!.itemId == selectedUomItem?.itemId);

                                           bool isFlatRateSelectedForItemName(String itemName) {
                                             // Check if "flatrate" is already selected for the same item name
                                             return selectedProductsList.any((product) =>
                                             product.itemChosen!.itemName == itemName && product.itemChosen!.uom!.contains('Flat'));
                                           }

                                           bool isOtherUomSelectedForItemName(String itemName) {
                                             // Check if any UOM other than "flatrate" is selected for the same item name
                                             return selectedProductsList.any((product) =>
                                             product.itemChosen!.itemName == itemName && !product.itemChosen!.uom!.contains('Flat'));
                                           }

                                           bool canSelectUom(String itemName, String selectedUom) {
                                             // If trying to select "flatrate" but other UOMs already selected, reject
                                             if (selectedUom.contains('Flat') && isOtherUomSelectedForItemName(itemName)) {
                                               print("Cannot select 'flatrate' as other UOMs are already selected for $itemName.");

                                               Get.snackbar(
                                                     'Oops',
                                                     'Cannot Select Flat Rate. Other Uom Exist!',
                                                     backgroundColor: Colors.redAccent.withOpacity(0.7),
                                                     colorText: Colors.white,
                                                     snackPosition: SnackPosition.TOP, // Adjust position if needed
                                                     duration: Duration(seconds: 2), // Adjust duration if needed
                                                     margin: EdgeInsets.only(left: 16.0,right: 16), // Adjust margin if needed
                                                     borderRadius: 10.0, // Adjust border radius if needed
                                                   );
                                               return false;
                                             }

                                             // If other UOM is selected but "flatrate" already exists, reject
                                             if (!selectedUom.contains('Flat') && isFlatRateSelectedForItemName(itemName)) {
                                               print("Cannot select other UOMs as 'flatrate' is already selected for $itemName.");
                                               Get.snackbar(
                                                 'Oops',
                                                 'Flat Rate already exists!',
                                                 backgroundColor: Colors.redAccent.withOpacity(0.7),
                                                 colorText: Colors.white,
                                                 snackPosition: SnackPosition.TOP, // Adjust position if needed
                                                 duration: Duration(seconds: 2), // Adjust duration if needed
                                                 margin: EdgeInsets.only(left: 16.0,right: 16), // Adjust margin if needed
                                                 borderRadius: 10.0, // Adjust border radius if needed
                                               );
                                               return false;
                                             }
                                             // If flat rate is selected but "flatrate" already exists, reject
                                             if (selectedUom.contains('Flat') && isFlatRateSelectedForItemName(itemName)) {
                                               print("Cannot select other UOMs as 'flatrate' is already selected for $itemName.");
                                               Get.snackbar(
                                                 'Oops',
                                                 'Flat Rate already exists!',
                                                 backgroundColor: Colors.redAccent.withOpacity(0.7),
                                                 colorText: Colors.white,
                                                 snackPosition: SnackPosition.TOP, // Adjust position if needed
                                                 duration: Duration(seconds: 2), // Adjust duration if needed
                                                 margin: EdgeInsets.only(left: 16.0,right: 16), // Adjust margin if needed
                                                 borderRadius: 10.0, // Adjust border radius if needed
                                               );
                                               return false;
                                             }
                                             // No conflicts, allow selection
                                             return true;
                                           }

                                           // Usage
                                           String itemName = selectedUomItem?.itemName ?? ''; // Get the item's name
                                           String selectedUom = selectedUomItem?.uom ?? ''; // Get the selected UOM

                                           if (canSelectUom(itemName, selectedUom)) {
                                             if(isExistingProducts){
                                               Get.snackbar(
                                                 'Oops',
                                                 'Product already exists!',
                                                 backgroundColor: Colors.redAccent.withOpacity(0.7),
                                                 colorText: Colors.white,
                                                 snackPosition: SnackPosition.TOP, // Adjust position if needed
                                                 duration: Duration(seconds: 2), // Adjust duration if needed
                                                 margin: EdgeInsets.only(left: 16.0,right: 16), // Adjust margin if needed
                                                 borderRadius: 10.0, // Adjust border radius if needed
                                               );
                                             }else
                                             {

                                               selectedProduct product = selectedProduct(
                                                   quantity: _quantityController.text,
                                                   Amount : individualTotal.toString(),
                                                   itemChosen: selectedUomItem
                                               );

                                               selectedProductsList.add(product);
                                               grandTotal = selectedProductsList.fold(0.0, (sum, product) => sum! + double.parse(product.Amount));

                                               Get.snackbar(
                                                 'Success',
                                                 'Product Successfully Added!',
                                                 backgroundColor: Colors.green.withOpacity(0.7),
                                                 colorText: Colors.white,
                                                 snackPosition: SnackPosition.TOP, // Adjust position if needed
                                                 duration: Duration(seconds: 2), // Adjust duration if needed
                                                 margin: EdgeInsets.only(left: 16.0,right: 16), // Adjust margin if needed
                                                 borderRadius: 10.0, // Adjust border radius if needed
                                               );

                                               setState(() {
                                                 _ItemDropdownKey = GlobalKey();
                                                 selectedItems = null;
                                                 _UomDropdownKey = GlobalKey();
                                                 selectedUomItem = null;
                                                 _quantityController.clear();
                                                 individualTotal = "0.00";
                                               });

                                             }
                                             print("UOM selection for $itemName is allowed.");
                                           }
                                           else {
                                             // Block selection if the check fails
                                             print("UOM selection for $itemName is blocked.");
                                           }

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
                                            const Size(double.infinity, 55),
                                          ),
                                        ),
                                        child:  Text(
                                          'Add Item',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.manrope(
                                            fontSize: fontSize * 1,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFFFFCC2A),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (selectedProductsList.isNotEmpty) SizedBox(height: 20),
                  if (selectedProductsList.isNotEmpty)
                    Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(
                          top: 10, bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                expandItems = !expandItems;
                              });
                            },
                            child: Container(
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEFEFEF),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(7),
                                  topRight: Radius.circular(7),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 15,
                                    right: 15,
                                    top: 15,
                                    bottom: 20),
                                child: Row(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.add_circle_outline_outlined,
                                      color: Colors.black,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                     Text(
                                      'Added Products',
                                      style: GoogleFonts.manrope(
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
                          ),
                          if (expandItems)
                            AnimatedContainer(
                              duration: const Duration(
                                  milliseconds: 500),
                              curve: Curves.easeInOut,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0,
                                    right: 8.0,
                                    top: 0),
                                child: Column(
                                  children: [
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                      NeverScrollableScrollPhysics(),
                                      itemCount: selectedProductsList.length,
                                      itemBuilder:
                                          (context, index) {
                                            selectedProduct currentItem = selectedProductsList[index];
                                        return PaidGoodsItem(
                                          UOM: currentItem.itemChosen!.uom.toString(),
                                          itemName: currentItem.itemChosen!.itemName,
                                          rate: currentItem.itemChosen!.rate.toString(),
                                          quantity: currentItem.quantity,
                                          totalAmount: currentItem.Amount,
                                          RemoveItemFromList: () => RemoveItemFromList(index),

                                        );
                                      },
                                    ),

                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Row(
                                        children: [
                                          Text('Grand Total:',  style: GoogleFonts.manrope(
                                            fontSize: fontSize * 1,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),),
                                          SizedBox(
                                            width: size.width * 0.01,
                                          ),
                                          Flexible(
                                            child: Text(("Ksh ${formatNumb(grandTotal.toString())}"),
                                                style: GoogleFonts.manrope(
                                                  fontSize: fontSize * 1,
                                                  // fontWeight: FontWeight.w500,
                                                  color: Colors.black.withOpacity(0.7),
                                                )),
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 22,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Checkbox(
                          activeColor: Colors.blueAccent,
                          value: isChecked,
                          onChanged: (bool? newValue) {
                            setState(() {
                              isChecked = newValue ?? false;
                            });
                          }),
                      SizedBox(
                        width: size.width * 0.001,
                      ),
                       Flexible(
                        child: Text(
                          'I declare that all the information provided in this form is true and correct to the best of my knowledge.',
                          style: GoogleFonts.manrope(
                              fontSize: fontSize * 0.9,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54),
                        ),
                      ),
                    ],
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
                     onPressed: _submitForm,
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
                      child: isLoading ?
                          CircularProgressIndicator(
                            color: Colors.white,
                          )
                          : Text(
                        'Submit',
                        style: GoogleFonts.manrope(
                          fontSize: fontSize * 1.2,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF3E4095),
                        ),
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

  void showFlatRateErrorAndResetFields() {
    Get.snackbar(
      'Error',
      'You must select the right Flat rate option based on your selected vehicle type (${widget.vehicleTypeName}).',
      backgroundColor: Colors.redAccent.withOpacity(0.7),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 4), // Adjust duration if needed
      margin: EdgeInsets.only(left: 16.0, right: 16), // Adjust margin if needed
      borderRadius: 10.0, // Adjust border radius if needed
    );

    setState(() {
      _quantityController.text = '';  // Reset the quantity field
      selectedUomItem = null;         // Clear the selected UOM
      _UomDropdownKey = GlobalKey();  // Reset the dropdown key
      quantityReadyOnly = false;      // Set the quantity as editable
      individualTotal = '0.00';       // Reset the individual total
    });
  }


  calcTotalIndividual(double quanity, OffLoadingItemsDatum? item){
    setState(() {
      individualTotal = (quanity * item!.rate!).toString();
      print("The selected individual total is ${individualTotal}");
    });

  }

  void RemoveItemFromList(int index) {
    setState(() {
      selectedProductsList.removeAt(index);  // Remove by index
      grandTotal = selectedProductsList.fold(0.0, (sum, product) => sum! + double.parse(product.Amount));
    });
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
      readOnly: true,
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
  void _submitForm() async {
    if(selectedProductsList.isEmpty){
      Get.snackbar(
        'Oops',
        'Please Add Products First',
        backgroundColor: Colors.redAccent.withOpacity(0.7),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 2),
        margin: EdgeInsets.only(left: 16.0,right: 16),
        borderRadius: 10.0,
      );
    }else  if(isChecked == false){
      Get.snackbar(
        'Oops',
        'Please Accept Declaration First',
        backgroundColor: Colors.redAccent.withOpacity(0.7),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 2),
        margin: EdgeInsets.only(left: 16.0,right: 16),
        borderRadius: 10.0,
      );
    } else {
      setState(() {
        isLoading = true;
      });
      List<Map<String, dynamic>> postData =
      selectedProductsList.map((product) {
        return {
          'id': product.itemChosen!.itemId,
          'amount': product.itemChosen!.rate,
          'quantity': product.quantity
        };
      }).toList();
      await ApiProvider()
          .postOffloadingItems(
          clientName: widget.clientName,
          clientPhone: widget.clientPhone,
          plateNumber: widget.plateNumber,
          vehicleType: widget.vehicleType,
          zone: widget.zoneId,
          token: widget.token,
          items: postData,
          penalty: 0
      )
          .then((value) async {
        setState(() {
          isLoading = false;
        });
        if(value['status'] == "success"){
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          if (widget.navigateBackAgain == 'Thrice') {
            Navigator.of(context).pop();
          }
          if (widget.navigateBackAgain == 'Four') {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          }
          var responseData = value['data'] ?? value;
          print('DEBUG postOffloadingItems response: $value');
          print('DEBUG responseData: $responseData');
          String? newAppId = responseData['application_id']?.toString()
              ?? responseData['id']?.toString()
              ?? responseData['applicationId']?.toString()
              ?? value['application_id']?.toString()
              ?? value['id']?.toString()
              ?? (widget.capturedApplicationId != null && widget.capturedApplicationId.toString() != '0' ? widget.capturedApplicationId.toString() : null);
          print('DEBUG newAppId: $newAppId');
          widget.CheckPaymentDialogCallback!(
            trackingId: value['tracking_id'].toString(),
            applicationId: newAppId,
            clientPhone: widget.clientPhone,
            plateNumber: widget.plateNumber,
            resubmitCallback: (String newPhone) {
              if (mounted) {
                setState(() {
                  widget.clientPhone = newPhone;
                });
                _submitForm();
              }
            },
          );
        }else{
          _showRetrySubmitPhoneDialog(value['message'].toString().replaceAll("[", "").replaceAll("]", ""));
        }
      }).catchError((onError) {
        setState(() {
          isLoading = false;
        });
        debugPrint('Error: ${onError.toString()}');
        _showRetrySubmitPhoneDialog(onError.toString().replaceAll("[", "").replaceAll("]", ""));
      });
    }
  }

  Future<void> _showRetrySubmitPhoneDialog(String errorMessage) async {
    bool _isValidNumber = true; // assume true initially or let user correct it
    String _fullPhoneNumber = widget.clientPhone ?? '';

    bool? confirmPrompt = await showDialog<bool>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        TextEditingController phoneNumberController = TextEditingController(text: widget.clientPhone);
        PhoneNumber _initialPhoneNumber = PhoneNumber(phoneNumber: widget.clientPhone, isoCode: 'KE');
        double fontSize = MediaQuery.of(context).size.width / 28.0;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(child: Text("Payment Initialization Failed", style: GoogleFonts.manrope(fontSize: fontSize * 1.1, fontWeight: FontWeight.bold, color: Colors.red))),
                  SizedBox(height: 8),
                  Center(child: Text(errorMessage, style: GoogleFonts.manrope(fontSize: fontSize * 0.9, color: Colors.black87), textAlign: TextAlign.center)),
                  SizedBox(height: 15),
                  Center(child: Text("Please confirm or edit the client's phone number to retry:", style: GoogleFonts.manrope(fontSize: fontSize * 1))),
                  SizedBox(height: 15),
                  InternationalPhoneNumberInput(
                    countries: ["KE"],
                    onInputChanged: (PhoneNumber number) {
                      _fullPhoneNumber = number.phoneNumber ?? '';
                    },
                    onInputValidated: (isValid) {
                      setStateDialog(() {
                        _isValidNumber = isValid;
                      });
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
                    ignoreBlank: true,
                    autoValidateMode: AutovalidateMode.onUserInteraction,
                    spaceBetweenSelectorAndTextField: 25,
                    selectorTextStyle: GoogleFonts.manrope(),
                    initialValue: _initialPhoneNumber,
                    textFieldController: phoneNumberController,
                    formatInput: true,
                    errorMessage: 'Please enter a valid phone number',
                    inputDecoration: InputDecoration(
                      prefixIconColor: Colors.black38,
                      hintStyle: GoogleFonts.manrope(fontSize: fontSize),
                      hintText: '712-256-408',
                      alignLabelWithHint: false,
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Color(0xFF46B1FD))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Color(0xFF46B1FD))),
                    ),
                    keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
                    inputBorder: OutlineInputBorder(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: TextButton.styleFrom(backgroundColor: Colors.red, padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0)),
                  child: Text("Cancel", style: GoogleFonts.montserrat(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w400)),
                ),
                TextButton(
                  onPressed: () {
                    if (_isValidNumber) {
                      Navigator.of(context).pop(true);
                    } else {
                       Get.snackbar('Oops', 'Invalid Phone Number', backgroundColor: Colors.redAccent.withOpacity(0.7), colorText: Colors.white, snackPosition: SnackPosition.TOP, duration: Duration(seconds: 2), margin: EdgeInsets.only(left: 16.0, right: 16), borderRadius: 10.0);
                    }
                  },
                  style: TextButton.styleFrom(backgroundColor: Colors.green, padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0)),
                  child: Text("Retry Request", style: GoogleFonts.montserrat(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w400)),
                ),
              ],
            );
          }
        );
      }
    );

    if (confirmPrompt == true) {
      if (mounted) {
        setState(() {
          widget.clientPhone = _fullPhoneNumber;
        });
        _submitForm();
      }
    }
  }
}


class selectedProduct {

  String quantity;
  String Amount;
  OffLoadingItemsDatum? itemChosen;

  selectedProduct({
    required this.quantity,
    required this.Amount,
    required this.itemChosen
  });
}








class PaidGoodsItem extends StatefulWidget {
  PaidGoodsItem({
    super.key,
    required this.itemName,
    required this.UOM,
    required this.totalAmount,
    required this.quantity,
    required this.rate,
    required this.RemoveItemFromList
  });

  String? itemName;
  String? UOM;
  String? quantity;
  String? totalAmount;
  String? rate;
  final Function? RemoveItemFromList;

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
        SizedBox(height: 10,),
        Row(
          children: [
            SizedBox(
              width:screenWidth*0.55,
              child: Row(
                children: [
                  Text('Item :',  style: GoogleFonts.manrope(
                    fontSize: fontSize * 1,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),),
                  SizedBox(
                    width: size.width * 0.01,
                  ),
                  Flexible(
                    child: Text(
                         widget.itemName.toString(),
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
              child:  Row(
                children: [
                  Text('Quantity:',  style: GoogleFonts.manrope(
                    fontSize: fontSize * 1,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),),
                  SizedBox(
                    width: size.width * 0.01,
                  ),
                  Text('${widget.quantity}',
                    style: GoogleFonts.manrope(
                      fontSize: fontSize * 1,
                      // fontWeight: FontWeight.w500,
                      color: Colors.black.withOpacity(0.7),
                    ),)
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
            SizedBox(
              width:screenWidth*0.55,
              child: Row(
                children: [
                  Text('U.O.M:',  style: GoogleFonts.manrope(
                    fontSize: fontSize * 1,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),),
                  SizedBox(
                    width: size.width * 0.01,
                  ),
                  Expanded(
                    child: Text(
                        '${widget.UOM}',
                        style: GoogleFonts.manrope(
                          fontSize: fontSize * 1,
                          // fontWeight: FontWeight.w500,
                          color: Colors.black.withOpacity(0.7),
                        )),
                  )
                ],
              ),
            ),
            SizedBox(width: screenWidth* 0.01,),
            Flexible(
              child:  Row(
                children: [
                  Text('Rate:',  style: GoogleFonts.manrope(
                    fontSize: fontSize * 1,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),),
                  SizedBox(
                    width: size.width * 0.01,
                  ),
                  Text(("${formatNumb(widget.rate.toString())}"),
                    style: GoogleFonts.manrope(
                      fontSize: fontSize * 1,
                      // fontWeight: FontWeight.w500,
                      color: Colors.black.withOpacity(0.7),
                    ),)
                ],
              ),
            ),
          ],
        ),

        SizedBox(
          height: size.height * 0.009,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: screenWidth * 0.7,
              child: Row(
                children: [
                  Text('Total:',  style: GoogleFonts.manrope(
                    fontSize: fontSize * 1,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),),
                  SizedBox(
                    width: size.width * 0.01,
                  ),
                  Flexible(
                    child: Text(("Ksh ${formatNumb(widget.totalAmount.toString())}"),
                        style: GoogleFonts.manrope(
                          fontSize: fontSize * 1,
                          // fontWeight: FontWeight.w500,
                          color: Colors.black.withOpacity(0.7),
                        )),
                  )
                ],
              ),
            ),
            SizedBox(width: 5,),
            IconButton(
              onPressed: (){
                widget.RemoveItemFromList?.call();
              },
              icon: Icon(Icons.delete),)
          ],
        ),
        const Divider(),
      ],
    );
  }
}


