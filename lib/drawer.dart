import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nailgonew/localizationchecker.dart';
import 'package:nailgonew/screens/cart.dart';
import 'package:nailgonew/screens/direction_screen.dart';
import 'package:nailgonew/screens/login.dart';
import 'package:nailgonew/screens/profile_screen.dart';
import 'package:nailgonew/screens/wishlist_screen.dart';
import 'package:nailgonew/services/custom_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({
    Key? key,
  }) : super(key: key);

  @override
  _MainDrawerState createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  bool isLoggedIn = false;
  String userName = '';
  String userEmail = '';
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
    _loadUserName();
  }

  Future<void> checkLoginStatus() async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      //isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      if (isLoggedIn) {
        // userName = prefs.getString('userName') ?? '';
        // userEmail = prefs.getString('userEmail') ?? '';
      }
    });
  }

  void _logOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Text(
            "are".tr(),
            style: TextStyle(color: Colors.black, fontSize: 20),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "cancel".tr(),
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () async {
                await _performLogout(context);
              },
              child: Text(
                "log".tr(),
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? '';
    });
  }

  final String url = "https://nailgo.ae/requestform";

  Future<void> _openBrowser(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // safer & more reliable
      );
      if (!launched) {
        throw Exception("Could not launch $url");
      }
    } catch (e) {
      debugPrint('Launch error: $e');
      // Optional: Show a snackbar or dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not open the link.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.only(top: 50),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                color: Colors.white,
                alignment: Alignment.center,
                padding: const EdgeInsets.only(right: 30, bottom: 20),
                child: Container(
                  height: 150,
                  color: Color.fromARGB(255, 101, 132, 158),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 48,
                      ),
                      Text(
                        userName.isEmpty ? '' : userName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                  visualDensity:
                      const VisualDensity(horizontal: -4, vertical: -4),
                  leading: Image.asset(
                    'assets/person_ic.png',
                    height: 24,
                    color: Color.fromRGBO(153, 153, 153, 1),
                  ),
                  title: Text('profile'.tr(),
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                          fontSize: 18)),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return UserProfileScreen();
                    }));
                  }),
              SizedBox(
                height: 20,
              ),
              ListTile(
                  visualDensity:
                      const VisualDensity(horizontal: -4, vertical: -4),
                  leading: Image.asset(
                    'assets/lang.webp',
                    height: 24,
                    color: Color.fromRGBO(153, 153, 153, 1),
                  ),
                  title: Text('change'.tr(),
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                          fontSize: 18)),
                  onTap: () {
                    LocalizationChecker.changeLanguage(context);
                  }),
              SizedBox(
                height: 20,
              ),
              ListTile(
                  visualDensity:
                      const VisualDensity(horizontal: -4, vertical: -4),
                  leading: Image.asset(
                    'assets/heart.png',
                    height: 24,
                    color: Color.fromRGBO(153, 153, 153, 1),
                  ),
                  title: Text('wish'.tr(),
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                          fontSize: 18)),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return WishlistScreen();
                    }));
                  }),
              SizedBox(
                height: 20,
              ),
              ListTile(
                  visualDensity:
                      const VisualDensity(horizontal: -4, vertical: -4),
                  leading: Image.asset(
                    'assets/cart_ic.png',
                    height: 24,
                    color: Color.fromRGBO(153, 153, 153, 1),
                  ),
                  title: Text('cart'.tr(),
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                          fontSize: 18)),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return CartPage();
                    }));
                  }),
              SizedBox(
                height: 20,
              ),
              ListTile(
                  visualDensity:
                      const VisualDensity(horizontal: -4, vertical: -4),
                  leading: Image.asset(
                    'assets/headphone_ic.png',
                    height: 24,
                    color: Color.fromRGBO(153, 153, 153, 1),
                  ),
                  title: Text('service'.tr(),
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                          fontSize: 18)),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return CustomService();
                    }));
                  }),
              SizedBox(
                height: 20,
              ),
              ListTile(
                visualDensity:
                    const VisualDensity(horizontal: -4, vertical: -4),
                leading: Image.asset(
                  'assets/delete.png',
                  height: 24,
                ),
                title: Text(
                  'deleteAccount'.tr(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                    fontSize: 18,
                  ),
                ),
                onTap: () {
                  _openBrowser(url);
                },
              ),

              SizedBox(
                height: 20,
              ),
              ListTile(
                  visualDensity:
                      const VisualDensity(horizontal: -4, vertical: -4),
                  leading: Image.asset(
                    'assets/power_ic.png',
                    height: 24,
                    color: Color.fromRGBO(153, 153, 153, 1),
                  ),
                  title: Text('logout'.tr(),
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                          fontSize: 18)),
                  onTap: () {
                    _logOut(context);
                  }),
              //   ListTile(
              // visualDensity:
              //     const VisualDensity(horizontal: -4, vertical: -4),
              // leading: Image.asset(
              //   'assets/cart_ic.png',
              //   height: 24,
              //   color: Colors.red,
              // ),
              // title: Text('test',
              //     style: TextStyle(
              //         color: Colors.black,
              //         fontWeight: FontWeight.w400,
              //         fontSize: 18)),
              // onTap: () {
              //   Navigator.push(context,
              //       MaterialPageRoute(builder: (context) {
              //     return LoadingPage();
              //   }));
              // }),
            ],
          ),
        ),
      ),
    );
  }
}
