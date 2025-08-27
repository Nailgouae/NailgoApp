import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:nailgonew/screens/forgotpassword/forgot_password.dart';
import 'package:nailgonew/screens/home.dart';
import 'package:nailgonew/screens/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

   bool _passwordVisible = false;   

  Future<void> loginUser(BuildContext context) async {
    final String apiUrl = "http://nailgo.ae/api/v2/auth/login";

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        "X-Requested-With": "XMLHttpRequest",
      },
      body: jsonEncode({
        "email": emailController.text,
        "password": passwordController.text,
        "identity_matrix": "ec669dad-9136-439d-b8f4-80298e7e6f37",
      }),
    );

    if (response.statusCode == 200) {
      print(response.body);
      Map<String, dynamic> responseData = json.decode(response.body);
      String accessToken = responseData['access_token'];
      String userId = responseData['user']['id'].toString();
      String userName = responseData['user']['name'];
      String userEmail = responseData['user']['email'];
      //String userPhone = responseData['user']['phone'];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLoggedIn', true);
      prefs.setString('userId', userId);
      prefs.setString('userName', userName);
      prefs.setString('userEmail', userEmail);
      prefs.setString('accessToken', accessToken);
      // prefs.setString('userPhone', userPhone);
      // Successful login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login successful!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login failed. Please check your credentials."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

 @override
Widget build(BuildContext context) {
  return WillPopScope(
    onWillPop: () async {
      await SystemNavigator.pop();
      return true;
    },
    child: Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/nail_bg.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 80),
                    const Text(
                      'Welcome',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 201, 152, 79),
                        fontSize: 23,
                        fontFamily: 'Brown Sugar',
                      ),
                    ),
                    const SizedBox(height: 100),
                    const Text(
                      "Login",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 201, 152, 79),
                        fontSize: 23,
                        fontFamily: 'Brown Sugar',
                      ),
                    ),
                    const SizedBox(height: 25),
                    TextField(
                      cursorColor: Colors.black,
                      controller: emailController,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        labelText: ' Email or Phone number',
                        labelStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 12.0),
                      ),
                    ),
                    const SizedBox(height: 20),
                  TextField(
                        cursorColor: Colors.black,
                        controller: passwordController,
                        obscureText: !_passwordVisible,
                        decoration: InputDecoration(
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          labelText: 'Password',
                          labelStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 12.0),
                          // 👇 eye / eye-off toggle
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() => _passwordVisible = !_passwordVisible);
                            },
                          ),
                        ),
                      ),
                    Align(
  alignment: Alignment.centerRight,
  child: TextButton(
    style: TextButton.styleFrom(
      padding: EdgeInsets.zero,                // no extra hit zone
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ForgotPassword()),
      );
    },
    child: const Text(
      'Forgot password?',
      style: TextStyle(
        color: Color.fromARGB(255, 185, 92, 4), // same accent as “Sign up”
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),
                    const SizedBox(height: 50),
                    Container(
                      width: 250,
                      child: ElevatedButton(
                        onPressed: () async {
                          loginUser(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(218, 212, 90, 19),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        child: Text(
                          'Login',
                          style: TextStyle(
                              color: Colors.white, fontFamily: 'Brown Sugar'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w400),
                        ),
                        SizedBox(width: 5),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignupPage()),
                            );
                          },
                          child: Text(
                            "Sign up",
                            style: TextStyle(
                                color: Color.fromARGB(255, 185, 92, 4),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30), // bottom padding
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}
}