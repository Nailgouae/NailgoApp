import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nailgonew/screens/camera_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';




class LoadingPage extends StatefulWidget {
  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
   @override
  void initState() {
    super.initState();
    _clearFingerData();
  }
    Future<void> _clearFingerData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('finger_details'); // Remove finger data key
    print('Finger data cleared');
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(13.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 40,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'fourfingerinstruction'.tr(),
                  style: TextStyle(color: Colors.black,fontSize: 15),
                ),
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(),
                height: 300, width: 300, child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset('assets/four.jpeg'))),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'fourfingerinstruction2'.tr(),
                  style: TextStyle( color: Colors.black,fontSize: 15),
                ),
              ),
              SizedBox(height: 60),
              BrownButton(
                label: 'continue'.tr(),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => CameraScreen())
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BrownButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  BrownButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 250,
        height: 50,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 185, 92, 4),
        
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
