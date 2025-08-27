import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nailgonew/repositories/fogotpasswordapi.dart';
import 'package:nailgonew/screens/forgotpassword/otp.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
   final TextEditingController emailController = TextEditingController();
   @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Close the app when the user presses the back button on this screen.
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
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/nail_bg.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                    
      
                      const SizedBox(height: 180),
                      const Text(
                        'Forgot Password',
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
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          labelText: ' Enter Your Email',
                          labelStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 12.0),
                        ),
                      ),
                      const SizedBox(height: 50),
                      SizedBox(
                        width: 250,
                        child: ElevatedButton(
                         onPressed: () async {
  final email = emailController.text.trim();

  if (email.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Enter your e-mail first')),
    );
    return;
  }

  showDialog(                       // simple loading dialog
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.black,strokeWidth: 2,)),
  );

  try {
    await PasswordApi.sendResetRequest(email);
    Navigator.pop(context);         // close loader
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OtpPage(email: email)),
    );
  } catch (e) {
    Navigator.pop(context);         // close loader
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$e')),
    );
  }
},
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(218, 212, 90, 19),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                          child: const Text(
                            'Send Reset Link',
                            style: TextStyle(
                                color: Colors.white, ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context); // Back to login
                        },
                        child: const Text(
                          'Back to Login',
                          style: TextStyle(
                              color: Color.fromARGB(255, 185, 92, 4),
                              fontWeight: FontWeight.bold),
                        ),
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

  /// Replace this stub with your own password-reset logic.
  Future<void> resetPassword(BuildContext context) async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter your email or phone number.'),
      ));
      return;
    }

    // TODO: Integrate with your backend/Firebase to send the reset link or OTP.
    // Example:
    // await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('If the account exists, a reset link has been sent.'),
    ));
  }
}