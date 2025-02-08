import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';


class userData{
   static String? token;
   static String? userId;
   static String? firstName;
   static String? lastName;
   static String? fullName;
   static String? email;
   static String? mobile;


   static Future<void> loadFromPreferences() async {

      final _kId = "id_preference";
      final _kemail = "email_preference";
      final _firstName = 'firstName_preference';
      final _lastName = 'lastName_preference';
      final _kmobile = "mobile_preference";
      final _token = 'token_preference';


      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // Load each field from SharedPreferences and assign it to UserData
      userId = prefs.getString(_kId);
      email = prefs.getString(_kemail);
      firstName = prefs.getString(_firstName);
      lastName = prefs.getString(_lastName);
      mobile = prefs.getString(_kmobile);
      token = prefs.getString(_token);


   }


}