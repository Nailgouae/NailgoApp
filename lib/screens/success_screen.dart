import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nailgonew/screens/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Success extends StatefulWidget {
  const Success({super.key});

  @override
  State<Success> createState() => _SuccessState();
}

class _SuccessState extends State<Success> {
  @override
  void initState() {
    super.initState();
    _callPaymentStatusUpdateApi();
  }

  Future<void> _callPaymentStatusUpdateApi() async {
    try {
      final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId'); // use same key as set earlier
      if (userId == null) return;

      var uri = Uri.parse("http://nailgo.ae/api/v2/payment_status_update");
      var request = http.MultipartRequest('POST', uri);
      request.fields['user_id'] = userId;

      var response = await request.send();

      if (response.statusCode == 200) {
        print("Payment status updated successfully.");
      } else {
        print("Failed to update payment status.");
      }
    } catch (e) {
      print("Error calling payment status update: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => Home()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/tick.jpeg',
                  width: 200,
                  height: 200,
                ),
                SizedBox(height: 20),
                Text(
                  'successdialogue'.tr(),
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                SizedBox(height: 20),
                InkWell(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (context) => Home()),
  (Route<dynamic> route) => false, // Remove all previous routes
);

                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 185, 92, 4),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    height: 50,
                    width: 220,
                    child: Center(
                      child: Text(
                        'continueshopping'.tr(),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
