import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nailgonew/screens/home.dart';

class NotSuccess extends StatefulWidget {
  const NotSuccess({super.key});

  @override
  State<NotSuccess> createState() => _NotSuccessState();
}

class _NotSuccessState extends State<NotSuccess> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/warning.png',
                width: 200,
                height: 200,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'paymentunsuccesful'.tr(),
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              SizedBox(height: 10),
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
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
