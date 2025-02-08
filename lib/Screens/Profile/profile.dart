
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../Authentication/changePassword.dart';
import '../Dashboard/dashboard.dart';
import '../appDrawer.dart';






class profile extends StatefulWidget {
  const profile({super.key});

  @override
  State<profile> createState() => _profileState();
}




class _profileState extends State<profile> {


  late SharedPreferences prefs;
  final _kId = "id_preference";
  final _kemail = "email_preference";
  final _firstName = 'firstName_preference';
  final _lastName = 'lastName_preference';
  final _kmobile = "mobile_preference";
  final _token = 'token_preference';

  String? phone = '';
  String? email = '';
  String? firstName = '';
  String? lastName = '';
  String? token = '';

  Future<void> _loadUserData() async {
    prefs = await SharedPreferences.getInstance();

    // Fetch user data from SharedPreferences
    setState(() {
      firstName = prefs.getString(_firstName) ?? '';
      lastName = prefs.getString(_lastName) ?? '';
      phone = prefs.getString(_kmobile ?? '' ) ;
      email = prefs.getString(_kemail) ?? '';

    });


  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    Size size = MediaQuery.of(context).size;
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
            "User Profile",
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
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20))),
          child: ScrollConfiguration(
            behavior: ScrollBehavior().copyWith(overscroll: false),
            child: SingleChildScrollView(
              child:Padding(
                padding: const EdgeInsets.only(top: 15.0, left: 20, right: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 15.0,
                    ),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.asset(
                            'assets/images/profile.png',
                            fit: BoxFit.cover,
                          )
                      ),
                    ),


                    const SizedBox(
                      height: 12,
                    ),
                    Text(
                      "${firstName} ${lastName}" ?? 'N/A',
                      style: GoogleFonts.manrope(
                        // fontSize: 18,
                        fontSize: fontSize* 1.3,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                        // letterSpacing: 1
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text("County Government Enforcer",   style: GoogleFonts.manrope(
                      // fontSize: 16,
                      fontSize: fontSize* 1.2,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                      // letterSpacing: 1
                    ),),
                    const SizedBox(
                      height: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0,bottom: 20, right: 10,left: 10),
                      child: Column(
                        children: [
                          Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.call_outlined,
                                    color: Color(0xFFE15858),
                                  ),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Mobile',
                                        style: GoogleFonts.manrope(
                                          fontSize: fontSize* 1.1,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        phone! ?? "N/A",
                                        style: GoogleFonts.manrope(
                                          fontSize: fontSize* 1.1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Divider(
                                color: Colors.grey,
                                thickness: 0.5,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.email_outlined,
                                    color: Color(0xFF9367B4),
                                  ),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Email',
                                        style: GoogleFonts.manrope(
                                          fontSize: fontSize* 1.1,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        email!,
                                        style: GoogleFonts.manrope(
                                          fontSize: fontSize* 1.1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Divider(
                                color: Colors.grey,
                                thickness: 0.5,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          InkWell(
                            onTap: (){
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (c) => ChangePassword()));
                            },
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.lock_clock,
                                      color:  Color(0xFFE25985),
                                    ),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Password',
                                          style: GoogleFonts.manrope(
                                            fontSize: fontSize* 1.1,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          "Change Password",
                                          style: GoogleFonts.manrope(
                                            fontSize: fontSize* 1.1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Divider(
                                  color: Colors.grey,
                                  thickness: 0.5,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),

                        ],
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),
        ),

    );}
}
