import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final roleOptions = ['admin', 'customer'];
  String selectedRole = 'customer';
  String error = '';
  bool loading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Lock orientation to portrait when entering register page
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    // Restore all orientations when leaving register page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    });
    super.dispose();
  }

  Future<void> register() async {
    // Validate inputs first
    if (emailController.text.isEmpty) {
      setState(() => error = 'Email tidak boleh kosong');
      return;
    }

    if (!emailController.text.contains('@')) {
      setState(() => error = 'Email tidak valid');
      return;
    }

    if (passwordController.text.isEmpty) {
      setState(() => error = 'Password tidak boleh kosong');
      return;
    }

    if (passwordController.text.length < 6) {
      setState(() => error = 'Password minimal 6 karakter');
      return;
    }

    setState(() => loading = true);
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set({'email': emailController.text, 'role': selectedRole});

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      String errorMsg = 'Gagal daftar';
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            errorMsg = 'Email sudah terdaftar';
            break;
          case 'invalid-email':
            errorMsg = 'Format email tidak valid';
            break;
          case 'weak-password':
            errorMsg = 'Password terlalu lemah';
            break;
          default:
            errorMsg = 'Gagal daftar: ${e.code}';
        }
      } else {
        errorMsg = 'Gagal daftar: ${e.toString()}';
      }
      setState(() => error = errorMsg);
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.lightBlue[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/icon.png',
                          width: 48,
                          height: 48,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email tidak boleh kosong';
                        }
                        if (!value.contains('@')) {
                          return 'Email tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password tidak boleh kosong';
                        }
                        if (value.length < 6) {
                          return 'Password minimal 6 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    if (error.isNotEmpty)
                      Text(error, style: const TextStyle(color: Colors.red)),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed:
                            loading
                                ? null
                                : () {
                                  if (_formKey.currentState!.validate()) {
                                    register();
                                  }
                                },
                        child:
                            loading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : const Text(
                                  "Daftar",
                                  style: TextStyle(color: Colors.white),
                                ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacementNamed(context, '/'),
                      child: const Text(
                        "Sudah punya akun? Login di sini",
                        style: TextStyle(
                          color: Colors.lightBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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
