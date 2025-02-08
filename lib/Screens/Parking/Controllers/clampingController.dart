

import 'package:dio/dio.dart';
import 'package:enforcer/Data/userData.dart';
import 'package:enforcer/Screens/Parking/Controllers/parkingController.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Api/api_provider.dart';
import '../../../Api/endpoints.dart';
import '../../../widgets/failed_dialog.dart';
import '../../../widgets/sucess-dialog.dart';
import '../Models/vehicleCategoriesModel.dart';
import '../Models/zonesModel.dart';

class clampingController extends ChangeNotifier{

  final formKey = GlobalKey<FormState>();
  TextEditingController plateController = TextEditingController();

  /// Fetching Zones and Locations
  Future<Map<String, GetMyZones>>? zonesFuture;
  Map<String, GetMyZones>? myZones;
  List<Location>? locations;

  GetMyZones? selectedZone;
  Location? selectedLocation;

  Future fetchZones() async{
    try{
      zonesFuture = ApiProvider().getParkingZones();
      notifyListeners();
    }catch (e){
      notifyListeners();
    }finally{
      notifyListeners();
    }
  }

  void toggleZones(GetMyZones zoneName){
    selectedZone = zoneName;
    locations = zoneName!.locations;
    selectedLocation = null;
    notifyListeners();
  }

  /// Fetching Vehicle Categories
  Future<List<GetVehicleCategoriesModel>>? vehicleCategoriesFuture;
  List<GetVehicleCategoriesModel>? vehicleCategories;

  GetVehicleCategoriesModel? selectedCategory;

  Future fetchVehicleCategories() async{
    try{
      vehicleCategoriesFuture = ApiProvider().getVehicleCategories();
      notifyListeners();
    }catch (e){
      notifyListeners();
    }finally{
      notifyListeners();
    }
  }



  bool isClamping = false;

  Future<void> clampVehicle({
    required BuildContext context
}) async{
    try{
      isClamping = true;
      notifyListeners();
      Map<String, dynamic> response;

      FormData formData = FormData.fromMap({
        "plateNum" : plateController.text,
        "staffId" : userData.userId,
        "categoryId" : selectedCategory!.id,
        "zoneId" : selectedZone!.zoneId,
        "locationId" : selectedLocation!.locationId,
        "fetchKey" : Endpoints.SEC_KEY
      });

      formData.fields.forEach((element) {
        print("Key is ${element.key} Value is ${element.value}");
      });

      response = await ApiProvider().clampVehicle(formData: formData);

      if(response["status"] == "Success"){
        isClamping = false;
        notifyListeners();
        var provider = Provider.of<parkingController>(context,listen: false);
        await provider.clearPlateData();
        clearClampData();
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (ctx) {
            return SucessDialog(
              message: "Successfully Clamped Vehicle ${response['plateNumber']}",

            );
          },
        );


      }else{
        showDialog(
            context: context,
            builder: (ctx) {
              return FailedDialog(
                  message: "Failed to Clamp. Something went Wrong");
            });
      }
    }catch (e){
      isClamping = false;
      showDialog(
          context: context,
          builder: (ctx) {
            return FailedDialog(
                message: "Failed to Clamp. Something went Wrong");
          });
      notifyListeners();

    }finally{
      isClamping = false;
      notifyListeners();

    }
  }


  clearClampData(){
    selectedCategory = null;
    selectedZone = null;
    selectedLocation = null;
    plateController.clear();
  }

}