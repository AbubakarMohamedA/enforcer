import 'package:enforcer/splashScreen.dart';
import 'package:enforcer/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:provider/provider.dart';

import 'Screens/Parking/Controllers/clampingController.dart';
import 'Screens/Parking/Controllers/parkingController.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp( MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => parkingController()),
        ChangeNotifierProvider(create: (context) => clampingController()),
      ],
      child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Msa Enforce App',
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primarySwatch: Colors.blue,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            backgroundColor: const  Color(0xFF0D00DF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide.none,
            ),
            elevation: 0,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          fillColor: const Color(0xFFFBFBFB),
          filled: true,
          border: defaultOutlineInputBorder,
          // enabledBorder: defaultOutlineInputBorder,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF46B1FD)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            // borderSide: const BorderSide(color: Color(0xFFF2994A)),
            // borderSide: const BorderSide(color: Color(0xFFEF5828)),
            borderSide: const BorderSide(color: Color(0xFF46B1FD)),

          ),

        ),
      ),
    );
  }
}

