import 'package:flutter/material.dart';
import '../../repositories/fogotpasswordapi.dart';
import '../login.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key, required this.email});

  final String email;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  Future<void> _submit() async {
    final pass = _passCtrl.text;
    final confirm = _confirmCtrl.text;

    if (pass.isEmpty || confirm.isEmpty) {
      _snack('Please fill every field');
      return;
    }
    if (pass != confirm) {
      _snack('Passwords don’t match');
      return;
    }

    setState(() => _loading = true);
    try {
      await PasswordApi.resetPassword(widget.email, pass);

      if (mounted) {
        _snack('Password updated! Please login.');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) =>  LoginPage()),
          (_) => false,
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

    OutlineInputBorder border(Color color) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: color),
        );

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/nail_bg.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 80),
                   
                    const SizedBox(height: 100),
                    const Text(
                      'Set New Password',
                      style: TextStyle(
                        fontFamily: 'Brown Sugar',
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 201, 152, 79),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 25),

                    // ── New Password ─────────────────────────
                    TextField(
                      controller: _passCtrl,
                      obscureText: _obscure,
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        labelText: 'New password',
                        labelStyle: const TextStyle(color: Colors.grey),
                        border: border(Colors.grey.shade400),
                        focusedBorder: border(brand),
                        suffixIcon: IconButton(
                          icon: Icon(
                              _obscure ? Icons.visibility : Icons.visibility_off),
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 12),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Confirm Password ─────────────────────
                    TextField(
                      controller: _confirmCtrl,
                      obscureText: _obscure,
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        labelText: 'Confirm password',
                        labelStyle: const TextStyle(color: Colors.grey),
                        border: border(Colors.grey.shade400),
                        focusedBorder: border(brand),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 12),
                      ),
                    ),
                    const SizedBox(height: 50),

                    // ── Update Button ────────────────────────
                    SizedBox(
                      width: 250,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        style:
                            ElevatedButton.styleFrom(backgroundColor: brand),
                        child: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text(
                                'UPDATE',
                                style: TextStyle(
                                    color: Colors.white,
                                  ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}