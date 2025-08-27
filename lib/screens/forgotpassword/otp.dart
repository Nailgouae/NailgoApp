import 'package:flutter/material.dart';
import 'package:nailgonew/screens/forgotpassword/reset_password.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../repositories/fogotpasswordapi.dart';


class OtpPage extends StatefulWidget {
  const OtpPage({super.key, required this.email});

  final String email;

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _otpController = TextEditingController();
  bool _loading = false;

  Future<void> _verify() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      _snack('Enter the full 6-digit OTP');
      return;
    }

    setState(() => _loading = true);
    try {
      await PasswordApi.verifyOtp(widget.email, otp);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResetPasswordPage(email: widget.email),
          ),
        );
      }
    } catch (e) {
      _snack('$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

 @override
Widget build(BuildContext context) {
  const brand = Color.fromARGB(218, 212, 90, 19);

  return Scaffold(
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            // give the scroll view a finite height
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(        // <-- NEW
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/nail_bg.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 100),
                      const Text(
                        'Verify OTP',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 201, 152, 79),
                          fontSize: 23,
                          fontFamily: 'Brown Sugar',
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'We’ve sent a 6-digit code to',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        widget.email,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 40),

                      // Pin code field …
                      PinCodeTextField(
                        length: 6,
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        animationType: AnimationType.fade,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(8),
                          fieldHeight: 48,
                          fieldWidth: 40,
                          activeFillColor: Colors.white,
                          inactiveFillColor: Colors.white,
                          selectedFillColor: Colors.white,
                          activeColor: brand,
                          selectedColor: brand,
                          inactiveColor: Colors.grey.shade400,
                        ),
                        animationDuration: const Duration(milliseconds: 250),
                        enableActiveFill: true,
                        onChanged: (_) {},
                        appContext: context,
                      ),

                      const SizedBox(height: 32),
                      SizedBox(
                        width: 180,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _verify,
                          style: ElevatedButton.styleFrom(backgroundColor: brand,foregroundColor: Colors.white),
                          child: _loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Verify'),
                        ),
                      ),

                      const Spacer(), // now legal because of IntrinsicHeight
                      TextButton(
                        onPressed: _loading ? null : _verify,
                        child: const Text('Resend Code'),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
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