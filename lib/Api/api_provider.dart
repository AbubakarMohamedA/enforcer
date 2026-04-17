import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:enforcer/Screens/Parking/clampVehicle.dart';
import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';

import '../Models/HawkersModel/checkHawkerStatus.dart';
import '../Models/HawkersModel/getCategoriesModel.dart';
import '../Models/HawkersModel/getHawkerStats.dart';
import '../Models/HawkersModel/getLocations.dart';
import '../Models/HawkersModel/getZones.dart';
import '../Models/HawkersModel/paidHawkers.dart';
import '../Models/Offloading/getDailyOffloadingApplications.dart';
import '../Models/Offloading/getLastCessMadeApplication.dart';
import '../Models/Offloading/getOffLoadingVehicleType.dart';
import '../Models/Offloading/getOffLoadingZones.dart';
import '../Models/Offloading/getOffloadingItems.dart';
import '../Models/Offloading/getOffloadingStatsModel.dart';
import '../Models/Offloading/getPenaltyRates.dart';
import '../Models/userModel.dart';
import '../Screens/Parking/Models/vehicleCategoriesModel.dart';
import '../Screens/Parking/Models/zonesModel.dart';
import '../Models/MarketEntryModel/getMarketTollTypes.dart';
import '../Models/MarketEntryModel/getMarketTollCategories.dart';
import '../Models/MarketEntryModel/getMarketStats.dart';
import '../Models/MarketEntryModel/paidMarket.dart';
import 'endpoints.dart';

class ApiProvider {
  final Dio dio = Dio();
  
  // Cache for Market categories to facilitate UI mapping and lookup of isIdNumber
  static List<MarketTollCategoryDatum>? _marketCategoriesCache;

  Future<Map<String, dynamic>> staffLogin({
    required String email,
    required String password,
  }) async {
    Response? result;

    print("The email is $email");
    print("The pass is $password");

    try {
      final payload = {
        'appType': 'login',
        'email': email,
        'password': password,
      };

      print("The Login Payload is: $payload");

      result = await Dio().post(
        Endpoints.MARKET_URL,
        options: Options(
          preserveHeaderCase: true,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'ngrok-skip-browser-warning': 'true', // Bypass ngrok warning page
          },
        ),
        data: payload,
      );

      print("The RESULT IS: ${result.data}");

      if (kDebugMode) {
        print('The Login result is $result');
        print('The result status is ${result.statusCode}');
      }

      if (result.statusCode != 200) {
        throw Exception('Server returned ${result.statusCode}');
      }

      // Dio automatically decodes JSON if the response header is application/json
      if (result.data is Map<String, dynamic>) {
        return result.data;
      } else if (result.data is String) {
        return jsonDecode(result.data);
      } else {
        throw Exception('Unexpected response format');
      }
    } on SocketException {
      throw const SocketException('Bad Internet Connection');
    } on FormatException catch (e) {
      throw FormatException('Invalid Server Response: $e');
    } on DioException catch (e) {
      if (e.error is SocketException) {
        throw Exception('Connection error. Please check your internet.');
      } else if (e.response != null) {
        final data = e.response!.data;
        final message = (data is Map) ? data['message'] : 'Server error: ${e.response!.statusCode}';
        throw Exception(message);
      } else {
        throw Exception('Connection failed: ${e.message}');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // CHANGE PASSWORD
  Future<Map<String, dynamic>> changePassword({
    required String userId,
    required String email,
    required String newPass,
  }) async {
    Response? result;
    try {
      print("User Id ${userId}");
      print("Email Id ${email}");
      print("Password Is ${newPass}");

      FormData formData = FormData.fromMap({
        "userEmail": email,
        "userId" : userId,
        "password": newPass,
      });

      print("The form data is ${formData.fields}");
      print(Endpoints.PRNEWPASS_URL);

      result = await dio.post(
        Endpoints.PRNEWPASS_URL,
        // Replace with your actual officer login endpoint
        // options: Options(
        //   headers: {
        //     'Content-Type': 'application/json', // Set content type to JSON
        //   },
        // ),
        data: formData,
      );
      print("The RESULT IS: ${result}");
      // if (result.data is String) {
      //   try {
      //     // Attempt to parse the string as JSON
      //     result.data = jsonDecode(result.data);
      //   } catch (e) {
      //     // If parsing fails, throw a FormatException
      //     throw FormatException("Response is not in JSON format");
      //   }
      // }

      if (kDebugMode && result != null) {
        print('The  result is $result');
        print('The result is ${result.statusCode}');
      }

      if (result?.statusCode == 200) {
        if (result!.data is Map<String, dynamic>) {
          return result.data as Map<String, dynamic>;
        } else if (result.data is String) {
          return jsonDecode(result.data);
        } else {
          return {"status": "success"};
        }
      } else {
        throw Exception('Server error: ${result?.statusCode}');
      }
    } on SocketException {
      throw const SocketException('Bad Internet');
    } on FormatException catch (e) {
      throw FormatException(e.toString());
    } on DioException catch (e) {
      if (e.error is SocketException) {
        // Handle SocketException separately
        print('SocketException: ${e.error}');
        throw Exception('Connection error');
      } else {
        // Handle other DioError cases
        print('DioError: $e');
        if (e.response != null) {
          print(
              'DioError Response: ${e.response!.statusCode}, ${e.response!.data}');
        }
        throw Exception(e.response!.data['message']);
      }
    }

  }

  // Future<Map<String, dynamic>> changePassword({
  //   required String userId,
  //   required String email,
  //   required String newPass,
  // }) async {
  //   Response? result;
  //   try {
  //     print("User Id ${userId}");
  //     print("Email Id ${email}");
  //     print("Password Is ${newPass}");
  //
  //     // Prepare the data as a Map (which will be converted to JSON)
  //     Map<String, dynamic> data = {
  //       "userEmail": email,
  //       "userId": userId,
  //       "password": newPass,
  //     };
  //
  //     // Print the data
  //     print("The form data is ${data}");
  //
  //     // Send the request with the JSON data and appropriate headers
  //     result = await Dio().post(
  //       Endpoints.PRNEWPASS_URL, // Replace with your actual endpoint
  //       data: jsonEncode(data), // Convert the map to JSON string
  //       options: Options(
  //         headers: {
  //           'Content-Type': 'application/json', // Set content type to JSON
  //         },
  //       ),
  //     );
  //
  //     print("The RESULT IS: ${result}");
  //
  //     if (kDebugMode) {
  //       print('The result is $result');
  //       print('The result is ${result.statusCode}');
  //     }
  //
  //     if (result.statusCode != 200) throw Exception();
  //
  //     return result.data;
  //   } on SocketException {
  //     throw const SocketException('Bad Internet');
  //   } on FormatException catch (e) {
  //     throw FormatException(e.toString());
  //   } on DioError catch (e) {
  //     if (e.error is SocketException) {
  //       print('SocketException: ${e.error}');
  //       throw Exception('Connection error');
  //     } else {
  //       print('DioError: $e');
  //       if (e.response != null) {
  //         print(
  //             'DioError Response: ${e.response!.statusCode}, ${e.response!.data}');
  //       }
  //       throw Exception(e.response!.data['message']);
  //     }
  //   }
  // }


  // FORGOT PASSWORD
  Future<Map<String, dynamic>> forgotPassword({
    required String emailAddress,
  }) async {

    print(Endpoints.PRESET_URL);

    Response? result;
    try {
      FormData formData = FormData.fromMap({
        "email": emailAddress,

      });
      result = await dio.post(
          Endpoints.PRESET_URL, // Replace with your actual officer login endpoint
        data: formData
      );

      print("The RESULT IS: ${result}");

      if (kDebugMode && result != null) {
        print('The Login result is $result');
        print('The result is ${result.statusCode}');
      }

      if (result?.statusCode != 200) throw Exception();

    } on SocketException {
      throw const SocketException('Bad Internet');
    } on FormatException catch (e) {
      throw FormatException(e.toString());
    } on DioException catch (e) {
      if (e.error is SocketException) {
        // Handle SocketException separately
        print('SocketException: ${e.error}');
        throw Exception('Connection error');
      } else if(e.response!.statusCode == 422){
        throw Exception(e.response!.data['email']);
      } else{
        // Handle other DioError cases
        print('DioError: $e');
        if (e.response != null) {
          print(
              'DioError Response: ${e.response!.statusCode}, ${e.response!.data}');
        }
        throw Exception(e.response!.data['message']);
      }
    }

    if (result == null) throw Exception("Failed to get response from server");
    return (result.data is String) ? jsonDecode(result.data) : result.data;
  }

  //CHECK HAWKER STATISTICS - I.E Daily paid , Monthly Paid et.c
  Future<GetHawkerStats> getHawkerStats({
    required String? token,
    // required String? agentId,
  }) async  {
    try {

      final response = await Dio().get(
        Endpoints.HAWKER_URL, // Replace with your actual endpoint
        queryParameters: {
          'appType' : 'getStats',
          // 'converted_to_order' : "True"
        },
        options: Options(
          preserveHeaderCase: true,
          contentType: Headers.jsonContentType,
          headers: {
            'Authorization': 'Bearer ${token}',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },

        ),
      );

      if (response.statusCode == 200) {
        print('Hawker Stats Data: ${response.data}');
        final jsonData = response.data;
        final hawkerStats = GetHawkerStats.fromJson(jsonData);
        return hawkerStats;
      } else {
        throw Exception();
      }
    } on SocketException {
      throw const SocketException('Bad Internet');
    } on FormatException catch (e) {
      throw FormatException(e.toString());
    } on DioException catch (e) {
      if (e.error is SocketException) {
        // Handle SocketException separately
        print('SocketException: ${e.error}');
        throw Exception('Connection error');
      } else {
        // Handle other DioError cases
        print('DioError: $e');
        if (e.response != null) {
          print(
              'DioError Response: ${e.response!.statusCode}, ${e.response!.data}');
        }
        throw Exception(e.response?.data['message'] ?? 'Please check your Connection');
      }
    }
  }

  //CHECK HAWKER STATUS IF PAID OR NOT
  Future<Map<String, dynamic>> checkHawkerStatus({
    required String? token,
    required String? hawkerId,
    // required String? agentId,
  }) async  {
    try {
      final response = await Dio().get(
        Endpoints.HAWKER_URL, // Replace with your actual endpoint
        queryParameters: {
          'appType' : 'checkHawkerStatus',
          'hawkerId' : hawkerId
          // 'converted_to_order' : "True"
        },
        options: Options(
          preserveHeaderCase: true,
          contentType: Headers.jsonContentType,
          headers: {
            'Authorization': 'Bearer ${token}',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        print('Hawker Status Data: ${response.data}');


        // final jsonData = response.data;
        // final hawkerStatus = CheckHawkerStatus.fromJson(jsonData);
        return response.data;
      } else {
        throw Exception();
      }
    } on SocketException {
      throw const SocketException('Bad Internet');
    } on FormatException catch (e) {
      throw FormatException(e.toString());
    } on DioException catch (e) {
      if (e.error is SocketException) {
        // Handle SocketException separately
        print('SocketException: ${e.error}');
        throw Exception('Connection error');
      } else {
        // Handle other DioError cases
        print('DioError: $e');
        if (e.response != null) {
          print(
              'DioError Response: ${e.response!.statusCode}, ${e.response!.data}');
        }
        throw Exception(e.response?.data['message'] ?? 'Please check your Connection');
      }
    }
  }

  //Get Hawker Zones
  Future<GetZones> getZones({
    required String? token,
    // required String? agentId,
  }) async  {
    try {

      final response = await Dio().get(
        Endpoints.HAWKER_URL, // Replace with your actual endpoint
        queryParameters: {
          'appType' : 'getHawkingZones',
          // 'converted_to_order' : "True"
        },
        options: Options(
          preserveHeaderCase: true,
          contentType: Headers.jsonContentType,
          headers: {
            'Authorization': 'Bearer ${token}',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },

        ),
      );

      if (response.statusCode == 200) {
        print('Hawker Zones Data: ${response.data}');
        final jsonData = response.data;
        final zones = GetZones.fromJson(jsonData);
        return zones;
      } else {
        throw Exception();
      }
    } on SocketException {
      throw const SocketException('Bad Internet');
    } on FormatException catch (e) {
      throw FormatException(e.toString());
    } on DioException catch (e) {
      if (e.error is SocketException) {
        // Handle SocketException separately
        print('SocketException: ${e.error}');
        throw Exception('Connection error');
      } else {
        // Handle other DioError cases
        print('DioError: $e');
        if (e.response != null) {
          print(
              'DioError Response: ${e.response!.statusCode}, ${e.response!.data}');
        }
        throw Exception(e.response?.data['message'] ?? 'Please check your Connection');
      }
    }
  }

  // Future<List<LocationsDatum>> getLocations({
  //   required String? token,
  // }) async {
  //   try {
  //     final response = await Dio().get(
  //       Endpoints.MAIN_URL, // Replace with your actual endpoint
  //       queryParameters: {
  //         'appType': 'getLocations',
  //         // 'converted_to_order' : "True"
  //       },
  //       options: Options(
  //         contentType: Headers.jsonContentType,
  //         headers: {
  //           'Authorization': 'Bearer $token',
  //           'Content-Type': 'application/json',
  //           'Accept': 'application/json',
  //         },
  //       ),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       print('Hawker Locations Data: ${response.data}');
  //       final List<dynamic> data = response.data['data'];
  //
  //       List<LocationsDatum> locationsData = data
  //           .map((location) => LocationsDatum.fromJson(location as Map<String, dynamic>))
  //           .toList();
  //
  //       return locationsData;
  //     } else {
  //       throw Exception('Failed to load locations');
  //     }
  //   } on SocketException {
  //     throw const SocketException('No Internet connection');
  //   } on FormatException catch (e) {
  //     throw FormatException('Data format error: ${e.message}');
  //   } on DioError catch (e) {
  //     if (e.error is SocketException) {
  //       print('SocketException: ${e.error}');
  //       throw Exception('Connection error');
  //     } else {
  //       print('DioError: $e');
  //       if (e.response != null) {
  //         print(
  //             'DioError Response: ${e.response!.statusCode}, ${e.response!.data}');
  //       }
  //       throw Exception(e.response?.data['message'] ?? 'Please check your Connection');
  //     }
  //   }
  // }
  Future<GetLocations> getLocations({
    required String? token,
    required String? zoneId,
    // required String? agentId,
  }) async  {
    try {

      final response = await Dio().get(
        Endpoints.HAWKER_URL, // Replace with your actual endpoint
        queryParameters: {
          'appType' : 'getLocations',
          'zone_id' : zoneId,
          // 'converted_to_order' : "True"
        },
        options: Options(
          preserveHeaderCase: true,
          contentType: Headers.jsonContentType,
          headers: {
            'Authorization': 'Bearer ${token}',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },

        ),
      );

      if (response.statusCode == 200) {
        print('Hawker Locations Data: ${response.data}');
        final jsonData = response.data;
        final locations = GetLocations.fromJson(jsonData);
        return locations;
      } else {
        throw Exception();
      }
    } on SocketException {
      throw const SocketException('Bad Internet');
    } on FormatException catch (e) {
      throw FormatException(e.toString());
    } on DioException catch (e) {
      if (e.error is SocketException) {
        // Handle SocketException separately
        print('SocketException: ${e.error}');
        throw Exception('Connection error');
      } else {
        // Handle other DioError cases
        print('DioError: $e');
        if (e.response != null) {
          print(
              'DioError Response: ${e.response!.statusCode}, ${e.response!.data}');
        }
        throw Exception(e.response?.data['message'] ?? 'Please check your Connection');
      }
    }
  }

  Future<GetCategories> getCategories({
    required String? token,
    // required String? agentId,
  }) async  {
    try {

      print("The token is ${token}");
      final response = await Dio().get(
        Endpoints.HAWKER_URL, // Replace with your actual endpoint
        queryParameters: {
          'appType' : 'getCategory',
          // 'converted_to_order' : "True"
        },
        options: Options(
          preserveHeaderCase: true,
          contentType: Headers.jsonContentType,
          headers: {
            'Authorization': 'Bearer ${token}',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },

        ),
      );

      if (response.statusCode == 200) {
        print('Hawker Categories Data: ${response.data}');
        final jsonData = response.data;
        final categories = GetCategories.fromJson(jsonData);
        return categories;
      } else {
        throw Exception();
      }
    } on SocketException {
      throw const SocketException('Bad Internet');
    } on FormatException catch (e) {
      throw FormatException(e.toString());
    } on DioException catch (e) {
      if (e.error is SocketException) {
        // Handle SocketException separately
        print('SocketException: ${e.error}');
        throw Exception('Connection error');
      } else {
        // Handle other DioError cases
        print('DioError: $e');
        if (e.response != null) {
          print(
              'DioError Response: ${e.response!.statusCode}, ${e.response!.data}');
        }
        throw Exception(e.response?.data['message'] ?? 'Please check your Connection');
      }
    }
  }

  Future<Map<String, dynamic>> promptHawker({
    required String? token,
    required String? hawkerId,
    required String? hawkerName,
    required String? hawkerMobile,
    required String? hawkerZoneId,
    required String? hawkerLocationId,
    required String? hawkerCategoryId,
    // required String? agentId,
  }) async {
         print("'amount' : 1,");
    try {
      final response = await Dio().post(
        Endpoints.HAWKER_URL, // Replace with your actual endpoint
        data: {
          'appType' : 'promptHawker',
          'hawkerName' : hawkerName,
          'hawkerId' : hawkerId,
          'hawkerMobile' : hawkerMobile,
          'zoneId' : hawkerZoneId,
          'amount' : 50,
          'locationId' : hawkerLocationId,
          'categoryId' : hawkerCategoryId
          // 'converted_to_order' : "True"
        },
        options: Options(
          preserveHeaderCase: true,
          contentType: Headers.jsonContentType,
          headers: {
            'Authorization': 'Bearer ${token}',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        print('Hawker Status Data: ${response.data}');
        // final jsonData = response.data;
        // final hawkerStatus = CheckHawkerStatus.fromJson(jsonData);
        return response.data;
      } else {
        throw Exception();
      }
    } on SocketException {
      throw const SocketException('Bad Internet');
    } on FormatException catch (e) {
      throw FormatException(e.toString());
    } on DioException catch (e) {
      if (e.error is SocketException) {
        // Handle SocketException separately
        print('SocketException: ${e.error}');
        throw Exception('Connection error');
      } else {
        // Handle other DioError cases
        print('DioError: $e');
        if (e.response != null) {
          print(
              'DioError Response: ${e.response!.statusCode}, ${e.response!.data}');
        }
        throw Exception(e.response?.data['message'] ?? 'Please check your Connection');
      }
    }
  }

  Future<PaidHawkers> getPaidHawkers({
    required String? token,
  }) async {
    try {

      print("The token is ${token}");
      final response = await Dio().get(
        Endpoints.HAWKER_URL, // Replace with your actual endpoint
        queryParameters: {
          'appType' : 'getPaidHawkers',
          // 'converted_to_order' : "True"
        },
        options: Options(
          preserveHeaderCase: true,
          contentType: Headers.jsonContentType,
          headers: {
            'Authorization': 'Bearer ${token}',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },

        ),
      );

      if (response.statusCode == 200) {
        print('Paid Hawkers List Data: ${response.data}');
        final jsonData = response.data;
        final paidHawkers = PaidHawkers.fromJson(jsonData);
        return paidHawkers;
      } else {
        throw Exception();
      }
    } on SocketException {
      throw const SocketException('Bad Internet');
    } on FormatException catch (e) {
      throw FormatException(e.toString());
    } on DioException catch (e) {
      if (e.error is SocketException) {
        // Handle SocketException separately
        print('SocketException: ${e.error}');
        throw Exception('Connection error');
      } else {
        // Handle other DioError cases
        print('DioError: $e');
        if (e.response != null) {
          print(
              'DioError Response: ${e.response!.statusCode}, ${e.response!.data}');
        }
        throw Exception(e.response?.data['message'] ?? 'Please check your Connection');
      }
    }
  }

/********************************* OFFLOADING FUNCTIONS ************************************************/

    Future<GetVehicleLastPaymentCess> getLastpaymentCess({
      required String token,
      required String? plateNumber,
    })async{
       try{
         print("The token is ${Endpoints.OFFLOADING_URL}");
         final response = await Dio().get(
           Endpoints.OFFLOADING_URL,
           queryParameters: {
             "appType" : "checkStatus",
             "plateNumber" : plateNumber
           },
           options: Options(
             preserveHeaderCase: true,
             contentType: Headers.jsonContentType,
             headers: {
               'Authorization': 'Bearer ${token}',
               'Content-Type': 'application/json',
               'Accept': 'application/json',
             }
           ),
         );

       //  Get the data and check the response
         if(response.statusCode == 200){
           print('getLastpaymentCess Data: ${response.data}');
           final jsonData = response.data;
           final LastCessPayment = GetVehicleLastPaymentCess.fromJson(jsonData);
           return LastCessPayment;
         }else{
           throw Exception();
         }
       }on SocketException {
         throw const SocketException('Bad Internet');
       } on FormatException catch (e) {
         throw FormatException(e.toString());
       }on DioError catch (e) {
         if (e.error is SocketException) {
           // Handle SocketException separately
           print('SocketException: ${e.error}');
           throw Exception('Connection error');
         } else {
           // Handle other DioError cases
           print('DioError: $e');
           if (e.response != null) {
             print('DioError Response: ${e.response!.statusCode}, ${e.response!.data}');
           }
           // throw Exception(e.response?.data['message'] ?? 'Please check your Connection');
           throw Exception();
         }
       }
     }


    Future<GetDailyOffloadingApplications> getDailyOffloadingApplications({
      required String token,
    }) async{
        try{
          print("The token is ${token}");
          final response = await Dio().get(
            Endpoints.OFFLOADING_URL,
            queryParameters: {
              "appType" : "getTasks"
            },
            options: Options(
              preserveHeaderCase: true,
              contentType: Headers.jsonContentType,
              headers: {
                'Authorization': 'Bearer ${token}',
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              }
            )
          );

          if(response.statusCode == 200){
            print("The Daily Offloading ");
            final jsonData = response.data;
            final getOffloadingApplication = GetDailyOffloadingApplications.fromJson(jsonData);
            return getOffloadingApplication;
          }else{
            throw Exception();
          }
        }on SocketException {
          throw const SocketException('Bad Internet');
        } on FormatException catch (e) {
          throw FormatException(e.toString());
        }on DioError catch (e) {
          if (e.error is SocketException) {
            print('SocketException: ${e.error}');
            throw Exception('Bad Internet connection');
          } else {
            print('DioError: $e');
            // Checking if the response data is a Map
            if (e.response?.data is Map<String, dynamic>) {
              final responseData = e.response?.data;
              if (responseData.containsKey('message')) {
                throw Exception(responseData['message']);
              } else {
                throw Exception('Unknown error: $responseData');
              }
            } else if (e.response?.data is String) {
              // If response data is a String, throw it as an error
              throw Exception(e.response?.data);
            } else {
              throw Exception('Unknown error occurred.');
            }
          }
        }
     }


  Future<GetOffLoadingStats> getOffLoadingStats({
    required String? token,
    // required String? agentId,
  }) async  {
    try {

      final response = await Dio().get(
        Endpoints.OFFLOADING_URL, // Replace with your actual endpoint
        queryParameters: {
          'appType' : 'getStats',
          // 'converted_to_order' : "True"
        },
        options: Options(
          preserveHeaderCase: true,
          contentType: Headers.jsonContentType,
          headers: {
            'Authorization': 'Bearer ${token}',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },

        ),
      );

      if (response.statusCode == 200) {
        print('Offloading Stats Data: ${response.data}');
        final jsonData = response.data;
        final offloadingStats = GetOffLoadingStats.fromJson(jsonData);
        return offloadingStats;
      } else {
        throw Exception();
      }
    } on SocketException {
      throw const SocketException('Bad Internet');
    } on FormatException catch (e) {
      throw FormatException(e.toString());
    } on DioException catch (e) {
      if (e.error is SocketException) {
        // Handle SocketException separately
        print('SocketException: ${e.error}');
        throw Exception('Connection error');
      } else {
        // Handle other DioError cases
        print('DioError: $e');
        if (e.response != null) {
          print(
              'DioError Response: ${e.response!.statusCode}, ${e.response!.data}');
        }
        throw Exception(e.response?.data['message'] ?? 'Please check your Connection');
      }
    }
  }


//  CHECK PERMISSIONS
//   Future<Map<String, dynamic>> checkPermission({
//     required String permissionType,
//     required String token,
//
//   }) async {
//     Response? result;
//     try {
//       result = await Dio().post(
//         Endpoints.PERMISSION_URL, // Replace with your actual endpoint
//         options: Options(
//           headers: {
//             'Authorization': 'Bearer ${token}',
//             'Content-Type': 'application/json', // Set content type to JSON
//           },
//
//         ),
//         data: {
//           'permission' : permissionType
//         },
//       );
//
//       if (kDebugMode) {
//         print('The Permission result is $result');
//         print('The Permission is ${result.statusCode}');
//       }
//       if (result.statusCode != 200) throw Exception();
//       return result.data;
//     } on SocketException {
//       throw const SocketException('Bad Internet');
//     } on FormatException catch (e) {
//       throw FormatException(e.toString());
//     } on DioException catch (e) {
//       if (e.error is SocketException) {
//         print('SocketException: ${e.error}');
//         throw Exception('Connection error');
//       } else {
//         print('DioError: $e');
//         if (e.response != null) {
//           throw Exception(e.response?.data['message']);
//         } else {
//           throw Exception('Unknown error');
//         }
//       }
//     }
//   }



  Future<Map<String, dynamic>> checkPermission({
    required String permissionType,
    required String token,
     String? url
  }) async {
    Response? result;
    try {
      result = await Dio().post(
        // url == null ?
        // Endpoints.PERMISSION_URL : "https://eportal.mombasa.go.ke/mobile/android/staff/checkAppPermission.php", // Replace with your actual endpoint
        "https://eportal.mombasa.go.ke/mobile/android/staff/checkAppPermission.php",
        options: Options(
          preserveHeaderCase: true,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json', // Set content type to JSON
          },
        ),
        data: {
          'permission': permissionType,
        },
      );

      if (kDebugMode) {
        print('The Permission result is $result');
        print('The Permission status code is ${result.statusCode}');
      }

      if (result.statusCode == 200) {
        return result.data;
      } else {
        throw Exception('Error: ${result.data}');
      }
    } on SocketException {
      throw const SocketException('Bad Internet connection');
    } on FormatException catch (e) {
      throw FormatException('Bad response format: ${e.message}');
    } on DioException catch (e) {
      if (e.error is SocketException) {
        print('SocketException: ${e.error}');
        throw Exception('Bad Internet connection');
      } else {
        print('DioError: $e');
        // Checking if the response data is a Map
        if (e.response?.data is Map<String, dynamic>) {
          final responseData = e.response?.data;
          if (responseData.containsKey('message')) {
            throw Exception(responseData['message']);
          } else {
            throw Exception('Unknown error: $responseData');
          }
        } else if (e.response?.data is String) {
          // If response data is a String, throw it as an error
          throw Exception(e.response?.data);
        } else {
          throw Exception('Unknown error occurred.');
        }
      }
    }
  }


  Future<GetOffloadingZones> getOffLoadingZones({
    required String token,
  }) async {
    Response? result;
    try {
      result = await Dio().get(
        Endpoints.OFFLOADING_URL, // Replace with your actual endpoint
        queryParameters: {
          'appType' : 'getZones'
        },
        options: Options(
          preserveHeaderCase: true,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json', // Set content type to JSON
          },
        ),


      );

      if (kDebugMode) {
        print('The Get Zones result is $result');
        print('The Get Zones status code is ${result.statusCode}');
      }

      if (result.statusCode == 200) {
        final jsonData = result.data;
        final getOffLoadingZones = GetOffloadingZones.fromJson(jsonData);
        return getOffLoadingZones;
      } else {
        throw Exception('Error: ${result.data}');
      }
    } on SocketException {
      throw const SocketException('Bad Internet connection');
    } on FormatException catch (e) {
      throw FormatException('Bad response format: ${e.message}');
    } on DioException catch (e) {
      if (e.error is SocketException) {
        print('SocketException: ${e.error}');
        throw Exception('Bad Internet connection');
      } else {
        print('DioError: $e');
        // Checking if the response data is a Map
        if (e.response?.data is Map<String, dynamic>) {
          final responseData = e.response?.data;
          if (responseData.containsKey('message')) {
            throw Exception(responseData['message']);
          } else {
            throw Exception('Unknown error: $responseData');
          }
        } else if (e.response?.data is String) {
          // If response data is a String, throw it as an error
          throw Exception(e.response?.data);
        } else {
          throw Exception('Unknown error occurred.');
        }
      }
    }
  }

  Future<GetOffloadingVehicleType> getOffLoadingVehicleTypes({
    required String token,
  }) async {
    Response? result;
    try {
      result = await Dio().get(
        Endpoints.OFFLOADING_URL, // Replace with your actual endpoint
        queryParameters: {
          'appType' : 'getVehicleTypes'
        },
        options: Options(
          preserveHeaderCase: true,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json', // Set content type to JSON
          },
        ),


      );

      if (kDebugMode) {
        print('The Get Vehicle result is $result');
        print('The Get Vehicl status code is ${result.statusCode}');
      }

      if (result.statusCode == 200) {
        final jsonData = result.data;
        final getOffLoadingVehicleTypes = GetOffloadingVehicleType.fromJson(jsonData);
        return getOffLoadingVehicleTypes;
      } else {
        throw Exception('Error: ${result.data}');
      }
    } on SocketException {
      throw const SocketException('Bad Internet connection');
    } on FormatException catch (e) {
      throw FormatException('Bad response format: ${e.message}');
    } on DioException catch (e) {
      if (e.error is SocketException) {
        print('SocketException: ${e.error}');
        throw Exception('Bad Internet connection');
      } else {
        print('DioError: $e');
        // Checking if the response data is a Map
        if (e.response?.data is Map<String, dynamic>) {
          final responseData = e.response?.data;
          if (responseData.containsKey('message')) {
            throw Exception(responseData['message']);
          } else {
            throw Exception('Unknown error: $responseData');
          }
        } else if (e.response?.data is String) {
          // If response data is a String, throw it as an error
          throw Exception(e.response?.data);
        } else {
          throw Exception('Unknown error occurred.');
        }
      }
    }
  }

  Future<GetOffloadingItems> getOffLoadingItems({
    required String token,
  }) async {
    Response? result;
    try {
      result = await Dio().get(
        Endpoints.OFFLOADING_URL, // Replace with your actual endpoint
        queryParameters: {
          'appType' : 'getItems'
        },
        options: Options(
          preserveHeaderCase: true,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json', // Set content type to JSON
          },
        ),


      );

      if (kDebugMode) {
        print('The Get Items result is $result');
        print('The Get Items status code is ${result.statusCode}');
      }

      if (result.statusCode == 200) {
        final jsonData = result.data;
        GetOffloadingItems getOffLoadingItems = GetOffloadingItems.fromJson(jsonData);
        return getOffLoadingItems;
      } else {
        throw Exception('Error: ${result.data}');
      }
    } on SocketException {
      throw const SocketException('Bad Internet connection');
    } on FormatException catch (e) {
      throw FormatException('Bad response format: ${e.message}');
    } on DioException catch (e) {
      if (e.error is SocketException) {
        print('SocketException: ${e.error}');
        throw Exception('Bad Internet connection');
      } else {
        print('DioError: $e');
        // Checking if the response data is a Map
        if (e.response?.data is Map<String, dynamic>) {
          final responseData = e.response?.data;
          if (responseData.containsKey('message')) {
            throw Exception(responseData['message']);
          } else {
            throw Exception('Unknown error: $responseData');
          }
        } else if (e.response?.data is String) {
          // If response data is a String, throw it as an error
          throw Exception(e.response?.data);
        } else {
          throw Exception('Unknown error occurred.');
        }
      }
    }
  }

  Future<Map<String, dynamic>> postOffloadingItems({
    required String token,
    required String vehicleType,
    required String plateNumber,
    required String clientName,
    required String clientPhone,
    required String zone,
    required List<Map<String, dynamic>> items,
    required int penalty,
  }) async {
    Response? result;
    try {
      print("The client phone is ${clientPhone}");
      result = await Dio().post(
        Endpoints.OFFLOADING_URL, // Replace with your actual endpoint
        data: {
          "appType": "createApplication",
          "origin": "Mombasa",
          "destination": "Mombasa",
          "vehicleType": vehicleType,
          "plateNumber": plateNumber,
          "clientName": clientName,
          "clientPhoneNumber": clientPhone,
          "zone": zone,
          "items" : items,
          "penalty" : penalty
        },
        options: Options(
          preserveHeaderCase: true,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json', // Set content type to JSON
          },
        ),
      );

      if (kDebugMode) {
        print('The Upload Offloading result is $result');
        print('The Upload Offloading status code is ${result.statusCode}');
      }
      if (result.statusCode != 200) throw Exception();
    } on SocketException {
      throw const SocketException('Bad Internet connection');
    } on FormatException catch (e) {
      throw FormatException('Bad response format: ${e.message}');
    } on DioException catch (e) {
      if (e.error is SocketException) {
        print('SocketException: ${e.error}');
        throw Exception('Bad Internet connection');
      } else {
        print('DioError: $e');
        // Checking if the response data is a Map
        if (e.response?.data is Map<String, dynamic>) {
          final responseData = e.response?.data;
          if (responseData.containsKey('message')) {
            throw Exception(responseData['message']);
          } else {
            throw Exception('Unknown error: $responseData');
          }
        } else if (e.response?.data is String) {
          // If response data is a String, throw it as an error
          throw Exception(e.response?.data);
        } else {
          throw Exception('Unknown error occurred.');
        }
      }
    }
    return result.data;
  }


  //PROMPT TO PAY AFTER APPLICATION IS ALREADY CAPTURED
  Future<Map<String, dynamic>> promptPaymentOfSavedApplications({
    required String token,
    required int applicationId,
    required String clientPhone,
  }) async {
    Response? result;
    print("The client Phone is ${clientPhone}");
    try {
      result = await Dio().post(
        Endpoints.OFFLOADING_URL, // Replace with your actual endpoint
        data: {
          "appType": "promptOffloadingApplicationPayment",
          "applicationId": applicationId,
          "clientPhoneNumber" : clientPhone,
        },
        options: Options(
          preserveHeaderCase: true,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json', // Set content type to JSON
          },
        ),
      );

      if (kDebugMode) {
        print('The prompt result is $result');
        print('The prompt Offloading status code is ${result.statusCode}');
      }
      if (result.statusCode != 200) throw Exception();
    } on SocketException {
      throw const SocketException('Bad Internet connection');
    } on FormatException catch (e) {
      throw FormatException('Bad response format: ${e.message}');
    } on DioException catch (e) {
      if (e.error is SocketException) {
        print('SocketException: ${e.error}');
        throw Exception('Bad Internet connection');
      } else {
        print('DioError: $e');
        // Checking if the response data is a Map
        if (e.response?.data is Map<String, dynamic>) {
          final responseData = e.response?.data;
          if (responseData.containsKey('message')) {
            throw Exception(responseData['message']);
          } else {
            throw Exception('Unknown error: $responseData');
          }
        } else if (e.response?.data is String) {
          // If response data is a String, throw it as an error
          throw Exception(e.response?.data);
        } else {
          throw Exception('Unknown error occurred.');
        }
      }
    }
    return result.data;
  }


  //CHECK HAWKER STATUS IF PAID OR NOT
  Future<Map<String, dynamic>> checkOffLoadingPaymentStatus({
    required String? token,
    required String? trackingId,
    // required String? agentId,
  }) async  {
    try {
      print("The tracking id passed is ${trackingId}");
      final response = await Dio().get(
        Endpoints.OFFLOADING_URL, // Replace with your actual endpoint
        queryParameters: {
          'appType' : 'checkPaymentStatus',
          'trackingId' : trackingId
          // 'converted_to_order' : "True"
        },
        options: Options(
          preserveHeaderCase: true,
          contentType: Headers.jsonContentType,
          headers: {
            'Authorization': 'Bearer ${token}',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        print('Offloading Payment Status Data: ${response.data}');

        // final jsonData = response.data;
        // final hawkerStatus = CheckHawkerStatus.fromJson(jsonData);
        return response.data;
      } else {
        throw Exception();
      }
    } on SocketException {
      throw const SocketException('Bad Internet');
    } on FormatException catch (e) {
      throw FormatException(e.toString());
    } on DioException catch (e) {
      if (e.error is SocketException) {
        // Handle SocketException separately
        print('SocketException: ${e.error}');
        throw Exception('Connection error');
      } else {
        // Handle other DioError cases
        print('DioError: $e');
        if (e.response != null) {
          print(
              'DioError Response: ${e.response!.statusCode}, ${e.response!.data}');
        }
        throw Exception(e.response?.data['message'] ?? 'Please check your Connection');
      }
    }
  }

//  GET PENALTY RATES
  Future<GetPenaltyRates> getOffLoadingPenatyRates({
    required String token,
    required String? vehicleType,
  }) async {
    Response? result;


    print("The vehicle type is ${vehicleType}");

    try {
      result = await Dio().get(
        Endpoints.OFFLOADING_URL, // Replace with your actual endpoint
        queryParameters: {
          'appType' : 'getPenaltyRates',
          'vehicleType' : vehicleType,
        },
        options: Options(
          preserveHeaderCase: true,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json', // Set content type to JSON
          },
        ),


      );

      if (kDebugMode) {
        print('The OffLoadingPenalty result is $result');
        print('The OffLoadingPenalty status code is ${result.statusCode}');
      }

      if (result.statusCode == 200) {
        final jsonData = result.data;
        final getOffLoadingPenalty = GetPenaltyRates.fromJson(jsonData);
        return getOffLoadingPenalty;
      } else {
        throw Exception('Error: ${result.data}');
      }
    } on SocketException {
      throw const SocketException('Bad Internet connection');
    } on FormatException catch (e) {
      throw FormatException('Bad response format: ${e.message}');
    } on DioException catch (e) {
      if (e.error is SocketException) {
        print('SocketException: ${e.error}');
        throw Exception('Bad Internet connection');
      } else {
        print('DioError: $e');
        // Checking if the response data is a Map
        if (e.response?.data is Map<String, dynamic>) {
          final responseData = e.response?.data;
          if (responseData.containsKey('message')) {
            throw Exception(responseData['message']);
          } else {
            throw Exception('Unknown error: $responseData');
          }
        } else if (e.response?.data is String) {
          // If response data is a String, throw it as an error
          throw Exception(e.response?.data);
        } else {
          throw Exception('Unknown error occurred.');
        }
      }
    }
  }



  /// PARKING MODULE
///
  Future<Map<String, dynamic>> checkParkingStatus({
    required String plateNum,
  }) async {
    Response? result;
    try {
      FormData formData = FormData.fromMap({
        "payCheck" : plateNum,
        "plate_num" : plateNum,
        "fetchKey" : Endpoints.SEC_KEY
      });
      result = await Dio().post(
        Endpoints.PARKING_URL, // Replace with your actual endpoint
        data: formData
      );

      if (kDebugMode) {
        print('The Permission result is $result');
        print('The Permission status code is ${result.statusCode}');
      }

      if (result.statusCode == 200) {
        return jsonDecode(result.data);
      } else {
        throw Exception('Error: ${result.data}');
      }
    } on SocketException {
      throw const SocketException('Bad Internet connection');
    } on FormatException catch (e) {
      throw FormatException('Bad response format: ${e.message}');
    } on DioException catch (e) {
      if (e.error is SocketException) {
        print('SocketException: ${e.error}');
        throw Exception('Bad Internet connection');
      } else {
        print('DioError: $e');
        // Checking if the response data is a Map
        if (e.response?.data is Map<String, dynamic>) {
          final responseData = e.response?.data;
          if (responseData.containsKey('message')) {
            throw Exception(responseData['message']);
          } else {
            throw Exception('Unknown error: $responseData');
          }
        } else if (e.response?.data is String) {
          // If response data is a String, throw it as an error
          throw Exception(e.response?.data);
        } else {
          throw Exception('Unknown error occurred.');
        }
      }
    }
  }


  Future<Map<String, GetMyZones>> getParkingZones() async {
    Response? result;
    try {
      // Make API call using Dio
      // result = await dio.post('${Endpoints.PARKING_ZONES}/');

      result = await dio.post('https://eportal.mombasa.go.ke/mobile/android/parking/fetchZones.php');

      if (kDebugMode && result != null) {
        print('The zones result is ${result.data}');
        print('The zones status code is ${result.statusCode}');
      }

      // Check for successful status code
      if (result?.statusCode != 200) {
        throw Exception('Failed to fetch zones. Status code: ${result?.statusCode}');
      }

      // Parse data directly since Dio already parses JSON response into a Map
      final dynamic data = (result!.data is String) ? jsonDecode(result.data) : result.data;

      if (data is! Map<String, dynamic>) {
        throw FormatException('Unexpected data format');
      }

      // Parse the data into GetMyZones
      return getMyZonesFromJson(jsonEncode(data)); // Convert Map to JSON String
    } on SocketException {
      throw const SocketException('Bad Internet');
    } on FormatException catch (e) {
      throw FormatException(e.toString());
    } on DioException catch (e) {
      if (e.error is SocketException) {
        print('SocketException: ${e.error}');
        throw Exception('Please Check Your Internet Connection');
      } else {
        print('DioError: $e');
        if (e.response != null) {
          print(
              'DioError Response: ${e.response!.statusCode}, ${e.response!.data}');
        }
        throw Exception(e.response?.data['message']);
      }
    }
  }


  Future<List<GetVehicleCategoriesModel>> getVehicleCategories() async {
    Response? response;
    try {
      FormData formData = FormData.fromMap({
        "secKey": '${Endpoints.SEC_KEY}'
      });

      response = await dio.post("${Endpoints.VEHICLE_CATEGORIES}", data: formData);

      if (response.statusCode != 200) {
        throw Exception('Server error: ${response.statusCode}');
      }

      final dynamic rawData = response.data;
      final List<dynamic> data = (rawData is String) ? jsonDecode(rawData) : rawData;

      if (kDebugMode) {
        print('The categories result is $rawData');
        print('The categories status code is ${response.statusCode}');
      }

      return data.map((json) => GetVehicleCategoriesModel.fromJson(json)).toList();

    }on SocketException {
      throw const SocketException('Bad Internet');
    } on FormatException catch (e) {
      throw FormatException(e.toString());
    } on DioException catch (e) {
      if (e.error is SocketException) {
        // Handle SocketException separately
        print('SocketException: ${e.error}');
        throw Exception('Please Check Your Internet Connection');
      } else {
        // Handle other DioError cases
        print('DioError: $e');
        if (e.response != null) {
          print(
              'DioError Response: ${e.response!.statusCode}, ${e.response!.data}');
        }
        throw Exception(e.response?.data['message']);
      }
    }

  }


  Future<Map<String, dynamic>> clampVehicle({
    required FormData formData,
  }) async {
    Response? result;
    try {
      result = await Dio().post(
          Endpoints.CLAMP_VEHICLE, // Replace with your actual endpoint
          data: formData
      );

      if (kDebugMode) {
        print('The Clamp result is $result');
        print('The Clamp status code is ${result.statusCode}');
      }

      if (result.statusCode == 200) {
        return jsonDecode(result.data);
      } else {
        throw Exception('Error: ${result.data}');
      }
    } on SocketException {
      throw const SocketException('Bad Internet connection');
    } on FormatException catch (e) {
      throw FormatException('Bad response format: ${e.message}');
    } on DioException catch (e) {
      if (e.error is SocketException) {
        print('SocketException: ${e.error}');
        throw Exception('Bad Internet connection');
      } else {
        print('DioError: $e');
        // Checking if the response data is a Map
        if (e.response?.data is Map<String, dynamic>) {
          final responseData = e.response?.data;
          if (responseData.containsKey('message')) {
            throw Exception(responseData['message']);
          } else {
            throw Exception('Unknown error: $responseData');
          }
        } else if (e.response?.data is String) {
          // If response data is a String, throw it as an error
          throw Exception(e.response?.data);
        } else {
          throw Exception('Unknown error occurred.');
        }
      }
    }
  }


  Future<GetMarketTollTypes> getMarketTollTypes({
    required String? token,
  }) async  {
    try {
      final response = await Dio().get(
        Endpoints.MARKET_URL, // Using the new MARKET_URL
        queryParameters: {
          'appType' : 'getCategories', // New appType as per request
        },
        options: Options(
          preserveHeaderCase: true,
          contentType: Headers.jsonContentType,
          headers: {
            'Authorization': 'Bearer ${token}',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final jsonData = response.data;
        // Parse all categories and cache them
        GetMarketTollCategories allCategories = GetMarketTollCategories.fromJson(jsonData);
        _marketCategoriesCache = allCategories.data;

        // Extract unique "types" from categories to satisfy existing UI "Toll Type" dropdown
        final uniqueTypes = _marketCategoriesCache!
            .map((e) => e.toJson()['type'] ?? (e.name?.split(' ').first ?? 'Other')) // Fallback logic if needed
            // Actually, the new API has a "type" field in it. Let's use the raw JSON "type"
            .toSet() 
            .toList();
        
        // Re-extracting properly from raw data to be sure
        final List<dynamic> rawData = jsonData['data'] ?? [];
        final typesSet = rawData.map((e) => e['type'].toString()).toSet().toList();

        final typesData = typesSet.asMap().entries.map((e) => MarketTollTypeDatum(
          id: e.key + 1, 
          name: e.key < typesSet.length ? typesSet[e.key] : 'Other'
        )).toList();

        return GetMarketTollTypes(status: 'success', data: typesData);
      } else {
        throw Exception();
      }
    } on SocketException {
      throw const SocketException('Bad Internet');
    } on FormatException catch (e) {
      throw FormatException(e.toString());
    } on DioException catch (e) {
      if (e.error is SocketException) {
        throw Exception('Connection error');
      } else {
        throw Exception(e.response?.data['message'] ?? 'Please check your Connection');
      }
    }
  }

  Future<GetMarketTollCategories> getMarketTollCategories({
    required String? token,
    required String? typeId,
  }) async  {
    // The UI passes typeId (1, 2, 3...) which we generated in getMarketTollTypes
    // We need to filter our cached categories by the corresponding type name.
    
    if (_marketCategoriesCache == null) {
      await getMarketTollTypes(token: token);
    }

    try {
      // Get the type name from getMarketTollTypes logic (re-running it briefly or using a static list)
      // For simplicity, we fetch all categories and filter. 
      // But we need the type name. Since we don't have a static list of names yet, we'll re-derive.
      
      final response = await Dio().get(
        Endpoints.MARKET_URL,
        queryParameters: {
          'appType' : 'getCategories',
        },
        options: Options(
          preserveHeaderCase: true,
          contentType: Headers.jsonContentType,
          headers: {
            'Authorization': 'Bearer ${token}',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final jsonData = response.data;
        final List<dynamic> rawData = jsonData['data'] ?? [];
        final typesSet = rawData.map((e) => e['type'].toString()).toSet().toList();
        
        int idx = int.tryParse(typeId ?? '1') ?? 1;
        String selectedTypeName = (idx > 0 && idx <= typesSet.length) ? typesSet[idx - 1] : '';

        final filteredRaw = rawData.where((e) => e['type'] == selectedTypeName).toList();
        final categories = filteredRaw.map((e) => MarketTollCategoryDatum.fromJson(e)).toList();

        return GetMarketTollCategories(status: 'success', data: categories);
      } else {
        throw Exception();
      }
    } catch (e) {
      throw Exception('Failed to load categories');
    }
  }

  Future<Map<String, dynamic>> promptMarketEntry({
    required String? token,
    required String? plateId,
    required String? phone,
    required String? typeId,
    required String? categoryId,
    required double? amount,
  }) async {
    try {
      // Determine isIdNumber based on the cached categories or a fresh fetch if necessary
      bool isIdNumber = false;
      if (_marketCategoriesCache != null) {
        final cat = _marketCategoriesCache!.firstWhereOrNull((e) => e.id.toString() == categoryId);
        if (cat != null) {
          isIdNumber = cat.isIdNumber == 1;
        }
      }

      final response = await Dio().post(
        Endpoints.MARKET_URL, 
        data: {
          'appType' : 'createOrder', 
          'identifier' : plateId,   
          'mobile' : phone,
          'marketId' : 1,           
          'categoryId' : int.tryParse(categoryId ?? '0') ?? 0,
          // 'amount' : amount,        
          'isIdNumber' : isIdNumber,
        },
        options: Options(
          preserveHeaderCase: true,
          contentType: Headers.jsonContentType,
          headers: {
            'Authorization': 'Bearer ${token}',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception();
      }
    } on SocketException {
      throw const SocketException('Bad Internet');
    } on FormatException catch (e) {
      throw FormatException(e.toString());
    } on DioException catch (e) {
      if (e.error is SocketException) {
        throw Exception('Connection error');
      } else {
        final data = e.response?.data;
        final msg = (data is Map) ? data['message'] : null;
        throw Exception(msg ?? 'Payment request failed. Please check your connection.');
      }
    }
  }

  Future<Map<String, dynamic>> checkMarketPaymentStatus({
  required String? token,
  required String? orderId, // 👈 pass orderId from promptMarketEntry response
}) async {
  try {
    final response = await Dio().get(
      Endpoints.MARKET_URL,
      queryParameters: {
        'appType': 'checkPaymentStatus',
        'orderId': orderId, // e.g. "MKTE-000042"
      },
      options: Options(
        preserveHeaderCase: true,
        contentType: Headers.jsonContentType,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    if (response.statusCode == 200) {
      final data = response.data;
      // Response shape:
      // {
      //   "status": "success",
      //   "orderStatus": "Completed",
      //   "message": "Payment successful",
      //   "receiptNo": "TESTING",
      //   "updatedAt": "2026-04-15 20:47:25"
      // }
      if (data['status'] == 'success' && data['orderStatus'] == 'Completed') {
        return {
          "status": "success",
          "data": "Completed",
          "receiptNo": data['receiptNo'] ?? '',
          "updatedAt": data['updatedAt'] ?? '',
          "message": data['message'] ?? '',
        };
      }

      return {
        "status": "success",
        "data": "Pending",
      };
    } else {
      throw Exception('Unexpected status code: ${response.statusCode}');
    }
  } on SocketException {
    throw const SocketException('Bad Internet');
  } on FormatException catch (e) {
    throw FormatException(e.toString());
  } on DioException catch (e) {
    if (e.error is SocketException) {
      throw Exception('Connection error');
    } else {
      return {"status": "success", "data": "Pending"};
    }
  }
}

  // CHECK MARKET STATISTICS
  Future<GetMarketStats> getMarketStats({
  required String? token,
}) async {
  try {
    final response = await dio.get(
      Endpoints.MARKET_URL,
      queryParameters: {
        'appType': 'getDailyTickets', // 👈 same endpoint as getPaidMarket
      },
      options: Options(
        preserveHeaderCase: true,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      ),
    );

    if (response.statusCode == 200) {
      final rawData = response.data;

      if (rawData == null || rawData is! Map || rawData['status'] != 'success') {
        return GetMarketStats.fromJson({
          "status": "success",
          "daily_stats":   {"paid_market": "0", "total_amount": "0.00"},
          "monthly_stats": {"paid_market": "0", "total_amount": "0.00"},
        });
      }

      final List<dynamic> tickets = rawData['tickets'] ?? []; // 👈 was 'data'

      // Sum amounts from charge field
      double totalAmount = tickets.fold(0.0, (sum, e) =>
          sum + (double.tryParse(e['charge']?.toString() ?? '0') ?? 0.0));

      return GetMarketStats.fromJson({
        "status": "success",
        "daily_stats": {
          "paid_market":  tickets.length.toString(), // 👈 count of tickets
          "total_amount": totalAmount.toStringAsFixed(2),
        },
        "monthly_stats": {
          "paid_market":  tickets.length.toString(),
          "total_amount": totalAmount.toStringAsFixed(2),
        },
      });
    } else {
      throw Exception();
    }
  } on SocketException {
    throw const SocketException('Bad Internet');
  } on FormatException catch (e) {
    throw FormatException(e.toString());
  } on DioException catch (e) {
    if (e.error is SocketException) {
      throw Exception('Connection error');
    } else {
      throw Exception(e.response?.data['message'] ?? 'Please check your Connection');
    }
  }
}
  Future<PaidMarket> getPaidMarket({
    required String? token,
  }) async {
    try {
      final response = await Dio().get(
        Endpoints.MARKET_URL, 
        queryParameters: {
          'appType' : 'getDailyTickets',
        },
        options: Options(
          preserveHeaderCase: true,
          contentType: Headers.jsonContentType,
          headers: {
            'Authorization': 'Bearer ${token}',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        if (response.data == null || response.data is String) {
          return PaidMarket(status: 'success', data: []);
        }
        final jsonData = response.data;
        return PaidMarket.fromJson(jsonData);
      } else {
        throw Exception();
      }
    } on SocketException {
      throw const SocketException('Bad Internet');
    } on FormatException catch (e) {
      throw FormatException(e.toString());
    } on DioException catch (e) {
      if (e.error is SocketException) {
        throw Exception('Connection error');
      } else {
        throw Exception(e.response?.data['message'] ?? 'Please check your Connection');
      }
    }
  }

}
